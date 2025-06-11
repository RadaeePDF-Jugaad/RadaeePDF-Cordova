package com.radaee.annotui;

import android.content.Context;
import android.graphics.drawable.ColorDrawable;
import android.text.InputFilter;
import android.text.InputType;
import android.util.TypedValue;
import android.view.KeyEvent;
import android.view.LayoutInflater;
import android.view.View;
import android.view.inputmethod.EditorInfo;
import android.view.inputmethod.InputMethodManager;
import android.widget.EditText;
import android.widget.RelativeLayout;
import android.widget.TextView;

import com.radaee.pdf.Page;
import com.radaee.viewlib.R;

public class UIAnnotPopEdit extends UIAnnotPop {

    private final EditText m_edit;
    public UIAnnotPopEdit(View parent)
    {
        super(LayoutInflater.from(parent.getContext()).inflate(R.layout.pop_edit, null));
        m_edit = (EditText) findView(R.id.annot_text);
    }
    public void update(Page.Annotation annot, float[] annot_rect, float scale)
    {
        setFocusable(true);
        setTouchable(true);
        setBackgroundDrawable(new ColorDrawable(0));
        setWidth((int)(annot_rect[2] - annot_rect[0]));
        setHeight((int)(annot_rect[3] - annot_rect[1]));

        RelativeLayout.LayoutParams lp = new RelativeLayout.LayoutParams((int)(annot_rect[2] - annot_rect[0]), (int)(annot_rect[3] - annot_rect[1]));
        m_edit.setLayoutParams(lp);
        m_edit.setText(annot.GetEditText());
        m_edit.setTextSize(TypedValue.COMPLEX_UNIT_PX, annot.GetEditTextSize() * scale);
        m_edit.setBackgroundColor(0xFFFFFFC0);
        m_edit.setPadding(2, 2, 2, 2);
        m_edit.setTextColor(annot.GetEditTextColor() | 0xff000000);
        switch (annot.GetEditType()) {
            case 1:
                m_edit.setSingleLine();
                m_edit.setInputType(InputType.TYPE_CLASS_TEXT + InputType.TYPE_TEXT_VARIATION_NORMAL);
                break;
            case 2:
                m_edit.setSingleLine();
                m_edit.setInputType(InputType.TYPE_CLASS_TEXT + InputType.TYPE_TEXT_VARIATION_PASSWORD);
                break;
            case 3:
                m_edit.setSingleLine(false);
                m_edit.setInputType(InputType.TYPE_CLASS_TEXT + InputType.TYPE_TEXT_VARIATION_NORMAL + InputType.TYPE_TEXT_FLAG_MULTI_LINE);
                break;
        }
        int maxlen = annot.GetEditMaxlen();
        if(maxlen > ((1<<20) + 8))
            m_edit.setFilters(new InputFilter[]{new InputFilter.LengthFilter((1<<20))});
        else if (maxlen > 0)
            m_edit.setFilters(new InputFilter[]{new InputFilter.LengthFilter(maxlen)});
        else
            m_edit.setFilters(new InputFilter[]{new InputFilter.LengthFilter((1<<20))});

        m_edit.setOnFocusChangeListener(new View.OnFocusChangeListener() {
            @Override
            public void onFocusChange(View v, boolean hasFocus) {
                InputMethodManager inputMgr = (InputMethodManager)m_edit.getContext().getSystemService(Context.INPUT_METHOD_SERVICE);
                if (hasFocus) {
                    inputMgr.toggleSoftInput(InputMethodManager.SHOW_FORCED, 0);
                    inputMgr.showSoftInput(v, InputMethodManager.SHOW_IMPLICIT);
                } else {
                    inputMgr.toggleSoftInput(InputMethodManager.SHOW_IMPLICIT, 0);
                    inputMgr.hideSoftInputFromWindow(m_edit.getWindowToken(), 0);
                }
            }
        });

        m_edit.setOnEditorActionListener(new TextView.OnEditorActionListener() {
            @Override
            public boolean onEditorAction(TextView v, int actionId, KeyEvent event) {
                if (actionId == EditorInfo.IME_ACTION_DONE) {
                    dismiss();
                    return true;
                }
                return false;
            }
        });

        m_edit.setVisibility(View.VISIBLE);
    }
    public String getEditText()
    {
        return m_edit.getText().toString();
    }
    public int getContentHeight()
    {
        return m_edit.getLineHeight() * m_edit.getLineCount();
    }
}