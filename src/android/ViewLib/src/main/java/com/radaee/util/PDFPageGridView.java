package com.radaee.util;

import android.content.Context;
import android.util.AttributeSet;
import android.widget.AbsListView;
import android.widget.GridView;

public class PDFPageGridView extends GridView {
    private void init()
    {
        setOnScrollListener(new OnScrollListener() {
            @Override
            public void onScrollStateChanged(AbsListView view, int scrollState) {
            }

            @Override
            public void onScroll(AbsListView view, int firstVisibleItem, int visibleItemCount, int totalItemCount) {
                if(m_adt != null) m_adt.refresh_range(firstVisibleItem, firstVisibleItem + visibleItemCount);
            }
        });
    }
    public PDFPageGridView(Context context) {
        super(context);
        init();
    }
    public PDFPageGridView(Context context, AttributeSet attrs) {
        super(context, attrs);
        init();
    }
    private com.radaee.pdf.Document m_doc;
    private PDFPageGridAdt m_adt;
    public void PDFOpen(com.radaee.pdf.Document doc)
    {
        setNumColumns(3);
        m_doc = doc;
        m_adt = new PDFPageGridAdt(getContext(), m_doc);
        setAdapter(m_adt);
    }
    public void PDFClose()
    {
        if(m_adt != null) m_adt.close();
        m_adt = null;
    }
    public boolean[] PDFGetRemoval()
    {
        if(m_adt == null) return null;
        return m_adt.getRemoval();
    }
    public int[] PDFGetRotate()
    {
        if(m_adt == null) return null;
        return m_adt.getRotate();
    }
    public boolean PDFIsModified()
    {
        if(m_adt == null) return false;
        return m_adt.isModified();
    }
}
