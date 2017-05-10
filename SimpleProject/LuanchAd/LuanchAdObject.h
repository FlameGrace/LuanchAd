//
//  LuanchAdObject.h
//  LuanchAd
//
//  Created by 李嘉军 on 2017/5/10.
//  Copyright © 2017年 lli. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface LuanchAdObject : NSObject

@property (strong, nonatomic) UIImage *image;

@property (strong, nonatomic) NSString *adUrl;

+ (instancetype)object;

@end
