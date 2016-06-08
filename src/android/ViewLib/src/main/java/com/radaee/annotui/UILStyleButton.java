package com.radaee.annotui;

import android.annotation.SuppressLint;
import android.content.Context;
import android.graphics.Canvas;
import android.graphics.DashPathEffect;
import android.graphics.Paint;
import android.graphics.Path;
import android.graphics.drawable.ColorDrawable;
import androidx.annotation.Nullable;
import android.util.AttributeSet;
import android.view.LayoutInflater;
import android.view.View;
import android.widget.Button;
import android.widget.LinearLayout;

import com.radaee.viewlib.R;

@SuppressLint("AppCompatCustomView")
public class UILStyleButton extends Button {
    private static float ms_density = -1;

    private int Dp2Px(float dp) {
        if (ms_density < 0) ms_density = getContext().getResources().getDisplayMetrics().density;
        return (int) (dp * ms_density + 0.5f);
    }

    private int Px2Dp(float px) {
        if (ms_density < 0) ms_density = getContext().getResources().getDisplayMetrics().density;
        return (int) (px / ms_density + 0.5f);
    }

    private LinearLayout m_layout;
    private UIAnnotPop m_popup;

    private void init() {
        setDash(null);
        setBackgroundColor(-1);

        m_layout = (LinearLayout) LayoutInflater.from(getContext()).inflate(R.layout.pop_lstyle, null);
        OnClickListener listener = new OnClickListener() {
            @Override
            public void onClick(View v) {
                setDash(((UILStyleView) v).getDash());
                m_popup.dismiss();
            }
        };

        UILStyleView vw_lstyle = m_layout.findViewById(R.id.vw_lsolid);
        vw_lstyle.setOnClickListener(listener);

        vw_lstyle = m_layout.findViewById(R.id.vw_ldash11);
        vw_lstyle.setDash(new float[]{1, 1});
        vw_lstyle.setOnClickListener(listener);

        vw_lstyle = m_layout.findViewById(R.id.vw_ldash22);
        vw_lstyle.setDash(new float[]{2, 2});
        vw_lstyle.setOnClickListener(listener);

        vw_lstyle = m_layout.findViewById(R.id.vw_ldash44);
        vw_lstyle.setDash(new float[]{4, 4});
        vw_lstyle.setOnClickListener(listener);

        vw_lstyle = m_layout.findViewById(R.id.vw_ldash4222);
        vw_lstyle.setDash(new float[]{4, 2, 2, 2});
        vw_lstyle.setOnClickListener(listener);

        vw_lstyle = m_layout.findViewById(R.id.vw_ldash16242);
        vw_lstyle.setDash(new float[]{16, 2, 4, 2});
        vw_lstyle.setOnClickListener(listener);

        m_popup = new UIAnnotPop(m_layout, Dp2Px(90), Dp2Px(m_layout.getChildCount() * 25));
        m_popup.setFocusable(true);
        m_popup.setTouchable(true);
        m_popup.setBackgroundDrawable(new ColorDrawable(0));
        setOnClickListener(new OnClickListener() {
            @Override
            public void onClick(View v) {
                if (!m_popup.isShowing()) {
                    int[] location = new int[2];
                    UILStyleButton.this.getLocationInWindow(location);
                    m_popup.show(UILStyleButton.this, location[0] + UILStyleButton.this.getWidth() + Dp2Px(10), location[1]);
                }
            }
        });
    }

    public UILStyleButton(Context context) {
        super(context);
        init();
    }

    public UILStyleButton(Context context, @Nullable AttributeSet attrs) {
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