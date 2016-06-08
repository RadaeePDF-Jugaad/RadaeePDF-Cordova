package com.radaee.view;

import com.radaee.pdf.DIB;
import com.radaee.pdf.Document;
import com.radaee.pdf.Global;

import android.content.Context;
import android.graphics.Canvas;
import android.view.MotionEvent;

@Deprecated
public class PDFViewCurl extends PDFView
{
	private int m_pageno = 0;
	private boolean m_duals[];
	private DIB m_dib1 = null;
	private DIB m_dib2 = null;
	private int mBackSideClr = 0xFFFFFFCC;
	public PDFViewCurl(Context context)
	{
		super(context);
	}
	@Override
	public void vOpen(Document doc, int page_gap, int back_color, PDFViewListener listener)
	{
		super.vOpen(doc, page_gap, back_color, listener);
		m_pageno = 0;
		m_duals = null;
		m_dib1 = new DIB();
		m_dib2 = new DIB();
	}
	@Override
	public void vClose()
	{
		super.vClose();
		if(m_dib1 != null) m_dib1.Free();
		if(m_dib2 != null) m_dib2.Free();
		m_dib1 = null;
		m_dib2 = null;
		m_pageno = 0;
		m_duals = null;
	}
	@Override
	protected void vLayout()
	{
		if( m_doc == null || m_w <= m_page_gap || m_h <= m_page_gap ) return;
		m_docw = m_w;
		m_doch = m_h;
		m_dib1.CreateOrResize(m_w, m_h);
		m_dib2.CreateOrResize(m_w, m_h);
		int cur = 0;
		int cnt = m_doc.GetPageCount();
		if(m_pages == null)
		{
			m_pages = new PDFVPage[cnt];
			m_duals = new boolean[cnt];
		}
		if( m_h > m_w )//vertical
		{
			for( cur = 0; cur < cnt; cur++ )
			{
				if( m_pages[cur] == null ) m_pages[cur] = new PDFVPage(m_doc, cur);
				float w1 = m_doc.GetPageWidth(cur);
				float h1 = m_doc.GetPageHeight(cur);
				float w2 = 0;
				float h2 = 0;
				m_duals[cur] = false;
				if( w1 > h1 && cur < cnt - 1 )
				{
					w2 = m_doc.GetPageWidth(cur + 1);
					h2 = m_doc.GetPageHeight(cur + 1);
					if( w2 > h2 ) m_duals[cur] = true;
				}
				float scale1;
				float scale2;
				int x;
				int y;
				scale1 = m_w / w1;
				scale2 = m_h / h1;
				if( scale1 > scale2 ) scale1 = scale2;
				if( m_duals[cur] )
				{
					if( m_pageno == cur + 1 )
						m_pageno = cur;
					float scale3 = m_w / w2;
					float scale4 = m_w / h2;
					if( scale1 > scale3 ) scale1 = scale3;
					if( scale1 > scale4 ) scale1 = scale4;

					x = (int)((m_w - w1 * scale1) / 2);
					y = (int)((m_h - (h1+h2) * scale1) / 2);
					m_pages[cur].SetRect(x, y, scale1);
					y += m_pages[cur].GetHeight();
					
					cur++;
					if( m_pages[cur] == null ) m_pages[cur] = new PDFVPage(m_doc, cur);
					x = (int)((m_w - w2 * scale1) / 2);
					m_duals[cur] = true;
					m_pages[cur].SetRect(x, y, scale1);
				}
				else
				{
					x = (int)((m_w - w1 * scale1) / 2);
					y = (int)((m_h - h1 * scale1) / 2);
					m_pages[cur].SetRect(x, y, scale1);
				}
			}
		}
		else//landscape
		{
			for( cur = 0; cur < cnt; cur++ )
			{
				if( m_pages[cur] == null ) m_pages[cur] = new PDFVPage(m_doc, cur);
				float w1 = m_doc.GetPageWidth(cur);
				float h1 = m_doc.GetPageHeight(cur);
				float w2 = 0;
				float h2 = 0;
				m_duals[cur] = false;
				if( h1 > w1 && cur < cnt - 1 )
				{
					w2 = m_doc.GetPageWidth(cur + 1);
					h2 = m_doc.GetPageHeight(cur + 1);
					if( h2 > w2 ) m_duals[cur] = true;
				}
				float scale1;
				float scale2;
				int x;
				int y;
				scale1 = m_w / w1;
				scale2 = m_h / h1;
				if( scale1 > scale2 ) scale1 = scale2;
				if( m_duals[cur] )
				{
					if( m_pageno == cur + 1 )
						m_pageno = cur;
					float scale3 = m_w / w2;
					float scale4 = m_w / h2;
					if( scale1 > scale3 ) scale1 = scale3;
					if( scale1 > scale4 ) scale1 = scale4;

					x = (int)((m_w - (w1+w2) * scale1) / 2);
					y = (int)((m_h - h1 * scale1) / 2);
					m_pages[cur].SetRect(x, y, scale1);
					x += m_pages[cur].GetWidth();
					
					cur++;
					if( m_pages[cur] == null ) m_pages[cur] = new PDFVPage(m_doc, cur);
					y = (int)((m_h - h2 * scale1) / 2);
					m_duals[cur] = true;
					m_pages[cur].SetRect(x, y, scale1);
				}
				else
				{
					x = (int)((m_w - w1 * scale1) / 2);
					y = (int)((m_h - h1 * scale1) / 2);
					m_pages[cur].SetRect(x, y, scale1);
				}
			}
		}
    	m_stepx = m_w / 8;
    	m_stepy = 0;
	}
	@Override
	protected int vGetPage( int vx, int vy )
	{
		if( m_doc == null || m_duals == null || m_w <= 0 || m_h <= 0 ) return -1;
		if( m_duals[m_pageno] )
		{
			if( m_h > m_w )
			{
				if( vy >= m_pages[m_pageno + 1].GetY() )
					return m_pageno + 1;
				else
					return m_pageno;
			}
			else
			{
				if( vx >= m_pages[m_pageno + 1].GetX() )
					return m_pageno + 1;
				else
					return m_pageno;
			}
		}
		else
		{
			return m_pageno;
		}
	}
	private int m_hold_style = 0;
	private float m_stepy = 0;
	private float m_stepx = 0;
	private int m_hold_dir = 0;
    @Override
	protected boolean motionNormal(MotionEvent event)
	{
    	if( vGetLock() == 3 ) return true;
		switch(event.getActionMasked())
		{
		case MotionEvent.ACTION_DOWN:
			if( m_status == STA_NONE )
			{
				m_holdx = event.getX();
				m_holdy = event.getY();
    			if( m_holdy > m_h / 2 ) m_hold_style = 1;
    			else m_hold_style = 2;
    			if( m_holdx > m_w / 2 )
    			{
    				if( m_duals[m_pageno] && m_pageno < m_pages.length - 2 )
    					m_status = STA_MOVING;
    				else if( !m_duals[m_pageno] && m_pageno < m_pages.length - 1 )
    					m_status = STA_MOVING;
    				else
    					m_hold_style = 0;
    			}
    			else
    			{
    				if( m_pageno > 0 )
    				{
    					if( m_duals[m_pageno - 1] )
    					{
    						m_pageno -= 2;
    					}
    					else
    					{
    						m_pageno --;
    					}
    					m_status = STA_MOVING;
        				if(m_listener != null)
        					m_listener.OnPDFPageChanged(m_pageno);
    				}
    				else
    					m_hold_style = 0;
    			}
    	    	if( m_listener != null ) m_listener.OnPDFInvalidate(false);
			}
			break;
		case MotionEvent.ACTION_MOVE:
			if( m_status == STA_MOVING )
			{
				m_holdx = event.getX();
				m_holdy = event.getY();
				if( m_listener != null ) m_listener.OnPDFInvalidate(false);
			}
			break;
		case MotionEvent.ACTION_UP:
		case MotionEvent.ACTION_CANCEL:
			if( m_status == STA_MOVING )
			{
				m_holdx = event.getX();
				m_holdy = event.getY();
    			if( m_holdx > m_w / 2 )//previous page
    			{
    				if( m_hold_style == 1 )//right-bottom corner
    					m_stepy = (m_h - m_holdy) / (m_w - m_holdx);
    				else//right-top corner
    					m_stepy = -m_holdy / (m_w - m_holdx);
    				m_hold_dir = 1;
    			}
    			else//next page
    			{
    				if( m_hold_style == 1 )
    				{
    					m_stepy = (m_h - m_holdy) / (m_stepx * 3);
    					if( m_stepy < 0 ) m_stepy = 0;
    				}
    				else
    				{
    					m_stepy = (0 - m_holdy) / (m_stepx * 3);
    					if( m_stepy > 0 ) m_stepy = 0;
    				}
    				m_hold_dir = -1;
    			}
				m_status = STA_CURLING;
				if( m_listener != null ) m_listener.OnPDFInvalidate(false);
			}
			break;
		}
		return true;
	}
    @Override
	protected void vOnTimer(Object obj)
    {
    	if( m_status == STA_MOVING )
    	{
        	if( m_listener != null )
        		m_listener.OnPDFInvalidate(false);
       		return;
    	}
		if( m_status == STA_CURLING && m_hold_dir != 0 )
		{
    		if( m_hold_dir < 0 )//next page
    		{
    			if( m_holdx <= -m_w/2 )
   				{
    				m_status = STA_NONE;
    				if( m_duals[m_pageno] )
    					m_pageno += 2;
    				else
    					m_pageno ++;
    				if(m_listener != null)
    					m_listener.OnPDFPageChanged(m_pageno);
    			}
    			else
    			{
		    		m_holdx -= m_stepx;
		    		m_holdy += m_stepy * m_stepx;
		    		if( m_holdy < 0.0001 ) m_holdy = 0;
		    		if( m_holdy > m_h - 0.0001 ) m_holdy = m_h;
    			}
    		}
    		else//previous page
    		{
	    		m_holdx += m_stepx;
	    		m_holdy += m_stepy * m_stepx;
    			if( m_holdx >= m_w )
    				m_status = STA_NONE;
    		}
        	if( m_listener != null )
        		m_listener.OnPDFInvalidate(false);
		}
		else
		{
	    	if( !m_pages[m_pageno].IsFinished() )
	    	{
	        	if( m_listener != null )
	        		m_listener.OnPDFInvalidate(false);
        		return;
	    	}
	    	if( m_duals[m_pageno] && m_pageno < m_pages.length - 1 && !m_pages[m_pageno + 1].IsFinished() )
	    	{
	        	if( m_listener != null )
	        		m_listener.OnPDFInvalidate(false);
        		return;
	    	}
		}
    }
    @Override
	public void vDraw( Canvas canvas )
	{
		if( m_pages == null ) return;
		int disp_start = -1;
		int disp_end = -1;
		int sel_rect1[] = null;
		int sel_rect2[] = null;
		if( m_status != STA_MOVING && m_status != STA_CURLING )
		{
			int cur = 0;
			while( cur < m_pageno )
			{
				m_thread.end_render(m_pages[cur]);
				cur++;
			}
			m_bmp.eraseColor(m_back);
			disp_start = cur;
			m_draw_bmp.Create(m_bmp);
			m_thread.start_render(m_pages[cur]);
			m_pages[cur].Draw(m_draw_bmp, 0, 0);
			if( sel_rect1 == null || sel_rect2 == null )
			{
				sel_rect1 = m_pages[cur].GetSelRect1(0, 0);
				sel_rect2 = m_pages[cur].GetSelRect2(0, 0);
			}
			if( m_finder.find_get_page() == cur )
				m_finder.find_draw(m_draw_bmp, m_pages[cur], 0, 0);
			cur++;
			if( m_duals[cur - 1] )
			{
				m_thread.start_render(m_pages[cur]);
				m_pages[cur].Draw(m_draw_bmp, 0, 0);
				if( sel_rect1 == null || sel_rect2 == null )
				{
					sel_rect1 = m_pages[cur].GetSelRect1(0, 0);
					sel_rect2 = m_pages[cur].GetSelRect2(0, 0);
				}
				if( m_finder.find_get_page() == cur )
					m_finder.find_draw(m_draw_bmp, m_pages[cur], 0, 0);
				cur++;
			}
			if( Global.g_dark_mode ) m_draw_bmp.Invert();
			m_draw_bmp.Free(m_bmp);
			disp_end = cur;
			int cnt = m_pages.length;
			while( cur < cnt )
			{
				m_thread.end_render(m_pages[cur]);
				cur++;
			}
		}
		else
		{
			int cur = 0;
			while( cur < m_pageno )
			{
				m_thread.end_render(m_pages[cur]);
				cur++;
			}
			disp_start = cur;
			m_dib1.DrawRect(m_back, 0, 0, m_w, m_h, 1);
			m_dib2.DrawRect(m_back, 0, 0, m_w, m_h, 1);
			m_thread.start_render(m_pages[cur]);
			m_pages[cur].DrawDIB(m_dib1, 0, 0);
			if( sel_rect1 == null || sel_rect2 == null )
			{
				sel_rect1 = m_pages[cur].GetSelRect1(0, 0);
				sel_rect2 = m_pages[cur].GetSelRect2(0, 0);
			}
			if( m_finder.find_get_page() == cur )
				m_finder.find_draw_to_dib(m_dib1, m_pages[cur], 0, 0);
			cur++;
			if( m_duals[cur - 1] && cur < m_pages.length )
			{
				m_thread.start_render(m_pages[cur]);
				m_pages[cur].DrawDIB(m_dib1, 0, 0);
				if( sel_rect1 == null || sel_rect2 == null )
				{
					sel_rect1 = m_pages[cur].GetSelRect1(0, 0);
					sel_rect2 = m_pages[cur].GetSelRect2(0, 0);
				}
				if( m_finder.find_get_page() == cur )
					m_finder.find_draw_to_dib(m_dib1, m_pages[cur], 0, 0);
				cur++;
			}
			if( cur < m_pages.length )
			{
				m_thread.start_render(m_pages[cur]);
				m_pages[cur].DrawDIB(m_dib2, 0, 0);
				if( sel_rect1 == null || sel_rect2 == null )
				{
					sel_rect1 = m_pages[cur].GetSelRect1(0, 0);
					sel_rect2 = m_pages[cur].GetSelRect2(0, 0);
				}
				if( m_finder.find_get_page() == cur )
					m_finder.find_draw_to_dib(m_dib2, m_pages[cur], 0, 0);
				cur++;
				if( m_duals[cur - 1] && cur < m_pages.length )
				{
					m_thread.start_render(m_pages[cur]);
					m_pages[cur].DrawDIB(m_dib2, 0, 0);
					if( sel_rect1 == null || sel_rect2 == null )
					{
						sel_rect1 = m_pages[cur].GetSelRect1(0, 0);
						sel_rect2 = m_pages[cur].GetSelRect2(0, 0);
					}
					if( m_finder.find_get_page() == cur )
						m_finder.find_draw_to_dib(m_dib2, m_pages[cur], 0, 0);
					cur++;
				}
				if( Global.g_dark_mode )
					Global.DrawScroll(m_bmp, m_dib1, m_dib2, (int)m_holdx, (int)m_holdy, -m_hold_style, mBackSideClr);
				else
					Global.DrawScroll(m_bmp, m_dib1, m_dib2, (int)m_holdx, (int)m_holdy, m_hold_style, mBackSideClr);
			}
			else
			{
				m_draw_bmp.Create(m_bmp);
				m_dib1.DrawToBmp(m_draw_bmp, 0, 0);
		        if( Global.g_dark_mode ) m_draw_bmp.Invert();
		        m_draw_bmp.Free(m_bmp);
			}
			disp_end = cur;
			int cnt = m_pages.length;
			while( cur < cnt )
			{
				m_thread.end_render(m_pages[cur]);
				cur++;
			}
		}
		canvas.drawBitmap(m_bmp, 0, 0, null);
		if( m_listener != null && disp_start >= 0 )
		{
			if( disp_end < 0 ) disp_end = m_pages.length;
			while( disp_start < disp_end )
			{
				m_listener.OnPDFPageDisplayed(canvas, m_pages[disp_start] );
				disp_start++;
			}
			if( sel_rect1 != null && sel_rect2 != null )
				m_listener.OnPDFSelecting(canvas, sel_rect1, sel_rect2);
		}
	}
    @Override
	public void vSetPos( PDFPos pos, int vx, int vy )
	{
		if( pos == null ) return;
		vGotoPage(pos.pageno);
	}
    @Override
	public void vGotoPage( int pageno )
    {
		if( m_pages == null || pageno < 0 || pageno >= m_pages.length ) return;
		int cur = 0;
		int cnt = pageno;
		while( cur < cnt )
		{
			if( m_duals[cur] )
			{
				if( cur == cnt - 1 ) break;
				cur += 2;
			}
			else cur++;
		}
		m_pageno = cur;
		if( m_listener != null )
		{
			m_listener.OnPDFInvalidate(false);
			m_listener.OnPDFPageChanged(m_pageno);
		}
    }
    @Override
	protected void vFindGoto()
    {
		if( m_pages == null ) return;
		vGotoPage( m_finder.find_get_page() );
    }

    public void setCurlBackSideClr(int color) {
		mBackSideClr = color;
	}
}
