package com.radaee.reader;

import android.annotation.SuppressLint;
import androidx.annotation.Nullable;
import android.content.Context;
import android.graphics.Canvas;
import android.util.AttributeSet;
import android.view.View;

public class GLCanvas extends View
{
    public interface CanvasListener
    {
        void drawLayer(Canvas canvas);
    }
    private CanvasListener m_listener;
    public GLCanvas(Context context, @Nullable AttributeSet attrs, int defStyleAttr) {
        super(context, attrs, defStyleAttr);
        init(context);
    }
    public GLCanvas(Context context, @Nullable AttributeSet attrs) {
        super(context, attrs);
        init(context);
    }
    public GLCanvas(Context context) {
        super(context);
        init(context);
    }
    private void init(Context context)
    {
    }
    public void vOpen(CanvasListener listener)
    {
        m_listener = listener;
    }
    @SuppressLint("MissingSuperCall")
    @Override
    public void draw(Canvas canvas)
    {
        if(m_listener != null) m_listener.drawLayer(canvas);
    }
}
