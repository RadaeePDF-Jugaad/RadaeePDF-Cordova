//
//  ReaderHandler.h
//  PDFViewer
//
//  Created by Emanuele Bortolami on 27/07/16.
//
//

#import <Foundation/Foundation.h>
#import "PDFObjc.h"
#import "PDFV.h"

#define SMART_ZOOM

@interface ReaderHandler : NSObject

+ (PDF_RECT)handleAutomaticZoom:(PDFV *)mPdfView withPos:(struct PDFV_POS)mPosition forDoc:(PDFDoc *)mDoc containedInWidth:(int)mWidth;

@end
