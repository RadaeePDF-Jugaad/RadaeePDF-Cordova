//
//  PopColor.h
//  RDPDFReader
//
//  Created by Radaee Lou on 2020/5/7.
//  Copyright © 2020 Radaee. All rights reserved.
//

#pragma once
#import <UIKit/UIKit.h>
typedef void(^func_color)(Boolean,unsigned int);
@interface PopColor : UIView
{
    func_color m_callback;
    unsigned int m_color;
    __weak IBOutlet UISlider *mR;
    __weak IBOutlet UISlider *mG;
    __weak IBOutlet UISlider *mB;
    __weak IBOutlet UIButton *mEnable;
    __weak IBOutlet UILabel *mLEnable;
    Boolean m_has_enable;
}
-(void)setPara:(unsigned int)color :(Boolean)has_enable :(func_color)callback;
-(IBAction)OnEnable:(id)sender;
-(IBAction)OnOK:(id)sender;
-(IBAction)OnCancel:(id)sender;
-(IBAction)OnProgress:(id)sender;
@end
