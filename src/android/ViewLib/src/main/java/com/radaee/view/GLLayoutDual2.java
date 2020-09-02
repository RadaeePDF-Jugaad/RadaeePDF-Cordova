package com.radaee.view;

import android.content.Context;

import com.radaee.pdf.Global;

import javax.microedition.khronos.opengles.GL10;

public class GLLayoutDual2 extends GLLayout {
    public static final int SCALE_NONE = 0;
    public static final int SCALE_SAME_WIDTH = 1;
    public static final int SCALE_SAME_HEIGHT = 2;
    public static final int SCALE_FIT = 3;
    public static final int ALIGN_CENTER = 0;
    public static final int ALIGN_LEFT = 1;
    public static final int ALIGN_RIGHT = 2;
    private boolean m_vert_dual[];
    private boolean m_horz_dual[];
    private boolean m_rtol;
    private int m_align_type;
    private int m_scale_mode;

    private class PDFCell {
        int top;
        int bottom;
        float scale;
        int page_left;
        int page_right;
    }

    private PDFCell m_cells[];

    public GLLayoutDual2(Context context, int align, int scale_mode, boolean rtol, boolean horz_dual[], boolean vert_dual[]) {
        super(context);
        m_horz_dual = horz_dual;
        m_vert_dual = vert_dual;
        m_align_type = align;
        m_scale_mode = scale_mode;
        m_rtol = rtol;
    }

    @Override
    public int vGetPage(int vx, int vy) {
        if (m_vw <= 0 || m_vh <= 0) return -1;
        vy += vGetY();
        int pt = 0;
        int pb = m_cells.length - 1;
        int hg = (m_page_gap >> 1);
        while (pb >= pt) {
            int mid = (pt + pb) >> 1;
            PDFCell pmid = m_cells[mid];
            if (vy < pmid.top - hg)
                pb = mid - 1;
            else if (vy >= pmid.bottom + hg)
                pt = mid + 1;
            else {
                GLPage page = m_pages[pmid.page_left];
                if (vx >= page.GetRight() && pmid.page_right >= 0) return pmid.page_right;
                else return pmid.page_left;
            }
        }
        int mid = (pb < 0) ? 0 : pb;
        PDFCell pmid = m_cells[mid];
        GLPage page = m_pages[pmid.page_left];
        if (vx >= page.GetRight() && pmid.page_right >= 0) return pmid.page_right;
        else return pmid.page_left;
    }

    private static final boolean dual_at(boolean para[], int icell) {
        if (para == null || icell >= para.length) return false;
        return para[icell];
    }

    private final void layout_ltor(float scale, boolean zoom, boolean para[]) {
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
            cell.top = m_layh;
            int cellw = (int) (cw * scale * cell.scale) + m_page_gap;
            int cellh = (int) (ch * scale * cell.scale) + m_page_gap;
            int x = m_page_gap >> 1;
            int y = m_page_gap >> 1;
            if (cellh < m_vh) {
                y = (m_vh - cellh) >> 1;
                cellh = m_vh;
            }
            switch (m_align_type) {
                case ALIGN_LEFT:
                    if (cellw < m_vw) {
                        cellw = m_vw;
                    }
                    break;
                case ALIGN_RIGHT:
                    if (cellw < m_vw) {
                        x = (m_vw - cellw) - (m_page_gap >> 1);
                        cellw = m_vw;
                    }
                    break;
                default:
                    if (cellw < m_vw) {
                        x = (m_vw - cellw) >> 1;
                        cellw = m_vw;
                    }
                    break;
            }
            cell.bottom = cell.top + cellh;
            GLPage pleft = m_pages[cell.page_left];
            pleft.gl_layout(x, m_layh + y, scale * cell.scale);
            if (!zoom) pleft.gl_alloc();
            if (cell.page_right >= 0) {
                GLPage pright = m_pages[cell.page_right];
                pright.gl_layout(pleft.GetRight(), m_layh + y, scale * cell.scale);
                if (!zoom) pright.gl_alloc();
            }
            m_layh = cell.bottom;
            if (m_layw < cellw) m_layw = cellw;
        }
    }

    private final void layout_rtol(float scale, boolean zoom, boolean para[]) {
        if (m_vw <= 0 || m_vh <= 0) return;
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
            cell.top = m_layh;
            int cellw = (int) (cw * scale * cell.scale) + m_page_gap;
            int cellh = (int) (ch * scale * cell.scale) + m_page_gap;
            int x = m_page_gap >> 1;
            int y = m_page_gap >> 1;
            if (cellh < m_vh) {
                y = (m_vh - cellh) >> 1;
                cellh = m_vh;
            }
            switch (m_align_type) {
                case ALIGN_LEFT:
                    if (cellw < m_vw) {
                        cellw = m_vw;
                    }
                    break;
                case ALIGN_RIGHT:
                    if (cellw < m_vw) {
                        x = (m_vw - cellw) - (m_page_gap >> 1);
                        cellw = m_vw;
                    }
                    break;
                default:
                    if (cellw < m_vw) {
                        x = (m_vw - cellw) >> 1;
                        cellw = m_vw;
                    }
                    break;
            }
            cell.bottom = cell.top + cellh;
            GLPage pleft = m_pages[cell.page_left];
            pleft.gl_layout(m_layw + x, y, scale * cell.scale);
            if (!zoom) pleft.gl_alloc();
            if (cell.page_right >= 0) {
                GLPage pright = m_pages[cell.page_right];
                pright.gl_layout(pleft.GetRight(), y, scale * cell.scale);
                if (!zoom) pright.gl_alloc();
            }
            m_layh = cell.bottom;
            if (m_layw < cellw) m_layw = cellw;
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

    private int get_cell(int vy) {
        if (m_pages == null || m_pages.length <= 0 || m_cells == null) return -1;
        int top = 0;
        int bottom = m_cells.length - 1;
        while (top <= bottom) {
            int mid = (top + bottom) >> 1;
            PDFCell pg1 = m_cells[mid];
            if (vy < pg1.top) {
                bottom = mid - 1;
            } else if (vy > pg1.bottom) {
                top = mid + 1;
            } else {
                return mid;
            }
        }
        if (bottom < 0) return -1;
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
        int cell1 = get_cell(y + m_vh / 2);
        int cell2 = get_cell(endy + m_vh / 2);
        if (cell2 > cell1) cell2 = cell1 + 1;
        if (cell2 < cell1) cell2 = cell1 - 1;
        m_scroller.computeScrollOffset();
        m_scroller.forceFinished(true);
        //vScrollAbort();
        if (cell1 < cell2) {
            if (cell2 == m_cells.length)
                do_scroll(x, y, endx - x, m_cells[cell2 - 1].bottom - m_vh - y);
            else {
                PDFCell cell = m_cells[cell1];
                if (y < cell.bottom - m_vh)
                    do_scroll(x, y, endx - x, cell.bottom - m_vh - y);
                else
                    do_scroll(x, y, endx - x, m_cells[cell2].top - y);
            }
        } else if (cell1 > cell2) {
            if (cell2 < 0)
                do_scroll(x, y, 0, -y);
            else {
                PDFCell cell = m_cells[cell1];
                if (y > cell.top)
                    do_scroll(x, y, endx - x, cell.top - y);
                else
                    do_scroll(x, y, endx - x, m_cells[cell2].bottom - m_vh - y);
            }
        } else {
            if (endy + m_vh > m_cells[cell2].bottom) {
                if (endy + (m_vh >> 1) > m_cells[cell2].bottom) {
                    cell2++;
                    if (cell2 == m_cells.length)
                        do_scroll(x, y, endx - x, m_cells[cell2 - 1].bottom - m_vh - y);
                    else
                        do_scroll(x, y, endx - x, m_cells[cell2].bottom - m_vh - y);
                } else
                    do_scroll(x, y, endx - x, m_cells[cell2].bottom - m_vh - y);
            }
            else if(endy < m_cells[cell2].top)
            {
                if(endy + (m_vh >> 1) < m_cells[cell2].top)
                {
                    cell2--;
                    if (cell2 < 0)
                        do_scroll(x, y, endx - x, m_cells[0].top - y);
                    else
                        do_scroll(x, y, endx - x, m_cells[cell2].top - y);
                }
                else
                    do_scroll(x, y, endx - x, m_cells[cell2].top - y);
            }  else {
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
            if (y < cell.bottom) {
                m_scroller.abortAnimation();
                m_scroller.forceFinished(true);
                if (y <= cell.bottom - m_vh) {
                } else if (cell.bottom - y > (m_vh >> 1)) {
                    m_scroller.startScroll(x, y, 0, cell.bottom - y - m_vh);
                } else if (ccur < m_cells.length - 1) {
                    m_scroller.startScroll(x, y, 0, cell.bottom - y);
                } else {
                    m_scroller.startScroll(x, y, 0, cell.bottom - y - m_vh);
                }
                break;
            }
            ccur++;
        }
    }

    @Override
    public void vGotoPage(int pageno) {
        if (m_pages == null || m_doc == null || m_vw <= 0 || m_vh <= 0 || pageno < 0 || pageno >= m_cells.length)
            return;
        gl_abort_scroll();
        GLPage gpage = m_pages[pageno];
        int icell = get_cell((gpage.GetTop() + gpage.GetBottom()) >> 1);
        if (icell < 0) icell = 0;
        if (icell >= m_cells.length) icell = m_cells.length - 1;
        PDFCell cell = m_cells[icell];
        int top = cell.top;
        int h = cell.bottom - top;
        int y = top + ((h - m_vh) >> 1);
        m_scroller.setFinalX(y);
    }

    @Override
    public void vScrolltoPage(int pageno) {
        if (m_pages == null || m_doc == null || m_vw <= 0 || m_vh <= 0 || pageno < 0 || pageno >= m_cells.length)
            return;
        gl_abort_scroll();
        GLPage gpage = m_pages[pageno];
        int icell = get_cell((gpage.GetLeft() + gpage.GetRight()) >> 1);
        if (icell < 0) icell = 0;
        if (icell >= m_cells.length) icell = m_cells.length - 1;
        PDFCell cell = m_cells[icell];

        int top = cell.top;
        int h = cell.bottom - top;
        int y = top + ((h - m_vh) >> 1);
        int oldx = m_scroller.getCurrX();
        int oldy = m_scroller.getCurrY();
        m_scroller.startScroll(oldx, oldy, 0, y - oldy);
    }

    private PDFCell m_zoom_cell;

    @Override
    public void gl_zoom_set_pos(int vx, int vy, PDFPos pos) {
        if (pos == null || m_cells == null || pos.pageno < 0) return;
        GLPage gpage = m_pages[pos.pageno];
        if (m_zoom_cell == null) {
            int icell = get_cell(gpage.GetVY(pos.y));
            if (icell < 0) icell = 0;
            if (icell >= m_cells.length) icell = m_cells.length - 1;
            m_zoom_cell = m_cells[icell];
        }
        int docy = gpage.GetVY(pos.y) - vy;
        if (docy < m_zoom_cell.top) docy = m_zoom_cell.top;
        if (docy + m_vh > m_zoom_cell.bottom) docy = m_zoom_cell.bottom - m_vh;
        vSetY(docy);
        vSetX(gpage.GetVX(pos.x) - vx);
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

        if (m_pages == null || m_doc == null || m_vw <= 0 || m_vh <= 0 || pos.pageno < 0 || pos.pageno >= m_cells.length)
            return;
        gl_abort_scroll();
        int ccur = 0;
        while (ccur < m_cells.length) {
            PDFCell cell = m_cells[ccur];
            if (pos.pageno == cell.page_left || pos.pageno == cell.page_right) {
                int top = cell.top;
                int h = cell.bottom - top;
                int oldx = m_scroller.getCurrX();
                int oldy = m_scroller.getCurrY();
                if (h <= m_vh) {
                    int y = top + ((h - m_vh) >> 1);
                    if (oldy < top || oldy + m_vh > cell.bottom)
                        m_scroller.startScroll(oldx, oldy, 0, y - oldy);
                } else {
                    int y0 = top - m_page_gap / 2;
                    int y1 = cell.bottom + m_page_gap / 2;
                    if (oldy < y0)
                        m_scroller.startScroll(oldx, oldy, 0, y0 - oldy);
                    else if (oldy + m_vh > y1)
                        m_scroller.startScroll(oldx, oldy, 0, y1 - (oldy + m_vh));
                }
                break;
            }
            ccur++;
        }
    }
}
