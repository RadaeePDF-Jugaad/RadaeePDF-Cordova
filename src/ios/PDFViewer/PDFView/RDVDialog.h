//
//  Header.h
//  PDFViewer
//
//  Created by Radaee on 2019/4/30.
//

#import <UIKit/UIKit.h>
#import "PDFObjc.h"

typedef void (^BtnClickBlock)();

@interface RDVDialog : UIViewController
{
    PDFPage    *m_page;
    PDFAnnot   *m_annot;
    UIView     *panelView;
    UIButton   *confirmBtn;
    UIButton   *cancelBtn;
    UITextView *titleTextView;
    UITextView *contentTextView;
}
@property (nonatomic, copy) BtnClickBlock okBtnClickBlock;
@property (nonatomic, copy) BtnClickBlock deleteAnnotBlock;
@property (nonatomic, copy) BtnClickBlock cancelAnnotBlock;

- (instancetype)init:(PDFPage *)page withAnnot:(PDFAnnot *)annot;


@end
