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
    self.view.backgroundColor = [UIColor lightGrayColor];
}

- (void)viewWillAppear:(BOOL)animated
{
    UILabel *subjectLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, self.navigationController.navigationBar.frame.size.height + 15, 90, 50)];
    subjectLabel.text = @"Subject:";
    subjectLabel.textAlignment = NSTextAlignmentCenter;
    
    UILabel *contentLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, subjectLabel.frame.origin.y + subjectLabel.frame.size.height + 5, 90, 50)];
    contentLabel.text = @"Content:";
    contentLabel.textAlignment = NSTextAlignmentCenter;
    
    textField = [[UITextField alloc] initWithFrame:CGRectMake(subjectLabel.frame.size.width, subjectLabel.frame.origin.y, self.view.bounds.size.width  - (subjectLabel.frame.size.width + 5) - 5, 44)];
    textField.backgroundColor = [UIColor whiteColor];
    
    textView = [[UITextView alloc] initWithFrame:CGRectMake(contentLabel.frame.size.width, contentLabel.frame.origin.y, self.view.bounds.size.width - (contentLabel.frame.size.width + 5) - 5, self.view.bounds.size.height - contentLabel.frame.origin.y - 5)];
    
    [self.view addSubview:subjectLabel];
    [self.view addSubview:contentLabel];
    [self.view addSubview:textField];
    [self.view addSubview:textView];
    
    textField.text = _subject;
    textView.text = _text;
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
        [m_delegate OnSaveTextAnnot:@"" subject:@""];
    }
    [self dismissViewControllerAnimated:YES completion:^{
       
    }];
    
    return NO;
}

-(void)saveTextAnnot
{
    if(m_delegate)
    {
        [m_delegate OnSaveTextAnnot:textView.text subject:textField.text];
    }
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
}
-(void)setDelegate:(id<saveTextAnnotDelegate>)delegate
{
    m_delegate = delegate;
}

@end
