package com.radaee.util;

import android.app.Activity;
import android.content.Context;
import android.content.Intent;
import android.os.Bundle;
import android.os.Handler;
import android.text.Editable;
import android.text.InputFilter;
import android.text.InputType;
import android.util.TypedValue;
import android.view.MotionEvent;
import android.view.View;
import android.view.Window;
import android.view.inputmethod.InputMethodManager;
import android.widget.EditText;
import android.widget.RelativeLayout;

import com.radaee.viewlib.R;

public class PopupEditAct extends Activity {

    private EditText m_txt;
    private RelativeLayout m_layout;

    public interface ActRetListener {
        void OnEditValue(String val);
    }

    static public ActRetListener ms_listener;
    private ActRetListener m_listener;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        m_listener = ms_listener;
        ms_listener = null;
        super.onCreate(savedInstanceState);
        requestWindowFeature(Window.FEATURE_NO_TITLE);
        overridePendingTransition(android.R.anim.fade_in, android.R.anim.fade_out);
        setContentView(R.layout.pop_edit);
        m_layout = (RelativeLayout)findViewById(R.id.lay_root);
        m_txt = (EditText)findViewById(R.id.annot_text);
        m_txt.setVisibility(View.INVISIBLE);
        Handler handler = new Handler();
        Runnable runnable=new Runnable(){
            @Override
            public void run() {
                int[] location = new int[2];
                m_layout.getLocationOnScreen(location);
                Intent intent = getIntent();
                float x = intent.getFloatExtra("x", location[0]) - location[0];
                float y = intent.getFloatExtra("y", location[1]) - location[1];
                float w = intent.getFloatExtra("w", 0);
                float h = intent.getFloatExtra("h", 0);
                int type = intent.getIntExtra("type", 0);
                int maxlen = intent.getIntExtra("max", 0);
                float size = intent.getFloatExtra("size", 0);
                m_txt.setText(intent.getStringExtra("txt"));
                RelativeLayout.LayoutParams lp = new RelativeLayout.LayoutParams((int)w, (int)h);
                lp.addRule(RelativeLayout.ALIGN_PARENT_LEFT);
                lp.addRule(RelativeLayout.ALIGN_PARENT_TOP);
                lp.leftMargin = (int)x;
                lp.topMargin = (int)y;
                m_txt.setLayoutParams(lp);
                m_txt.setTextSize(TypedValue.COMPLEX_UNIT_PX, size);
                m_txt.setBackgroundColor(0xFFFFFFC0);
                m_txt.setPadding(2, 2, 2, 2);
                m_txt.setTextColor(0xFF000000);
                switch (type) {
                    case 1:
                        m_txt.setSingleLine();
                        m_txt.setInputType(InputType.TYPE_CLASS_TEXT + InputType.TYPE_TEXT_VARIATION_NORMAL);
                        break;
                    case 2:
                        m_txt.setSingleLine();
                        m_txt.setInputType(InputType.TYPE_CLASS_TEXT + InputType.TYPE_TEXT_VARIATION_PASSWORD);
                        break;
                    case 3:
                        m_txt.setSingleLine(false);
                        m_txt.setInputType(InputType.TYPE_CLASS_TEXT + InputType.TYPE_TEXT_VARIATION_NORMAL + InputType.TYPE_TEXT_FLAG_MULTI_LINE);
                        break;
                }
                if(maxlen > 1020)
                    m_txt.setFilters(new InputFilter[]{new InputFilter.LengthFilter(1020)});
                else if (maxlen > 0)
                    m_txt.setFilters(new InputFilter[]{new InputFilter.LengthFilter(maxlen)});
                else
                    m_txt.setFilters(new InputFilter[]{new InputFilter.LengthFilter(1020)});
                m_txt.setVisibility(View.VISIBLE);

                //show the keyboard
                InputMethodManager imm = (InputMethodManager) getSystemService(Context.INPUT_METHOD_SERVICE);
                imm.showSoftInput(m_txt, InputMethodManager.SHOW_IMPLICIT);
            }
        };
        handler.postDelayed(runnable, 50);
    }

    @Override
    public void onBackPressed() {
        if(m_txt == null || !m_txt.isShown()) return;
        updateAnnot();
        super.onBackPressed();
        overridePendingTransition(0, android.R.anim.fade_out);
    }

    @Override
    public boolean onTouchEvent(MotionEvent event) {
        if(event.getActionMasked() == MotionEvent.ACTION_UP) {
            if (m_txt == null || !m_txt.isShown()) return false;
            updateAnnot();
            finish();
            overridePendingTransition(0, android.R.anim.fade_out);
        }
        return true;
    }

    private void updateAnnot() {
        Editable value = m_txt.getText();
        if(value != null && m_listener != null)
            m_listener.OnEditValue(value.toString());
    }
}
