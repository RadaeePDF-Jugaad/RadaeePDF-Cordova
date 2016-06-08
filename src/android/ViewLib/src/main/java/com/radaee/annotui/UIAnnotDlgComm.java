package com.radaee.annotui;

import android.app.AlertDialog;
import android.content.Context;
import android.content.DialogInterface;
import android.view.LayoutInflater;
import android.view.View;
import android.widget.CheckBox;
import android.widget.EditText;
import android.widget.RelativeLayout;
import android.widget.SeekBar;
import android.widget.TextView;
import android.widget.Toast;

import com.radaee.pdf.Page;
import com.radaee.viewlib.R;

public class UIAnnotDlgComm extends UIAnnotDlg {
    public UIAnnotDlgComm(Context ctx) {
        super((RelativeLayout) LayoutInflater.from(ctx).inflate(R.layout.dlg_annot_prop_comm, null));
        setCancelable(false);
        setPositiveButton(R.string.ok, new DialogInterface.OnClickListener() {
            @Override
            public void onClick(DialogInterface dialog, int which) {
                dialog.dismiss();

                if (m_annot.IsLocked()) {
                    Toast.makeText(getContext(), R.string.cannot_write_or_encrypted, Toast.LENGTH_SHORT).show();
                } else {
                    float width;
                    try {
                        EditText num_lwidth = m_layout.findViewById(R.id.edit_lwidth);
                        width = Float.parseFloat(num_lwidth.getText().toString());
                    } catch (NumberFormatException ignored) {
                        width = -1f;
                    }
                    if (width > 0)
                        m_annot.SetStrokeWidth(width);
                    UILStyleButton btn_lstyle = m_layout.findViewById(R.id.btn_lstyle);
                    m_annot.SetStrokeDash(btn_lstyle.getDash());

                    UIColorButton btn_lcolor = m_layout.findViewById(R.id.btn_lcolor);
                    SeekBar seek_alpha = m_layout.findViewById(R.id.seek_alpha);
                    int color = btn_lcolor.getColor() & 0xffffff;
                    int alpha = seek_alpha.getProgress();
                    if (alpha == 0) alpha = 1;
                    m_annot.SetStrokeColor((alpha << 24) | color);

                    UIColorButton btn_fcolor = m_layout.findViewById(R.id.btn_fcolor);
                    if (btn_fcolor.getVisibility() != View.GONE) {
                        if (btn_fcolor.getColorEnable()) {
                            color = btn_fcolor.getColor() & 0xffffff;
                            m_annot.SetFillColor((alpha << 24) | color);
                        } else
                            m_annot.SetFillColor(0);
                    }
                }

                CheckBox chk_lock = m_layout.findViewById(R.id.chk_lock);
                m_annot.SetLocked(chk_lock.isChecked());

                if (m_callback != null)
                    m_callback.onUpdate();
            }
        });
        setNegativeButton(R.string.cancel, new DialogInterface.OnClickListener() {
            @Override
            public void onClick(DialogInterface dialog, int which) {
                dialog.dismiss();
                if (m_callback != null)
                    m_callback.onCancel();
            }
        });
    }

    void show(Page.Annotation annot, boolean has_fill, UIAnnotMenu.IMemnuCallback calllback) {
        setTitle("Annotation Property");
        m_annot = annot;
        m_callback = calllback;

        EditText num_lwidth = m_layout.findViewById(R.id.edit_lwidth);
        num_lwidth.setText(String.valueOf(m_annot.GetStrokeWidth()));
        UILStyleButton btn_lstyle = m_layout.findViewById(R.id.btn_lstyle);
        btn_lstyle.setDash(null);

        int color = m_annot.GetStrokeColor();
        int alpha = (color >> 24) & 255;
        color |= 0xff000000;
        UIColorButton btn_lcolor = m_layout.findViewById(R.id.btn_lcolor);
        btn_lcolor.setColorEnable(true);
        btn_lcolor.setColor(color);
        btn_lcolor.setColorMode(true);

        UIColorButton btn_fcolor = m_layout.findViewById(R.id.btn_fcolor);
        if (has_fill) {
            color = m_annot.GetFillColor();
            if (color != 0) color |= 0xff000000;
            btn_fcolor.setColor(color);
            btn_fcolor.setColorEnable(color != 0);
            btn_fcolor.setColorMode(false);
        } else {
            TextView txt_fcolor = m_layout.findViewById(R.id.txt_fcolor);
            txt_fcolor.setVisibility(View.GONE);
            btn_fcolor.setVisibility(View.GONE);
        }

        SeekBar seek_alpha = m_layout.findViewById(R.id.seek_alpha);
        final TextView txt_alpha = m_layout.findViewById(R.id.txt_alpha_val);
        seek_alpha.setMax(255);
        seek_alpha.setProgress(alpha);
        txt_alpha.setText(String.format("%d", alpha));
        seek_alpha.setOnSeekBarChangeListener(new SeekBar.OnSeekBarChangeListener() {
            @Override
            public void onProgressChanged(SeekBar seekBar, int progress, boolean fromUser) {
                txt_alpha.setText(String.format("%d", progress));
            }

            @Override
            public void onStartTrackingTouch(SeekBar seekBar) {
            }

            @Override
            public void onStopTrackingTouch(SeekBar seekBar) {
            }
        });

        CheckBox chk_lock = m_layout.findViewById(R.id.chk_lock);
        if (m_annot.IsLocked()) chk_lock.setChecked(true);

        AlertDialog dlg = create();
        dlg.show();
    }
}