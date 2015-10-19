//
//  MJPhotoBrowser.m
//
//  Created by mj on 13-3-4.
//  Copyright (c) 2013年 itcast. All rights reserved.

#import <QuartzCore/QuartzCore.h>
#import "MJPhotoBrowser.h"
#import "MJPhoto.h"
#import "SDWebImageManager+MJ.h"
#import "MJPhotoView.h"
#import "MJPhotoToolbar.h"
//#import "RTLabel.h"
#import "UICommon.h"

#define kPadding 10
#define kPhotoViewTagOffset 1000
#define kPhotoViewIndex(photoView) ([photoView tag] - kPhotoViewTagOffset)

@interface MJPhotoBrowser () <MJPhotoViewDelegate>
{
    // 滚动的view
	UIScrollView *_photoScrollView;
    // 所有的图片view
	NSMutableSet *_visiblePhotoViews;
    NSMutableSet *_reusablePhotoViews;
    // 工具条
    MJPhotoToolbar *_toolbar;
    
    // 一开始的状态栏
    BOOL _statusBarHiddenInited;
    
    UIButton * _oriBtn;
}
@end

@implementation MJPhotoBrowser

#pragma mark - Lifecycle
- (void)loadView
{
    _statusBarHiddenInited = [UIApplication sharedApplication].isStatusBarHidden;
    // 隐藏状态栏
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationFade];
    self.view = [[UIView alloc] init];
    self.view.frame = [UIScreen mainScreen].bounds;
	self.view.backgroundColor = [UIColor blackColor];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // 1.创建UIScrollView
    [self createScrollView];
    
    // 2.创建工具条
    [self createToolbar];
    
    //3.查看原图
    [self createSeeOriginImage];
    
    //3.加水印
//    if(_isShowLogo)
//    {
//        [self createLogoBar];
//    }
}

- (void) createSeeOriginImage
{
    if(!_oriBtn)
    {
        _oriBtn = [[UIButton alloc] init];
        CGFloat screenW = [UIScreen mainScreen].bounds.size.width;
        CGFloat screenH = [UIScreen mainScreen].bounds.size.height;
        _oriBtn.frame = CGRectMake((screenW - 111)/2, (screenH - 26 - 14), 111, 26);
        [_oriBtn setTitle:@"查看原图" forState:UIControlStateNormal];
        [_oriBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_oriBtn setTitleColor:RGBACOLOR(255, 255, 255, 0.7) forState:UIControlStateHighlighted];
        [_oriBtn setBackgroundImage:[UIImage imageNamed:@"btn_chakan"] forState:UIControlStateNormal];
        [_oriBtn setBackgroundImage:[UIImage imageNamed:@"btn_chakan_2"] forState:UIControlStateHighlighted];
        _oriBtn.titleLabel.font = [UIFont systemFontOfSize:12];
        
        [self.view addSubview:_oriBtn];
        
        [_oriBtn addTarget:self action:@selector(jumpToOriginImage:) forControlEvents:UIControlEventTouchUpInside];
        
        _oriBtn.hidden = YES;
    }
}

- (void)jumpToOriginImage:(id)sender
{
    NSLog(@"下载原图");
    
    NSInteger index = _oriBtn.tag;
    
    MJPhoto *photo = _photos[index];//_photos[index]
    
    for (MJPhotoView *photoView in _visiblePhotoViews) {
        if (kPhotoViewIndex(photoView) == index) {
            [_visiblePhotoViews removeObject:photoView];
        }
    }

    MJPhotoView *photoView = [self dequeueReusablePhotoView];
    if (!photoView) { // 添加新的图片view
        photoView = [[MJPhotoView alloc] init];
        photoView.photoViewDelegate = self;
    }
    // 调整当期页的frame
    CGRect bounds = _photoScrollView.bounds;
    CGRect photoViewFrame = bounds;
    photoViewFrame.size.width -= (2 * kPadding);
    photoViewFrame.origin.x = (bounds.size.width * index) + kPadding;
    photoView.tag = kPhotoViewTagOffset + index;
    
    photoView.frame = photoViewFrame;
    photo.showedOriginImage = YES;
    photo.firstShow = YES;
    photoView.photo = photo;
        
    [_visiblePhotoViews addObject:photoView];
    
    NSInteger tag = kPhotoViewTagOffset + index;
    
    [[_photoScrollView viewWithTag:tag] removeFromSuperview];
    
    [_photoScrollView addSubview:photoView];
    
    NSString * str = [NSString stringWithFormat:@"查看原图 (%@)", photo.originSize];
    [_oriBtn setTitle:str forState:UIControlStateNormal];
    _oriBtn.hidden = photo.originUrl ? NO : YES;//momo

}


- (void)show
{
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    [window addSubview:self.view];
    [window.rootViewController addChildViewController:self];

    if (_currentPhotoIndex == 0) {
        [self showPhotos];
    }
}

#pragma mark - 私有方法
#pragma mark 创建工具条
- (void)createToolbar
{
    CGFloat barHeight = 44;
//    CGFloat barY = self.view.frame.size.height - barHeight;
    CGFloat barY = 40;
    _toolbar = [[MJPhotoToolbar alloc] init];
    _toolbar.dataArray = _dataArray;
    _toolbar.frame = CGRectMake(0, barY, self.view.frame.size.width, barHeight);
    _toolbar.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    _toolbar.photos = _photos;
    [self.view addSubview:_toolbar];
    
    [self updateTollbarState];
}

#pragma mark 创建UIScrollView
- (void)createScrollView
{
    CGRect frame = self.view.bounds;
    frame.origin.x -= kPadding;
    frame.size.width += (2 * kPadding);
	_photoScrollView = [[UIScrollView alloc] initWithFrame:frame];
	_photoScrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	_photoScrollView.pagingEnabled = YES;
	_photoScrollView.delegate = self;
	_photoScrollView.showsHorizontalScrollIndicator = NO;
	_photoScrollView.showsVerticalScrollIndicator = NO;
	_photoScrollView.backgroundColor = [UIColor clearColor];
    _photoScrollView.contentSize = CGSizeMake(frame.size.width * _photos.count, 0);
	[self.view addSubview:_photoScrollView];
    _photoScrollView.contentOffset = CGPointMake(_currentPhotoIndex * frame.size.width, 0);
}

- (void)setPhotos:(NSArray *)photos
{
    _photos = photos;
    
    if (photos.count > 1) {
        _visiblePhotoViews = [NSMutableSet set];
        _reusablePhotoViews = [NSMutableSet set];
    }
    
    for (int i = 0; i<_photos.count; i++) {
        MJPhoto *photo = _photos[i];
        photo.index = i;
        photo.firstShow = i == _currentPhotoIndex;
    }
}

//- (void)handleDoubleTap:(UIGestureRecognizer *)gesture
//{
//
//    [NSObject cancelPreviousPerformRequestsWithTarget:self];
//    [NSObject cancelPreviousPerformRequestsWithTarget:_photoScrollView.superview.nextResponder];
//    float newScale = (_photoScrollView.zoomScale <=_photoScrollView.minimumZoomScale?3.0:_photoScrollView.minimumZoomScale);
//    CGRect zoomRect = [self zoomRectForScale:newScale withCenter:[gesture locationInView:gesture.view]];
//    [_photoScrollView zoomToRect:zoomRect animated:YES];
//}
//
//- (CGRect)zoomRectForScale:(float)scale withCenter:(CGPoint)center
//{
//    CGRect zoomRect;
//    zoomRect.size.height = _photoScrollView.frame.size.height / scale;
//    zoomRect.size.width  = _photoScrollView.frame.size.width  / scale;
//    zoomRect.origin.x = center.x - (zoomRect.size.width  / 2.0);
//    zoomRect.origin.y = center.y - (zoomRect.size.height / 2.0);
//    return zoomRect;
//}


#pragma mark 设置选中的图片
- (void)setCurrentPhotoIndex:(NSUInteger)currentPhotoIndex
{
    _currentPhotoIndex = currentPhotoIndex;
    
    for (int i = 0; i<_photos.count; i++) {
        MJPhoto *photo = _photos[i];
        photo.firstShow = i == currentPhotoIndex;
    }
    
    if ([self isViewLoaded]) {
        _photoScrollView.contentOffset = CGPointMake(_currentPhotoIndex * _photoScrollView.frame.size.width, 0);
        
        // 显示所有的相片
        [self showPhotos];
    }
}

#pragma mark - MJPhotoView代理
- (void)photoViewSingleTap:(MJPhotoView *)photoView
{
    [UIApplication sharedApplication].statusBarHidden = _statusBarHiddenInited;
    self.view.backgroundColor = [UIColor clearColor];
    
    // 移除工具条
    [_toolbar removeFromSuperview];
}

- (void)photoViewDidEndZoom:(MJPhotoView *)photoView
{
    [self.view removeFromSuperview];
    [self removeFromParentViewController];
    
    if (_delegate && [_delegate respondsToSelector:@selector(photoBrowser:didClickToPageAtIndex:)]) {
        [_delegate photoBrowser:self didClickToPageAtIndex:_currentPhotoIndex];
    }
    
}

- (void)photoViewImageFinishLoad:(MJPhotoView *)photoView
{
    
    
    _toolbar.currentPhotoIndex = _currentPhotoIndex;
}

#pragma mark 显示照片
- (void)showPhotos
{
    // 只有一张图片
    if (_photos.count == 1) {
        [self showPhotoViewAtIndex:0];
        return;
    }
    
    CGRect visibleBounds = _photoScrollView.bounds;
	int firstIndex = (int)floorf((CGRectGetMinX(visibleBounds)+kPadding*2) / CGRectGetWidth(visibleBounds));
	int lastIndex  = (int)floorf((CGRectGetMaxX(visibleBounds)-kPadding*2-1) / CGRectGetWidth(visibleBounds));
    if (firstIndex < 0) firstIndex = 0;
    if (firstIndex >= _photos.count) firstIndex = _photos.count - 1;
    if (lastIndex < 0) lastIndex = 0;
    if (lastIndex >= _photos.count) lastIndex = _photos.count - 1;
	
	// 回收不再显示的ImageView
    NSInteger photoViewIndex;
	for (MJPhotoView *photoView in _visiblePhotoViews) {
        
//        UITapGestureRecognizer *doubleTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self
//                                                                                           action:@selector(handleDoubleTap:)];
//        [doubleTapGesture setNumberOfTapsRequired:2];
//        [photoView addGestureRecognizer:doubleTapGesture];
        
        photoViewIndex = kPhotoViewIndex(photoView);
		if (photoViewIndex < firstIndex || photoViewIndex > lastIndex) {
			[_reusablePhotoViews addObject:photoView];
			[photoView removeFromSuperview];
		}
	}
    
	[_visiblePhotoViews minusSet:_reusablePhotoViews];
    while (_reusablePhotoViews.count > 2) {
        [_reusablePhotoViews removeObject:[_reusablePhotoViews anyObject]];
    }
	
	for (NSUInteger index = firstIndex; index <= lastIndex; index++) {
		if (![self isShowingPhotoViewAtIndex:index]) {
			[self showPhotoViewAtIndex:index];
		}
	}
}

#pragma mark 显示一个图片view
- (void)showPhotoViewAtIndex:(int)index
{
    MJPhotoView *photoView = [self dequeueReusablePhotoView];
    if (!photoView) { // 添加新的图片view
        photoView = [[MJPhotoView alloc] init];
        photoView.photoViewDelegate = self;
    }
    
    // 调整当期页的frame
    CGRect bounds = _photoScrollView.bounds;
    CGRect photoViewFrame = bounds;
    photoViewFrame.size.width -= (2 * kPadding);
    photoViewFrame.origin.x = (bounds.size.width * index) + kPadding;
    photoView.tag = kPhotoViewTagOffset + index;
    
    MJPhoto *photo = _photos[index];
    photoView.frame = photoViewFrame;
    photoView.photo = photo;

    [_visiblePhotoViews addObject:photoView];
    [_photoScrollView addSubview:photoView];
    
    [self createSeeOriginImage];
    NSString * str = [NSString stringWithFormat:@"查看原图 (%@)", photo.originSize];
    [_oriBtn setTitle:str forState:UIControlStateNormal];
    _oriBtn.hidden = photo.originUrl ? NO : YES;//momo
    _oriBtn.tag = index;
    
    [self loadImageNearIndex:index];
}

#pragma mark 加载index附近的图片
- (void)loadImageNearIndex:(int)index
{
    if (index > 0) {
        MJPhoto *photo = _photos[index - 1];
        
        [SDWebImageManager downloadWithURL:photo.url];
    }
    
    if (index < _photos.count - 1) {
        MJPhoto *photo = _photos[index + 1];
        [SDWebImageManager downloadWithURL:photo.url];
    }
}

#pragma mark index这页是否正在显示
- (BOOL)isShowingPhotoViewAtIndex:(NSUInteger)index {
	for (MJPhotoView *photoView in _visiblePhotoViews) {
		if (kPhotoViewIndex(photoView) == index) {
           return YES;
        }
    }
	return  NO;
}

#pragma mark 循环利用某个view
- (MJPhotoView *)dequeueReusablePhotoView
{
    MJPhotoView *photoView = [_reusablePhotoViews anyObject];
	if (photoView) {
		[_reusablePhotoViews removeObject:photoView];
	}
	return photoView;
}

#pragma mark 更新toolbar状态
- (void)updateTollbarState
{
    _currentPhotoIndex = _photoScrollView.contentOffset.x / _photoScrollView.frame.size.width;
    _toolbar.currentPhotoIndex = _currentPhotoIndex;
}

#pragma mark - UIScrollView Delegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
	[self showPhotos];
    [self updateTollbarState];
}
@end