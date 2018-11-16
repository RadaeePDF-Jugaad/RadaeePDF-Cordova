//
//  RDAnnotToolBar.h
//  PDFViewer
//
//  Created by strong on 2018/3/26.
//

#import <UIKit/UIKit.h>

#define ICON_WIDTH 30

@protocol RDToolBarDelegate

// normalbar delegate
- (void)closeView;
- (void)searchView;
- (void)showDrawModeTableView;
- (void)selectIsStarting;
- (void)undoAnnot;
- (void)redoAnnot;
- (void)toggleGrid;
- (void)showMoreButtons;
//performbar delegate
- (void)nextword;
- (void)prevword;
- (void)searchCancel;
//searchbar delegate
- (void)performAnnot;
- (void)deleteAnnot;
- (void)annotCancel;

@end

@interface RDAnnotToolBar : UIToolbar

@property (nonatomic, strong) UIBarButtonItem *moreButton;
@property (nonatomic,weak) id<RDToolBarDelegate> m_delegate;

@property (strong, nonatomic) UIImage *closeImage;
@property (strong, nonatomic) UIImage *searchImage;
@property (strong, nonatomic) UIImage *gridImage;
@property (strong, nonatomic) UIImage *deleteImage;
@property (strong, nonatomic) UIImage *doneImage;
@property (strong, nonatomic) UIImage *removeImage;
@property (strong, nonatomic) UIImage *undoImage;
@property (strong, nonatomic) UIImage *redoImage;
@property (strong, nonatomic) UIImage *performImage;
@property (strong, nonatomic) UIImage *moreImage;
@property (strong, nonatomic) UIImage *drawImage;
@property (strong, nonatomic) UIImage *selectImage;
@property (strong, nonatomic) UIImage *prevImage;
@property (strong, nonatomic) UIImage *nextImage;

@property (nonatomic) BOOL hideSearchImage;
@property (nonatomic) BOOL hideDrawImage;
@property (nonatomic) BOOL hideSelImage;
@property (nonatomic) BOOL hideUndoImage;
@property (nonatomic) BOOL hideRedoImage;
@property (nonatomic) BOOL hideMoreImage;
@property (nonatomic) BOOL hideGridImage;

- (void)setupToolBarArray;
- (void)changeToPerformToolBar;
- (void)changeToSearchToolBar;
- (void)changeToNormalToolBar;

@end
