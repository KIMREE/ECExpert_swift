//
//  WaveformView.m
//  ECBLUE
//
//  Created by renchunyu on 15/1/19.
//  Copyright (c) 2015年 ecigarfan. All rights reserved.
//

#import "WaveformView.h"
#define WIDTH self.frame.size.width
#define HEIGHT self.frame.size.height
@implementation WaveformView


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code

    if (_array) {
        
        
        CGContextRef context = UIGraphicsGetCurrentContext();

        _maxValue=[self getMax:_array];
        //划线
        CGContextSetRGBStrokeColor(context, 255/255.0, 0/255.0, 0/255.0, 1.0);
        CGContextSetLineWidth(UIGraphicsGetCurrentContext(), 1.0);
        CGContextMoveToPoint(context, 1, 0.7*HEIGHT);
        for (int i=0; i<_array.count; i++) {
        CGContextAddLineToPoint(UIGraphicsGetCurrentContext(), (i+1)*WIDTH/_array.count, 0.7*HEIGHT-[_array[i] doubleValue]*0.2*HEIGHT/_maxValue);
            }
        CGContextStrokePath(context);
    }else{
    
        CGContextRef context = UIGraphicsGetCurrentContext();

        CGContextSetRGBStrokeColor(context, 255/255.0, 0/255.0, 0/255.0, 1.0);
        CGContextSetLineWidth(UIGraphicsGetCurrentContext(), 1.0);
        CGContextMoveToPoint(context, 1, 0.7*HEIGHT);
        CGContextAddLineToPoint(UIGraphicsGetCurrentContext(), WIDTH, 0.7*HEIGHT);
        
        CGContextStrokePath(context);

    }
    
}


//获取波峰值
-(double) getMax:(NSArray*)array;
{
    double maxValue=0;
    for (int i=0; i<array.count; i++) {
        if (fabsf([array[i] floatValue])>fabs(maxValue)) {
            maxValue=[array[i] doubleValue];
        }

        
    }

    return maxValue;
}


@end
