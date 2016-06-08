package com.radaee.view;

import android.annotation.SuppressLint;
import android.annotation.TargetApi;
import android.content.Context;
import android.os.Build;
import android.os.Handler;
import android.os.Looper;
import android.os.Message;
import androidx.viewpager.widget.PagerAdapter;
import androidx.viewpager.widget.ViewPager;
import android.util.AttributeSet;
import android.view.MotionEvent;
import android.view.View;
import android.view.ViewGroup;

import com.radaee.pdf.Document;
import com.radaee.pdf.VNCache;

/**
 * Created by radaee on 2015/5/14.
 */
@TargetApi(Build.VERSION_CODES.GINGERBREAD)
public class PDFViewPager extends ViewPager {
    private PDFPageView[] m_pages = null;
    private VThread m_thread;
    private final Handler m_hand_ui = new Handler(Looper.myLooper()) {
        public void handleMessage(Message msg) {
            PDFPageView pagev;
            int pageno;
            switch (msg.what)//render finished.
            {
                case 0:
                    //if(m_listener != null) m_listener.OnPageRendered(((VCache)msg.obj).vGetPageNO());
                    if (m_pages != null) {
                        long cache = (((long)msg.arg1) << 32) | (((long)msg.arg2)& 0xffffffffL);
                        pageno = VNCache.getNO(cache);
                        if(pageno >= m_pages.length || pageno < 0) return;
                        pagev = m_pages[pageno];
                        if (pagev != null && pagev.vIsRenderFinish())
                            pagev.vRenderFinish();
                    }
                    break;
                case 1://find operation returned.
                    if (msg.arg1 == 1)//succeeded
                    {
                        //vFindGoto();
                        //if( m_listener != null )
                        //    m_listener.OnFound( true );
                    } else {
                        //if( m_listener != null )
                        //    m_listener.OnFound( false );
                    }
                    break;
                case 100://timer
                    if (m_pages != null) {
                        pageno = PDFViewPager.this.getCurrentItem();
                        if (m_pages != null && m_pages.length > 0 && m_pages[pageno] != null)
                            m_pages[pageno].invalidate();
                        //if(m_listener != null) m_listener.OnTimer();
                    }
                    break;
            }
            super.handleMessage(msg);
        }
    };

    private class PDFPageAdapter extends PagerAdapter {
        private final Document m_doc;
        private final Context m_ctx;

        public PDFPageAdapter(Context ctx, Document doc) {
            m_doc = doc;
            m_ctx = ctx;
        }
        @Override
        public java.lang.Object instantiateItem(android.view.ViewGroup container, int position)
        {
            if(m_pages[position] == null)
            {
                m_pages[position] = new PDFPageView(m_ctx);
                m_pages[position].vOpen(m_thread, m_thread, m_doc, position, m_fit_type);
                container.addView(m_pages[position]);
            }
            m_pages[position].invalidate();
            return m_pages[position];
        }
        @Override
        public int getCount() {
            return m_pages.length;
        }

        @Override
        public void destroyItem(ViewGroup container, int position, Object object)
        {
            PDFPageView pview = m_pages[position];
            m_pages[position] = null;
            container.removeView(pview);
            pview.vFreeCache();
            pview.vClose();
        }
        @Override
        public boolean isViewFromObject(View view, Object o) {
            return view == o;
        }
        @Override
        public CharSequence getPageTitle(int position) {
            return "Page:" + position;
        }
    }
    private PDFPageAdapter m_adt;

    public PDFViewPager(Context context) {
        super(context);
    }
    public PDFViewPager(Context context, AttributeSet attrs) {
        super(context, attrs);
    }
    private int m_fit_type;

    /**
     * @param doc
     * @param fit_type page fit mode: 0- fit screen. 1- fit width. 2- fit height.
     */
    public void PDFOpen(Document doc, int fit_type)
    {
        //VPage.SetConfigure(getContext());
        m_fit_type = fit_type;
        m_thread = new VThread(m_hand_ui);
        m_thread.start();
        //m_thread_cache = new VThread(m_hand_ui);
        //m_thread_cache.start();
        int cnt = doc.GetPageCount();
        m_pages = new PDFPageView[cnt];
        m_adt = new PDFPageAdapter(getContext(), doc);
        setAdapter(m_adt);
        setCurrentItem(0);
    }

    public void PDFClose() {
        if (m_pages != null) {
            int cur = 0;
            int cnt = m_pages.length;
            for (cur = 0; cur < cnt; cur++) {
                if (m_pages[cur] != null && m_pages[cur].vIsOpened()) {
                    m_pages[cur].vClose();
                    m_pages[cur] = null;
                }
            }
            m_pages = null;
        }
        if (m_thread != null) {
            m_thread.destroy();
            //m_thread_cache.destroy();
            m_thread = null;
            //m_thread_cache = null;
        }
    }
    @Override
    protected void finalize() throws Throwable
    {
        PDFClose();
        super.finalize();
    }

    @SuppressLint("ClickableViewAccessibility")
    @Override
    //Added to avoid pointerIndex out of range
    public boolean onTouchEvent(MotionEvent ev) {
        try {
            return super.onTouchEvent(ev);
        } catch (IllegalArgumentException ex) {
            ex.printStackTrace();
        }
        return false;
    }

    @Override
    //Added to avoid pointerIndex out of range
    public boolean onInterceptTouchEvent(MotionEvent ev) {
        try {
            return super.onInterceptTouchEvent(ev);
        } catch (IllegalArgumentException ex) {
            ex.printStackTrace();
        }
        return false;
    }
}
