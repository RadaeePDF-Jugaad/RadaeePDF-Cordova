package com.radaee.view;

import android.content.Context;
import android.util.Log;

import com.radaee.pdf.Global;

import javax.microedition.khronos.opengles.GL10;

public class GLLayoutDualV extends GLLayout {
    public static final int ALIGN_CENTER = 0;
    public static final int ALIGN_LEFT = 1;
    public static final int ALIGN_RIGHT = 2;
    private final boolean m_rtol;
    private final boolean m_has_cover;
    private final boolean m_same_width;
    private final int m_align_type;

    private static class PDFCell {
        int top;
        int bottom;
        float scale;
        int page_left;
        int page_right;
    }

    private PDFCell[] m_cells;

    public GLLayoutDualV(Context context, int align, boolean rtol, boolean has_cover, boolean same_width) {
        super(context);
        m_align_type = align;
        m_rtol = rtol;
        m_has_cover = has_cover;
        m_same_width = same_width;
    }

    @Override
    public int vGetPage(int vx, int vy) {
        if (m_vw <= 0 || m_vh <= 0) return -1;
        vy += vGetY();
        vx += vGetX();
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
                Log.e("CELL:", String.format("%d|%d", pmid.page_left, pmid.page_right));
                GLPage page = m_pages[pmid.page_left];
                if (vx >= page.GetRight() && pmid.page_right >= 0) return pmid.page_right;
                else return pmid.page_left;
            }
        }
        int mid = (pb < 0) ? 0 : pb;
        PDFCell pmid = m_cells[mid];
        GLPage page = m_pages[pmid.page_left];
        Log.e("CELL:", String.format("%d|%d", pmid.page_left, pmid.page_right));
        if (vx >= page.GetRight() && pmid.page_right >= 0) return pmid.page_right;
        else return pmid.page_left;
    }

    @Override
    public void gl_layout(float scale, boolean zoom) {
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
            if((!m_has_cover || pcur > 0) && pcur < m_page_cnt - 1)//dual page cell
            {
                cw += m_doc.GetPageWidth(pcur + 1);
                float ch2 = m_doc.GetPageHeight(pcur + 1);
                if (ch < ch2) ch = ch2;
                pcur += 2;
            }
            else
                pcur++;
            if (maxw < cw) maxw = cw;
            if (maxh < ch) maxh = ch;
            float scalew = (m_vw - m_page_gap) / cw;
            cw *= scalew;
            ch *= scalew;
            if (minscalew > (int) cw) minscalew = (int) cw;
            if (minscaleh > (int) ch) minscaleh = (int) ch;
            ccnt++;
        }

        boolean changed = (m_cells == null || m_cells.length != ccnt);
        if (changed) m_cells = new PDFCell[ccnt];
        m_scale_min = (float) (m_vw - m_page_gap) / maxw;
        float max_scale = m_scale_min * m_max_zoom;
        if (scale < m_scale_min) scale = m_scale_min;
        if (scale > max_scale) scale = max_scale;
        //if(m_scale == scale) return;
        float scalew;
        m_scale = scale;
        m_layw = (int)(scale * maxw) + m_page_gap;
        m_layh = 0;
        pcur = 0;
        for (int ccur = 0; ccur < ccnt; ccur++) {
            float cw = m_doc.GetPageWidth(pcur);
            float ch = m_doc.GetPageHeight(pcur);
            if (changed) m_cells[ccur] = new PDFCell();
            PDFCell cell = m_cells[ccur];
            if((!m_has_cover || pcur > 0) && pcur < m_page_cnt - 1)//dual page cell
            {
                cw += m_doc.GetPageWidth(pcur + 1);
                float ch2 = m_doc.GetPageHeight(pcur + 1);
                if (ch < ch2) ch = ch2;

                if (m_rtol) {
                    cell.page_left = pcur + 1;
                    cell.page_right = pcur;
                }
                else {
                    cell.page_left = pcur;
                    cell.page_right = pcur + 1;
                }
                pcur += 2;
            } else {
                cell.page_left = pcur++;
                cell.page_right = -1;
            }
            if (m_same_width) {
                scalew = minscalew / cw;
                cell.scale = scalew / m_scale_min;
            }
            else {
                cell.scale = 1;
            }
            cell.top = m_layh;
            int cellw = (int) (cw * scale * cell.scale) + m_page_gap;
            int cellh = (int) (ch * scale * cell.scale) + m_page_gap;
            int x = m_page_gap >> 1;
            switch (m_align_type) {
                case ALIGN_LEFT:
                    break;
                case ALIGN_RIGHT:
                    x = (m_layw - cellw) - (m_page_gap >> 1);
                    break;
                default:
                    x = (m_layw - cellw) >> 1;
                    break;
            }
            cell.bottom = cell.top + cellh;
            GLPage pleft = m_pages[cell.page_left];
            pleft.gl_layout(x, m_layh + (m_page_gap >> 1), scale * cell.scale);
            if (!zoom) pleft.gl_alloc();
            if (cell.page_right >= 0) {
                GLPage pright = m_pages[cell.page_right];
                pright.gl_layout(pleft.GetRight(), m_layh + (m_page_gap >> 1), scale * cell.scale);
                if (!zoom) pright.gl_alloc();
            }
            m_layh = cell.bottom;
        }
    }

    @Override
    protected void gl_flush_range(GL10 gl10)
    {
        if(!m_scroller.computeScrollOffset() && m_pageno2 > m_pageno1) return;
        int pageno1 = vGetPage(-GLBlock.m_cell_size, -GLBlock.m_cell_size);
        int pageno2 = vGetPage(m_vw + GLBlock.m_cell_size, m_vh + GLBlock.m_cell_size);
        if( pageno1 >= 0 && pageno2 >= 0 )
        {
            if( pageno1 > pageno2 )
            {
                int tmp = pageno1;
                pageno1 = pageno2;
                pageno2 = tmp;
            }
            pageno2++;
            if (m_rtol) {
                if (pageno1 > 0) pageno1--;
                if (pageno2 < m_page_cnt) pageno2++;
            }
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
}
