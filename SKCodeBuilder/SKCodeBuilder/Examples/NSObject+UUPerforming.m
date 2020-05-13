//
//  NSObject+UUPerforming.m
//  DrivingTest
//
//  Created by shangkun on 2019/11/28.
//  Copyright © 2019 eclicks. All rights reserved.
//

#import "NSObject+UUPerforming.h"

@implementation NSObject (UUPerforming)

- (void)uu_performSelector:(SEL)aSelector withArguments:(NSArray *)arguments {
     
    [self uu_performSelector:aSelector withArguments:arguments afterDelay:0];
}

- (void)uu_performSelector:(SEL)aSelector withArguments:(NSArray *)arguments afterDelay:(NSTimeInterval)delay {
    
    [self uu_performSelector:aSelector withArguments:arguments afterDelay:delay inModes:@[NSRunLoopCommonModes]];
}

- (void)uu_performSelector:(SEL)aSelector withArguments:(NSArray *)arguments afterDelay:(NSTimeInterval)delay inModes:(NSArray<NSRunLoopMode> *)modes {
    
    [[NSRunLoop currentRunLoop] performInModes:modes block:^{
        NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithCapacity:2];
        [dic safeSetObject:NSStringFromSelector(aSelector) forKey:@"aSelector"];
        [dic safeSetObject:arguments forKey:@"arguments"];
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(uu_privatePerformWithParams:) object:dic];
        [self performSelector:@selector(uu_privatePerformWithParams:) withObject:dic afterDelay:delay];
    }];
}

- (void)uu_privatePerformWithParams:(NSDictionary *)params {
    
    SEL aSelector = NSSelectorFromString([params objectForKey:@"aSelector"]);
    NSArray *arguments = [params objectForKey:@"arguments"];
    
    NSMethodSignature *signature = [self.class instanceMethodSignatureForSelector:aSelector];
    if (signature == nil) {
        NSString *errorinfo = [NSString stringWithFormat:@"没有找到这个方法：%@",NSStringFromSelector(aSelector)];
        @throw [NSException exceptionWithName:@"异常错误" reason:errorinfo userInfo:nil];
        return;
    }
    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:signature];
    invocation.target = self;
    invocation.selector = aSelector;
    // 签名中方法参数的个数，内部包含了self和_cmd，所以参数从第3个开始
    if (arguments && arguments.count) {
        NSUInteger argumentsCount = signature.numberOfArguments - 2;
        NSUInteger sourceCount = arguments.count;
        NSUInteger minCount = MIN(argumentsCount, sourceCount);
        for (NSUInteger i = 0; i < minCount; i++) {
            id arg = [arguments objectAtIndex:i];
            // id _Nullable objc_msgSend(id _Nullable self, SEL _Nonnull op, ...)
            [invocation setArgument:&arg atIndex:2+i];
        }
    }
    [invocation invoke];
}

- (id)uu_performSelector:(SEL)aSelector withMoreArguments:(id)argumet, ... {
    
    NSMethodSignature *signature = [self.class instanceMethodSignatureForSelector:aSelector];
    if (signature == nil) {
        NSString *errorinfo = [NSString stringWithFormat:@"没有找到这个方法：%@",NSStringFromSelector(aSelector)];
        @throw [NSException exceptionWithName:@"异常错误" reason:errorinfo userInfo:nil];
    }
    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:signature];
    invocation.target = self;
    invocation.selector = aSelector;
    NSUInteger argumentsCount = signature.numberOfArguments - 2;
    
    va_list argList;
    va_start(argList, argumet);
    id tempObject = argumet;
    for (NSUInteger i = 0; i < argumentsCount; i++) {
        if (tempObject != [UUPerformingEnd mark]) {
            [invocation setArgument:&tempObject atIndex:2+i];
            tempObject = va_arg(argList, id);  // 这里有点问题,不一定都是id 类型，可能还有其他类型，暂时不要用
        } else {
            break;
        }
    }
    
    va_end(argList);
    [invocation invoke];
    // 获取返回值
    id returnValue = nil;
    if (strcmp(signature.methodReturnType, "v") == 0) { // void 类型
        printf("无返回值 signature.methodReturnType >>>> %s",signature.methodReturnType);
    } else { // 有返回值
        printf("有返回值 signature.methodReturnType >>>> %s",signature.methodReturnType);
        [invocation getReturnValue:&returnValue];
    }
    return returnValue;
}

NSString *DTString(id param, ...) {
    
    NSMutableString *mString = [[NSMutableString alloc] initWithString:@""];
    va_list argList;
    va_start(argList, param);
    id arg = param;

    while (arg != [UUPerformingEnd mark]) {
        if (arg != nil) {
            NSString *str = [NSString stringWithFormat:@"%@",arg];
            [mString appendString:str];
        }
        arg = va_arg(argList, id);
    }
    va_end(argList);
    
    return [mString copy];
}

@end

@implementation UUPerformingEnd
// [UUPerformingEnd end] 为自定义的结束符号,为了让参数可以传nil
+ (instancetype)mark{
    static id end = nil;
    static dispatch_once_t token;
    dispatch_once(&token, ^{
        end = [[self class] new];
    });
    return end;
}

@end
