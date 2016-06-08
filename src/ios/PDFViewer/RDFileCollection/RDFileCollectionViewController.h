//
//  RDFileCollectionViewController.h
//  PDFViewer
//
//  Created by Federico Vellani on 18/06/2020.
//

#import <UIKit/UIKit.h>
#import "sys/utsname.h"
#import "PDFHttpStream.h"
#import "PDFReaderCtrl.h"
#import "RDPDFReflowViewController.h"
#import "RDPageViewController.h"
#import "RDVGlobal.h"
#import "PDFHttpStream.h"
#import "RDFileCollectionViewCell.h"
#import "RDFileDetailViewController.h"
#import "RDMetaDataViewController.h"

@interface RDFileCollectionViewController : UICollectionViewController <RDFileCollectionViewCellDelegate, RDFileDetailViewControllerDelegate, UICollectionViewDelegateFlowLayout>
{
    NSMutableArray *m_files;
    PDFReaderCtrl *m_pdf;
    RDPDFReflowViewController *m_pdfR;
    RDPageViewController *m_pdfP;
    PDFHttpStream *httpStream;
}

@end
