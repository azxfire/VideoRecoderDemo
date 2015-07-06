//
//  WTViewController.m
//  VideoRecoderDemo
//
//  Created by Dady on 14-8-13.
//  Copyright (c) 2014年 qiaoqiao. All rights reserved.
//  选择录制视频的方式：(1)AVCaptureSession,(2)UIImagePickerController

#import "WTViewController.h"
#import "WTVideoViewController.h"
@interface WTViewController ()
@end

@implementation WTViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	//添加AVCaptureSession按钮
    UIButton* avcaptureBtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [avcaptureBtn setTitle:@"录制：AVCaptureSession" forState:UIControlStateNormal];
    [avcaptureBtn addTarget:self action:@selector(recordCapture:) forControlEvents:UIControlEventTouchUpInside];
    CGRect rect = CGRectMake(10, 100, 300, 30);
    avcaptureBtn.frame = rect;
    [self.view addSubview:avcaptureBtn];
    
    rect.origin.y +=50;
    UIButton* imagePicker = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [imagePicker setTitle:@"录制：UIImagePickerController" forState:UIControlStateNormal];
    [imagePicker addTarget:self action:@selector(imagePicker:) forControlEvents:UIControlEventTouchUpInside];
    imagePicker.frame = rect;
    [self.view addSubview:imagePicker];
    
    
    
}
/**
 *  AVCaptureSession touchuUpInSideEvent
 *
 *  @param sender <#sender description#>
 */
-(void)recordCapture:(id)sender
{
    NSLog(@"AVCapture choosed");
    // 检测设备是否支持录像。
//    if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
//        UIAlertView* alert = [[UIAlertView alloc]initWithTitle:@"" message:@"设备无摄像头" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil , nil];
//        [alert show];
//        return;
//    }
    WTVideoViewController* vc = [[WTVideoViewController alloc]init];
//    [self presentModalViewController:vc animated:NO];
//    [self presentViewController:self.vc animated:YES completion:nil];
    [self presentViewController:vc animated:YES completion:^{
        
    }];
//    [self presentModalViewController:self.vc animated:NO];
}
/**
 *  UIImagePicker touchUpInSideEvent
 *
 *  @param
 */
-(void)imagePicker:(id)sender
{
     NSLog(@"imagePicker choosed");
    // 检测设备是否支持录像。
    if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        UIAlertView* alert = [[UIAlertView alloc]initWithTitle:@"" message:@"设备无摄像头" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
        return;
    }
    UIImagePickerController* pickerViewController = [[UIImagePickerController alloc]init];
    
    //设置摄像头未输入源，而不是相册
    pickerViewController.sourceType = UIImagePickerControllerSourceTypeCamera;
    //确定为摄像，不是拍照
   NSArray* availableMedia = [UIImagePickerController availableMediaTypesForSourceType:UIImagePickerControllerSourceTypeCamera];
    pickerViewController.mediaTypes = [NSArray arrayWithObject:availableMedia[1]];
    [self presentViewController:pickerViewController animated:YES completion:nil];
    //设置最大的录像时间
    pickerViewController.videoMaximumDuration = 30;
    pickerViewController.delegate = self;
    
   
}
-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    [self dismissViewControllerAnimated:YES completion:nil];
}
-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissViewControllerAnimated:YES completion:nil];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
