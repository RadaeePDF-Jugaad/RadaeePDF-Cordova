package com.radaee.view;

import android.content.Context;
import android.graphics.Bitmap;
import android.graphics.Bitmap.Config;
import android.graphics.Canvas;
import android.os.Handler;
import android.os.Looper;
import android.os.Message;
import android.widget.Scroller;

import com.radaee.pdf.BMP;
import com.radaee.pdf.Document;
import com.radaee.pdf.Global;
import com.radaee.pdf.VNBlock;
import com.radaee.pdf.VNCache;

@SuppressWarnings("WeakerAccess")
abstract public class PDFLayout {
    public static class PDFPos {
        public float x = 0;
        public float y = 0;
        public int pageno = 0;
    }

    /**
     * call-back listener classv
     *
     * @author radaee
     */
    public interface LayoutListener {
        /**
         * fired when pageno changed.
         *
         * @param pageno pageno.<br/>
         */
        void OnPageChanged(int pageno);

        void OnPageRendered(int pageno);

        void OnCacheRendered(int pageno);

        /**
         * fired when searching end.
         *
         * @param found true if found, otherwise pass false.
         */
        void OnFound(boolean found);

        /**
         * fired when a page displayed.
         *
         * @param canvas canvas to draw.
         * @param vpage  VPage object
         */
        void OnPageDisplayed(Canvas canvas, VPage vpage);

        void OnTimer();
    }

    protected Config m_bmp_format = Config.ARGB_8888;
    protected Bitmap m_bmp = null;
    protected Document m_doc = null;
    protected VPage[] m_pages = null;
    protected VThread m_thread = null;
    protected VFinder m_finder = null;
    protected int m_w = 0;
    protected int m_h = 0;
    protected int m_tw = 0;
    protected int m_th = 0;
    protected float m_scale = 0;
    protected float m_scale_min = 1;
    protected float m_scale_max = 1;
    protected float m_zoom_level = Global.g_layout_zoom_level;
    protected float m_zoom_level_clip = Global.g_layout_zoom_clip;
    protected int m_disp_page1 = 0;
    protected int m_disp_page2 = 0;
    protected int m_cache_page1 = 0;
    protected int m_cache_page2 = 0;
    protected int m_page_gap = 4;
    protected int m_back_color = Global.g_readerview_bg_color;
    protected float m_page_maxw;
    protected float m_page_maxh;
    protected LayoutListener m_listener = null;
    protected Scroller m_scroller = null;
    protected Handler m_hand_ui = new Handler(Looper.getMainLooper()) {
        @Override
        public void handleMessage(Message msg) {
            if(m_thread == null) return;
            switch (msg.what) {
                case 0: //render finished.
                    long cache = (((long) msg.arg1) << 32) | (((long) msg.arg2) & 0xffffffffL);
                    if (m_listener != null) m_listener.OnCacheRendered(VNCache.getNO(cache));
                    break;
                case 1://find operation returned.
                    if (msg.arg1 == 1)//succeeded
                    {
                        vFindGoto();
                        if (m_listener != null)
                            m_listener.OnFound(true);
                    } else {
                        if (m_listener != null)
                            m_listener.OnFound(false);
                    }
                    break;
                case 2: //cache finished
                    long blk = (((long) msg.arg1) << 32) | (((long) msg.arg2) & 0xffffffffL);
                    //if (m_listener != null) m_listener.OnCacheRendered(VNBlock.getPageNO(blk));
                    if (m_listener != null) m_listener.OnPageRendered(VNBlock.getPageNO(blk));
                    break;
                case 100://timer
                    if (m_listener != null) m_listener.OnTimer();
                    break;
            }
            super.handleMessage(msg);
        }
    };
    private final Context m_ctx;

    protected float[] m_scales = null;
    protected float[] m_scales_min = null;

    protected PDFLayout(Context context) {
        m_ctx = context;
        m_scroller = new Scroller(context);
    }

    /**
     * invoke when resize.
     *
     * @param cx new width
     * @param cy new height
     */
    public void vResize(int cx, int cy) {
        if (cx <= 0 || cy <= 0) return;
        if (cx == m_w && cy == m_h) return;
        if (m_pages == null) return;
        vScrollAbort();
        PDFPos pos = vGetPos(m_w / 2, m_h / 2);
        m_w = cx;
        m_h = cy;
        if (m_bmp != null) m_bmp.recycle();
        m_bmp = Bitmap.createBitmap(m_w, m_h, m_bmp_format);
        int cnt = m_pages.length;
        int clipw = (m_w > m_h) ? m_h : m_w - m_page_gap;
        for (int cur = 0; cur < cnt; cur++) {
            if (m_pages[cur] != null) {
                m_pages[cur].vCacheEnd(m_thread);
                m_pages[cur].vDestroy(m_thread);
            }
            m_pages[cur] = new VPage(m_doc, cur, clipw, clipw, m_bmp_format);
        }
        m_scales = null;
        m_scales_min = null;
        vLayout();
        vSetPos(m_w / 2, m_h / 2, pos);
    }

    public final void vScrollAbort() {
        if (m_doc != null) {
            if (!m_scroller.isFinished() && m_listener != null) {
                m_scroller.computeScrollOffset();
                Scroller scroller = new Scroller(m_ctx);
                scroller.setFinalX(m_scroller.getCurrX());
                scroller.setFinalY(m_scroller.getCurrY());
                m_scroller = scroller;
                m_scroller.computeScrollOffset();
            }
        }
    }

    public final boolean vScrollCompute() {
        return m_doc != null && m_scroller.computeScrollOffset();
    }

    private final BMP m_dbmp = new BMP();

    private void vDrawZoom(Canvas canvas, int x, int y) {
        int pageno0 = m_disp_page1;
        int pageno1 = m_disp_page2;
        if (Global.g_dark_mode) {
            if (m_bmp.getConfig() == Config.ARGB_8888)
            {
                //for ARGB_8888, using SIMD to enhance speed.
                m_dbmp.Create(m_bmp);
                if (((m_back_color >> 24) & 255) == 0)
                    m_dbmp.DrawRect(0xFFFFFF, 0, 0, m_w, m_h, 1);
                else
                    m_dbmp.DrawRect(m_back_color, 0, 0, m_w, m_h, 1);
                m_dbmp.Free(m_bmp);
            }
            else
            {
                if (((m_back_color >> 24) & 255) == 0)
                    m_bmp.eraseColor(-1);
                else
                    m_bmp.eraseColor(m_back_color);
            }
            Canvas bcan = new Canvas(m_bmp);
            while (pageno0 < pageno1) {
                m_pages[pageno0].vDraw(m_thread, bcan, x, y);
                pageno0++;
            }
            m_dbmp.Create(m_bmp);
            //if (((m_back_color >> 24) & 255) == 0)
            //    m_dbmp.DrawRect(0xFFFFFF, 0, 0, m_w, m_h, 1);
            //else
            //    m_dbmp.DrawRect(m_back_color, 0, 0, m_w, m_h, 1);
            m_dbmp.Invert();
            m_dbmp.Free(m_bmp);
            canvas.drawBitmap(m_bmp, 0, 0, null);
        } else {
            canvas.drawColor(m_back_color);
            while (pageno0 < pageno1) {
                m_pages[pageno0].vDraw(m_thread, canvas, x, y);
                pageno0++;
            }
        }
    }

    private void vDrawNormal(Canvas canvas, int x, int y) {
        int pageno0 = m_disp_page1;
        int pageno1 = m_disp_page2;
        boolean clip = m_scale > m_zoom_level_clip * m_scale_min;
        VPage vp;
        //m_bmp.eraseColor(m_back_color);
        m_dbmp.Create(m_bmp);
        if (Global.g_dark_mode && ((m_back_color >> 24) & 255) == 0)
            m_dbmp.DrawRect(0xFFFFFF, 0, 0, m_w, m_h, 1);
        else
            m_dbmp.DrawRect(m_back_color, 0, 0, m_w, m_h, 1);
        while (pageno0 < pageno1)//first step: only draw finished block.
        {
            boolean clipPage = Global.g_auto_scale ? m_scales[pageno0] / m_scales_min[pageno0] > m_zoom_level_clip : clip;
            vp = m_pages[pageno0++];
            vp.vClips(m_thread, clipPage);//clip to blocks.
            vp.vDraw(m_thread, m_dbmp, x, y);
        }
        if (Global.g_dark_mode)//dark mode.
        {
            if (Global.g_cache_enable)//zoom cache to bitmap
            {
                m_dbmp.Free(m_bmp);
                Canvas bcan = new Canvas(m_bmp);
                pageno0 = m_disp_page1;
                while (pageno0 < pageno1) {
                    vp = m_pages[pageno0++];
                    vp.vDrawStep1(m_thread, bcan);
                    vp.vDrawEnd();
                }
                m_dbmp.Create(m_bmp);
            } else//draw rendering blocks to
            {
                pageno0 = m_disp_page1;
                while (pageno0 < pageno1) {
                    vp = m_pages[pageno0++];
                    vp.vDrawStep2(m_dbmp);
                    vp.vDrawEnd();
                }
            }
            m_dbmp.Invert();//convert to dark.
            m_dbmp.Free(m_bmp);
            canvas.drawBitmap(m_bmp, 0, 0, null);
        } else {
            if (Global.g_cache_enable)//zoom cache to canvas directly.
            {
                m_dbmp.Free(m_bmp);
                canvas.drawBitmap(m_bmp, 0, 0, null);
                pageno0 = m_disp_page1;
                while (pageno0 < pageno1) {
                    vp = m_pages[pageno0++];
                    vp.vDrawStep1(m_thread, canvas);
                    vp.vDrawEnd();
                }
            } else//if not in cache mode, just draw rendering block.
            {
                pageno0 = m_disp_page1;
                while (pageno0 < pageno1) {
                    vp = m_pages[pageno0++];
                    vp.vDrawStep2(m_dbmp);
                    vp.vDrawEnd();
                }

                m_dbmp.Free(m_bmp);
                canvas.drawBitmap(m_bmp, 0, 0, null);
            }
        }
        //if(Global.debug_mode) Log.e("draw", String.format("%d", SystemClock.elapsedRealtime() - tick_time));
    }

    /**
     * draw layout to canvas.
     *
     * @param canvas  canvas to draw.
     * @param zooming zooming status.
     */
    public void vDraw(Canvas canvas, boolean zooming) {
        if(m_doc == null) return;
        vFlushRange();
        int pageno0 = m_disp_page1;
        int pageno1 = m_disp_page2;
        if (pageno0 < 0 || pageno1 < 0 || pageno1 <= pageno0) return;
        int x = vGetX();
        int y = vGetY();

        if (zooming) vDrawZoom(canvas, x, y);
        else vDrawNormal(canvas, x, y);
        pageno0 = m_finder.find_get_page();
        if (pageno0 >= m_disp_page1 && pageno0 < m_disp_page2)
            m_finder.find_draw(canvas, m_pages[pageno0], x, y);
        if (m_listener != null) {
            pageno0 = m_disp_page1;
            while (pageno0 < pageno1) {
                m_listener.OnPageDisplayed(canvas, m_pages[pageno0]);
                pageno0++;
            }
        }
    }

    public final boolean vRenderFinished() {
        int pageno0 = m_disp_page1;
        int pageno1 = m_disp_page2;
        if (pageno0 < 0 || pageno1 < 0) return true;
        while (pageno0 < pageno1) {
            if (!m_pages[pageno0].vFinished()) return false;
            pageno0++;
        }
        return true;
    }

    public void vRenderSync(VPage page) {
        if (m_pages == null || page == null) return;
        page.vCacheEnd(m_thread);
        vFlushCacheRange();
        m_thread.wait_pending();//wait pending operation finished.
        page.vRenderSync(m_thread, page.GetX() - vGetX(), page.GetY() - vGetY(), m_w, m_h);
    }

    /**
     * render page again, after page modified.
     *
     * @param page page object obtained by vGetPage()
     */
    public void vRenderAsync(VPage page) {
        if (m_pages == null || page == null) return;
        page.vCacheEnd(m_thread);
        vFlushCacheRange();
        page.vRenderAsync(m_thread, page.GetX() - vGetX(), page.GetY() - vGetY(), m_w, m_h);
    }

    abstract public void vLayout();

    abstract public int vGetPage(int vx, int vy);

    public final VPage vGetPage(int pageno) {
        if (pageno < 0) pageno = 0;
        if (pageno > m_pages.length - 1) pageno = m_pages.length - 1;
        return m_pages[pageno];
    }

    public PDFPos vGetPos(int vx, int vy) {
        if (m_w <= 0 || m_h <= 0) return null;
        int pageno = vGetPage(vx, vy);
        if (pageno < 0) return null;
        vx += vGetX();
        vy += vGetY();
        VPage vpage = m_pages[pageno];
        PDFPos pos = new PDFPos();
        pos.x = vpage.GetPDFX(vx);
        pos.y = vpage.GetPDFY(vy);
        pos.pageno = pageno;
        return pos;
    }

    public void vSetPos(int vx, int vy, PDFPos pos) {
        if (pos == null) return;
        VPage vpage = m_pages[pos.pageno];
        vSetX(vpage.GetVX(pos.x) - vx);
        vSetY(vpage.GetVY(pos.y) - vy);
        m_scroller.computeScrollOffset();
    }

    public void vGotoPage(int pageno) {
        if (m_pages == null || pageno < 0 || pageno >= m_pages.length) return;
        int hgap = (m_page_gap >> 1);
        float x = m_pages[pageno].GetX() - hgap;
        float y = m_pages[pageno].GetY() - hgap;
        if (x > m_tw - m_w) x = m_tw - m_w;
        if (x < 0) x = 0;
        if (y > m_th - m_h) y = m_th - m_h;
        if (y < 0) y = 0;
        m_scroller.setFinalX((int) x);
        m_scroller.setFinalY((int) y);
        m_scroller.computeScrollOffset();
        if (m_scroller.isFinished())//let next computeScrollOffset return true. and ensure that flush range will run normally.
            m_scroller.setFinalY(m_scroller.getCurrY());//make isFinished false.
    }

    public void vScrolltoPage(int pageno) {
        if (m_pages == null || pageno < 0 || pageno >= m_pages.length) return;
        int hgap = (m_page_gap >> 1);
        float x = m_pages[pageno].GetX() - hgap;
        float y = m_pages[pageno].GetY() - hgap;
        if (x > m_tw - m_w) x = m_tw - m_w;
        if (x < 0) x = 0;
        if (y > m_th - m_h) y = m_th - m_h;
        if (y < 0) y = 0;
        float oldx = m_scroller.getCurrX();
        float oldy = m_scroller.getCurrY();
        m_scroller.startScroll((int)oldx, (int)oldy, (int)(x - oldx), (int)(y - oldy));
        m_scroller.computeScrollOffset();
    }

    public void vMoveEnd() {
    }

    protected int m_zoom_page0;
    protected int m_zoom_page1;

    public void vZoomStart() {
        vFlushRange();
        if (m_disp_page1 < 0 || m_disp_page2 < 0) {
            return;
        }
        vScrollAbort();
        m_zoom_page0 = m_disp_page1;
        m_zoom_page1 = m_disp_page2;
        int cur = m_zoom_page0;
        while (cur < m_zoom_page1) {
            m_pages[cur].vZoomStart(m_bmp_format);
            cur++;
        }
    }

    public boolean vZoomEnd() {
        if (m_zoom_page0 >= m_zoom_page1) {
            m_zoom_page0 = 0;
            m_zoom_page1 = -1;
            return true;
        }
        int cur = m_zoom_page0;
        while (cur < m_zoom_page1) {
            if (!m_pages[cur].vFinished())
                return false;
            cur++;
        }
        cur = m_zoom_page0;
        while (cur < m_zoom_page1) {
            m_pages[cur].vZoomEnd();
            cur++;
        }
        m_zoom_page0 = 0;
        m_zoom_page1 = -1;
        return true;
    }

    public void vZoomConfirmed() {
        int cur = m_zoom_page0;
        int x = vGetX();
        int y = vGetY();
        while (cur < m_zoom_page1) {
            m_pages[cur].vZoomConfirmed(m_thread, x, y, m_w, m_h);
            cur++;
        }
    }

    /**
     * Open View
     */
    public void vOpen(Document doc, LayoutListener listener) {
        if (doc == null) return;
        int cnt = doc.GetPageCount();
        if (cnt <= 0) return;
        m_listener = listener;
        m_doc = doc;
        float[] max = m_doc.GetPagesMaxSize();
        m_page_maxw = max[0];
        m_page_maxh = max[1];
        m_finder = new VFinder();
        m_pages = new VPage[cnt];
        m_thread = new VThread(m_hand_ui);
        m_thread.start();
        //m_thread_cache = new VThread(m_hand_ui);
        //m_thread_cache.start();
        m_scroller.setFinalX(0);
        m_scroller.setFinalY(0);
        if (m_w > 0 && m_h > 0) {
            m_bmp = Bitmap.createBitmap(m_w, m_h, m_bmp_format);
            m_scale = 0;
            int clipw = (m_w > m_h) ? m_h : m_w - m_page_gap;
            for (int cur = 0; cur < cnt; cur++) {
                if (m_pages[cur] != null) {
                    m_pages[cur].vCacheEnd(m_thread);
                    m_pages[cur].vDestroy(m_thread);
                }
                m_pages[cur] = new VPage(m_doc, cur, clipw, clipw, m_bmp_format);
            }
            vLayout();
        }
    }

    public void vClose() {
        if (m_pages == null) return;
        vScrollAbort();
        if (m_finder != null) {
            m_finder.find_end();
            m_finder = null;
        }
        int cnt = m_pages.length;
        for (int cur = 0; cur < cnt && m_pages[cur] != null; cur++) {
            m_pages[cur].vCacheEnd(m_thread);
            m_pages[cur].vDestroy(m_thread);
        }
        m_thread.destroy();
        m_thread = null;
        //m_thread_cache.destroy();
        //m_thread_cache = null;
        m_pages = null;
        m_scales = null;
        m_scales_min = null;
        if (m_bmp != null) {
            m_bmp.recycle();
            m_bmp = null;
        }
    }

    public void vSetBackColor(int color) {
        m_back_color = color;
    }

    public void vSetPageGap(int gap) {
        if (gap < 0) gap = 0;
        gap = (gap >> 1) << 1;
        m_page_gap = gap;
        vLayout();
    }

    public void vSetBmpFormat(Config format) {
        if (m_bmp_format == format || format == Config.ALPHA_8) return;
        m_bmp_format = format;
        if (m_bmp != null) {
            m_bmp.recycle();
            m_bmp = Bitmap.createBitmap(m_w, m_h, format);
        }
    }

    public final float vGetZoom() {
        return Global.g_auto_scale && m_pageno < m_scales.length ? m_scales[m_pageno] / m_scales_min[m_pageno] : m_scale / m_scale_min;
    }

    public void vZoomSet(int vx, int vy, PDFPos pos, float zoom) {
        m_scale = zoom * m_scale_min;
        if(Global.g_auto_scale) {
            int cnt = m_doc.GetPageCount();
            for(int i = 0; i < cnt; i++) {
                float newScale = zoom * m_scales_min[i];
                if(newScale < m_scales_min[i]) newScale = m_scales_min[i];
                if(newScale > vGetMaxScale()) newScale = vGetMaxScale();
                m_scales[i] = newScale;
            }
        }
        vLayout();
        vSetPos(vx, vy, pos);
    }

    public void vFindStart(String key, boolean match_case, boolean whole_word) {
        vFindStart(key, match_case, whole_word, false);
    }

    public void vFindStart(String key, boolean match_case, boolean whole_word, boolean skipBlank) {
        if (m_pages == null) return;
        int pageno = vGetPage(m_w / 4, m_h / 4);
        m_finder.find_end();
        m_finder.find_start(m_doc, pageno, key, match_case, whole_word, skipBlank);
    }

    protected void vFindGoto() {
        if (m_pages == null) return;
        int pg = m_finder.find_get_page();
        if (pg < 0 || pg >= m_doc.GetPageCount()) return;
        int x = vGetX();
        int y = vGetY();
        float[] pos = m_finder.find_get_pos();
        if (pos == null) return;
        VPage vp = m_pages[pg];
        pos[0] = vp.ToDIBX(pos[0]) + vp.GetX();
        pos[1] = vp.ToDIBY(pos[1]) + vp.GetY();
        pos[2] = vp.ToDIBX(pos[2]) + vp.GetX();
        pos[3] = vp.ToDIBY(pos[3]) + vp.GetY();
        int mw0 = (m_w >> 3);
        int mw1 = m_w - mw0;
        int mh0 = (m_h >> 3);
        int mh1 = m_h - mw0;
        if (x > pos[0] - mw0) x = (int) pos[0] - mw0;
        if (x < pos[2] - mw1) x = (int) pos[2] - mw1;
        if (y > pos[1] - mh0) y = (int) pos[1] - mh0;
        if (y < pos[3] - mh1) y = (int) pos[3] - mh1;
        if (x > m_tw - m_w) x = m_tw - m_w;
        if (x < 0) x = 0;
        if (y > m_th - m_h) y = m_th - m_h;
        if (y < 0) y = 0;
        vScrollAbort();
        m_scroller.setFinalX(x);
        m_scroller.setFinalY(y);
        //we have override vFindGoto method in PDFLayoutDual class.
        //if (this instanceof PDFLayoutDual) vGotoPage(pg);
    }

    public int vFind(int dir) {
        if (m_pages == null) return -1;
        int ret = m_finder.find_prepare(dir);
        if (ret == 1) {
            if (m_listener != null)
                m_listener.OnFound(true);
            vFindGoto();
            return 0;//succeeded
        }
        if (ret == 0) {
            if (m_listener != null)
                m_listener.OnFound(false);
            return -1;//failed
        }
        m_thread.start_find(m_finder);//need thread operation.
        return 1;
    }

    public void vFindEnd() {
        if (m_pages == null) return;
        m_finder.find_end();
    }

    public final int vGetX() {
        m_scroller.computeScrollOffset();
        int x = m_scroller.getCurrX();
        if (x > m_tw - m_w) x = m_tw - m_w;
        if (x < 0) x = 0;
        return x;
    }

    public void vSetX(int x) {
        if (x > m_tw - m_w) x = m_tw - m_w;
        if (x < 0) x = 0;
        m_scroller.setFinalX(x);
    }

    public final int vGetY() {
        m_scroller.computeScrollOffset();
        int y = m_scroller.getCurrY();
        if (y > m_th - m_h) y = m_th - m_h;
        if (y < 0) y = 0;
        return y;
    }

    public void vSetY(int y) {
        if (y > m_th - m_h) y = m_th - m_h;
        if (y < 0) y = 0;
        m_scroller.setFinalY(y);
    }

    public boolean vFling(int holdx, int holdy, float dx, float dy, float vx, float vy) {
        m_scroller.abortAnimation();
        m_scroller.forceFinished(true);
        m_scroller.fling(vGetX(), vGetY(), (int) -vx, (int) -vy, -m_w, m_tw, -m_h, m_th);
        return true;
    }

    protected int m_pageno = -1;

    protected void vFlushCacheRange() {
        //float mul = m_scale / m_scale_min;
        float mul = Global.g_auto_scale ? m_scales[m_pageno] / m_scales_min[m_pageno] : m_scale / m_scale_min;
        PDFPos pos1 = vGetPos((int) (-m_w * mul), (int) (-m_h * mul));
        PDFPos pos2 = vGetPos(m_w + (int) (m_w * mul), m_h + (int) (m_h * mul));
        if (pos1 == null || pos2 == null) return;
        int pageno1 = pos1.pageno;
        int pageno2 = pos2.pageno;
        if (pageno1 >= 0 && pageno2 >= 0) {
            if (pageno1 > pageno2) {
                int tmp = pageno1;
                pageno1 = pageno2;
                pageno2 = tmp;
            }
            pageno2++;
            if (m_cache_page1 < pageno1) {
                int start = m_cache_page1;
                int end = pageno1;
                if (end > m_cache_page2) end = m_cache_page2;
                while (start < end) {
                    VPage vpage = m_pages[start];
                    //vpage.vCacheEnd(m_thread_cache);
                    vpage.vCacheEnd(m_thread);
                    start++;
                }
            }
            if (m_cache_page2 > pageno2) {
                int start = pageno2;
                int end = m_cache_page2;
                if (start < m_cache_page1) start = m_cache_page1;
                while (start < end) {
                    VPage vpage = m_pages[start];
                    //vpage.vCacheEnd(m_thread_cache);
                    vpage.vCacheEnd(m_thread);
                    start++;
                }
            }
        } else {
            int start = m_disp_page1;
            int end = m_disp_page2;
            while (start < end) {
                VPage vpage = m_pages[start];
                //vpage.vCacheEnd(m_thread_cache);
                vpage.vCacheEnd(m_thread);
                start++;
            }
        }
        m_cache_page1 = pageno1;
        m_cache_page2 = pageno2;
        pageno1 = m_pageno;
        pageno2 = m_pageno + 1;

        while (pageno1 > pos1.pageno && pageno2 < pos2.pageno) {
            VPage vpage1 = m_pages[pageno1];
            VPage vpage2 = m_pages[pageno2];
            //vpage1.vCacheStart1(m_thread_cache);
            //vpage2.vCacheStart1(m_thread_cache);
            vpage1.vCacheStart1(m_thread);
            vpage2.vCacheStart1(m_thread);
            pageno1--;
            pageno2++;
        }
        while (pageno1 >= pos1.pageno) {
            VPage vpage1 = m_pages[pageno1];
            //vpage1.vCacheStart1(m_thread_cache);
            vpage1.vCacheStart1(m_thread);
            pageno1--;
        }
        while (pageno2 < pos2.pageno) {
            VPage vpage2 = m_pages[pageno2];
            //vpage2.vCacheStart1(m_thread_cache);
            vpage2.vCacheStart1(m_thread);
            pageno2++;
        }

        VPage vpage1 = m_pages[pos1.pageno];
        VPage vpage2 = m_pages[pos2.pageno];
        if (vpage1 == vpage2) {
            vpage1.vCacheStart(m_thread, pos1.x, pos1.y, pos2.x, pos2.y);
        } else {
            vpage2.vCacheStart2(m_thread, pos2.x, pos2.y);
            vpage1.vCacheStart0(m_thread, pos1.x, pos1.y);
            if (pos2.pageno > pos1.pageno) {
                for (pageno1 = pos1.pageno + 1; pageno1 < pos2.pageno; pageno1++) {
                    vpage1 = m_pages[pageno1];
                    vpage1.vCacheStart1(m_thread);
                }
            } else {
                for (pageno2 = pos2.pageno + 1; pageno2 < pos1.pageno; pageno2++) {
                    vpage2 = m_pages[pageno2];
                    vpage2.vCacheStart1(m_thread);
                }
            }
        }
    }

    protected void vFlushRange() {
        int pageno1 = vGetPage(0, 0);
        int pageno2 = vGetPage(m_w, m_h);
        if (pageno1 >= 0 && pageno2 >= 0) {
            if (pageno1 > pageno2) {
                int tmp = pageno1;
                pageno1 = pageno2;
                pageno2 = tmp;
            }
            pageno2++;
            if (m_disp_page1 < pageno1) {
                int start = m_disp_page1;
                int end = pageno1;
                if (end > m_disp_page2) end = m_disp_page2;
                while (start < end) {
                    VPage vpage = m_pages[start];
                    vpage.vEndPage(m_thread);
                    start++;
                }
            }
            if (m_disp_page2 > pageno2) {
                int start = pageno2;
                int end = m_disp_page2;
                if (start < m_disp_page1) start = m_disp_page1;
                while (start < end) {
                    VPage vpage = m_pages[start];
                    vpage.vEndPage(m_thread);
                    start++;
                }
            }
        } else {
            int start = m_disp_page1;
            int end = m_disp_page2;
            while (start < end) {
                VPage vpage = m_pages[start];
                vpage.vEndPage(m_thread);
                start++;
            }
        }
        m_disp_page1 = pageno1;
        m_disp_page2 = pageno2;
        if (m_listener != null && (pageno1 = vGetPage(m_w / 4, m_h / 4)) != m_pageno)
            m_listener.OnPageChanged(m_pageno = pageno1);
        if (Global.g_cache_enable)
            vFlushCacheRange();
    }

    /**
     * @return width of window
     */
    public final int vGetWidth() {
        return m_w;
    }

    /**
     * @return height of window
     */
    public final int vGetHeight() {
        return m_h;
    }

    /**
     * @return total width of document in view
     */
    public final int vGetTWidth() {
        return m_tw;
    }

    /**
     * @return total height of document in view
     */
    public final int vGetTHeight() {
        return m_th;
    }

    public final float vGetMinScale() {
        return Global.g_auto_scale && m_scales_min != null && m_pageno > -1 ? m_scales_min[m_pageno] : m_scale_min;
    }

    public final float vGetScale() {
        return Global.g_auto_scale && m_scales != null && m_pageno > -1 ? m_scales[m_pageno] : m_scale;
    }

    public final float vGetMaxScale() {
        return m_scale_max;
    }

    @Override
    protected void finalize() throws Throwable {
        vClose();
        super.finalize();
    }
}