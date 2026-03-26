package com.radaee.reader;

import android.content.Context;
import android.graphics.Bitmap;
import android.graphics.Canvas;
import android.graphics.Color;
import android.graphics.Paint;
import android.util.AttributeSet;
import android.view.View;

import androidx.annotation.Nullable;

import com.radaee.pdf.Document;
import com.radaee.pdf.Global;
import com.radaee.pdf.Matrix;
import com.radaee.pdf.Page;

public class PDFGrayView extends View
{
    private Document m_doc;
    private Page m_page;
    private int m_pageno;
    private Bitmap m_bmp;
    private Paint m_paint;
    public PDFGrayView(Context context) {
        super(context);
        init(context);
    }
    public PDFGrayView(Context context, @Nullable AttributeSet attrs) {
        super(context, attrs);
        init(context);
    }
    private void init(Context ctx)
    {
        m_paint = new Paint();
        m_paint.setStyle(Paint.Style.FILL);
        m_paint.setARGB(255, 0, 0, 0);//white
    }
    @Override
    protected void onSizeChanged(int w, int h, int oldw, int oldh) {
        super.onSizeChanged(w, h, oldw, oldh);
        render_page(m_pageno);
        invalidate();
    }
    private void close_page()
    {
        if (m_page != null) m_page.Close();
        m_page = null;
        if (m_bmp != null) m_bmp.recycle();
        m_bmp = null;
    }
    private void render_page(int pageno)
    {
        if (m_doc == null) return;
        int vw = getWidth();
        int vh = getHeight();
        if (vw <=0 || vh <= 0) return;
        close_page();

        m_pageno = pageno;
        m_page = m_doc.GetPage(pageno);
        float pw = m_doc.GetPageWidth(pageno);
        float ph = m_doc.GetPageHeight(pageno);
        float scale1 = (float)vw / pw;
        float scale2 = (float)vh / ph;
        if (scale1 > scale2) scale1 = scale2;

        int bw = (int)(scale1 * pw);
        int bh = (int)(scale1 * ph);
        m_bmp = Bitmap.createBitmap(bw, bh, Bitmap.Config.ALPHA_8);
        Matrix mat = new Matrix(scale1, -scale1, 0, bh);
        m_page.RenderToGrayBmp(m_bmp, mat);
        Global.dither16Grays(m_bmp);
        Global.invertBmp(m_bmp);
        mat.Destroy();
    }

    @Override
    protected void onDraw(Canvas canvas)
    {
        super.onDraw(canvas);
        canvas.drawColor(Color.WHITE);//erase white.
        if (m_bmp == null) return;
        int x = (getWidth() - m_bmp.getWidth()) >> 1;
        int y = (getHeight() - m_bmp.getHeight()) >> 1;
        canvas.drawBitmap(m_bmp, x, y, m_paint);
    }
    public void PDFOpen(Document doc)
    {
        m_doc = doc;
        render_page(0);
        invalidate();
    }
    public void PDFClose()
    {
        close_page();
        m_pageno = 0;
    }
    public void PDFGotoPage(int pageno)
    {
        if (pageno < 0 || pageno > m_doc.GetPageCount() - 1) return;
        render_page(pageno);
        invalidate();
    }
    public void PDFNextPage()
    {
        if (m_pageno > m_doc.GetPageCount() - 2) return;
        render_page(m_pageno + 1);
        invalidate();
    }
    public void PDFPrevPage()
    {
        if (m_pageno < 1) return;
        render_page(m_pageno - 1);
        invalidate();
    }
    @Override
    protected void finalize() throws Throwable {
        close_page();
        super.finalize();
    }
}
