package com.radaee.annotui;

import android.app.AlertDialog;
import android.content.Context;
import android.content.DialogInterface;
import android.view.LayoutInflater;
import android.widget.RelativeLayout;
import android.widget.TextView;

import com.radaee.pdf.Document;
import com.radaee.pdf.Page;
import com.radaee.pdf.Sign;
import com.radaee.viewlib.R;

public class UIAnnotDlgSignProp extends UIAnnotDlg {
    private Document m_doc;
    public UIAnnotDlgSignProp(Context ctx) {
        super((RelativeLayout) LayoutInflater.from(ctx).inflate(R.layout.dlg_annot_signprop, null));
        setCancelable(false);
        setNegativeButton("Close", new DialogInterface.OnClickListener() {
            @Override
            public void onClick(DialogInterface dialog, int which) {
                dialog.dismiss();
                if(m_callback != null)
                    m_callback.onCancel();
            }
        });
    }
    public void show(Page.Annotation annot, Document doc, UIAnnotMenu.IMemnuCallback calllback)
    {
        setTitle("Annotation Property");
        m_annot = annot;
        m_doc = doc;
        m_callback = calllback;

        TextView txt_issue = m_layout.findViewById(R.id.txt_issue);
        TextView txt_subj = m_layout.findViewById(R.id.txt_subject);
        TextView txt_ver = m_layout.findViewById(R.id.txt_version);
        TextView txt_reason = m_layout.findViewById(R.id.txt_reason);
        TextView txt_location = m_layout.findViewById(R.id.txt_location);
        TextView txt_contact = m_layout.findViewById(R.id.txt_contact);
        TextView txt_mod = m_layout.findViewById(R.id.txt_mod);
        TextView txt_verify = m_layout.findViewById(R.id.txt_verify);

        Sign sign = m_annot.GetSign();
        txt_issue.setText("Issue:" + sign.GetIssue());
        txt_subj.setText("Subject:" + sign.GetSubject());
        txt_ver.setText("Version:" + sign.GetVersion());
        txt_reason.setText("Reason:" + sign.GetReason());
        txt_location.setText("Location:" + sign.GetLocation());
        txt_contact.setText("Contact:" + sign.GetContact());
        txt_mod.setText("SignTime:" + sign.GetModDateTime());
        int iret = m_doc.VerifySign(sign);
        if (iret== 0)
            txt_verify.setText("Verify:OK");
        else
            txt_verify.setText("Verify:Changed");

        AlertDialog dlg = create();
        dlg.show();
    }
}
