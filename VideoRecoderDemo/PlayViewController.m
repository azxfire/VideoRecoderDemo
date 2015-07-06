
//
//  WTVideoViewController.m
//  VideoRecoderDemo
//
//  Created by Dady on 14-8-13.
//  Copyright (c) 2014年 qiaoqiao. All rights reserved.
//
#import "PlayViewController.h"
#import <MediaPlayer/MediaPlayer.h>
#import "QQTextView.h"
@interface PlayViewController ()<UITextViewDelegate>

@property (nonatomic, retain) MPMoviePlayerController* player;
@property (nonatomic, strong) QQTextView *textView;
@property (nonatomic, strong) UITextView* centerTextView;
@end

@implementation PlayViewController
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
-(BOOL)prefersStatusBarHidden
{
    return YES;
}
- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    self.player = [[MPMoviePlayerController alloc] initWithContentURL:self.fileURL];
    
//    self.player.scalingMode = MPMovieScalingModeAspectFit;
    self.player.controlStyle = MPMovieControlStyleDefault;
    [self.player prepareToPlay];
    [self.player.view setFrame:self.view.bounds];
//    self.player.view.frame = CGRectMake(0, 0, 320, 480);
    [self.player setScalingMode:MPMovieScalingModeAspectFill];
    [self.view addSubview:self.player.view];
    
    
//    [self.player setControlStyle:MPMovieControlStyleNone];//隐藏视频播放的控制条
//    UIButton* test  = [UIButton buttonWithType:UIButtonTypeContactAdd];
//    test.center = CGPointMake(200, 40);
//    [test addTarget:self action:@selector(click) forControlEvents:UIControlEventTouchUpInside];
//    [self.player.view addSubview:test];
    UITextView* textView = [[UITextView alloc]initWithFrame:CGRectMake(10, 40, 300, 300)];
    textView.backgroundColor = [UIColor clearColor];
    textView.textAlignment = NSTextAlignmentCenter;
    [self.player.view addSubview:textView];
    [self setupTextView];
    NSNotificationCenter* notificationCenter = [NSNotificationCenter defaultCenter];
    [ notificationCenter addObserver:self selector:@selector(done:) name:MPMoviePlayerPlaybackDidFinishNotification object:self.player ];
    [ notificationCenter addObserver:self selector:@selector(done2:) name:MPMoviePlayerReadyForDisplayDidChangeNotification object:self.player];
    MPVolumeView* volum = [[MPVolumeView alloc]initWithFrame:CGRectMake(0, 400, 320, 20)];
    [self.view addSubview:volum];
    
    
    //添加返回按钮
    UIButton* back = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    back.frame = CGRectMake(10, 20, 40, 30);
    [back setTitle:@"返回" forState:UIControlStateNormal];
    [back addTarget:self action: @selector(back) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:back];
    
    
//    [self.player play];
}
-(void)back
{
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
}
-(void)setupTextView
{
    //添加上半部分的TextView(含有placeholder)
    QQTextView* testView = [[QQTextView alloc]init];
    testView.font = [UIFont systemFontOfSize:15];
    testView.frame = CGRectMake(10, 50, 300, 300);
    testView.backgroundColor = [UIColor clearColor];
    testView.alwaysBounceVertical = YES;
    testView.delegate = self;
    testView.placeHolder = @"Tap to add text";
    testView.textAlignment = NSTextAlignmentCenter;
    testView.textColor = [UIColor whiteColor];
//    testView.backgroundColor = [UIColor redColor];
    self.textView = testView;
    [self.player.view addSubview:testView];
    //添加下半部分的TextView
    UITextView* centerTextView = [[UITextView alloc]init];
    centerTextView.frame = CGRectMake(20, 200, 300, 300);
//    centerTextView.backgroundColor = [UIColor blueColor];
    centerTextView.alwaysBounceVertical = YES;
    centerTextView.textAlignment = NSTextAlignmentCenter;
    centerTextView.delegate = self;
    centerTextView.backgroundColor = [UIColor clearColor];
    self.centerTextView = centerTextView;
//    [self.player.view addSubview:centerTextView];
    
    
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(textDidChange) name:UITextViewTextDidChangeNotification object:testView];
    [QQNotificationCenter addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [QQNotificationCenter addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}
/**
 *  键盘即将显示的时候调用
 */
- (void)keyboardWillShow:(NSNotification *)note
{
    [UIView animateWithDuration:0.25 animations:^{
         self.textView.placeHolder = @"";
    }];
   
    NSLog(@"键盘即将粗线");
}
/**
 *  键盘即将退出的时候调用
 */
- (void)keyboardWillHide:(NSNotification *)note
{
    NSLog(@"键盘即将退出了");

}
-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [self.textView endEditing:YES];
    [self.centerTextView endEditing:YES];
}
-(void)textDidChange
{
//    self.navigationItem.rightBarButtonItem.enabled = (self.textView.text.length != 0);
}
-(void)click
{
    NSLog(@"++++++++++++++");
}
- (void)done:(id)sender
{
    [self.player play];
//    [self dismissViewControllerAnimated:YES completion:^{
//        ;
//    }];
}

- (void)done2:(id)sender
{
    NSLog(@"aa");
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
