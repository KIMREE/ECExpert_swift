//
//  HeartRateTestViewController.h
//  ECExpert
//
//  Created by renchunyu on 15/1/23.
//  Copyright (c) 2015年 renchunyu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import "WaveformView.h"

@interface HeartRateTestViewController : UIViewController<AVCaptureVideoDataOutputSampleBufferDelegate>
{
    UILabel *hintTitle;
    
    NSData *mData;
    float valueLast,value,diffOne,diffTwo,diffThree;//色深及色深差
    Byte *testByte;
    NSMutableArray *valueArray;
    int heartRate,counter,counterLast;//心率，计数器
    
    //心率数据数组
    NSMutableArray *heartRateArray;
    //波形图
    WaveformView *waveView;
    
    //运动小知识
    NSArray *sportHintArray;
    //心率按钮打开
    BOOL isBtnOn;
    BOOL isCalculateHeart;
    
}
@property (strong,nonatomic)   NSTimer* timerStart,*timeStop;
@property (strong,nonatomic)  AVCaptureSession *session;
@property (strong,nonatomic) UIImage *inputImage;
//心率显示界面
@property (strong,nonatomic) UIImageView *backgroundImageView;
@property (strong,nonatomic) UILabel *heartRateLabel;
-(void)timerFired;
@end
