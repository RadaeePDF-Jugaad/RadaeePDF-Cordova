//
//  RDTextAnnotViewController.h
//  PDFViewer
//
//  Created by Federico Vellani on 01/07/2020.
//

#import <UIKit/UIKit.h>
@class PDFAnnot;

@protocol RDPopupTextViewControllerDelegate <NSObject>

- (void)onDismissPopupTextViewEdited:(BOOL)edited;

@end

@interface RDPopupTextViewController : UIViewController

@property (strong, nonatomic) PDFAnnot *annot;
@property (strong, nonatomic) id <RDPopupTextViewControllerDelegate> delegate;

@property (strong, nonatomic) IBOutlet UITextField *subjectTextField;
@property (strong, nonatomic) IBOutlet UITextView *textView;
@property (strong, nonatomic) IBOutlet UIButton *dismissButton;
 
- (IBAction)dismissView:(id)sender;

@end

