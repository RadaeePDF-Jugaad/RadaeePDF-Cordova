//
//  ReaderHandler.m
//  PDFViewer
//
//  Created by Emanuele Bortolami on 27/07/16.
//
//

#import "ReaderHandler.h"

@implementation ReaderHandler

static int mPrevIndex;
static int mNextIndex;
static PDF_RECT mParaRectOrg;
static PDF_RECT mSecondParaRectOrg;


+ (PDF_RECT)handleAutomaticZoom:(PDFV *)mPdfView withPos:(struct PDFV_POS)mPosition forDoc:(PDFDoc *)mDoc containedInWidth:(int)mWidth
{
    return [ReaderHandler getParagraphsToRead:mPdfView withPos:mPosition forDoc:mDoc withZoom:YES];
}

/*
 public interface OnTextToSpeechStoppedListener {
 void OnTextToSpeechStopped();
}
 
public static void handleText2Speech(PDFView mPdfView, PDFView.PDFPos mPosition, Document mDoc, final String mCountry, final Context mContext,
                                     final OnTextToSpeechStoppedListener listener) {
    try {
        if(mTextToSpeech != null && mTextToSpeech.isSpeaking()) //if text to speach already running stop it
            stopTextToSpeech(null);
        
        mTextToSpeechPaint = new Paint();
        mTextToSpeechPaint.setARGB(0x40, 255, 255, 0);
        mTextToSpeechPaint.setStyle(Paint.Style.FILL);
        
        mTextToSpeechActive = true;
        
        Page mCurrentPage = mDoc.GetPage(mPosition.pageno); //get the current page
        mCurrentPage.ObjsStart();
        getParagraphsToRead(mPdfView, mPosition, mDoc, false); //call to adjust the start and end indeces of the paragraphs to read
        mText =  mCurrentPage.ObjsGetString(mPrevIndex, mCurrentPage.ObjsAlignWord(mNextIndex, 1) + 1); //get the whole text
        if(StringUtils.isEmpty(mText))
            return;
        
        mText = checkTextCorrection(mText);
        
        if(StringUtils.isNotEmpty(mCountry))
            mLocale = new Locale(mCountry);
        else
            mLocale = Locale.getDefault();
        
        mTextToSpeech = new TextToSpeech(mContext, new TextToSpeech.OnInitListener() {
            @Override
            public void onInit(int status) {
                if(status == TextToSpeech.SUCCESS) {
                    int result = 0;
                    mTextToSpeech.setLanguage(mLocale);
                    
                    //split the whole text to blocks to avoid the text to speech max limit
                    String[] mTextArray = StringUtils.splitByWholeSeparatorPreserveAllTokens(mText, ".\r\n", 5);
                    mTextArray = Common.clean(mTextArray);
                    for (int i = 0 ; i < mTextArray.length ; i++) {
                        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP)
                            result = mTextToSpeech.speak(mTextArray[i], TextToSpeech.QUEUE_ADD, null, i == mTextArray.length - 1 ? "Done" : "messageID");
                        else {
                            HashMap<String, String> map = new HashMap<>();
                            if(i == mTextArray.length - 1)
                                map.put(TextToSpeech.Engine.KEY_PARAM_UTTERANCE_ID, "Done");
                            else
                                map.put(TextToSpeech.Engine.KEY_PARAM_UTTERANCE_ID, "messageID");
                            //noinspection deprecation
                            result = mTextToSpeech.speak(mTextArray[i], TextToSpeech.QUEUE_ADD, map);
                        }
                    }
                    if(result != TextToSpeech.SUCCESS) {
                        new MobileReplicaDialog(mContext, mContext.getString(R.string.text_to_speech_error)).show();
                        stopTextToSpeech(listener);
                    }
                }
            }
        });
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.ICE_CREAM_SANDWICH_MR1) {
            mTextToSpeech.setOnUtteranceProgressListener(new UtteranceProgressListener() {
                @Override
                public void onStart(String utteranceId) { }
                
                @Override
                public void onDone(String utteranceId) {
                    if(utteranceId.equals("Done"))
                        stopTextToSpeech(listener);
                }
                
                @Override
                public void onError(String utteranceId) {}
            });
        } else { //noinspection deprecation
            mTextToSpeech.setOnUtteranceCompletedListener(new TextToSpeech.OnUtteranceCompletedListener() {
                @Override
                public void onUtteranceCompleted(String utteranceId) {
                    if(utteranceId.equals("Done"))
                        stopTextToSpeech(listener);
                }
            });
        }
    } catch (Exception e) { e.printStackTrace(); }
}

public static void stopTextToSpeech(OnTextToSpeechStoppedListener mOnTextToSpeechStopped) {
    try {
        if(mTextToSpeech != null) {
            mParaRect = null;
            mSecondParaRect = null;
            mTextToSpeechActive = false;
            mTextToSpeech.stop();
            mTextToSpeech.shutdown();
            mTextToSpeech = null;
            
            if(mOnTextToSpeechStopped != null)
                mOnTextToSpeechStopped.OnTextToSpeechStopped();
        }
    } catch (Exception e) {
        e.getMessage();
    }
}

public static void reAdjustAfterZoom(PDFView mPdfView, PDFView.PDFPos mPosition) {
    if(mTextToSpeech != null && mTextToSpeech.isSpeaking())
        toDIBCoordinates(mPdfView, mPosition, mParaRectOrg, mSecondParaRectOrg);
}
*/

+ (PDF_RECT)getParagraphsToRead:(PDFV *)mPdfView withPos:(struct PDFV_POS)mPosition forDoc:(PDFDoc *)mDoc withZoom:(BOOL)zoom
{
    PDFPage *mCurrentPage = [mDoc page:mPosition.pageno];
    [mCurrentPage objsStart];
    
    //get the index of the tapped character
    int mClickedCharIndex = [mCurrentPage objsAlignWord:[mCurrentPage objsGetCharIndex:mPosition.x :mPosition.y] :-1];
    
    BOOL mDividedByColumns = NO;
    PDF_RECT mFirstRect;
    PDF_RECT mSecondRect;
    PDF_RECT mNextCharRect;
    PDF_RECT mCurrCharRect;
    
    mPrevIndex = mClickedCharIndex;
    mNextIndex = [mCurrentPage objsAlignWord:mClickedCharIndex :1];
    
    if (mPrevIndex < 0 || mNextIndex < 0) {
        PDF_RECT empty_rect;
        empty_rect.bottom = 0;
        empty_rect.left = 0;
        empty_rect.right = 0;
        empty_rect.top = 0;
        return empty_rect;
    }
    
    [mCurrentPage objsCharRect:mClickedCharIndex :&mFirstRect];
    float mCharHeight = mFirstRect.bottom - mFirstRect.top;
    
    //parse backword till arrive to the paragraph start
    [mCurrentPage objsCharRect:mPrevIndex :&mCurrCharRect];
    [mCurrentPage objsCharRect:mPrevIndex -1 :&mNextCharRect];
    double mFontHeightDiff = abs((mNextCharRect.bottom - mNextCharRect.top) - mCharHeight);
    while ((mFontHeightDiff < 0.4 || (mFontHeightDiff > 4 && mFontHeightDiff < 5)) && mPrevIndex >= 0) {
        if(zoom && [[mCurrentPage objsString:mPrevIndex -3 :mPrevIndex] isEqualToString:@".\r\n"]) //in case of zoom, read only one paragraph
            break;
        
        mPrevIndex--;
        mPrevIndex = [mCurrentPage objsAlignWord:mPrevIndex :-1];
        
        //adjust the whole paragraph coordinates
        mFirstRect = [ReaderHandler adjustFirstParagraphCoordinates:mNextCharRect dividedByColums:mDividedByColumns withFirstRect:mFirstRect];
        mSecondRect = [ReaderHandler adjustFirstParagraphCoordinates:mNextCharRect dividedByColums:mDividedByColumns withFirstRect:mSecondRect];
        
        [mCurrentPage objsCharRect:mPrevIndex :&mCurrCharRect];
        if (mPrevIndex > 0) {
            [mCurrentPage objsCharRect:mPrevIndex -1 :&mNextCharRect];
        }
        if ((mNextCharRect.right - mCurrCharRect.left) < -10 && abs(mNextCharRect.top - mCurrCharRect.top) > 10 && !mDividedByColumns) {
            mDividedByColumns = true; //paragraph is divided in 2 columns
        }
        
        mFontHeightDiff = abs(mNextCharRect.bottom - mNextCharRect.top) - mCharHeight;
        /*String s = mCurrentPage.ObjsGetString(mPrevIndex, mPrevIndex + 1);
         Log.i("--Prev--", " -- char height = " + (mNextCharRect[3] - mNextCharRect[1]) + " -- char = " + s + "  last 3 char = " +
         mCurrentPage.ObjsGetString(mPrevIndex - 3, mPrevIndex) + " -- font diff = " + Math.abs((mNextCharRect[3] - mNextCharRect[1]) - mCharHeight));*/
    }
    
    // Log.i("--Finished prev--", " -- char height = " + (mNextCharRect[3] - mNextCharRect[1])	+ " -- char = " + mCurrentPage.ObjsGetString(mPrevIndex - 1, mPrevIndex));
    
    //parse foreword till arrive to the paragraph end
    mDividedByColumns = false;
    [mCurrentPage objsCharRect:mNextIndex :&mCurrCharRect];
    [mCurrentPage objsCharRect:mNextIndex + 1 :&mNextCharRect];
    mFontHeightDiff = abs((mNextCharRect.bottom - mNextCharRect.top) - mCharHeight);
    while ((mFontHeightDiff < 0.4 || (mFontHeightDiff > 4 && mFontHeightDiff < 5)) && mNextIndex <= [mCurrentPage objsCount] - 1)
    {
        if(zoom && [[mCurrentPage objsString:mNextIndex :mNextIndex +3] isEqualToString:@".\r\n"]) //in case of zoom, read only one paragraph
            break;
        
        mNextIndex++;
        mNextIndex = [mCurrentPage objsAlignWord:mNextIndex :1];
        
        //adjust the whole paragraph coordinates
        mFirstRect = [ReaderHandler adjustFirstParagraphCoordinates:mNextCharRect dividedByColums:mDividedByColumns withFirstRect:mFirstRect];
        mSecondRect = [ReaderHandler adjustFirstParagraphCoordinates:mNextCharRect dividedByColums:mDividedByColumns withFirstRect:mSecondRect];
        
        [mCurrentPage objsCharRect:mNextIndex :&mCurrCharRect];
        if (mNextIndex < ([mCurrentPage objsCount] -1)) {
            [mCurrentPage objsCharRect:mNextIndex +1 :&mNextCharRect];
        }
        if((mNextCharRect.left - mCurrCharRect.right) > 10 && abs(mNextCharRect.top - mCurrCharRect.top) > 10 && !mDividedByColumns) //paragraph is divided in 2 columns
            mDividedByColumns = true;
        
        mFontHeightDiff = abs((mNextCharRect.bottom - mNextCharRect.top) - mCharHeight);
        /*String s = mCurrentPage.ObjsGetString(mNextIndex, mNextIndex + 1);
         /Log.i("--Next--"," -- char height = " + (mNextCharRect[3] - mNextCharRect[1]) + " -- char = " + s + "  next 2 char =" +
         mCurrentPage.ObjsGetString(mNextIndex + 1, mNextIndex + 3) + " -- font diff = " + Math.abs((mNextCharRect[3] - mNextCharRect[1]) - mCharHeight));*/
    }
    //Log.i("--Finished next--"," -- char height = " + (mNextCharRect[3] - mNextCharRect[1]) + " -- char = " + mCurrentPage.ObjsGetString(mNextIndex + 1, mPrevIndex + 2));
    
    NSLog(@"--All Tapped String--");
    NSLog(@"-- %@", [mCurrentPage objsString:mPrevIndex :[mCurrentPage objsAlignWord:mNextIndex :1]]);
    
    if (zoom) {
        //mFirstRect = toDIBCoordinates(mPdfView, mPosition, mFirstRect);
    }
    else {
        mParaRectOrg = mFirstRect;
        if (mSecondRect.left != mSecondRect.right) {
            mSecondParaRectOrg = mSecondRect;
        }
        [ReaderHandler toDIBCoordinates:mPdfView withPos:mPosition firstPara:mFirstRect secondPara:mSecondRect];
    }
    
    mCurrentPage = nil;
    
    return mFirstRect;
}

+ (PDF_RECT)toDIBCoordinates:(PDFV *)mPdfView withPos:(struct PDFV_POS)mPosition para:(PDF_RECT)mPara
{
    PDF_RECT mResult;
    PDFVPage *mViewPage = [mPdfView vGetPage:mPosition.pageno];
    int px = [mViewPage GetVX:[mPdfView vGetX]];
    int py = [mViewPage GetVY:[mPdfView vGetY]];
    float tmp = mPara.top;
    mResult.left = [mViewPage ToDIBX:mPara.left] + px;
    mResult.top = [mViewPage ToDIBY:mPara.bottom] + py;
    mResult.right = [mViewPage ToDIBX:mPara.right] + px;
    mResult.bottom = [mViewPage ToDIBY:tmp] + py;
    return mResult;
}

+ (void)toDIBCoordinates:(PDFV *)mPdfView withPos:(struct PDFV_POS)mPosition firstPara:(PDF_RECT)mFirstPara secondPara:(PDF_RECT)mSecondPara {
    PDFVPage *mViewPage = [mPdfView vGetPage:mPosition.pageno];
    int px = [mViewPage GetVX:[mPdfView vGetX]];
    int py = [mViewPage GetVY:[mPdfView vGetY]];
    float tmp = mFirstPara.top;
    PDF_RECT mParaRect;
    mParaRect.left = [mViewPage ToDIBX:mFirstPara.left] + px;
    mParaRect.top = [mViewPage ToDIBY:mFirstPara.bottom] + py;
    mParaRect.right = [mViewPage ToDIBX:mFirstPara.right] + px;
    mParaRect.bottom = [mViewPage ToDIBY:tmp] + py;
    if(mSecondPara.left == mSecondPara.right) {
        tmp = mSecondPara.top;
        PDF_RECT mSecondParaRect;
        mSecondParaRect.left = [mViewPage ToDIBX:mSecondPara.left] + px;
        mSecondParaRect.top = [mViewPage ToDIBY:mSecondPara.bottom] + py;
        mSecondParaRect.right = [mViewPage ToDIBX:mSecondPara.right] + px;
        mSecondParaRect.bottom = [mViewPage ToDIBY:tmp] + py;
    }
}

+ (PDF_RECT)adjustFirstParagraphCoordinates:(PDF_RECT)mNextCharRect dividedByColums:(BOOL)mDividedByColumns withFirstRect:(PDF_RECT)mFirstRect
{
    if(mFirstRect.left > mNextCharRect.left && !mDividedByColumns) //left
        mFirstRect.left = mNextCharRect.left;
    if(mFirstRect.top > mNextCharRect.top && !mDividedByColumns) //top
        mFirstRect.top = mNextCharRect.top;
    if(mFirstRect.right < mNextCharRect.right && !mDividedByColumns) //right
        mFirstRect.right = mNextCharRect.right;
    if(mFirstRect.bottom < mNextCharRect.bottom && !mDividedByColumns) //bottom
        mFirstRect.bottom = mNextCharRect.bottom;
    
    return mFirstRect;
}

+ (PDF_RECT)adjustSecondParagraphCoordinates:(PDF_RECT)mNextCharRect dividedByColums:(BOOL)mDividedByColumns withFirstRect:(PDF_RECT)mSecondRect
{
    if(mDividedByColumns) {
        if(mSecondRect.left == mSecondRect.right)
            mSecondRect = mNextCharRect;
        if(mSecondRect.left > mNextCharRect.left) //left
            mSecondRect.left = mNextCharRect.left;
        if(mSecondRect.top > mNextCharRect.top) //top
            mSecondRect.top = mNextCharRect.top;
        if(mSecondRect.right < mNextCharRect.right) //right
            mSecondRect.right = mNextCharRect.right;
        if(mSecondRect.bottom < mNextCharRect.bottom) //bottom
            mSecondRect.bottom = mNextCharRect.bottom;
    }
    
    return mSecondRect;
}

+ (NSString *)checkTextCorrection:(NSString *)mText2Correct
{
    if (mText2Correct && mText2Correct.length > 0) {
        mText2Correct = [mText2Correct stringByReplacingOccurrencesOfString:@"-\r\n" withString:@""];
    }
    
    return mText2Correct;
}

@end
