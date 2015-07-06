//
//  WTVideoViewController.m
//  VideoRecoderDemo
//
//  Created by Dady on 14-8-13.
//  Copyright (c) 2014年 qiaoqiao. All rights reserved.
//

#import "WTVideoViewController.h"
#import "PlayViewController.h"
#import <AssetsLibrary/AssetsLibrary.h>
@interface WTVideoViewController ()
//是否开始录制的标记
@property (nonatomic, assign) BOOL started;
//视频录制的帧的总量
@property (nonatomic, assign) CMTime frameDuration;
//下一帧
@property (nonatomic, assign) CMTime nextFPTS;
//视频录制的session
@property (nonatomic, retain) AVCaptureSession* captureSession;
//存储数据(音频，视频)的中间媒介
@property (nonatomic, retain) AVAssetWriter* assetWriter;
//assetWriter写入视频的时候使用的输入数据
@property (nonatomic, retain) AVAssetWriterInput* videoAssetWriterInput;
//assetWriter写入音频的时候使用的输入数据
@property (nonatomic, retain) AVAssetWriterInput* audioAssetWriterInput;
//捕获的视频输出
@property (nonatomic, retain) AVCaptureVideoDataOutput* videoOutput;
//捕获的音频输出
@property (nonatomic, retain) AVCaptureAudioDataOutput* audioOutput;
//存储mov格式视频的URL
@property (nonatomic, retain) NSURL* outputMovURL;
//存储mp4格式视频的地址
@property (nonatomic, retain) NSURL* outputMp4URL;

@property (nonatomic, retain) AVCaptureDevice* videoDevice;
@property (nonatomic, retain) AVCaptureDeviceInput* videoInput;

//显示捕获的层
@property (nonatomic, retain) UIView* previewView;
//显示视频录制的进度
@property (nonatomic, retain) UIProgressView* progrossBar;
//当前是第几帧
@property (nonatomic, assign) NSInteger currentFrame;
//最大帧
@property (nonatomic, assign) NSInteger maxFrame;

//闪光灯按钮，当使用的是前置摄像头的时候不能使用摄像灯
@property (nonatomic, weak) UIButton* changeTorchModeBtn;
//是否录制音频
@property (nonatomic, weak) UISwitch* recodeAudioSwitch;

//播放按钮
@property (nonatomic, weak) UIButton* playBtn;
@property (nonatomic, weak) UIButton* playmp4Btn;
//记录切换摄像头按钮，当正在进行录制的时候禁止切换摄像头
@property (nonatomic, weak) UIButton* cameraToggleBtn;
@end

@implementation WTVideoViewController
-(void)dealloc
{
    
}
-(BOOL)prefersStatusBarHidden
{
    return YES;
}
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
-(void)viewDidAppear:(BOOL)animated
{
    [self.captureSession startRunning];
}
- (void)viewDidLoad
{
   
    self.view.backgroundColor = [UIColor whiteColor];
    self.started = NO;
    self.currentFrame = 0;
    self.maxFrame = 240; // 设置每秒24帖，最长10秒
    
    
    self.outputMovURL = [NSURL fileURLWithPath:[[self docDir] stringByAppendingPathComponent:@"v.mov"]];
    self.outputMp4URL = [NSURL fileURLWithPath:[[self docDir] stringByAppendingPathComponent:@"v.mp4"]];
    
    [self deleteFile:self.outputMovURL];
    [self deleteFile:self.outputMp4URL];
    
    [self setupAVCapture];
    [self setupPreview];
    [self setupButtons];
    [self setupProgressBar];
     [super viewDidLoad];
}

- (void)back:(id)sender
{
    if (![self.presentedViewController isBeingDismissed]) {
//        [self dismissViewControllerAnimated:YES completion:NULL];
        //点击返回的时候让视频停止录制
        [self dismissModalViewControllerAnimated:YES];
        self.started = NO;
        //设置进度条进度为0
        self.progrossBar.progress = 0;
        //删除沙河缓存文件
        [self deleteFile:self.outputMovURL];
        [self deleteFile:self.outputMp4URL];
        //关闭闪光灯
        //返回的时候必须关闭闪光灯，否则再次进入视频录制的时候还是会开着闪光灯的
        if(self.videoDevice.torchMode == AVCaptureTorchModeOn)
            
        {
            [self.captureSession beginConfiguration];
            [self.videoDevice lockForConfiguration:nil];
            
            [self.videoDevice setTorchMode:AVCaptureTorchModeOff];
            
            [self.videoDevice unlockForConfiguration];
            [self.captureSession commitConfiguration];
        }
        
    }
    
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark - private method
//查找系统目录
- (NSString*)docDir
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *docDir = nil;
    if ([paths count] > 0) {
        docDir = [paths objectAtIndex:0];
    }
    return docDir;
}
- (void)showAlert:(NSString*)text
{
    UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@""
                                                    message:text
                                                   delegate:nil
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil, nil];
    [alert show];
}

- (void)deleteFile:(NSURL*)filePath
{
    NSFileManager *fm = [[NSFileManager alloc] init];
    // 是否存在
    BOOL isExistsOk = [fm fileExistsAtPath:[filePath path]];
    
    if (isExistsOk) {
        [fm removeItemAtURL:filePath error:nil];
        NSLog(@"file deleted:%@",filePath);
    }
    else {
        NSLog(@"file not exists:%@",filePath);
    }
    
}
#pragma mark - capture method
//这个方法比较耗时间
- (BOOL)setupAVCapture
{
    NSError *error = nil;
    // 24 fps - taking 25 pictures will equal 1 second of video
	self.frameDuration = CMTimeMakeWithSeconds(1./24., 90000);
	
	self.captureSession = [[AVCaptureSession alloc] init];
	[self.captureSession setSessionPreset:AVCaptureSessionPreset640x480];
	
    
    //创建device input self.captureSession addOutput
    AVCaptureDevice* microPhone = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeAudio];
    AVCaptureDeviceInput* audioInput = [AVCaptureDeviceInput deviceInputWithDevice:microPhone error:&error];
    
    if (error) {
        return NO;
    }
    if ([self.captureSession canAddInput:audioInput]) {
        [self.captureSession addInput:audioInput];
    }
    
    self.audioOutput = [[AVCaptureAudioDataOutput alloc]init];
    [self.audioOutput setSampleBufferDelegate:self queue:dispatch_get_main_queue()];
    if ([self.captureSession canAddOutput:self.audioOutput]) {
        [self.captureSession addOutput:self.audioOutput];
    }
 
    
	// Select a video device, make an input
	AVCaptureDevice *backCamera = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    self.videoDevice = backCamera;
    
	AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:backCamera error:&error];
    self.VideoInput = input;
    
    
	if (error)
		return NO;
	if ([self.captureSession canAddInput:input])
		[self.captureSession addInput:input];
	
    self.videoOutput = [[AVCaptureVideoDataOutput alloc] init];
    [self.videoOutput setAlwaysDiscardsLateVideoFrames:YES];
    if ([self.captureSession canAddOutput:self.videoOutput]) {
        [self.captureSession addOutput:self.videoOutput];
    }
    dispatch_queue_t queue = dispatch_queue_create("myQueue", NULL);
    [self.videoOutput setSampleBufferDelegate:self queue:queue];
    
	
    self.videoOutput.videoSettings =
    [NSDictionary dictionaryWithObject:
     [NSNumber numberWithInt:kCVPixelFormatType_32BGRA]
                                forKey:(id)kCVPixelBufferPixelFormatTypeKey];
    
    // start the capture session running, note this is an async operation
    // status is provided via notifications such as AVCaptureSessionDidStartRunningNotification/AVCaptureSessionDidStopRunningNotification
//    [self.captureSession startRunning];
#warning 如果在这里就进行startRunning的话就会到这modal控制器的速度非常的慢。所以应该将这个步骤添加到viewDidAppear方法中去
//	[self.captureSession startRunning];
	return YES;
    
}
#pragma mark - changeTorchMode
/**
 *  开启或者关闭闪光灯
 */
-(void)changeTorchMode
{
    if (self.videoDevice.torchMode == AVCaptureTorchModeOff) {
        //打开闪光灯的方法
        [self.captureSession beginConfiguration];
        [self.videoDevice lockForConfiguration:nil];
        
        // Set torch to on
        [self.videoDevice setTorchMode:AVCaptureTorchModeOn];
        
        [self.videoDevice unlockForConfiguration];
        [self.captureSession commitConfiguration];
    }else if(self.videoDevice.torchMode == AVCaptureTorchModeOn)
        
    {
        [self.captureSession beginConfiguration];
        [self.videoDevice lockForConfiguration:nil];
        
        // Set torch to on
        [self.videoDevice setTorchMode:AVCaptureTorchModeOff];
        
        [self.videoDevice unlockForConfiguration];
        [self.captureSession commitConfiguration];
    }
    
}

-(AVCaptureDevice *)CameraWithPosition:(AVCaptureDevicePosition)Position
{
    NSArray* Devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    for (AVCaptureDevice *Device in Devices) {
        if ([Device position] == Position) {
            return Device;
        }
    }
    return nil;
}

-(void)CameraSetOutputProperties
{
    //SET THE CONNECTION PROPERTIES (output properties)
    AVCaptureConnection* CaptureConnection = [self.videoOutput connectionWithMediaType:AVMediaTypeVideo];
    
    //Set landscape(if required)
    if ([CaptureConnection isVideoOrientationSupported]) {
        AVCaptureVideoOrientation orientation = AVCaptureVideoOrientationLandscapeRight;
        [CaptureConnection setVideoOrientation:orientation];
    }
    
}
/**
 *  切换前后摄像头
 */
-(IBAction)CameraToggleButtonPressed
{
    if ([[AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo]count]>1) {
        NSLog(@"Toggle camera");
        NSError* error;
        AVCaptureDeviceInput* NewVideoInput;
        AVCaptureDevicePosition position = self.videoInput.device.position;
        if (position == AVCaptureDevicePositionBack) {
            CATransition* anim = [CATransition animation];
            //            anim.subtype = kCATransitionFromTop;
            anim.type = @"pageUnCurl";
            anim.duration = 0.5;
            [self.view.layer addAnimation:anim forKey:nil];
            NewVideoInput = [[AVCaptureDeviceInput alloc]initWithDevice:[self CameraWithPosition:AVCaptureDevicePositionFront] error:&error];
            self.changeTorchModeBtn.enabled = NO;
            
        }else if (position == AVCaptureDevicePositionFront)
        {
            CATransition* anim = [CATransition animation];
            //            anim.subtype = kCATransitionFromTop;
            anim.type = @"pageUnCurl";
            anim.duration = 0.5;
            [self.view.layer addAnimation:anim forKey:nil];
            NewVideoInput = [[AVCaptureDeviceInput alloc]initWithDevice:[self CameraWithPosition:AVCaptureDevicePositionBack] error:&error];
            self.changeTorchModeBtn.enabled = YES;
        }
        if (NewVideoInput != nil) {
            [self.captureSession beginConfiguration];
            [self.captureSession removeInput:self.videoInput];
            if ([self.captureSession canAddInput:NewVideoInput]) {
                [self.captureSession addInput:NewVideoInput];
                self.videoInput = NewVideoInput;
            }
            else
            {
                [self.captureSession addInput:self.videoInput];
            }
            [self CameraSetOutputProperties];
            
            [self.captureSession commitConfiguration];
            //            [NewVideoInput release];
        }
    }
}


#pragma mark setupPreview
/**
 *  设置显示画面的层到self.view上面
 */
- (void)setupPreview
{
    CGFloat windowH = [UIScreen mainScreen].bounds.size.height;
    self.previewView = [[UIView alloc]initWithFrame:CGRectMake(0, 10, 320, windowH-50)];
    AVCaptureVideoPreviewLayer* previewLayer = [[AVCaptureVideoPreviewLayer alloc]initWithSession:self.captureSession];
    [previewLayer setVideoGravity:AVLayerVideoGravityResizeAspectFill];
    [previewLayer setFrame:[self.previewView bounds]];
    
    //添加layer到previewView
    CALayer* rootLayer = [self.previewView layer];
    [rootLayer setBackgroundColor:[[UIColor blackColor]CGColor]];
    [rootLayer addSublayer:previewLayer];
    [self.view addSubview:self.previewView];
    
    //添加一个按钮用来开启或者关闭闪光灯
    UIButton* changeTorchModeBtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    changeTorchModeBtn.frame = CGRectMake(20, 360, 60, 30);
    [changeTorchModeBtn setTitle:@"闪光灯" forState:UIControlStateNormal];
    self.changeTorchModeBtn = changeTorchModeBtn;
    [self.view addSubview:changeTorchModeBtn];
    [changeTorchModeBtn addTarget:self action:@selector(changeTorchMode) forControlEvents:UIControlEventTouchUpInside];
    //添加一个按钮来切换前后摄像头
    UIButton* cameraToggleBtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    cameraToggleBtn.frame = CGRectMake(20, 300, 60, 30);
    [cameraToggleBtn setTitle:@"摄像头" forState:UIControlStateNormal];
    [self.view addSubview:cameraToggleBtn];
    self.cameraToggleBtn = cameraToggleBtn;
    [cameraToggleBtn addTarget:self action:@selector(CameraToggleButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    //添加一个按钮来决定是否录制音频
    UISwitch* recodeAudioSwitch = [[UISwitch alloc]init];
    recodeAudioSwitch.frame = CGRectMake(260, 360, 0, 0);
    [self.view addSubview:recodeAudioSwitch];
    self.recodeAudioSwitch = recodeAudioSwitch;
    
    //添加是否录制音频的lable
    UIButton* audioBtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    audioBtn.frame = CGRectMake(210, 300, 120, 30);
    [audioBtn setTitle:@"是否录制音频" forState:UIControlStateNormal];
    [self.view addSubview:audioBtn];
    
}
/**
 *  添加按钮
 */
- (void)setupButtons
{
    CGFloat w = 60.0f;
    CGFloat h = 40.0f;
    CGFloat y = self.view.frame.size.height - h;
    CGRect f = CGRectMake(0.0f, y, w, h);
    UIButton* button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    button.frame = f;
    [button setTitle:@"start" forState:UIControlStateNormal];
    [button addTarget:self action:@selector(start:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];
    
    f.origin.x += (w + 5);
    UIButton* button1 = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    button1.frame = f;
    [button1 setTitle:@"stop" forState:UIControlStateNormal];
    [button1 addTarget:self action:@selector(stop:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button1];
    
    
    f.origin.x += (w + 5);
    UIButton* button2 = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    button2.frame = f;
    [button2 setTitle:@"playmov" forState:UIControlStateNormal];
    [button2 addTarget:self action:@selector(playmov:) forControlEvents:UIControlEventTouchUpInside];
//    button2.enabled = NO;
    self.playBtn = button2;
    self.playBtn.enabled = NO;
    [self.view addSubview:button2];
    
    f.origin.x += (w + 5);
    UIButton* button3 = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    button3.frame = f;
    [button3 setTitle:@"playmp4" forState:UIControlStateNormal];
    self.playmp4Btn = button3;
    self.playmp4Btn.enabled = NO;
    [button3 addTarget:self action:@selector(playmp4:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button3];
    
    f.origin.x += (w + 5);
    UIButton* button4 = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    button4.frame = f;
    [button4 setTitle:@"back" forState:UIControlStateNormal];
    [button4 addTarget:self action:@selector(back:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button4];
    
}
/**
 *  设置进度指示器
 */
-(void)setupProgressBar
{
    self.progrossBar = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleDefault];
    self.progrossBar.frame = CGRectMake(0.0f, 5.0f, self.view.frame.size.width, 10.0f);
    [self.view addSubview:self.progrossBar];
}
/**
 *  button action
 */
- (void)start:(id)sender
{
    
    UIButton* button = (UIButton*)sender;
    
    
    if (self.started) {
        // 暂停
        [button setTitle:@"start" forState:UIControlStateNormal];
        self.started = NO;
    }
    else {
        // 开始
        if (self.currentFrame == 0) {
            // 试图删一下原誩件
            [self deleteFile:self.outputMovURL];
            [self deleteFile:self.outputMp4URL];
            self.cameraToggleBtn.enabled = NO;
            
        }
        [button setTitle:@"pause" forState:UIControlStateNormal];
        self.started = YES;
    }

}
- (void)stop:(id)sender
{
    NSLog(@"%ld",(long)self.currentFrame);
    self.started = NO;
    if (self.assetWriter != nil) {
        [self.videoAssetWriterInput markAsFinished];//标记为录制完成
        [self.assetWriter finishWritingWithCompletionHandler:^{
            ;
        }];
        self.videoAssetWriterInput = nil;
        self.assetWriter = nil;
    }
    self.currentFrame = 0;
}
- (void)playmov:(id)sender
{
    NSFileManager *fm = [[NSFileManager alloc] init];
    // 是否存在
    BOOL isExistsOk = [fm fileExistsAtPath:[self.outputMovURL path]];
    
    if (isExistsOk) {
        PlayViewController* vc = [[PlayViewController alloc] init];
        vc.fileURL = self.outputMovURL;
        [self presentViewController:vc animated:YES completion:^{
            NSData* data = [NSData dataWithContentsOfURL:vc.fileURL];
            ;
            NSLog(@"%f",(unsigned long)data.length/1024.0/1024);//10秒录制240帧，视屏的大小
        }];
    }
    else {
        [self showAlert:@"文件不存在"];
    }
    

    
}
- (void)playmp4:(id)sender
{
    NSFileManager *fm = [[NSFileManager alloc] init];
    // 是否存在
    BOOL isExistsOk = [fm fileExistsAtPath:[self.outputMp4URL path]];
    
    if (isExistsOk) {
        PlayViewController* vc = [[PlayViewController alloc] init];
        vc.fileURL = self.outputMp4URL;
        [self presentViewController:vc animated:YES completion:^{
            ;
        }];
    }
    else {
        //        [self showAlert:@"文件不存在"];
        [self convertToMp4];
    }
    
}

- (void)convertToMp4
{
    NSString* _mp4Quality = AVAssetExportPresetMediumQuality;
    
    // 试图删除原mp4
    [self deleteFile:self.outputMp4URL];
    
    // 生成mp4
    CFAbsoluteTime s = CFAbsoluteTimeGetCurrent();
    AVURLAsset *avAsset = [AVURLAsset URLAssetWithURL:self.outputMovURL options:nil];
    NSArray *compatiblePresets = [AVAssetExportSession exportPresetsCompatibleWithAsset:avAsset];
    
    if ([compatiblePresets containsObject:_mp4Quality]) {
        __block AVAssetExportSession *exportSession = [[AVAssetExportSession alloc]initWithAsset:avAsset
                                                                                      presetName:_mp4Quality];
        
        exportSession.outputURL = self.outputMp4URL;
        //        exportSession.shouldOptimizeForNetworkUse = _networkOpt;
        exportSession.outputFileType = AVFileTypeMPEG4;
        [exportSession exportAsynchronouslyWithCompletionHandler:^{
            switch ([exportSession status]) {
                case AVAssetExportSessionStatusFailed:
                    NSLog(@"AVAssetExportSessionStatusFailed:%@",[exportSession error]);
                    break;
                    
                case AVAssetExportSessionStatusCancelled:
                    NSLog(@"Export canceled");
                    break;
                case AVAssetExportSessionStatusCompleted:
                {
                    NSLog(@"Successful!");
                    [self performSelectorOnMainThread:@selector(convertFinish) withObject:nil waitUntilDone:NO];
                    CFAbsoluteTime e = CFAbsoluteTimeGetCurrent();
                    
                    NSLog(@"MP4:%f",e-s);
                    
                }
                    break;
                default:
                    break;
            }
        }];
    }
    else
    {
        [self showAlert:@"AVAsset doesn't support mp4 quality"];
    }
}
- (void)convertFinish
{
    [self showAlert:@"convert OK"];
}
static CGFloat DegreesToRadians(CGFloat degrees) {
    return degrees * M_PI / 180;
};
-(BOOL)setupAssetWriterForURL:(NSURL *)fileURL formatDescription:(CMFormatDescriptionRef)formatDescription
{
    // allocate the writer object with our output file URL
	NSError *error = nil;
	self.assetWriter = [[AVAssetWriter alloc] initWithURL:fileURL fileType:AVFileTypeQuickTimeMovie error:&error] ;
	if (error)
		return NO;
	
    // initialized a new input for video to receive sample buffers for writing
    // passing nil for outputSettings instructs the input to pass through appended samples, doing no processing before they are written
#warning 下面这两个属性会影响录制视频的质量，从而影响视频的大小
    // 下面这个参数，设置图像质量，数字越大，质量越好
    NSDictionary *videoCompressionProps = [NSDictionary dictionaryWithObjectsAndKeys:
                                           [NSNumber numberWithDouble:480*1024.0], AVVideoAverageBitRateKey,
                                           nil ];
    // 设置编码和宽高比。宽高比最好和摄像比例一致，否则图片可能被压缩或拉伸
    NSDictionary* dic = [NSDictionary dictionaryWithObjectsAndKeys:AVVideoCodecH264, AVVideoCodecKey,
                         [NSNumber numberWithFloat:640.0f], AVVideoWidthKey,
                         [NSNumber numberWithFloat:480.0f], AVVideoHeightKey,
                         videoCompressionProps, AVVideoCompressionPropertiesKey, nil];
	self.videoAssetWriterInput = [AVAssetWriterInput assetWriterInputWithMediaType:AVMediaTypeVideo outputSettings:dic];
	[self.videoAssetWriterInput setExpectsMediaDataInRealTime:YES];
	if ([self.assetWriter canAddInput:self.videoAssetWriterInput])
		[self.assetWriter addInput:self.videoAssetWriterInput];
	
    // specify the prefered transform for the output file
	CGFloat rotationDegrees;
	switch ([[UIDevice currentDevice] orientation]) {
		case UIDeviceOrientationPortraitUpsideDown:
			rotationDegrees = -90.;
			break;
		case UIDeviceOrientationLandscapeLeft: // no rotation
			rotationDegrees = 0.;
			break;
		case UIDeviceOrientationLandscapeRight:
			rotationDegrees = 180.;
			break;
		case UIDeviceOrientationPortrait:
		case UIDeviceOrientationUnknown:
		case UIDeviceOrientationFaceUp:
		case UIDeviceOrientationFaceDown:
		default:
			rotationDegrees = 90.;
			break;
	}
    AVCaptureDevicePosition position = self.videoInput.device.position;
    if (position == AVCaptureDevicePositionFront) {
        rotationDegrees = -90;
    }
	CGFloat rotationRadians = DegreesToRadians(rotationDegrees);
	[self.videoAssetWriterInput setTransform:CGAffineTransformMakeRotation(rotationRadians)];
	
    
    //add the audio input
    AudioChannelLayout acl;
    bzero(&acl, sizeof(acl));
    acl.mChannelLayoutTag = kAudioChannelLayoutTag_Mono;
    NSDictionary* audioOutputSettings = nil;
    audioOutputSettings = [ NSDictionary dictionaryWithObjectsAndKeys:
                           
                           [ NSNumber numberWithInt: kAudioFormatMPEG4AAC ], AVFormatIDKey,
                           
                           [ NSNumber numberWithInt:64000], AVEncoderBitRateKey,
                           
                           [ NSNumber numberWithFloat: 44100.0 ], AVSampleRateKey,
                           
                           [ NSNumber numberWithInt: 1 ], AVNumberOfChannelsKey,
                           
                           [ NSData dataWithBytes: &acl length: sizeof( acl ) ], AVChannelLayoutKey,
                           
                           nil ];
    self.audioAssetWriterInput = [AVAssetWriterInput assetWriterInputWithMediaType:AVMediaTypeAudio outputSettings:audioOutputSettings];
    self.audioAssetWriterInput.expectsMediaDataInRealTime = YES;
#warning 在这里决定在录制视频的同时进行音频的录制
    //控制是否录制音频
    if ([self.recodeAudioSwitch isOn]) {
        [self.assetWriter addInput:self.audioAssetWriterInput];
    }
    
    
    
    // initiates a sample-writing at time 0
	self.nextFPTS = kCMTimeZero;
	[self.assetWriter startWriting];
	[self.assetWriter startSessionAtSourceTime:self.nextFPTS];
	
    return YES;

}
//AVCaptureVideoDataOutputSampleBufferDelegate,AVCaptureAudioDataOutputSampleBufferDelegate这两个代理共同使用的方法
/**
 *  这个代理方法在每次获得一个新的帧的时候都会调用
 */
-(void)captureOutput:(AVCaptureOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection
{
    if (self.started) {
        // set up the AVAssetWriter using the format description from the first sample buffer captured
        if ( self.assetWriter == nil ) {
            //NSLog(@"Writing movie to \"%@\"", outputURL);
            CMFormatDescriptionRef formatDescription = CMSampleBufferGetFormatDescription(sampleBuffer);
            if ( NO == [self setupAssetWriterForURL:self.outputMovURL formatDescription:formatDescription] ) {
                NSLog(@"setupAssetWriterForURL error");
                return;
            }
        }
        // re-time the sample buffer - in this sample frameDuration is set to 5 fps
        CMSampleTimingInfo timingInfo = kCMTimingInfoInvalid;
        timingInfo.duration = self.frameDuration;
        timingInfo.presentationTimeStamp = self.nextFPTS;
        CMSampleBufferRef sbufWithNewTiming = NULL;
        
        
        OSStatus err = CMSampleBufferCreateCopyWithNewTiming(kCFAllocatorDefault,
                                                             sampleBuffer,
                                                             1, // numSampleTimingEntries
                                                             &timingInfo,
                                                             &sbufWithNewTiming);
        if (err) {
            NSLog(@"CMSampleBufferCreateCopyWithNewTiming error");
            return;
        }
        
        if (captureOutput == self.videoOutput ) {
            // append the sample buffer if we can and increment presnetation time
            if ( [self.videoAssetWriterInput isReadyForMoreMediaData] ) {
                if ([self.videoAssetWriterInput appendSampleBuffer:sbufWithNewTiming]) {
                    self.nextFPTS = CMTimeAdd(self.frameDuration, self.nextFPTS);
                }
                else {
                    NSError *error = [self.assetWriter error];
                    NSLog(@"failed to append sbuf: %@", error);
                }
            }
            else {
                NSLog(@"isReadyForMoreMediaData error");
            }
            
            // release the copy of the sample buffer we made
            CFRelease(sbufWithNewTiming);
            
            self.currentFrame++;//当获取到新的frame的时候self.currentFrame自动加1
            //新建一个线程进行进度条的更新
            dispatch_async(dispatch_get_main_queue(), ^{
                CGFloat p = (CGFloat)((CGFloat)self.currentFrame / (CGFloat)self.maxFrame);
                [self.progrossBar setProgress:p animated:YES];
                
            });
            
            if (self.currentFrame >= self.maxFrame) {
                [self performSelectorOnMainThread:@selector(stopedForce) withObject:nil waitUntilDone:YES];
                
            }
            
        }
        else if (captureOutput == self.audioOutput) {
            if (self.assetWriter.status > AVAssetWriterStatusWriting) {
                NSLog(@"Waring:write status is %d",self.assetWriter.status);
                if (self.assetWriter.status == AVAssetWriterStatusFailed)
                    NSLog(@"Error:%@",self.assetWriter.error);
                return;
                
            }
            if ([self.audioAssetWriterInput isReadyForMoreMediaData]) {
                if ([self.audioAssetWriterInput appendSampleBuffer:sbufWithNewTiming])
                    return;
            }
        }
        
    }

}
/**
 *  得到图片
 *
 *  @param sampleBuffer <#sampleBuffer description#>
 *
 *  @return <#return value description#>
 */
- (UIImage *) imageFromSampleBuffer:(CMSampleBufferRef) sampleBuffer
{
    CVImageBufferRef imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);

    CVPixelBufferLockBaseAddress(imageBuffer,0);
    
  
    size_t bytesPerRow = CVPixelBufferGetBytesPerRow(imageBuffer);
    
    size_t width = CVPixelBufferGetWidth(imageBuffer);
    size_t height = CVPixelBufferGetHeight(imageBuffer);
    
  
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    if (!colorSpace)
    {
        NSLog(@"CGColorSpaceCreateDeviceRGB failure");
        return nil;
    }
    
   
    void *baseAddress = CVPixelBufferGetBaseAddress(imageBuffer);
    
    size_t bufferSize = CVPixelBufferGetDataSize(imageBuffer);
    
   
    CGDataProviderRef provider = CGDataProviderCreateWithData(NULL, baseAddress, bufferSize,
                                                              NULL);
    
    CGImageRef cgImage =
    CGImageCreate(width,
                  height,
                  8,
                  32,
                  bytesPerRow,
                  colorSpace,
                  kCGImageAlphaNoneSkipFirst | kCGBitmapByteOrder32Little,
                  provider,
                  NULL,
                  true,
                  kCGRenderingIntentDefault);
    CGDataProviderRelease(provider);
    CGColorSpaceRelease(colorSpace);
    
    
    UIImage *image = [UIImage imageWithCGImage:cgImage];
    CGImageRelease(cgImage);
    
    CVPixelBufferUnlockBaseAddress(imageBuffer, 0);
    
    return image;
}
/**
 *  录制视频达到了240帧自动停止，并且保存到相册，编辑的文字没有保存到相册，只是作为一个属性传递
 */
- (void)stopedForce
{
    [self stop:nil];
    [self showAlert:@"stoped force"];
    self.playBtn.enabled = YES;
    self.playmp4Btn.enabled = YES;
    
    self.cameraToggleBtn.enabled = YES;
    
    //录制完成保存到相册
    ALAssetsLibrary* library = [[ALAssetsLibrary alloc]init];
    if ([library videoAtPathIsCompatibleWithSavedPhotosAlbum:self.outputMovURL]) {
        [library writeVideoAtPathToSavedPhotosAlbum:self.outputMovURL completionBlock:^(NSURL *assetURL, NSError *error) {
            
        }];
    }
}
@end
