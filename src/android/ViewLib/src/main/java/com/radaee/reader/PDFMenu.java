package com.radaee.reader;

import android.graphics.drawable.ColorDrawable;
import android.view.Gravity;
import android.view.LayoutInflater;
import android.view.View;
import android.widget.PopupWindow;
import android.widget.RelativeLayout;

public class PDFMenu implements PopupWindow.OnDismissListener {
    private PopupWindow m_popup = null;
    private View m_parent = null;
    private View m_view = null;

    PDFMenu(RelativeLayout parent, int resource, int width, int height) {
        m_view = LayoutInflater.from(parent.getContext()).inflate(resource, null);
        m_popup = new PopupWindow(m_view);
        m_popup.setOnDismissListener(this);
        m_popup.setFocusable(false);
        m_popup.setTouchable(true);
        m_popup.setOutsideTouchable(true);
        m_popup.setBackgroundDrawable(new ColorDrawable(0));
        final float scale = parent.getContext().getResources().getDisplayMetrics().density;
        m_popup.setWidth((int) (width * scale));
        m_popup.setHeight((int) (height * scale));
        m_parent = parent;
    }

    final View MenuGetView() {
        return m_view;
    }

    final void MenuShow(int x, int y) {
        try {
            int[] location = new int[2];
            m_parent.getLocationOnScreen(location);
            m_popup.showAtLocation(m_parent, Gravity.NO_GRAVITY, x + location[0], y + location[1]);
        } catch (Exception exc) {
        }
    }

    final void MenuDismiss() {
        m_popup.dismiss();
    }

    @Override
    public void onDismiss() {
    }

    int getWidth() {
        return m_popup != null ? m_popup.getWidth() : 0;
    }
}