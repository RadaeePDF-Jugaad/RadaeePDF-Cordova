package com.radaee.view;

import android.content.Context;

import com.radaee.pdf.Document;
import com.radaee.pdf.Global;

public class PDFLayoutDual extends PDFLayout
{
    private boolean[] m_vert_dual;
    private boolean[] m_horz_dual;
    private boolean m_rtol = false;
    private boolean m_rtol_init = false;
    private boolean m_page_align_top = true;
    protected static class PDFCell
    {
        public int left;
        public int right;
        int page_left;
        int page_right;
    }
    protected PDFCell[] m_cells;
    public PDFLayoutDual(Context context)
    {
        super(context);
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
    public boolean vFling(int holdx, int holdy, float dx, float dy, float vx, float vy)
    {
        if(m_cells == null) return false;
        vx *= Global.fling_speed;
        vy *= Global.fling_speed;
        int x = vGetX();
        int y = vGetY();
        int endx = x - (int)vx;
        int endy = y - (int)vy;
        if(endx > m_tw - m_w) endx = m_tw - m_w;
        if(endx < 0) endx = 0;
        if(endy > m_th - m_h) endy = m_th - m_h;
        if(endy < 0) endy = 0;
        int cell1 = vGetCell(x);
        int cell2 = vGetCell(endx);
        if(cell2 > cell1) cell2 = cell1 + 1;
        if(cell2 < cell1) cell2 = cell1 - 1;
        m_scroller.abortAnimation();
        m_scroller.forceFinished(true);
        //vScrollAbort();
        if(m_rtol) {
            if (cell1 > cell2) {
                if (cell2 < 0)
                    do_scroll(x, y, m_cells[0].right - m_w - x, 0);
                else {
                    PDFCell cell = m_cells[cell1];
                    if (x < cell.right - m_w)
                        do_scroll(x, y, cell.right - m_w - x, endy - y);
                    else
                        do_scroll(x, y, m_cells[cell2].left - x, endy - y);
                }
            } else if (cell1 < cell2) {
                if (cell2 == m_cells.length)
                    do_scroll(x, y, -x, endy - y);
                else {
                    PDFCell cell = m_cells[cell1];
                    if (x > cell.left)
                        do_scroll(x, y, cell.left - x, endy - y);
                    else
                        do_scroll(x, y, m_cells[cell2].right - m_w - x, endy - y);
                }
            } else {
                PDFCell cell = m_cells[cell2];
                if (endx + m_w > cell.right) {
                    if (endx + (m_w>>1) > cell.right) {
                        cell2--;
                        if (cell2 < 0)
                            do_scroll(x, y, m_cells[cell2 + 1].left - x, endy - y);
                        else
                            do_scroll(x, y, m_cells[cell2].right - m_w - x, endy - y);
                    } else
                        do_scroll(x, y, m_cells[cell2].right - m_w - x, endy - y);
                } else
                    do_scroll(x, y, endx - x, endy - y);
            }
        }
        else {
            if (cell1 < cell2) {
                if (cell2 == m_cells.length)
                    do_scroll(x, y, m_cells[cell2 - 1].right - m_w - x, endy - y);
                else {
                    PDFCell cell = m_cells[cell1];
                    if (x < cell.right - m_w)
                        do_scroll(x, y, cell.right - m_w - x, endy - y);
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
                        do_scroll(x, y, m_cells[cell2].right - m_w - x, endy - y);
                }
            } else {
                PDFCell cell = m_cells[cell2];
                if (endx + m_w > cell.right) {
                    if (endx + (m_w>>1) > cell.right) {
                        cell2++;
                        if (cell2 == m_cells.length)
                            do_scroll(x, y, m_cells[cell2 - 1].right - m_w - x, endy - y);
                        else
                            do_scroll(x, y, m_cells[cell2].left - x, endy - y);
                    } else
                        do_scroll(x, y, m_cells[cell2].right - m_w - x, endy - y);
                } else {
                    do_scroll(x, y, endx - x, endy - y);
                }
            }
        }
        return true;
    }
    @Override
    public void vLayout()
    {
        if( m_doc == null || m_w <= m_page_gap || m_h <= m_page_gap ) return;
        int pcur = 0;
        int pcnt = m_doc.GetPageCount();
        int ccur = 0;
        int ccnt = 0;
        float max_w = 0;
        float max_h = 0;
        float max_sh = 0;
        if(Global.g_auto_scale)
        {
            if (m_scales == null)
                m_scales = new float[pcnt];
            if (m_scales_min == null)
                m_scales_min = new float[pcnt];
        }
        //int clipw = (m_w > m_h) ? m_h : m_w;
        if( m_h > m_w ) //portrait
        {
            while( pcur < pcnt )
            {
                if( m_vert_dual != null && ccnt < m_vert_dual.length && m_vert_dual[ccnt] && pcur < pcnt - 1 )
                {
                    float w = m_doc.GetPageWidth(pcur) + m_doc.GetPageWidth(pcur + 1);
                    if( max_w < w ) max_w = w;
                    float h0 = m_doc.GetPageHeight(pcur);
                    if( max_h < h0 ) max_h = h0;
                    float h1 = m_doc.GetPageHeight(pcur + 1);
                    if( max_h < h1 ) max_h = h1;
                    if(Global.g_auto_scale)
                    {
                        if(m_scales[pcur] == 0)
                        {
                            float minScale = (m_w - m_page_gap) / w;
                            float maxh = h0;
                            if (maxh < h1) maxh = h1;
                            float scale = ((float) (m_h - m_page_gap)) / maxh;
                            if (minScale > scale) minScale = scale;
                            m_scales[pcur] = minScale;
                            m_scales_min[pcur] = minScale;
                            m_scales[pcur + 1] = minScale;
                            m_scales_min[pcur + 1] = minScale;
                        }
                        if(max_sh < m_scales[pcur] * h0) max_sh = m_scales[pcur] * h0;
                        if(max_sh < m_scales[pcur + 1] * h1) max_sh = m_scales[pcur + 1] * h1;
                    }
                    pcur += 2;
                }
                else
                {
                    float w = m_doc.GetPageWidth(pcur);
                    if( max_w < w ) max_w = w;
                    float h = m_doc.GetPageHeight(pcur);
                    if( max_h < h ) max_h = h;
                    if(Global.g_auto_scale)
                    {
                        if(m_scales[pcur] == 0) {
                            float minScale = (m_w - m_page_gap) / w;
                            float scale = ((float) (m_h - m_page_gap)) / h;
                            if (minScale > scale) minScale = scale;
                            m_scales[pcur] = minScale;
                            m_scales_min[pcur] = minScale;
                        }
                        if(max_sh < m_scales[pcur] * h) max_sh = m_scales[pcur] * h;
                    }
                    pcur++;
                }
                ccnt++;
            }
            m_scale_min = ((float)(m_w - m_page_gap)) / max_w;
            float scale = ((float)(m_h - m_page_gap)) / max_h;
            if( m_scale_min > scale ) m_scale_min = scale;
            m_scale_max = m_scale_min * m_zoom_level;
            if( m_scale < m_scale_min ) m_scale = m_scale_min;
            if( m_scale > m_scale_max ) m_scale = m_scale_max;
            boolean clip = m_scale / m_scale_min > m_zoom_level_clip;
            m_th = (Global.g_auto_scale ? (int)max_sh : (int)(max_h * m_scale)) + m_page_gap;
            if( m_th < m_h ) m_th = m_h;
            m_cells = new PDFCell[ccnt];
            pcur = 0;
            ccur = 0;
            int left = 0;
            while( ccur < ccnt )
            {
                PDFCell cell = new PDFCell();
                int w = 0;
                int cw = 0;
                boolean clipPage = Global.g_auto_scale ? m_scales[pcur] / m_scales_min[pcur] > m_zoom_level_clip : clip;
                float pageScale = Global.g_auto_scale ? m_scales[pcur] : m_scale;
                if( m_vert_dual != null && ccur < m_vert_dual.length && m_vert_dual[ccur] && pcur < pcnt - 1 )
                {
                    float pageScale2 = Global.g_auto_scale ? m_scales[pcur + 1] : m_scale;
                    w = Global.g_auto_scale ? (int)( (m_doc.GetPageWidth(pcur) * pageScale) + (m_doc.GetPageWidth(pcur + 1)
                            * pageScale2)) : (int)( (m_doc.GetPageWidth(pcur) + m_doc.GetPageWidth(pcur + 1)) * pageScale);
                    if( w + m_page_gap < m_w ) cw = m_w;
                    else cw = w + m_page_gap;
                    cell.page_left = pcur;
                    cell.page_right = pcur + 1;
                    cell.left = left;
                    cell.right = left + cw;
                    if(m_page_align_top)
                    {
                        m_pages[pcur].vLayout(left + (cw - w) / 2, m_page_gap / 2, pageScale, clipPage);
                        m_pages[pcur + 1].vLayout(m_pages[pcur].GetX() + m_pages[pcur].GetWidth(), m_page_gap / 2, pageScale2, clipPage);
                    }
                    else
                    {
                        m_pages[pcur].vLayout(left + (cw - w) / 2, (int) (m_th - m_doc.GetPageHeight(pcur) * pageScale) / 2, pageScale, clipPage);
                        m_pages[pcur + 1].vLayout(m_pages[pcur].GetX() + m_pages[pcur].GetWidth(), (int) (m_th - m_doc.GetPageHeight(pcur + 1) * pageScale2) / 2, pageScale2, clipPage);
                    }
                    pcur += 2;
                }
                else
                {
                    w = (int)( m_doc.GetPageWidth(pcur) * pageScale );
                    if( w + m_page_gap < m_w ) cw = m_w;
                    else cw = w + m_page_gap;
                    cell.page_left = pcur;
                    cell.page_right = -1;
                    cell.left = left;
                    cell.right = left + cw;
                    if(m_page_align_top) {
                        m_pages[pcur].vLayout(left + (cw - w) / 2, m_page_gap / 2, pageScale, clipPage);
                    }
                    else {
                        m_pages[pcur].vLayout(left + (cw - w) / 2, (int) (m_th - m_doc.GetPageHeight(pcur) * pageScale) / 2, pageScale, clipPage);
                    }
                    pcur++;
                }
                left += cw;
                m_cells[ccur] = cell;
                ccur++;
            }
            m_tw = left;
        }
        else //landscape
        {
            while( pcur < pcnt )
            {
                if( (m_horz_dual == null || ccnt >= m_horz_dual.length || (m_horz_dual[ccnt]) && pcur < pcnt - 1) )
                {
                    float w = m_doc.GetPageWidth(pcur) + m_doc.GetPageWidth(pcur + 1);
                    if( max_w < w ) max_w = w;
                    float h0 = m_doc.GetPageHeight(pcur);
                    if( max_h < h0 ) max_h = h0;
                    float h1 = m_doc.GetPageHeight(pcur + 1);
                    if( max_h < h1 ) max_h = h1;
                    if(Global.g_auto_scale)
                    {
                        if (m_scales[pcur] == 0)
                        {
                            float minScale = (m_w - m_page_gap) / w;
                            float maxh = h0;
                            if (maxh < h1) maxh = h1;
                            float scale = ((float) (m_h - m_page_gap)) / maxh;
                            if (minScale > scale) minScale = scale;
                            m_scales[pcur] = minScale;
                            m_scales_min[pcur] = minScale;
                            m_scales[pcur + 1] = minScale;
                            m_scales_min[pcur + 1] = minScale;
                        }
                        if(max_sh < m_scales[pcur] * h0) max_sh = m_scales[pcur] * h0;
                        if(max_sh < m_scales[pcur + 1] * h1) max_sh = m_scales[pcur + 1] * h1;
                    }
                    pcur += 2;
                }
                else
                {
                    float w = m_doc.GetPageWidth(pcur);
                    if( max_w < w ) max_w = w;
                    float h = m_doc.GetPageHeight(pcur);
                    if( max_h < h ) max_h = h;
                    if(Global.g_auto_scale)
                    {
                        if(m_scales[pcur] == 0)
                        {
                            float minScale = (m_w - m_page_gap) / w;
                            float scale = ((float) (m_h - m_page_gap)) / h;
                            if (minScale > scale) minScale = scale;
                            m_scales[pcur] = minScale;
                            m_scales_min[pcur] = minScale;
                        }
                        if(max_sh < m_scales[pcur] * h) max_sh = m_scales[pcur] * h;
                    }
                    pcur++;
                }
                ccnt++;
            }
            m_scale_min = ((float)(m_w - m_page_gap)) / max_w;
            float scale = ((float)(m_h - m_page_gap)) / max_h;
            if( m_scale_min > scale ) m_scale_min = scale;
            m_scale_max = m_scale_min * m_zoom_level;
            if( m_scale < m_scale_min ) m_scale = m_scale_min;
            if( m_scale > m_scale_max ) m_scale = m_scale_max;
            boolean clip = m_scale / m_scale_min > m_zoom_level_clip;
            m_th = (Global.g_auto_scale ? (int)max_sh : (int)(max_h * m_scale)) + m_page_gap;
            if( m_th < m_h ) m_th = m_h;
            m_cells = new PDFCell[ccnt];
            pcur = 0;
            ccur = 0;
            int left = 0;
            while( ccur < ccnt )
            {
                PDFCell cell = new PDFCell();
                int w = 0;
                int cw = 0;
                boolean clipPage = Global.g_auto_scale ? m_scales[pcur] / m_scales_min[pcur] > m_zoom_level_clip : clip;
                float pageScale = Global.g_auto_scale ? m_scales[pcur] : m_scale;
                if ((m_horz_dual == null || ccur >= m_horz_dual.length ) && pcur == 0 )
                {
                    w = (int)( m_doc.GetPageWidth(pcur) * pageScale );
                    if( w + m_page_gap < m_w ) cw = m_w;
                    else cw = w + m_page_gap;
                    cell.page_left = pcur;
                    cell.page_right = -1;
                    cell.left = left;
                    cell.right = left + cw;
                    if(m_page_align_top)
                    {
                        m_pages[pcur].vLayout(left + (cw - w) / 2, m_page_gap / 2, pageScale, clipPage);
                    }
                    else {
                        m_pages[pcur].vLayout(left + (cw - w) / 2, (int) (m_th - m_doc.GetPageHeight(pcur) * pageScale) / 2, pageScale, clipPage);
                    }
                    pcur++;
                }
                else if( (m_horz_dual == null || ccur >= m_horz_dual.length || m_horz_dual[ccur]) && pcur < pcnt - 1 )
                {
                    float pageScale2 = Global.g_auto_scale ? m_scales[pcur + 1] : m_scale;
                    w = Global.g_auto_scale ? (int)( (m_doc.GetPageWidth(pcur) * pageScale) + (m_doc.GetPageWidth(pcur + 1)
                            * pageScale2)) : (int)( (m_doc.GetPageWidth(pcur) + m_doc.GetPageWidth(pcur + 1)) * pageScale);
                    if( w + m_page_gap < m_w ) cw = m_w;
                    else cw = w + m_page_gap;
                    cell.page_left = pcur;
                    cell.page_right = pcur + 1;
                    cell.left = left;
                    cell.right = left + cw;
                    if(m_page_align_top)
                    {
                        m_pages[pcur].vLayout(left + (cw - w) / 2, m_page_gap / 2, pageScale, clip);
                        m_pages[pcur + 1].vLayout(m_pages[pcur].GetX() + m_pages[pcur].GetWidth(), m_page_gap / 2, pageScale2, clip);
                    }
                    else {
                        m_pages[pcur].vLayout(left + (cw - w) / 2, (int) (m_th - m_doc.GetPageHeight(pcur) * pageScale) / 2, pageScale, clip);
                        m_pages[pcur + 1].vLayout(m_pages[pcur].GetX() + m_pages[pcur].GetWidth(), (int) (m_th - m_doc.GetPageHeight(pcur + 1) * pageScale2) / 2, pageScale2, clip);
                    }
                    pcur += 2;
                }
                else
                {
                    w = (int)( m_doc.GetPageWidth(pcur) * pageScale );
                    if( w + m_page_gap < m_w ) cw = m_w;
                    else cw = w + m_page_gap;
                    cell.page_left = pcur;
                    cell.page_right = -1;
                    cell.left = left;
                    cell.right = left + cw;
                    if(m_page_align_top)
                    {
                        m_pages[pcur].vLayout(left + (cw - w) / 2, m_page_gap / 2, pageScale, clipPage);
                    }
                    else {
                        m_pages[pcur].vLayout(left + (cw - w) / 2, (int) (m_th - m_doc.GetPageHeight(pcur) * pageScale) / 2, pageScale, clipPage);
                    }
                    pcur++;
                }
                left += cw;
                m_cells[ccur] = cell;
                ccur++;
            }
            m_tw = left;
        }
        if( m_rtol )
        {
            ccur = 0;
            pcur = 0;
            while( ccur < ccnt )
            {
                PDFCell cell = m_cells[ccur];
                int tmp = cell.left;
                cell.left = m_tw - cell.right;
                cell.right = m_tw - tmp;
                if( cell.page_right >= 0 )
                {
                    tmp = cell.page_left;
                    cell.page_left = cell.page_right;
                    cell.page_right = tmp;
                }
                ccur++;
            }
            while( pcur < pcnt )
            {
                VPage vpage = m_pages[pcur];
                vpage.SetX(m_tw - (vpage.GetX() + vpage.GetWidth()));
                pcur++;
            }
            if(!m_rtol_init)
            {
                m_scroller.setFinalX(m_tw - m_w);
                m_rtol_init = true;
            }
        }
    }
    @Override
    public void vClose()
    {
        super.vClose();
        m_rtol_init = false;
    }
    @Override
    public int vGetPage(int vx, int vy)
    {
        if( m_pages == null || m_pages.length <= 0  || m_cells == null) return -1;
        int left = 0;
        int right = m_cells.length - 1;
        vx += vGetX();
        if( !m_rtol )//ltor
        {
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
                    VPage vpage = m_pages[pg1.page_left];
                    if(pg1.page_right >= 0 && vx > vpage.GetX() + vpage.GetWidth() )
                        return pg1.page_right;
                    else
                        return pg1.page_left;
                }
            }
        }
        else//rtol
        {
            while( left <= right )
            {
                int mid = (left + right)>>1;
                PDFCell pg1 = m_cells[mid];
                if( vx < pg1.left )
                {
                    left = mid + 1;
                }
                else if( vx > pg1.right )
                {
                    right = mid - 1;
                }
                else
                {
                    VPage vpage = m_pages[pg1.page_left];
                    if(pg1.page_right >= 0 && vx > vpage.GetX() + vpage.GetWidth() )
                        return pg1.page_right;
                    else
                        return pg1.page_left;
                }
            }
        }
        if( right < 0 )
        {
            return 0;
        }
        else
        {
            return m_pages.length - 1;
        }
    }
    protected int vGetCell(int vx)
    {
        if( m_pages == null || m_pages.length <= 0  || m_cells == null) return -1;
        int left = 0;
        int right = m_cells.length - 1;
        if( !m_rtol )//ltor
        {
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
        }
        else//rtol
        {
            while( left <= right )
            {
                int mid = (left + right)>>1;
                PDFCell pg1 = m_cells[mid];
                if( vx < pg1.left )
                {
                    left = mid + 1;
                }
                else if( vx > pg1.right )
                {
                    right = mid - 1;
                }
                else
                {
                    return mid;
                }
            }
        }
        if(right < 0) return -1;
        else return m_cells.length;
    }
    @Override
    public void vMoveEnd()
    {
        int ccur = 0;
        int x = vGetX();
        int y = vGetY();
        if( m_rtol )
        {
            while( ccur < m_cells.length )
            {
                PDFCell cell = m_cells[ccur];
                if( x >= cell.left )
                {
                    m_scroller.abortAnimation();
                    m_scroller.forceFinished(true);
                    if( x <= cell.right - m_w )
                    {
                    }
                    else if( cell.right - x > m_w/2 )
                    {
                        m_scroller.startScroll(x, y, cell.right - x - m_w, 0);
                    }
                    else if( ccur < m_cells.length - 1 )
                    {
                        m_scroller.startScroll(x, y, cell.right - x, 0);
                    }
                    else
                    {
                        m_scroller.startScroll(x, y, cell.right - x - m_w, 0);
                    }
                    break;
                }
                ccur++;
            }
        }
        else
        {
            while( ccur < m_cells.length )
            {
                PDFCell cell = m_cells[ccur];
                if( x < cell.right )
                {
                    m_scroller.abortAnimation();
                    m_scroller.forceFinished(true);
                    if( x <= cell.right - m_w )
                    {
                    }
                    else if( cell.right - x > m_w/2 )
                    {
                        m_scroller.startScroll(x, y, cell.right - x - m_w, 0);
                    }
                    else if( ccur < m_cells.length - 1 )
                    {
                        m_scroller.startScroll(x, y, cell.right - x, 0);
                    }
                    else
                    {
                        m_scroller.startScroll(x, y, cell.right - x - m_w, 0);
                    }
                    break;
                }
                ccur++;
            }
        }
    }
    @Override
    public void vGotoPage( int pageno )
    {
        if( m_pages == null || m_doc == null || m_w <= 0 || m_h <= 0 || pageno < 0 || pageno >= m_pages.length ) return;
        
        vScrollAbort();
        int ccur = 0;
        while( ccur < m_cells.length )
        {
            PDFCell cell = m_cells[ccur];
            if( pageno == cell.page_left || pageno == cell.page_right )
            {
                int left = m_cells[ccur].left;
                int w = m_cells[ccur].right - left;
                int x = left + (w - m_w)/2;
                m_scroller.setFinalX(x);
                m_scroller.computeScrollOffset();
                m_scroller.setFinalX(x);
                break;
            }
            ccur++;
        }
    }
    @Override
    public void vScrolltoPage( int pageno )
    {
        if( m_pages == null || m_doc == null || m_w <= 0 || m_h <= 0 || pageno < 0 || pageno >= m_pages.length ) return;
        vScrollAbort();
        int ccur = 0;
        while( ccur < m_cells.length )
        {
            PDFCell cell = m_cells[ccur];
            if( pageno == cell.page_left || pageno == cell.page_right )
            {
                int left = m_cells[ccur].left;
                int w = m_cells[ccur].right - left;
                int x = left + (w - m_w)/2;
                m_scroller.computeScrollOffset();
                float oldx = m_scroller.getCurrX();
                float oldy = m_scroller.getCurrY();
                m_scroller.startScroll((int)oldx, (int)oldy, (int)(x - oldx), 0);
                break;
            }
            ccur++;
        }
    }
    public void vSetLayoutPara( boolean[] verts, boolean[] horzs, boolean rtol, boolean pages_align_top )
    {
        m_vert_dual = verts;
        m_horz_dual = horzs;
        m_rtol = rtol;
        m_page_align_top = pages_align_top;
        vLayout();
    }
    protected void vFindGoto() {
        if (m_pages == null) return;
        int pg = m_finder.find_get_page();
        if (pg < 0 || pg >= m_doc.GetPageCount()) return;
        int x = vGetX();
        int y = vGetY();
        float[] pos = m_finder.find_get_pos();
        if (pos == null) return;
        pos[0] = m_pages[pg].ToDIBX(pos[0]) + m_pages[pg].GetX();
        pos[1] = m_pages[pg].ToDIBY(pos[1]) + m_pages[pg].GetY();
        pos[2] = m_pages[pg].ToDIBX(pos[2]) + m_pages[pg].GetX();
        pos[3] = m_pages[pg].ToDIBY(pos[3]) + m_pages[pg].GetY();
        if (x > pos[0] - m_w / 8) x = (int) pos[0] - m_w / 8;
        if (x < pos[2] - m_w * 7 / 8) x = (int) pos[2] - m_w * 7 / 8;
        if (y > pos[1] - m_h / 8) y = (int) pos[1] - m_h / 8;
        if (y < pos[3] - m_h * 7 / 8) y = (int) pos[3] - m_h * 7 / 8;
        if (x > m_tw - m_w) x = m_tw - m_w;
        if (x < 0) x = 0;
        if (y > m_th - m_h) y = m_th - m_h;
        if (y < 0) y = 0;
        vScrollAbort();
        m_scroller.setFinalX(x);
        m_scroller.setFinalY(y);
        vGotoPage(pg);
    }
}