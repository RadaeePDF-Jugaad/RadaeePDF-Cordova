package com.radaee.view;

import android.content.Context;

import com.radaee.pdf.Document;
import com.radaee.pdf.Global;

@Deprecated
public class PDFViewHorz extends PDFView
{
	private boolean m_rtol = false;
	public PDFViewHorz(Context context)
	{
		super(context);
	}
	public void vSetDirection( boolean rtol )
	{
		m_rtol = rtol;
	}
	@Override
	public void vOpen(Document doc, int page_gap, int back_color, PDFViewListener listener)
	{
		super.vOpen(doc, page_gap, back_color, listener);
		if( m_rtol )
		{
			m_scroller.setFinalX(m_docw);
			m_scroller.computeScrollOffset();
		}
	}
	@Override
	public void vResize(int w, int h)
	{
		boolean set = (m_rtol && (m_w <=0 || m_h <= 0));
		super.vResize(w, h);
		if( set )
		{
			m_scroller.setFinalX(m_docw);
			m_scroller.computeScrollOffset();
		}
	}
	@Override
	protected void vLayout()
	{
		if( m_doc == null || m_w <= m_page_gap || m_h <= m_page_gap ) return;
		int cur = 0;
		int cnt = m_doc.GetPageCount();
        float[] size = m_doc.GetPagesMaxSize();
		float maxh = size[1];
		m_scale_min = ((float)(m_h - m_page_gap)) / maxh;
		m_scale_max = m_scale_min * Global.g_view_zoom_level;
		if( m_scale < m_scale_min ) m_scale = m_scale_min;
		if( m_scale > m_scale_max ) m_scale = m_scale_max;

		if(m_pages == null) m_pages = new PDFVPage[cnt];
		int left = m_page_gap / 2;
		int top = m_page_gap / 2;
		m_docw = 0;
		m_doch = 0;
		if( m_rtol )
		{
			cur = cnt - 1;
			while( cur >= 0 )
			{
				if( m_pages[cur] == null ) m_pages[cur] = new PDFVPage(m_doc, cur);
				m_pages[cur].SetRect(left, top, m_scale);
				left += m_pages[cur].GetWidth() + m_page_gap;
				if( m_doch < m_pages[cur].GetHeight() ) m_doch = m_pages[cur].GetHeight();
				cur--;
			}
		}
		else
		{
			cur = 0;
			while( cur < cnt )
			{
				if( m_pages[cur] == null ) m_pages[cur] = new PDFVPage(m_doc, cur);
				m_pages[cur].SetRect(left, top, m_scale);
				left += m_pages[cur].GetWidth() + m_page_gap;
				if( m_doch < m_pages[cur].GetHeight() ) m_doch = m_pages[cur].GetHeight();
				cur++;
			}
		}
		m_docw = left;
	}
	@Override
	protected int vGetPage( int vx, int vy )
	{
		if( m_pages == null || m_pages.length <= 0 ) return -1;
		int left = 0;
		int right = m_pages.length - 1;
		int gap = m_page_gap>>1;
		int x = m_scroller.getCurrX() + vx;
		if( !m_rtol )//ltor
		{
			while( left <= right )
			{
				int mid = (left + right)>>1;
				PDFVPage pg1 = m_pages[mid];
				if( x < pg1.GetX() - gap )
				{
					right = mid - 1;
				}
				else if( x > pg1.GetX() + pg1.GetWidth() + gap )
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
				PDFVPage pg1 = m_pages[mid];
				if( x < pg1.GetX() - gap )
				{
					left = mid + 1;
				}
				else if( x > pg1.GetX() + pg1.GetWidth() + gap )
				{
					right = mid - 1;
				}
				else
				{
					return mid;
				}
			}
		}
		if( right < 0 ) return 0;
		else return m_pages.length - 1;
	}
}
