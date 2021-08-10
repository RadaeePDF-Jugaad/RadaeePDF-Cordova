//
//  PDFNavThumb.h
//  RDPDFReader
//
//  Created by Radaee Lou on 2020/5/3.
//  Copyright © 2020 Radaee. All rights reserved.
//
#import "PDFObjc.h"
#import "UICellView.h"
typedef void(^func_nav)(id);
@interface PDFNavThumb : UIScrollView
{
    dispatch_queue_t m_queue;
    Boolean m_cancel;
    NSString *m_cur_dir;
    func_nav OnPDFOpen;
    func_delete OnPDFDelete;
}
-(id)initWithFrame:(CGRect)frame;
-(id)initWithCoder:(NSCoder *)aDecoder;
-(void)setCallback:(func_nav)pdf_open :(func_delete)pdf_delete;
-(void)setDir:(NSString *)dir;
-(void)refresh;
@end
