package com.radaee.annotui;

import android.content.Context;
import android.graphics.Bitmap;
import android.graphics.Canvas;
import android.graphics.Color;
import android.graphics.Paint;
import android.util.AttributeSet;
import android.view.MotionEvent;
import android.view.View;

import com.radaee.pdf.Document;
import com.radaee.pdf.Matrix;
import com.radaee.pdf.Page;
import com.radaee.pdf.PageContent;

public class UISignView extends View {
    public UISignView(Context context) {
        super(context);
        init();
    }
    public UISignView(Context context, AttributeSet attrs) {
        super(context, attrs);
        init();
    }
    private com.radaee.pdf.Path m_path_r;
    private android.graphics.Path m_path_a;
    private Paint m_paint;
    private Paint m_paint_border;

    private void init()
    {
        m_path_r = new com.radaee.pdf.Path();
        m_path_a = new android.graphics.Path();
        m_paint = new Paint();

        int cBack = Color.BLUE;
        int cBorder = Color.BLACK;

        m_paint.setColor(cBack);
        m_paint.setAlpha(255);
        m_paint.setStyle(Paint.Style.STROKE);
        m_paint.setStrokeWidth(2);
        m_paint.setStrokeJoin(Paint.Join.ROUND);
        m_paint.setStrokeCap(Paint.Cap.ROUND);
        m_paint_border = new Paint();
        m_paint_border.setColor(cBorder);
        m_paint_border.setStyle(Paint.Style.STROKE);
        m_paint_border.setStrokeWidth(1);
    }
    public void SignSetParameter(int color, float width)
    {
        m_paint = new Paint();
        m_paint.setColor(color);
        m_paint.setStyle(Paint.Style.STROKE);
        m_paint.setStrokeWidth(width);
        m_paint.setStrokeJoin(Paint.Join.ROUND);
        m_paint.setStrokeCap(Paint.Cap.ROUND);
        invalidate();
    }
    public com.radaee.pdf.Path SignGetPath()
    {
        return m_path_r;
    }

    public Bitmap SignGetBmp()
    {
        Bitmap bmp = Bitmap.createBitmap(getWidth(), getHeight(), Bitmap.Config.ARGB_8888);
        draw(new Canvas(bmp));
        return bmp;
    }

    public Document.DocForm SignMakeForm(Document doc, Page.Annotation annot)
    {
        if (m_path_a.isEmpty()) return null;
        Document.DocForm form = doc.NewForm();
        PageContent content = new PageContent();
        int iw = getWidth();
        int ih = getHeight();
        content.Create();
        content.GSSave();
        Matrix mat = new Matrix(1, -1, 0, ih);
        content.GSSetMatrix(mat);
        mat.Destroy();
        content.SetStrokeCap(1);
        content.SetStrokeJoin(1);
        content.SetStrokeWidth(m_paint.getStrokeWidth());
        content.SetStrokeColor(m_paint.getColor());
        content.StrokePath(m_path_r);
        content.GSRestore();
        form.SetContent(content, 0, 0, iw, ih);
        content.Destroy();
        return form;
    }
    @Override
    protected void onDraw(Canvas canvas) {
        //super.onDraw(canvas);
        if(m_path_a == null) return;
        canvas.drawColor(-1);
        canvas.drawPath(m_path_a, m_paint);
        canvas.drawRect(1, 1, getWidth(), getHeight(), m_paint_border);
    }

    @Override
    public boolean onTouchEvent(MotionEvent event) {
        float x = event.getX();
        float y = event.getY();
        switch(event.getActionMasked())
        {
            case MotionEvent.ACTION_DOWN:
                m_path_r.MoveTo(x, y);
                m_path_a.moveTo(x, y);
                break;
            case MotionEvent.ACTION_MOVE:
                m_path_r.LineTo(x, y);
                m_path_a.lineTo(x, y);
                invalidate();
                break;
            case MotionEvent.ACTION_UP:
            case MotionEvent.ACTION_CANCEL:
                m_path_r.LineTo(x, y);
                m_path_a.lineTo(x, y);
                invalidate();
                break;
        }
        return true;
    }
}
