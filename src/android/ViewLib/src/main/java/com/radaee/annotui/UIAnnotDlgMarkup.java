package com.radaee.annotui;

import android.app.AlertDialog;
import android.content.Context;
import android.content.DialogInterface;
import android.view.LayoutInflater;
import android.widget.CheckBox;
import android.widget.RelativeLayout;
import android.widget.SeekBar;
import android.widget.TextView;
import android.widget.Toast;

import com.radaee.pdf.Page;
import com.radaee.viewlib.R;

public class UIAnnotDlgMarkup extends UIAnnotDlg {
    public UIAnnotDlgMarkup(Context ctx)
    {
        super((RelativeLayout) LayoutInflater.from(ctx).inflate(R.layout.dlg_annot_prop_markup, null));
        setCancelable(false);
        setPositiveButton(R.string.ok, new DialogInterface.OnClickListener() {
            @Override
            public void onClick(DialogInterface dialog, int which) {
                dialog.dismiss();

                if (m_annot.IsLocked()) {
                    Toast.makeText(getContext(), R.string.cannot_write_or_encrypted, Toast.LENGTH_SHORT).show();
                }
                else {
                    UIColorButton btn_lcolor = m_layout.findViewById(R.id.btn_lcolor);
                    SeekBar seek_alpha = m_layout.findViewById(R.id.seek_alpha);
                    int color = btn_lcolor.getColor() & 0xffffff;
                    int alpha = seek_alpha.getProgress();
                    if (alpha == 0) alpha = 1;
                    if (m_annot.GetType() == 9)
                        m_annot.SetFillColor((alpha << 24) | color);
                    else
                        m_annot.SetStrokeColor((alpha << 24) | color);
                }

                CheckBox chk_lock = m_layout.findViewById(R.id.chk_lock);
                m_annot.SetLocked(chk_lock.isChecked());

                if(m_callback != null)
                    m_callback.onUpdate();
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
    void show(Page.Annotation annot, UIAnnotMenu.IMemnuCallback calllback)
    {
        setTitle("Markup Property");
        m_annot = annot;
        m_callback = calllback;

        int color = (m_annot.GetType() == 9)?m_annot.GetFillColor():m_annot.GetStrokeColor();
        int alpha = (color >> 24) & 255;
        color |= 0xff000000;
        UIColorButton btn_lcolor = m_layout.findViewById(R.id.btn_lcolor);
        btn_lcolor.setColorEnable(true);
        btn_lcolor.setColor(color);
        btn_lcolor.setColorMode(true);

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