package com.radaee.util;

import android.animation.ObjectAnimator;
import android.annotation.SuppressLint;
import android.content.Context;
import android.util.AttributeSet;
import android.view.MotionEvent;
import android.widget.RelativeLayout;

public class RDRelativeLayout extends RelativeLayout {
    public RDRelativeLayout(Context context, AttributeSet attrs) {
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
}
