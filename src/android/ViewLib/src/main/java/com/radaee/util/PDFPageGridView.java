package com.radaee.util;

import android.content.Context;
import android.graphics.Bitmap;
import android.os.Handler;
import android.os.Looper;
import android.os.Message;
import android.util.AttributeSet;
import android.view.View;
import android.view.ViewGroup;
import android.widget.AbsListView;
import android.widget.BaseAdapter;
import android.widget.GridView;
import android.widget.ImageView;
import android.widget.RelativeLayout;

import com.radaee.pdf.Matrix;
import com.radaee.pdf.Page;
import com.radaee.viewlib.R;

public class PDFPageGridView extends GridView {
    public static class PDFPageGridAdt extends BaseAdapter {
        private class PDFPageGridItem
        {
            boolean render()
            {
                if(m_status < 0) return false;
                float pw = m_doc.GetPageWidth(m_pageno);
                float ph = m_doc.GetPageHeight(m_pageno);
                float scale1 = m_w / pw;
                float scale2 = m_h / ph;
                if(scale1 > scale2) scale1 = scale2;
                int iw = (int)(pw * scale1);
                int ih = (int)(ph * scale2);
                Bitmap bmp = Bitmap.createBitmap(iw, ih, Bitmap.Config.ARGB_8888);
                bmp.eraseColor(-1);
                Page page = m_doc.GetPage(m_pageno);
                Matrix mat = new Matrix(scale1, -scale1, 0, ih);
                m_page = page;
                page.RenderToBmp(bmp, mat);
                mat.Destroy();
                if(m_status < 0)
                {
                    bmp.recycle();
                    return false;
                }
                else
                {
                    m_bmp = bmp;
                    m_status = 2;
                    return true;
                }
            }
            void clear()
            {
                if (m_page == null) return;
                else m_page.Close();
                m_page = null;
            }
            RelativeLayout m_lay;
            ImageView m_img;
            Bitmap m_bmp;
            Page m_page;
            int m_w;
            int m_h;
            int m_pageno;
            int m_rotate_org;
            int m_rotate;
            boolean m_deleted;
            boolean render_start()
            {
                if(m_status == 0)
                {
                    m_status = 1;
                    return true;
                }
                return false;
            }
            boolean render_end()
            {
                if(m_status > 0)
                {
                    m_status = -1;
                    return true;
                }
                return false;
            }
            int m_status;
        }

        static private class PDFPageGridThread extends Thread {
            private Handler m_hand = null;
            private Handler m_handUI = null;
            private boolean is_notified = false;
            private boolean is_waitting = false;

            private synchronized void wait_init() {
                try {
                    if (is_notified)
                        is_notified = false;
                    else {
                        is_waitting = true;
                        wait();
                        is_waitting = false;
                    }
                } catch (Exception ignored) {
                }
            }

            private synchronized void notify_init() {
                if (is_waitting)
                    notify();
                else
                    is_notified = true;
            }

            protected PDFPageGridThread(Handler hand_ui) {
                super();
                m_handUI = hand_ui;
            }

            @Override
            public void start() {
                super.start();
                wait_init();
            }

            @Override
            public void run() {
                Looper.prepare();
                setPriority(android.os.Process.THREAD_PRIORITY_BACKGROUND);
                m_hand = new Handler(Looper.myLooper()) {
                    public void handleMessage(Message msg) {
                        if (msg != null) {
                            if (msg.what == 0)//render function
                            {
                                PDFPageGridItem item = (PDFPageGridItem) msg.obj;
                                if (item.render())
                                    m_handUI.sendMessage(m_handUI.obtainMessage(0, item));
                                super.handleMessage(msg);
                            }
                            else if (msg.what == 1)
                            {
                                PDFPageGridItem item = (PDFPageGridItem) msg.obj;
                                item.clear();
                                m_handUI.sendMessage(m_handUI.obtainMessage(1, item));
                                super.handleMessage(msg);
                            }
                            else//quit
                            {
                                super.handleMessage(msg);
                                getLooper().quit();
                            }
                        } else
                            getLooper().quit();
                    }
                };
                notify_init();
                Looper.loop();
            }
            protected synchronized void end_render(PDFPageGridItem item) {
                if (!item.render_end()) return;
                m_hand.sendMessage(m_hand.obtainMessage(1, item));
            }
            protected synchronized void start_render(PDFPageGridItem item) {
                if (!item.render_start()) return;
                m_hand.sendMessage(m_hand.obtainMessage(0, item));
            }

            public synchronized void destroy() {
                try {
                    m_hand.sendEmptyMessage(100);
                    join();
                    m_hand = null;
                    m_handUI = null;
                } catch (InterruptedException ignored) {
                }
            }
        }

        private final com.radaee.pdf.Document m_doc;
        private final PDFPageGridItem[] m_pages_org;
        private PDFPageGridItem[] m_pages;
        private final PDFPageGridThread m_thread;
        private boolean m_modified;
        private void refresh_pages()
        {
            int count = 0;
            int cur;
            for(cur = 0; cur < m_pages_org.length; cur++)
            {
                PDFPageGridItem item = m_pages_org[cur];
                if (!item.m_deleted) count++;
            }
            m_pages = new PDFPageGridItem[count];
            int pcur = 0;
            for(cur = 0; cur < m_pages_org.length; cur++)
            {
                PDFPageGridItem item = m_pages_org[cur];
                if (!item.m_deleted) m_pages[pcur++] = item;
            }
            notifyDataSetChanged();
        }
        static private float ms_density = 0;
        public PDFPageGridAdt(Context ctx, com.radaee.pdf.Document doc)
        {
            m_doc = doc;
            if (ms_density == 0)
                ms_density = ctx.getResources().getDisplayMetrics().density;
            int pages_cnt = m_doc.GetPageCount();
            m_pages_org = new PDFPageGridItem[pages_cnt];
            m_pages = new PDFPageGridItem[pages_cnt];
            for(int ip = 0; ip < pages_cnt; ip++)
            {
                PDFPageGridItem item = new PDFPageGridItem();
                item.m_lay = (RelativeLayout)RelativeLayout.inflate(ctx, R.layout.item_page, null);
                item.m_img = item.m_lay.findViewById(R.id.img_page);
                item.m_w = (int)(ms_density * 100);
                item.m_h = (int)(ms_density * 100);
                item.m_pageno = ip;
                Page page = m_doc.GetPage(ip);
                item.m_rotate = page.GetRotate();
                item.m_rotate_org = item.m_rotate;
                page.Close();
                m_pages_org[ip] = item;
                m_pages[ip] = item;
                final PDFPageGridItem fitem = item;
                ImageView view = item.m_lay.findViewById(R.id.img_rotate);
                view.setOnClickListener(new View.OnClickListener() {
                    @Override
                    public void onClick(View v) {
                        fitem.m_rotate += 90;
                        fitem.m_rotate %= 360;
                        int dang = fitem.m_rotate - fitem.m_rotate_org;
                        if(dang < 0) dang += 360;
                        fitem.m_img.setPivotX(fitem.m_img.getWidth() >> 1);
                        fitem.m_img.setPivotY(fitem.m_img.getHeight() >> 1);
                        fitem.m_img.setRotation(dang);
                        m_modified = true;
                    }
                });
                view = item.m_lay.findViewById(R.id.img_delete);
                view.setOnClickListener(new View.OnClickListener() {
                    @Override
                    public void onClick(View v) {
                        if(m_pages.length < 2)
                        {
                            return;
                        }
                        fitem.m_deleted = true;
                        m_thread.end_render(fitem);
                        m_modified = true;
                        refresh_pages();
                    }
                });
            }
            m_thread = new PDFPageGridThread(new Handler(Looper.getMainLooper()){
                public void handleMessage(Message msg) {
                    if (msg == null) return;
                    PDFPageGridItem item = (PDFPageGridItem)msg.obj;
                    if( msg.what == 1)
                    {
                        item.m_bmp = null;
                        item.m_status = 0;
                    }
                    item.m_img.setImageBitmap(item.m_bmp);
                }
            });
            m_thread.start();
        }

        public void close()
        {
            m_thread.destroy();
        }

        public void refresh_range(int item0, int item1)
        {
            int ip = 0;
            while(ip < item0)
            {
                m_thread.end_render(m_pages[ip++]);
            }
            while(ip < item1)
            {
                m_thread.start_render(m_pages[ip++]);
            }
            while(ip < m_pages.length)
            {
                m_thread.end_render(m_pages[ip++]);
            }
        }

        @Override
        public int getCount() {
            if(m_doc == null) return 0;
            return m_pages.length;
        }

        @Override
        public Object getItem(int position) {
            if(m_doc == null) return null;
            return m_pages[position];
        }

        @Override
        public long getItemId(int position) {
            return 0;
        }

        @Override
        public View getView(int position, View convertView, ViewGroup parent) {
            if(m_doc == null) return null;
            PDFPageGridItem item = m_pages[position];
            if(item == null) return null;
            return item.m_lay;
        }

        public boolean[] getRemoval()
        {
            boolean[] ret = new boolean[m_pages_org.length];
            for(int pcur = 0; pcur < m_pages_org.length; pcur++)
            {
                ret[pcur] = m_pages_org[pcur].m_deleted;
            }
            return ret;
        }
        public int[] getRotate()
        {
            int[] ret = new int[m_pages_org.length];
            for(int pcur = 0; pcur < m_pages_org.length; pcur++)
            {
                ret[pcur] = m_pages_org[pcur].m_rotate | (m_pages_org[pcur].m_rotate_org << 16);
            }
            return ret;
        }
        public boolean isModified()
        {
            return m_modified;
        }
    }
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
