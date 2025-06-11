package com.radaee.util;

import android.animation.Animator;
import android.animation.AnimatorListenerAdapter;
import android.animation.ArgbEvaluator;
import android.animation.ObjectAnimator;
import android.animation.ValueAnimator;
import android.content.Context;
import android.util.AttributeSet;
import android.view.View;

import androidx.annotation.Nullable;

public class RDBGView extends View {
    private int m_status = 0;
    public RDBGView(Context context, @Nullable AttributeSet attrs) {
        super(context, attrs);
        setBackgroundColor(0x80000000);
    }
    public boolean RDIsShowing()
    {
        return (m_status == 1 || m_status == 2);
    }
    public boolean RDIsHidding()
    {
        return (m_status == 3 || m_status == 0);
    }
    public void RDShow()
    {
        clearAnimation();
        ValueAnimator animator = ObjectAnimator.ofInt(this, "backgroundColor", 0, 0x80000000);
        animator.setDuration(500);
        animator.setEvaluator(new ArgbEvaluator());
        animator.setRepeatCount(0);
        animator.setRepeatMode(ValueAnimator.RESTART);
        animator.addListener(new AnimatorListenerAdapter() {
            @Override
            public void onAnimationStart(Animator animation) {
                super.onAnimationStart(animation);
                setVisibility(VISIBLE);
            }
            @Override
            public void onAnimationEnd(Animator animation) {
                super.onAnimationEnd(animation);
                clearAnimation();
                m_status = 2;
            }
        });
        m_status = 1;
        animator.start();
    }
    public void RDHide()
    {
        clearAnimation();
        ValueAnimator animator = ObjectAnimator.ofInt(this, "backgroundColor", 0x80000000, 0);
        animator.setDuration(500);
        animator.setEvaluator(new ArgbEvaluator());
        animator.setRepeatCount(0);
        animator.setRepeatMode(ValueAnimator.RESTART);
        animator.addListener(new AnimatorListenerAdapter() {
            @Override
            public void onAnimationEnd(Animator animation) {
                super.onAnimationEnd(animation);
                setVisibility(GONE);
                clearAnimation();
                m_status = 0;
            }
        });
        m_status = 3;
        animator.start();
    }
}
