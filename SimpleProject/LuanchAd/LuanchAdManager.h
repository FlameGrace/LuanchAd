//
//  LuanchAdManager.h
//  LuanchAd
//
//  Created by Flame Grace on 2017/5/10.
//  Copyright © 2017年 Flame Grace. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "LuanchAdObject.h"


typedef void(^LuanchAdBeClicked)(LuanchAdObject *ad);


//the key in  [NSUserDefaults standardUserDefaults] for save the ad url
#define LuanchAdUserDefaultsKey (@"adUrl")
//local path fot save the picture
#define LuanchAdImageLocalPath ([NSString stringWithFormat:@"%@/Documents/ad.data",NSHomeDirectory()])

//request url
#define LuanchAdHttpRequestUrl (@"http://192.168.2.1:8000/ad/")
/* The response of request likes
 @{
     LuanchAdHttpResponse_imageUrlKey:@"http://xx.jpg",
     LuanchAdHttpResponse_adUrlKey:@"http://ad"
 }
 */
#define LuanchAdHttpResponse_imageUrlKey (@"image")
#define LuanchAdHttpResponse_adUrlKey (@"ad")

@interface LuanchAdManager : NSObject

+ (instancetype)shareManager;


/**
 show ad View
 must be called after [UIApplication sharedApplication].keyWindow not nil.
 @param seconds  show duration
 @param clickBlock callback when ad View be clicked
 */
- (void)showAdViewInDuration:(NSInteger)seconds adViewBeClicked:(LuanchAdBeClicked)clickBlock;


@end
