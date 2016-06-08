package com.radaee.view;

import android.app.ActivityManager;
import android.content.Context;
import android.graphics.Bitmap;
import android.graphics.Canvas;
import android.graphics.Paint;
import android.util.AttributeSet;
import android.view.GestureDetector;
import android.view.MotionEvent;
import android.view.View;
import android.widget.Scroller;

import com.radaee.pdf.BMP;
import com.radaee.pdf.Document;
import com.radaee.pdf.Global;

/**
 * Created by radaee on 2015/3/13.
 */
public class PDFPageView extends View
{
    static final protected int STA_NONE = 0;
    static final protected int STA_ZOOM = 1;
    //static final protected int STA_SELECT = 2;
    //static final protected int STA_INK = 3;
    //static final protected int STA_RECT = 4;
    //static final protected int STA_ELLIPSE = 5;
    //static final protected int STA_NOTE = 6;
    //static final protected int STA_LINE = 7;
    //static final protected int STA_STAMP = 8;
    //static final protected int STA_ANNOT = 100;
    private int m_status = STA_NONE;
    private Document m_doc;
    private int m_pageno;
    private VThread m_thread;
    private VThread m_thread_cache;
    private Bitmap m_bmp;
    VPage m_vpage;
    private int m_x;
    private int m_y;
    private int m_w;
    private int m_h;
    private int m_pw;
    private int m_ph;
    private float m_scale;
    private float m_scale_min;
    private float m_scale_max;
    private int m_fit_type;
    private int m_margin_left;
    private int m_margin_top;
    static private int m_page_gap = 10;
    protected interface PageListener
    {
    }
    private void init()
    {
        m_scroller = new Scroller(getContext());
        m_gesture = new GestureDetector(getContext(), new PDFGestureListener());
        if(m_info_paint == null) {
            m_info_paint = new Paint();
            m_info_paint.setARGB(255, 255, 0, 0);
            m_info_paint.setTextSize(30);
        }
        m_scale = 0;
        m_x = 0;
        m_y = 0;
        m_w = 0;
        m_h = 0;
        m_thread = null;
    }
    private ActivityManager m_amgr;
    private final ActivityManager.MemoryInfo m_info = new ActivityManager.MemoryInfo();
    private Paint m_info_paint = new Paint();
    public PDFPageView(Context context)
    {
        super(context);
        init();
        if(Global.debug_mode)
        {
            m_amgr = (ActivityManager)context.getSystemService(Context.ACTIVITY_SERVICE);
            m_info_paint.setARGB(255, 255, 0, 0);
            m_info_paint.setTextSize(30);
        }
    }
    public PDFPageView(Context context, AttributeSet attrs)
    {
        super(context, attrs);
        init();
        if(Global.debug_mode)
        {
            m_amgr = (ActivityManager)context.getSystemService(Context.ACTIVITY_SERVICE);
            m_info_paint.setARGB(255, 255, 0, 0);
            m_info_paint.setTextSize(30);
        }
    }

    /**
     * open page as single View.
     * @param thread
     * @param thread_cache
     * @param doc
     * @param pageno
     * @param fit_type 0: fit screen. 1: fit width. 2: fit height.
     */
    public void vOpen(VThread thread, VThread thread_cache, Document doc, int pageno, int fit_type)
    {
        vClose();
        m_scale = 0;
        m_x = 0;
        m_y = 0;
        m_doc = doc;
        m_pageno = pageno;
        m_thread = thread;
        m_thread_cache = thread_cache;
        m_fit_type = fit_type;
        vLayout();
    }
    public boolean vIsOpened()
    {
        return m_doc != null;
    }
    public void vFreeCache()
    {
        float pw = m_doc.GetPageWidth(m_pageno);
        float ph = m_doc.GetPageHeight(m_pageno);
        m_scale = m_scale_min;
        int dibw = (int)(m_scale * pw);
        int dibh = (int)(m_scale * ph);
        m_pw = dibw + m_page_gap;
        m_ph = dibh + m_page_gap;
        if(m_w >= m_pw) m_margin_left = (m_w - m_pw + m_page_gap) / 2;
        else m_margin_left = m_page_gap / 2;
        if(m_h >= m_ph) m_margin_top = (m_h - m_ph + m_page_gap) / 2;
        else m_margin_top = m_page_gap / 2;
        SetX(0);
        SetY(0);
        if(m_vpage != null) {
            //m_vpage.vLayout(0, 0, m_scale, true);
            m_vpage.vCacheEnd(m_thread);
            m_vpage.vEndPage(m_thread);
        }
        //SetScale(m_scale_min);
        if(m_bmp != null)
        {
            m_bmp.recycle();
            m_bmp = null;
        }
        m_doc = null;
    }
    public void vClose()
    {
        if(m_vpage != null)
        {
            m_vpage.vCacheEnd(m_thread_cache);
            m_vpage.vDestroy(m_thread);
            m_vpage = null;
        }
        if(m_bmp != null)
        {
            m_bmp.recycle();
            m_bmp = null;
        }
        m_thread = null;
        m_thread_cache = null;
        m_doc = null;
    }
    public final int PDFGetPageNO()
    {
        return m_pageno;
    }
    private void SetX(int x)
    {
        m_x = x;
        if(m_x > m_pw - m_w)
            m_x = m_pw - m_w;
        if(m_x < 0)
            m_x = 0;
    }
    private void SetY(int y)
    {
        m_y = y;
        if(m_y > m_ph - m_h)
            m_y = m_ph - m_h;
        if(m_y < 0)
            m_y = 0;
    }
    private float GetPDFX(float x)
    {
        return (x + m_x - m_margin_left) / m_scale;
    }
    private float GetPDFY(float y)
    {
        return m_doc.GetPageHeight(m_pageno) -  (y + m_y - m_margin_top) / m_scale;
    }
    private void SetPDFX(float x, float pdfx)
    {
        x = (pdfx * m_scale) + m_margin_left - x;
        SetX((int)x);
    }
    private void SetPDFY(float y, float pdfy)
    {
        y = ((m_doc.GetPageHeight(m_pageno) - pdfy) * m_scale) + m_margin_top - y;
        SetY((int)y);
    }
    private void SetScale(float scale)
    {
        float pw = m_doc.GetPageWidth(m_pageno);
        float ph = m_doc.GetPageHeight(m_pageno);
        if(scale < m_scale_min)
            scale = m_scale_min;
        if(scale > m_scale_max)
            scale = m_scale_max;
        m_scale = scale;
        int dibw = (int)(m_scale * pw);
        int dibh = (int)(m_scale * ph);
        m_pw = dibw + m_page_gap;
        m_ph = dibh + m_page_gap;
        if(m_w >= m_pw) m_margin_left = (m_w - m_pw + m_page_gap) / 2;
        else m_margin_left = m_page_gap / 2;
        if(m_h >= m_ph) m_margin_top = (m_h - m_ph + m_page_gap) / 2;
        else m_margin_top = m_page_gap / 2;
        SetX(m_x);
        SetY(m_y);
        m_vpage.vLayout(m_margin_left, m_margin_top, m_scale, true);
        m_vpage.vClips(m_thread, true);
    }
    private void vLayout()
    {
        if(m_w > 0 && m_h > 0)
        {
            if(m_doc != null)
            {
                float pw = m_doc.GetPageWidth(m_pageno);
                float ph = m_doc.GetPageHeight(m_pageno);
                float scale1 = (m_w - m_page_gap) / pw;
                float scale2 = (m_h - m_page_gap) / ph;
                switch(m_fit_type)
                {
                    case 1:
                        m_scale_min = scale1;
                        break;
                    case 2:
                        m_scale_min = scale2;
                        break;
                    default:
                        if (scale1 > scale2) scale1 = scale2;
                        m_scale_min = scale1;
                        break;
                }
                m_scale_max = scale1 * 12;
                if(m_vpage == null)
                {
                    int clipw = (pw > ph) ? (int)(pw * m_scale_min) : (int)(ph * m_scale_min);
                    m_vpage = new VPage(m_doc, m_pageno, clipw, clipw, Bitmap.Config.ARGB_8888);
                }
                SetScale(m_scale_min);
            }
        }
    }
    @Override
    protected void onSizeChanged( int w, int h, int oldw, int oldh )
    {
        super.onSizeChanged(w,h,oldw, oldh);
        m_x = 0;
        m_y = 0;
        m_w = w;
        m_h = h;
        if(m_vpage != null)
        {
            m_vpage.vCacheEnd(m_thread_cache);
            m_vpage.vDestroy(m_thread);
            m_vpage = null;
        }
        if(m_bmp != null) {m_bmp.recycle();m_bmp = null;}
        vLayout();
    }
    private void vDrawZoom(Canvas canvas, int x, int y)
    {
        Canvas bcan = new Canvas(m_bmp);
        m_vpage.vDraw(m_thread, bcan, x, y);
        if(Global.g_dark_mode)
        {
            BMP bmp = new BMP();
            bmp.Create(m_bmp);
            bmp.Invert();
            bmp.Free(m_bmp);
        }
        canvas.drawBitmap(m_bmp, 0, 0, null);
    }
    private void vDrawNormal(Canvas canvas, int x, int y)
    {
        BMP bmp = new BMP();
        bmp.Create(m_bmp);
        m_vpage.vDraw(m_thread, bmp, x, y);
        bmp.Free(m_bmp);
        Canvas bcan = new Canvas(m_bmp);
        m_vpage.vDrawStep1(m_thread, bcan);
        bmp.Create(m_bmp);

        m_vpage.vDrawStep2(bmp);
        if (Global.g_dark_mode) {
            bmp.Invert();
        }
        bmp.Free(m_bmp);
        canvas.drawBitmap(m_bmp, 0, 0, null);
        m_vpage.vDrawEnd();
    }
    @Override
    protected void onDraw(Canvas canvas)
    {
        if(m_doc == null || m_vpage == null || m_w <= 0 || m_h <= 0) return;
        if(m_bmp == null)
        {
            m_bmp = Bitmap.createBitmap(m_w, m_h, Bitmap.Config.ARGB_8888);
        }
        m_bmp.eraseColor(0xFFCCCCCC);
        m_vpage.vCacheStart1(m_thread_cache);
        //canvas.save();
        //Path path = new Path();
        //float x = m_margin_left - m_x;
        //float y = m_margin_top - m_y;
        //path.addRoundRect(new RectF(x, y, x + m_vpage.GetWidth(), y + m_vpage.GetHeight()),
        //        m_scale * 10, m_scale * 10, Path.Direction.CCW);
        //canvas.clipPath(path);
        if(m_zooming)
        {
            vDrawZoom(canvas, m_x, m_y);
            /*
            Canvas bcan = new Canvas(m_bmp);
            m_vpage.vDraw(bcan, m_x, m_y);
            if(Global.g_dark_mode)
            {
                BMP bmp = new BMP();
                bmp.Create(m_bmp);
                bmp.Invert();
                bmp.Free(m_bmp);
            }
            canvas.drawBitmap(m_bmp, 0, 0, null);
            */
        }
        else
        {
            vDrawNormal(canvas, m_x, m_y);
            /*
            int ret = 0;
            BMP bmp = new BMP();
            bmp.Create(m_bmp);
            m_vpage.vDraw(m_thread, bmp, m_x, m_y);
            bmp.Free(m_bmp);
            canvas.drawBitmap(m_bmp, 0, 0, null);
            */
        }
        //canvas.restore();
        if(Global.debug_mode && m_amgr != null)
        {
            try {
                m_amgr.getMemoryInfo(m_info);
                canvas.drawText("AvialMem:" + m_info.availMem / (1024 * 1024) + " M", 20, 150, m_info_paint);
            }
            catch(Exception ex)
            {
                ex.printStackTrace();
            }
        }
    }
    private Scroller m_scroller;
    class PDFGestureListener extends GestureDetector.SimpleOnGestureListener
    {
        @Override
        public boolean onFling(MotionEvent e1, MotionEvent e2, float velocityX, float velocityY)
        {
            if(m_status == STA_NONE)
            {
                if(m_x <= 0 || m_x >= m_pw - m_w)
                    return false;
                float dx = e2.getX() - e1.getX();
                float dy = e2.getY() - e1.getY();
                m_scroller.fling(m_x, m_y, (int)-velocityX, (int)-velocityY, 0, m_pw, 0, m_ph);
                return true;
            }
            else return false;
        }
        @Override
        public boolean onDoubleTap(MotionEvent e)
        {
            return false;
        }
        @Override
        public boolean onDoubleTapEvent(MotionEvent e)
        {
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
        }
        @Override
        public boolean onScroll(MotionEvent e1, MotionEvent e2, float distanceX, float distanceY)
        {
            return false;
        }
        @Override
        public void onShowPress(MotionEvent e)
        {
        }
        @Override
        public boolean onSingleTapConfirmed(MotionEvent e)
        {
            return false;
        }
        @Override
        public boolean onSingleTapUp(MotionEvent e)
        {
            return false;
        }
    }
    private GestureDetector m_gesture = null;
    @Override
    public void computeScroll()
    {
        if( m_vpage != null && m_scroller.computeScrollOffset() )
        {
            SetX(m_scroller.getCurrX());
            SetY(m_scroller.getCurrY());
            invalidate();
        }
    }
    private float m_hold_px;
    private float m_hold_py;
    private float m_hold_x = -10000;
    private float m_hold_y = -10000;
    private float m_zoom_dis0;
    private float m_zoom_scale;
    private float m_zoom_pdfx;
    private float m_zoom_pdfy;
    private boolean touchNone(MotionEvent event)
    {
        if( m_status != STA_NONE ) return false;
        if( m_gesture.onTouchEvent(event) ) return true;
        boolean bOK = true;
        switch(event.getActionMasked())
        {
            case MotionEvent.ACTION_DOWN:
                m_hold_x = event.getX();
                m_hold_y = event.getY();
                m_hold_px = m_x;
                m_hold_py = m_y;
                //m_layout.vScrollAbort();
                invalidate();
                break;
            case MotionEvent.ACTION_MOVE:
                if(m_hold_x <= -10000 && m_hold_y <= -10000)
                {
                    m_hold_x = event.getX();
                    m_hold_y = event.getY();
                    m_hold_px = m_x;
                    m_hold_py = m_y;
                }
                else
                {
                    int x = (int)(m_hold_px + m_hold_x - event.getX());
                    int y = (int)(m_hold_py + m_hold_y - event.getY());
                    if( x > m_pw - m_w )
                    {
                        x = m_pw - m_w;
                        bOK = false;
                    }
                    if(x < 0)
                    {
                        x = 0;
                        bOK = false;
                    }
                    if( y > m_ph - m_h )
                        y = m_ph - m_h;
                    if( y < 0 )
                        y = 0;
                    m_x = x;
                    m_y = y;
                    invalidate();
                }
                break;
            case MotionEvent.ACTION_UP:
            case MotionEvent.ACTION_CANCEL:
                if(m_hold_x <= -10000 && m_hold_y <= -10000)
                {
                    m_hold_x = event.getX();
                    m_hold_y = event.getY();
                    m_hold_px = m_x;
                    m_hold_py = m_y;
                }
                else
                {
                    int x = (int)(m_hold_px + m_hold_x - event.getX());
                    int y = (int)(m_hold_py + m_hold_y - event.getY());
                    if( x > m_pw - m_w )
                    {
                        x = m_pw - m_w;
                        bOK = false;
                    }
                    if(x < 0)
                    {
                        x = 0;
                        bOK = false;
                    }
                    if( y > m_ph - m_h )
                        y = m_ph - m_h;
                    if( y < 0 )
                        y = 0;
                    m_x = x;
                    m_y = y;
                    invalidate();
                    //m_layout.vMoveEnd();
                }
                m_hold_x = -10000;
                m_hold_y = -10000;
                break;
            case MotionEvent.ACTION_POINTER_DOWN:
                if( event.getPointerCount() >= 2 )
                {
                    m_status = STA_ZOOM;
                    m_hold_x = (event.getX(0) + event.getX(1))/2;
                    m_hold_y = (event.getY(0) + event.getY(1))/2;
                    m_zoom_pdfx = GetPDFX(m_hold_x);
                    m_zoom_pdfy = GetPDFY(m_hold_y);
                    //m_zoom_pos = m_layout.vGetPos( (int)m_hold_x, (int)m_hold_y );
                    float dx = event.getX(0) - event.getX(1);
                    float dy = event.getY(0) - event.getY(1);
                    m_zoom_dis0 = Global.sqrtf(dx * dx + dy * dy);
                    m_zoom_scale = m_scale;
                    m_status = STA_ZOOM;
                    m_vpage.vZoomStart(Bitmap.Config.ARGB_8888);
                    m_zooming = true;
                    //if(m_listener != null)
                    //    m_listener.OnPDFZoomStart();
                }
                break;
        }
        return bOK;
    }
    private boolean m_zooming = false;
    private boolean onTouchZoom(MotionEvent event)
    {
        if( m_status != STA_ZOOM ) return false;
        switch(event.getActionMasked())
        {
            case MotionEvent.ACTION_MOVE:
                if(event.getPointerCount() < 2)
                {
                    m_status = STA_NONE;
                    return false;
                }
                if( m_status == STA_ZOOM )
                {
                    float dx = event.getX(0) - event.getX(1);
                    float dy = event.getY(0) - event.getY(1);
                    float dis1 = Global.sqrtf(dx * dx + dy * dy);
                    SetScale(m_zoom_scale * dis1 / m_zoom_dis0);
                    SetPDFX(m_hold_x, m_zoom_pdfx);
                    SetPDFY(m_hold_y, m_zoom_pdfy);
                    invalidate();
                }
                break;
            case MotionEvent.ACTION_UP:
            case MotionEvent.ACTION_POINTER_UP:
            case MotionEvent.ACTION_CANCEL:
                if( m_status == STA_ZOOM && event.getPointerCount() <= 2 )
                {
                    float dx = event.getX(0) - event.getX(1);
                    float dy = event.getY(0) - event.getY(1);
                    float dis1 = Global.sqrtf(dx * dx + dy * dy);
                    SetScale(m_zoom_scale * dis1 / m_zoom_dis0);
                    SetPDFX(m_hold_x, m_zoom_pdfx);
                    SetPDFY(m_hold_y, m_zoom_pdfy);
                    m_vpage.vZoomConfirmed(m_thread, m_x, m_y, m_w, m_h);
                    m_hold_x = -10000;
                    m_hold_y = -10000;
                    m_status = STA_NONE;
                    invalidate();
                }
                break;
            default:
                if(event.getPointerCount() < 2)
                {
                    m_status = STA_NONE;
                    return false;
                }
                break;
        }
        return true;
    }
    @Override
    public boolean onTouchEvent(MotionEvent event)
    {
        //if (m_pw <= m_w || m_ph <= m_h) return false;
        try {
            if (onTouchZoom(event)) {
                getParent().requestDisallowInterceptTouchEvent(true);
                return true;
            }
            boolean bOK = touchNone(event);
            getParent().requestDisallowInterceptTouchEvent(bOK);
            return bOK;
        }
        catch(Exception e)
        {
            return false;
        }
    }
    public boolean vIsRenderFinish()
    {
        if(m_vpage == null) return false;
        return m_vpage.vFinished();
    }
    public void vRenderFinish()
    {
        if(m_vpage == null) return;
        m_vpage.vZoomEnd();
        m_zooming = false;
        invalidate();
    }
    @Override
    protected void finalize() throws Throwable
    {
        vClose();
        super.finalize();
    }
}
