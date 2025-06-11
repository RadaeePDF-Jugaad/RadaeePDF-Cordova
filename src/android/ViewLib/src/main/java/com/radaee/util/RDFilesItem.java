package com.radaee.util;

import android.content.Context;
import android.view.LayoutInflater;
import android.view.View;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.RelativeLayout;
import android.widget.TextView;

import com.radaee.pdf.Document;
import com.radaee.pdf.Global;
import com.radaee.viewlib.R;

import java.io.File;

public class RDFilesItem
{
    static public class RDFileItem
    {
        public File m_file;
        public RelativeLayout m_view;
    }
    protected LinearLayout m_view;
    protected RDExpView m_thead;
    protected RelativeLayout m_panel;
    protected RDLinearLayout m_list;
    protected File m_dir;
    protected RDFileItem[] m_items;
    private final RDFilesView.OnFilesListener m_listener;
    private final RDLockerSet m_lset;
    public RDFilesItem(Context ctx, int ignore, String preffix, RDLockerSet lset, File dir, File[] files, RDFilesView.OnFilesListener listener)
    {
        m_listener = listener;
        m_lset = lset;
        m_view = (LinearLayout) LayoutInflater.from(ctx).inflate(R.layout.item_dir_list, null);
        m_thead = m_view.findViewById(R.id.txt_head);
        TextView tname = m_view.findViewById(R.id.txt_name);
        tname.setText(preffix + dir.getAbsolutePath().substring(ignore));
        m_panel = m_view.findViewById(R.id.lay_panel);
        m_panel.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                m_thead.RDSwap();
                if (m_thead.RDIsExp())
                    //m_list.setVisibility(View.VISIBLE);
                    m_list.RDExpand();
                else
                    m_list.RDCollapse();
                    //m_list.setVisibility(View.GONE);
            }
        });
        m_list = m_view.findViewById(R.id.lst_files);
        m_dir = dir;
        m_items = new RDFileItem[files.length];
        int cnt = files.length;
        for(int cur = 0; cur < cnt; cur++)
        {
            RDFileItem item = new RDFileItem();
            item.m_file = files[cur];
            item.m_view = (RelativeLayout)LayoutInflater.from(ctx).inflate(R.layout.item_file_list, null);
            final int idx = cur;
            item.m_view.setOnClickListener(new View.OnClickListener() {
                @Override
                public void onClick(View v) { m_listener.OnItemClick(RDFilesItem.this, idx); }
            });
            tname = item.m_view.findViewById(R.id.txt_name);
            tname.setText(item.m_file.getName());

            ImageView imgv = item.m_view.findViewById(R.id.img_thumb);
            imgv.setColorFilter(Global.gridview_icon_color);
            imgv.setImageBitmap(RDGridView.m_def_pdf_icon);

            imgv = item.m_view.findViewById(R.id.img_more);
            imgv.setColorFilter(Global.gridview_icon_color);
            imgv.setOnClickListener(new View.OnClickListener() {
                @Override
                public void onClick(View v) { m_listener.OnItemMore(RDFilesItem.this, idx); }
            });
            m_list.addView(item.m_view);
            m_items[cur] = item;
        }
    }
    public int RDGetFileCount()
    {
        return m_items.length;
    }
    public File RDGetFile(int idx)
    {
        return m_items[idx].m_file;
    }
    public int RDOpen(int idx, Document doc, String password )
    {
        File file = m_items[idx].m_file;
        String key = file.getAbsolutePath();
        Object locker = m_lset.Lock(key);
        int ret = doc.Open(key, password);
        m_lset.Unlock(key, locker);
        return ret;
    }
    public int RDDelete(int idx)
    {
        File file = m_items[idx].m_file;
        String key = file.getAbsolutePath();
        Object locker = m_lset.Lock(key);
        int ret = remove(idx);
        file.delete();
        m_lset.Unlock(key, locker);
        return ret;
    }
    private int remove(int idx)
    {
        int cnt = m_items.length - 1;
        if (cnt <= 0) return 0;

        m_list.removeView(m_items[idx].m_view);
        RDFileItem[] items = new RDFileItem[cnt];
        if (idx >= 0) System.arraycopy(m_items, 0, items, 0, idx);
        for(int cur = idx; cur < cnt; cur++)
        {
            RDFileItem item = m_items[cur + 1];
            ImageView imgv = item.m_view.findViewById(R.id.img_more);
            imgv.setColorFilter(Global.gridview_icon_color);
            final int index = cur;
            imgv.setOnClickListener(new View.OnClickListener() {
                @Override
                public void onClick(View v) { if (m_listener != null) m_listener.OnItemMore(RDFilesItem.this, index); }
            });
            item.m_view.setOnClickListener(new View.OnClickListener() {
                @Override
                public void onClick(View v) { if (m_listener != null) m_listener.OnItemClick(RDFilesItem.this, index); }
            });
            items[cur] = item;
        }
        m_items = items;
        return cnt;
    }
}
