//
//  JPGuideCenter.h
//  ComponentBasic
//
//  Created by chichi on 16/3/29.
//  Copyright © 2016年 chichi. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^JPGuideCenterComplete)(void);

@interface JPGuideCenter : NSObject

/**
 * 引导页初始化
 */
+ (instancetype)defaultCenter;

/**
 * 设置数据源
 */
- (void)showInWindow:(UIWindow*)window
              images:(NSArray *)images
            complete:(void(^)(void))complete;

@end
