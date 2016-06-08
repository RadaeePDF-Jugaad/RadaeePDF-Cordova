package com.radaee.annotui;

import android.content.Context;
import android.graphics.Canvas;
import android.graphics.DashPathEffect;
import android.graphics.Paint;
import android.graphics.Path;
import androidx.annotation.Nullable;
import android.util.AttributeSet;
import android.view.View;

public class UILStyleView extends View {
    private static float ms_density = -1;

    private int Dp2Px(float dp) {
        if (ms_density < 0) ms_density = getContext().getResources().getDisplayMetrics().density;
        return (int) (dp * ms_density + 0.5f);
    }

    private int Px2Dp(float px) {
        if (ms_density < 0) ms_density = getContext().getResources().getDisplayMetrics().density;
        return (int) (px / ms_density + 0.5f);
    }

    private void init() {
        setDash(null);
        setBackgroundColor(-1);
    }

    public UILStyleView(Context context) {
        super(context);
        init();
    }

    public UILStyleView(Context context, @Nullable AttributeSet attrs) {
        super(context, attrs);
        init();
    }

    private Path mPath;
    private Paint m_paint;
    private float[] m_dashs_org;

    protected void setDash(float[] dashs) {
        m_dashs_org = dashs;
        mPath = new Path();
        m_paint = new Paint();
        m_paint.setStyle(Paint.Style.STROKE);
        if (dashs != null && dashs.length > 0) {
            float[] m_dashs_draw = new float[dashs.length];
            float scale = Dp2Px(1);
            for (int i = 0; i < dashs.length; i++)
                m_dashs_draw[i] = dashs[i] * scale;
            m_paint.setPathEffect(new DashPathEffect(m_dashs_draw, 0));
        }
        m_paint.setStrokeWidth(Dp2Px(1));
        m_paint.setColor(0xFF000000);
        invalidate();
    }

    protected float[] getDash() {
        return m_dashs_org;
    }

    protected void onDraw(Canvas canvas) {
        float lw = Dp2Px(1);
        float right = getWidth() - lw;
        float y = getHeight() * 0.5f;
        mPath.moveTo(lw, y);
        mPath.quadTo(lw, y, right, y);
        canvas.drawPath(mPath, m_paint);
    }
}