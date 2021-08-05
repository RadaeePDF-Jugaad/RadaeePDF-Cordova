//
//  SignatureViewController.m
//  PDFViewer
//
//  Created by Emanuele Bortolami on 15/01/18.
//

#import "SignatureViewController.h"
#import "UviSignatureView.h"
#import "RDVGlobal.h"

@interface SignatureViewController () {
    
    UviSignatureView *sigView;
    UIToolbar *toolbar;
}

@end

@implementation SignatureViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    UIBarButtonItem *done = [[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStyleDone target:self action:@selector(getImage)];
    UIBarButtonItem *reset = [[UIBarButtonItem alloc] initWithTitle:@"Reset" style:UIBarButtonItemStyleDone target:self action:@selector(resetImage)];
    UIBarButtonItem *close = [[UIBarButtonItem alloc] initWithTitle:@"Close" style:UIBarButtonItemStyleDone target:self action:@selector(dismissView)];
    UIBarButtonItem *flex = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    UIBarButtonItem *fix = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    
    toolbar = [[UIToolbar alloc] init];
    [toolbar setItems:@[done, fix, reset, flex, close]];
    toolbar.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    
    sigView = [[UviSignatureView alloc] init];
    self.view = sigView;
    
    [sigView addSubview:toolbar];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [toolbar setFrame:CGRectMake(0, 0, self.view.bounds.size.width, 44)];
}

- (void)getImage
{
    // Save image to temp path
    [sigView signatureImage:CGPointZero text:@"" fitSignature:GLOBAL.g_fit_signature_to_field];
    [_delegate didSign:_annotIdx];
}

- (void)resetImage
{
    [sigView erase];
}

- (void)dismissView
{
    [self dismissViewControllerAnimated:YES completion:^{
        [self->_delegate onDismissSignView];
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return UIInterfaceOrientationMaskLandscapeRight;
    }
    
    return UIInterfaceOrientationMaskAll;
}

- (BOOL)shouldAutorotate
{
    return ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad);
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
