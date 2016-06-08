package com.radaee.annotui;

import android.graphics.drawable.ColorDrawable;
import android.view.LayoutInflater;
import android.view.View;
import android.widget.AdapterView;

import com.radaee.pdf.Page;
import com.radaee.util.ComboList;
import com.radaee.viewlib.R;

public class UIAnnotPopCombo extends UIAnnotPop {
    private final ComboList m_combo;
    private int m_combo_item;
    public UIAnnotPopCombo(View parent) {
        super(LayoutInflater.from(parent.getContext()).inflate(R.layout.pop_combo, null));
        m_combo = (ComboList) findView(R.id.annot_combo);
    }
    public void update(Page.Annotation annot, float[] annot_rect)
    {
        String[] opts = new String[annot.GetComboItemCount()];
        int cur = 0;
        while (cur < opts.length) {
            opts[cur] = annot.GetComboItem(cur);
            cur++;
        }
        setFocusable(true);
        setTouchable(true);
        setBackgroundDrawable(new ColorDrawable(0));
        setWidth((int) (annot_rect[2] - annot_rect[0]));
        if ((annot_rect[3] - annot_rect[1] - 4) * opts.length > 250)
            setHeight(250);
        else
            setHeight((int) (annot_rect[3] - annot_rect[1] - 4) * opts.length);
        m_combo.set_opts(opts);
        m_combo_item = -1;
        m_combo.setOnItemClickListener(new AdapterView.OnItemClickListener() {
            @Override
            public void onItemClick(AdapterView<?> adapterView, View view, int i, long l) {
                m_combo_item = i;
                dismiss();
            }
        });
    }
    public int getSelItem()
    {
        return m_combo_item;
    }
}