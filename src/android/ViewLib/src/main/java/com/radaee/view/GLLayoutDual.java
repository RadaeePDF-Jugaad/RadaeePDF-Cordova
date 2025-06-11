package com.radaee.view;

import android.content.Context;

import com.radaee.pdf.Global;

import javax.microedition.khronos.opengles.GL10;

public class GLLayoutDual extends GLLayout {
    public static final int SCALE_NONE = 0;
    public static final int SCALE_SAME_WIDTH = 1;
    public static final int SCALE_SAME_HEIGHT = 2;
    public static final int SCALE_FIT = 3;
    public static final int ALIGN_CENTER = 0;
    public static final int ALIGN_TOP = 1;
    public static final int ALIGN_BOTTOM = 2;
    private final boolean[] m_vert_dual;
    private final boolean[] m_horz_dual;
    private final boolean m_rtol;
    private final int m_align_type;
    private final int m_scale_mode;

    private static class PDFCell {
        int left;
        int right;
        float scale;
        int page_left;
        int page_right;
    }

    private PDFCell[] m_cells;

    public GLLayoutDual(Context context, int align, int scale_mode, boolean rtol, boolean[] horz_dual, boolean[] vert_dual) {
        super(context);
        m_horz_dual = horz_dual;
        m_vert_dual = vert_dual;
        m_align_type = align;
        m_scale_mode = scale_mode;
        m_rtol = rtol;
    }

    private int range_p0(int vx, int vy)
    {
        int icell = get_cell(vx + vGetX());
        if (icell < 0) icell = 0;
        if (icell >= m_cells.length) icell = m_cells.length - 1;
        PDFCell cell = m_cells[icell];
        if (cell.page_right < 0) return cell.page_left;
        if (cell.page_left > cell.page_right) return cell.page_right;
        else return cell.page_left;
    }
    private int range_p1(int vx, int vy)
    {
        int icell = get_cell(vx + vGetX());
        if (icell < 0) icell = 0;
        if (icell >= m_cells.length) icell = m_cells.length - 1;
        PDFCell cell = m_cells[icell];
        if (cell.page_right < 0) return cell.page_left;
        if (cell.page_left > cell.page_right) return cell.page_left;
        else return cell.page_right;
    }
    @Override
    protected void gl_flush_range(GL10 gl10)
    {
        if(!m_scroller.computeScrollOffset() && m_pageno2 > m_pageno1) return;
        int pageno1 = -1;
        int pageno2 = -1;
        if(m_rtol)
        {
            pageno1 = range_p1(-m_vw - GLBlock.m_cell_size, -GLBlock.m_cell_size);
            pageno2 = range_p0(m_vw * 2 + GLBlock.m_cell_size, m_vh + GLBlock.m_cell_size);
        }
        else
        {
            pageno1 = range_p0(-m_vw - GLBlock.m_cell_size, -GLBlock.m_cell_size);
            pageno2 = range_p1(m_vw * 2 + GLBlock.m_cell_size, m_vh + GLBlock.m_cell_size);
        }
        if( pageno1 >= 0 && pageno2 >= 0 )
        {
            if( pageno1 > pageno2 )
            {
                int tmp = pageno1;
                pageno1 = pageno2;
                pageno2 = tmp;
            }
            pageno2++;
            if( m_pageno1 < pageno1 )
            {
                int start = m_pageno1;
                int end = pageno1;
                if( end > m_pageno2 ) end = m_pageno2;
                while( start < end )
                {
                    GLPage vpage = m_pages[start];
                    vpage.gl_end_zoom(gl10, m_thread);
                    vpage.gl_end(gl10, m_thread);
                    start++;
                }
            }
            if( m_pageno2 > pageno2 )
            {
                int start = pageno2;
                int end = m_pageno2;
                if( start < m_pageno1 ) start = m_pageno1;
                while( start < end )
                {
                    GLPage vpage = m_pages[start];
                    vpage.gl_end_zoom(gl10, m_thread);
                    vpage.gl_end(gl10, m_thread);
                    start++;
                }
            }
        }
        else
        {
            int start = m_pageno1;
            int end = m_pageno2;
            while( start < end )
            {
                GLPage vpage = m_pages[start];
                vpage.gl_end_zoom(gl10, m_thread);
                vpage.gl_end(gl10, m_thread);
                start++;
            }
        }
        m_pageno1 = pageno1;
        m_pageno2 = pageno2;
    }
    @Override
    public void gl_draw(GL10 gl10) {
        if (m_doc == null) return;
        gl_flush_range(gl10);
        int vx = vGetX();
        int vy = vGetY();
        for (int pcur = m_pageno1; pcur < m_pageno2; pcur++)
            m_pages[pcur].gl_draw2(gl10, m_thread, m_def_text, vx, vy, m_vw, m_vh);
    }
    @Override
    public int vGetPage(int vx, int vy) {
        if (m_vw <= 0 || m_vh <= 0) return -1;
        vx += vGetX();
        int pl = 0;
        int pr = m_cells.length - 1;
        int hg = (m_page_gap >> 1);
        while (pr >= pl) {
            int mid = (pl + pr) >> 1;
            PDFCell pmid = m_cells[mid];
            if (vx < pmid.left - hg)
                pr = mid - 1;
            else if (vx >= pmid.right + hg)
                pl = mid + 1;
            else {
                GLPage page = m_pages[pmid.page_left];
                if (vx >= page.GetRight() && pmid.page_right >= 0) return pmid.page_right;
                else return pmid.page_left;
            }
        }
        int mid = (pr < 0) ? 0 : pr;
        PDFCell pmid = m_cells[mid];
        GLPage page = m_pages[pmid.page_left];
        if (vx >= page.GetRight() && pmid.page_right >= 0) return pmid.page_right;
        else return pmid.page_left;
    }

    private static boolean dual_at(boolean[] para, int icell) {
        if (para == null || icell >= para.length) return false;
        return para[icell];
    }

    private void layout_ltor(float scale, boolean zoom, boolean[] para) {
        if (m_vw <= 0 || m_vh <= 0) return;
        float maxw = 0;
        float maxh = 0;
        int minscalew = 0x40000000;
        int minscaleh = 0x40000000;
        int pcur = 0;
        int ccnt = 0;
        while (pcur < m_page_cnt) {
            float cw = m_doc.GetPageWidth(pcur);
            float ch = m_doc.GetPageHeight(pcur);
            if (dual_at(para, ccnt)) {
                if (pcur < m_page_cnt - 1) {
                    cw += m_doc.GetPageWidth(pcur + 1);
                    float ch2 = m_doc.GetPageHeight(pcur + 1);
                    if (ch < ch2) ch = ch2;
                    pcur += 2;
                } else pcur++;
            } else pcur++;
            if (maxw < cw) maxw = cw;
            if (maxh < ch) maxh = ch;
            float scalew = (m_vw - m_page_gap) / cw;
            float scaleh = (m_vh - m_page_gap) / ch;
            if (scalew > scaleh) scalew = scaleh;
            cw *= scalew;
            ch *= scalew;
            if (minscalew > (int) cw) minscalew = (int) cw;
            if (minscaleh > (int) ch) minscaleh = (int) ch;
            ccnt++;
        }

        boolean changed = (m_cells == null || m_cells.length != ccnt);
        if (changed) m_cells = new PDFCell[ccnt];
        m_scale_min = (float) (m_vw - m_page_gap) / maxw;
        float scalew;
        float scaleh = (float) (m_vh - m_page_gap) / maxh;
        if (m_scale_min > scaleh) m_scale_min = scaleh;
        float max_scale = m_scale_min * m_max_zoom;
        if (scale < m_scale_min) scale = m_scale_min;
        if (scale > max_scale) scale = max_scale;
        //if(m_scale == scale) return;
        m_scale = scale;
        m_layw = 0;
        m_layh = 0;
        pcur = 0;
        for (int ccur = 0; ccur < ccnt; ccur++) {
            float cw = m_doc.GetPageWidth(pcur);
            float ch = m_doc.GetPageHeight(pcur);
            if (changed) m_cells[ccur] = new PDFCell();
            PDFCell cell = m_cells[ccur];
            if (dual_at(para, ccur)) {
                if (pcur < m_page_cnt - 1) {
                    cw += m_doc.GetPageWidth(pcur + 1);
                    float ch2 = m_doc.GetPageHeight(pcur + 1);
                    if (ch < ch2) ch = ch2;

                    cell.page_left = pcur;
                    cell.page_right = pcur + 1;
                    pcur += 2;
                } else {
                    cell.page_left = pcur++;
                    cell.page_right = -1;
                }
            } else {
                cell.page_left = pcur++;
                cell.page_right = -1;
            }
            switch (m_scale_mode) {
                case SCALE_SAME_WIDTH:
                    scalew = minscalew / cw;
                    cell.scale = scalew / m_scale_min;
                    break;
                case SCALE_SAME_HEIGHT:
                    scaleh = minscaleh / ch;
                    cell.scale = scaleh / m_scale_min;
                    break;
                case SCALE_FIT:
                    scalew = (m_vw - m_page_gap) / cw;
                    scaleh = (m_vh - m_page_gap) / ch;
                    cell.scale = ((scalew > scaleh) ? scaleh : scalew) / m_scale_min;
                    break;
                default:
                    cell.scale = 1;
                    break;
            }
            cell.left = m_layw;
            int cellw = (int) (cw * scale * cell.scale) + m_page_gap;
            int cellh = (int) (ch * scale * cell.scale) + m_page_gap;
            int x = m_page_gap >> 1;
            int y = m_page_gap >> 1;
            if (cellw < m_vw) {
                x = (m_vw - cellw) >> 1;
                cellw = m_vw;
            }
            switch (m_align_type) {
                case ALIGN_TOP:
                    if (cellh < m_vh) {
                        cellh = m_vh;
                    }
                    break;
                case ALIGN_BOTTOM:
                    if (cellh < m_vh) {
                        y = (m_vh - cellh) - (m_page_gap >> 1);
                        cellh = m_vh;
                    }
                    break;
                default:
                    if (cellh < m_vh) {
                        y = (m_vh - cellh) >> 1;
                        cellh = m_vh;
                    }
                    break;
            }
            cell.right = cell.left + cellw;
            GLPage pleft = m_pages[cell.page_left];
            pleft.gl_layout(m_layw + x, y, scale * cell.scale);
            if (!zoom) pleft.gl_alloc();
            if (cell.page_right >= 0) {
                GLPage pright = m_pages[cell.page_right];
                pright.gl_layout(pleft.GetRight(), y, scale * cell.scale);
                if (!zoom) pright.gl_alloc();
            }
            m_layw = cell.right;
            if (m_layh < cellh) m_layh = cellh;
        }
    }

    private void layout_rtol(float scale, boolean zoom, boolean[] para) {
        if (m_vw <= 0 || m_vh <= 0) return;
        float maxw = 0;
        float maxh = 0;
        int minscalew = 0x40000000;
        int minscaleh = 0x40000000;
        int pcur = 0;
        int ccnt = 0;
        boolean last_dual = false;
        while (pcur < m_page_cnt) {
            float cw = m_doc.GetPageWidth(pcur);
            float ch = m_doc.GetPageHeight(pcur);
            if (dual_at(para, ccnt)) {
                if (pcur < m_page_cnt - 1) {
                    cw += m_doc.GetPageWidth(pcur + 1);
                    float ch2 = m_doc.GetPageHeight(pcur + 1);
                    if (ch < ch2) ch = ch2;
                    pcur += 2;
                    if (pcur == m_page_cnt) last_dual = true;
                } else pcur++;
            } else pcur++;
            if (maxw < cw) maxw = cw;
            if (maxh < ch) maxh = ch;
            float scalew = (m_vw - m_page_gap) / cw;
            float scaleh = (m_vh - m_page_gap) / ch;
            if (scalew > scaleh) scalew = scaleh;
            cw *= scalew;
            ch *= scalew;
            if (minscalew > (int) cw) minscalew = (int) cw;
            if (minscaleh > (int) ch) minscaleh = (int) ch;
            ccnt++;
        }

        boolean changed = (m_cells == null || m_cells.length != ccnt);
        if (changed) m_cells = new PDFCell[ccnt];
        m_scale_min = (float) (m_vw - m_page_gap) / maxw;
        float scalew;
        float scaleh = (float) (m_vh - m_page_gap) / maxh;
        if (m_scale_min > scaleh) m_scale_min = scaleh;
        float max_scale = m_scale_min * m_max_zoom;
        if (scale < m_scale_min) scale = m_scale_min;
        if (scale > max_scale) scale = max_scale;
        //if(m_scale == scale) return;
        m_scale = scale;
        m_layw = 0;
        m_layh = 0;
        pcur = m_page_cnt - 1;
        for (int ccur = 0; ccur < ccnt; ccur++) {
            float cw = m_doc.GetPageWidth(pcur);
            float ch = m_doc.GetPageHeight(pcur);
            if (changed) m_cells[ccur] = new PDFCell();
            PDFCell cell = m_cells[ccur];
            if (dual_at(para, ccnt - ccur - 1)) {
                if (pcur > 0 || last_dual) {
                    last_dual = false;

                    cw += m_doc.GetPageWidth(pcur - 1);
                    float ch2 = m_doc.GetPageHeight(pcur - 1);
                    if (ch < ch2) ch = ch2;

                    cell.page_left = pcur - 1;
                    cell.page_right = pcur;
                    pcur -= 2;
                } else {
                    cell.page_left = pcur--;
                    cell.page_right = -1;
                }
            } else {
                cell.page_left = pcur--;
                cell.page_right = -1;
            }
            switch (m_scale_mode) {
                case SCALE_SAME_WIDTH:
                    scalew = minscalew / cw;
                    cell.scale = scalew / m_scale_min;
                    break;
                case SCALE_SAME_HEIGHT:
                    scaleh = minscaleh / ch;
                    cell.scale = scaleh / m_scale_min;
                    break;
                case SCALE_FIT:
                    scalew = (m_vw - m_page_gap) / cw;
                    scaleh = (m_vh - m_page_gap) / ch;
                    cell.scale = ((scalew > scaleh) ? scaleh : scalew) / m_scale_min;
                    break;
                default:
                    cell.scale = 1;
                    break;
            }
            cell.left = m_layw;
            int cellw = (int) (cw * scale * cell.scale) + m_page_gap;
            int cellh = (int) (ch * scale * cell.scale) + m_page_gap;
            int x = m_page_gap >> 1;
            int y = m_page_gap >> 1;
            if (cellw < m_vw) {
                x = (m_vw - cellw) >> 1;
                cellw = m_vw;
            }
            switch (m_align_type) {
                case ALIGN_TOP:
                    if (cellh < m_vh) {
                        cellh = m_vh;
                    }
                    break;
                case ALIGN_BOTTOM:
                    if (cellh < m_vh) {
                        y = (m_vh - cellh) - (m_page_gap >> 1);
                        cellh = m_vh;
                    }
                    break;
                default:
                    if (cellh < m_vh) {
                        y = (m_vh - cellh) >> 1;
                        cellh = m_vh;
                    }
                    break;
            }
            cell.right = cell.left + cellw;
            GLPage pleft = m_pages[cell.page_left];
            pleft.gl_layout(m_layw + x, y, scale * cell.scale);
            if (!zoom) pleft.gl_alloc();
            if (cell.page_right >= 0) {
                GLPage pright = m_pages[cell.page_right];
                pright.gl_layout(pleft.GetRight(), y, scale * cell.scale);
                if (!zoom) pright.gl_alloc();
            }
            m_layw = cell.right;
            if (m_layh < cellh) m_layh = cellh;
        }
    }

    @Override
    public void gl_layout(float scale, boolean zoom) {
        if (m_vw > m_vh)//landscape
        {
            if (!m_rtol) layout_ltor(scale, zoom, m_horz_dual);
            else layout_rtol(scale, zoom, m_horz_dual);
        } else//portrait
        {
            if (!m_rtol) layout_ltor(scale, zoom, m_vert_dual);
            else layout_rtol(scale, zoom, m_vert_dual);
        }
    }

    private void do_scroll(int x, int y, int dx, int dy) {
        float secx = dx * 512 / m_vw;
        float secy = dy * 512 / m_vh;
        int sec = (int) Global.sqrtf(secx * secx + secy * secy);
        m_scroller.startScroll(x, y, dx, dy, sec);
    }

    private int get_cell(int vx) {
        if (m_pages == null || m_pages.length <= 0 || m_cells == null) return -1;
        int left = 0;
        int right = m_cells.length - 1;
        while (left <= right) {
            int mid = (left + right) >> 1;
            PDFCell pg1 = m_cells[mid];
            if (vx < pg1.left) {
                right = mid - 1;
            } else if (vx > pg1.right) {
                left = mid + 1;
            } else {
                return mid;
            }
        }
        if (right < 0) return -1;
        else return m_cells.length;
    }

    @Override
    public boolean gl_fling(int holdx, int holdy, float dx, float dy, float vx, float vy) {
        if (m_cells == null) return false;
        vx *= Global.fling_speed;
        vy *= Global.fling_speed;

        int x = vGetX();
        int y = vGetY();
        int endx = x - (int) vx;
        int endy = y - (int) vy;
        if (endx > m_layw - m_vw) endx = m_layw - m_vw;
        if (endx < 0) endx = 0;
        if (endy > m_layh - m_vh) endy = m_layh - m_vh;
        if (endy < 0) endy = 0;
        int cell1 = get_cell(x + m_vw / 2);
        int cell2 = get_cell(endx + m_vw / 2);
        if (cell2 > cell1) cell2 = cell1 + 1;
        if (cell2 < cell1) cell2 = cell1 - 1;
        m_scroller.computeScrollOffset();
        m_scroller.forceFinished(true);
        //vScrollAbort();
        if (cell1 < cell2) {
            if (cell2 == m_cells.length)
                do_scroll(x, y, m_cells[cell2 - 1].right - m_vw - x, endy - y);
            else {
                PDFCell cell = m_cells[cell1];
                if (x < cell.right - m_vw)
                    do_scroll(x, y, cell.right - m_vw - x, endy - y);
                else
                    do_scroll(x, y, m_cells[cell2].left - x, endy - y);
            }
        } else if (cell1 > cell2) {
            if (cell2 < 0)
                do_scroll(x, y, -x, 0);
            else {
                PDFCell cell = m_cells[cell1];
                if (x > cell.left)
                    do_scroll(x, y, cell.left - x, endy - y);
                else
                    do_scroll(x, y, m_cells[cell2].right - m_vw - x, endy - y);
            }
        } else {
            PDFCell cell = m_cells[cell2];
            if (endx + m_vw > cell.right) {
                if (endx + (m_vw / 2) > cell.right) {
                    cell2++;
                    if (cell2 == m_cells.length)
                        do_scroll(x, y, m_cells[cell2 - 1].right - m_vw - x, endy - y);
                    else
                        do_scroll(x, y, m_cells[cell2].left - x, endy - y);
                } else
                    do_scroll(x, y, m_cells[cell2].right - m_vw - x, endy - y);
            }
            else if (endx < cell.left) {
                if (endx + (m_vw / 2) < cell.left) {
                    cell2--;
                    if (cell2 == -1)
                        do_scroll(x, y, m_cells[cell2 + 1].right - m_vw - x, endy - y);
                    else
                        do_scroll(x, y, m_cells[cell2].left - x, endy - y);
                } else
                    do_scroll(x, y, m_cells[cell2].left - x, endy - y);
            }
            else {
                //moving in same cell, we reduce the moving distance.
                endx = x - (int) (vx * 0.3f);
                endy = y - (int) (vy * 0.3f);
                if (endx > m_layw - m_vw) endx = m_layw - m_vw;
                if (endx < 0) endx = 0;
                if (endy > m_layh - m_vh) endy = m_layh - m_vh;
                if (endy < 0) endy = 0;

                do_scroll(x, y, endx - x, endy - y);
            }
        }
        return true;
    }

    @Override
    public void gl_move_end() {
        int ccur = 0;
        int x = vGetX();
        int y = vGetY();
        while (ccur < m_cells.length) {
            PDFCell cell = m_cells[ccur];
            if (x < cell.right) {
                m_scroller.abortAnimation();
                m_scroller.forceFinished(true);
                if (x <= cell.right - m_vw) {
                } else if (cell.right - x > (m_vw >> 1)) {
                    m_scroller.startScroll(x, y, cell.right - x - m_vw, 0);
                } else if (ccur < m_cells.length - 1) {
                    m_scroller.startScroll(x, y, cell.right - x, 0);
                } else {
                    m_scroller.startScroll(x, y, cell.right - x - m_vw, 0);
                }
                break;
            }
            ccur++;
        }
    }

    @Override
    public void vGotoPage(int pageno) {
        if (m_pages == null || m_doc == null || m_vw <= 0 || m_vh <= 0 || pageno < 0 || pageno >= m_page_cnt)
            return;
        gl_abort_scroll();
        GLPage gpage = m_pages[pageno];
        int icell = get_cell((gpage.GetLeft() + gpage.GetRight()) >> 1);
        if (icell < 0) icell = 0;
        if (icell >= m_cells.length) icell = m_cells.length - 1;
        PDFCell cell = m_cells[icell];
        int left = cell.left;
        int w = cell.right - left;
        int x = left + ((w - m_vw) >> 1);
        m_scroller.setFinalX(x);
        m_scroller.computeScrollOffset();
        m_scroller.setFinalX(x);
    }

    @Override
    public void vScrolltoPage(int pageno) {
        if (m_pages == null || m_doc == null || m_vw <= 0 || m_vh <= 0 || pageno < 0 || pageno >= m_page_cnt)
            return;
        gl_abort_scroll();
        GLPage gpage = m_pages[pageno];
        int icell = get_cell((gpage.GetLeft() + gpage.GetRight()) >> 1);
        if (icell < 0) icell = 0;
        if (icell >= m_cells.length) icell = m_cells.length - 1;
        PDFCell cell = m_cells[icell];

        int left = cell.left;
        int w = cell.right - left;
        int x = left + ((w - m_vw) >> 1);
        m_scroller.computeScrollOffset();
        int oldx = m_scroller.getCurrX();
        int oldy = m_scroller.getCurrY();
        m_scroller.startScroll(oldx, oldy, x - oldx, 0);
    }

    private PDFCell m_zoom_cell;

    @Override
    public void gl_zoom_set_pos(int vx, int vy, PDFPos pos) {
        if (pos == null || m_cells == null || pos.pageno < 0 || pos.pageno >= m_page_cnt) return;
        GLPage gpage = m_pages[pos.pageno];
        if (m_zoom_cell == null) {
            int icell = get_cell(gpage.GetVX(pos.x));
            if (icell < 0) icell = 0;
            if (icell >= m_cells.length) icell = m_cells.length - 1;
            m_zoom_cell = m_cells[icell];
        }
        int docx = gpage.GetVX(pos.x) - vx;
        if (docx < m_zoom_cell.left) docx = m_zoom_cell.left;
        if (docx + m_vw > m_zoom_cell.right) docx = m_zoom_cell.right - m_vw;
        vSetX(docx);
        vSetY(gpage.GetVY(pos.y) - vy);
        m_scroller.computeScrollOffset();//update scroller value immediately.
        if (m_scroller.isFinished())//let next computeScrollOffset return true. and ensure that flush range will run normally.
            m_scroller.setFinalY(m_scroller.getCurrY());//make isFinished false.
    }

    @Override
    public void gl_zoom_confirm(GL10 gl10) {
        m_zoom_cell = null;
        super.gl_zoom_confirm(gl10);
        m_scroller.computeScrollOffset();
        PDFPos pos = vGetPos(m_vw / 2, m_vh / 2);

        if (m_pages == null || m_doc == null || m_vw <= 0 || m_vh <= 0 || pos.pageno < 0 || pos.pageno >= m_page_cnt)
            return;
        gl_abort_scroll();
        int ccur = 0;
        while (ccur < m_cells.length) {
            PDFCell cell = m_cells[ccur];
            if (pos.pageno == cell.page_left || pos.pageno == cell.page_right) {
                int left = cell.left;
                int w = cell.right - left;
                int oldx = m_scroller.getCurrX();
                int oldy = m_scroller.getCurrY();
                if (w <= m_vw) {
                    int x = left + ((w - m_vw) >> 1);
                    if (oldx < left || oldx + m_vw > cell.right)
                        m_scroller.startScroll(oldx, oldy, x - oldx, 0);
                } else {
                    int x0 = left - m_page_gap / 2;
                    int x1 = cell.right + m_page_gap / 2;
                    if (oldx < x0)
                        m_scroller.startScroll(oldx, oldy, x0 - oldx, 0);
                    else if (oldx + m_vw > x1)
                        m_scroller.startScroll(oldx, oldy, x1 - (oldx + m_vw), 0);
                }
                break;
            }
            ccur++;
        }
    }
}
