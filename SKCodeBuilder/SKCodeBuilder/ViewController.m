//
//  ViewController.m
//  SKCodeBuilder
//
//  Created by shangkun on 2020/4/8.
//  Copyright © 2020 wushangkun. All rights reserved.
//

#import "ViewController.h"

@interface ViewController () <NSTextFieldDelegate>

@property (weak) IBOutlet NSPopUpButton *reqTypeBtn;
@property (weak) IBOutlet NSTextField *urlTF;

@property (unsafe_unretained) IBOutlet NSTextView *jsonTextView;
@property (unsafe_unretained) IBOutlet NSTextView *hTextView;
@property (unsafe_unretained) IBOutlet NSTextView *mTextView;

@end


@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.reqTypeBtn removeAllItems];
    [self.reqTypeBtn addItemsWithTitles:@[@"GET",@"POST"]];
    [self.reqTypeBtn selectItemAtIndex:0];
}

- (void)viewDidAppear {
    [super viewDidAppear];
    NSString *lastUrl = [[NSUserDefaults standardUserDefaults] objectForKey:@"LAST_URL"];
    if (lastUrl) {
        [self.urlTF setStringValue:lastUrl];
    }
}

- (IBAction)requestURLBtnClicked:(NSButton *)sender {
    NSLog(@"URL = %@",self.urlTF.stringValue);
    NSString *urlString = self.urlTF.stringValue;
    if (!urlString || urlString.length == 0)  return;
    __weak typeof(self) weakself = self;
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *task = [session dataTaskWithURL:[NSURL URLWithString:urlString] completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (!error && data) {
            id jsonObject = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
            if (jsonObject) {
                NSData *formatJsonData = [NSJSONSerialization dataWithJSONObject:jsonObject options:NSJSONWritingPrettyPrinted error:nil];
                NSString *jsonString = [[NSString alloc] initWithData:formatJsonData encoding:NSUTF8StringEncoding];
                [weakself configJsonTextViewWith:jsonString];
            }
        }
    }];
    [task resume];
    [[NSUserDefaults standardUserDefaults] setObject:urlString forKey:@"LAST_URL"];
}

- (void)configJsonTextViewWith:(NSString *)jsonString {
    NSAttributedString *attrString = [[NSAttributedString alloc] initWithString:jsonString];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.jsonTextView.textStorage setAttributedString:attrString];
        [self.jsonTextView.textStorage setFont:[NSFont systemFontOfSize:15]];
        [self.jsonTextView.textStorage setForegroundColor:[NSColor blueColor]];
    });
}

- (void)setRepresentedObject:(id)representedObject {
    [super setRepresentedObject:representedObject];
}


@end
