package com.radaee.reader;

import android.app.Activity;
import android.content.Intent;
import android.os.Bundle;
import android.view.View;
import android.widget.ImageView;

import com.radaee.pdf.Document;
import com.radaee.util.PDFPageGridView;
import com.radaee.viewlib.R;

public class PDFPagesAct extends Activity {
    static protected Document ms_tran_doc;
    private PDFPageGridView m_view;
    private Document m_doc;
    public void onCreate(Bundle savedInstanceState)
    {
        super.onCreate(savedInstanceState);
        m_doc = ms_tran_doc;
        ms_tran_doc = null;
        setContentView(R.layout.pdf_pages);
        m_view = findViewById(R.id.vw_pages);
        m_view.PDFOpen(m_doc);
        setResult(0);

        ImageView view = findViewById(R.id.btn_back);
        view.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                finish();
            }
        });
        view = findViewById(R.id.btn_ok);
        view.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                if(!m_view.PDFIsModified())
                {
                    finish();
                    return;
                }
                Intent intent = new Intent();
                boolean[] removal = m_view.PDFGetRemoval();
                int[] rotation = m_view.PDFGetRotate();
                intent.putExtra("removal", removal);
                intent.putExtra("rotate", rotation);
                setResult(1, intent);
                finish();
            }
        });
    }
    protected void onDestroy()
    {
        if (m_view != null) m_view.PDFClose();
        if (m_doc != null) m_doc.Close();
        super.onDestroy();
    }
}
