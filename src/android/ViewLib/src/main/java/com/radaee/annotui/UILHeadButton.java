package com.radaee.annotui;

import android.annotation.SuppressLint;
import android.content.Context;
import android.graphics.Canvas;
import android.graphics.Paint;
import android.graphics.Path;
import android.graphics.RectF;
import android.graphics.drawable.ColorDrawable;
import android.util.AttributeSet;
import android.view.LayoutInflater;
import android.view.View;
import android.widget.Button;
import android.widget.LinearLayout;

import com.radaee.viewlib.R;

@SuppressLint("AppCompatCustomView")
public class UILHeadButton extends Button {
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
    private LinearLayout m_layout;
    private UIAnnotPop m_popup;
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

        m_layout = (LinearLayout) LayoutInflater.from(getContext()).inflate(R.layout.pop_lhead, null);
        OnClickListener listener = new OnClickListener() {
            @Override
            public void onClick(View v) {
                setStyle(((UILHeadView)v).getStyle());
                m_popup.dismiss();
            }
        };
        UILHeadView vw_lhead = m_layout.findViewById(R.id.vw_lhead0);
        vw_lhead.setOnClickListener(listener);

        vw_lhead = m_layout.findViewById(R.id.vw_lhead1);
        vw_lhead.setStyle(1);
        vw_lhead.setOnClickListener(listener);

        vw_lhead = m_layout.findViewById(R.id.vw_lhead2);
        vw_lhead.setStyle(2);
        vw_lhead.setOnClickListener(listener);

        vw_lhead = m_layout.findViewById(R.id.vw_lhead3);
        vw_lhead.setStyle(3);
        vw_lhead.setOnClickListener(listener);

        vw_lhead = m_layout.findViewById(R.id.vw_lhead4);
        vw_lhead.setStyle(4);
        vw_lhead.setOnClickListener(listener);

        vw_lhead = m_layout.findViewById(R.id.vw_lhead5);
        vw_lhead.setStyle(5);
        vw_lhead.setOnClickListener(listener);

        vw_lhead = m_layout.findViewById(R.id.vw_lhead6);
        vw_lhead.setStyle(6);
        vw_lhead.setOnClickListener(listener);

        vw_lhead = m_layout.findViewById(R.id.vw_lhead7);
        vw_lhead.setStyle(7);
        vw_lhead.setOnClickListener(listener);

        vw_lhead = m_layout.findViewById(R.id.vw_lhead8);
        vw_lhead.setStyle(8);
        vw_lhead.setOnClickListener(listener);

        vw_lhead = m_layout.findViewById(R.id.vw_lhead9);
        vw_lhead.setStyle(9);
        vw_lhead.setOnClickListener(listener);

        m_popup = new UIAnnotPop(m_layout, Dp2Px(90), Dp2Px(m_layout.getChildCount() * 25));
        m_popup.setFocusable(true);
        m_popup.setTouchable(true);
        m_popup.setBackgroundDrawable(new ColorDrawable(0));
        setOnClickListener(new OnClickListener() {
            @Override
            public void onClick(View v) {
                if(!m_popup.isShowing())
                {
                    int[] location = new int[2];
                    UILHeadButton.this.getLocationInWindow(location);
                    //m_popup.show(UIColorButton.this, location[0], location[1] - Dp2Px(20));
                    m_popup.show(UILHeadButton.this, location[0] + UILHeadButton.this.getWidth() + Dp2Px(10), location[1]);
                }
            }
        });
    }
    public UILHeadButton(Context context) {
        super(context);
        init();
    }
    public UILHeadButton(Context context, AttributeSet attrs) {
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