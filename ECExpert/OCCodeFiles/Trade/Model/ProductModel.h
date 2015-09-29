//
//  ProductModel.h
//  ECExpert
//
//  Created by JIRUI on 15/5/13.
//  Copyright (c) 2015年 JIRUI. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ProductModel : NSObject

@property (copy, nonatomic) NSString *scanCode;
@property (assign, nonatomic) NSInteger totalCount;
@property (assign, nonatomic) NSInteger dispatchCount;
@property (copy, nonatomic) NSDate *effectiveDate;
@property (copy, nonatomic) NSDate *expirationDate;


// 商品条码    txt_gtin
@property (copy, nonatomic) NSString *barCodeImageUrl;

// 产品名称(英文)    Att_Sys_en-us_141_G
@property (copy, nonatomic) NSString *productNameEN;

// 产品名称    Att_Sys_zh-cn_141_G
@property (copy, nonatomic) NSString *productNameZH;

// UNSPSC分类    Att_Sys_zh-cn_22_G
@property (copy, nonatomic) NSString *UNSPSC;

// 品牌名称    Att_Sys_zh-cn_304_G
@property (copy, nonatomic) NSString *brandName;

// 规格型号    Att_Sys_zh-cn_332_G
@property (copy, nonatomic) NSString *specifications;

// 宽度    Att_Sys_zh-cn_101_G
@property (copy, nonatomic) NSString *width;
// 宽度单位   Att_Sys_zh-cn_104_G
@property (copy, nonatomic) NSString *widthUnit;

// 高度    Att_Sys_zh-cn_106_G
@property (copy, nonatomic) NSString *height;
// 高度单位    Att_Sys_zh-cn_326_G
@property (copy, nonatomic) NSString *heightUnit;

// 深度    Att_Sys_zh-cn_118_G
@property (copy, nonatomic) NSString *depth;
// 深度单位    Att_Sys_zh-cn_331_G
@property (copy, nonatomic) NSString *depthUnit;

// 原产国    Att_Sys_zh-cn_74_G
@property (copy, nonatomic) NSString *originCountry;

// 装配国    Att_Sys_zh-cn_171_G
@property (copy, nonatomic) NSString *assembleCountry;

// 产品系列    Att_Sys_zh-cn_181_G
@property (copy, nonatomic) NSString *productLine;

+ (ProductModel *) productWithKeyValues: (NSDictionary *)dic;

@end
