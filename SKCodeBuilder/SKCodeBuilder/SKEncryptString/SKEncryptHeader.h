//
//  SKEncryptHeader.h
//  SKCodeBuilder
//
//  Created by shangkun on 2020/5/27.
//  Copyright © 2020 wushangkun. All rights reserved.
//

#ifndef SKEncryptHeader_h
#define SKEncryptHeader_h

#ifdef __cplusplus
extern "C" {
#endif

typedef struct {
    char factor;
    char *value;
    int length;
    char *key;
    int kl;
    char decoded;
}SKEncryptString;

/// retutn decrypted C string.
/// @param data  encrypted data
static inline const char *sk_CString(const SKEncryptString *data) {
    if (data->decoded == 1) {
        return data->value;
    }
    int kl = data->kl;
    char a = 'c';
    if (kl > 0) {
        char b = 'd';
        for (int i = 0; i < kl; i++) {
            data->key[i] ^= (data->factor ^ b);
        }
        int cipherIndex = 0;
        for (int i = 0; i < data->length; i++) {
            cipherIndex = cipherIndex % kl;
            data->value[i] ^= (data->factor ^ a ^ data->key[cipherIndex]);
            cipherIndex++;
        }
    } else {
        for (int i = 0; i < data->length; i++) {
            data->value[i] ^= (data->factor ^ a);
        }
    }
    ((SKEncryptString *)data)->decoded = 1;
    return data->value;
}

#ifdef __OBJC__
#import <Foundation/Foundation.h>

/// retutn decrypted NSString.
/// @param data  encrypted data
static inline NSString *sk_OCString(const SKEncryptString *data)
{
    return [NSString stringWithUTF8String:sk_CString(data)];
}
#endif

#ifdef __cplusplus
}
#endif

#endif /* SKEncryptHeader_h */
