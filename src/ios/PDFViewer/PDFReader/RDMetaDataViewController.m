//
//  RDMetaDataViewController.m
//  PDFViewer
//
//  Created by Federico Vellani on 26/06/2020.
//

#import "RDMetaDataViewController.h"
#import "PDFObjc.h"

@interface RDMetaDataViewController ()

@end

@implementation RDMetaDataViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [_titleTextField setText:[_doc meta:@"Title"]];
    [_authorTextField setText:[_doc meta:@"Author"]];
    [_subjectTextField setText:[_doc meta:@"Subject"]];
    [_keyWordsTextView setText:[_doc meta:@"Keywords"]];
    
    if (@available(iOS 13.0, *)) {
        _keyWordsTextView.layer.borderColor = [UIColor systemGray4Color].CGColor;
    } else {
        _keyWordsTextView.layer.borderColor = [UIColor colorWithWhite:0.8 alpha:1.0].CGColor;
    }
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard)];
    [self.view addGestureRecognizer:tap];
}

- (void)dismissKeyboard
{
    [_titleTextField resignFirstResponder];
    [_authorTextField resignFirstResponder];
    [_subjectTextField resignFirstResponder];
    [_keyWordsTextView resignFirstResponder];
}

- (IBAction)dismissView:(id)sender
{
    [_doc setMeta:@"Title" :_titleTextField.text];
    [_doc setMeta:@"Author" :_authorTextField.text];
    [_doc setMeta:@"Subject" :_subjectTextField.text];
    [_doc setMeta:@"Keywords" :_keyWordsTextView.text];
    if (_autoSave) {
        [_doc save];
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
