package com.radaee.annotui;

import android.view.Gravity;
import android.view.View;
import android.widget.PopupWindow;

public class UIAnnotPop extends PopupWindow {

    public UIAnnotPop(View view) {
        super(view);
    }

    public UIAnnotPop(View view, int w, int h) {
        super(view, w, h);
    }

    public View findView(int id) {
        return getContentView().findViewById(id);
    }

    public void show(View parent, int x, int y) {
        showAtLocation(parent, Gravity.NO_GRAVITY, x, y);
    }
}