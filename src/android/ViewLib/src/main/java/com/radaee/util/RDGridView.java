package com.radaee.util;

import android.content.Context;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.os.Handler;
import android.os.Looper;
import android.os.Message;
import android.util.AttributeSet;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.recyclerview.widget.GridLayoutManager;
import androidx.recyclerview.widget.RecyclerView;

import com.radaee.viewlib.R;

import java.io.File;
import java.io.FileFilter;
import java.util.Vector;

public class RDGridView extends RecyclerView
{
    protected static Bitmap m_def_pdf_icon = null;
    protected static Bitmap m_def_dir_icon = null;
    protected static void Init(Context ctx)
    {
        if( m_def_pdf_icon == null )
            m_def_pdf_icon = BitmapFactory.decodeResource(ctx.getResources(), R.drawable.ic_grid_file);
        if( m_def_dir_icon == null )
            m_def_dir_icon = BitmapFactory.decodeResource(ctx.getResources(), R.drawable.ic_grid_folder0);
    }
    public static class RDGridAdt extends RecyclerView.Adapter
    {
        public interface OnGridListener
        {
            void OnItemClick(RDGridItem item);
            void OnItemMore(RDGridItem item);
            void OnPathChanged(String root, String path);
        }
        private static class RDGridThread extends Thread
        {
            private Handler m_hand = null;
            private Handler m_handUI = null;
            private boolean is_notified = false;
            private boolean is_waitting = false;
            private RDGridItem m_item = null;
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
            protected RDGridThread(Handler hand_ui)
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
                                set_item((RDGridItem)msg.obj);
                                if( m_item.render() ) m_handUI.sendMessage(m_handUI.obtainMessage(0, m_item));
                                set_item(null);
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
            protected synchronized void start_render( RDGridItem item )
            {
                item.start_render();
                m_hand.sendMessage(m_hand.obtainMessage(0, item));
            }
            private synchronized void set_item(RDGridItem item)
            {
                m_item = item;
            }
            protected synchronized void clear_tasks()
            {
                m_hand.removeMessages(0);
                if (m_item != null)
                    m_item.RDCancel();
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

        private OnGridListener m_listener;
        private RDLockerSet m_lset;
        protected RDGridAdt(Context ctx)
        {
            Init(ctx);
        }
        protected void RDSetListener(OnGridListener listener, RDLockerSet lset)
        {
            m_listener = listener;
            m_lset = lset;
        }
        private RDGridItem.RDFileItem[] m_items;
        private int m_items_cnt;
        private String m_root;
        private String m_subdir;
        private final RDGridThread m_thread = new RDGridThread(new Handler(Looper.getMainLooper()){
            public void handleMessage(Message msg) {
                RDGridItem item = (RDGridItem) msg.obj;
                item.UpdateThumb();
                item.m_vThumb.invalidate();
                super.handleMessage(msg);
            }
        });
        /**
         * new instance of holder.
         * @param parent
         * @param viewType
         * @return
         */
        @NonNull
        @Override
        public RecyclerView.ViewHolder onCreateViewHolder(@NonNull ViewGroup parent, int viewType) {
            View view = LayoutInflater.from(parent.getContext()).inflate(R.layout.item_file_grid, parent, false);
            return new RDGridItem(view, m_lset);
        }

        /**
         * assign data to holder
         * @param holder destination data object
         * @param position index
         */
        @Override
        public void onBindViewHolder(@NonNull RecyclerView.ViewHolder holder, int position)
        {
            RDGridItem item = (RDGridItem)holder;
            if (item.m_file != null) item.RDCancel();

            item.m_file = m_items[position];
            item.UpdateThumb();
            item.m_vMore.setOnClickListener(new View.OnClickListener() {
                @Override
                public void onClick(View v) {
                    if (m_listener != null) m_listener.OnItemMore(item);
                }
            });
            item.m_parent.setOnClickListener(new View.OnClickListener() {
                @Override
                public void onClick(View v)
                {
                    if (item.IsDir())
                    {
                        if (m_subdir == null) RDGotoSubDir(item.m_file.m_file.getName());
                        else RDGotoSubDir(m_subdir + "/" + item.m_file.m_file.getName());
                    }
                    else if (m_listener != null) m_listener.OnItemClick(item);
                }
            });
            if (item.m_file.m_file.isDirectory())
            {
                item.HideMore(true);
                item.UpdateNameAndSize();
            }
            else
            {
                item.HideMore(false);
                item.itemView.post(new Runnable() {
                    @Override
                    public void run() {
                        item.UpdateNameAndSize();
                        m_thread.start_render(item);
                    }
                });
            }
        }
        @Override
        public int getItemCount()
        {
            return m_items_cnt;
        }

        public void RDRemove(int pos)
        {
            m_items_cnt--;
            for (int cur = pos; cur < m_items_cnt; cur++)
            {
                m_items[cur] = m_items[cur + 1];
            }
            m_items[m_items_cnt] = null;
            notifyItemRemoved(pos);
        }
        public void RDSetRoot(String path)
        {
            m_root = path;
            m_thread.start();
        }

        private void insert_item(Vector<File> files, File item)
        {
            int left = 0;
            int right = files.size() - 1;
            if( item.isDirectory() )
            {
                while( left <= right )
                {
                    int mid = (left + right)>>1;
                    File tmp = files.get(mid);
                    if( !tmp.isDirectory() )
                        right = mid - 1;
                    else
                    {
                        String name0 = item.getName();
                        String name1 = tmp.getName();
                        int ret = name0.compareToIgnoreCase(name1);
                        if( ret == 0 )
                        {
                            left = mid;
                            break;
                        }
                        if( ret > 0 ) left = mid + 1;
                        else right = mid - 1;
                    }
                }
            }
            else
            {
                while( left <= right )
                {
                    int mid = (left + right)>>1;
                    File tmp = files.get(mid);
                    if( tmp.isDirectory() )
                        left = mid + 1;
                    else
                    {
                        String name0 = item.getName();
                        String name1 = tmp.getName();
                        int ret = name0.compareToIgnoreCase(name1);
                        if( ret == 0 )
                        {
                            left = mid;
                            break;
                        }
                        if( ret > 0 ) left = mid + 1;
                        else right = mid - 1;
                    }
                }
            }
            files.insertElementAt(item, left);
        }

        public void RDGotoSubDir(String subdir)
        {
            if (m_items != null)
            {
                m_thread.clear_tasks();
            }

            if (subdir == null || subdir.isEmpty())
                m_subdir = null;
            else
                m_subdir = subdir;

            String path = RDGetPath();
            File file = new File(path);
            if (m_listener != null) m_listener.OnPathChanged(m_root, path);
            File[] files = file.listFiles(new FileFilter() {
                @Override
                public boolean accept(File pathname) {
                    if (pathname.isDirectory()) return true;
                    String fname = pathname.getName();
                    //if (fname.length() > 5) {
                    //    String sext = fname.substring(fname.length() - 5).toLowerCase();
                    //    return sext.compareTo(".docx") == 0;
                    //}
                    if (fname.length() > 4) {
                        String sext = fname.substring(fname.length() - 4).toLowerCase();
                        return sext.compareTo(".pdf") == 0;
                    }
                    return false;
                }
            });
            if (files == null)
            {
                m_items_cnt = 0;
                m_items = null;
            }
            else
            {
                m_items_cnt = files.length;
                //sort all files by name, and group by type(directory, file)
                Vector<File> file_set = new Vector<File>();
                for (int cur = 0; cur < m_items_cnt; cur++)
                    insert_item(file_set, files[cur]);

                m_items = new RDGridItem.RDFileItem[m_items_cnt];
                for (int cur = 0; cur < m_items_cnt; cur++) {
                    RDGridItem.RDFileItem item = new RDGridItem.RDFileItem();
                    item.m_file = file_set.get(cur);
                    if (item.m_file.isDirectory())
                        item.m_thumb = m_def_dir_icon;
                    else
                        item.m_thumb = m_def_pdf_icon;
                    m_items[cur] = item;
                }
            }
            notifyDataSetChanged();
        }
        public void RDRefresh()
        {
            RDGotoSubDir(m_subdir);
        }
        public void RDGoUp()
        {
            if (m_subdir == null || m_subdir.isEmpty()) return;
            int idx = m_subdir.lastIndexOf('/');
            if (idx > 0) RDGotoSubDir(m_subdir.substring(0, idx));
            else RDGotoSubDir(null);
        }
        public String RDGetPath()
        {
            return (m_subdir == null || m_subdir.isEmpty()) ? m_root : m_root + "/" + m_subdir;
        }
        public void RDClose()
        {
            m_thread.destroy();
            m_items = null;
        }
    }
    private final RDGridAdt m_adt;
    public RDGridView(@NonNull Context context, @Nullable AttributeSet attrs)
    {
        super(context, attrs);
        GridLayoutManager lay_m = new GridLayoutManager(context, 2);
        lay_m.setOrientation(GridLayoutManager.VERTICAL);
        setLayoutManager(lay_m);
        m_adt = new RDGridAdt(context);
        setAdapter(m_adt);
    }
    protected void onSizeChanged (int w, int h, int oldw, int oldh)
    {
        super.onSizeChanged(w, h, oldw, oldh);
        GridLayoutManager lay_m = (GridLayoutManager)getLayoutManager();
        if (lay_m == null) return;
        int pw = (int)(getContext().getResources().getDisplayMetrics().density * 160);
        int cols = w / pw;
        if (cols < 1) cols = 1;
        lay_m.setSpanCount(cols);
        this.invalidate();
    }
    public void RDSetRoot(String path)
    {
        m_adt.RDSetRoot(path);
        m_adt.RDGotoSubDir(null);
    }
    public void RDSetListener(RDLockerSet lset, RDGridAdt.OnGridListener listener)
    {
        m_adt.RDSetListener(listener, lset);
    }
    public String RDGetPath()
    {
        return m_adt.RDGetPath();
    }
    public void RDFresh()
    {
        m_adt.RDRefresh();
    }
    public void RDGoUp()
    {
        m_adt.RDGoUp();
    }
    public void RDClose()
    {
        m_adt.RDClose();
    }
    public void RDRemove(int pos)
    {
        m_adt.RDRemove(pos);
    }
}
