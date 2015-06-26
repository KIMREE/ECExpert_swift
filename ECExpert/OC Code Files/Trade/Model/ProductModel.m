//
//  ProductModel.m
//  ECExpert
//
//  Created by JIRUI on 15/5/13.
//  Copyright (c) 2015年 JIRUI. All rights reserved.
//

#import "ProductModel.h"
#import <MJExtension/MJExtension.h>

@implementation ProductModel

+ (NSDictionary *)replacedKeyFromPropertyName{
    return @{
             @"barCodeImageUrl":@"txt_gtin",
             @"productNameZH":@"Att_Sys_zh-cn_141_G",
             @"productNameEN":@"Att_Sys_en-us_141_G",
             @"UNSPSC":@"Att_Sys_zh-cn_22_G",
             @"brandName":@"Att_Sys_zh-cn_304_G",
             @"specifications":@"Att_Sys_zh-cn_332_G",
             @"width":@"Att_Sys_zh-cn_101_G",
             @"widthUnit":@"Att_Sys_zh-cn_104_G",
             @"height":@"Att_Sys_zh-cn_106_G",
             @"heightUnit":@"Att_Sys_zh-cn_326_G",
             @"depth":@"Att_Sys_zh-cn_118_G",
             @"depthUnit":@"Att_Sys_zh-cn_331_G",
             @"originCountry":@"Att_Sys_zh-cn_74_G",
             @"assembleCountry":@"Att_Sys_zh-cn_171_G",
             @"productLine":@"Att_Sys_zh-cn_181_G"
             };
}

+ (ProductModel *)productWithKeyValues:(NSDictionary *)dic{
    return [ProductModel objectWithKeyValues:dic];
}

@end
