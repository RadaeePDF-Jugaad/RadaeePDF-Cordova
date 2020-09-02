package com.radaee.annotui;

import android.content.Context;
import android.graphics.Bitmap;
import android.graphics.Canvas;
import android.graphics.RectF;
import android.graphics.drawable.ColorDrawable;
import android.util.AttributeSet;
import android.view.LayoutInflater;
import android.view.View;
import android.widget.Button;
import android.widget.ImageView;
import android.widget.LinearLayout;

import com.radaee.pdf.Global;
import com.radaee.pdf.Page;
import com.radaee.viewlib.R;

public class UIIconButton extends Button {
    public UIIconButton(Context context) {
        super(context);
    }
    public UIIconButton(Context context, AttributeSet attrs) {
        super(context, attrs);
    }
    private static float ms_density = -1;
    private int Dp2Px(float dp) {
        if(ms_density < 0) ms_density = getContext().getResources().getDisplayMetrics().density;
        return (int) (dp * ms_density + 0.5f);
    }

    private int Px2Dp(float px) {
        if(ms_density < 0) ms_density = getContext().getResources().getDisplayMetrics().density;
        return (int) (px / ms_density + 0.5f);
    }
    private LinearLayout m_layout;
    private UIAnnotPop m_popup;
    private void init_text()
    {
        setIcon(0);
        setBackgroundColor(-1);

        m_layout = (LinearLayout) LayoutInflater.from(getContext()).inflate(R.layout.pop_icon_text, null);
        OnClickListener listener = new OnClickListener() {
            @Override
            public void onClick(View v) {
                setIcon((Integer)v.getTag());
                m_popup.dismiss();
            }
        };

        ImageView vw_icon;
        LinearLayout vw_item;
        vw_icon = m_layout.findViewById(R.id.img_00);
        setIcon(vw_icon, 0);
        vw_item = m_layout.findViewById(R.id.view_00);
        vw_item.setTag(new Integer(0));
        vw_item.setOnClickListener(listener);

        vw_icon = m_layout.findViewById(R.id.img_01);
        setIcon(vw_icon, 1);
        vw_item = m_layout.findViewById(R.id.view_01);
        vw_item.setTag(new Integer(1));
        vw_item.setOnClickListener(listener);

        vw_icon = m_layout.findViewById(R.id.img_02);
        setIcon(vw_icon, 2);
        vw_item = m_layout.findViewById(R.id.view_02);
        vw_item.setTag(new Integer(2));
        vw_item.setOnClickListener(listener);

        vw_icon = m_layout.findViewById(R.id.img_03);
        setIcon(vw_icon, 3);
        vw_item = m_layout.findViewById(R.id.view_03);
        vw_item.setTag(new Integer(3));
        vw_item.setOnClickListener(listener);

        vw_icon = m_layout.findViewById(R.id.img_04);
        setIcon(vw_icon, 4);
        vw_item = m_layout.findViewById(R.id.view_04);
        vw_item.setTag(new Integer(4));
        vw_item.setOnClickListener(listener);

        vw_icon = m_layout.findViewById(R.id.img_05);
        setIcon(vw_icon, 5);
        vw_item = m_layout.findViewById(R.id.view_05);
        vw_item.setTag(new Integer(5));
        vw_item.setOnClickListener(listener);

        vw_icon = m_layout.findViewById(R.id.img_06);
        setIcon(vw_icon, 6);
        vw_item = m_layout.findViewById(R.id.view_06);
        vw_item.setTag(new Integer(6));
        vw_item.setOnClickListener(listener);

        vw_icon = m_layout.findViewById(R.id.img_07);
        setIcon(vw_icon, 7);
        vw_item = m_layout.findViewById(R.id.view_07);
        vw_item.setTag(new Integer(7));
        vw_item.setOnClickListener(listener);

        vw_icon = m_layout.findViewById(R.id.img_08);
        setIcon(vw_icon, 8);
        vw_item = m_layout.findViewById(R.id.view_08);
        vw_item.setTag(new Integer(8));
        vw_item.setOnClickListener(listener);

        vw_icon = m_layout.findViewById(R.id.img_09);
        setIcon(vw_icon, 9);
        vw_item = m_layout.findViewById(R.id.view_09);
        vw_item.setTag(new Integer(9));
        vw_item.setOnClickListener(listener);

        vw_icon = m_layout.findViewById(R.id.img_10);
        setIcon(vw_icon, 10);
        vw_item = m_layout.findViewById(R.id.view_10);
        vw_item.setTag(new Integer(10));
        vw_item.setOnClickListener(listener);

        vw_icon = m_layout.findViewById(R.id.img_11);
        setIcon(vw_icon, 11);
        vw_item = m_layout.findViewById(R.id.view_11);
        vw_item.setTag(new Integer(11));
        vw_item.setOnClickListener(listener);

        vw_icon = m_layout.findViewById(R.id.img_12);
        setIcon(vw_icon, 12);
        vw_item = m_layout.findViewById(R.id.view_12);
        vw_item.setTag(new Integer(12));
        vw_item.setOnClickListener(listener);

        vw_icon = m_layout.findViewById(R.id.img_13);
        setIcon(vw_icon, 13);
        vw_item = m_layout.findViewById(R.id.view_13);
        vw_item.setTag(new Integer(13));
        vw_item.setOnClickListener(listener);

        vw_icon = m_layout.findViewById(R.id.img_14);
        setIcon(vw_icon, 14);
        vw_item = m_layout.findViewById(R.id.view_14);
        vw_item.setTag(new Integer(14));
        vw_item.setOnClickListener(listener);

        vw_icon = m_layout.findViewById(R.id.img_15);
        setIcon(vw_icon, 15);
        vw_item = m_layout.findViewById(R.id.view_15);
        vw_item.setTag(new Integer(15));
        vw_item.setOnClickListener(listener);

        m_popup = new UIAnnotPop(m_layout, Dp2Px(140), Dp2Px(m_layout.getChildCount() * 20) + Dp2Px(20));
        m_popup.setFocusable(true);
        m_popup.setTouchable(true);
        m_popup.setBackgroundDrawable(new ColorDrawable(0));
        setOnClickListener(new OnClickListener() {
            @Override
            public void onClick(View v) {
                if(!m_popup.isShowing())
                {
                    int[] location = new int[2];
                    UIIconButton.this.getLocationInWindow(location);
                    //m_popup.show(UIColorButton.this, location[0], location[1] - Dp2Px(20));
                    m_popup.show(UIIconButton.this, location[0] + UIIconButton.this.getWidth() + Dp2Px(20), location[1]);
                }
            }
        });
    }
    private void init_attach()
    {
        setIcon(0);
        setBackgroundColor(-1);

        m_layout = (LinearLayout) LayoutInflater.from(getContext()).inflate(R.layout.pop_icon_attach, null);
        OnClickListener listener = new OnClickListener() {
            @Override
            public void onClick(View v) {
                setIcon((Integer)v.getTag());
                m_popup.dismiss();
            }
        };

        ImageView vw_icon;
        LinearLayout vw_item;
        vw_icon = m_layout.findViewById(R.id.img_00);
        setIcon(vw_icon, 0);
        vw_item = m_layout.findViewById(R.id.view_00);
        vw_item.setTag(new Integer(0));
        vw_item.setOnClickListener(listener);

        vw_icon = m_layout.findViewById(R.id.img_01);
        setIcon(vw_icon, 1);
        vw_item = m_layout.findViewById(R.id.view_01);
        vw_item.setTag(new Integer(1));
        vw_item.setOnClickListener(listener);

        vw_icon = m_layout.findViewById(R.id.img_02);
        setIcon(vw_icon, 2);
        vw_item = m_layout.findViewById(R.id.view_02);
        vw_item.setTag(new Integer(2));
        vw_item.setOnClickListener(listener);

        vw_icon = m_layout.findViewById(R.id.img_03);
        setIcon(vw_icon, 3);
        vw_item = m_layout.findViewById(R.id.view_03);
        vw_item.setTag(new Integer(3));
        vw_item.setOnClickListener(listener);

        m_popup = new UIAnnotPop(m_layout, Dp2Px(160), Dp2Px(m_layout.getChildCount() * 24));
        m_popup.setFocusable(true);
        m_popup.setTouchable(true);
        m_popup.setBackgroundDrawable(new ColorDrawable(0));
        setOnClickListener(new OnClickListener() {
            @Override
            public void onClick(View v) {
                if(!m_popup.isShowing())
                {
                    int[] location = new int[2];
                    UIIconButton.this.getLocationInWindow(location);
                    //m_popup.show(UIColorButton.this, location[0], location[1] - Dp2Px(20));
                    m_popup.show(UIIconButton.this, location[0] + UIIconButton.this.getWidth() + Dp2Px(20), location[1]);
                }
            }
        });
    }
    private void setIcon(ImageView iview, int icon)
    {
        Bitmap bmp = Bitmap.createBitmap(48, 48, Bitmap.Config.ARGB_8888);
        bmp.eraseColor(-1);
        Global.drawAnnotIcon(m_atype, icon, bmp);
        iview.setImageBitmap(bmp);
    }
    private int m_icon;
    private int m_atype;
    private Bitmap m_bmp;
    public void load(Page.Annotation annot)
    {
        m_atype = annot.GetType();
        if(m_atype == 1) init_text();
        else if(m_atype == 17) init_attach();
    }
    public int getIcon()
    {
        return m_icon;
    }
    public void setIcon(int icon)
    {
        m_icon = icon;
        m_bmp = Bitmap.createBitmap(48, 48, Bitmap.Config.ARGB_8888);
        m_bmp.eraseColor(-1);
        Global.drawAnnotIcon(m_atype, m_icon, m_bmp);

        invalidate();
    }
    protected void onDraw(Canvas canvas)
    {
        if(m_bmp != null)
            canvas.drawBitmap(m_bmp, null, new RectF(0, 0, getWidth(), getHeight()), null);
    }
}