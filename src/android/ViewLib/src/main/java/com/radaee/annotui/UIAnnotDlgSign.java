package com.radaee.annotui;

import android.app.AlertDialog;
import android.content.Context;
import android.content.DialogInterface;
import android.text.TextUtils;
import android.view.LayoutInflater;
import android.view.View;
import android.widget.AdapterView;
import android.widget.Button;
import android.widget.EditText;
import android.widget.RelativeLayout;
import android.widget.TextView;
import android.widget.Toast;

import com.radaee.pdf.Document;
import com.radaee.pdf.Global;
import com.radaee.pdf.Page;

import com.radaee.util.FileBrowserAdt;
import com.radaee.util.FileBrowserView;
import com.radaee.viewlib.R;

public class UIAnnotDlgSign extends UIAnnotDlg {
    private Document m_doc;
    public static float dp2px(Context context, float dpValue) {
        final float scale = context.getResources().getDisplayMetrics().density;
        return dpValue * scale;
    }
    public UIAnnotDlgSign(final Context ctx) {
        super((RelativeLayout) LayoutInflater.from(ctx).inflate(R.layout.dlg_annot_signature, null));
        setCancelable(false);
        Button btn_browser = m_layout.findViewById(R.id.btn_browser);
        final UISignView sign_pad = m_layout.findViewById(R.id.sign_pad);
        final EditText edit_path = m_layout.findViewById(R.id.edit_path);

        btn_browser.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                //open browser dialog.
                AlertDialog.Builder builder = new AlertDialog.Builder(m_layout.getContext());
                builder.setTitle("Please select cert file");
                LayoutInflater inflater = (LayoutInflater)ctx.getSystemService (Context.LAYOUT_INFLATER_SERVICE);
                View view = inflater.inflate(R.layout.dlg_browser, null);
                builder.setView(view);
                builder.setNegativeButton("Close", new DialogInterface.OnClickListener() {
                    @Override
                    public void onClick(DialogInterface dialog, int which) {
                        dialog.dismiss();
                    }
                });
                final AlertDialog dlg = builder.create();
                dlg.setOnShowListener(new DialogInterface.OnShowListener() {
                    @Override
                    public void onShow(DialogInterface dialog) {
                        final FileBrowserView fb_view = dlg.findViewById(R.id.fb_view);
                        TextView txt_filter = dlg.findViewById(R.id.txt_filter);
                        txt_filter.setText("*.p12 *.pfx");
                        fb_view.FileInit("/mnt", new String[]{".p12", ".pfx"});
                        fb_view.setOnItemClickListener(new AdapterView.OnItemClickListener() {
                            @Override
                            public void onItemClick(AdapterView<?> parent, View view, int position, long id) {
                                FileBrowserAdt.SnatchItem item = (FileBrowserAdt.SnatchItem)fb_view.getItemAtPosition(position);
                                if(item.m_item.is_dir()) fb_view.FileGotoSubdir(item.m_item.get_name());
                                else {
                                    edit_path.setText(item.m_item.get_path());
                                    dlg.dismiss();
                                }
                            }
                        });
                    }
                });
                dlg.show();
            }
        });
        setPositiveButton("OK", new DialogInterface.OnClickListener() {
            @Override
            public void onClick(DialogInterface dialog, int which) {
                EditText edit_pswd = m_layout.findViewById(R.id.edit_pswd);
                Document.DocForm form = sign_pad.SignMakeForm(m_doc, m_annot);
                if (form == null) {
                    Toast.makeText(getContext(), "Form is empty", Toast.LENGTH_LONG).show();
                    return;
                }
                String spath = edit_path.getText().toString();
                String spswd = edit_pswd.getText().toString();
                String signer = !TextUtils.isEmpty(Global.sAnnotAuthor) ? Global.sAnnotAuthor : "radaee";
                int iret = m_annot.SignField(form, spath, spswd, signer,"", "", "");
                if(iret == 0)
                {
                    dialog.dismiss();
                    if(m_callback != null)
                        m_callback.onUpdate();
                }
                else if(iret == -5)
                    Toast.makeText(getContext(), "Sign failed, can't open cert file.", Toast.LENGTH_LONG).show();
                else
                    Toast.makeText(getContext(), "Sign failed.", Toast.LENGTH_LONG).show();
            }
        });
        setNegativeButton("Cancel", new DialogInterface.OnClickListener() {
            @Override
            public void onClick(DialogInterface dialog, int which) {
                dialog.dismiss();
                if(m_callback != null)
                    m_callback.onCancel();
            }
        });
        m_layout.addOnLayoutChangeListener(
                new View.OnLayoutChangeListener() {
                    @Override
                    public void onLayoutChange(View v, int left, int top, int right, int bottom, int oldLeft, int oldTop, int oldRight, int oldBottom) {
                        v.removeOnLayoutChangeListener(this);
                        //keep signature area aspect.
                        float signPadW = sign_pad.getWidth();
                        //104 dp is exclude height value that assigned by layout xml file.
                        //if layout file changed, you shall update exclude dp value in following codes.
                        float exclude = dp2px(getContext(), 104);
                        float signPadH = (bottom - top) - exclude;
                        float[] annotRect = m_annot.GetRect();
                        float scaleW = signPadW / (annotRect[2] - annotRect[0]);
                        float scaleH = signPadH / (annotRect[3] - annotRect[1]);
                        if(scaleW > scaleH) scaleW = scaleH;

                        RelativeLayout.LayoutParams layoutParams = new RelativeLayout.LayoutParams((int) ((annotRect[2] - annotRect[0]) * scaleW),
                                (int) ((annotRect[3] - annotRect[1]) * scaleW));
                        layoutParams.addRule(RelativeLayout.BELOW, R.id.txt_hwriting);
                        layoutParams.addRule(RelativeLayout.CENTER_HORIZONTAL);
                        sign_pad.setLayoutParams(layoutParams);
                    }
                });
    }
    public void show(Page.Annotation annot, Document doc, UIAnnotMenu.IMemnuCallback calllback)
    {
        setTitle("Sign the Field");
        m_annot = annot;
        m_doc = doc;
        m_callback = calllback;
        AlertDialog dlg = create();
        dlg.show();
    }
}