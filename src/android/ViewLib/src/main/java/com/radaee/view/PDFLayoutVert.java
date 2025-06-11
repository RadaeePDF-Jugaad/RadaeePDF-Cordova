package com.radaee.view;

import android.content.Context;

import com.radaee.pdf.Global;

public class PDFLayoutVert extends PDFLayout
{
	@Override
	public void vLayout()
	{
		if(m_w <= 0 || m_h <= 0 || m_doc == null || m_pages == null) return;
        int cnt = m_doc.GetPageCount();
        int cur;

		if(Global.g_auto_scale && m_scales == null) m_scales = new float[cnt];
		if(Global.g_auto_scale && m_scales_min == null) m_scales_min = new float[cnt];

		m_scale_min = (m_w - m_page_gap) / m_page_maxw;
		m_scale_max = m_scale_min * m_zoom_level;
		if(m_scale < m_scale_min) m_scale = m_scale_min;
		if(m_scale > m_scale_max) m_scale = m_scale_max;
		m_tw = (int)(m_page_maxw * m_scale);
		m_th = 0;
		int y = m_page_gap>>1;
		boolean clip = m_scale / m_scale_min > m_zoom_level_clip;
		for(cur = 0;cur < cnt;cur++)
		{
			if(Global.g_auto_scale && m_scales[cur] == 0) {
				m_scales[cur] = ((float)(m_w - m_page_gap)) / m_doc.GetPageWidth(cur);
				m_scales_min[cur] = ((float)(m_w - m_page_gap)) / m_doc.GetPageWidth(cur);
			}
            float pageScale = Global.g_auto_scale ? m_scales[cur] : m_scale;
			int w = (int)(m_doc.GetPageWidth(cur) * pageScale);
			int h = (int)(m_doc.GetPageHeight(cur) * pageScale);
			int x = Global.g_auto_scale ? m_page_gap >> 1:
					((int)(m_page_maxw * pageScale) + m_page_gap - w)>>1;
			boolean clipPage = Global.g_auto_scale ? pageScale / m_scales_min[cur] > m_zoom_level_clip : clip;
			m_pages[cur].vLayout(x, y, pageScale, clipPage);
			y += h + m_page_gap;
		}
		m_th = y - (m_page_gap>>1);
	}

	public PDFLayoutVert(Context context)
	{
		super(context);
	}

	@Override
	public int vGetPage(int vx, int vy)
	{
			if( m_pages == null) return -1;
			vx += vGetX();
			vy += vGetY();
			int left = 0;
			int right = m_pages.length - 1;
			VPage vpage;
			if( vy < m_pages[0].GetY() )
            {
                return 0;
            }
            else if( vy > m_pages[right].GetY() )
            {
                return right;
            }
			while(left <= right)
            {
                int mid = (left + right)>>1;
                vpage = m_pages[mid];
                switch(vpage.LocVert(vy, m_page_gap>>1))
                {
                case -1:
                    right = mid - 1;
                    break;
                case 1:
                    left = mid + 1;
                    break;
                default:
                    if( vpage.GetWidth() <= 0 || vpage.GetHeight() <= 0 ) return -1;
                    return mid;
                }
            }
		return -1;
	}
}