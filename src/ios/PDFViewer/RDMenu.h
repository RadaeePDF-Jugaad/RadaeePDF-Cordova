//
//  RDMenu.h
//  PDFViewer
//
//  Created by Emanuele Bortolami on 11/06/2020.
//

#import <UIKit/UIKit.h>
#import "UILShadowView.h"

NS_ASSUME_NONNULL_BEGIN

#define rd_menu_width 250
#define rd_menu_height 40

typedef void(^RDBlock)(int);
@interface RDMenu : UILShadowView
{
    RDBlock m_callback;
}

//definisci property per tipo di menu
@property (nonatomic) BOOL isSearchMenu;
- (instancetype)init:(CGPoint)point :(RDBlock)callback :(NSArray *)items;
- (instancetype)initWithSwitch:(CGPoint)point :(RDBlock)callback :(NSMutableArray *)items;

@end

NS_ASSUME_NONNULL_END
