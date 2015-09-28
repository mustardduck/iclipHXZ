//
//  PreviewViewController.m
//  miaozhuan
//
//  Created by 孙向前 on 14-11-6.
//  Copyright (c) 2014年 zdit. All rights reserved.
//

#import "PreviewViewController.h"
//#import "NetImageView.h"
#import "MJPhotoBrowser.h"
#import "MJPhoto.h"

@interface PreviewViewController ()<MJPhotoBrowserDelegate>

@end

@implementation PreviewViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    
    if (_dataArray.count == 1) {
        _pageControl.hidden = YES;
    } else {
        _pageControl.numberOfPages = _dataArray.count;
        _pageControl.currentPage = _currentPage;
//        [_pageControl setImagePageStateNormal:[UIImage imageNamed:@"001.png"]];
//        [_pageControl setImagePageStateHighlighted:[UIImage imageNamed:@"002.png"]];
    }
    
#warning Fix-150205-真是。。。。无语。
    [self performSelector:@selector(haha) withObject:nil afterDelay:0.5];
    
}

- (void)haha{
    
    NSMutableArray *photos = [[NSMutableArray alloc] initWithCapacity:_dataArray.count];
    for (int i = 0; i<_dataArray.count; i++) {
        // 替换为中等尺寸图片
        MJPhoto *photo = [[MJPhoto alloc] init];
        NSString *pictureUrlStr = [_dataArray[i] valueForKey:@"PictureUrl"];
        if (!pictureUrlStr.length || [pictureUrlStr isKindOfClass:[NSNull class]]) {
//            photo.image = [UICommon getIos4OffsetY] ? [UIImage imageNamed:@"iphone5.png"] :[UIImage imageNamed:@"iphone4.png"];
//            UIImageView *imgview = [UICommon getIos4OffsetY] ? [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"iphone5.png"]] : [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"iphone4.png"]];
//            photo.srcImageView = imgview;
        } else {
            photo.url = [NSURL URLWithString:pictureUrlStr]; // 图片路径
        }
        [photos addObject:photo];
    }
    
    // 2.显示相册
    MJPhotoBrowser *browser = [[MJPhotoBrowser alloc] init];
    browser.delegate = self;
    browser.dataArray = _dataArray;
    browser.currentPhotoIndex = _currentPage; // 弹出相册时显示的第一张图片是？
    browser.photos = photos; // 设置所有的图片
    browser.isShowLogo = _isShowLogo;
    [browser show];
}

// 切换到某一页图片
- (void)photoBrowser:(MJPhotoBrowser *)photoBrowser didChangedToPageAtIndex:(NSUInteger)index{
    _pageControl.currentPage = index;
}

- (void)photoBrowser:(MJPhotoBrowser *)photoBrowser didClickToPageAtIndex:(NSUInteger)index{
    [self dismissModalViewControllerAnimated:NO];
}

@end
