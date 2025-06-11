package com.radaee.annotui;

import android.view.LayoutInflater;
import android.view.View;
import android.widget.ImageButton;
import android.widget.LinearLayout;
import android.widget.RelativeLayout;

import com.radaee.pdf.Page;
import com.radaee.viewlib.R;

public class UIAnnotMenu {

    private final LinearLayout m_view;
    private Page.Annotation m_annot;
    private Boolean m_has_perform;
    private Boolean m_has_edit;
    private Boolean m_has_remove;
    private Boolean m_has_property;
    private static float ms_density = -1;

    public interface IMemnuCallback {
        void onUpdate();

        void onRemove();

        void onPerform();

        void onCancel();
    }

    private IMemnuCallback m_callback;

    private int Dp2Px(float dp) {
        if (ms_density < 0)
            ms_density = m_view.getContext().getResources().getDisplayMetrics().density;
        return (int) (dp * ms_density + 0.5f);
    }

    private int Px2Dp(float px) {
        if (ms_density < 0)
            ms_density = m_view.getContext().getResources().getDisplayMetrics().density;
        return (int) (px / ms_density + 0.5f);
    }

    public UIAnnotMenu(RelativeLayout parent) {
        m_view = (LinearLayout) LayoutInflater.from(parent.getContext()).inflate(R.layout.pop_annot, null);
        parent.addView(m_view);
        m_view.setVisibility(View.GONE);
        RelativeLayout.LayoutParams paras = new RelativeLayout.LayoutParams(RelativeLayout.LayoutParams.WRAP_CONTENT,
                m_view.getContext().getResources().getDimensionPixelOffset(R.dimen.annot_menu_btn_size));
        m_view.setLayoutParams(paras);

        ImageButton btn = m_view.findViewById(R.id.btn_annot_edit);
        btn.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                new UIAnnotDlgPopup(m_view.getContext()).show(m_annot, m_callback);
                hide();
            }
        });
        btn = m_view.findViewById(R.id.btn_annot_property);
        btn.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                switch (m_annot.GetType()) {
                    case 4:
                    case 8:
                        new UIAnnotDlgLine(m_view.getContext()).show(m_annot, m_callback);
                        break;
                    case 3:
                    case 5:
                    case 6:
                    case 7:
                        new UIAnnotDlgComm(m_view.getContext()).show(m_annot, true, m_callback);
                        break;
                    case 15:
                        new UIAnnotDlgComm(m_view.getContext()).show(m_annot, false, m_callback);
                        break;
                    case 9:
                    case 10:
                    case 11:
                    case 12:
                        new UIAnnotDlgMarkup(m_view.getContext()).show(m_annot, m_callback);
                        break;
                    case 1:
                    case 17:
                        new UIAnnotDlgIcon(m_view.getContext()).show(m_annot, m_callback);
                        break;
                    default:
                        if (m_callback != null)
                            m_callback.onCancel();
                        break;
                }
                hide();
            }
        });
        btn = m_view.findViewById(R.id.btn_annot_remove);
        btn.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                if (m_callback != null)
                    m_callback.onRemove();
                hide();
            }
        });
        btn = m_view.findViewById(R.id.btn_annot_perform);
        btn.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                if (m_callback != null)
                    m_callback.onPerform();
                hide();
            }
        });
    }

    public boolean show(Page.Annotation annot, float[] annot_rect, IMemnuCallback callback) {
        m_annot = annot;
        m_callback = callback;
        int atype = annot.GetType();
        boolean is_show = (atype != 20 && atype != 3);
        m_has_perform = (atype == 2 || atype == 17 || atype == 18 || atype == 19 || atype == 21 || atype == 25 || atype == 26);
        m_has_edit = (atype == 1 || atype == 4 || atype == 5 || atype == 6 ||
                atype == 7 || atype == 8 || atype == 9 || atype == 10 ||
                atype == 11 || atype == 12 || atype == 13 || atype == 15);
        m_has_remove = (atype != 0);
        m_has_property = (atype != 0 && atype != 2 && atype != 13);

        int btnsCount = 0;
        if (m_has_perform) {
            btnsCount++;
            m_view.findViewById(R.id.btn_annot_perform).setVisibility(View.VISIBLE);
        } else m_view.findViewById(R.id.btn_annot_perform).setVisibility(View.GONE);

        if (m_has_edit) {
            btnsCount++;
            m_view.findViewById(R.id.btn_annot_edit).setVisibility(View.VISIBLE);
        } else m_view.findViewById(R.id.btn_annot_edit).setVisibility(View.GONE);

        if (m_has_remove) {
            btnsCount++;
            m_view.findViewById(R.id.btn_annot_remove).setVisibility(View.VISIBLE);
        } else m_view.findViewById(R.id.btn_annot_remove).setVisibility(View.GONE);

        if (m_has_property) {
            btnsCount++;
            m_view.findViewById(R.id.btn_annot_property).setVisibility(View.VISIBLE);
        } else m_view.findViewById(R.id.btn_annot_property).setVisibility(View.GONE);

        if (is_show) {
            m_view.setX(calculateX(annot_rect, btnsCount));
            m_view.setY(calculateY(annot_rect));
            m_view.setVisibility(View.VISIBLE);
            return true;
        } else {
            m_view.setVisibility(View.GONE);
            return false;
        }
    }

    public void hide() {
        m_view.setVisibility(View.GONE);
    }

    private float calculateX(float[] annot_rect, int btnsCount) {
        float screenWidth = m_view.getContext().getResources().getDisplayMetrics().widthPixels;
        float annotWidth = annot_rect[2] - annot_rect[0];
        float menuWidth = btnsCount * m_view.getContext().getResources().getDimensionPixelOffset(R.dimen.annot_menu_btn_size);
        float x = annot_rect[0] + ((annotWidth - menuWidth) / 2);
        if(x + menuWidth >= screenWidth)
            x -= (x + menuWidth) - screenWidth + m_view.getContext().getResources().getDimensionPixelOffset(R.dimen.annot_menu_bar_margin);
        else if(x <= 0)
            x = m_view.getContext().getResources().getDimensionPixelOffset(R.dimen.annot_menu_bar_margin);
        return x;
    }

    private float calculateY(float[] annot_rect) {
        float y;
        y = annot_rect[1] - (m_view.getContext().getResources().getDimensionPixelOffset(R.dimen.annot_menu_btn_size)
                + m_view.getContext().getResources().getDimensionPixelOffset(R.dimen.annot_menu_bar_margin));
        if (y<0) y = annot_rect[3] + m_view.getContext().getResources().getDimensionPixelOffset(R.dimen.annot_menu_bar_margin);
        return y;
    }
}