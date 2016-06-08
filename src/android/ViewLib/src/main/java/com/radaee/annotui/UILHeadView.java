package com.radaee.annotui;

import android.content.Context;
import android.graphics.Canvas;
import android.graphics.Paint;
import android.graphics.Path;
import android.graphics.RectF;
import android.util.AttributeSet;
import android.view.View;

public class UILHeadView extends View {
    private int m_style;
    private static float ms_density = -1;
    private int Dp2Px(float dp) {
        if(ms_density < 0) ms_density = getContext().getResources().getDisplayMetrics().density;
        return (int) (dp * ms_density + 0.5f);
    }

    private int Px2Dp(float px) {
        if(ms_density < 0) ms_density = getContext().getResources().getDisplayMetrics().density;
        return (int) (px / ms_density + 0.5f);
    }
    private Paint m_paint_stroke;
    private Paint m_paint_fill;
    private void init()
    {
        setBackgroundColor(-1);
        m_paint_stroke = new Paint();
        m_paint_stroke.setStyle(Paint.Style.STROKE);
        m_paint_stroke.setStrokeWidth(Dp2Px(1));
        m_paint_stroke.setColor(0xFF000000);

        m_paint_fill = new Paint();
        m_paint_fill.setStyle(Paint.Style.FILL);
        m_paint_fill.setColor(0xFF808080);
    }
    public UILHeadView(Context context) {
        super(context);
        init();
    }
    public UILHeadView(Context context, AttributeSet attrs) {
        super(context, attrs);
        init();
    }
    protected void onDraw(Canvas canvas)
    {
        float lw = Dp2Px(1);
        float left = lw * 8;
        float right = getWidth() - lw;
        float y = getHeight() * 0.5f;
        canvas.drawLine(left, y, right, y, m_paint_stroke);
        Path path = new Path();
        RectF rect;
        switch(m_style)
        {
            case 1://OpenArrow
                canvas.drawLine(left + Dp2Px(1.732f * 5), y - Dp2Px(0.5f * 5), left, y, m_paint_stroke);
                canvas.drawLine(left, y, left + Dp2Px(1.732f * 5), y + Dp2Px(0.5f * 5), m_paint_stroke);
                break;
            case 2://ClosedArrow
                path.moveTo(left + Dp2Px(1.732f * 5), y - Dp2Px(0.5f * 5));
                path.lineTo(left, y);
                path.lineTo(left + Dp2Px(1.732f * 5), y + Dp2Px(0.5f * 5));
                path.close();
                canvas.drawPath(path, m_paint_fill);
                canvas.drawPath(path, m_paint_stroke);
                break;
            case 3://Square
                rect = new RectF(left - Dp2Px(1 * 5), y - Dp2Px(1 * 5), left + Dp2Px(1 * 5), y + Dp2Px(1 * 5));
                canvas.drawRect(rect, m_paint_fill);
                canvas.drawRect(rect, m_paint_stroke);
                break;
            case 4://Circle
                canvas.drawCircle(left, y, Dp2Px(1 * 5), m_paint_fill);
                canvas.drawCircle(left, y, Dp2Px(1 * 5), m_paint_stroke);
                break;
            case 5://Butt
                canvas.drawLine(left, y - Dp2Px(1 * 5), left, y + Dp2Px(1 * 5), m_paint_stroke);
                break;
            case 6://Diamond
                path.moveTo(left - Dp2Px(0.707f * 5), y);
                path.lineTo(left, y - Dp2Px(0.707f * 5));
                path.lineTo(left + Dp2Px(0.707f * 5), y);
                path.lineTo(left, y + Dp2Px(0.707f * 5));
                path.close();
                canvas.drawPath(path, m_paint_fill);
                canvas.drawPath(path, m_paint_stroke);
                break;
            case 7://ROpenArrow
                canvas.drawLine(left - Dp2Px(1.732f * 5), y - Dp2Px(0.5f * 5), left, y, m_paint_stroke);
                canvas.drawLine(left, y, left - Dp2Px(1.732f * 5), y + Dp2Px(0.5f * 5), m_paint_stroke);
                break;
            case 8://RClosedArrow
                path.moveTo(left - Dp2Px(1.732f * 5), y - Dp2Px(0.5f * 5));
                path.lineTo(left, y);
                path.lineTo(left - Dp2Px(1.732f * 5), y + Dp2Px(0.5f * 5));
                path.close();
                canvas.drawPath(path, m_paint_fill);
                canvas.drawPath(path, m_paint_stroke);
                break;
            case 9://Slash
                canvas.drawLine(left + Dp2Px(0.5f * 5), y - Dp2Px(0.866f * 5), left - Dp2Px(0.5f * 5), y + Dp2Px(0.866f * 5), m_paint_stroke);
                break;
            default:
                break;
        }
    }
    protected void setStyle(int style)
    {
        m_style = style;
        invalidate();
    }
    protected int getStyle()
    {
        return m_style;
    }
}
