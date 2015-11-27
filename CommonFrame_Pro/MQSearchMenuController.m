//
//  ICSideMenuController.m
//  CDSideBar
//
//  Created by ionitech on 15/6/4.
//  Copyright (c) 2015年 Christophe Dellac. All rights reserved.
//

#import "MQSearchMenuController.h"
#import "SKSTableViewCell.h"
#import "Mark.h"
#import "UICommon.h"

@interface MQSearchMenuController()
{
    NSIndexPath*    _indexTime;
    NSIndexPath*    _indexType;
    
    UIView * _searchTopView;
    UIView * _searchMarkView;
}


@end

@implementation MQSearchMenuController


@synthesize menuColor = _menuColor;
@synthesize isOpen = _isOpen;


#pragma mark -
#pragma mark TableViewDelaget

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"SKSTableViewCell";
    
    SKSTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (!cell)
        cell = [[SKSTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    
    Mark * mark = _nameList[indexPath.section][indexPath.row][0];
    
    cell.titleLbl.text = mark.labelName;
    cell.iconImg.image = [UIImage imageNamed:mark.labelImage];
    cell.backgroundColor = RGBCOLOR(31, 31, 31);
    
    UILabel* bottomLine = [[UILabel alloc] initWithFrame:CGRectMake(0, 43.5, tableView.frame.size.width, 0.5)];
    [bottomLine setBackgroundColor:RGBCOLOR(74, 74, 74)];
    [cell.contentView addSubview:bottomLine];
    
    if ((indexPath.section == 0 && (indexPath.row == 2 || indexPath.row == 1 || indexPath.row == 0)))
        cell.expandable = YES;
    else
        cell.expandable = NO;
    
    return cell;
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForSubRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"SliderTypeCellIdentifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    for(UIView *view in cell.contentView.subviews) {
        [view removeFromSuperview];
    }
    
    NSInteger section = indexPath.section;
    NSInteger row = indexPath.row;
    NSInteger subRow = indexPath.subRow;
    
    if(indexPath.subRow < [_nameList[indexPath.section][indexPath.row] count])
    {
        Mark * m = _nameList[indexPath.section][indexPath.row][indexPath.subRow];
        
        UIImageView* img = [[UIImageView alloc] initWithFrame:CGRectMake(14, 14, 17, 17)];
        [img setBackgroundColor:[UIColor clearColor]];
        [img setImage:[UIImage imageNamed:m.labelImage]];
        
        [cell.contentView addSubview:img];
        
        UILabel* name = [[UILabel alloc] initWithFrame:CGRectMake(XW(img)+ 14, 0, 200, 44)];
        [name setBackgroundColor:[UIColor clearColor]];
        [name setText:m.labelName];
        [name setTextColor:RGBCOLOR(251, 251, 251)];
        [name setFont:[UIFont systemFontOfSize:14]];
        [cell.contentView addSubview:name];
        
        cell.contentView.backgroundColor = RGBCOLOR(36, 36, 36);
        
        UILabel* bottomLine = [[UILabel alloc] initWithFrame:CGRectMake(0, 43.5, tableView.frame.size.width, 0.5)];
        [bottomLine setBackgroundColor:RGBCOLOR(74, 74, 74)];
        [cell.contentView addSubview:bottomLine];
    }
    
    return cell;
}



- (void)tableView:(SKSTableView *)tableView didSelectSubRowAtIndexPath:(NSIndexPath *)indexPath
{
//    NSLog(@"Section: %d, Row:%d, Subrow:%d", indexPath.section, indexPath.row, indexPath.subRow);
//    
//    if ([self.delegate respondsToSelector:@selector(cdSliderCellClicked:)])
//        [self.delegate cdSliderCellClicked:indexPath];
//    //[self dismissMenu];
//    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44;
}

- (CGFloat)tableView:(UITableView *)tableView heightForSubRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [_nameList count];
}

- (BOOL)tableView:(SKSTableView *)tableView shouldExpandSubRowsOfCellAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0 && indexPath.row == 0)
    {
        return YES;
    }
    
    return NO;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_nameList[section] count];
}

- (NSInteger)tableView:(SKSTableView *)tableView numberOfSubRowsAtIndexPath:(NSIndexPath *)indexPath
{
    return [_nameList[indexPath.section][indexPath.row] count] - 1;
}

#pragma mark -
#pragma mark Init

- (MQSearchMenuController*)initWithImages:(NSArray*)images  names:(NSArray*)nameList  menuButton:(UIButton*)button
{

    [button addTarget:self action:@selector(showMenu) forControlEvents:UIControlEventTouchUpInside];
    
    _menuButton = button;
    
    _backgroundMenuView = [[UIView alloc] init];
    _menuColor = [UIColor whiteColor];
    _buttonList = [[NSMutableArray alloc] initWithArray:images];
    _nameList = [[NSMutableArray alloc] initWithArray:nameList];
    
    
    return self;
}

- (void)insertMenuButtonOnView:(UIView*)view atPosition:(CGPoint)position
{
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissMenu)];
    [view addGestureRecognizer:singleTap];
    
    singleTap.delegate = self;
    
    _viewWidth = view.frame.size.width;
    
    UIView * topButtonView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREENWIDTH, 24)];
    topButtonView.backgroundColor = [UIColor clearColor];
    [_backgroundMenuView addSubview: topButtonView];
    
    UIButton * closeBtn = [[UIButton alloc] initWithFrame:CGRectMake(SCREENWIDTH - 46, 0, 46, 24)];
    closeBtn.titleLabel.font = Font(12);
    closeBtn.titleLabel.textColor = [UIColor whiteColor];
    [closeBtn setTitle:@"关闭" forState:UIControlStateNormal];
    closeBtn.backgroundColor = [UIColor backgroundColor];
    [closeBtn addTarget:self action:@selector(closeButtonClick) forControlEvents:UIControlEventTouchUpInside];
    [closeBtn setRoundCorner:3.3];
    [_backgroundMenuView addSubview:closeBtn];
    
    CGRect tableFrame = CGRectMake(0, 24 , _viewWidth, [UIApplication sharedApplication].delegate.window.bounds.size.height - 60);
    
    _mainTableView = [[SKSTableView alloc]  initWithFrame:tableFrame];
    _mainTableView.showsVerticalScrollIndicator = NO;
    [_mainTableView setBackgroundColor:[UIColor blackColor]];
    [_mainTableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    _mainTableView.shouldExpandOnlyOneCell = YES;
    _mainTableView.SKSTableViewDelegate = self;
    
    _mainTableView.tableHeaderView = ({
        
        [self searchHeaderView];
    
    });
    
    [_backgroundMenuView addSubview:_mainTableView];
    
    _backgroundMenuView.frame = CGRectMake(0, SCREENHEIGHT, _viewWidth, view.frame.size.height);
    _backgroundMenuView.backgroundColor = [UIColor clearColor];
    [view addSubview:_backgroundMenuView];
    
}

- (void) closeButtonClick
{
    [self dismissMenu];
}

- (UIView *) searchHeaderView
{
    if(!_searchTopView)
    {
        _searchTopView = [[UIView alloc] initWithFrame:CGRectMake(0, 24, SCREENWIDTH, 157)];
        _searchTopView.backgroundColor = [UIColor backgroundColor];

    }
    
    if(!_searchMarkView)
    {
        _searchMarkView = [[UIView alloc] initWithFrame:CGRectMake(14, 14, SCREENWIDTH - 14 * 2, 34)];
        _searchMarkView.backgroundColor = [UIColor whiteColor];
        [_searchMarkView setRoundColorCorner:3.3 withColor:[UIColor grayLineColor]];
        
        [_searchTopView addSubview:_searchMarkView];
        
        UIImageView * searchIcon = [[UIImageView alloc] initWithFrame:CGRectMake(7, 10, 14, 14)];
        searchIcon.image = [UIImage imageNamed:@"icon_sousuo_huise"];
        [_searchTopView addSubview:searchIcon];
        
        UITextField * txtField = [[UITextField alloc] initWithFrame:CGRectMake(28, 0, W(_searchMarkView) - 28, 34)];
        txtField.tag = 1;
        txtField.placeholder = @"请输入您要查找的关键字";
        
    }

    return _searchTopView;
}

- (void)bgTap
{
    [self dismissMenu];
    
}

#pragma mark -
#pragma mark Gesture recognizer action

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    NSLog(@"%@", NSStringFromClass([touch.view class]));
    
    if ([NSStringFromClass([touch.view class]) isEqualToString:@"UITableViewCellContentView"]) {
        return NO;
    }
    else if ([NSStringFromClass([touch.view class]) isEqualToString:@"PPDragDropBadgeView"]) {
        //UIView* cView = touch.view;
        UIView* pView = touch.view.superview;
        for (UIControl* control in pView.subviews) {
            if ([control isKindOfClass:[UIButton class]]) {
                UIButton* btn = (UIButton*)control;
                [btn sendActionsForControlEvents:UIControlEventTouchUpInside];
                
                break;
            }
        }
        return NO;
    }
    else if ([NSStringFromClass([touch.view class]) isEqualToString:@"ZYQTapAssetView"]) {
        return NO;
    }
    
    return YES;
}

#pragma mark -
#pragma mark Menu button action

- (void)dismissMenuWithSelection:(UIButton*)button
{
    [UIView animateWithDuration:0.3f
                          delay:0.0f
         usingSpringWithDamping:.2f
          initialSpringVelocity:10.f
                        options:0 animations:^{
                            button.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1.2, 1.2);
                        }
                     completion:^(BOOL finished) {
                         [self dismissMenu];
                     }];
}

- (void)dismissMenu
{
    //[_bgView setHidden:YES];
    if (_isOpen)
    {
        _isOpen = !_isOpen;
        [self performDismissAnimation];
    }
}

- (void)showMenu
{
    if (!_isOpen)
    {
        //[_bgView setHidden:NO];
        _isOpen = YES;
        [self performSelectorInBackground:@selector(performOpenAnimation) withObject:nil];
    }
    else
    {
        [self dismissMenu];
    }
    
    if ([self.delegate respondsToSelector:@selector(partfarmButtonClicked:)]) {
        [self.delegate partfarmButtonClicked:@"2"];
    }
}

- (void)onMenuButtonClick:(UIButton*)button
{
    if ([self.delegate respondsToSelector:@selector(cdSliderCellClicked:)])
        //        [self.delegate cdSliderCellClicked:button.tag];
        [self dismissMenuWithSelection:button];
}

#pragma mark -
#pragma mark - Animations

- (void)performDismissAnimation
{
    [UIView animateWithDuration:0.4 animations:^{
        _menuButton.alpha = 1.0f;
        _menuButton.transform = CGAffineTransformTranslate(CGAffineTransformIdentity, 0, 0);
        _backgroundMenuView.transform = CGAffineTransformTranslate(CGAffineTransformIdentity, 0, 0);
    }];
}

- (void)performOpenAnimation
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [UIView animateWithDuration:0.4 animations:^{
            _backgroundMenuView.transform = CGAffineTransformTranslate(CGAffineTransformIdentity, 0, -SCREENHEIGHT + 64 + 53);
        }];
    });
}

@end