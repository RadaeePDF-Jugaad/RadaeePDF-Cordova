package com.radaee.util;

import android.content.Context;
import android.util.AttributeSet;
import android.widget.ListView;

import com.radaee.pdf.Document;

public class OutlineList extends ListView
{
	OutlineListAdt m_adt;
	public OutlineList(Context context, AttributeSet attrs)
	{
		super(context, attrs);
		m_adt = new OutlineListAdt(context);
	}
	public void SetOutlines(Document doc)
	{
		setAdapter(m_adt);
		m_adt.set_outlines(doc);
	}
    public OutlineListAdt.outline_ui_item GetItem(int pos)
    {
        return (OutlineListAdt.outline_ui_item)m_adt.getItem(pos);
    }
}
