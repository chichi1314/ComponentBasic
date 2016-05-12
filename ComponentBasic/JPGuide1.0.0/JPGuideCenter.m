//
//  JPGuideCenter.m
//  ComponentBasic
//
//  Created by chichi on 16/3/29.
//  Copyright © 2016年 chichi. All rights reserved.
//
#import "JPGuideCenter.h"

#define kScreenBounds [UIScreen mainScreen].bounds

static NSString *identifier = @"cell";

//单张页面
@interface JPGuideCell : UICollectionViewCell

/**
 *   imageView,表示展示的cell
 */
@property (nonatomic, strong) UIImageView *imageView;

/**
 *   button,表示展示的按钮
 */
@property (nonatomic, strong) UIButton    *button;

@end

@implementation JPGuideCell

- (instancetype)init
{
    if (self = [super init]) {
        [self setup];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self setup];
    }
    return self;
}

- (void)setup
{
    self.layer.masksToBounds = YES;
    [self.contentView addSubview:self.imageView];
    [self.contentView addSubview:self.button];
}

- (UIImageView *)imageView
{
    if (!_imageView) {
        _imageView = [UIImageView new];
        [_imageView setFrame:kScreenBounds];
        [_imageView setCenter:CGPointMake(kScreenBounds.size.width/2, kScreenBounds.size.height/2)];
    }
    return _imageView;
}

- (UIButton *)button
{
    if (!_button) {
        _button = [UIButton buttonWithType:UIButtonTypeCustom];
        [_button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [_button.layer setCornerRadius:5.f];
        [_button setBackgroundColor:[UIColor clearColor]];
        [_button setFrame:CGRectMake(20, 0, kScreenBounds.size.width - 40, 60)];
        [_button setCenter:CGPointMake(kScreenBounds.size.width/2, kScreenBounds.size.height*0.8)];
    }
    return _button;
}

@end



//引导页对象
@interface JPGuideCenter ()<UICollectionViewDataSource, UICollectionViewDelegate>

/**
 *   images,表示展示的图片数组
 */
@property (nonatomic, strong) NSArray           *images;

/**
 *   window,表示展示的父视图
 */
@property (nonatomic, strong) UIWindow          *window;

/**
 *   collectionView,表示展示的列表容器
 */
@property (nonatomic, strong) UICollectionView  *collectionView;

/**
 *   pageControl,表示展示的分页控件
 */
@property (nonatomic, strong) UIPageControl     *pageControl;

/**
 *   guideComplete,结束回调
 */
@property (nonatomic, strong) JPGuideCenterComplete guideComplete;

@end


@implementation JPGuideCenter

static id staticGuideCenter = nil;

#pragma mark - === life cycle 生命周期 ===
+ (instancetype)defaultCenter
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        staticGuideCenter = [JPGuideCenter new];
    });
    return staticGuideCenter;
}

- (void)dealloc
{
    NSLog(@"Component Logger: JPGuideCenter is killed");
}


#pragma mark - === delegate 视图委托 ===
//UIScrollViewDelegate
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    
    self.pageControl.currentPage = (scrollView.contentOffset.x / kScreenBounds.size.width);
}

//UICollectionViewDataSource
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return self.images.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    JPGuideCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
    
    NSString *path = [self.images objectAtIndex:indexPath.row];
    UIImage  *img  = [UIImage imageNamed:path];
    CGSize    size = [self adapterSizeImageSize:img.size compareSize:kScreenBounds.size];
    
    cell.imageView.frame = CGRectMake(0, 0, size.width, size.height);
    cell.imageView.image = img;
    cell.imageView.center= CGPointMake(kScreenBounds.size.width/2, kScreenBounds.size.height/2);
    if (indexPath.row == self.images.count - 1) {
        [cell.button setHidden:NO];
        [cell.button addTarget:self action:@selector(eventNextHandler:) forControlEvents:UIControlEventTouchUpInside];
    }else{
        [cell.button setHidden:YES];
    }
    
    return cell;
}

#pragma mark - === event response 事件相应 ===
- (void)eventNextHandler:(id)sender
{
    [UIView animateWithDuration:1.0 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        self.collectionView.alpha = 0.0;
        self.pageControl.alpha = 0.0;
        [self.collectionView setTransform:CGAffineTransformMakeScale(1.3, 1.3)];
    } completion:^(BOOL finished) {
        if (self.guideComplete) {
            self.guideComplete();
        }
        [self.pageControl removeFromSuperview];
        [self.collectionView removeFromSuperview];
        
        //释放对象
        staticGuideCenter = nil;
        [self setWindow:nil];
        [self setCollectionView:nil];
        [self setPageControl:nil];
        [self setImages:nil];
        [self setGuideComplete:nil];
    }];
}

#pragma mark - === public  methods 公有方法 ===
- (void)showInWindow:(UIWindow*)window images:(NSArray *)images complete:(void(^)(void))complete
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString        *version     = [[NSBundle mainBundle].infoDictionary objectForKey:@"CFBundleShortVersionString"];
    
    NSString *guideVersion       = [NSString stringWithFormat:@"Guide_%@", version];
    BOOL      isShowGuideView    = NO;//[userDefaults boolForKey:guideVersion];
    
    if (!isShowGuideView && !self.window) {
        [self setGuideComplete:complete];
        [self setImages:images];
        [self.pageControl setNumberOfPages:images.count];
        [self setWindow:window];
        
        [self.window addSubview:self.collectionView];
        [self.window addSubview:self.pageControl];
        
        [userDefaults setBool:YES forKey:guideVersion];
        [userDefaults synchronize];
    }else{
        staticGuideCenter = nil;
    }
}

#pragma mark - === private methods 私有方法 ===
- (CGSize)adapterSizeImageSize:(CGSize)origin compareSize:(CGSize)targetSize
{
    CGFloat w = targetSize.width;
    CGFloat h = targetSize.width / origin.width * origin.height;
    
    if (h < targetSize.height) {
        w = targetSize.height / h * w;
        h = targetSize.height;
    }
    
    return CGSizeMake(w, h);
}

#pragma mark - === request 请求 ===

#pragma mark - === setters 属性 ===

#pragma mark - === getters 属性 ===
- (UICollectionView *)collectionView
{
    if (!_collectionView) {
        
        CGRect screen = [UIScreen mainScreen].bounds;
        UICollectionViewFlowLayout *layout = [UICollectionViewFlowLayout new];
        [layout setMinimumInteritemSpacing:0];
        [layout setMinimumLineSpacing:0];
        [layout setItemSize:screen.size];
        [layout setScrollDirection:UICollectionViewScrollDirectionHorizontal];
        
        _collectionView = [[UICollectionView alloc] initWithFrame:screen collectionViewLayout:layout];
        [_collectionView setBounces:NO];
        [_collectionView setBackgroundColor:[UIColor whiteColor]];
        [_collectionView setShowsHorizontalScrollIndicator:NO];
        [_collectionView setShowsVerticalScrollIndicator:NO];
        [_collectionView setPagingEnabled:YES];
        [_collectionView setDataSource:self];
        [_collectionView setDelegate:self];
        [_collectionView registerClass:[JPGuideCell class] forCellWithReuseIdentifier:identifier];
    }
    return _collectionView;
}

- (UIPageControl *)pageControl
{
    if (!_pageControl) {
        _pageControl = [UIPageControl new];
        [_pageControl setFrame:CGRectMake(0, 0, kScreenBounds.size.width, 44.f)];
        [_pageControl setCenter:CGPointMake(kScreenBounds.size.width/2, kScreenBounds.size.height*0.95)];
        [_pageControl setPageIndicatorTintColor:[UIColor lightGrayColor]];
        [_pageControl setCurrentPageIndicatorTintColor:[UIColor orangeColor]];
    }
    return _pageControl;
}

@end
