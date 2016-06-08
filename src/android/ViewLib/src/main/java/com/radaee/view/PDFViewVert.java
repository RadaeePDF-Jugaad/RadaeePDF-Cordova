package com.radaee.view;

import android.content.Context;

import com.radaee.pdf.Global;

@Deprecated
public class PDFViewVert extends PDFView
{
	private int m_align = 0;
	public PDFViewVert(Context context)
	{
		super(context);
	}
	/**
	 * set page horizon align in view.<br/>
	 * if pages in document are all in same size, the align parameter shall no effect.
	 * @param align 0: left, 1: center, 2: right.
	 */
	public void vSetPageAlign(int align)
	{
		m_align = align;
	}
	@Override
	protected void vLayout()
	{
		if( m_doc == null || m_w <= m_page_gap || m_h <= m_page_gap ) return;
		int cur = 0;
		int cnt = m_doc.GetPageCount();
        float[] size = m_doc.GetPagesMaxSize();
        float maxw = size[0];
		m_scale_min = ((float)(m_w - m_page_gap)) / maxw;
		m_scale_max = m_scale_min * Global.g_view_zoom_level;
		if( m_scale < m_scale_min ) m_scale = m_scale_min;
		if( m_scale > m_scale_max ) m_scale = m_scale_max;

		if(m_pages == null) m_pages = new PDFVPage[cnt];
		int left = m_page_gap / 2;
		int top = m_page_gap / 2;
		m_docw = (int)(m_scale * maxw) + m_page_gap;
		cur = 0;
		if( m_align == 1 )//center
		{
			m_doch = 0;
			while( cur < cnt )
			{
				if( m_pages[cur] == null ) m_pages[cur] = new PDFVPage(m_doc, cur);
				left = (m_docw - (int)(m_doc.GetPageWidth(cur) * m_scale)) / 2;
				m_pages[cur].SetRect(left, top, m_scale);
				top += m_pages[cur].GetHeight() + m_page_gap;
				cur++;
			}
			m_doch = top;
		}
		else if( m_align == 2 )//right
		{
			m_doch = 0;
			while( cur < cnt )
			{
				if( m_pages[cur] == null ) m_pages[cur] = new PDFVPage(m_doc, cur);
				left = m_docw - (int)(m_doc.GetPageWidth(cur) * m_scale) - m_page_gap / 2;
				m_pages[cur].SetRect(left, top, m_scale);
				top += m_pages[cur].GetHeight() + m_page_gap;
				cur++;
			}
			m_doch = top;
		}
		else
		{
			m_doch = 0;
			while( cur < cnt )
			{
				if( m_pages[cur] == null ) m_pages[cur] = new PDFVPage(m_doc, cur);
				m_pages[cur].SetRect(left, top, m_scale);
				top += m_pages[cur].GetHeight() + m_page_gap;
				cur++;
			}
			m_doch = top;
		}
	}
	@Override
	protected int vGetPage( int vx, int vy )
	{
		if( m_pages == null || m_pages.length <= 0 ) return -1;
		int left = 0;
		int right = m_pages.length - 1;
		int y = m_scroller.getCurrY() + vy;
		int gap = m_page_gap>>1;
		while( left <= right )
		{
			int mid = (left + right)>>1;
			PDFVPage pg1 = m_pages[mid];
			if( y < pg1.GetY() - gap )
			{
				right = mid - 1;
			}
			else if( y > pg1.GetY() + pg1.GetHeight() + gap )
			{
				left = mid + 1;
			}
			else
			{
				return mid;
			}
		}
		if( right < 0 ) return 0;
		else return m_pages.length - 1;
	}
}
