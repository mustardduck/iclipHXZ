//
//  MQworkTimeSelectVC.m
//  CommonFrame_Pro
//
//  Created by 倩 莫 on 16/1/7.
//  Copyright © 2016年 ionitech. All rights reserved.
//

#import "MQworkTimeSelectVC.h"
#import "RRAttributedString.h"

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
    
    CGRect tableFrame = CGRectMake(0, 0 , SCREENWIDTH, 44 * 5);
    
    _mainTableView = [[UITableView alloc]  initWithFrame:tableFrame];
    _mainTableView.showsVerticalScrollIndicator = NO;
    [_mainTableView setBackgroundColor:[UIColor grayMarkColor]];
    [_mainTableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    
    _mainTableView.delegate = self;
    _mainTableView.dataSource = self;
    
    [_mainView addSubview:_mainTableView];
    
    pView = _mainView;
    
    _mainView.transform = CGAffineTransformTranslate(CGAffineTransformIdentity, 0, - H(_mainTableView) + 44);
    
    _mainView.hidden = YES;
    
//    UIView * line = [[UIView alloc] initWithFrame:CGRectMake(SCREENWIDTH / 2 + 1, H(_mainTableView) - 0.5, W(_mainTableView), 0.5)];
//    line.backgroundColor = [UIColor grayLineColor];
//    [_mainView addSubview:line];
//    
//    line = [[UIView alloc] initWithFrame:CGRectMake(X(line), 0, 0.5, H(_mainTableView))];
//    line.backgroundColor = [UIColor grayLineColor];
//    [_mainView addSubview:line];
    
    return self;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (!cell)
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    
    WorkPlanTime * wpt = _timeList[indexPath.row];
    
    UILabel * titleLbl = [cell viewWithTag:111];
    if(!titleLbl)
    {
        titleLbl = [[UILabel alloc] initWithFrame:CGRectMake(20, 0, SCREENWIDTH - 20 , 44)];
        titleLbl.tag = 111;
        titleLbl.backgroundColor = [UIColor clearColor];
        titleLbl.font = Font(15);
        titleLbl.textColor = [UIColor whiteColor];
    }
    
    NSString * timeStr = @"";
    
    if(wpt.week == 0)
    {
        timeStr = [NSString stringWithFormat:@"    无       %ld月", wpt.month];
    }
    else
    {
        timeStr = [NSString stringWithFormat:@"第%ld周    %ld月", wpt.week, wpt.month];
    }
    
    NSString * mondayDateStr = [UICommon stringFromDate:[UICommon mondayDateFromWPT: wpt]];
    NSString * weekendDateStr = [UICommon stringFromDate:[UICommon weekendDateFromWPT: wpt]];

    mondayDateStr = [mondayDateStr substringWithRange:NSMakeRange(5, 5)];
    weekendDateStr = [weekendDateStr substringWithRange:NSMakeRange(5, 5)];
    
    NSString * dateStr = [NSString stringWithFormat:@"%@ ~ %@                     %@",mondayDateStr, weekendDateStr, timeStr];
    
    
    if(wpt.year == _currentWPT.year && wpt.month == _currentWPT.month && wpt.week == _currentWPT.week)
    {
        //        [tableView selectRowAtIndexPath:indexPath animated:YES scrollPosition:UITableViewScrollPositionBottom];
//        NSAttributedString *attrStr = [RRAttributedString setText:dateStr font:titleLbl.font range:NSMakeRange(0, 2)];
        NSAttributedString *attrStr = [RRAttributedString setText:dateStr color:[UIColor blueTextColor] range:NSMakeRange(dateStr.length - timeStr.length, timeStr.length)];
        titleLbl.attributedText = attrStr;
    }
    else
    {
        titleLbl.text = dateStr;
    }
    
    cell.contentView.backgroundColor = [UIColor grayMarkColor];
    
//    cell.selectedBackgroundView = [[UIView alloc] initWithFrame:cell.frame];
//    cell.selectedBackgroundView.backgroundColor = [UIColor tagBlueBackColor];
    
    [cell.contentView addSubview:titleLbl];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44;
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
    
    self.currentWPT = wpt;
        
    if ([self.delegate respondsToSelector:@selector(didSelectTime:)])
        [self.delegate didSelectTime:wpt];
    
    [self showTopMenu:@"2"];
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
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
