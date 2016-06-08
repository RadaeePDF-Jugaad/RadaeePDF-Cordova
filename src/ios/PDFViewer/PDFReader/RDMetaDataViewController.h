//
//  RDMetaDataViewController.h
//  PDFViewer
//
//  Created by Federico Vellani on 26/06/2020.
//

#import <UIKit/UIKit.h>

@class RDPDFDoc;
@interface RDMetaDataViewController : UIViewController

@property (strong, nonatomic) RDPDFDoc *doc;
@property (nonatomic) BOOL autoSave;

@property (strong, nonatomic) IBOutlet UITextField *titleTextField;
@property (strong, nonatomic) IBOutlet UITextField *authorTextField;
@property (strong, nonatomic) IBOutlet UITextField *subjectTextField;
@property (strong, nonatomic) IBOutlet UITextView *keyWordsTextView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *authorLabel;
@property (weak, nonatomic) IBOutlet UILabel *subjectLabel;
@property (weak, nonatomic) IBOutlet UILabel *keywordLabel;

- (IBAction)dismissView:(id)sender;

@end
