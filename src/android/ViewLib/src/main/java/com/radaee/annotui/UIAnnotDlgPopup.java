package com.radaee.annotui;

import android.app.AlertDialog;
import android.content.Context;
import android.content.DialogInterface;
import android.view.LayoutInflater;
import android.widget.EditText;
import android.widget.RelativeLayout;

import com.radaee.pdf.Page;
import com.radaee.viewlib.R;

public class UIAnnotDlgPopup extends UIAnnotDlg {
    public UIAnnotDlgPopup(Context ctx)
    {
        super((RelativeLayout) LayoutInflater.from(ctx).inflate(R.layout.dlg_annot_popup, null));
        setCancelable(false);
        setPositiveButton(R.string.ok, new DialogInterface.OnClickListener() {
            @Override
            public void onClick(DialogInterface dialog, int which) {
                EditText edit_subj = (EditText)m_layout.findViewById(R.id.txt_subj);
                m_annot.SetPopupSubject(edit_subj.getText().toString());
                EditText edit_content = (EditText)m_layout.findViewById(R.id.txt_content);
                m_annot.SetPopupText(edit_content.getText().toString());
                dialog.dismiss();
                if(m_callback != null)
                    m_callback.onCancel();
            }
        });
        setNegativeButton(R.string.cancel, new DialogInterface.OnClickListener() {
            @Override
            public void onClick(DialogInterface dialog, int which) {
                dialog.dismiss();
                if(m_callback != null)
                    m_callback.onCancel();
            }
        });
    }
    void show(Page.Annotation annot, UIAnnotMenu.IMemnuCallback callback)
    {
        m_annot = annot;
        m_callback = callback;
        String label = m_annot.GetPopupLabel();
        if(label == null || label.isEmpty())
            setTitle("Popup Text");
        else
            setTitle(label);
        EditText edit_subj = (EditText)m_layout.findViewById(R.id.txt_subj);
        edit_subj.setText(m_annot.GetPopupSubject());
        EditText edit_content = (EditText)m_layout.findViewById(R.id.txt_content);
        edit_content.setText(m_annot.GetPopupText());
        AlertDialog dlg = create();
        dlg.show();
    }
}
