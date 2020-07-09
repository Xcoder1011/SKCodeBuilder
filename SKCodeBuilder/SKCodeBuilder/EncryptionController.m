//
//  EncryptionController.m
//  SKCodeBuilder
//
//  Created by shangkun on 2020/7/9.
//  Copyright © 2020 wushangkun. All rights reserved.
//

#import "EncryptionController.h"
#import "SKCodeBuilder.h"
#import "ExampleEncryptConst.h"

@interface EncryptionController ()

@property (unsafe_unretained) IBOutlet NSTextView *inputTextView;
@property (unsafe_unretained) IBOutlet NSTextView *hTextView;
@property (unsafe_unretained) IBOutlet NSTextView *mTextView;

@end

@implementation EncryptionController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
}

- (IBAction)encryptString:(NSButton *)sender {
    
    NSString *inputString = self.inputTextView.textStorage.string;
    [self configJsonTextViewWith:inputString textView:self.inputTextView color:[NSColor blackColor]];
     NSLog(@"原始字符串：%@",inputString);
     __weak typeof(self) weakself = self;
     [SKCodeBuilder encryptString:inputString withKey:nil completion:^(NSString *hStr, NSString *mStr) {
         NSLog(@"加密后hStr：\n%@", hStr);
         NSLog(@"加密后mStr：\n%@", mStr);
         NSColor *color = [NSColor colorWithCalibratedRed:215/255.f green:0/255.f  blue:143/255.f  alpha:1.0];
         [weakself configJsonTextViewWith:hStr textView:weakself.hTextView color:color];
         [weakself configJsonTextViewWith:mStr textView:weakself.mTextView color:color];
         
     }];
     
    /// example decrypt
     NSString *decryptStr = sk_OCString(_1242105574);
     NSLog(@"解密后：%@", decryptStr);
}

/// config textView content on main thred.
- (void)configJsonTextViewWith:(NSString *)text
                      textView:(NSTextView *)textView
                         color:(NSColor *)color {
    NSAttributedString *attrString = [[NSAttributedString alloc] initWithString:text];
    dispatch_async(dispatch_get_main_queue(), ^{
        [textView.textStorage setAttributedString:attrString];
        [textView.textStorage setFont:[NSFont systemFontOfSize:15]];
        [textView.textStorage setForegroundColor:color];
    });
}
@end
