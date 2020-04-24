//
//  ViewController.m
//  SKCodeBuilder
//
//  Created by shangkun on 2020/4/8.
//  Copyright © 2020 wushangkun. All rights reserved.
//

#import "ViewController.h"
#import "NSString+CodeBuilder.h"
#import "SKCodeBuilder.h"

@interface ViewController () <NSTextFieldDelegate>

@property (weak) IBOutlet NSPopUpButton *reqTypeBtn;
@property (weak) IBOutlet NSTextField *urlTF;

@property (unsafe_unretained) IBOutlet NSTextView *jsonTextView;
@property (unsafe_unretained) IBOutlet NSTextView *hTextView;
@property (unsafe_unretained) IBOutlet NSTextView *mTextView;

@property (nonatomic, strong) SKCodeBuilder *builder;

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

/// start generate code....
- (IBAction)startMakeCode:(NSButton *)sender {
    
    NSString *jsonString = self.jsonTextView.textStorage.string;
    NSDictionary *jsonDict = [jsonString _toJsonDict];
    BOOL isvalid = [NSJSONSerialization isValidJSONObject:jsonDict];
    if (!isvalid) {
        NSAlert *alert = [[NSAlert alloc] init];
        [alert setMessageText:@"warn: is not a valid JSON !!!"];
        [alert setAlertStyle:NSAlertStyleWarning];
        [alert beginSheetModalForWindow:self.view.window completionHandler:nil];
        NSLog(@"warn: is not a valid JSON !!!");
        return;
    }
    
    [self configJsonTextViewWith:jsonString];
    // NSLog(@">>>>>>>> startMakeCode with valid json = \n%@",jsonString);
    NSMutableString *string = [self.builder build_OC_h_withDict:jsonDict];
    // NSLog(@">>>>>>>> build_OC_h_withDict = \n%@",string);

    NSAttributedString *attrString = [[NSAttributedString alloc] initWithString:string];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.hTextView.textStorage setAttributedString:attrString];
        [self.hTextView.textStorage setFont:[NSFont systemFontOfSize:15]];
        [self.hTextView.textStorage setForegroundColor:[NSColor colorWithCalibratedRed:215/255.f green:0/255.f  blue:143/255.f  alpha:1.0]];
    });
}

/// GET request URL
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

- (SKCodeBuilder *)builder {
    if (!_builder) {
        _builder = [[SKCodeBuilder alloc] init];
        SKCodeBuilderConfig *config = [SKCodeBuilderConfig new];
        config.rootModelName = @"TestModel";
        config.authorName = @"wushangkun";
        _builder.config = config;
    }
    return _builder;
}

- (void)setRepresentedObject:(id)representedObject {
    [super setRepresentedObject:representedObject];
}

@end
