//
//  ReaderHandler.h
//  PDFViewer
//
//  Created by Emanuele Bortolami on 27/07/16.
//
//

#import <Foundation/Foundation.h>
#import "PDFObjc.h"
#import "RDVLayout.h"
#import "RDVPage.h"

//#define SMART_ZOOM

@interface ReaderHandler : NSObject

+ (PDF_RECT)handleAutomaticZoom:(RDVLayout *)mPdfView withPos:(RDVPos)mPosition forDoc:(PDFDoc *)mDoc containedInWidth:(int)mWidth;

@end
