package com.radaee.view;

import android.graphics.Bitmap;
import android.graphics.Canvas;
import android.graphics.Paint;
import android.graphics.Rect;
import android.os.Handler;
import android.os.HandlerThread;
import android.os.Looper;
import android.os.Message;
import android.util.Log;

import com.radaee.pdf.VNBlock;
import com.radaee.pdf.VNCache;
import com.radaee.pdf.VNPage;

import java.util.Timer;
import java.util.TimerTask;

public class VThread extends HandlerThread implements VNPage.VNPageListener
{
	private Handler m_hand = null;
	private Handler m_handUI = null;
	private Timer m_timer;
	private TimerTask m_timer_task = null;
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
	protected VThread(Handler hand_ui)
	{
		super("VThread");
		m_handUI = hand_ui;
	}
	@Override
    public void start()
	{
		super.start();
		wait_init();
		m_timer = new Timer();
		m_timer_task = new TimerTask()
        {
        	public void run()
        	{
        		m_handUI.sendEmptyMessage(100);
        	}
        };
        m_timer.schedule(m_timer_task, 100, 100);
		m_hand = new Handler(getLooper())
		{
			@Override
			public void handleMessage(Message msg)
			{
				if( msg != null )
				{
					if( msg.what == 0 )//render function
					{
						long cache = (((long)msg.arg1) << 32) | (((long)msg.arg2)& 0xffffffffL);
						VNCache.render(cache, false);
						m_handUI.sendMessage(m_handUI.obtainMessage(0, msg.arg1, msg.arg2 ));
						msg.obj = null;
						super.handleMessage(msg);
					}
					else if( msg.what == 1 )
					{
						long cache = (((long)msg.arg1) << 32) | (((long)msg.arg2)& 0xffffffffL);
						VNCache.destroy(cache);
						msg.obj = null;
						super.handleMessage(msg);
					}
					else if( msg.what == 2 )
					{
						int ret = ((VFinder)msg.obj).find();
						m_handUI.sendMessage( m_handUI.obtainMessage(1, ret, 0) );
						msg.obj = null;
						super.handleMessage(msg);
					}
					else if( msg.what == 3 )
					{
						long blk = (((long)msg.arg1) << 32) | (((long)msg.arg2)& 0xffffffffL);
						VNBlock.Render(blk);
						m_handUI.sendMessage( m_handUI.obtainMessage(2, msg.arg1, msg.arg2) );
						super.handleMessage(msg);
					}
					else if( msg.what == 4 )
					{
						long blk = (((long)msg.arg1) << 32) | (((long)msg.arg2)& 0xffffffffL);
						VNBlock.destroy(blk);
						super.handleMessage(msg);
					}
					else if(msg.what == 100)
					{
						getLooper().quit();
						super.handleMessage(msg);
					}
					m_pending--;
				}
				else
				{
					getLooper().quit();
				}
			}
		};
	}
	@Override
	protected void onLooperPrepared()
	{
		notify_init();
	}
	private int m_pending = 0;
	protected void start_find(VFinder finder)
	{
		m_pending++;
		m_hand.sendMessage(m_hand.obtainMessage(2, finder));
	}
	public synchronized void destroy()
	{
		try
		{
			m_timer.cancel();
			m_timer_task.cancel();
			m_timer = null;
			m_timer_task = null;
			m_hand.sendEmptyMessage(100);
			join();
			m_hand = null;
			m_handUI = null;
		}
		catch(Exception e)
		{
			e.printStackTrace();
		}
	}

	@Override
	public void Render(long vcache) {
		m_pending++;
		m_hand.sendMessage(m_hand.obtainMessage(0, (int)(vcache >> 32), (int)vcache));
	}

	@Override
	public void Dealloc(long vcache) {
		//Log.e("VTHREAD", "before cache destroy:" + String.format("%x", vcache));
		m_pending++;
		m_hand.sendMessage(m_hand.obtainMessage(1, (int)(vcache >> 32), (int)vcache));
	}

	@Override
	public void BlkRender(long block) {
		m_pending++;
		m_hand.sendMessage(m_hand.obtainMessage(3, (int)(block >> 32), (int)block));
	}

	@Override
	public void BlkDealloc(long block) {
		//Log.e("VTHREAD", "before block destroy:" + String.format("%x", block));
		m_pending++;
		m_hand.sendMessage(m_hand.obtainMessage(4, (int)(block >> 32), (int)block));
	}
	protected synchronized void wait_pending()
	{
		try {
			while (m_pending > 0) {
				wait(50);
			}
		}
		catch(Exception ex)
		{
			ex.printStackTrace();
		}
	}
	private final Rect m_src = new Rect();
	private final Rect m_dst = new Rect();
	private static Paint ms_paint = null;
	@Override
	public boolean Draw(long block, Canvas canvas, int src_left, int src_top, int src_right, int src_bottom, int dst_left, int dst_top, int dst_right, int dst_bottom)
	{
		if(canvas == null) return false;
		m_src.left = src_left;
		m_src.top = src_top;
		m_src.right = src_right;
		m_src.bottom = src_bottom;

		m_dst.left = dst_left;
		m_dst.top = dst_top;
		m_dst.right = dst_right;
		m_dst.bottom = dst_bottom;

		if(ms_paint == null) {
			ms_paint = new Paint();
			ms_paint.setStyle(Paint.Style.FILL);
			ms_paint.setColor(-1);
		}
		Bitmap bmp = VNBlock.bmp(block);
		if(bmp != null)
		{
			canvas.drawBitmap(bmp, m_src, m_dst, null);
			return true;
		}
		else
		{
			canvas.drawRect(m_dst, ms_paint);
			return VNBlock.getSta(block) == 0;
		}
	}
}
