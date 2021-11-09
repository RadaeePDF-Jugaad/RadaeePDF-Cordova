//
//  SignatureViewController.h
//  PDFViewer
//
//  Created by Emanuele Bortolami on 15/01/18.
//

#import <UIKit/UIKit.h>
#import "RDVPage.h"

@protocol SignatureDelegate <NSObject>

- (void)didSign:(RDVPage *)vp :(RDPDFAnnot *)annot;
- (void)onDismissSignView;

@end

@interface SignatureViewController : UIViewController

@property (weak, nonatomic) id <SignatureDelegate> delegate;
@property (nonatomic) RDVPage *annotPage;
@property (nonatomic) RDPDFAnnot *annot;

@end
