package com.radaee.util;

import android.app.Activity;
import android.os.Bundle;
import androidx.annotation.Nullable;

import com.radaee.pdf.Document;
import com.radaee.pdf.Global;
import com.radaee.view.PDFViewThumb;
import com.radaee.viewlib.R;

/**
 * @author Nermeen created on 24/01/2017.
 */
public class PDFThumbGrid extends Activity {

    public static Document mDoc;

    @Override
    protected void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        setContentView(R.layout.pdf_thumb_grid_view);

        PDFThumbView mThumbView = findViewById(R.id.thumb_view);
        mThumbView.thumbOpen(mDoc, new PDFViewThumb.PDFThumbListener() {
            @Override
            public void OnPageClicked(int pageno) {
                RadaeePluginCallback.getInstance().onThumbPageClick(pageno);
                finish();
            }
        }, (int) (Global.thumbGridElementHeight * getResources().getDisplayMetrics().density), 3,
                Global.thumbGridBgColor, Global.thumbGridElementGap);
    }
}