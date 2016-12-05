//
//  RNImageSplit.m
//  RNImageSplit
//
//  Created by wangzixiao on 16/11/14.
//  Copyright © 2016年 WangZiXiao. All rights reserved.
//

#import "RNImageSplit.h"
#import <CoreGraphics/CoreGraphics.h>

@interface RNImageSplit ()
@property(nonatomic, strong) UIImage * code;
@end

@implementation RNImageSplit

RCT_EXPORT_MODULE()

RCT_EXPORT_METHOD(splitImage:(NSString *)ImagePath withCodeImagePath:(NSString *) codeImagePath callback:(RCTResponseSenderBlock)callback) {
    //    //获取屏幕尺寸
    CGFloat Swidth = [UIScreen mainScreen].bounds.size.width;
    CGFloat Sheight = [UIScreen mainScreen].bounds.size.height;
    UIImage * image = [UIImage imageWithContentsOfFile:ImagePath];
    //绘制底部View背景
    UIView * bottomView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, image.size.width, Sheight * 0.299)];
    bottomView.backgroundColor = [UIColor colorWithRed:57/255.0f green:74/255.0f blue:95/255.0f alpha:1];
    //绘制底部View内部控件
    UILabel * label = [[UILabel alloc]initWithFrame:CGRectMake(38, bottomView.frame.size.height *0.15, Swidth * 0.80, 40)];
    label.text = @"长按二维码，";
    label.textColor = [UIColor whiteColor];
    label.font = [UIFont fontWithName:@"PingFangSC-Medium" size:28];
    [bottomView addSubview:label];
    
    UILabel * geneLabel = [[UILabel alloc]initWithFrame:CGRectMake(label.frame.origin.x, CGRectGetMaxY(label.frame), label.frame.size.width, label.frame.size.height)];
    geneLabel.text = @"生成你的基因名片→";
    geneLabel.textColor = [UIColor whiteColor];
    geneLabel.font = [UIFont fontWithName:@"PingFangSC-Medium" size:28];
    [bottomView addSubview:geneLabel];
    //logo
    UIImageView * logoView = [[UIImageView alloc]initWithFrame:CGRectMake(label.frame.origin.x, CGRectGetMaxY(geneLabel.frame) + 12, Swidth *0.485, Sheight* 0.072)];
    logoView.image = [UIImage imageNamed:@"img-logo-white"];
    [bottomView addSubview:logoView];
    //二维码
    if(![codeImagePath  isEqual: @""]) {
        NSURL *imageUrl = [NSURL URLWithString:codeImagePath];
        NSData *data = [NSData dataWithContentsOfURL:imageUrl];
        if(data != nil) {
            self.code = [UIImage imageWithData:data];
        } else {
            self.code = [UIImage imageNamed:@"QR_Code"];
        }
    } else {
        self.code = [UIImage imageNamed:@"QR_Code"];
    }
    CGFloat imageSize = bottomView.frame.size.height -80;
    UIImageView * twoCodeImage = [[UIImageView alloc]initWithFrame:CGRectMake(CGRectGetMaxX(bottomView.frame) - 74 - imageSize, 40, imageSize, imageSize)];
    twoCodeImage.image = self.code;
    [bottomView addSubview:twoCodeImage];
    
    //底部绘制完毕，将UIView转换成UIImage
    UIGraphicsBeginImageContextWithOptions(bottomView.bounds.size, NO, [UIScreen mainScreen].scale);
    [bottomView.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage * bottomImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    //开始合成图片
    CGFloat width = image.size.width;
    CGFloat height = image.size.height + bottomImage.size.height;
    CGSize offScreenSize = CGSizeMake(width, height);
    
    // UIGraphicsBeginImageContext(offScreenSize);用这个重绘图片会模糊
    UIGraphicsBeginImageContextWithOptions(offScreenSize, NO, [UIScreen mainScreen].scale);
    //顶部图片
    CGRect rectT = CGRectMake(0, 0, image.size.width, image.size.height);
    [image drawInRect:rectT];
    //底部图片
    CGRect rectB = CGRectMake(0, rectT.origin.y + image.size.height, bottomImage.size.width, bottomImage.size.height);
    [bottomImage drawInRect:rectB];
    
    UIImage* imagez = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    //把图片存沙盒
    NSString *path_sandox = NSHomeDirectory();
    //设置一个图片的存储路径
    NSString *imagePath = [path_sandox stringByAppendingString:@"/Documents/share.png"];
    //把图片直接保存到指定的路径
    [UIImagePNGRepresentation(imagez) writeToFile:imagePath atomically:YES];
    NSLog(imagePath);
    callback(@[imagePath ? imagePath : [NSNull null]]);
}
@end
