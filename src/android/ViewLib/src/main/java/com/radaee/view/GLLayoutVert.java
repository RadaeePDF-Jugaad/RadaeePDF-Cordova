package com.radaee.view;

import android.content.Context;

public class GLLayoutVert extends GLLayout {
    public static final int ALIGN_CENTER = 0;
    public static final int ALIGN_LEFT = 1;
    public static final int ALIGN_RIGHT = 2;
    private final int m_align;
    private final boolean m_same_width;
    public GLLayoutVert(Context context, int align, boolean same_width)
    {
        super(context);
        m_same_width = same_width;
        m_align = align;
    }
    @Override
    public int vGetPage(int vx, int vy) {
        if(m_vw <= 0 || m_vh <= 0) return -1;
        vy += vGetY();
        int pl = 0;
        int pr = m_page_cnt - 1;
        int hg = (m_page_gap >> 1);
        while(pr >= pl)
        {
            int mid = (pl + pr) >> 1;
            GLPage pmid = m_pages[mid];
            if(vy < pmid.GetTop() - hg)
                pr = mid - 1;
            else if(vy >= pmid.GetBottom() + hg)
                pl = mid + 1;
            else return mid;
        }
        return (pr < 0) ? 0 : pr;
    }

    @Override
    public void gl_layout(float scale, boolean zoom)
    {
        if(m_vw <= 0 || m_vh <= 0) return;
        float[] size = m_doc.GetPagesMaxSize();
        m_scale_min = (m_vw - m_page_gap) / size[0];
        float max_scale = m_scale_min * m_max_zoom;
        if(scale < m_scale_min) scale = m_scale_min;
        if(scale > max_scale) scale = max_scale;
        if(m_scale == scale) return;
        m_scale = scale;
        m_layw = (int)(size[0] * m_scale) + m_page_gap;
        int y = m_page_gap >> 1;
        for(int pcur = 0; pcur < m_page_cnt; pcur++)
        {
            int x;
            float pg_scale = m_scale;
            float pg_width = m_doc.GetPageWidth(pcur);
            if(m_same_width)
                pg_scale = m_scale * size[0] / pg_width;
            switch(m_align)
            {
                case ALIGN_LEFT:
                    x = m_page_gap >> 1;
                    break;
                case ALIGN_RIGHT:
                    x = m_layw - (m_page_gap >> 1);
                    break;
                default:
                    x = (m_layw - (int)(m_doc.GetPageWidth(pcur) * pg_scale)) >> 1;
                    break;
            }
            m_pages[pcur].gl_layout(x, y, pg_scale);
            if(!zoom) m_pages[pcur].gl_alloc();
            y += (int)(m_doc.GetPageHeight(pcur) * pg_scale) + m_page_gap;
        }
        m_layh = y - (m_page_gap >> 1);
    }
}
