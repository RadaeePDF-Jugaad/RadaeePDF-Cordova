package com.radaee.util;

import android.content.Context;
import android.database.DataSetObserver;
import android.os.Handler;
import android.os.Looper;
import android.os.Message;
import android.util.AttributeSet;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ImageView;
import android.widget.ListAdapter;
import android.widget.ListView;
import android.widget.RelativeLayout;
import android.widget.TextView;

import com.radaee.pdf.Global;
import com.radaee.viewlib.R;

import java.io.File;

public class RDRecentView extends ListView
{
    public interface OnRecentListener
    {
        void OnItemClick(RDRecentItem item, int idx);
        void OnItemMore(RDRecentItem item, int idx);
    }
    private static class RDRecentThread extends Thread
    {
        private Handler m_hand = null;
        private Handler m_handUI = null;
        private boolean is_notified = false;
        private boolean is_waitting = false;
        private synchronized void wait_init()
        {
            try
            {
                if( is_notified )
                    is_notified = false;
                else
                {
                    is_waitting = true;
                    wait();
                    is_waitting = false;
                }
            }
            catch(Exception ignored)
            {
            }
        }
        private synchronized void notify_init()
        {
            if( is_waitting )
                notify();
            else
                is_notified = true;
        }
        protected RDRecentThread(Handler hand_ui)
        {
            super();
            m_handUI = hand_ui;
        }
        @Override
        public void start()
        {
            super.start();
            wait_init();
        }
        @Override
        public void run()
        {
            Looper.prepare();
            setPriority(android.os.Process.THREAD_PRIORITY_BACKGROUND);
            m_hand = new Handler(Looper.myLooper())
            {
                public void handleMessage(Message msg)
                {
                    if( msg != null )
                    {
                        if( msg.what == 0 )//render function
                        {
                            RDRecentItem item = (RDRecentItem)msg.obj;
                            if( item.render() ) m_handUI.sendMessage(m_handUI.obtainMessage(0, item));
                            super.handleMessage(msg);
                        }
                        else//quit
                        {
                            super.handleMessage(msg);
                            getLooper().quit();
                        }
                    }
                    else
                        getLooper().quit();
                }
            };
            notify_init();
            Looper.loop();
        }
        protected synchronized void start_render( RDRecentItem item )
        {
            item.start_render();
            m_hand.sendMessage(m_hand.obtainMessage(0, item));
        }
        protected void clear_tasks()
        {
            m_hand.removeMessages(0);
        }
        public synchronized void destroy()
        {
            try
            {
                m_hand.sendEmptyMessage(100);
                join();
                m_hand = null;
                m_handUI = null;
            }
            catch(InterruptedException ignored)
            {
            }
        }
    }
    class RDRecentAdt implements ListAdapter
    {
        private RDRecentItem[] m_items;
        private DataSetObserver m_dset;
        private final RDRecentThread m_thread;
        protected RDRecentAdt()
        {
            m_thread = new RDRecentThread(new Handler(Looper.getMainLooper()){
                public void handleMessage(Message msg) {
                    RDRecentItem item = (RDRecentItem) msg.obj;
                    item.UpdateThumb();
                    item.m_view.invalidate();
                    super.handleMessage(msg);
                }
            });
            m_thread.start();
        }
        @Override
        public boolean areAllItemsEnabled() { return true; }
        @Override
        public boolean isEnabled(int position) { return true; }

        @Override
        public void registerDataSetObserver(DataSetObserver observer) {
            m_dset = observer;
        }
        @Override
        public void unregisterDataSetObserver(DataSetObserver observer) {
            m_dset = null;
        }
        @Override
        public int getCount() {
            if (m_items == null) return 0;
            return m_items.length;
        }
        @Override
        public Object getItem(int position) {
            return m_items[position];
        }
        @Override
        public long getItemId(int position) {
            return 0;
        }
        @Override
        public boolean hasStableIds() {
            return false;
        }
        @Override
        public View getView(int position, View convertView, ViewGroup parent) {
            return m_items[position].m_view;
        }
        @Override
        public int getItemViewType(int position) {
            return 0;
        }
        @Override
        public int getViewTypeCount() {
            return 1;
        }
        @Override
        public boolean isEmpty() {
            if (m_items == null) return true;
            return (m_items.length <= 0);
        }
        public boolean CanUpdate()
        {
            return (m_dset != null);
        }
        public void Update(Context ctx)
        {
            if (m_dirty)
            {
                if (m_dset != null)
                {
                    m_dset.onChanged();
                    m_dirty = false;
                    return;
                }
            }
            if (m_items != null)
            {
                for (RDRecentItem item : m_items) item.RDCancel();
                m_thread.clear_tasks();
            }
            RDRecent recent = new RDRecent(ctx);
            int cnt = recent.GetCount();
            m_items = new RDRecentItem[cnt];
            for(int cur = 0; cur < cnt; cur++)
            {
                RDRecentItem item = new RDRecentItem(ctx, m_lset);
                item.m_file = new File(recent.get_path(cnt - cur - 1));
                item.m_pageno = recent.get_page(cnt - cur - 1);
                item.m_view_type = recent.get_vtype(cnt - cur - 1);

                ImageView imgv = item.m_view.findViewById(R.id.img_more);
                imgv.setColorFilter(Global.gridview_icon_color);
                final int idx = cur;
                imgv.setOnClickListener(new OnClickListener() {
                    @Override
                    public void onClick(View v) { if (m_listener != null) m_listener.OnItemMore(item, idx); }
                });
                item.m_view.setOnClickListener(new OnClickListener() {
                    @Override
                    public void onClick(View v) { if (m_listener != null) m_listener.OnItemClick(item, idx); }
                });

                TextView tview = item.m_view.findViewById(R.id.txt_name);
                tview.setText(item.m_file.getName());

                m_items[cur] = item;
                m_thread.start_render(item);
            }
            recent.Close();

            if (m_dset != null) m_dset.onChanged();
            else m_dirty = true;
        }
        public void Remove(RDRecentItem item)
        {
            int cnt = m_items.length;
            for(int cur = 0; cur < cnt; cur++)
            {
                if (m_items[cur] == item)
                {
                    Remove(cur);
                    return;
                }
            }
        }
        public void Remove(int idx)
        {
            RDRecent recent = new RDRecent(getContext());
            recent.remove(m_items.length - idx - 1);
            recent.Close();
            int cnt = m_items.length - 1;
            RDRecentItem[] items = new RDRecentItem[cnt];
            if (idx >= 0) System.arraycopy(m_items, 0, items, 0, idx);
            for(int cur = idx; cur < cnt; cur++)
            {
                RDRecentItem item = m_items[cur + 1];
                ImageView imgv = item.m_view.findViewById(R.id.img_more);
                imgv.setColorFilter(Global.gridview_icon_color);
                final int index = cur;
                imgv.setOnClickListener(new OnClickListener() {
                    @Override
                    public void onClick(View v) { if (m_listener != null) m_listener.OnItemMore(item, index); }
                });
                item.m_view.setOnClickListener(new OnClickListener() {
                    @Override
                    public void onClick(View v) { if (m_listener != null) m_listener.OnItemClick(item, index); }
                });
                items[cur] = item;
            }
            m_items = items;
            if (m_dset != null) m_dset.onChanged();
        }
        public void Close()
        {
            m_thread.destroy();
        }
    }
    private final RDRecentAdt m_adt;
    private RDLockerSet m_lset;
    public RDRecentView(Context context, AttributeSet attrs) {
        super(context, attrs);
        RDGridView.Init(context);
        m_adt = new RDRecentAdt();
        setAdapter(m_adt);
    }
    private OnRecentListener m_listener;
    public void OpenRecent(RDLockerSet lset, OnRecentListener listener)
    {
        m_listener = listener;
        m_lset = lset;
        m_adt.Update(getContext());
    }
    public void Remove(RDRecentItem item)
    {
        m_adt.Remove(item);
    }
    public void Clear()
    {
        RDRecent recent = new RDRecent(getContext());
        recent.clear();
        recent.Close();
        m_adt.Update(getContext());
    }
    private boolean m_dirty;
    public void Update()
    {
        m_adt.Update(getContext());
    }
    public void Close()
    {
        m_adt.Close();
    }

    @Override
    protected void onAttachedToWindow() {
        super.onAttachedToWindow();
        m_adt.Update(getContext());
    }
    public boolean IsEmpty()
    {
        return m_adt.getCount() <= 0;
    }
}
