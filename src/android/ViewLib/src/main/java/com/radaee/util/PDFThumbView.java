package com.radaee.util;

import android.content.Context;
import android.graphics.Bitmap;
import android.graphics.Canvas;
import android.graphics.Paint;
import android.graphics.Paint.Align;
import android.util.AttributeSet;
import android.view.MotionEvent;
import android.view.View;
import android.view.ViewGroup;

import com.radaee.pdf.Document;
import com.radaee.pdf.Global;
import com.radaee.view.PDFVPage;
import com.radaee.view.PDFView.PDFViewListener;
import com.radaee.view.PDFViewThumb;
import com.radaee.view.PDFViewThumb.PDFThumbListener;

public class PDFThumbView extends View implements PDFViewListener {

    protected PDFViewThumb m_thumb;

    public PDFThumbView(Context context, AttributeSet attrs) {
        super(context, attrs);

        m_thumb = new PDFViewThumb(context);
    }

    @Override
    public void OnPDFPageRendered(int pageno) {
    }

    public void OnPDFPageChanged(int pageno) {
    }

    public boolean OnPDFDoubleTapped(float x, float y) {
        return false;
    }

    public boolean OnPDFSingleTapped(float x, float y) {
        return false;
    }

    public void OnPDFLongPressed(float x, float y) {
    }

    public void OnPDFShowPressed(float x, float y) {
    }

    public void OnPDFSelectEnd() {
    }

    public void OnPDFFound(boolean found) {
    }

    public void OnPDFInvalidate(boolean post) {
        if (!isShown()) return;
        postInvalidate();
    }

    @Override
    public void computeScroll() {
        if (m_thumb != null)
            m_thumb.vComputeScroll();
    }

    @Override
    protected void onDraw(Canvas canvas) {
        if (m_thumb != null) {
            m_thumb.vDraw(canvas);
        }
    }

    @Override
    protected void onSizeChanged(int w, int h, int oldw, int oldh) {
        if (m_thumb != null)
            m_thumb.vResize(w, h);
    }

    @Override
    public boolean onTouchEvent(MotionEvent event) {
        return m_thumb != null && m_thumb.vTouchEvent(event);
    }

    private Document m_doc;
    private int m_gap;
    private int m_bgColor;
    private int m_orientation;
    PDFThumbListener m_listener;
    public void thumbOpen(Document doc, PDFThumbListener listener, boolean isRTL) {
        if (Global.g_thumbview_height > 0) { //added to support configurable height
            ViewGroup.LayoutParams params = getLayoutParams();
            params.height = (int) (Global.g_thumbview_height * getContext().getResources().getDisplayMetrics().density);
            setLayoutParams(params);
        }
        if (isRTL)
        {
            m_orientation = 2;
            m_thumb.vSetOrientation(2);//RTOL horizontal layout
        }
        m_thumb.vOpen(doc, 8, Global.g_thumbview_bg_color, this);
        m_listener = listener;
        m_thumb.vSetThumbListener(listener);
        m_thumb.vResize(getWidth(), getHeight());
        m_doc = doc;
        m_gap = 8;
        m_bgColor = Global.g_thumbview_bg_color;
    }

    public void thumbOpen( Document doc, PDFThumbListener listener, int thumbHeight, int orientation, int bgColor, int gap) {
        m_orientation = orientation;
        m_doc = doc;
        m_gap = gap;
        m_bgColor = bgColor;
        m_thumb.vSetOrientation(orientation);
        m_thumb.setThumbHeight(thumbHeight);
        m_thumb.vOpen(doc, gap, bgColor, this);
        m_listener = listener;
        m_thumb.vSetThumbListener(listener);
        m_thumb.vResize(getWidth(), getHeight());
    }

    public void thumbClose()
    {
        if (m_thumb != null) {
            m_thumb.vClose();
        }
    }
    public void thumbSave()
    {
        if (m_thumb != null) {
            m_thumb.vClose();
        }
    }
    public void thumbRestore()
    {
        m_thumb.vSetOrientation(m_orientation);
        m_thumb.vOpen(m_doc, m_gap, m_bgColor, this);
        m_thumb.vSetThumbListener(m_listener);
        m_thumb.vResize(getWidth(), getHeight());
        invalidate();
    }

    /**
     * set selected page and goto the page
     *
     * @param pageno 0 based page NO.
     */
    public void thumbGotoPage(int pageno) {
        m_thumb.vSetSel(pageno, isShown());
    }

    /**
     * render a page again, after page is edited.
     *
     * @param pageno 0 based page NO.
     */
    public void thumbUpdatePage(int pageno) {
        m_thumb.vRenderAsync(m_thumb.vGetPage(pageno));
    }

    public void thumbSetBmpFormat(Bitmap.Config format) {
        m_thumb.vSetBmpFormat(format);
    }

    private final Paint m_paint = new Paint();

    public void OnPDFPageDisplayed(Canvas canvas, PDFVPage vpage) {
        if (!Global.g_display_pageno_on_thumbnail) return;
        m_paint.setColor(0x800000FF);
        int top = vpage.GetVY(m_thumb.vGetY());
        int bottom = top + vpage.GetHeight();
        int left = vpage.GetVX(m_thumb.vGetX());
        int right = left + vpage.GetWidth();
        if (m_thumb.vGetOrientation() == 1)//vertical
            m_paint.setTextSize(m_thumb.vGetWinW() * 0.2f);
        else if(m_thumb.vGetOrientation() == 3) //grid
            m_paint.setTextSize(m_thumb.getThumbHeight() * 0.2f);
        else
            m_paint.setTextSize(m_thumb.vGetWinH() * 0.2f);
        m_paint.setTextAlign(Align.CENTER);
        canvas.drawText(String.valueOf(vpage.GetPageNo() + 1),
                (left + right) * 0.5f, (top + bottom) * 0.5f, m_paint);
    }

    public void OnPDFSelecting(Canvas canvas, int[] rect1, int[] rect2) {}

    @Override
    public void OnPDFZoomStart() {}

    @Override
    public void OnPDFZoomEnd() {}

    @Override
    protected void finalize() throws Throwable {
        if (m_thumb != null) {
            m_thumb.vClose();
            m_thumb = null;
        }
        super.finalize();
    }
}
