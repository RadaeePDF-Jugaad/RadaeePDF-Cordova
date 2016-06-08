package com.radaee.annotui;

import android.app.AlertDialog;
import android.content.Context;
import android.content.DialogInterface;
import android.util.DisplayMetrics;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.view.ViewParent;
import android.widget.AdapterView;
import android.widget.Button;
import android.widget.EditText;
import android.widget.FrameLayout;
import android.widget.RelativeLayout;
import android.widget.TextView;
import android.widget.Toast;

import com.radaee.pdf.Document;
import com.radaee.pdf.Global;
import com.radaee.pdf.Page;
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
        final EditText edit_path = m_layout.findViewById(R.id.edit_path);
        EditText edit_pswd = m_layout.findViewById(R.id.edit_pswd);
        TextView txt_cert = m_layout.findViewById(R.id.txt_cert);
        TextView txt_pswd = m_layout.findViewById(R.id.txt_pswd);

        if(!Global.g_fake_sign) {
            btn_browser.setVisibility(View.VISIBLE);
            edit_path.setVisibility(View.VISIBLE);
            edit_pswd.setVisibility(View.VISIBLE);
            txt_cert.setVisibility(View.VISIBLE);
            txt_pswd.setVisibility(View.VISIBLE);
            btn_browser.setOnClickListener(new View.OnClickListener() {
                @Override
                public void onClick(View v) {
                    //open browser dialog.
                    AlertDialog.Builder builder = new AlertDialog.Builder(m_layout.getContext());
                    builder.setTitle(getContext().getString(R.string.sign_select_certificate));
                    LayoutInflater inflater = (LayoutInflater) ctx.getSystemService(Context.LAYOUT_INFLATER_SERVICE);
                    View view = inflater.inflate(R.layout.dlg_browser, null);
                    builder.setView(view);
                    builder.setNegativeButton(getContext().getString(R.string.confirm), new DialogInterface.OnClickListener() {
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
                            txt_filter.setText(getContext().getString(R.string.sign_certificate_filetype));
                            fb_view.FileInit("/mnt", new String[]{".p12", ".pfx"});
                            fb_view.setOnItemClickListener(new AdapterView.OnItemClickListener() {
                                @Override
                                public void onItemClick(AdapterView<?> parent, View view, int position, long id) {
                                    FileBrowserView.FileBrowserAdt.SnatchItem item = (FileBrowserView.FileBrowserAdt.SnatchItem) fb_view.getItemAtPosition(position);
                                    if (item.m_item.is_dir())
                                        fb_view.FileGotoSubdir(item.m_item.get_name());
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
        } else {
            btn_browser.setVisibility(View.GONE);
            edit_path.setVisibility(View.GONE);
            edit_pswd.setVisibility(View.GONE);
            txt_cert.setVisibility(View.GONE);
            txt_pswd.setVisibility(View.GONE);
        }
        setPositiveButton(getContext().getString(R.string.ok), new DialogInterface.OnClickListener() {
            @Override
            public void onClick(DialogInterface dialog, int which) {
                UISignView sign_pad = m_layout.findViewById(R.id.sign_pad);
                Document.DocForm form = sign_pad.SignMakeForm(m_doc, m_annot);
                if (form == null) {
                    Toast.makeText(getContext(), "Form is empty", Toast.LENGTH_LONG).show();
                    return;
                }
                String spswd = null;
                String spath = null;
                if(!Global.g_fake_sign) {
                    spath = edit_path.getText().toString();
                    spswd = edit_pswd.getText().toString();
                } else {
                    // The dummy certificate is only to set the graphic signature
                    // the suggestion is to substitute the resource with a different certificate
                    spath = Global.tmp_path + "/radaeepdf_test.pfx";
                    spswd = "RadaeePDFTest";
                }
                int iRet = m_annot.SignField(form, spath, spswd, "", "", "", "");
                if(iRet == 0)
                {
                    dialog.dismiss();
                    if(m_callback != null)
                        m_callback.onUpdate();
                }
                else if(iRet == -5)
                    Toast.makeText(getContext(), getContext().getString(R.string.sign_error_fail_certificate), Toast.LENGTH_LONG).show();
                else
                    Toast.makeText(getContext(), getContext().getString(R.string.sign_error_fail), Toast.LENGTH_LONG).show();
            }
        });
        setNegativeButton(getContext().getString(R.string.cancel), new DialogInterface.OnClickListener() {
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
                    public void onLayoutChange(View v, int left, int top, int right, int bottom, int oldLeft, int oldTop, int oldRight, int oldBottom)
                    {
                        // keep signature area aspect ratio.
                        // 104dp is exclude height value that assigned by layout xml file.
                        // if layout file changed, you shall update exclude dp value in following codes.
                        int dpExclude;
                        if(!Global.g_fake_sign) {
                            dpExclude = 104;
                        } else {
                            dpExclude = 34;
                        }
                        DisplayMetrics dm = getContext().getResources().getDisplayMetrics();
                        float layw = dm.widthPixels * 0.9f;
                        float layh = dm.heightPixels * 0.9f;
                        float exclude = dp2px(getContext(), dpExclude);
                        float arect[] = m_annot.GetRect();
                        float scale1 = layw / (arect[2] - arect[0]);
                        float scale2 = (layh - exclude) / (arect[3] - arect[1]);
                        if(scale1 > scale2) scale1 = scale2;

                        layw = (arect[2] - arect[0]) * scale1;
                        layh = (arect[3] - arect[1]) * scale1;

                        FrameLayout.LayoutParams lp = new FrameLayout.LayoutParams((int)layw,  (int)(layh + exclude));
                        v.setLayoutParams(lp);
                        forceWrapContent(v);
                    }
                });
    }
    public void show(Page.Annotation annot, Document doc, UIAnnotMenu.IMemnuCallback callBack)
    {
        //setTitle(getContext().getString(R.string.sign_title));
        m_annot = annot;
        m_doc = doc;
        m_callback = callBack;
        AlertDialog dlg = create();
        dlg.show();
    }

    protected void forceWrapContent(View v) {
        View current = v;
        do {
            ViewParent parent = current.getParent();
            if (parent != null) {
                try {
                    current = (View) parent;
                } catch (ClassCastException e) {
                    break;
                }
                current.getLayoutParams().width = ViewGroup.LayoutParams.WRAP_CONTENT;
                current.getLayoutParams().height = ViewGroup.LayoutParams.WRAP_CONTENT;
            }
        } while (current.getParent() != null);
        current.requestLayout();
    }
}
