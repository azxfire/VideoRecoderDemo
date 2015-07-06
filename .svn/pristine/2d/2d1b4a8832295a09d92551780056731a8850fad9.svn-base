//
//  QQTextView.m
//  videoRecord
//
//  Created by Dady on 14-8-11.
//  Copyright (c) 2014年 Mike. All rights reserved.
//

#import "QQTextView.h"
@interface QQTextView()
@property (nonatomic, strong) UILabel *placeHolderLable;
@end
@implementation QQTextView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        UILabel* placeHolderLable = [[UILabel alloc]init];
        placeHolderLable.textColor = [UIColor whiteColor];
        placeHolderLable.hidden = YES;
        placeHolderLable.numberOfLines = 0;
        placeHolderLable.backgroundColor = [UIColor clearColor];
        placeHolderLable.font = self.font;
        [self insertSubview:placeHolderLable atIndex:0];
        self.placeHolderLable = placeHolderLable;
        
        //监听testView文字的改变
        [QQNotificationCenter addObserver:self selector:@selector(textDidChange) name:UITextViewTextDidChangeNotification object:self];
    }
    return self;
}
-(void)setPlaceHolder:(NSString *)placeHolder
{
    _placeHolder = [placeHolder copy];
    self.placeHolderLable.text = placeHolder;
    if (placeHolder.length) {
        self.placeHolderLable.hidden = NO;
        
        //计算frame
        CGFloat placeHolderX = 5;
        CGFloat placeHolderY = 7;
        CGFloat maxW = self.frame.size.width - 2 * placeHolderX;
        CGFloat maxH = self.frame.size.height - 2 * placeHolderY;
        CGSize placeHolderSize = [placeHolder sizeWithFont:self.placeHolderLable.font constrainedToSize:CGSizeMake(maxW, maxH)];
//        CGSize placeHolderSize = [placeHolder sizeWithAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:15]}];
        self.placeHolderLable.center = CGPointMake(self.center.x, 15);
        self.placeHolderLable.bounds = CGRectMake(0, 0, placeHolderSize.width, placeHolderSize.height);
    }else{
        self.placeHolderLable.hidden = YES;
    }
}
-(void)setPlaceHolderColor:(UIColor *)placeHolderColor
{
    _placeHolderColor = placeHolderColor;
    self.placeHolderLable.textColor = placeHolderColor;
}
-(void)setFont:(UIFont *)font
{
    [super setFont:font];
    self.placeHolderLable.font = font;
    self.placeHolder  = self.placeHolder;
}
- (void)textDidChange
{
    self.placeHolderLable.hidden = (self.text.length != 0);
}
-(void)dealloc
{
    [QQNotificationCenter removeObserver:self];
    
}
@end
