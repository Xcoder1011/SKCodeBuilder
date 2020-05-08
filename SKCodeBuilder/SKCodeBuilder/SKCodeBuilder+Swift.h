//
//  SKCodeBuilder+Swift.h
//  SKCodeBuilder
//
//  Created by shangkun on 2020/5/7.
//  Copyright © 2020 wushangkun. All rights reserved.
//

#import <AppKit/AppKit.h>

#import "SKCodeBuilder.h"

@interface SKCodeBuilder (Swift)

/// 接下来需要处理的 字典 key - value
@property (nonatomic, strong) NSMutableDictionary *handleDicts;

- (void)build_Swift_withJsonObj:(id)jsonObj complete:(BuildComplete)complete;

- (void)generate_Swift_File_withPath:(NSString *)filePath
                         swiftString:(NSMutableString *)swiftString
                            complete:(GenerateFileComplete)complete;

@end

