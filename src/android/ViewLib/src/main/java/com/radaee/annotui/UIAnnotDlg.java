package com.radaee.annotui;

import android.app.AlertDialog;
import android.widget.RelativeLayout;

import com.radaee.pdf.Page;

public class UIAnnotDlg extends AlertDialog.Builder {
    protected Page.Annotation m_annot;
    protected RelativeLayout m_layout;
    protected UIAnnotMenu.IMemnuCallback m_callback;
    public UIAnnotDlg(RelativeLayout view)
    {
        super(view.getContext());
        setView(view);
        m_layout = view;
    }
}
