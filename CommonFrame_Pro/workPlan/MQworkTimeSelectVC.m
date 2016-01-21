//
//  MQworkTimeSelectVC.m
//  CommonFrame_Pro
//
//  Created by 倩 莫 on 16/1/7.
//  Copyright © 2016年 ionitech. All rights reserved.
//

#import "MQworkTimeSelectVC.h"

#import "UICommon.h"

@interface MQworkTimeSelectVC()
{
    UIView* _mainView;
    
    NSMutableArray *_timeList;

}

@end

@implementation MQworkTimeSelectVC

- (void)showTopMenu:(id)sender
{
    if ([sender isKindOfClass:[NSString class]]) {
        
        if (_isOpen) {
            [_mainView setBackgroundColor:[UIColor clearColor]];

            [self performDismissAnimation];
            _isOpen = FALSE;
        }
        else{
            [self performOpenAnimation];
            _isOpen = TRUE;
        }
    }
    else
    {
        if ([self.delegate respondsToSelector:@selector(partfarmButtonClicked:)]) {
            [self.delegate partfarmButtonClicked:@"2"];
        }
    }
}

- (void) closeButtonClick
{
    [self showTopMenu:@"1"];
}

#pragma mark -
#pragma mark TableViewDelegate

- (MQworkTimeSelectVC*)initWithMenuNameList:(NSArray*)timeList actionControl:(UIButton*)button parentView:(UIView*)pView
{
    _timeList = [[NSMutableArray alloc] initWithArray:timeList];
    
    _mainView = pView;
    
//    [_mainView setBackgroundColor:[UIColor clearColor]];
    
    [button addTarget:self action:@selector(showTopMenu:) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton * closeBtn = [[UIButton alloc] initWithFrame:_mainView.frame];
    closeBtn.backgroundColor = [UIColor clearColor];
    [closeBtn addTarget:self action:@selector(closeButtonClick) forControlEvents:UIControlEventTouchUpInside];
    [_mainView addSubview:closeBtn];
    
    CGRect tableFrame = CGRectMake(SCREENWIDTH / 2 + 1, 0 , SCREENWIDTH / 2, 224);
    
    _mainTableView = [[UITableView alloc]  initWithFrame:tableFrame];
    _mainTableView.showsVerticalScrollIndicator = NO;
    [_mainTableView setBackgroundColor:[UIColor grayMarkColor]];
    [_mainTableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    
    _mainTableView.delegate = self;
    _mainTableView.dataSource = self;
    
    [_mainView addSubview:_mainTableView];
    
    pView = _mainView;
    
    _mainView.transform = CGAffineTransformTranslate(CGAffineTransformIdentity, 0, - 224 + 44);
    
    _mainView.hidden = YES;
    
    UIView * line = [[UIView alloc] initWithFrame:CGRectMake(SCREENWIDTH / 2 + 1, H(_mainTableView) - 0.5, W(_mainTableView), 0.5)];
    line.backgroundColor = [UIColor grayLineColor];
    [_mainView addSubview:line];
    
    line = [[UIView alloc] initWithFrame:CGRectMake(X(line), 0, 0.5, H(_mainTableView))];
    line.backgroundColor = [UIColor grayLineColor];
    [_mainView addSubview:line];
    
    return self;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (!cell)
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    
    WorkPlanTime * wpt = _timeList[indexPath.row];
    
    if(wpt.year == _currentWPT.year && wpt.month == _currentWPT.month && wpt.week == _currentWPT.week)
    {
        [tableView selectRowAtIndexPath:indexPath animated:YES scrollPosition:UITableViewScrollPositionBottom];
    }
    
    UILabel * titleLbl = [cell viewWithTag:111];
    if(!titleLbl)
    {
        titleLbl = [[UILabel alloc] initWithFrame:CGRectMake(8, 0, SCREENWIDTH / 2 - 16 , 34)];
        titleLbl.tag = 111;
        titleLbl.backgroundColor = [UIColor clearColor];
        titleLbl.textAlignment = NSTextAlignmentCenter;
        titleLbl.font = Font(15);
        titleLbl.textColor = [UIColor whiteColor];
    }
    
    NSString * timeStr = @"";
    
    if(wpt.week == 0)
    {
        timeStr = [NSString stringWithFormat:@"   无     %ld月  %ld年", wpt.month, wpt.year];
    }
    else
    {
        timeStr = [NSString stringWithFormat:@"第%ld周  %ld月  %ld年", wpt.week, wpt.month, wpt.year];
    }
    
    titleLbl.text = timeStr;
    
    if(indexPath.row == 0)
    {
        titleLbl.top = 10;
    }
    else
    {
        titleLbl.top = 0;
    }
    
    cell.contentView.backgroundColor = [UIColor grayMarkColor];
    
    cell.selectedBackgroundView = [[UIView alloc] initWithFrame:cell.frame];
    cell.selectedBackgroundView.backgroundColor = [UIColor tagBlueBackColor];
    
    [cell.contentView addSubview:titleLbl];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.row == 0 || indexPath.row == _timeList.count - 1)
    {
        return 44;
    }
    return 34;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _timeList.count;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    WorkPlanTime * wpt = _timeList[indexPath.row];
    
    if ([self.delegate respondsToSelector:@selector(didSelectTime:)])
        [self.delegate didSelectTime:wpt];
    
    [self showTopMenu:@"2"];
}

- (void)performDismissAnimation
{
    [UIView animateWithDuration:0.2 animations:^{
        _mainView.transform = CGAffineTransformTranslate(CGAffineTransformIdentity, 0, - 224 + 44);
        [self performSelector:@selector(delayMethod) withObject:nil afterDelay:0.2f];
        
    }];
    
}

- (void)delayMethod
{
    _mainView.hidden = YES;
    
}

- (void)delayMethodShadow
{
    [_mainView setBackgroundColor:RGBACOLOR(0, 0, 0, 0.5 )];
}

- (void)performOpenAnimation
{
    _mainView.hidden = NO;
    dispatch_async(dispatch_get_main_queue(), ^{
        [UIView animateWithDuration:0.2 animations:^{
            _mainView.transform = CGAffineTransformTranslate(CGAffineTransformIdentity, 0, 44);
            [self performSelector:@selector(delayMethodShadow) withObject:nil afterDelay:0.2f];

        }];
    });
}

@end
