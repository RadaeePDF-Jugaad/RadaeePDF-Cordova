//
//  MenuAnnotOp.h
//  RDPDFReader
//
//  Created by Radaee Lou on 2020/5/7.
//  Copyright © 2020 Radaee. All rights reserved.
//

#pragma once
#import <UIKit/UIKit.h>
#import "PDFObjc.h"
typedef void(^func_annotop)(int);
@interface MenuAnnotOp : UIView
{
    PDFAnnot *m_annot;
    func_annotop m_callback;
    Boolean m_has_perform;
    Boolean m_has_edit;
    Boolean m_has_remove;
    Boolean m_has_property;
}
-(id)init:(PDFAnnot *)annot :(CGPoint)position :(func_annotop)callback;
-(PDFAnnot *)annot;
-(void)updateIcons:(UIImage *)iPerform :(UIImage *)iRemove;
@end
