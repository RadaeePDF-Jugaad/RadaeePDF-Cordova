package com.radaee.view;

import java.util.Timer;
import java.util.TimerTask;

import android.os.Handler;
import android.os.Looper;
import android.os.Message;

/**
Inner class.<br/>
developer should not use this.
*/
@Deprecated
public class PDFVThread extends Thread
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
		catch(Exception e)
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
	protected PDFVThread(Handler hand_ui)
	{
		super();
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
        m_timer.schedule(m_timer_task, 100, 50);
	}
	@Override
    public void run()
	{
		Looper.prepare();
		m_hand = new Handler(Looper.myLooper())
		{
			public void handleMessage(Message msg)
			{
				if( msg != null )
				{
					if( msg.what == 0 )//render function
					{
						((PDFVCache)msg.obj).Render();
						m_handUI.sendMessage( m_handUI.obtainMessage(0, (PDFVCache)msg.obj ) );
						msg.obj = null;
						super.handleMessage(msg);
					}
					else if( msg.what == 1 )
					{
						((PDFVCache)msg.obj).Clear();
						msg.obj = null;
						super.handleMessage(msg);
					}
					else if( msg.what == 2 )
					{
						int ret = ((PDFVFinder)msg.obj).find();
						m_handUI.sendMessage( m_handUI.obtainMessage(1, ret, 0) );
						msg.obj = null;
						super.handleMessage(msg);
					}
					else if( msg.what == 3 )
					{
						((PDFVCache)msg.obj).RenderThumb();
						m_handUI.sendMessage( m_handUI.obtainMessage(0, (PDFVCache)msg.obj ) );
						msg.obj = null;
						super.handleMessage(msg);
					}
					else if( msg.what == 100 )//quit
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
	public final void start_render( PDFVPage page )
	{
		switch( page.RenderPrepare() )
		{
		case 1: break;
		case 2: end_render( page ); start_render(page); break;
		default: m_hand.sendMessage(m_hand.obtainMessage(0, page.m_cache)); break;
		}
	}
	protected final void start_render_thumb( PDFVPage page )
	{
		switch( page.RenderPrepare() )
		{
		case 1: break;
		case 2: end_render( page ); start_render_thumb(page); break;
		default: m_hand.sendMessage(m_hand.obtainMessage(3, page.m_cache)); break;
		}
	}
	protected final void end_render( PDFVPage page )
	{
		PDFVCache cache = page.CancelRender();
		if( cache != null )
			m_hand.sendMessage(m_hand.obtainMessage(1, cache));
	}
	protected final void start_find( PDFVFinder finder )
	{
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
		catch(InterruptedException e)
		{
		}
	}
}
