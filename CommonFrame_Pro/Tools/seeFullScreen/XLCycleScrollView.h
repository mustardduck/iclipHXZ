//
//  XLCycleScrollView.h
//  CycleScrollViewDemo
//
//  Created by xie liang on 9/14/12.
//  Copyright (c) 2012 xie liang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RRPageControl.h"

@protocol XLCycleScrollViewDelegate;
@protocol XLCycleScrollViewDatasource;

@interface XLCycleScrollView : UIView<UIScrollViewDelegate>
{
    UIScrollView *_scrollView;
    RRPageControl *_pageControl;
    
    __weak id<XLCycleScrollViewDelegate> _delegate;
    __weak id<XLCycleScrollViewDatasource> _datasource;
    
    NSInteger _totalPages;
    NSInteger _curPage;
    
    NSMutableArray *_curViews;
}

@property (nonatomic,readonly) UIScrollView *scrollView;
@property (nonatomic,readonly) RRPageControl *pageControl;
@property (nonatomic,assign) BOOL enable;
@property (nonatomic,assign) NSInteger currentPage;
@property (nonatomic,weak,setter = setDataource:) id<XLCycleScrollViewDatasource> datasource;
@property (nonatomic,weak,setter = setDelegate:) id<XLCycleScrollViewDelegate> delegate;

- (void)reloadData;
- (void)setViewContent:(UIView *)view atIndex:(NSInteger)index;

@end

@protocol XLCycleScrollViewDelegate <NSObject>

@optional
- (void)didClickPage:(XLCycleScrollView *)csView atIndex:(NSInteger)index;
- (void)updatePage:(NSNumber *)page;
@end

@protocol XLCycleScrollViewDatasource <NSObject>

@required
- (NSInteger)numberOfPages:(XLCycleScrollView*)scrollView;
- (UIView *)XLScrollView:(XLCycleScrollView*)scrollView pageAtIndex:(NSInteger)index;

@end
