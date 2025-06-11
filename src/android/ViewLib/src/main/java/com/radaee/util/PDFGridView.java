package com.radaee.util;

import java.io.File;
import java.util.Vector;

import android.content.Context;
import android.content.res.Configuration;
import android.os.Handler;
import android.os.Looper;
import android.os.Message;
import android.util.AttributeSet;
import android.util.DisplayMetrics;
import android.view.View;
import android.view.ViewGroup;
import android.widget.BaseAdapter;
import android.widget.GridView;

public class PDFGridView extends GridView
{
	//static protected int clr_back = 0xFFCCCCCC;
	//static protected int clr_text = 0xFF000044;
	public static class SnatchItem
	{
		public String m_path;
		public String m_name;
		public PDFGridItem m_item;
	}
	public static class PDFGridAdt extends BaseAdapter
	{
		private final Context m_context;
		private final PDFGridThread m_thread;
		private final Vector<SnatchItem> m_items = new Vector<SnatchItem>();
		private void insert_item( SnatchItem item )
		{
			int left = 0;
			int right = m_items.size() - 1;
			if( item.m_item.is_dir() )
			{
				while( left <= right )
				{
					int mid = (left + right)>>1;
					SnatchItem tmp = m_items.get(mid);
					if( !tmp.m_item.is_dir() )
						right = mid - 1;
					else
					{
						int ret = item.m_name.compareToIgnoreCase(tmp.m_name);
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
					SnatchItem tmp = m_items.get(mid);
					if( tmp.m_item.is_dir() )
						left = mid + 1;
					else
					{
						int ret = item.m_name.compareToIgnoreCase(tmp.m_name);
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
			m_items.insertElementAt(item, left);
		}
		public void destroy()
		{
			int cur = 0;
			int cnt = m_items.size();
			while( cur < cnt )
			{
				m_items.get(cur).m_item.page_destroy();
				cur++;
			}
			m_thread.destroy();
			m_items.clear();
		}
		public void set_dir( File file, boolean need_up )
		{
			int cur = 0;
			int cnt = m_items.size();
			while( cur < cnt )
			{
				m_items.get(cur).m_item.page_destroy();
				cur++;
			}
			m_items.clear();
			{
				SnatchItem item = new SnatchItem();
				item.m_name = ".";
				item.m_path = null;
				item.m_item = new PDFGridItem(m_context, null);
				item.m_item.set_dir(item.m_name, item.m_path);
				insert_item( item );
			}
			if( need_up )
			{
				SnatchItem item = new SnatchItem();
				item.m_name = "..";
				item.m_path = null;
				item.m_item = new PDFGridItem(m_context, null);
				item.m_item.set_dir(item.m_name, item.m_path);
				insert_item( item );
			}

			File[] files = file.listFiles();
			if( files == null )
			{
				notifyDataSetChanged();
				return;
			}
			cur = 0;
			cnt = files.length;
			while( cur < cnt )
			{
				if( !files[cur].isHidden() )
				{
					if( files[cur].isFile() )
					{
						String name = files[cur].getName();
						int len = name.length();
						if( len > 4 )
						{
							String ext = name.substring(name.length() - 4);
							if( ext.compareToIgnoreCase(".pdf") == 0 )
							{
								SnatchItem item = new SnatchItem();
								item.m_name = files[cur].getName();
								item.m_path = files[cur].getPath();
								item.m_item = new PDFGridItem(m_context, null);
								item.m_item.set_file(m_thread, item.m_name, item.m_path);
								insert_item( item );
							}
						}
					}
					if( files[cur].isDirectory() )
					{
						SnatchItem item = new SnatchItem();
						item.m_name = files[cur].getName();
						item.m_path = files[cur].getPath();
						item.m_item = new PDFGridItem(m_context, null);
						item.m_item.set_dir(item.m_name, item.m_path);
						insert_item( item );
					}
				}
				cur++;
			}
			notifyDataSetChanged();
		}
		public PDFGridAdt( Context ctx )
		{
			m_context = ctx;
			Handler hand_ui = new Handler(Looper.getMainLooper()) {
				public void handleMessage(Message msg) {
					PDFGridItem item = (PDFGridItem) msg.obj;
					item.page_set();
					notifyDataSetChanged();
					super.handleMessage(msg);
				}
			};
			m_thread = new PDFGridThread(hand_ui);
			m_thread.start();
		}
		public int getCount()
		{
			return m_items.size();
		}

		public Object getItem(int arg0)
		{
			return m_items.get(arg0);
		}

		public long getItemId(int position)
		{
			return 0;
		}

		public View getView(int position, View convertView, ViewGroup parent)
		{
			return m_items.get(position).m_item;
		}
	}
	public static class PDFGridThread extends Thread
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
		protected PDFGridThread(Handler hand_ui)
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
							PDFGridItem item = (PDFGridItem)msg.obj;
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
		protected synchronized void start_render( PDFGridItem item )
		{
			m_hand.sendMessage(m_hand.obtainMessage(0, item));
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
	private PDFGridAdt m_adt;
	private String m_root;
	private String m_cur;
	public PDFGridView(Context context, AttributeSet attrs)
	{
		super(context, attrs);
		m_adt = new PDFGridAdt(context);
		DisplayMetrics dm = getContext().getResources().getDisplayMetrics();
		if(dm.widthPixels > dm.heightPixels)
			setNumColumns(5);
		else
			setNumColumns(3);
		this.setBackgroundColor(0xFF444444);
		this.setAdapter(m_adt);
	}
	public void PDFSetRootPath(String path)
	{
		m_root = path;
		m_cur = path;
		File root = new File( m_cur );
		int w = getWidth();
		int h = getHeight();
		if( w >0 || h > 0 )
		{
			if(w > h)
				setNumColumns(5);
			else
				setNumColumns(3);
		}
		else
		{
			DisplayMetrics dm = getContext().getResources().getDisplayMetrics();
			if(dm.widthPixels > dm.heightPixels)
				setNumColumns(5);
			else
				setNumColumns(3);
		}
		if( root.exists() && root.isDirectory() )
		{
			m_adt.set_dir(root, false);
		}
	}
	public void PDFGotoSubdir(String name)
	{
		String new_path = m_cur;
		if (name.equals("."))
		{
		}
		else if(name.equals(".."))
		{
			int index = m_cur.lastIndexOf('/');
			if( index < 0 ) return;
			new_path = new_path.substring(0, index);
		}
		else
		{
			new_path += "/";
			new_path += name;
		}
		File dir = new File( new_path );
		if( dir.exists() && dir.isDirectory() )
		{
			m_adt.notifyDataSetInvalidated();
			m_cur = new_path;
			m_adt.set_dir(dir, m_cur.compareTo(m_root) != 0);
		}
	}
	public void close()
	{
        if(m_adt != null) {
            m_adt.destroy();
            m_adt = null;
        }
	}
	public String getPath() {
	    return m_cur;	    
	}

	@Override
	public void onConfigurationChanged(Configuration newConfig)
	{
	    super.onConfigurationChanged(newConfig);
	    if (newConfig.orientation == Configuration.ORIENTATION_PORTRAIT)
	    {
	        setNumColumns(3);
	    }
	    else if (newConfig.orientation == Configuration.ORIENTATION_LANDSCAPE)
	    {
	        setNumColumns(5);
	    }
	}
	
	/*protected void onSizeChanged (int w, int h, int oldw, int oldh)
	{
		if( w * 3 > h * 5 )
			this.setNumColumns(5);
		else if( w * 3 < h * 4 )
			this.setNumColumns(4);
		else
			this.setNumColumns(3);
		this.invalidate();
	}*/
    @Override
    protected void finalize() throws Throwable
    {
        close();
        super.finalize();
    }
}
