//
//  SignatureViewController.h
//  PDFViewer
//
//  Created by Emanuele Bortolami on 15/01/18.
//

#import <UIKit/UIKit.h>

@protocol SignatureDelegate <NSObject>

- (void)didSign;

@end

@interface SignatureViewController : UIViewController

@property (weak, nonatomic) id <SignatureDelegate> delegate;

@end
