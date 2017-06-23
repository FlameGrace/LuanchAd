//
//  LuanchAdObject.h
//  LuanchAd
//
//  Created by Flame Grace on 2017/5/10.
//  Copyright © 2017年 Flame Grace. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface LuanchAdObject : NSObject

@property (strong, nonatomic) UIImage *image;

@property (strong, nonatomic) NSString *adUrl;

+ (instancetype)object;

@end
