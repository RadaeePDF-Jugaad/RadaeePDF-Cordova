//
//  TextAnnotViewController.h
//  PDFViewer
//
//  Created by strong on 13-7-11.
//
//

#import <UIKit/UIKit.h>
@protocol saveTextAnnotDelegate <NSObject>

-(void)OnSaveTextAnnot:(NSString *)textAnnot subject:(NSString *)subject;
@end


@interface TextAnnotViewController : UIViewController
{
    id<saveTextAnnotDelegate> m_delegate;
    UITextField *textField;
    UITextView *textView;
    NSString* text;
}
@property(readwrite) int pos_x;
@property(readwrite) int pos_y;
@property(nonatomic) BOOL readOnly;
@property(strong, nonatomic) NSString *text;
@property(strong, nonatomic) NSString *subject;


-(void)setDelegate:(id<saveTextAnnotDelegate>)delegate;
@end
