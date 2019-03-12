package com.radaee.reader;

import android.content.Context;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.view.animation.Animation;
import android.view.animation.TranslateAnimation;
import android.widget.RelativeLayout;

public class PDFTopBar
{
	private RelativeLayout m_parent = null;
	private View m_view = null;
	PDFTopBar(RelativeLayout parent, int resource)
	{
		Context context = parent.getContext();
		m_view = LayoutInflater.from(context).inflate(resource, null);
        m_parent = parent;
		RelativeLayout.LayoutParams lp = new RelativeLayout.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.WRAP_CONTENT);
		lp.addRule(RelativeLayout.CENTER_HORIZONTAL);
		m_parent.addView(m_view, lp);
		m_view.setVisibility(View.INVISIBLE);
	}
	public final View BarGetView(){return m_view;}
	public final void BarShow()
	{
		m_view.clearAnimation();
		Animation anim = new TranslateAnimation(0, 0, -m_view.getHeight(), 0);
		anim.setDuration(200);
		anim.setAnimationListener(new Animation.AnimationListener()
		{
			public void onAnimationStart(Animation animation)
			{
				m_view.setVisibility(View.VISIBLE);
			}
			public void onAnimationRepeat(Animation animation)
			{
			}
			public void onAnimationEnd(Animation animation)
			{
			}
		});
		m_view.startAnimation(anim);
	}
	public final void BarHide()
	{
		m_view.clearAnimation();
		Animation anim = new TranslateAnimation(0, 0, 0, -m_view.getHeight());
		anim.setDuration(200);
		anim.setAnimationListener(new Animation.AnimationListener()
		{
			public void onAnimationStart(Animation animation)
			{
			}
			public void onAnimationRepeat(Animation animation)
			{
			}
			public void onAnimationEnd(Animation animation)
			{
				m_view.setVisibility(View.INVISIBLE);
			}
		});
		m_view.startAnimation(anim);
	}
	public final int BarGetHeight()
	{
		return m_view.getHeight();
	}
	public final void BarSwitch(PDFTopBar bar)
	{
		if( bar != null )
		{
			m_view.setVisibility(View.INVISIBLE);
			bar.m_view.setVisibility(View.VISIBLE);
		}
	}
}
