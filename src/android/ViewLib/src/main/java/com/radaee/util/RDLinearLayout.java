package com.radaee.util;

import android.animation.ObjectAnimator;
import android.annotation.SuppressLint;
import android.content.Context;
import android.util.AttributeSet;
import android.view.MotionEvent;
import android.view.ViewGroup;
import android.view.animation.Animation;
import android.view.animation.Transformation;
import android.widget.LinearLayout;

import androidx.annotation.Nullable;
import androidx.interpolator.view.animation.FastOutLinearInInterpolator;

public class RDLinearLayout extends LinearLayout {
    public RDLinearLayout(Context context, @Nullable AttributeSet attrs) {
        super(context, attrs);
    }
    @SuppressLint("ClickableViewAccessibility")
    @Override
    public boolean onTouchEvent(MotionEvent event)
    {
        int eve = event.getActionMasked();
        if (eve == MotionEvent.ACTION_UP || eve == MotionEvent.ACTION_CANCEL) {
            ObjectAnimator oa = ObjectAnimator.ofFloat(this, "scaleX", 0.8f, 1f);
            oa.setDuration(200);
            ObjectAnimator oa2 = ObjectAnimator.ofFloat(this, "scaleY", 0.8f, 1f);
            oa2.setDuration(200);
            oa.start();
            oa2.start();
        }
        else if (eve == MotionEvent.ACTION_DOWN) {
            ObjectAnimator oa = ObjectAnimator.ofFloat(this, "scaleX", 1f, 0.8f);
            oa.setDuration(200);
            ObjectAnimator oa2 = ObjectAnimator.ofFloat(this, "scaleY", 1f, 0.8f);
            oa2.setDuration(200);
            oa.start();
            oa2.start();
        }
        return super.onTouchEvent(event);
    }

    public void RDExpand() {
        int cnt = getChildCount();
        if (cnt > 120)
        {
            setVisibility(VISIBLE);
            return;
        }
        measure(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.WRAP_CONTENT);
        final int viewHeight = getMeasuredHeight();
        getLayoutParams().height = 0;
        setVisibility(VISIBLE);

        Animation animation = new Animation() {
            @Override
            protected void applyTransformation(float interpolatedTime, Transformation t) {
                if (interpolatedTime == 1) {
                    getLayoutParams().height = ViewGroup.LayoutParams.WRAP_CONTENT;
                } else {
                    getLayoutParams().height = (int) (viewHeight * interpolatedTime);
                }
                requestLayout();
            }
        };
        if (cnt < 6) cnt = 6;
        if (cnt > 60) cnt = 60;
        animation.setDuration(cnt * 15);
        animation.setInterpolator(new FastOutLinearInInterpolator());
        startAnimation(animation);
    }

    public void RDCollapse() {
        int cnt = getChildCount();
        if (cnt > 120)
        {
            setVisibility(GONE);
            return;
        }
        measure(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.WRAP_CONTENT);
        final int viewHeight = getMeasuredHeight();

        Animation animation = new Animation() {
            @Override
            protected void applyTransformation(float interpolatedTime, Transformation t) {
                getLayoutParams().height = viewHeight - (int) (viewHeight * interpolatedTime);
                requestLayout();
            }
        };
        if (cnt < 6) cnt = 6;
        if (cnt > 60) cnt = 60;
        animation.setDuration(cnt * 15);
        animation.setInterpolator(new FastOutLinearInInterpolator());
        animation.setAnimationListener(new Animation.AnimationListener() {
            @Override
            public void onAnimationStart(Animation animation) {
            }

            @Override
            public void onAnimationEnd(Animation animation) {
                setVisibility(GONE);
            }

            @Override
            public void onAnimationRepeat(Animation animation) {
            }
        });
        startAnimation(animation);
    }
}
