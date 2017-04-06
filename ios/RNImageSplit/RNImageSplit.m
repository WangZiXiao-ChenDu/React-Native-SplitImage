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

- (UIImage*)imageCompressWithSimple:(UIImage*)image scaledToSize:(CGSize)size
{
    UIGraphicsBeginImageContextWithOptions(size, YES, 1.0);
    [image drawInRect:CGRectMake(0,0,size.width,size.height)];
    UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

RCT_EXPORT_METHOD(spliceImageVertical:(NSArray *)imageArr callback:(RCTResponseSenderBlock)callback) {
    float width = 0;
    float height = 0;
    float y = 0;
    for (int i = 0; i< imageArr.count; i++) {
        UIImage * image = [UIImage imageWithContentsOfFile:imageArr[i]];
        width = image.size.width;
        height += image.size.height;
    }
    CGSize offScreenSize = CGSizeMake(width, height);
    UIGraphicsBeginImageContextWithOptions(offScreenSize, YES, 1.0);
    
    for (int i = 0; i < imageArr.count; i++) {
        UIImage * image = [UIImage imageWithContentsOfFile:imageArr[i]];
        CGRect rect = CGRectMake(0, y, image.size.width, image.size.height);
        [image drawInRect:rect];
        y += image.size.height;
    }
    
    UIImage* finishImage = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    //把图片存沙盒
    NSString *path_sandox = NSHomeDirectory();
    //设置一个图片的存储路径
    NSString *imagePath = [path_sandox stringByAppendingString:@"/Documents/VerticalSpliceImage.jpg"];
    //把图片直接保存到指定的路径
    NSError *error;
    
    NSData *data = UIImageJPEGRepresentation(finishImage, 0.5);
    
    BOOL writeSucceeded = [data writeToFile:imagePath options:0 error:&error];
    if (!writeSucceeded) {
        NSLog( @"拼接图片保存沙盒失败" );
        finishImage = nil;
    } else {
        NSLog( @"拼接图片到document %@", imagePath );
        callback(@[imagePath ? imagePath : [NSNull null]]);
    }
}

RCT_EXPORT_METHOD(spliceImageHorizontal:(NSArray *)imageArr callback:(RCTResponseSenderBlock)callback) {
    float width = 0;
    float height = 0;
    for (NSString* path in imageArr) {
        UIImage * image = [UIImage imageWithContentsOfFile:path];
        width += image.size.width;
        height = image.size.height;
    }
    CGSize offScreenSize = CGSizeMake(width, height);
    UIGraphicsBeginImageContextWithOptions(offScreenSize, NO, [UIScreen mainScreen].scale);
    
    for (int i = 0; i < imageArr.count; i++) {
        UIImage * image = [UIImage imageWithContentsOfFile:imageArr[i]];
        CGRect rect = CGRectMake(image.size.width * i, 0, image.size.width, image.size.height);
        [image drawInRect:rect];
    }
    
    UIImage* finishImage = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    //把图片存沙盒
    NSString *path_sandox = NSHomeDirectory();
    //设置一个图片的存储路径
    NSString *imagePath = [path_sandox stringByAppendingString:@"/Documents/HorizontalSpliceImage.jpg"];
    //把图片直接保存到指定的路径
    NSError *error;
    
    NSData *data = UIImageJPEGRepresentation(finishImage, 0.5);
    
    BOOL writeSucceeded = [data writeToFile:imagePath options:0 error:&error];
    if (!writeSucceeded) {
        NSLog( @"拼接图片保存沙盒失败" );
        finishImage = nil;
    } else {
        NSLog( @"拼接图片到document %@", imagePath );
        callback(@[imagePath ? imagePath : [NSNull null]]);
    }
}

RCT_EXPORT_METHOD(splitImage:(NSString *)ImagePath withCodeImagePath:(NSString *) codeImagePath callback:(RCTResponseSenderBlock)callback) {
    //    //获取屏幕尺寸
    int pt = 0;
    CGFloat Swidth = [UIScreen mainScreen].bounds.size.width;
    CGFloat Sheight = [UIScreen mainScreen].bounds.size.height;
    UIImage * image = [UIImage imageWithContentsOfFile:ImagePath];
    switch ((int)Swidth) {
        case 320:
            pt = 1;
            break;
        case 375:
            pt = 2;
            break;
        case 414:
            pt = 3;
            break;
        default:
            pt = 1;
            break;
    }
    //绘制底部View背景
    UIView * bottomView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, image.size.width, 100 * pt)];
    bottomView.backgroundColor = [UIColor colorWithRed:57/255.0f green:74/255.0f blue:95/255.0f alpha:1];
    
    //绘制底部View内部控件
    UILabel * label = [[UILabel alloc]initWithFrame:CGRectMake(38 * pt, 15 * pt, 200 * pt, 20 * pt)];
    label.text = @"长按二维码，";
    label.textColor = [UIColor whiteColor];
    label.font = [UIFont fontWithName:@"PingFangSC-Medium" size:14 * pt];
    [bottomView addSubview:label];
    
    UILabel * geneLabel = [[UILabel alloc]initWithFrame:CGRectMake(label.frame.origin.x, CGRectGetMaxY(label.frame), label.frame.size.width, label.frame.size.height)];
    geneLabel.text = @"开启自己的基因探索之旅";
    geneLabel.textColor = [UIColor whiteColor];
    geneLabel.font = [UIFont fontWithName:@"PingFangSC-Medium" size:14 * pt];
    [bottomView addSubview:geneLabel];
    //logo
    UIImageView * logoView = [[UIImageView alloc]initWithFrame:CGRectMake(label.frame.origin.x, CGRectGetMaxY(geneLabel.frame) + 6, 91 * pt, 24 * pt)];
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
    CGFloat imageSize = 60 * pt;
    UIImageView * twoCodeImage = [[UIImageView alloc]initWithFrame:CGRectMake(CGRectGetMaxX(bottomView.frame) - 37 * pt - imageSize, 20 * pt, imageSize, imageSize)];
    twoCodeImage.image = self.code;
    [bottomView addSubview:twoCodeImage];
    
    //底部绘制完毕，将UIView转换成UIImage
    UIGraphicsBeginImageContextWithOptions(bottomView.bounds.size, YES, 1.0);
    [bottomView.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage * bottomImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    //开始合成图片
    CGFloat width = image.size.width;
    CGFloat height = image.size.height + bottomImage.size.height;
    CGSize offScreenSize = CGSizeMake(width, height);
    
    // UIGraphicsBeginImageContext(offScreenSize);用这个重绘图片会模糊
    UIGraphicsBeginImageContextWithOptions(offScreenSize, YES, 1.0);
    //顶部图片
    CGRect rectT = CGRectMake(0, 0, image.size.width, image.size.height);
    [image drawInRect:rectT];
    //底部图片
    CGRect rectB = CGRectMake(0, rectT.origin.y + image.size.height, bottomImage.size.width, bottomImage.size.height);
    [bottomImage drawInRect:rectB];
    
    UIImage* finishImage = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    //把图片存沙盒
    NSString *path_sandox = NSHomeDirectory();
    //设置一个图片的存储路径
    NSString *imagePath = [path_sandox stringByAppendingString:@"/Documents/share.jpg"];
    //把图片直接保存到指定的路径
    NSError *error;
    
    NSData *data = UIImageJPEGRepresentation(finishImage, 0.5);
    
    BOOL writeSucceeded = [data writeToFile:imagePath options:0 error:&error];
    if (!writeSucceeded) {
        NSLog( @"图片保存沙盒失败" );
        finishImage = nil;
    } else {
        NSLog( @"保存到document %@", imagePath );
        callback(@[imagePath ? imagePath : [NSNull null]]);
    }
}

RCT_EXPORT_METHOD(splitallTags:(NSString *)ImagePath withCodeImagePath:(NSString *) codeImagePath callback:(RCTResponseSenderBlock)callback) {
    //    //获取屏幕尺寸
    CGFloat Swidth = [UIScreen mainScreen].bounds.size.width;
    CGFloat Sheight = [UIScreen mainScreen].bounds.size.height;
    UIImage * topImage = [UIImage imageWithContentsOfFile:ImagePath];
    NSLog(@"-----> %ld, %ld", topImage.size.width, topImage.size.height);
    int pt;
    int Y;
    if (Sheight == 667) {
        pt = 2;
        Y = 478;
    } else if (Sheight == 736) {
        pt = 2;
        Y = 478;
    } else {
        pt = 1;
        Y = 600;
    }
    //绘制顶部view
    UIImageView * topImageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, Swidth, Sheight)];
    topImageView.image = topImage;
    UIView * splaceView = [[UIView alloc]initWithFrame:CGRectMake(0, Y, topImage.size.width, 40*pt)];
    splaceView.backgroundColor = [UIColor colorWithRed:83/255.0f green:195/255.0f blue:237/255.0f alpha:1];
    [topImageView addSubview:splaceView];
    UIGraphicsBeginImageContextWithOptions(topImageView.bounds.size, NO, [UIScreen mainScreen].scale);
    [topImageView.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage * image= UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    //绘制底部View背景
    UIView * bottomView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, image.size.width, 50*pt)];
    bottomView.backgroundColor = [UIColor colorWithRed:57/255.0f green:74/255.0f blue:95/255.0f alpha:1];
    //绘制底部View内部控件
    UILabel * label = [[UILabel alloc]initWithFrame:CGRectMake(19*pt, 7.5*pt, 150*pt, 10*pt)];
    label.text = @"长按二维码，";
    label.textColor = [UIColor whiteColor];
    label.font = [UIFont fontWithName:@"PingFangSC-Medium" size:14];
    [bottomView addSubview:label];
    
    UILabel * geneLabel = [[UILabel alloc]initWithFrame:CGRectMake(label.frame.origin.x, CGRectGetMaxY(label.frame), label.frame.size.width, label.frame.size.height)];
    geneLabel.text = @"开启自己的基因探索之旅";
    geneLabel.textColor = [UIColor whiteColor];
    geneLabel.font = [UIFont fontWithName:@"PingFangSC-Medium" size:14];
    [bottomView addSubview:geneLabel];
    //logo
    UIImageView * logoView = [[UIImageView alloc]initWithFrame:CGRectMake(label.frame.origin.x, CGRectGetMaxY(geneLabel.frame) + 6*pt, 45.5*pt, 12*pt)];
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
    UIImageView * twoCodeImage = [[UIImageView alloc]initWithFrame:CGRectMake(bottomView.frame.size.width - 19*pt - 30*pt, 10*pt, 30*pt, 30*pt)];
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
    
    UIImage* finishImage = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    //把图片存沙盒
    NSString *path_sandox = NSHomeDirectory();
    //设置一个图片的存储路径
    NSString *imagePath = [path_sandox stringByAppendingString:@"/Documents/share.jpg"];
    //把图片直接保存到指定的路径
    NSError *error;
    
    NSData *data = UIImageJPEGRepresentation(finishImage, 0.5);
    
    BOOL writeSucceeded = [data writeToFile:imagePath options:0 error:&error];
    if (!writeSucceeded) {
        NSLog( @"图片保存沙盒失败" );
        finishImage = nil;
    } else {
        NSLog( @"保存到document %@", imagePath );
        callback(@[imagePath ? imagePath : [NSNull null]]);
    }
}
@end
