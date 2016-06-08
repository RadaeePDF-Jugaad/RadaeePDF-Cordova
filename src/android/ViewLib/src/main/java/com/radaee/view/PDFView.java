package com.radaee.view;

import com.radaee.pdf.BMP;
import com.radaee.pdf.Document;
import com.radaee.pdf.Global;

import android.content.Context;
import android.graphics.Bitmap;
import android.graphics.Bitmap.Config;
import android.graphics.Canvas;
import android.os.Handler;
import android.os.Looper;
import android.os.Message;
import android.view.GestureDetector;
import android.view.MotionEvent;
import android.widget.Scroller;
@Deprecated
public class PDFView
{
	static final protected int STA_NONE = 0;
	static final protected int STA_MOVING = 1;
	static final protected int STA_ZOOM = 2;
	static final protected int STA_SELECT = 3;
	static final protected int STA_CURLING = 4;
    protected Config m_bmp_format = Config.ARGB_8888;
	protected Document m_doc = null;
	protected Scroller m_scroller = null;
	protected int m_w;
	protected int m_h;
	protected int m_docw;
	protected int m_doch;
	protected int m_lock = 0;
	protected Bitmap m_bmp;
	protected PDFVThread m_thread;
	protected PDFVFinder m_finder;
	protected float m_scale;
	protected float m_scale_min;
	protected float m_scale_max;
	protected int m_page_gap = 4;
	protected PDFVPage[] m_pages = null;
	protected int m_back = 0xFFCCCCCC;
	protected int m_status = STA_NONE;
	protected boolean m_drawbmp = false;
    private GestureDetector m_gesture = null;
    protected PDFViewListener m_listener = null;
    /**
     * call-back listener class
     * @author radaee
     */
    public interface PDFViewListener
    {
    	/**
    	 * fired when page changed.
    	 * @param pageno 0 based pageno.<br/>
    	 */
    	void OnPDFPageChanged(int pageno);
    	/**
    	 * fired when double tapped.
    	 * @param x x coordinate
    	 * @param y y coordinate
    	 * @return true, if process it, or skipped.
    	 */
    	boolean OnPDFDoubleTapped( float x, float y );
    	/**
    	 * fired when single tapped.
    	 * @param x x coordinate
    	 * @param y y coordinate
    	 * @return true, if process it, or skipped.
    	 */
    	boolean OnPDFSingleTapped( float x, float y );
    	/**
    	 * fired when long pressed.
    	 * @param x x coordinate
    	 * @param y y coordinate
    	 */
    	void OnPDFLongPressed( float x, float y );
    	/**
    	 * fired when tapped without moving.
    	 * @param x x coordinate
    	 * @param y y coordinate
    	 */
    	void OnPDFShowPressed( float x, float y );
    	/**
    	 * fired when text selecting end.
    	 */
    	void OnPDFSelectEnd();
    	/**
    	 * fired when searching end.
    	 * @param found true if found, otherwise pass false.
    	 */
    	void OnPDFFound(boolean found);
    	/**
    	 * notify to redraw the view
    	 * @param post whether post invalidate?
    	 */
    	void OnPDFInvalidate(boolean post);
    	/**
    	 * fired when a page displayed.
    	 * @param vpage
    	 */
    	void OnPDFPageDisplayed( Canvas canvas, PDFVPage vpage );
    	/**
    	 * fired when selecting.
    	 * @param canvas Canvas object to draw.
    	 * @param rect1 first char's location, in Canvas coordinate.
    	 * @param rect2 last char's location, in Canvas coordinate.
    	 */
    	void OnPDFSelecting( Canvas canvas, int[] rect1, int[] rect2 );
        void OnPDFZoomStart();
        void OnPDFZoomEnd();
		void OnPDFPageRendered(int pageno);
    }
    public static class PDFPos
    {
    	public int pageno;
    	public float x;
    	public float y;
    }
	protected Handler m_hand_ui = new Handler(Looper.getMainLooper())
	{
    	@Override
    	public void handleMessage(Message msg)
    	{
			switch( msg.what )//render finished.
			{
			case 0:
				if( m_listener != null ) {
					m_listener.OnPDFInvalidate(false);
					m_listener.OnPDFPageRendered(((PDFVCache)msg.obj).m_pageno);
				}
				break;
			case 1://find operation returned.
        		{
        			if( msg.arg1 == 1 )//succeeded
        			{
        				PDFView.this.vFindGoto();
        				if( m_listener != null )
        					m_listener.OnPDFFound( true );
        			}
        			else
        			{
        				if( m_listener != null )
        					m_listener.OnPDFFound( false );
        			}
        		}
        		break;
			case 100://timer
				if( m_scroller.isFinished() && m_pages != null && m_status != STA_ZOOM )
					vOnTimer(msg.obj);
				break;
			}
			super.handleMessage(msg);
    	}
	};
	protected void vOnTimer(Object obj)
	{
		int cur = m_prange_start;
		int cnt = m_prange_end;
		if( m_drawbmp )
		{
			while( cur < cnt )
			{
				if( m_pages[cur].NeedBmp() )
					break;
				cur++;
			}
			if( cur >= cnt )
			{
				m_drawbmp = false;
				cur = 0;
				while( cur < cnt )
				{
					m_pages[cur].DeleteBmp();
					cur++;
				}
				if( m_listener != null ) m_listener.OnPDFInvalidate(false);
			}
		}
		else
		{
			while( cur < cnt )
			{
				if( !m_pages[cur].IsFinished() )
				{
					if( m_listener != null ) m_listener.OnPDFInvalidate(false);
					break;
				}
				cur++;
			}
		}
	}
	private final Context m_ctx;
	public PDFView(Context context)
	{
		m_ctx = context;
		m_scroller = new Scroller(context);
    	m_gesture = new GestureDetector( context, new PDFGestureListener() );
	}
	public void vSetBackColor( int color )
	{
		m_back = color;
		if( m_listener != null ) m_listener.OnPDFInvalidate(false);
	}
	public void vSetPageGap( int gap )
	{
		m_page_gap = gap;
		PDFPos pos = vGetPos(0, 0);
		vLayout();
		vSetPos(pos,0, 0);
		if( m_listener != null ) m_listener.OnPDFInvalidate(false);
	}
	public void vResize(int w, int h)
	{
		if( w == 0 || h == 0 || m_lock == 4 ) return;
		if( m_bmp != null ) m_bmp.recycle();
		m_bmp = Bitmap.createBitmap(w, h, m_bmp_format);
		m_w = w;
		m_h = h;
		vLayout();
		if( m_listener != null )
		{
			m_listener.OnPDFInvalidate(false);
		}
	}
	public boolean vMovingFinished()
	{
		return m_status == STA_NONE && m_scroller.isFinished();
	}
	public void vComputeScroll()
	{  
		if( m_scroller.computeScrollOffset() )
		{
			if( m_listener != null ) m_listener.OnPDFInvalidate(true);
		}
	}
	protected int m_prange_start = 0;//to avoid allocate
	protected int m_prange_end = 0;//to avoid allocate
	protected int m_pageno = -1;
	protected void vFlushRange()
	{
		if( m_status == STA_ZOOM ) return;
		int pageno1 = vGetPage(0,0);
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
			if( m_prange_start < pageno1 )
			{
				int start = m_prange_start;
				int end = pageno1;
				if( end > m_prange_end ) end = m_prange_end;
				while( start < end )
				{
					PDFVPage vpage = m_pages[start];
					m_thread.end_render(vpage);
					vpage.DeleteBmp();
					start++;
				}
			}
			if( m_prange_end > pageno2 )
			{
				int start = pageno2;
				int end = m_prange_end;
				if( start < m_prange_start ) start = m_prange_start;
				while( start < end )
				{
					PDFVPage vpage = m_pages[start];
					m_thread.end_render(vpage);
					vpage.DeleteBmp();
					start++;
				}
			}
		}
		else
		{
			int start = m_prange_start;
			int end = m_prange_end;
			while( start < end )
			{
				PDFVPage vpage = m_pages[start];
				m_thread.end_render(vpage);
				vpage.DeleteBmp();
				start++;
			}
		}
		m_prange_start = pageno1;
		m_prange_end = pageno2;
		pageno1 = vGetPage(m_w/4,m_h/4);
		if( m_listener != null && pageno1 != m_pageno )
		{
			m_listener.OnPDFPageChanged(m_pageno = pageno1);
		}	
	}
	protected BMP m_draw_bmp = new BMP();
	public void vDraw( Canvas canvas )
	{
		if( m_pages == null ) return;
		//long rec_time = System.currentTimeMillis();
		int left = m_scroller.getCurrX();
		int top = m_scroller.getCurrY();
		int left1 = left;
		int top1 = top;
		if( left1 > m_docw - m_w ) left1 = m_docw - m_w;
		if( left1 < 0 ) left1 = 0;
		if( top1 > m_doch - m_h ) top1 = m_doch - m_h;
		if( top1 < 0 ) top1 = 0;
		if(  left1 != left )
		{
			vSetX(left1);
			left = left1;
		}
		if( top1 != top )
		{
			vSetY(top1);
			top = top1;
		}
		vFlushRange();
		int cur = m_prange_start;
		int end = m_prange_end;
		int[] sel_rect1 = null;
		int[] sel_rect2 = null;
		if( m_drawbmp )
		{
			if( Global.g_dark_mode )
			{
				m_bmp.eraseColor(m_back);
				Canvas bcan = new Canvas(m_bmp);
				while( cur < end )
				{
					PDFVPage vpage = m_pages[cur];
					if( m_status != STA_ZOOM ) m_thread.start_render(vpage);
					vpage.Draw(bcan, left, top);
					if( sel_rect1 == null || sel_rect2 == null )
					{
						sel_rect1 = vpage.GetSelRect1(left, top);
						sel_rect2 = vpage.GetSelRect2(left, top);
					}
					if( m_finder.find_get_page() == cur )
						m_finder.find_draw(bcan, vpage, left, top);
					cur++;
				}
				m_draw_bmp.Create(m_bmp);
				m_draw_bmp.Invert();
				m_draw_bmp.Free(m_bmp);
				//Log.i("time_d1", String.valueOf(System.currentTimeMillis() - rec_time));
				canvas.drawBitmap(m_bmp, 0, 0, null);
				//Log.i("time_d2", String.valueOf(System.currentTimeMillis() - rec_time));
			}
			else
			{
				canvas.drawColor(m_back);
				while( cur < end )
				{
					PDFVPage vpage = m_pages[cur];
					if( m_status != STA_ZOOM ) m_thread.start_render(vpage);
					if( sel_rect1 == null || sel_rect2 == null )
					{
						sel_rect1 = vpage.GetSelRect1(left, top);
						sel_rect2 = vpage.GetSelRect2(left, top);
					}
					vpage.Draw(canvas, left, top);
					if( m_finder.find_get_page() == cur )
						m_finder.find_draw(canvas, vpage, left, top);
					cur++;
				}
			}
		}
		else
		{
			m_bmp.eraseColor(m_back);
			//Log.i("time_d0", String.valueOf(System.currentTimeMillis() - rec_time));
			m_draw_bmp.Create(m_bmp);
			while( cur < end )
			{
				PDFVPage vpage = m_pages[cur];
				m_thread.start_render(vpage);
				if( sel_rect1 == null || sel_rect2 == null )
				{
					sel_rect1 = vpage.GetSelRect1(left, top);
					sel_rect2 = vpage.GetSelRect2(left, top);
				}
				vpage.Draw(m_draw_bmp, left, top);
				if( m_finder.find_get_page() == cur )
					m_finder.find_draw(m_draw_bmp, vpage, left, top);
				cur++;
			}
			if( Global.g_dark_mode ) {
				m_draw_bmp.Invert();
			}
			m_draw_bmp.Free(m_bmp);
			//Log.i("time_d1", String.valueOf(System.currentTimeMillis() - rec_time));
			canvas.drawBitmap(m_bmp, 0, 0, null);
			//Log.i("time_d2", String.valueOf(System.currentTimeMillis() - rec_time));
		}
		if( m_listener != null )
		{
			cur = m_prange_start;
			end = m_prange_end;
			while( cur < end )
			{
				m_listener.OnPDFPageDisplayed(canvas, m_pages[cur] );
				cur++;
			}
			if( sel_rect1 != null && sel_rect2 != null )
				m_listener.OnPDFSelecting(canvas, sel_rect1, sel_rect2);
		}
		//Log.i("time_draw", String.valueOf(System.currentTimeMillis() - rec_time));
	}
	public void vOpen(Document doc, int page_gap, int back_color, PDFViewListener listener)
	{
		vClose();
		m_doc = doc;
		m_thread = new PDFVThread(m_hand_ui);
		m_thread.start();
		m_page_gap = page_gap;
		m_back = back_color;
		m_finder = new PDFVFinder();
		m_listener = listener;
		vLayout();
		if( m_listener != null ) m_listener.OnPDFInvalidate(false);
	}
    public void vSetBmpFormat(Config format)
    {
        if(m_bmp_format == format || format == Config.ALPHA_8) return;
        m_bmp_format = format;
        if(m_bmp != null)
        {
            m_bmp.recycle();
            m_bmp = Bitmap.createBitmap(m_w, m_h, format);
            m_listener.OnPDFInvalidate(false);
        }
    }
	public void vClose()
	{
		if( m_finder != null )
		{
			m_finder.find_end();
			m_finder = null;
		}
		if( m_pages != null )
		{
			int cur = 0;
			int cnt = m_pages.length;
			while( cur < cnt )
			{
				if( m_pages[cur] != null )
				{
					m_thread.end_render(m_pages[cur]);
				}
				cur++;
			}
			m_pages = null;
		}
		if( m_thread != null )
		{
			m_thread.destroy();
			m_thread = null;
		}
		if( m_bmp != null )
		{
			m_bmp.recycle();
			m_bmp = null;
		}
		vSetX(0);
		vSetY(0);
		m_scroller.computeScrollOffset();
		m_prange_start = 0;
		m_prange_end = 0;
		m_pageno = -1;
		m_drawbmp = false;
	}
	protected float m_holdx;
	protected float m_holdy;
	protected float m_holdsx;
	protected float m_holdsy;
	private float m_movex;
	private float m_movey;
	private float m_zoom_dis1;
	private float m_zoom_dis2;
	private float m_zoom_scale;
	private PDFPos m_zoom_pos;
    class PDFGestureListener extends GestureDetector.SimpleOnGestureListener
    {
        @Override
        public boolean onFling(MotionEvent e1, MotionEvent e2, float velocityX, float velocityY)
        {
        	if( m_status != STA_MOVING || m_lock == 3 ) return false;
        	float dx = e2.getX() - e1.getX();
        	float dy = e2.getY() - e1.getY();
			if( m_lock == 1 ) {velocityX = 0; dx = 0;}
			if( m_lock == 2 ) {velocityY = 0; dy = 0;}
        	if( vOnFling( dx, dy, velocityX, velocityY ) )
        	{
        		m_status = STA_NONE;
        		if( m_listener != null ) m_listener.OnPDFInvalidate(false);
        		return true;
        	}
        	else
        		return false;
        }
        @Override
        public boolean onDoubleTap(MotionEvent e)
        {
   			return false;
        }
        @Override
        public boolean onDoubleTapEvent(MotionEvent e)
        {
    		if( m_listener != null && m_status == STA_MOVING )
    		{
    			if( m_listener.OnPDFDoubleTapped(e.getX(), e.getY()) )
    			{
    				m_status = STA_NONE;
    				return true;
    			}
    			else return false;
    		}
    		else
    			return false;
        }
        @Override
        public boolean onDown(MotionEvent e)
        {
        	return false;
        }
        @Override
        public void onLongPress(MotionEvent e)
        {
    		if( m_listener != null )
    			m_listener.OnPDFLongPressed(e.getX(), e.getY());
        }
        @Override
        public boolean onScroll(MotionEvent e1, MotionEvent e2, float distanceX, float distanceY)
        {
        	return false;
        }
        @Override
        public void onShowPress(MotionEvent e)
        {
    		if( m_listener != null )
    			m_listener.OnPDFShowPressed(e.getX(), e.getY());
        }
        @Override
        public boolean onSingleTapConfirmed(MotionEvent e)
        {
        	return true;
        }
        @Override
        public boolean onSingleTapUp(MotionEvent e)
        {
			boolean ret = vSingleTap( e.getX(), e.getY() );
			if( m_listener != null && m_status == STA_MOVING )
			{
				if( m_listener.OnPDFSingleTapped(e.getX(), e.getY()) )
				{
					m_status = STA_NONE;
					return true;
				}
				else
				{
					if (ret) m_status = STA_NONE;
					return ret;
				}
			}
			else
				return ret;
        }
    }
    protected boolean vSingleTap( float x, float y ){ return false; }
    private boolean motionZoom(MotionEvent event)
    {
		switch(event.getActionMasked())
		{
		case MotionEvent.ACTION_MOVE:
			if( m_status == STA_ZOOM )
			{
				float dx = event.getX(0) - event.getX(1);
				float dy = event.getY(0) - event.getY(1);
				m_zoom_dis2 = Global.sqrtf(dx * dx + dy * dy);
				float scale = m_zoom_scale * m_zoom_dis2 / m_zoom_dis1;
				if( m_scale/scale > 1.0001 || m_scale/scale < 0.999 )
				{
					m_scale = scale;
					vLayout();
					vSetPos( m_zoom_pos, (int)m_holdx, (int)m_holdy );
				}
			}
			break;
		case MotionEvent.ACTION_UP:
		case MotionEvent.ACTION_POINTER_UP:
		case MotionEvent.ACTION_CANCEL:
			if( m_status == STA_ZOOM )
			{
				m_status = STA_NONE;
				float dx = event.getX(0) - event.getX(1);
				float dy = event.getY(0) - event.getY(1);
				m_zoom_dis2 = Global.sqrtf(dx * dx + dy * dy);
				float scale = m_zoom_scale * m_zoom_dis2 / m_zoom_dis1;
				if( m_scale/scale > 1.0001 || m_scale/scale < 0.999 )
				{
					m_scale = scale;
					vLayout();
					vSetPos( m_zoom_pos, (int)m_holdx, (int)m_holdy );
				}
				if( m_listener != null )
                {
                    m_listener.OnPDFInvalidate(false);
                    m_listener.OnPDFZoomEnd();
                }
				vOnZoomEnd();
			}
			break;
		}
    	return true;
    }
	protected boolean motionNormal(MotionEvent event)
	{
		if( m_gesture.onTouchEvent(event) ) return true;
		switch(event.getActionMasked())
		{
		case MotionEvent.ACTION_DOWN:
			if( m_status == STA_NONE )
			{
				Scroller scroller = new Scroller(m_ctx);
				m_scroller.computeScrollOffset();
				m_holdsx = m_scroller.getCurrX();
				m_holdsy = m_scroller.getCurrY();
				m_holdx = event.getX();
				m_holdy = event.getY();
				scroller.setFinalX((int)m_holdsx);
				scroller.setFinalY((int)m_holdsy);
				scroller.computeScrollOffset();
				m_scroller = scroller;
				m_status = STA_MOVING;
			}
			break;
		case MotionEvent.ACTION_MOVE:
			if( m_status == STA_MOVING )
			{
				m_movex = event.getX();
				m_movey = event.getY();
				int x = (int)(m_holdsx + m_holdx - m_movex);
				int y = (int)(m_holdsy + m_holdy - m_movey);
				if( m_lock == 1 || m_lock == 3 ) x = (int)m_holdsx;
				if( m_lock == 2 || m_lock == 3 ) y = (int)m_holdsy;
				vSetX(x);
				vSetY(y);
				if( m_listener != null ) m_listener.OnPDFInvalidate(false);
			}
			break;
		case MotionEvent.ACTION_UP:
		case MotionEvent.ACTION_CANCEL:
			if( m_status == STA_MOVING )
			{
				m_movex = event.getX();
				m_movey = event.getY();
				int x = (int)(m_holdsx + m_holdx - m_movex);
				int y = (int)(m_holdsy + m_holdy - m_movey);
				if( m_lock == 1 || m_lock == 3 ) x = (int)m_holdsx;
				if( m_lock == 2 || m_lock == 3 ) y = (int)m_holdsy;
				vSetX(x);
				vSetY(y);
				m_status = STA_NONE;
				vOnMoveEnd(x, y);
				if( m_listener != null ) m_listener.OnPDFInvalidate(false);
			}
			break;
		case MotionEvent.ACTION_POINTER_DOWN:
			if( event.getPointerCount() == 2 && m_status == STA_MOVING && m_lock != 5 )
			{
				m_scroller.forceFinished(true);
	        	m_scroller.abortAnimation();
				m_holdx = (event.getX(0) + event.getX(1))/2;
				m_holdy = (event.getY(0) + event.getY(1))/2;
				float dx = event.getX(0) - event.getX(1);
				float dy = event.getY(0) - event.getY(1);
				m_zoom_pos = vGetPos( (int)m_holdx, (int)m_holdy );
				m_zoom_dis1 = Global.sqrtf(dx * dx + dy * dy);
				m_zoom_dis2 = m_zoom_dis1;
				m_zoom_scale = m_scale;
				int cur = m_prange_start;
				int cnt = m_prange_end;
				while( cur < cnt )
				{
					m_pages[cur].CreateBmp(m_bmp_format);
					m_thread.end_render(m_pages[cur]);
					cur++;
				}
				m_drawbmp = true;
				m_status = STA_ZOOM;
                if(m_listener != null)
                    m_listener.OnPDFZoomStart();
			}
			break;
		}
		return true;
	}
	private boolean motionSelect(MotionEvent event)
	{
		switch(event.getActionMasked())
		{
		case MotionEvent.ACTION_DOWN:
			m_holdx = event.getX();
			m_holdy = event.getY();
			vClearSel();
			break;
		case MotionEvent.ACTION_MOVE:
			m_movex = event.getX();
			m_movey = event.getY();
			vSetSel( m_holdx, m_holdy, m_movex, m_movey );
			break;
		case MotionEvent.ACTION_UP:
		case MotionEvent.ACTION_CANCEL:
			m_movex = event.getX();
			m_movey = event.getY();
			vSetSel( m_holdx, m_holdy, m_movex, m_movey );
			if( m_listener != null ) m_listener.OnPDFSelectEnd();
			break;
		}
		return true;
	}
	public boolean vTouchEvent(MotionEvent event)
	{
		if( m_status == STA_NONE || m_status == STA_MOVING )
			return motionNormal(event);
		if( m_status == STA_ZOOM && m_lock != 5 )
			return motionZoom(event);
		if( m_status == STA_SELECT )
			return motionSelect(event);
		return true;
	}
	/**
	 * implement by derived class.
	 */
	protected void vLayout()
	{
	}
	/**
	 * implement by derived class.
	 */
	public PDFVPage vGetPage( int pageno )
	{
		if( m_pages == null ) return null;
		if( pageno < 0 || pageno >= m_pages.length ) return null;
		return m_pages[pageno];
	}
	protected int vGetPage( int vx, int vy )
	{
		return 0;
	}
	/**
	 * get Position from point in view coordinate, implement in derived class.<br/>
	 * pass (0,0) to get position of left-top corner 
	 * @param vx x in view coordinate
	 * @param vy y in view coordinate
	 * @return position in PDF coordinate.
	 */
	public PDFPos vGetPos( int vx, int vy )
	{
		if( m_pages == null || m_pages.length <= 0 ) return null;
		int pageno = vGetPage( vx, vy );
		if( pageno < 0 ) return null;
		PDFPos pos = new PDFPos();
		pos.pageno = pageno;
		pos.x = m_pages[pageno].ToPDFX(vx, m_scroller.getCurrX());
		pos.y = m_pages[pageno].ToPDFY(vy, m_scroller.getCurrY());
		return pos;
	}
	/**
	 * set Position to point in view coordinate, implement in derived class.<br/>
	 * pass (0,0) to set position to left-top corner. 
	 * @param pos position in PDF coordinate.
	 * @param vx x in view coordinate
	 * @param vy y in view coordinate
	 */
	public void vSetPos( PDFPos pos, int vx, int vy )
	{
		if( pos == null || m_pages == null || pos.pageno < 0 || pos.pageno >= m_pages.length ) return;
		float x = m_pages[pos.pageno].GetX() + pos.x * m_scale - vx;
		float y = m_pages[pos.pageno].GetY() + ((m_doc.GetPageHeight(pos.pageno) - pos.y) * m_scale) - vy;
		m_scroller.forceFinished(true);
    	m_scroller.abortAnimation();
		vSetX((int) x);
		vSetY((int) y);
		m_scroller.computeScrollOffset();
		if( m_listener != null ) m_listener.OnPDFInvalidate(false);
	}
	public void vGotoPage( int pageno )
	{
		if( m_pages == null || pageno < 0 || pageno >= m_pages.length ) return;
		float x = m_pages[pageno].GetX();
		float y = m_pages[pageno].GetY();
		m_scroller.forceFinished(true);
    	m_scroller.abortAnimation();
		vSetX((int)x);
		vSetY((int) y);
		m_scroller.computeScrollOffset();
		if( m_listener != null ) m_listener.OnPDFInvalidate(false);
	}
	protected boolean vOnFling( float dx, float dy, float velocityX, float velocityY )
	{
		if( m_pages == null || m_lock == 3 ) return false;
		int ivx = (int)(-velocityX * Global.fling_dis / 2);
		int ivy = (int)(-velocityY * Global.fling_dis / 2);
		m_scroller.fling((int)m_scroller.getCurrX(), (int)m_scroller.getCurrY(), ivx, ivy, 0, m_docw - m_w, 0, m_doch - m_h);
		return true;
	}
	protected void vOnMoveEnd( int x, int y )
	{
	}
	protected void vOnZoomEnd()
	{
	}
	/**
	 * zoom operations
	 * @param scale absolute scale value apply to View
	 * @param fx fixed point
	 * @param fy fixed point
	 */
	public void vSetScale( float scale, float fx, float fy )
	{
		if( m_pages == null ) return;
		PDFPos pos = vGetPos((int)fx, (int)fy);
		int cur = 0;
		int cnt = m_pages.length;
		while( cur < cnt )
		{
			m_pages[cur].CreateBmp(m_bmp_format);
			m_thread.end_render(m_pages[cur]);
			cur++;
		}
		m_drawbmp = true;
		m_scale = scale;
		vLayout();
		vSetPos( pos, (int)fx, (int)fy );
		if( m_listener != null ) m_listener.OnPDFInvalidate(false);
	}
	/**
	 * get absolute scale value between [vGetMinScale, vGetMaxScale]
	 * @return scale value
	 */
	public float vGetScale()
	{
		return m_scale;
	}
	public float vGetMinScale()
	{
		return m_scale_min;
	}
	public float vGetMaxScale()
	{
		return m_scale_max;
	}
	public void vRenderSync( PDFVPage page )
	{
		if( m_pages == null || page == null ) return;
		m_thread.end_render(page);
		page.RenderPrepare();
		page.m_cache.Render();
		if( m_listener != null )
			m_listener.OnPDFInvalidate(false);
	}
	/**
	 * render page again, after page modified.
	 * @param page page object obtained by vGetPage()
	 */
	public void vRenderAsync( PDFVPage page )
	{
		if( m_pages == null || page == null ) return;
		/*
		int cur = 0;
		int cnt = m_pages.length;
		while( cur < cnt )
		{
			m_pages[cur].CreateBmp();
			m_thread.end_render(m_pages[cur]);
			cur++;
		}
		m_drawbmp = true;
		*/
		m_thread.end_render(page);
		m_thread.start_render(page);
	}
	/**
	 * set locks
	 * @param lock 0: non-lock.<br/>
	 * 1: lock horizontal moving.<br/>
	 * 2: lock vertical moving.<br/>
	 * 3: lock moving.<br/>
	 * 4: lock resize.<br/>
	 * 5: lock zooming.<br/>
	 */
	public void vSetLock( int lock )
	{
		m_lock = lock;
	}
	/**
	 * return lock status.
	 * @return 0: non-lock.<br/>
	 * 1: lock horizontal moving.<br/>
	 * 2: lock vertical moving.<br/>
	 * 3: lock moving.<br/>
	 * 4: lock resize.<br/>
	 * 5: lock zooming.<br/>
	 */
	public int vGetLock()
	{
		return m_lock;
	}
	public void vSetSel( float x1, float y1, float x2, float y2 )
	{
		if( m_pages == null ) return;
		int pcur = 0;
		int pcnt = m_pages.length;
		while( pcur < pcnt )
		{
			m_pages[pcur].ClearSel();
			pcur++;
		}
		PDFPos pos = vGetPos( (int)x1, (int)y1 );
		PDFVPage vpage = m_pages[pos.pageno];
		vpage.SetSel(x1, y1, x2, y2, m_scroller.getCurrX(), m_scroller.getCurrY());
		if( m_listener != null ) m_listener.OnPDFInvalidate(false);
	}
	public String vGetSel()
	{
		if( m_pages == null ) return null;
		int pcur = 0;
		int pcnt = m_pages.length;
		while( pcur < pcnt )
		{
			String val = m_pages[pcur].GetSel();
			if( val != null ) return val;
			pcur++;
		}
		return null;
	}
	public void vClearSel()
	{
		if( m_pages == null ) return;
		int pcur = 0;
		int pcnt = m_pages.length;
		while( pcur < pcnt )
		{
			m_pages[pcur].ClearSel();
			pcur++;
		}
		if( m_listener != null ) m_listener.OnPDFInvalidate(false);
	}
	public void vSetSelStatus(boolean set)
	{
		if( set )
			m_status = STA_SELECT;
		else
			m_status = STA_NONE;
	}
	/**
	 * set current selected text as text-markup annotation.
	 * @param type 0:highlight 1:underline 2:strikeout
	 * @return true or false
	 */
	public boolean vSetSelMarkup(int type)
	{
		if( m_pages == null ) return false;
		int pcur = 0;
		int pcnt = m_pages.length;
		while( pcur < pcnt )
		{
			if( m_pages[pcur].SetSelMarkup(type) )
			{
				vRenderSync(m_pages[pcur]);
				return true;
			}
			pcur++;
		}
		return false;
	}
	public void vFindStart( String key, boolean match_case, boolean whole_word )
	{
		if( m_pages == null ) return;
		int pageno = vGetPage(0,0);
		m_finder.find_end();
		m_finder.find_start(m_doc, pageno, key, match_case, whole_word);
	}
	protected void vFindGoto()
	{
		if( m_pages == null ) return;
		int pg = m_finder.find_get_page();
    	if( pg < 0 || pg >= m_doc.GetPageCount() ) return;
		float[] pos = m_finder.find_get_pos();
		if( pos == null ) return;
		pos[0] = m_pages[pg].ToDIBX(pos[0]) + m_pages[pg].GetX();
		pos[1] = m_pages[pg].ToDIBY(pos[1]) + m_pages[pg].GetY();
		pos[2] = m_pages[pg].ToDIBX(pos[2]) + m_pages[pg].GetX();
		pos[3] = m_pages[pg].ToDIBY(pos[3]) + m_pages[pg].GetY();
		m_scroller.computeScrollOffset();
		float x = m_scroller.getCurrX();
		float y = m_scroller.getCurrY();
		if( x > pos[0] - m_w/8 ) x = pos[0] - m_w/8;
		if( x < pos[2] - m_w*7/8 ) x = pos[2] - m_w*7/8;
		if( y > pos[1] - m_h/8 ) y = pos[1] - m_h/8;
		if( y < pos[3] - m_h*7/8 ) y = pos[3] - m_h*7/8;
		m_scroller.forceFinished(true);
    	m_scroller.abortAnimation();
		vSetX((int) x);
		vSetY((int) y);
		m_scroller.computeScrollOffset();
		if( m_listener != null ) m_listener.OnPDFInvalidate(false);
	}
	public int vFind(int dir)
	{
		if( m_pages == null ) return -1;
		int ret = m_finder.find_prepare(dir);
		if( ret == 1 )
		{
			if( m_listener != null )
				m_listener.OnPDFFound( true );
			vFindGoto();
			return 0;//succeeded
		}
		if( ret == 0 )
		{
			if( m_listener != null )
				m_listener.OnPDFFound( false );
			return -1;//failed
		}
		m_thread.start_find( m_finder );//need thread operation.
		return 1;
	}
	public void vFindEnd()
	{
		if( m_pages == null ) return;
		m_finder.find_end();
	}
	/**
	 * scroll and center the page.
	 * @param pageno
	 */
	public void vCenterPage( int pageno )
	{
		if( m_pages == null || m_doc == null || m_w <= 0 || m_h <= 0 ) return;
		m_scroller.forceFinished(true);
    	m_scroller.abortAnimation();
		int left = m_pages[pageno].m_x - m_page_gap/2;
		int top = m_pages[pageno].m_y - m_page_gap/2;
		int w = m_pages[pageno].m_w + m_page_gap;
		int h = m_pages[pageno].m_h + m_page_gap;
		int x = left + (w - m_w)/2;
		int y = top + (h - m_h)/2;
		int oldx = m_scroller.getCurrX();
		int oldy = m_scroller.getCurrY();
		m_scroller.startScroll(oldx, oldy, x - oldx, y - oldy);
	}
	public final int vGetX()
	{
		return m_scroller.getCurrX();
	}
	public final int vGetY()
	{
		return m_scroller.getCurrY();
	}
	public final int vGetWinW()
	{
		return m_w;
	}
	public final int vGetWinH()
	{
		return m_h;
	}
	public final int vGetDocW()
	{
		return m_docw;
	}
	public final int vGetDocH()
	{
		return m_doch;
	}
    @Override
    protected void finalize() throws Throwable
    {
        vClose();
        super.finalize();
    }

	public void vSetX(int x) {
		if( x > m_docw - m_w ) x = m_docw - m_w;
		if( x < 0 ) x = 0;
		m_scroller.setFinalX(x);
	}

	public void vSetY(int y) {
		if( y > m_doch - m_h ) y = m_doch - m_h;
		if( y < 0 ) y = 0;
		m_scroller.setFinalY(y);
	}
}
