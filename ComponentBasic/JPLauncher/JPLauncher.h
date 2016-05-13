//
//  JPLauncher.h
//  ComponentBasic
//
//  Created by chichi on 16/3/29.
//  Copyright © 2016年 chichi. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, JPLaunchercompleteType){
    /** 正常消失 */
    JPLaunchercompleteTypeNone = 0,
    
    /** 点击跳过 */
    JPLaunchercompleteTypeJumpOver,
    
    /** 点击详情 */
    JPLaunchercompleteTypeDetail
};

/** 广告页结束回调 */
typedef void(^JPLauncherComplete)(JPLaunchercompleteType);

@interface JPLauncher : NSObject

+ (instancetype)defaultLanucher;

- (void)showInWindow:(UIWindow *)window
              imgUrl:(NSString *)urlString
        timeInterval:(NSTimeInterval)interval
        detailParams:(NSDictionary *)params
            complete:(void(^)(JPLaunchercompleteType))complete;
@end
