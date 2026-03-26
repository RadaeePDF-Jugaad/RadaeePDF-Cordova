package com.radaee.view;

import android.content.Context;

import com.radaee.pdf.Document;
import com.radaee.pdf.Global;
import com.radaee.pdf.VNBlock;

public class PDFLayoutDualV extends PDFLayout
{
    public static final int ALIGN_CENTER = 0;
    public static final int ALIGN_LEFT = 1;
    public static final int ALIGN_RIGHT = 2;
    private final boolean m_rtol;
    private final boolean m_has_cover;
    private final boolean m_same_width;
    private final int m_align_type;

    private static class PDFCell {
        int top;
        int bot;
        float scale;
        int page_left;
        int page_right;
    }
    protected PDFCell[] m_cells;
    public PDFLayoutDualV(Context context, int align, boolean rtol, boolean has_cover, boolean same_width)
    {
        super(context);
        m_align_type = align;
        m_rtol = rtol;
        m_has_cover = has_cover;
        m_same_width = same_width;
    }
    @Override
    public void vOpen(Document doc, LayoutListener listener)
    {
        super.vOpen(doc, listener);
    }
    protected void do_scroll(int x, int y, int dx, int dy)
    {
        float secx = (float)dx * 1000 / m_w;
        float secy = (float)dy * 1000 / m_h;
        int sec = (int)Global.sqrtf(secx * secx + secy * secy);
        m_scroller.startScroll(x, y, dx, dy, sec);
    }
    @Override
    public void vLayout()
    {
        if (m_w <= 0 || m_h <= 0) return;
        float maxw = 0;
        float maxh = 0;
        int minscalew = 0x40000000;
        int minscaleh = 0x40000000;
        int pcur = 0;
        int pcnt = m_pages.length;
        int ccnt = 0;
        while (pcur < pcnt) {
            float cw = m_doc.GetPageWidth(pcur);
            float ch = m_doc.GetPageHeight(pcur);
            if((!m_has_cover || pcur > 0) && pcur < pcnt - 1)//dual page cell
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
            float scalew = (m_w - m_page_gap) / cw;
            cw *= scalew;
            ch *= scalew;
            if (minscalew > (int) cw) minscalew = (int) cw;
            if (minscaleh > (int) ch) minscaleh = (int) ch;
            ccnt++;
        }

        boolean changed = (m_cells == null || m_cells.length != ccnt);
        if (changed) m_cells = new PDFCell[ccnt];
        m_scale_min = (float) (m_w - m_page_gap) / maxw;
        float max_scale = m_scale_min * m_zoom_level;
        if (m_scale < m_scale_min) m_scale = m_scale_min;
        if (m_scale > max_scale) m_scale = max_scale;
        //if(m_scale == scale) return;
        float scalew;
        boolean clip = m_scale / m_scale_min > m_zoom_level_clip;
        m_tw = (int)(m_scale * maxw) + m_page_gap;
        m_th = 0;
        pcur = 0;
        for (int ccur = 0; ccur < ccnt; ccur++) {
            float cw = m_doc.GetPageWidth(pcur);
            float ch = m_doc.GetPageHeight(pcur);
            if (changed) m_cells[ccur] = new PDFCell();
            PDFCell cell = m_cells[ccur];
            if((!m_has_cover || pcur > 0) && pcur < pcnt - 1)//dual page cell
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
            cell.top = m_th;
            int cellw = (int) (cw * m_scale * cell.scale) + m_page_gap;
            int cellh = (int) (ch * m_scale * cell.scale) + m_page_gap;
            int x = m_page_gap >> 1;
            switch (m_align_type) {
                case ALIGN_LEFT:
                    break;
                case ALIGN_RIGHT:
                    x += (m_tw - cellw);
                    break;
                default:
                    x = (m_tw - cellw + m_page_gap) >> 1;
                    break;
            }
            cell.bot = cell.top + cellh;
            VPage pleft = m_pages[cell.page_left];
            pleft.vLayout(x, m_th + (m_page_gap >> 1), m_scale * cell.scale, clip);
            if (cell.page_right >= 0) {
                VPage pright = m_pages[cell.page_right];
                pright.vLayout(pleft.GetX() + pleft.GetWidth(), m_th + (m_page_gap >> 1), m_scale * cell.scale, clip);
            }
            m_th = cell.bot;
        }
    }
    @Override
    public int vGetPage(int vx, int vy) {
        if (m_w <= 0 || m_h <= 0) return -1;
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
            else if (vy >= pmid.bot + hg)
                pt = mid + 1;
            else {
                //Log.e("CELL:", String.format("%d|%d", pmid.page_left, pmid.page_right));
                VPage page = m_pages[pmid.page_left];
                if (vx >= page.GetX() + page.GetWidth() && pmid.page_right >= 0) return pmid.page_right;
                else return pmid.page_left;
            }
        }
        int mid = (pb < 0) ? 0 : pb;
        PDFCell pmid = m_cells[mid];
        VPage page = m_pages[pmid.page_left];
        //Log.e("CELL:", String.format("%d|%d", pmid.page_left, pmid.page_right));
        if (vx >= page.GetX() + page.GetWidth() && pmid.page_right >= 0) return pmid.page_right;
        else return pmid.page_left;
    }

    @Override
    protected void vFlushRange() {
        int pageno1 = vGetPage(0, 0);
        int pageno2 = vGetPage(m_w, m_h);
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
                if (pageno2 < m_pages.length) pageno2++;
            }
            if( m_disp_page1 < pageno1 )
            {
                int start = m_disp_page1;
                int end = pageno1;
                if( end > m_disp_page2 ) end = m_disp_page2;
                while( start < end )
                {
                    VPage vpage = m_pages[start];
                    vpage.vEndPage(m_thread);
                    start++;
                }
            }
            if( m_disp_page2 > pageno2 )
            {
                int start = pageno2;
                int end = m_disp_page2;
                if( start < m_disp_page1 ) start = m_disp_page1;
                while( start < end )
                {
                    VPage vpage = m_pages[start];
                    vpage.vEndPage(m_thread);
                    start++;
                }
            }
        }
        else
        {
            int start = m_disp_page1;
            int end = m_disp_page2;
            while( start < end )
            {
                VPage vpage = m_pages[start];
                vpage.vEndPage(m_thread);
                start++;
            }
        }
        m_disp_page1 = pageno1;
        m_disp_page2 = pageno2;
        /*
        int pageno1 = vGetPage(0, 0);
        int pageno2 = vGetPage(m_w, m_h);
        if (pageno1 >= 0 && pageno2 >= 0) {
            if (pageno1 > pageno2) {
                int tmp = pageno1;
                pageno1 = pageno2;
                pageno2 = tmp;
            }
            pageno2++;
            if (m_disp_page1 < pageno1) {
                int start = m_disp_page1;
                int end = pageno1;
                if (end > m_disp_page2) end = m_disp_page2;
                while (start < end) {
                    VPage vpage = m_pages[start];
                    vpage.vEndPage(m_thread);
                    start++;
                }
            }
            if (m_disp_page2 > pageno2) {
                int start = pageno2;
                int end = m_disp_page2;
                if (start < m_disp_page1) start = m_disp_page1;
                while (start < end) {
                    VPage vpage = m_pages[start];
                    vpage.vEndPage(m_thread);
                    start++;
                }
            }
        } else {
            int start = m_disp_page1;
            int end = m_disp_page2;
            while (start < end) {
                VPage vpage = m_pages[start];
                vpage.vEndPage(m_thread);
                start++;
            }
        }
        m_disp_page1 = pageno1;
        m_disp_page2 = pageno2;
        if (m_listener != null && (pageno1 = vGetPage(m_w / 4, m_h / 4)) != m_pageno)
            m_listener.OnPageChanged(m_pageno = pageno1);
        if (Global.g_cache_enable)
            vFlushCacheRange();
         */
    }
}