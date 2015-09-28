//
//  XLCycleScrollView.m
//  CycleScrollViewDemo
//
//  Created by xie liang on 9/14/12.
//  Copyright (c) 2012 xie liang. All rights reserved.
//

#import "XLCycleScrollView.h"


@implementation XLCycleScrollView{
    BOOL flag;
}
@synthesize enable=_enable;
@synthesize scrollView = _scrollView;
@synthesize pageControl = _pageControl;
@synthesize currentPage = _curPage;
@synthesize datasource = _datasource;
@synthesize delegate = _delegate;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        _enable=YES;
        _scrollView = [[UIScrollView alloc] initWithFrame:self.bounds];
        
        _scrollView.delegate = self;
        _scrollView.contentSize = CGSizeMake(self.bounds.size.width * 3, self.bounds.size.height);
        _scrollView.showsHorizontalScrollIndicator = NO;
        _scrollView.contentOffset = CGPointMake(self.bounds.size.width, 0);
        _scrollView.pagingEnabled = YES;
        [self addSubview:_scrollView];
        
        CGRect rect = self.bounds;
        rect.origin.y = rect.size.height - 30;
        rect.size.height = 30;
        
        //        _pageControl = [[RRPageControl alloc] initWithFrame:rect];
        //        _pageControl.userInteractionEnabled = NO;
        //        [self addSubview:_pageControl];
        
        _curPage = 0;
    }
    return self;
}

- (void)setDataource:(id<XLCycleScrollViewDatasource>)datasource
{
    _datasource = datasource;
    [self reloadData];
    
}

- (void)reloadData
{
    _totalPages = [_datasource numberOfPages:self];
    if (_totalPages == 0) {
        return;
    }
    _pageControl.numberOfPages = _totalPages;
    [self loadData];
    
}

- (void)loadData
{
    
    _pageControl.currentPage = _curPage;
    
    //从scrollView上移除所有的subview
    NSArray *subViews = [_scrollView subviews];
    if([subViews count] != 0) {
        [subViews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    }
    
    [self getDisplayImagesWithCurpage:_curPage];
    
    for (int i = 0; i < 3; i++) {
        UIView *v = [_curViews objectAtIndex:i];
        v.userInteractionEnabled = YES;
        UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                    action:@selector(handleTap:)];
        [v addGestureRecognizer:singleTap];
        //        [singleTap release];
        v.frame = CGRectOffset(v.frame, v.frame.size.width * i, 0);
        [_scrollView addSubview:v];
    }
    
    [_scrollView setContentOffset:CGPointMake(_scrollView.frame.size.width, 0)];
    
    //    _curPage++;
    //    if (_curPage >= _totalPages) {
    //        _curPage = 0;
    //    }
    
    [self scrollbyself];
    //    [_scrollView setContentOffset:CGPointMake(_scrollView.frame.size.width + 320, 0) animated:YES];
    //    [self performSelector:@selector(loadData) withObject:nil afterDelay:4.f];
    
    
    
}

- (void)scrollbyself
{
    if (_enable) {
        
        [self scrollViewDidEndDecelerating:_scrollView ];
        [_scrollView setContentOffset:CGPointMake(_scrollView.frame.size.width*2, 0) animated:YES];
        [self scrollViewDidScroll:_scrollView];
        
        double delayInSeconds = 1;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            
            [self scrollViewDidEndDecelerating:_scrollView ];
            
            double delayInSeconds = 2;
            dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
            dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                
                [self scrollbyself];
                
                
            });
        });
    }
    else
    {
        //        double delayInSeconds = 5.0;
        //        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
        //        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        //            [self scrollbyself];
        //        });
    }
    
}


- (void)swiptLoadData{
    
    _pageControl.currentPage = _curPage;
    
    //从scrollView上移除所有的subview
    NSArray *subViews = [_scrollView subviews];
    if([subViews count] != 0) {
        [subViews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    }
    
    [self getDisplayImagesWithCurpage:_curPage];
    
    for (int i = 0; i < 3; i++) {
        UIView *v = [_curViews objectAtIndex:i];
        v.userInteractionEnabled = YES;
        UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                    action:@selector(handleTap:)];
        [v addGestureRecognizer:singleTap];
        //        [singleTap release];
        v.frame = CGRectOffset(v.frame, v.frame.size.width * i, 0);
        [_scrollView addSubview:v];
    }
    
    [_scrollView setContentOffset:CGPointMake(_scrollView.frame.size.width, 0)];
    
}

- (void)getDisplayImagesWithCurpage:(NSInteger)page {
    
    NSInteger pre = [self validPageValue:_curPage-1];
    NSInteger last = [self validPageValue:_curPage+1];
    
    if (!_curViews) {
        _curViews = [[NSMutableArray alloc] init];
    }
    
    [_curViews removeAllObjects];
    
    [_curViews addObject:[_datasource XLScrollView:self pageAtIndex:pre]];
    [_curViews addObject:[_datasource XLScrollView:self pageAtIndex:page]];
    [_curViews addObject:[_datasource XLScrollView:self pageAtIndex:last]];
    
    
}

- (NSInteger)validPageValue:(NSInteger)value {
    
    if(value == -1) value = _totalPages - 1;
    if(value == _totalPages) value = 0;
    
    return value;
    
}

- (void)handleTap:(UITapGestureRecognizer *)tap {
    
    if ([_delegate respondsToSelector:@selector(didClickPage:atIndex:)]) {
        [_delegate didClickPage:self atIndex:_curPage];
    }
    
}

- (void)setViewContent:(UIView *)view atIndex:(NSInteger)index
{
    if (index == _curPage) {
        [_curViews replaceObjectAtIndex:1 withObject:view];
        for (int i = 0; i < 3; i++) {
            UIView *v = [_curViews objectAtIndex:i];
            v.userInteractionEnabled = YES;
            UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                        action:@selector(handleTap:)];
            [v addGestureRecognizer:singleTap];
            //            [singleTap release];
            v.frame = CGRectOffset(v.frame, v.frame.size.width * i, 0);
            [_scrollView addSubview:v];
        }
    }
}

#pragma mark - UIScrollViewDelegate
//- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
//    _enable = NO;
//}
//
//- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
//    _enable = YES;
//}

- (void)scrollViewDidScroll:(UIScrollView *)aScrollView {
    
    //    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    
    int x = aScrollView.contentOffset.x;
    
    //往下翻一张
    if(x >= (2*self.frame.size.width)) {
        _curPage = [self validPageValue:_curPage+1];
        [self swiptLoadData];
    }
    
    //往上翻
    if(x <= 0) {
        _curPage = [self validPageValue:_curPage-1];
        [self swiptLoadData];
    }
    
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)aScrollView {
    
    [_scrollView setContentOffset:CGPointMake(_scrollView.frame.size.width, 0) animated:YES];
    
    if (_curPage>=0&&_curPage<_totalPages) {
        NSLog(@"%@",self);
        if ([self.delegate respondsToSelector:@selector(updatePage:)]) {
            [self.delegate performSelector:@selector(updatePage:) withObject:[NSNumber numberWithInt:(int)_curPage]];
        }
        
    }
    
    //    [self performSelector:@selector(loadData) withObject:nil afterDelay:0.1f];
    //    _enable = YES;
    //    [self scrollbyself];
    
}


@end
