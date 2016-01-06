//
//  MQworkGroupSelectVC.m
//  CommonFrame_Pro
//
//  Created by 倩 莫 on 16/1/6.
//  Copyright © 2016年 ionitech. All rights reserved.
//

#import "MQworkGroupSelectVC.h"
#import "UICommon.h"

@interface MQworkGroupSelectVC()
{
    UIView* _mainView;
    
    NSMutableArray *_groupList;
    
}

@end

@implementation MQworkGroupSelectVC


#pragma mark -
#pragma mark TableViewDelegate

- (MQworkGroupSelectVC*)initWithMenuNameList:(NSArray*)groupList actionControl:(UIButton*)button parentView:(UIView*)pView
{
    _groupList = [[NSMutableArray alloc] initWithArray:groupList];

    _mainView = pView;
    
    [_mainView setBackgroundColor:[UIColor blackColor]];
    
    [button addTarget:self action:@selector(showTopMenu:) forControlEvents:UIControlEventTouchUpInside];

    CGRect tableFrame = CGRectMake(0, 0 , SCREENWIDTH / 2, 204);
    
    _mainTableView = [[UITableView alloc]  initWithFrame:tableFrame];
    _mainTableView.showsVerticalScrollIndicator = NO;
    [_mainTableView setBackgroundColor:[UIColor grayMarkColor]];
    [_mainTableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    _mainTableView.delegate = self;
    _mainTableView.dataSource = self;
    
    [_mainView addSubview:_mainTableView];

    pView = _mainView;
    
    _mainView.transform = CGAffineTransformTranslate(CGAffineTransformIdentity, 0, - 204 + 44);
    
    _mainView.hidden = YES;
    
    return self;
}

- (void)showTopMenu:(id)sender
{
    if ([sender isKindOfClass:[NSString class]]) {
        
        if (_isOpen) {
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
            [self.delegate partfarmButtonClicked:@"1"];
        }
    }
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (!cell)
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    
    Group * gr = _groupList[indexPath.row];
    
    UILabel * titleLbl = [cell viewWithTag:111];
    if(!titleLbl)
    {
        titleLbl = [[UILabel alloc] initWithFrame:CGRectMake(8, 0, SCREENWIDTH / 2 - 16 , 34)];
        titleLbl.tag = 111;
        titleLbl.backgroundColor = [UIColor clearColor];
        titleLbl.textAlignment = NSTextAlignmentCenter;
        titleLbl.font = Font(17);
        titleLbl.textColor = [UIColor whiteColor];
    }
    titleLbl.text = gr.workGroupName;
    
    cell.contentView.backgroundColor = [UIColor grayMarkColor];
    
    [cell.contentView addSubview:titleLbl];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 34;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _groupList.count;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(nonnull NSIndexPath *)indexPath
{
    Group * gr = _groupList[indexPath.row];
    
    if ([self.delegate respondsToSelector:@selector(didSelectGroup:)])
        [self.delegate didSelectGroup:gr];
    
    [self showTopMenu:@"1"];
}

- (void)performDismissAnimation
{
    [UIView animateWithDuration:0.2 animations:^{
        _mainView.transform = CGAffineTransformTranslate(CGAffineTransformIdentity, 0, - 204 + 44);
        [self performSelector:@selector(delayMethod) withObject:nil afterDelay:0.2f];

    }];
    
}

- (void)delayMethod
{
    _mainView.hidden = YES;

}

- (void)performOpenAnimation
{
    _mainView.hidden = NO;
    dispatch_async(dispatch_get_main_queue(), ^{
        [UIView animateWithDuration:0.2 animations:^{
            _mainView.transform = CGAffineTransformTranslate(CGAffineTransformIdentity, 0, 44);

        }];
    });
}

@end
