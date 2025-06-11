package com.radaee.view;

import com.radaee.pdf.Document;
import com.radaee.pdf.Global;

import android.content.Context;
import android.graphics.Canvas;
import android.graphics.Paint;
import android.graphics.Path;

public class PDFViewReflow extends PDFView
{
	private int m_pageno = 0;
	private Paint m_paint = new Paint();
	static private int BUTTON_SIZE = 60;
	public PDFViewReflow(Context context)
	{
		super(context);
		m_paint.setARGB(96, 128, 128, 128);
	}
	@Override
	public void vOpen(Document doc, int page_gap, int back_color, PDFViewListener listener)
	{
		super.vOpen(doc, page_gap, back_color, listener);
		m_pageno = 0;
		m_scale = 2;
		m_scale_min = 2;
		m_scale_max = 4;
	}
	@Override
	public void vClose()
	{
		super.vClose();
		m_pageno = 0;
	}
	@Override
	protected void vLayout()
	{
		if( m_doc == null || m_w <= m_page_gap || m_h <= m_page_gap ) return;
		if( m_scale < m_scale_min ) m_scale = m_scale_min;
		if( m_scale > m_scale_max ) m_scale = m_scale_max;
		if( m_pages == null )
		{
			int cnt = m_doc.GetPageCount();
			m_pages = new PDFVPage[cnt];
			int cur = 0;
			for( cur = 0; cur < cnt; cur++ )
			{
				m_pages[cur] = new PDFVPage(m_doc, cur);
			}
		}
		if( m_bmp != null ) m_bmp.recycle();
		m_bmp = m_pages[m_pageno].Reflow(m_w - m_page_gap, m_scale, true);
		if( m_bmp != null )
		{
			m_docw = m_bmp.getWidth();
			m_doch = m_bmp.getHeight();
			if( m_dark )
			{
				m_draw_bmp.Create(m_bmp);
				m_draw_bmp.Invert();
				m_draw_bmp.Free(m_bmp);
			}
		}
		else
		{
			m_docw = 0;
			m_doch = 0;
		}
		m_scroller.forceFinished(true);
		m_scroller.setFinalX(0);
		m_scroller.setFinalY(0);
		m_scroller.computeScrollOffset();
	}
	@Override
	protected int vGetPage( int vx, int vy )
	{
		return m_pageno;
	}
	@Override
	public PDFPos vGetPos( int vx, int vy )
	{
		if( m_doc == null || m_w <= 0 || m_h <= 0 ) return null;
		PDFPos m_pos = new PDFPos();
		m_pos.pageno = m_pageno;
		m_pos.x = 0;
		m_pos.y = m_doc.GetPageHeight(m_pageno);
		return m_pos;
	}
	boolean m_dark = false;
    @Override
	public void vDraw( Canvas canvas )
	{
		if( m_dark )
	    	canvas.drawColor(m_back^0xFFFFFF);
		else
			canvas.drawColor(m_back);
    	if( m_bmp != null )
    	{
    		if( m_dark != Global.g_dark_mode )
    		{
    			m_dark = Global.g_dark_mode;
    			m_draw_bmp.Create(m_bmp);
    			m_draw_bmp.Invert();
    			m_draw_bmp.Free(m_bmp);
    		}
    		canvas.drawBitmap(m_bmp, m_page_gap / 2 - m_scroller.getCurrX(), m_page_gap / 2  - m_scroller.getCurrY(), null);
    	}

		Path path = new Path();
		path.moveTo(4, m_h/2);
		path.lineTo(BUTTON_SIZE + 4, m_h/2 - BUTTON_SIZE);
		path.lineTo(BUTTON_SIZE + 4, m_h/2 + BUTTON_SIZE);
		path.close();
		canvas.drawPath(path, m_paint);
		path.reset();
		path.moveTo(m_w - 4, m_h/2);
		path.lineTo(m_w - BUTTON_SIZE - 4, m_h/2 - BUTTON_SIZE);
		path.lineTo(m_w - BUTTON_SIZE - 4, m_h/2 + BUTTON_SIZE);
		path.close();
		canvas.drawPath(path, m_paint);
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
    	if( m_doc == null || pageno < 0 || pageno >= m_doc.GetPageCount() ) return;
		if( m_pageno == pageno ) return;
    	m_pageno = pageno;
    	vLayout();
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
    @Override
    protected boolean vSingleTap( float x, float y )
    {
		if( x > 4 && x < BUTTON_SIZE + 4 && y > m_h/2 - BUTTON_SIZE && y < m_h/2 + BUTTON_SIZE )
		{
    		m_status = STA_NONE;
			vGotoPage(m_pageno - 1);
			return true;
		}
		if( x < m_w - 4 && x > m_w - BUTTON_SIZE - 4 && y > m_h/2 - BUTTON_SIZE && y < m_h/2 + BUTTON_SIZE )
		{
    		m_status = STA_NONE;
			vGotoPage(m_pageno + 1);
			return true;
		}
		return false;
    }
    @Override
	protected boolean vOnFling( float dx, float dy, float velocityX, float velocityY )
	{
		float ddx = dx;
		float ddy = dy;
		if( ddx < 0 ) ddx = -ddx;
		if( ddy < 0 ) ddy = -ddy;
		if( ddx < ddy ) return false;
		
		if( dx < 0 )
			vGotoPage(m_pageno + 1);
		else
			vGotoPage(m_pageno - 1);
		return true;
	}
}
