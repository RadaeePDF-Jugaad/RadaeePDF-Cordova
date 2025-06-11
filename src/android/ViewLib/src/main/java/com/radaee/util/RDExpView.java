package com.radaee.util;

import android.content.Context;
import android.content.res.Resources;
import android.graphics.Canvas;
import android.graphics.Paint;
import android.util.AttributeSet;
import android.view.View;

import androidx.annotation.Nullable;

import com.radaee.viewlib.R;

public class RDExpView extends View
{
    private boolean m_collepse;
    private static Paint m_paint;
    private static int dp2px(Context context, float dpValue) {
        return (int)(dpValue * context.getResources().getDisplayMetrics().density);
    }
    public RDExpView(Context context, @Nullable AttributeSet attrs) {
        super(context, attrs);
        m_collepse = false;
        if (m_paint == null)
        {
            m_paint = new Paint();
            m_paint.setStyle(Paint.Style.STROKE);
            m_paint.setStrokeCap(Paint.Cap.BUTT);
            Resources res = getResources();
            int color = res.getColor(R.color.tab_text_color);
            m_paint.setColor(color);
            m_paint.setStrokeWidth(dp2px(context, 1.6f));
        }
    }
    @Override
    protected void onDraw(Canvas canvas) {
        //super.onDraw(canvas);
        int vw = getWidth();
        int vh = getHeight();
        int gapx = (vw >> 2);
        int gapy = (vh >> 2);
        if (m_collepse)//draw '+'
        {
            canvas.drawLine(vw >> 1, gapy, vw >> 1, vh - gapy, m_paint);
        }
        //draw '-'
        canvas.drawLine(gapx, vh >> 1, vw - gapx, vh >> 1, m_paint );
        canvas.drawRect(gapx >> 1, gapy >> 1, vw - (gapx >> 1), vh - (gapy >> 1), m_paint);
    }
    public void RDSwap()
    {
        m_collepse = !m_collepse;
        invalidate();
    }
    public boolean RDIsExp()
    {
        return !m_collepse;
    }
}
