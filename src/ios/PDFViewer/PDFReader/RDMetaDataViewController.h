//
//  RDMetaDataViewController.h
//  PDFViewer
//
//  Created by Federico Vellani on 26/06/2020.
//

#import <UIKit/UIKit.h>

@class PDFDoc;
@interface RDMetaDataViewController : UIViewController

@property (strong, nonatomic) PDFDoc *doc;
@property (nonatomic) BOOL autoSave;

@property (strong, nonatomic) IBOutlet UITextField *titleTextField;
@property (strong, nonatomic) IBOutlet UITextField *authorTextField;
@property (strong, nonatomic) IBOutlet UITextField *subjectTextField;
@property (strong, nonatomic) IBOutlet UITextView *keyWordsTextView;

- (IBAction)dismissView:(id)sender;

@end
