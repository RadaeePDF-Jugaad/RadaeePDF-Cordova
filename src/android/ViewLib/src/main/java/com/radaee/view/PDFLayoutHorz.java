package com.radaee.view;

import android.content.Context;

import com.radaee.pdf.Document;
import com.radaee.pdf.Global;

/*
 * PDFSample
 * Created by Nermeen on 06/12/2017.
 */
public class PDFLayoutHorz extends PDFLayout {
    private boolean m_rtol;
    public PDFLayoutHorz(Context context, boolean rtol) {
        super(context);
        m_rtol = rtol;
    }

    @Override
    public void vOpen(Document doc, LayoutListener listener) {
        super.vOpen(doc, listener);
        if(m_rtol) {
            m_scroller.setFinalX(m_tw);
            m_scroller.computeScrollOffset();
        }
    }

    @Override
    public void vResize(int cx, int cy) {
        boolean set = (m_rtol && (m_w <=0 || m_h <= 0));
        super.vResize(cx, cy);
        if( set ) {
            m_scroller.setFinalX(m_tw);
            m_scroller.computeScrollOffset();
        }
    }

    @Override
    public void vLayout() {
        if (m_w <= 0 || m_h <= 0 || m_doc == null || m_pages == null) return;

        int cnt = m_doc.GetPageCount();
        int cur;

        if(Global.g_auto_scale && m_scales == null) m_scales = new float[cnt];
        if(Global.g_auto_scale && m_scales_min == null) m_scales_min = new float[cnt];

        m_scale_min = (m_h - m_page_gap) / m_page_maxh;
        m_scale_max = m_scale_min * m_zoom_level;
        if (m_scale < m_scale_min) m_scale = m_scale_min;
        if (m_scale > m_scale_max) m_scale = m_scale_max;

        boolean clip = m_scale / m_scale_min > m_zoom_level_clip;
        m_th = (int) (m_page_maxh * m_scale);
        m_tw = 0;
        int x = m_page_gap >> 1;
        if(m_rtol) {
            for (cur = cnt - 1; cur >= 0; cur--) {
                if(Global.g_auto_scale && m_scales[cur] == 0) {
                    m_scales[cur] = ((float)(m_h - m_page_gap)) / m_doc.GetPageHeight(cur);
                    m_scales_min[cur] = ((float)(m_h - m_page_gap)) / m_doc.GetPageHeight(cur);
                }
                float pageScale = Global.g_auto_scale ? m_scales[cur] : m_scale;
                int w = (int) (m_doc.GetPageWidth(cur) * pageScale);
                int h = (int) (m_doc.GetPageHeight(cur) * pageScale);
                int y = Global.g_auto_scale ? m_page_gap >> 1 : ((int) (m_page_maxh * pageScale) + m_page_gap - h) >> 1;
                boolean clipPage = Global.g_auto_scale ? pageScale / m_scales_min[cur] > m_zoom_level_clip : clip;
                m_pages[cur].vLayout(x, y, pageScale, clipPage);
                x += w + m_page_gap;
            }
        } else {
            for (cur = 0; cur < cnt; cur++) {
                if(Global.g_auto_scale && m_scales[cur] == 0) {
                    m_scales[cur] = ((float)(m_h - m_page_gap)) / m_doc.GetPageHeight(cur);
                    m_scales_min[cur] = ((float)(m_h - m_page_gap)) / m_doc.GetPageHeight(cur);
                }
                float pageScale = Global.g_auto_scale ? m_scales[cur] : m_scale;
                int w = (int) (m_doc.GetPageWidth(cur) * pageScale);
                int h = (int) (m_doc.GetPageHeight(cur) * pageScale);
                int y = Global.g_auto_scale ? m_page_gap >> 1 : ((int) (m_page_maxh * pageScale) + m_page_gap - h) >> 1;
                boolean clipPage = Global.g_auto_scale ? pageScale / m_scales_min[cur] > m_zoom_level_clip : clip;
                m_pages[cur].vLayout(x, y, pageScale, clipPage);
                x += w + m_page_gap;
            }
        }
        m_tw = x - (m_page_gap >> 1);
    }

    @Override
    public int vGetPage(int vx, int vy) {
        if (m_pages == null) return -1;
        vx += vGetX();
        int left = 0;
        int right = m_pages.length - 1;
        VPage vpage;
        if(!m_rtol) {
            if (vx < m_pages[0].GetX())
                return 0;
            else if (vx > m_pages[right].GetX())
                return right;
        }

        while (left <= right) {
            int mid = (left + right) >> 1;
            vpage = m_pages[mid];
            switch (vpage.LocHorz(vx, m_page_gap >> 1)) {
                case -1:
                    if(m_rtol)
                        left = mid + 1;
                    else
                        right = mid - 1;
                    break;
                case 1:
                    if(m_rtol)
                        right = mid - 1;
                    else
                        left = mid + 1;
                    break;
                default:
                    if (vpage.GetWidth() <= 0 || vpage.GetHeight() <= 0) return -1;
                    return mid;
            }
        }
        return -1;
    }
}