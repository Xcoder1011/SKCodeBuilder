//
//  NSObject+UUPerforming.h
//  DrivingTest
//
//  Created by shangkun on 2019/11/28.
//  Copyright © 2019 eclicks. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSObject (UUPerforming)

/// 支持多参数,不可传nil

- (void)uu_performSelector:(SEL)aSelector withArguments:(NSArray *)arguments;

- (void)uu_performSelector:(SEL)aSelector withArguments:(NSArray *)arguments afterDelay:(NSTimeInterval)delay;

- (void)uu_performSelector:(SEL)aSelector withArguments:(NSArray *)arguments afterDelay:(NSTimeInterval)delay inModes:(NSArray<NSRunLoopMode> *)modes;

/// 支持可变参数，可传nil

- (id)uu_performSelector:(SEL)aSelector withMoreArguments:(id)argumet,...;

/// 必须以 DTEnd 为结束符 ,可传nil
FOUNDATION_EXPORT NSString *DTString(id param, ...);

#define DTBox(var)                  __dt_box(@encode(__typeof__(var)), (var))

#define DTEnd                [UUPerformingEnd mark]

@end


@interface UUPerformingEnd : NSObject

+ (instancetype)mark;

@end

static inline id __dt_box(const char * type, ...)
{
    va_list argList;
    va_start(argList, type);
    
    id object = nil;
    if (strcmp(type, @encode(id)) == 0) {
        id param = va_arg(argList, id);
        object = param;
    } else if (strcmp(type, @encode(CGPoint)) == 0) {
        CGPoint param = (CGPoint)va_arg(argList, CGPoint);
        object = [NSValue valueWithCGPoint:param];
    } else if (strcmp(type, @encode(CGSize)) == 0) {
        CGSize param = (CGSize)va_arg(argList, CGSize);
        object = [NSValue valueWithCGSize:param];
    } else if (strcmp(type, @encode(CGVector)) == 0) {
        CGVector param = (CGVector)va_arg(argList, CGVector);
        object = [NSValue valueWithCGVector:param];
    } else if (strcmp(type, @encode(CGRect)) == 0) {
        CGRect param = (CGRect)va_arg(argList, CGRect);
        object = [NSValue valueWithCGRect:param];
    } else if (strcmp(type, @encode(NSRange)) == 0) {
        NSRange param = (NSRange)va_arg(argList, NSRange);
        object = [NSValue valueWithRange:param];
    } else if (strcmp(type, @encode(CFRange)) == 0) {
        CFRange param = (CFRange)va_arg(argList, CFRange);
        object = [NSValue value:&param withObjCType:type];
    } else if (strcmp(type, @encode(CGAffineTransform)) == 0) {
        CGAffineTransform param = (CGAffineTransform)va_arg(argList, CGAffineTransform);
        object = [NSValue valueWithCGAffineTransform:param];
    } else if (strcmp(type, @encode(CATransform3D)) == 0) {
        CATransform3D param = (CATransform3D)va_arg(argList, CATransform3D);
        object = [NSValue valueWithCATransform3D:param];
    } else if (strcmp(type, @encode(SEL)) == 0) {
        SEL param = (SEL)va_arg(argList, SEL);
        object = NSStringFromSelector(param);
    } else if (strcmp(type, @encode(Class)) == 0) {
        Class param = (Class)va_arg(argList, Class);
        object = NSStringFromClass(param);
    } else if (strcmp(type, @encode(UIOffset)) == 0) {
        UIOffset param = (UIOffset)va_arg(argList, UIOffset);
        object = [NSValue valueWithUIOffset:param];
    } else if (strcmp(type, @encode(UIEdgeInsets)) == 0) {
        UIEdgeInsets param = (UIEdgeInsets)va_arg(argList, UIEdgeInsets);
        object = [NSValue valueWithUIEdgeInsets:param];
    } else if (strcmp(type, @encode(short)) == 0) {
        short param = (short)va_arg(argList, int);
        object = @(param);
    } else if (strcmp(type, @encode(int)) == 0) {
        int param = (int)va_arg(argList, int);
        object = @(param);
    } else if (strcmp(type, @encode(long)) == 0) {
        long param = (long)va_arg(argList, long);
        object = @(param);
    } else if (strcmp(type, @encode(long long)) == 0) {
        long long param = (long long)va_arg(argList, long long);
        object = @(param);
    } else if (strcmp(type, @encode(float)) == 0) {
        float param = (float)va_arg(argList, double);
        object = @(param);
    } else if (strcmp(type, @encode(double)) == 0) {
        double param = (double)va_arg(argList, double);
        object = @(param);
    } else if (strcmp(type, @encode(BOOL)) == 0) {
        BOOL param = (BOOL)va_arg(argList, int);
        object = param ? @"YES" : @"NO";
    } else if (strcmp(type, @encode(bool)) == 0) {
        bool param = (bool)va_arg(argList, int);
        object = param ? @"true" : @"false";
    } else if (strcmp(type, @encode(char)) == 0) {
        char param = (char)va_arg(argList, int);
        object = [NSString stringWithFormat:@"%c", param];
    } else if (strcmp(type, @encode(unsigned short)) == 0) {
        unsigned short param = (unsigned short)va_arg(argList, unsigned int);
        object = @(param);
    } else if (strcmp(type, @encode(unsigned int)) == 0) {
        unsigned int param = (unsigned int)va_arg(argList, unsigned int);
        object = @(param);
    } else if (strcmp(type, @encode(unsigned long)) == 0) {
        unsigned long param = (unsigned long)va_arg(argList, unsigned long);
        object = @(param);
    } else if (strcmp(type, @encode(unsigned long long)) == 0) {
        unsigned long long param = (unsigned long long)va_arg(argList, unsigned long long);
        object = @(param);
    } else if (strcmp(type, @encode(unsigned char)) == 0) {
        unsigned char param = (unsigned char)va_arg(argList, unsigned int);
        object = [NSString stringWithFormat:@"%c", param];
    } else {
        void * param = (void *)va_arg(argList, void *);
        object = [NSString stringWithFormat:@"%p", param];
    }
    
    va_end(argList);
    
    return object;
}
