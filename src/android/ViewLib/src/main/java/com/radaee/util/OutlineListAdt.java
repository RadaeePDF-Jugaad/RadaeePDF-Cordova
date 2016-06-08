package com.radaee.util;

import android.content.Context;
import android.database.DataSetObserver;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.ListAdapter;
import android.widget.RelativeLayout;
import android.widget.TextView;

import com.radaee.pdf.Document;
import com.radaee.viewlib.R;


public class OutlineListAdt implements ListAdapter
{
    private Context m_ctx;
	private DataSetObserver m_obs = null;
    private Document m_doc;
    private class OutlineRec
    {
        private OutlineRec m_parent;
        private Document.Outline m_parent_outline;
    }
    private OutlineRec m_cur;
    public class outline_ui_item implements View.OnClickListener
    {
        private int m_type;
        private Document.Outline m_outline;
        private RelativeLayout m_layout;
        private TextView txt_name;
        private ImageView btn_goto;
        private outline_ui_item(Context ctx, Document.Outline outline)
        {
            m_type = 1;
            m_outline = outline;
            m_layout = (RelativeLayout)LayoutInflater.from(ctx).inflate(R.layout.item_outline, null);
            txt_name = (TextView)m_layout.findViewById(R.id.txt_name);
            txt_name.setText(outline.GetTitle());
            btn_goto = (ImageView)m_layout.findViewById(R.id.btn_goto);
            if(outline.GetChild() != null)
            {
                btn_goto.setVisibility(View.VISIBLE);
                btn_goto.setOnClickListener(this);
            }
            else
                btn_goto.setVisibility(View.INVISIBLE);
        }
        private outline_ui_item(Context ctx, int type, String name)
        {
            if(type == 1) type = 0;
            m_type = type;
            m_outline = null;
            m_layout = (RelativeLayout)LayoutInflater.from(ctx).inflate(R.layout.item_outline, null);
            txt_name = (TextView)m_layout.findViewById(R.id.txt_name);
            txt_name.setText(name);
            btn_goto = (ImageView)m_layout.findViewById(R.id.btn_goto);
            btn_goto.setVisibility(View.INVISIBLE);
            m_layout.setOnClickListener(this);
        }
        public int GetPageNO()
        {
            if(m_outline != null)
                return m_outline.GetDest();
            else return -1;
        }

        @Override
        public void onClick(View view)
        {
            if(view == btn_goto)//goto children level
            {
                OutlineRec cur = new OutlineRec();
                cur.m_parent_outline = m_outline;
                cur.m_parent = m_cur;
                m_cur = cur;
                refresh();
            }
            else if(view == m_layout)//goto parent level
            {
                if(m_cur != null)
                {
                    m_cur = m_cur.m_parent;
                    refresh();
                }
            }
        }
    }
    private outline_ui_item m_items[];
    private void refresh()
    {
        m_items = null;
        if(m_cur == null)
        {
            int cnt = 0;
            for(Document.Outline root = m_doc.GetOutlines(); root != null; root = root.GetNext())
                cnt++;
            if(cnt > 0)
            {
                m_items = new outline_ui_item[cnt];
                int cur = 0;
                for(Document.Outline root = m_doc.GetOutlines(); root != null; root = root.GetNext())
                {
                    m_items[cur] = new outline_ui_item(m_ctx, root);
                    cur++;
                }
            }
        }
        else
        {
            int cnt = 1;
            for(Document.Outline item = m_cur.m_parent_outline.GetChild(); item != null; item = item.GetNext())
                cnt++;
            m_items = new outline_ui_item[cnt];
            m_items[0] = new outline_ui_item(m_ctx, 0, "<parent>");
            int cur = 1;
            for(Document.Outline item = m_cur.m_parent_outline.GetChild(); item != null; item = item.GetNext())
            {
                m_items[cur] = new outline_ui_item(m_ctx, item);
                cur++;
            }
        }
        if(m_obs != null)
            m_obs.onChanged();
    }
    public OutlineListAdt(Context ctx)
    {
        m_ctx = ctx;
    }
	public void set_outlines( Document doc )
	{
        m_doc = doc;
        m_cur = null;
        refresh();
	}
	public int getCount()
	{
		if( m_items == null ) return 0;
		return m_items.length;
	}

	public Object getItem(int arg0)
	{
		return m_items[arg0];
	}

	public long getItemId(int position)
	{
		return 0;
	}

	public int getItemViewType(int position)
	{
		return 0;
	}

	public View getView(int position, View convertView, ViewGroup parent)
	{
		return m_items[position].m_layout;
	}

	public int getViewTypeCount()
	{
		return 1;
	}

	public boolean hasStableIds()
	{
		return false;
	}

	public boolean isEmpty()
	{
        boolean ret = ((m_items == null) || (m_items.length <= 0));
		return ret;
	}

	public void registerDataSetObserver(DataSetObserver observer)
	{
		m_obs = observer;
	}

	public void unregisterDataSetObserver(DataSetObserver observer)
	{
		m_obs = null;
	}

	public boolean areAllItemsEnabled()
	{
		return true;
	}

	public boolean isEnabled(int position)
	{
		return true;
	}
}
