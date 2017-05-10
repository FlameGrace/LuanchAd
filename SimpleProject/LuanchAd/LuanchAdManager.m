//
//  LuanchAdManager.m
//  LuanchAd
//
//  Created by 李嘉军 on 2017/5/10.
//  Copyright © 2017年 lli. All rights reserved.
//

#import "LuanchAdManager.h"
#import "LuanchAdView.h"

@interface LuanchAdManager()

@property (assign, nonatomic) NSInteger seconds;
@property (strong, nonatomic) NSTimer *timer;
@property (copy, nonatomic) LuanchAdBeClicked clickBlock;
@property (strong, nonatomic) LuanchAdObject *currentAd;
@property (strong, nonatomic) LuanchAdView *adView;

@end

@implementation LuanchAdManager

static LuanchAdManager *sharedManager = nil;


+ (instancetype)shareManager
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedManager = [[self alloc]init];
    });
    return sharedManager;
}

- (instancetype)init
{
    if(self = [super init])
    {
        self.currentAd = [LuanchAdObject object];
        self.currentAd.image = [UIImage imageWithContentsOfFile:LuanchAdImageLocalPath];
        self.currentAd.adUrl = [[NSUserDefaults standardUserDefaults]objectForKey:LuanchAdUserDefaultsKey];;
        [self performSelectorInBackground:@selector(updateAd) withObject:nil];
        
    }
    return self;
}

/**
 @return can we show AD View
 */
- (BOOL)canShowAdView
{
    if(self.currentAd.image&&self.currentAd.adUrl)
    {
        return YES;
    }
    return NO;
}


- (void)showAdViewInDuration:(NSInteger)seconds adViewBeClicked:(LuanchAdBeClicked)clickBlock
{
    if(![self canShowAdView])
    {
        return;
    }
    self.seconds = seconds;
    self.clickBlock = clickBlock;
    [self dismiss];
    [self updateTitle];
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
    [[UIApplication sharedApplication].keyWindow addSubview:self.adView];
    [self startTimer];
    
}

- (void)dismiss
{
    [self stopTimer];
    [self.adView removeFromSuperview];
    self.adView = nil;
}

- (void)dealloc
{
    [self stopTimer];
}

- (void)startTimer
{
    [self stopTimer];
    self.timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(handleTimer) userInfo:nil repeats:YES];
    [self.timer fire];
}

- (void)stopTimer
{
    [self.timer invalidate];
    self.timer = nil;
}

- (void)handleTimer
{
    self.seconds --;
    if(self.seconds <= 0)
    {
        [self stopTimer];
        [self dismiss];
        return;
    }
    [self updateTitle];
}

- (void)updateTitle
{
    NSAttributedString *title = [[NSAttributedString alloc]initWithString:[NSString stringWithFormat:@"%lds 跳过",self.seconds] attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:16],NSForegroundColorAttributeName:[UIColor whiteColor]}];
    [self.adView.nextButton setAttributedTitle:title forState:UIControlStateNormal];
}


- (void)openAdUrl
{
    if(self.clickBlock)
    {
        self.clickBlock(self.currentAd);
    }
    [self performSelector:@selector(dismiss) withObject:nil afterDelay:1];
}

//update the ad image and ad url
- (void)updateAd
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSURL *url = [NSURL URLWithString:LuanchAdHttpRequestUrl];
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
        [request setHTTPMethod:@"POST"];
        NSError *error;
        NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:&error];
        if(error)
        {
            NSLog(@"request error：%@",error);
            return ;
        }
        NSLog(@"data：%@",[[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding]);
        NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&error];
        if(error)
        {
            NSLog(@"数据json解析出错：%@",error);
            return ;
        }
        NSString *imageUrl = dic[@"img"];
        NSString *adUrl = dic[@"ad"];
        if(adUrl&&imageUrl&&adUrl.length>0&&imageUrl.length>0)
        {
            NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:imageUrl]];
            if(data && [data writeToFile:LuanchAdImageLocalPath atomically:YES])
            {
                [[NSUserDefaults standardUserDefaults]setObject:adUrl forKey:LuanchAdUserDefaultsKey];
            }
        }
    });
}

- (LuanchAdView *)adView
{
    if(!_adView)
    {
        CGRect frame = [UIScreen mainScreen].bounds;
        _adView = [[LuanchAdView alloc]initWithFrame:frame];
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(openAdUrl)];
        [_adView addGestureRecognizer:tap];
        _adView.imageView.image = self.currentAd.image;
        [_adView.nextButton addTarget:self action:@selector(dismiss) forControlEvents:UIControlEventTouchUpInside];
    }
    return _adView;
}

@end
