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

static NSString *const LastInputURLCacheKey = @"LastInputURLCacheKey";
static NSString *const SuperClassNameCacheKey = @"SuperClassNameCacheKey";
static NSString *const ModelNamePrefixCacheKey = @"ModelNamePrefixCacheKey";
static NSString *const RootModelNameCacheKey = @"RootModelNameCacheKey";
static NSString *const AuthorNameCacheKey = @"AuthorNameCacheKey";
static NSString *const BuildCodeTypeCacheKey = @"BuildCodeTypeCacheKey";
static NSString *const SupportJSONModelTypeCacheKey = @"SupportJSONModelTypeCacheKey";
static NSString *const ShouldGenerateFileCacheKey = @"ShouldGenerateFileCacheKey";
static NSString *const GenerateFilePathCacheKey = @"GenerateFilePathCacheKey";

@interface ViewController () <NSTextFieldDelegate>
{
    NSTextField *_currentInputTF;
}

@property (weak) IBOutlet NSPopUpButton *reqTypeBtn;
@property (weak) IBOutlet NSTextField *urlTF;

@property (unsafe_unretained) IBOutlet NSTextView *jsonTextView;
@property (unsafe_unretained) IBOutlet NSTextView *hTextView;
@property (unsafe_unretained) IBOutlet NSTextView *mTextView;

@property (weak) IBOutlet NSTextField *superClassNameTF;
@property (weak) IBOutlet NSTextField *modelNamePrefixTF;
@property (weak) IBOutlet NSTextField *rootModelNameTF;
@property (weak) IBOutlet NSTextField *authorNameTF;

@property (weak) IBOutlet NSPopUpButton *codeTypeBtn;
@property (weak) IBOutlet NSPopUpButton *jsonTypeBtn;
@property (weak) IBOutlet NSButton *generateFileBtn;

/// outputFilePath
@property (nonatomic, copy) NSString * outputFilePath;
@property (nonatomic, strong) SKCodeBuilder *builder;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
   
    [self.reqTypeBtn removeAllItems];
    [self.reqTypeBtn addItemsWithTitles:@[@"GET",@"POST"]];
    [self.reqTypeBtn selectItemAtIndex:0];
    
    [self.codeTypeBtn removeAllItems];
    [self.codeTypeBtn addItemsWithTitles:@[@"Objective-C",@"Swift"]];
    [self.codeTypeBtn selectItemAtIndex:0];
}

- (void)viewDidAppear {
    [super viewDidAppear];
    [self loadUserLastInputContent];
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
                [weakself configJsonTextViewWith:jsonString textView:weakself.jsonTextView color:[NSColor blueColor]];
            }
        }
    }];
    [task resume];
    [[NSUserDefaults standardUserDefaults] setObject:urlString forKey:LastInputURLCacheKey];
}

/// start generate code....
- (IBAction)startMakeCode:(NSButton *)sender {
    
    NSString *jsonString = self.jsonTextView.textStorage.string;
    NSDictionary *jsonDict = [jsonString _toJsonDict];
    BOOL isvalid = [NSJSONSerialization isValidJSONObject:jsonDict];
    if (!isvalid) {
        [self showAlertWithInfo:@"warn: is not a valid JSON !!!"];
        return;
    }
    
    [self saveUserInputContent];
    
    if (self.generateFileBtn.state == 1) {
        if (!_outputFilePath || _outputFilePath.length == 0) {
            [self showAlertWithInfo:@"请选择输出文件路径！"];
            return;
        }
    }
    
    [self configJsonTextViewWith:jsonString textView:self.jsonTextView color:[NSColor blueColor]];
    __weak typeof(self) weakself = self;
    
    [self.builder build_OC_withDict:jsonDict complete:^(NSMutableString *hString, NSMutableString *mString) {
        NSColor *color = [NSColor colorWithCalibratedRed:215/255.f green:0/255.f  blue:143/255.f  alpha:1.0];
        [weakself configJsonTextViewWith:hString textView:weakself.hTextView color:color];
        [weakself configJsonTextViewWith:mString textView:weakself.mTextView color:color];
        if (weakself.generateFileBtn.state == 1) {
            if (weakself.outputFilePath && weakself.outputFilePath.length) {
                [self.builder generate_OC_File_withPath:weakself.outputFilePath hString:hString mString:mString complete:nil];
            }
        }
    }];
}

- (void)showAlertWithInfo:(NSString *)info {
    NSAlert *alert = [[NSAlert alloc] init];
    [alert setMessageText:info];
    [alert setAlertStyle:NSAlertStyleWarning];
    [alert beginSheetModalForWindow:self.view.window completionHandler:nil];
}

- (IBAction)chooseOutputFilePath:(NSButton *)sender {
    NSLog(@"chooseOutputFilePath:");
    NSOpenPanel* openPanel = [NSOpenPanel openPanel];
    [openPanel setCanChooseFiles:NO];
    [openPanel setCanChooseDirectories:YES];
    NSInteger modal = [openPanel runModal];
    if (modal == NSModalResponseOK){
        NSURL *files = [[openPanel URLs] objectAtIndex:0];
        _outputFilePath = files.path;
        // >>>>  /Users/kun/Desktop/CodeGeneratorResult
        NSLog(@"chooseOutputFilePath: %@",_outputFilePath);
    }
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

/// load cache
- (void)loadUserLastInputContent {
    
    NSString *lastUrl = [[NSUserDefaults standardUserDefaults] objectForKey:LastInputURLCacheKey];
    if (lastUrl) [self.urlTF setStringValue:lastUrl];
    
    NSString *superClassName = [[NSUserDefaults standardUserDefaults] objectForKey:SuperClassNameCacheKey];
    if (superClassName) [self.superClassNameTF setStringValue:superClassName];
    
    NSString *modelNamePrefix = [[NSUserDefaults standardUserDefaults] objectForKey:ModelNamePrefixCacheKey];
    if (modelNamePrefix) [self.modelNamePrefixTF setStringValue:modelNamePrefix];
    
    NSString *rootModelName = [[NSUserDefaults standardUserDefaults] objectForKey:RootModelNameCacheKey];
    if (rootModelName) [self.rootModelNameTF setStringValue:rootModelName];
    
    NSString *authorName = [[NSUserDefaults standardUserDefaults] objectForKey:AuthorNameCacheKey];
    if (authorName) [self.authorNameTF setStringValue:authorName];
    
    self.builder.config.codeType = [[NSUserDefaults standardUserDefaults] integerForKey:BuildCodeTypeCacheKey];
    [self.codeTypeBtn selectItemAtIndex:self.builder.config.codeType - 1];

    self.builder.config.jsonType = [[NSUserDefaults standardUserDefaults] integerForKey:SupportJSONModelTypeCacheKey];
    [self.jsonTypeBtn selectItemAtIndex:self.builder.config.jsonType];
    
    [self.generateFileBtn setState:[[NSUserDefaults standardUserDefaults] boolForKey:ShouldGenerateFileCacheKey]];
    
    NSString *outputFilePath = [[NSUserDefaults standardUserDefaults] objectForKey:GenerateFilePathCacheKey];
    if (outputFilePath) _outputFilePath = outputFilePath;

}

/// save cache
- (void)saveUserInputContent {
    
    NSString *superClassName = self.superClassNameTF.stringValue.length ? self.superClassNameTF.stringValue : @"NSObject";
    self.builder.config.superClassName = superClassName;
    [[NSUserDefaults standardUserDefaults] setObject:superClassName forKey:SuperClassNameCacheKey];
    
    NSString *modelNamePrefix = self.modelNamePrefixTF.stringValue.length ? self.modelNamePrefixTF.stringValue : @"NS";
    self.builder.config.modelNamePrefix = modelNamePrefix;
    [[NSUserDefaults standardUserDefaults] setObject:modelNamePrefix forKey:ModelNamePrefixCacheKey];
    
    NSString *rootModelName = self.rootModelNameTF.stringValue.length ? self.rootModelNameTF.stringValue : @"NSRootModel";
    self.builder.config.rootModelName = rootModelName;
    [[NSUserDefaults standardUserDefaults] setObject:rootModelName forKey:RootModelNameCacheKey];
    
    NSString *authorName = self.authorNameTF.stringValue.length ? self.authorNameTF.stringValue : @"NSObject";
    self.builder.config.authorName = authorName;
    [[NSUserDefaults standardUserDefaults] setObject:authorName forKey:AuthorNameCacheKey];
    
    self.builder.config.codeType = self.codeTypeBtn.indexOfSelectedItem + 1;
    [[NSUserDefaults standardUserDefaults] setInteger:self.builder.config.codeType forKey:BuildCodeTypeCacheKey];

    self.builder.config.jsonType = self.jsonTypeBtn.indexOfSelectedItem;
    [[NSUserDefaults standardUserDefaults] setInteger:self.builder.config.jsonType forKey:SupportJSONModelTypeCacheKey];
    
    [[NSUserDefaults standardUserDefaults] setObject:_outputFilePath forKey:GenerateFilePathCacheKey];
    [[NSUserDefaults standardUserDefaults] setBool:self.generateFileBtn.state forKey:ShouldGenerateFileCacheKey];
}

/// _currentInputTF width
- (void)caculateInputContentWidth {
    if (_currentInputTF) {
        NSArray *constraints = _currentInputTF.constraints;
        NSMutableDictionary *attributes = [[NSMutableDictionary alloc] init];
        [attributes setObject:_currentInputTF.font forKey:NSFontAttributeName];
        CGFloat strWidth = [_currentInputTF.stringValue boundingRectWithSize:CGSizeMake(FLT_MAX, 22) options:NSStringDrawingUsesFontLeading | NSStringDrawingUsesLineFragmentOrigin attributes:attributes].size.width + 10;
        strWidth = MAX(strWidth, 114);
        [constraints enumerateObjectsUsingBlock:^(NSLayoutConstraint *constraint, NSUInteger idx, BOOL * _Nonnull stop) {
            if (constraint.firstAttribute == NSLayoutAttributeWidth) {
                constraint.constant = strWidth;
            }
        }];
    }
}

/// MARK: NSControlTextEditingDelegate
- (void)controlTextDidChange:(NSNotification *)obj {
    _currentInputTF = obj.object;
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(caculateInputContentWidth) object:nil];
    [self performSelector:@selector(caculateInputContentWidth) withObject:nil afterDelay:.1f];
}

///MARK: lazy load

/// code builder
- (SKCodeBuilder *)builder {
    if (!_builder) {
        _builder = [[SKCodeBuilder alloc] init];
    }
    return _builder;
}

- (void)setRepresentedObject:(id)representedObject {
    [super setRepresentedObject:representedObject];
}

@end
