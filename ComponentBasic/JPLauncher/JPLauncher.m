//
//  JPLauncher.m
//  ComponentBasic
//
//  Created by chichi on 16/3/29.
//  Copyright © 2016年 chichi. All rights reserved.
//

#import "JPLauncher.h"

#define kScreenBounds [UIScreen mainScreen].bounds

#define WeakSelf __weak typeof(self) weakSelf = self;

typedef NS_ENUM(NSInteger, JPLauncherProcess){
    /** 下载失败 */
    JPLauncherProcessFail = -1,
    
    /** 无 */
    JPLauncherProcessNone,
    
    /** 正在下载 */
    JPLauncherProcessLoading,
    
    /** 下载成功 */
    JPLauncherProcessSuccess
};

@interface JPLauncher ()<NSURLConnectionDataDelegate, NSURLConnectionDelegate>

@property (nonatomic, strong) UIWindow            *window;

@property (nonatomic, strong) UIView              *container;

@property (nonatomic, strong) NSMutableDictionary *detailParams;

@property (nonatomic, copy)   NSString            *imgUrl;

@property (nonatomic, strong) NSMutableData       *imgData;

@property (nonatomic, strong) NSURLConnection     *connection;

@property (nonatomic, assign) NSTimeInterval       timerInterval;

@property (nonatomic, assign) JPLauncherProcess    process;

@property (nonatomic, strong) JPLauncherComplete   launcherComplete;

@end

@implementation JPLauncher

static id staticLauncher = nil;

#pragma mark - === life cycle 生命周期 ===
+ (instancetype)defaultLanucher
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        staticLauncher = [JPLauncher new];
    });
    return staticLauncher;
}

- (void)dealloc
{
    NSLog(@"Component Logger: JPLauncher is killed");
}

#pragma mark - === delegate 视图委托 ===
//NSURLConnectionDataDelegate
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    NSHTTPURLResponse *resp = (NSHTTPURLResponse *)response;
    if (resp.statusCode !=200) {
        self.process = JPLauncherProcessFail;
        return;
    }
    self.imgData = [NSMutableData data];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [self.imgData appendData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    self.process = JPLauncherProcessSuccess;
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    self.process = JPLauncherProcessFail;
}

#pragma mark - === event response 事件相应 ===
//点击详情
- (void)eventClickDetail:(id)sender{
    [self handlerEndShowingWithType:JPLaunchercompleteTypeDetail];
}

//点击跳过
- (void)eventClickJumpover:(id)sender{
    [self handlerEndShowingWithType:JPLaunchercompleteTypeJumpOver];
}

#pragma mark - === public  methods 公有方法 ===
- (void)showInWindow:(UIWindow *)window
              imgUrl:(NSString *)urlString
        timeInterval:(NSTimeInterval)interval
        detailParams:(NSDictionary *)params
            complete:(void(^)(JPLaunchercompleteType))complete
{
    self.detailParams     = [NSMutableDictionary dictionary];
    self.timerInterval    = interval;
    self.imgUrl           = urlString;
    self.window           = window;
    self.launcherComplete = complete;
    
    if (![self validPath:urlString]) {
        return;
    }
    
    [self loadImageByPath:urlString];
    
    while (self.process != JPLauncherProcessFail && self.process != JPLauncherProcessSuccess) {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
    }
    
    [self.detailParams removeAllObjects];
    [self.detailParams addEntriesFromDictionary:params];
    if (self.process == JPLauncherProcessFail) {
        return;
    }
    [self showView];
}

#pragma mark - === private methods 私有方法 ===
//判断网址有效
- (BOOL)validPath:(NSString *)path
{
    NSURL *url = [NSURL URLWithString:path];
    return url != nil;
}

//下载图片
- (void)loadImageByPath:(NSString *)path
{
    NSURL        *url     = [NSURL URLWithString:path];
    NSURLRequest *request = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:10.];

//消除警告
#pragma clang diagnostic push
#pragma clang diagnostic ignored"-Wdeprecated-declarations"
    self.connection = [NSURLConnection connectionWithRequest:request delegate:self];
#pragma clang diagnostic pop
    
    if (self.connection) {
        [self setProcess:JPLauncherProcessLoading];
        [self.connection start];
    }
}

//展示下载的图片
- (void)showView
{
    //容器
    UIView *container = [[UIView alloc] initWithFrame:kScreenBounds];
    [container setBackgroundColor:[UIColor whiteColor]];
    [self.window addSubview:container];
    [self.window bringSubviewToFront:container];
    [self setContainer:container];
    
    //图片
    UIImageView *imgView = [[UIImageView alloc] initWithFrame:kScreenBounds];
    [imgView setImage:[UIImage imageWithData:self.imgData]];
    [imgView setContentMode:UIViewContentModeScaleAspectFill];
    [imgView setClipsToBounds:YES];
    [container addSubview:imgView];
    
    //详情按钮
    UIButton *jumpOverBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [jumpOverBtn setTitle:[NSString stringWithFormat:@"跳过%ds>>", (int)self.timerInterval] forState:UIControlStateNormal];
    [jumpOverBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [jumpOverBtn setTitleColor:[UIColor grayColor] forState:UIControlStateHighlighted];
    [jumpOverBtn.titleLabel setFont:[UIFont systemFontOfSize:13.f]];
    [jumpOverBtn setFrame:CGRectMake(kScreenBounds.size.width - 80, 30, 70, 30)];
    [jumpOverBtn.layer setBorderColor:[UIColor whiteColor].CGColor];
    [jumpOverBtn.layer setBorderWidth:1.f];
    [jumpOverBtn.layer setCornerRadius:5.f];
    [jumpOverBtn addTarget:self action:@selector(eventClickJumpover:) forControlEvents:UIControlEventTouchUpInside];
    [container addSubview:jumpOverBtn];
    
    //详情按钮
    UIButton *showDetailBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [showDetailBtn setTitle:@"查看详情>>" forState:UIControlStateNormal];
    [showDetailBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [showDetailBtn setTitleColor:[UIColor grayColor] forState:UIControlStateHighlighted];
    [showDetailBtn.titleLabel setFont:[UIFont systemFontOfSize:13.f]];
    [showDetailBtn setFrame:CGRectMake(kScreenBounds.size.width - 110, kScreenBounds.size.height - 40, 120, 30)];
    [showDetailBtn addTarget:self action:@selector(eventClickDetail:) forControlEvents:UIControlEventTouchUpInside];
    [container addSubview:showDetailBtn];
    if (self.detailParams.count == 0) {
        showDetailBtn.hidden = YES;
    }
    
    //倒计时标签
    __block int timeOut = (int)self.timerInterval;
    dispatch_queue_t  queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_source_t timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue);
    dispatch_source_set_timer(timer, dispatch_walltime(NULL, 0), 1.0 * NSEC_PER_SEC, 0);
    dispatch_source_set_event_handler(timer, ^{
        if (timeOut <= 0) {
            dispatch_source_cancel(timer);
            dispatch_async(dispatch_get_main_queue(), ^{
               [jumpOverBtn setTitle:@"跳过0s>>" forState:UIControlStateNormal];
            });
        }else{
            int       second     = timeOut % 60;
            NSString *timeString = [NSString stringWithFormat:@"%ds", second];
            dispatch_async(dispatch_get_main_queue(), ^{
                [jumpOverBtn setTitle:[NSString stringWithFormat:@"跳过%@>>", timeString] forState:UIControlStateNormal];
            });
            timeOut--;
        }
    });
    dispatch_resume(timer);
    
    //倒计时几秒消失
    __weak typeof(self) weakSelf = self;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(self.timerInterval * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
       [weakSelf handlerEndShowingWithType:JPLaunchercompleteTypeNone];
    });
}

//结束处理
- (void)handlerEndShowingWithType:(JPLaunchercompleteType)type
{
    __weak typeof(self) weakSelf = self;
    [UIView animateWithDuration:.25 animations:^{
        weakSelf.container.alpha = 0.0f;
    } completion:^(BOOL finished) {
        [weakSelf.container removeFromSuperview];
        if (weakSelf.launcherComplete) {
            weakSelf.launcherComplete(type);
        }
        
        //释放对象
        staticLauncher = nil;
        [self setWindow:nil];
        [self setDetailParams:nil];
        [self setContainer:nil];
        [self setConnection:nil];
        [self setContainer:nil];
        [self setImgUrl:nil];
        [self setLauncherComplete:nil];
    }];
}

#pragma mark - === request 请求 ===

#pragma mark - === setters 属性 ===

#pragma mark - === getters 属性 ===

@end
