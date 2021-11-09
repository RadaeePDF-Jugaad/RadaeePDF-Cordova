//
//  RDTextAnnotViewController.h
//  PDFViewer
//
//  Created by Federico Vellani on 01/07/2020.
//

#import <UIKit/UIKit.h>
@class RDPDFAnnot;

@protocol RDPopupTextViewControllerDelegate <NSObject>

- (void)onDismissPopupTextViewEdited:(BOOL)edited;

@end

@interface RDPopupTextViewController : UIViewController

@property (strong, nonatomic) RDPDFAnnot *annot;
@property (strong, nonatomic) id <RDPopupTextViewControllerDelegate> delegate;

@property (strong, nonatomic) IBOutlet UITextField *subjectTextField;
@property (strong, nonatomic) IBOutlet UITextView *textView;
@property (strong, nonatomic) IBOutlet UIButton *dismissButton;
@property (weak, nonatomic) IBOutlet UILabel *subjectLabel;
@property (weak, nonatomic) IBOutlet UILabel *textLabel;

- (IBAction)dismissView:(id)sender;

@end

