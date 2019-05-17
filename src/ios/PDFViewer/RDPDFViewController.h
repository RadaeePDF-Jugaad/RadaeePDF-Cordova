 //
//  RDPDFViewController.h
//  PDFViewer
//
//  Created by Radaee on 12-10-29.
//  Copyright (c) 2012年 Radaee. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PDFLayoutView.h"
#import "PDFIOS.h"
#import "OutLineViewController.h"
#import <CoreData/CoreData.h>
#import "TextAnnotViewController.h"
#import <MediaPlayer/MediaPlayer.h>
//#import "PDFThumbView.h"
#import "LeavesView.h"

@class OutLineViewController;
@class PDFView;
@class PopupMenu;
@class LeavesView;

@class PDFV;
@interface RDPDFViewController : UIViewController <UISearchBarDelegate,UIPrintInteractionControllerDelegate,saveTextAnnotDelegate,PDFLayoutDelegate,LeavesViewDataSource, LeavesViewDelegate>
{
    //GEAR
    MPMoviePlayerViewController *mpvc;
    //FINE
    PDFLayoutView *m_view;
  //  PDFThumbView *m_Thumbview;
    PDFDoc *m_doc;
    BOOL b_findStart;
    CGRect recttoolbar;
    NSString *findString;
    BOOL b_lock;
    OutLineViewController *outlineView;
    BOOL b_sigleTap;
    PopupMenu* popupMenu1;
    PopupMenu* popupMenu2;

    NSString *nuri;
    //popup view
    float begin_x;
    float begin_y;
    float end_x;
    float end_y;
    bool m_bSel;
    
    BOOL statusBarHidden;
    int posx;
    int posy;
    TextAnnotViewController *textAnnotVC;
    NSMutableArray *tempfiles;
    UIToolbar *annotToolBar;
    
    //PDFAnnot begin
    PDFPage *PDFpage;
    PDFAnnot *PDFannot;
    float annot_x;
    float annot_y;
    //PDFAnnot end
    
    
}
@property (strong, nonatomic) UIToolbar *toolBar;
@property (strong,nonatomic) UIToolbar *searchToolBar;
@property (strong,nonatomic) UIToolbar *drawLineToolBar;
@property (strong,nonatomic) UIToolbar *drawRectToolBar;
@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) IBOutlet UISearchBar* m_searchBar;
@property (strong,nonatomic)IBOutlet UISlider *sliderBar;
@property (strong,nonatomic)IBOutlet UILabel *pageNumLabel;
@property (assign, nonatomic)int pagecount;
@property (assign, nonatomic)int pagenow;
@property (assign,nonatomic) BOOL b_keyboard;
@property (assign,nonatomic) PopupMenu* popupMenu;
@property (readonly) LeavesView *leavesView;
@property (nonatomic) BOOL isCurling;
- (IBAction)composeFile:(id) sender;
- (IBAction)searchView:(id) sender;
- (IBAction)drawLine:(id) sender;
- (IBAction)drawRect:(id) sender;
-(IBAction)drawEllipse:(id)sender;
- (IBAction)viewMenu:(id) sender;
-(IBAction)lockView:(id)sender;
-(IBAction)searchCancel:(id)sender;
-(IBAction)prevword:(id)sender;
-(IBAction)nextword:(id)sender;

-(IBAction)drawLineDone:(id)sender;
-(IBAction)drawLineCancel:(id)sender;

-(IBAction)drawRectDone:(id)sender;
-(IBAction)drawRectCancel:(id)sender;

-(IBAction)drawEllipseDone:(id)sender;
-(IBAction)drawEllipseCancel:(id)sender;

-(IBAction)sliderValueChanged:(id)sender;
-(IBAction)sliderDragUp:(id)sender;
-(int)PDFOpen:(NSString *)path :(NSString *)pwd;
-(int)PDFOpenPage:(NSString *)path :(int)pageno : (float)x :(float)y :(NSString *)pwd;

//for test
-(int)PDFopenMem : (void *)data : (int)data_size :(NSString *)pwd;
-(int)PDFOpenStream :(id<PDFStream>)stream :(NSString *)password;

//-(int)openStream:(id<PDFStream>)stream : (NSString *)password;
-(void)PDFGoto:(int)pageno;
-(void)PDFClose;
-(void)initbar :(int) pageno;
-(BOOL)isPortrait;
-(void)PDFThumbNailinit:(int) pageno;

//GEAR
- (void)moviePlayedDidFinish:(NSNotification *)notification;
//END
@end
