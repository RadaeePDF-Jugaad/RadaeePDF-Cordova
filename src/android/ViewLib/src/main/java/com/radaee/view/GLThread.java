package com.radaee.view;

import android.os.Handler;
import android.os.Looper;
import android.os.Message;
import android.os.SystemClock;
import android.util.Log;

import com.radaee.pdf.Page;
import com.radaee.pdf.VNBlock;
import com.radaee.pdf.VNCache;

import javax.microedition.khronos.opengles.GL10;

public class GLThread extends Thread {
    private Handler m_hand = null;
    private Handler m_hand_gl = null;
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
    @Override
    public void run()
    {
        Looper.prepare();
        m_hand = new Handler(Looper.myLooper())
        {
            public void handleMessage(Message msg)
            {
                if( msg == null ) return;
                if( msg.what == 0 )//render function
                {
                    GLBlock blk = (GLBlock)msg.obj;
                    blk.bk_render();
                    if(m_hand_gl != null)
                        m_hand_gl.sendMessage( m_hand_gl.obtainMessage(0, 0, 0, blk) );
                    msg.obj = null;
                    super.handleMessage(msg);
                }
                else if( msg.what == 1 )
                {
                    GLBlock blk = (GLBlock)msg.obj;
                    blk.bk_destroy();
                    msg.obj = null;
                    super.handleMessage(msg);
                }
                else if( msg.what == 2 )
                {
                    int ret = ((VFinder)msg.obj).find();
                    if(m_hand_gl != null)
                        m_hand_gl.sendMessage( m_hand_gl.obtainMessage(2, ret, 0, msg.obj) );
                    msg.obj = null;
                    super.handleMessage(msg);
                }
                else if(msg.what == 3)
                {
                    ((GLReflowBlock)msg.obj).render();
                }
                else if(msg.what == 4)
                {
                    ((GLReflowBlock)msg.obj).destroy();
                }
                else if(msg.what == 5)
                {
                    ((Page)msg.obj).Close();
                }
                else if( msg.what == 100 )//quit
                {
                    super.handleMessage(msg);
                    getLooper().quit();
                }
            }
        };
        notify_init();
        Looper.loop();
    }
    public void render_start(GLBlock blk)
    {
        if(blk != null && blk.gl_start())
        {
            m_hand.sendMessage(m_hand.obtainMessage(0, blk));
        }
    }
    public boolean render_end(GL10 gl10, GLBlock blk)
    {
        if(blk == null) return false;
        if(blk.gl_end(gl10))
        {
            m_hand.sendMessage(m_hand.obtainMessage(1, blk));
            return true;
        }
        else return false;
    }
    protected void find_start(VFinder finder)
    {
        m_hand.sendMessage(m_hand.obtainMessage(2, finder));
    }
    @Override
    public void start()
    {
        super.start();
        wait_init();
    }
    public void set_handler(Handler hand_gl)
    {
        m_hand_gl = hand_gl;
    }
    public synchronized void destroy()
    {
        if(m_hand == null) return;
        try
        {
            m_hand.sendEmptyMessage(100);
            join();
            m_hand = null;
        }
        catch(InterruptedException e)
        {
        }
    }
    public void reflow_start(GLReflowBlock blk)
    {
        if(blk.render_start())
            m_hand.sendMessage(m_hand.obtainMessage(3, blk));
    }
    public void reflow_end(GLReflowBlock blk)
    {
        if(blk.render_cancel())
            m_hand.sendMessage(m_hand.obtainMessage(4, blk));
    }
    public void reflow_destroy_page(Page page)
    {
        if(page == null) return;
        m_hand.sendMessage(m_hand.obtainMessage(5, page));
    }
}
