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
    private boolean m_vert_dual[];
    private boolean m_horz_dual[];
    private boolean m_rtol;
    private int m_align_type;
    private int m_scale_mode;
    private class PDFCell
    {
        int left;
        int right;
        float scale;
        int page_left;
        int page_right;
    }
    private PDFCell m_cells[];
    public GLLayoutDual(Context context, int align, int scale_mode, boolean rtol, boolean horz_dual[], boolean vert_dual[])
    {
        super(context);
        m_horz_dual = horz_dual;
        m_vert_dual = vert_dual;
        m_align_type = align;
        m_scale_mode = scale_mode;
        m_rtol = rtol;
    }
    @Override
    public int vGetPage(int vx, int vy) {
        if(m_vw <= 0 || m_vh <= 0) return -1;
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
    private static final boolean dual_at(boolean para[], int icell)
    {
        if(para == null || icell >= para.length) return false;
        return para[icell];
    }
    private final void layout_ltor(float scale, boolean zoom, boolean para[])
    {
        if(m_vw <= 0 || m_vh <= 0) return;
        float maxw = 0;
        float maxh = 0;
        int minscalew = 0x40000000;
        int minscaleh = 0x40000000;
        int pcur = 0;
        int ccnt = 0;
        while(pcur < m_page_cnt)
        {
            float cw = m_doc.GetPageWidth(pcur);
            float ch = m_doc.GetPageHeight(pcur);
            if(dual_at(para, ccnt))
            {
                if(pcur < m_page_cnt - 1)
                {
                    cw += m_doc.GetPageWidth(pcur + 1);
                    float ch2 = m_doc.GetPageHeight(pcur + 1);
                    if(ch < ch2) ch = ch2;
                    pcur += 2;
                }
                else pcur++;
            }
            else pcur++;
            if(maxw < cw) maxw = cw;
            if(maxh < ch) maxh = ch;
            float scalew = (m_vw - m_page_gap) / cw;
            float scaleh = (m_vh - m_page_gap) / ch;
            if(scalew > scaleh) scalew = scaleh;
            cw *= scalew;
            ch *= scalew;
            if(minscalew > (int)cw) minscalew = (int)cw;
            if(minscaleh > (int)ch) minscaleh = (int)ch;
            ccnt++;
        }

        boolean changed = (m_cells == null || m_cells.length != ccnt);
        if(changed) m_cells = new PDFCell[ccnt];
        m_scale_min = (float)(m_vw - m_page_gap) / maxw;
        float scalew;
        float scaleh = (float)(m_vh - m_page_gap) / maxh;
        if(m_scale_min > scaleh) m_scale_min = scaleh;
        float max_scale = m_scale_min * m_max_zoom;
        if(scale < m_scale_min) scale = m_scale_min;
        if(scale > max_scale) scale = max_scale;
        //if(m_scale == scale) return;
        m_scale = scale;
        m_layw = 0;
        m_layh = 0;
        pcur = 0;
        for(int ccur = 0; ccur < ccnt; ccur++)
        {
            float cw = m_doc.GetPageWidth(pcur);
            float ch = m_doc.GetPageHeight(pcur);
            if(changed) m_cells[ccur] = new PDFCell();
            PDFCell cell = m_cells[ccur];
            if(dual_at(para, ccur))
            {
                if(pcur < m_page_cnt - 1)
                {
                    cw += m_doc.GetPageWidth(pcur + 1);
                    float ch2 = m_doc.GetPageHeight(pcur + 1);
                    if(ch < ch2) ch = ch2;

                    cell.page_left = pcur;
                    cell.page_right = pcur + 1;
                    pcur += 2;
                }
                else
                {
                    cell.page_left = pcur++;
                    cell.page_right = -1;
                }
            }
            else
            {
                cell.page_left = pcur++;
                cell.page_right = -1;
            }
            switch(m_scale_mode)
            {
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
            int cellw = (int)(cw * scale * cell.scale) + m_page_gap;
            int cellh = (int)(ch * scale * cell.scale) + m_page_gap;
            int x = m_page_gap >> 1;
            int y = m_page_gap >> 1;
            if(cellw < m_vw) { x = (m_vw - cellw) >> 1; cellw = m_vw; }
            switch(m_align_type)
            {
                case ALIGN_TOP:
                    if(cellh < m_vh) { cellh = m_vh; }
                    break;
                case ALIGN_BOTTOM:
                    if(cellh < m_vh) { y = (m_vh - cellh) - (m_page_gap >> 1); cellh = m_vh; }
                    break;
                default:
                    if(cellh < m_vh) { y = (m_vh - cellh) >> 1; cellh = m_vh; }
                    break;
            }
            cell.right = cell.left + cellw;
            GLPage pleft = m_pages[cell.page_left];
            pleft.gl_layout(m_layw + x, y, scale * cell.scale);
            if(!zoom) pleft.gl_alloc();
            if(cell.page_right >= 0)
            {
                GLPage pright = m_pages[cell.page_right];
                pright.gl_layout(pleft.GetRight(), y, scale * cell.scale);
                if(!zoom) pright.gl_alloc();
            }
            m_layw = cell.right;
            if(m_layh < cellh) m_layh = cellh;
        }
    }
    private final void layout_rtol(float scale, boolean zoom, boolean para[])
    {
        if(m_vw <= 0 || m_vh <= 0) return;
        if(m_vw <= 0 || m_vh <= 0) return;
        float maxw = 0;
        float maxh = 0;
        int minscalew = 0x40000000;
        int minscaleh = 0x40000000;
        int pcur = 0;
        int ccnt = 0;
        boolean last_dual = false;
        while(pcur < m_page_cnt)
        {
            float cw = m_doc.GetPageWidth(pcur);
            float ch = m_doc.GetPageHeight(pcur);
            if(dual_at(para, ccnt))
            {
                if(pcur < m_page_cnt - 1)
                {
                    cw += m_doc.GetPageWidth(pcur + 1);
                    float ch2 = m_doc.GetPageHeight(pcur + 1);
                    if(ch < ch2) ch = ch2;
                    pcur += 2;
                    if(pcur == m_page_cnt) last_dual = true;
                }
                else pcur++;
            }
            else pcur++;
            if(maxw < cw) maxw = cw;
            if(maxh < ch) maxh = ch;
            float scalew = (m_vw - m_page_gap) / cw;
            float scaleh = (m_vh - m_page_gap) / ch;
            if(scalew > scaleh) scalew = scaleh;
            cw *= scalew;
            ch *= scalew;
            if(minscalew > (int)cw) minscalew = (int)cw;
            if(minscaleh > (int)ch) minscaleh = (int)ch;
            ccnt++;
        }

        boolean changed = (m_cells == null || m_cells.length != ccnt);
        if(changed) m_cells = new PDFCell[ccnt];
        m_scale_min = (float)(m_vw - m_page_gap) / maxw;
        float scalew;
        float scaleh = (float)(m_vh - m_page_gap) / maxh;
        if(m_scale_min > scaleh) m_scale_min = scaleh;
        float max_scale = m_scale_min * m_max_zoom;
        if(scale < m_scale_min) scale = m_scale_min;
        if(scale > max_scale) scale = max_scale;
        //if(m_scale == scale) return;
        m_scale = scale;
        m_layw = 0;
        m_layh = 0;
        pcur = m_page_cnt - 1;
        for(int ccur = 0; ccur < ccnt; ccur++)
        {
            float cw = m_doc.GetPageWidth(pcur);
            float ch = m_doc.GetPageHeight(pcur);
            if(changed) m_cells[ccur] = new PDFCell();
            PDFCell cell = m_cells[ccur];
            if(dual_at(para, ccnt - ccur - 1))
            {
                if(pcur > 0 || last_dual)
                {
                    last_dual = false;

                    cw += m_doc.GetPageWidth(pcur - 1);
                    float ch2 = m_doc.GetPageHeight(pcur - 1);
                    if(ch < ch2) ch = ch2;

                    cell.page_left = pcur - 1;
                    cell.page_right = pcur;
                    pcur -= 2;
                }
                else
                {
                    cell.page_left = pcur--;
                    cell.page_right = -1;
                }
            }
            else
            {
                cell.page_left = pcur--;
                cell.page_right = -1;
            }
            switch(m_scale_mode)
            {
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
            int cellw = (int)(cw * scale * cell.scale) + m_page_gap;
            int cellh = (int)(ch * scale * cell.scale) + m_page_gap;
            int x = m_page_gap >> 1;
            int y = m_page_gap >> 1;
            if(cellw < m_vw) { x = (m_vw - cellw) >> 1; cellw = m_vw; }
            switch(m_align_type)
            {
                case ALIGN_TOP:
                    if(cellh < m_vh) { cellh = m_vh; }
                    break;
                case ALIGN_BOTTOM:
                    if(cellh < m_vh) { y = (m_vh - cellh) - (m_page_gap >> 1); cellh = m_vh; }
                    break;
                default:
                    if(cellh < m_vh) { y = (m_vh - cellh) >> 1; cellh = m_vh; }
                    break;
            }
            cell.right = cell.left + cellw;
            GLPage pleft = m_pages[cell.page_left];
            pleft.gl_layout(m_layw + x, y, scale * cell.scale);
            if(!zoom) pleft.gl_alloc();
            if(cell.page_right >= 0)
            {
                GLPage pright = m_pages[cell.page_right];
                pright.gl_layout(pleft.GetRight(), y, scale * cell.scale);
                if(!zoom) pright.gl_alloc();
            }
            m_layw = cell.right;
            if(m_layh < cellh) m_layh = cellh;
        }
    }
    @Override
    public void gl_layout(float scale, boolean zoom)
    {
        if(m_vw > m_vh)//landscape
        {
            if(!m_rtol) layout_ltor(scale, zoom, m_horz_dual);
            else layout_rtol(scale, zoom, m_horz_dual);
        }
        else//portrait
        {
            if(!m_rtol) layout_ltor(scale, zoom, m_vert_dual);
            else layout_rtol(scale, zoom, m_vert_dual);
        }
    }
    private void do_scroll(int x, int y, int dx, int dy)
    {
        float secx = dx * 512 / m_vw;
        float secy = dy * 512 / m_vh;
        int sec = (int) Global.sqrtf(secx * secx + secy * secy);
        m_scroller.startScroll(x, y, dx, dy, sec);
    }
    private int get_cell(int vx)
    {
        if( m_pages == null || m_pages.length <= 0  || m_cells == null) return -1;
        int left = 0;
        int right = m_cells.length - 1;
        while( left <= right )
        {
            int mid = (left + right)>>1;
            PDFCell pg1 = m_cells[mid];
            if( vx < pg1.left )
            {
                right = mid - 1;
            }
            else if( vx > pg1.right )
            {
                left = mid + 1;
            }
            else
            {
                return mid;
            }
        }
        if(right < 0) return -1;
        else return m_cells.length;
    }
    @Override
    public boolean gl_fling(int holdx, int holdy, float dx, float dy, float vx, float vy)
    {
        if(m_cells == null) return false;
        int x = vGetX();
        int y = vGetY();
        int endx = x - (int)vx;
        int endy = y - (int)vy;
        if(endx > m_layw - m_vw) endx = m_layw - m_vw;
        if(endx < 0) endx = 0;
        if(endy > m_layh - m_vh) endy = m_layh - m_vh;
        if(endy < 0) endy = 0;
        int cell1 = get_cell(x);
        int cell2 = get_cell(endx);
        if(cell2 > cell1) cell2 = cell1 + 1;
        if(cell2 < cell1) cell2 = cell1 - 1;
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
                if (endx + (m_vw>>1) > cell.right) {
                    cell2++;
                    if (cell2 == m_cells.length)
                        do_scroll(x, y, m_cells[cell2 - 1].right - m_vw - x, endy - y);
                    else
                        do_scroll(x, y, m_cells[cell2].left - x, endy - y);
                } else
                    do_scroll(x, y, m_cells[cell2].right - m_vw - x, endy - y);
            } else {
                do_scroll(x, y, endx - x, endy - y);
            }
        }
        return true;
    }
    @Override
    public void gl_move_end()
    {
        int ccur = 0;
        int x = vGetX();
        int y = vGetY();
        while( ccur < m_cells.length )
        {
            PDFCell cell = m_cells[ccur];
            if( x < cell.right )
            {
                m_scroller.abortAnimation();
                m_scroller.forceFinished(true);
                if( x <= cell.right - m_vw )
                {
                }
                else if( cell.right - x > (m_vw >> 1) )
                {
                    m_scroller.startScroll(x, y, cell.right - x - m_vw, 0);
                }
                else if( ccur < m_cells.length - 1 )
                {
                    m_scroller.startScroll(x, y, cell.right - x, 0);
                }
                else
                {
                    m_scroller.startScroll(x, y, cell.right - x - m_vw, 0);
                }
                break;
            }
            ccur++;
        }
    }
    @Override
    public void vGotoPage( int pageno )
    {
        if( m_pages == null || m_doc == null || m_vw <= 0 || m_vh <= 0 || pageno < 0 || pageno >= m_cells.length) return;
        gl_abort_scroll();
        int ccur = 0;
        while( ccur < m_cells.length )
        {
            PDFCell cell = m_cells[ccur];
            if( pageno == cell.page_left || pageno == cell.page_right )
            {
                int left = cell.left;
                int w = cell.right - left;
                int x = left + ((w - m_vw) >> 1);
                m_scroller.setFinalX(x);
                break;
            }
            ccur++;
        }
    }
    @Override
    public void vScrolltoPage( int pageno )
    {
        if( m_pages == null || m_doc == null || m_vw <= 0 || m_vh <= 0 || pageno < 0 || pageno >= m_cells.length) return;
        gl_abort_scroll();
        int ccur = 0;
        while( ccur < m_cells.length )
        {
            PDFCell cell = m_cells[ccur];
            if( pageno == cell.page_left || pageno == cell.page_right )
            {
                int left = cell.left;
                int w = cell.right - left;
                int x = left + ((w - m_vw) >> 1);
                int oldx = m_scroller.getCurrX();
                int oldy = m_scroller.getCurrY();
                m_scroller.startScroll(oldx, oldy, x - oldx, 0);
                break;
            }
            ccur++;
        }
    }
    @Override
    public void gl_zoom_confirm(GL10 gl10)
    {
        super.gl_zoom_confirm(gl10);
        m_scroller.computeScrollOffset();
        PDFPos pos = vGetPos(m_vw / 2, m_vh / 2);

        if( m_pages == null || m_doc == null || m_vw <= 0 || m_vh <= 0 || pos.pageno < 0 || pos.pageno >= m_cells.length) return;
        gl_abort_scroll();
        int ccur = 0;
        while( ccur < m_cells.length )
        {
            PDFCell cell = m_cells[ccur];
            if( pos.pageno == cell.page_left || pos.pageno == cell.page_right )
            {
                int left = cell.left;
                int w = cell.right - left;
                int x = left + ((w - m_vw) >> 1);
                int oldx = m_scroller.getCurrX();
                int oldy = m_scroller.getCurrY();
                if(oldx < left - m_page_gap / 2 || oldx + m_vw > cell.right + m_page_gap / 2)
                    m_scroller.startScroll(oldx, oldy, x - oldx, 0);
                break;
            }
            ccur++;
        }
    }
}
