//
//  TextAnnotViewController.m
//  PDFViewer
//
//  Created by strong on 13-7-11.
//
//

#import "TextAnnotViewController.h"

@interface TextAnnotViewController ()

@end

@implementation TextAnnotViewController
@synthesize pos_x;
@synthesize pos_y;

@synthesize text;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    NSString *title =[[NSString alloc]initWithFormat:NSLocalizedString(@"Text Annot", @"Localizable")];
    self.title = title;
    
    UIBarButtonItem *cancelBtn = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelTextAnnot)];
    
    UIBarButtonItem *saveBtn = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(saveTextAnnot)];
    
    self.navigationItem.leftBarButtonItem = cancelBtn;
    self.navigationItem.rightBarButtonItem = saveBtn;
    self.view.backgroundColor = [UIColor clearColor];
}

- (void)viewDidAppear:(BOOL)animated
{
    
    _textView = [UITextView new];
    _textView = [[UITextView alloc] initWithFrame:CGRectMake(0, self.navigationController.navigationBar.frame.size.height, self.view.bounds.size.width, self.view.bounds.size.height - self.navigationController.navigationBar.frame.size.height)];
    
    [self.view addSubview:_textView];
    
    _textView.text = text;
    [_textView becomeFirstResponder];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(BOOL)cancelTextAnnot
{
    if(m_delegate)
    {
        [m_delegate OnSaveTextAnnot:@""];
    }
    [self dismissViewControllerAnimated:YES completion:^{
       
    }];
    
    return NO;
}

-(void)saveTextAnnot
{
    if(m_delegate)
    {
        [m_delegate OnSaveTextAnnot:_textView.text];
    }
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
}
-(void)setDelegate:(id<saveTextAnnotDelegate>)delegate
{
    m_delegate = delegate;
}

@end
