package com.radaee.annotui;

import android.annotation.SuppressLint;
import android.content.Context;
import android.graphics.drawable.ColorDrawable;
import android.util.AttributeSet;
import android.view.LayoutInflater;
import android.view.View;
import android.widget.Button;
import android.widget.RelativeLayout;
import android.widget.SeekBar;
import android.widget.Switch;
import android.widget.TextView;

import com.radaee.viewlib.R;

@SuppressLint("AppCompatCustomView")
public class UIColorButton extends Button {

    private static float POPUP_HEIGHT = 200;
    private static float POPUP_WIDTH = 160;
    private boolean m_enable;
    private boolean m_enable_mode;
    private int m_color = 0xFF000000;
    private int m_color_pop = 0xFF000000;
    private RelativeLayout m_layout;
    private UIAnnotPop m_popup;
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
        m_layout = (RelativeLayout) LayoutInflater.from(getContext()).inflate(R.layout.pop_color, null);
        m_layout.findViewById(R.id.btn_ok).setOnClickListener(new OnClickListener() {
            @Override
            public void onClick(View v) {
                Switch tog_enable = m_layout.findViewById(R.id.tog_enable);
                m_enable = tog_enable.isChecked();
                if (m_enable) {
                    m_color = m_color_pop;
                    setBackgroundColor(m_color);
                    setText("");
                } else {
                    m_color = 0xFF000000;
                    m_color_pop = 0xFF000000;
                    setBackgroundColor(m_color);
                    setText("Disabled");
                }
                m_popup.dismiss();
            }
        });
        m_layout.findViewById(R.id.btn_cancel).setOnClickListener(new OnClickListener() {
            @Override
            public void onClick(View v) {
                m_popup.dismiss();
            }
        });

        SeekBar seek_r = m_layout.findViewById(R.id.seek_clr_r);
        SeekBar seek_g = m_layout.findViewById(R.id.seek_clr_g);
        SeekBar seek_b = m_layout.findViewById(R.id.seek_clr_b);

        seek_r.setMax(255);
        seek_r.setOnSeekBarChangeListener(new SeekBar.OnSeekBarChangeListener() {
            @Override
            public void onProgressChanged(SeekBar seekBar, int progress, boolean fromUser) {
                m_color_pop = (m_color_pop & 0xFF00FFFF) | (progress << 16);
                m_layout.setBackgroundColor(m_color_pop);
            }

            @Override
            public void onStartTrackingTouch(SeekBar seekBar) {
            }

            @Override
            public void onStopTrackingTouch(SeekBar seekBar) {
            }
        });
        seek_g.setMax(255);
        seek_g.setOnSeekBarChangeListener(new SeekBar.OnSeekBarChangeListener() {
            @Override
            public void onProgressChanged(SeekBar seekBar, int progress, boolean fromUser) {
                m_color_pop = (m_color_pop & 0xFFFF00FF) | (progress << 8);
                m_layout.setBackgroundColor(m_color_pop);
            }

            @Override
            public void onStartTrackingTouch(SeekBar seekBar) {
            }

            @Override
            public void onStopTrackingTouch(SeekBar seekBar) {
            }
        });
        seek_b.setMax(255);
        seek_b.setOnSeekBarChangeListener(new SeekBar.OnSeekBarChangeListener() {
            @Override
            public void onProgressChanged(SeekBar seekBar, int progress, boolean fromUser) {
                m_color_pop = (m_color_pop & 0xFFFFFF00) | progress;
                m_layout.setBackgroundColor(m_color_pop);
            }

            @Override
            public void onStartTrackingTouch(SeekBar seekBar) {
            }

            @Override
            public void onStopTrackingTouch(SeekBar seekBar) {
            }
        });

        m_popup = new UIAnnotPop(m_layout, Dp2Px(POPUP_WIDTH), Dp2Px(POPUP_HEIGHT));
        m_popup.setFocusable(true);
        m_popup.setTouchable(true);
        m_popup.setBackgroundDrawable(new ColorDrawable(0));
        setOnClickListener(new OnClickListener() {
            @Override
            public void onClick(View v) {
                if (!m_popup.isShowing()) {
                    int[] location = new int[2];
                    UIColorButton.this.getLocationInWindow(location);
                    Switch tog_enable = m_layout.findViewById(R.id.tog_enable);
                    tog_enable.setChecked(m_enable);
                    if (m_enable_mode) {
                        tog_enable.setVisibility(View.GONE);
                        TextView txt_enable = m_layout.findViewById(R.id.txt_enable);
                        txt_enable.setVisibility(View.GONE);
                        m_popup.setHeight(Dp2Px(POPUP_HEIGHT - 30));
                    }

                    m_layout.setBackgroundColor(m_color);
                    m_color_pop = m_color;
                    SeekBar seek_r = m_layout.findViewById(R.id.seek_clr_r);
                    SeekBar seek_g = m_layout.findViewById(R.id.seek_clr_g);
                    SeekBar seek_b = m_layout.findViewById(R.id.seek_clr_b);
                    seek_r.setProgress((m_color >> 16) & 255);
                    seek_g.setProgress((m_color >> 8) & 255);
                    seek_b.setProgress(m_color & 255);
                    m_popup.show(UIColorButton.this, location[0] + UIColorButton.this.getWidth() + Dp2Px(10), location[1]);
                }
            }
        });
    }

    public UIColorButton(Context context) {
        super(context);
        init();
    }

    public UIColorButton(Context context, AttributeSet attrs) {
        super(context, attrs);
        init();
    }

    public void setColor(int color) {
        m_color = color;
        m_color_pop = color;
        setBackgroundColor(m_color);
    }

    public int getColor() {
        return m_color;
    }

    public void setColorEnable(boolean enable) {
        m_enable = enable;
    }

    public boolean getColorEnable() {
        return m_enable;
    }

    public void setColorMode(boolean mode) {
        m_enable_mode = mode;
    }
}