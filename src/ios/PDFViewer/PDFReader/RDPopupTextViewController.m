//
//  RDTextAnnotViewController.m
//  PDFViewer
//
//  Created by Federico Vellani on 01/07/2020.
//

#import "RDPopupTextViewController.h"
#import "PDFObjc.h"

@interface RDPopupTextViewController ()

@end

@implementation RDPopupTextViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    _subjectTextField.text = [_annot getPopupSubject];
    _textView.text = [_annot getPopupText];
    _subjectTextField.userInteractionEnabled = _textView.userInteractionEnabled = ![_annot isAnnotReadOnly];
    
    if (@available(iOS 13.0, *)) {
        _textView.layer.borderColor = [UIColor systemGray4Color].CGColor;
    } else {
        _textView.layer.borderColor = [UIColor colorWithWhite:0.8 alpha:1.0].CGColor;
    }
        
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard)];
    [self.view addGestureRecognizer:tap];
}

- (void)dismissKeyboard
{
    [_subjectTextField resignFirstResponder];
    [_textView resignFirstResponder];
}

- (IBAction)dismissView:(id)sender
{
    BOOL edited = NO;
    if (![_annot isAnnotReadOnly]) {
        edited = (![[_annot getPopupSubject] isEqualToString:_subjectTextField.text] || ![[_annot getPopupText]isEqualToString:_textView.text]);
        [_annot setPopupSubject:_subjectTextField.text];
        [_annot setPopupText:_textView.text];
    }
    [self dismissViewControllerAnimated:YES completion:^{
        [self->_delegate onDismissPopupTextViewEdited:edited];
    }];
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
