package com.radaee.util;

import android.app.Activity;
import android.content.pm.ActivityInfo;
import android.graphics.Bitmap;
import android.os.Bundle;
import android.support.annotation.Nullable;
import android.view.View;
import android.view.Window;
import android.view.WindowManager;
import android.widget.Button;
import android.widget.TextView;

import com.github.gcacace.signaturepad.views.SignaturePad;
import com.radaee.viewlib.R;

/*
 * AndroidPDFSample
 * Created by Nermeen on 09/01/2018.
 */
public class CaptureSignature extends Activity {

    private Button mSaveButton;
    private Button mClearButton;
    private SignaturePad mSignaturePad;
    public static final String SIGNATURE_PAD_DESCR = "SIGNATURE_PAD_DESCR";
    public static final String FIT_SIGNATURE_BITMAP = "FIT_SIGNATURE_BITMAP";

    @Override
    public void setTheme(int resid) {
        super.setTheme(getResources().getBoolean(R.bool.landscape_only) ? R.style.AppBaseTheme : resid);
    }

    @Override
    protected void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        this.requestWindowFeature(Window.FEATURE_NO_TITLE);
        setContentView(R.layout.signature_pad);

        if (getResources().getBoolean(R.bool.landscape_only))
            setRequestedOrientation(ActivityInfo.SCREEN_ORIENTATION_LANDSCAPE);

        initLayout();
    }

    @Override
    protected void onSaveInstanceState(Bundle outState) {
        outState.putParcelable("signatureBitmap", mSignaturePad.getTransparentSignatureBitmap());
        super.onSaveInstanceState(outState);
    }

    @Override
    protected void onRestoreInstanceState(Bundle savedInstanceState) {
        if(savedInstanceState.getParcelable("signatureBitmap") != null)
            mSignaturePad.setSignatureBitmap((Bitmap)savedInstanceState.getParcelable("signatureBitmap"));
        super.onRestoreInstanceState(savedInstanceState);
    }

    @Override
    public void onAttachedToWindow() {
        super.onAttachedToWindow();

        adjustWindowSize();
    }

    private void adjustWindowSize() {
        if (!getResources().getBoolean(R.bool.landscape_only)) {
            int width = (int) (getResources().getConfiguration().smallestScreenWidthDp
                    * getResources().getDisplayMetrics().density * 0.9f);
            View view = getWindow().getDecorView();
            WindowManager.LayoutParams lp = (WindowManager.LayoutParams) view.getLayoutParams();
            lp.width = width;
            //noinspection SuspiciousNameCombination
            lp.height = width;
            getWindowManager().updateViewLayout(view, lp);
        }
    }

    private void initLayout() {
        mClearButton = (Button) findViewById(R.id.clear_button);
        mSaveButton = (Button) findViewById(R.id.save_button);

        ((TextView) findViewById(R.id.signature_pad_description)).setText(getIntent().getStringExtra(SIGNATURE_PAD_DESCR));

        mSignaturePad = (SignaturePad) findViewById(R.id.signature_pad);
        mSignaturePad.setMinWidth(3);
        mSignaturePad.setMaxWidth(3);
        mSignaturePad.setOnSignedListener(new SignaturePad.OnSignedListener() {
            @Override
            public void onStartSigning() {
            }

            @Override
            public void onSigned() {
                if (CaptureSignatureListener.getSignature() != null) {
                    CaptureSignatureListener.getSignature().recycle();
                    CaptureSignatureListener.setSignature(null);
                }
                mSaveButton.setEnabled(true);
                mClearButton.setEnabled(true);
            }

            @Override
            public void onClear() {
                mSaveButton.setEnabled(false);
                mClearButton.setEnabled(false);
            }
        });

        if (CaptureSignatureListener.getSignature() != null)
            mSignaturePad.setSignatureBitmap(CaptureSignatureListener.getSignature());

        mClearButton.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                mSignaturePad.clear();
            }
        });

        mSaveButton.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                CaptureSignatureListener.OnSignatureCaptured(mSignaturePad.getTransparentSignatureBitmap
                        (getIntent().getBooleanExtra(FIT_SIGNATURE_BITMAP, false)));
                finish();
            }
        });
    }

    public static class CaptureSignatureListener {
        private static Bitmap mSignature;
        private static OnSignatureCapturedListener mListener;

        public interface OnSignatureCapturedListener {
            void OnSignatureCaptured(Bitmap signature);
        }

        public static void setListener(OnSignatureCapturedListener listener) {
            mListener = listener;
        }

        public static void setSignature(Bitmap signature) {
            mSignature = signature;
        }

        static void OnSignatureCaptured(Bitmap signature) {
            if (mListener != null)
                mListener.OnSignatureCaptured(signature);
        }

        public static Bitmap getSignature() {
            return mSignature;
        }
    }
}