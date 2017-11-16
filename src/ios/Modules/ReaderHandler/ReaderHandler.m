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
    
    if (mClickedCharIndex < 0) return mFirstRect;
    
    mPrevIndex = mClickedCharIndex;
    mNextIndex = [mCurrentPage objsAlignWord:mClickedCharIndex :1];
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
    }
    
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
    }
    
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
