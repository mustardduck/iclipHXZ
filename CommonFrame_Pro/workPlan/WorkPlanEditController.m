//
//  WorkPlanEditController.m
//  CommonFrame_Pro
//
//  Created by 倩 莫 on 15/12/29.
//  Copyright © 2015年 ionitech. All rights reserved.
//

#import "WorkPlanEditController.h"
#import "Group.h"
#import "UICommon.h"
#import "WorkPlanMainCell.h"
#import "Mission.h"
#import "WorkPlanAddMissionController.h"
#import "MQworkGroupSelectVC.h"
#import "MQworkTimeSelectVC.h"
#import "NSDate+DateTools.h"
#import "WorkPlanTime.h"

@interface WorkPlanEditController ()<UITableViewDataSource, UITableViewDelegate, MQworkGroupSelectDelegate, MQworkTimeSelectDelegate>
{
    NSArray * _tags;
    
    BOOL _statusLayoutShow;
    
    MQworkGroupSelectVC * _MQworkGroupSelectVC;
    MQworkTimeSelectVC * _MQworkTimeSelectVC;
    
    IBOutlet UIView*      _leftMenuView;
    IBOutlet UIView*      _rightpMenuView;
    
    UILabel  *  _workGroupNameLbl;
    UIButton *  _groupBtn;
    
    UILabel  *  _timeLbl;
    UIButton *  _timeBtn;
    UIButton *  _layoutBtn;
}

@property (weak, nonatomic) IBOutlet UITableView *mainTableView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *leftViewWidthCons;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *rightViewWidthCons;

@end

@implementation WorkPlanEditController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    UIButton *leftButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 70, 20)];
    [leftButton addTarget:self action:@selector(btnBackButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    UIImageView* imgview = [[UIImageView alloc] initWithFrame:CGRectMake(0, 1, 10, 18)];
    [imgview setImage:[UIImage imageNamed:@"btn_fanhui"]];
    [leftButton addSubview:imgview];
    UILabel* ti = [[UILabel alloc] initWithFrame:CGRectMake(18, 0, 50, 20)];
    [ti setBackgroundColor:[UIColor clearColor]];
    [ti setTextColor:[UIColor whiteColor]];
    [ti setText:@"返回"];
    [ti setFont:[UIFont systemFontOfSize:17]];
    [leftButton addSubview:ti];
    UIBarButtonItem *leftBarButton = [[UIBarButtonItem alloc]initWithCustomView:leftButton];
    self.navigationItem.leftBarButtonItem = leftBarButton;
    
    if(!_rows)
    {
        _rows = [NSMutableArray array];
    }

    _tags = [Group findUserMainLabel:[LoginUser loginUserID] workGroupId:_workGroupId];
    
    for(int i = 0; i < _tags.count; i ++)
    {
        Mark * ma = _tags[i];
        
        NSMutableArray * arr = [NSMutableArray array];
        
        NSMutableDictionary * dic = [NSMutableDictionary dictionary];
        
        [dic setObject:arr forKey:ma.labelId];
        
        [_rows addObject:dic];
        
    }
    
    UIView * tView = [self layoutTopView];

    [self initGroupSelectView];
    
    [self initTimeSelectView];
    
    [self setTopView:tView];
}

- (UIView *)layoutTopView
{
    UIView * topView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREENWIDTH, 44)];
    topView.backgroundColor = [UIColor clearColor];
    
    _groupBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, SCREENWIDTH / 2, 44)];
    _groupBtn.backgroundColor = [UIColor backgroundColor];
    [_groupBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_groupBtn setContentHorizontalAlignment:UIControlContentHorizontalAlignmentRight];
    [_groupBtn setImage:[UIImage imageNamed:@"btn_jiantou_2"] forState:UIControlStateNormal];
    [_groupBtn setImageEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 10)];
    
    [topView addSubview:_groupBtn];
    
    UIView * line = [[UIView alloc] initWithFrame:CGRectMake(SCREENWIDTH / 2, 7, 1, 30)];
    line.backgroundColor = [UIColor grayLineColor];
    [topView addSubview:line];
    
    UILabel * userNameLbl = [[UILabel alloc] initWithFrame:CGRectMake( X(line) - 28 - 46, 0, 46, 44)];
    userNameLbl.backgroundColor = [UIColor clearColor];
    userNameLbl.font = Font(15);
    userNameLbl.textColor = [UIColor whiteColor];
    userNameLbl.textAlignment = NSTextAlignmentCenter;
    userNameLbl.text = [LoginUser loginUserName];
    [topView addSubview:userNameLbl];
    
    _workGroupNameLbl = [[UILabel alloc] initWithFrame:CGRectMake(7, 0, X(userNameLbl) - 9 * 2, 44)];
    _workGroupNameLbl.backgroundColor = [UIColor clearColor];
    _workGroupNameLbl.font = Font(15);
    _workGroupNameLbl.textColor = [UIColor whiteColor];
    _workGroupNameLbl.text = _workGroupName;
    _workGroupNameLbl.textAlignment = NSTextAlignmentCenter;
    [topView addSubview:_workGroupNameLbl];
    
    _timeBtn = [[UIButton alloc] initWithFrame:CGRectMake(SCREENWIDTH / 2 + 1, 0, SCREENWIDTH / 2 - 1, 44)];
    _timeBtn.backgroundColor = [UIColor backgroundColor];
    [_timeBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_timeBtn setContentHorizontalAlignment:UIControlContentHorizontalAlignmentRight];
    [_timeBtn setImage:[UIImage imageNamed:@"btn_jiantou_2"] forState:UIControlStateNormal];
    [_timeBtn setImageEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 10)];
    [topView addSubview:_timeBtn];

    _timeLbl = [[UILabel alloc] initWithFrame:CGRectMake(SCREENWIDTH / 2 + 1, 0, SCREENWIDTH / 2 - 1, 44)];
    _timeLbl.backgroundColor = [UIColor clearColor];
    _timeLbl.font = Font(15);
    _timeLbl.textColor = [UIColor whiteColor];
    _timeLbl.textAlignment = NSTextAlignmentCenter;
    [topView addSubview:_timeLbl];
    
    _layoutBtn = [[UIButton alloc] initWithFrame:CGRectMake(SCREENWIDTH - 76 - 14, 44, 76, 46)];
    _layoutBtn.backgroundColor = [UIColor clearColor];
    [_layoutBtn setTitleColor:[UIColor blueTextColor] forState:UIControlStateNormal];
    [_layoutBtn setContentHorizontalAlignment:UIControlContentHorizontalAlignmentRight];
    _layoutBtn.titleLabel.font = Font(15);
    [_layoutBtn setTitle:@"状态视图" forState:UIControlStateNormal];
    [_layoutBtn addTarget:self action:@selector(btnLayoutButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:_layoutBtn];
    
    line = [[UIView alloc] initWithFrame:CGRectMake(0, 43.5, SCREENWIDTH, 0.5)];
    line.backgroundColor = [UIColor grayLineColor];
    [topView addSubview:line];
    
    return topView;
}

- (void) setTopView:(UIView *)topView
{
    [self.view addSubview:topView];
}

- (void) initGroupSelectView
{
    NSArray * groupList = [Group findMeWgListByUserID:[LoginUser loginUserID]];
    
    _leftViewWidthCons.constant = SCREENWIDTH / 2;
    
    _MQworkGroupSelectVC = [[MQworkGroupSelectVC alloc] initWithMenuNameList:groupList actionControl:_groupBtn parentView:_leftMenuView];//_groupBtn
    _MQworkGroupSelectVC.delegate = self;
    
    
}

- (void) initTimeSelectView
{
    NSArray * timeList = [self getTimeArr];
    
    WorkPlanTime * wpt = timeList[0];
    
    NSString * timeStr = @"";
    
    if(wpt.week == 0)
    {
        timeStr = [NSString stringWithFormat:@"无  %ld月  %ld年", wpt.month, wpt.year];
    }
    else
    {
        timeStr = [NSString stringWithFormat:@"第%ld周  %ld月  %ld年", wpt.week, wpt.month, wpt.year];
    }
    
    _timeLbl.text = timeStr;
    
    _rightViewWidthCons.constant = SCREENWIDTH;

    _MQworkTimeSelectVC = [[MQworkTimeSelectVC alloc] initWithMenuNameList:timeList actionControl:_timeBtn parentView:_rightpMenuView];
    _MQworkTimeSelectVC.delegate = self;

}

- (NSMutableArray * ) getTimeArr
{
    NSMutableArray * timeArr = [NSMutableArray array];
    
    NSDate * nowDate = [NSDate date];
    
    NSLog(@"星期%ld", nowDate.weekday);//1：周天 2：周一 3：周二 4：周三 5：周四 6：周五 7：周六

    NSInteger weekday = [UICommon weekday:nowDate];
    
    NSInteger weekdayOrdinal = 1;//第一个星期几
    
    NSDate *newDate = nowDate;
    
    if(weekday != 1)//今天不是周一
    {
       newDate = [nowDate dateBySubtractingDays:weekday - 1];//本周的周一
    }
    
    NSDate * fiveYearsLaterDate = [newDate dateByAddingYears:5];
    
    while ([newDate isEarlierThanOrEqualTo:fiveYearsLaterDate]) {
        
        weekdayOrdinal = newDate.weekdayOrdinal;//第几周的周一
        
        if(newDate.day <= newDate.daysInMonth)//小于或等于最后一天
        {
            if(weekdayOrdinal == 1)
            {
                WorkPlanTime *wpt = [WorkPlanTime new];
                wpt.year = newDate.year;
                wpt.month = newDate.month;
                wpt.week = 0;
                [timeArr addObject:wpt];
            }

            WorkPlanTime *wpt = [WorkPlanTime new];
            wpt.year = newDate.year;
            wpt.month = newDate.month;
            wpt.week = weekdayOrdinal;
            [timeArr addObject:wpt];

            newDate = [newDate dateByAddingWeeks:1];//下一周的周一
            
        }
    }
    
    [timeArr removeObjectAtIndex:0];
    
    return timeArr;
}

#pragma -
#pragma Side Menu delegate

- (void)partfarmButtonClicked:(NSString*)val
{
    NSInteger index = [val integerValue];
    if(index == 1)
    {
        if (_MQworkGroupSelectVC.isOpen) {
            [_MQworkGroupSelectVC showTopMenu:@"1"];
        }
        else
        {
            _MQworkGroupSelectVC.isOpen = NO;
            [_MQworkGroupSelectVC showTopMenu:@"1"];
        }
    }
    if(index == 2)
    {
        if (_MQworkTimeSelectVC.isOpen) {
            [_MQworkTimeSelectVC showTopMenu:@"2"];
            _layoutBtn.hidden = NO;
        }
        else
        {
            _layoutBtn.hidden = YES;
            _MQworkTimeSelectVC.isOpen = NO;
            [_MQworkTimeSelectVC showTopMenu:@"2"];
        }
    }
}


- (void) viewWillAppear:(BOOL)animated
{
    [_mainTableView reloadData];
}

- (IBAction)groupBtnClicked:(id)sender
{
    
}

- (IBAction)timeBtnClicked:(id)sender
{
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)btnBackButtonClicked:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)btnDoneButtonClicked:(id)sender
{
    
}

- (IBAction)btnLayoutButtonClicked:(id)sender
{
    if(!_statusLayoutShow)
    {
        _statusLayoutShow = YES;
        [_layoutBtn setTitle:@"简易视图" forState:UIControlStateNormal];
    }
    else
    {
        _statusLayoutShow = NO;
        [_layoutBtn setTitle:@"状态视图" forState:UIControlStateNormal];
    }
    
    [_mainTableView reloadData];
}

#pragma mark -
#pragma mark Table View Action
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(!_statusLayoutShow)
    {
        Mark * ma = _tags[indexPath.section];
        
        NSInteger count = [[_rows[indexPath.section] objectForKey:ma.labelId] count];
        
        if(indexPath.row == count && count > 0)
        {
            return 44 + 40;
        }
    
        return 34;
    }
    else
    {
        Mark * ma = _tags[indexPath.section];
        
        NSInteger count = [[_rows[indexPath.section] objectForKey:ma.labelId] count];
        
        if(indexPath.row == count && count > 0)
        {
            return 44 + 40;
        }
        
        UITableViewCell *cell = [self tableView:tableView cellForRowAtIndexPath:indexPath];
        if(cell)
        {
            return cell.frame.size.height;
        }
    }
    
    return 34;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return _tags.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    Mark * ma = _tags[section];
    
    NSInteger count = [[_rows[section] objectForKey:ma.labelId] count];
    
    if(count == 0)
    {
        count = 1;
        
        if(section == _tags.count - 1)
        {
            count = 2;
        }
    }
    else
    {
        if(section == _tags.count - 1)
        {
            count += 1;
        }
    }
    
    return count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 34;
}

- (UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView* myView = [[UIView alloc] init];
    myView.backgroundColor = [UIColor backgroundColor];
    
    UIView * titleView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREENWIDTH, 28)];
    titleView.backgroundColor = [UIColor clearColor];
    [myView addSubview:titleView];
    
    UIImageView * icon = [[UIImageView alloc] initWithFrame:CGRectMake(14, 0, 8, 11)];
    icon.image = [UIImage imageNamed:@"icon_zhuyaogongzu"];
    [titleView addSubview:icon];
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(27, -3, 200, 18)];
    titleLabel.textColor=[UIColor whiteColor];
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.font = Font(15);
    
    Mark * ma = _tags[section];
    
    titleLabel.text= ma.labelName;
    [titleView addSubview:titleLabel];
    
    return myView;
}

- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(!_statusLayoutShow)
    {
        Mark * ma = _tags[indexPath.section];

        NSArray * mArr = [_rows[indexPath.section] objectForKey:ma.labelId];
        
        if(mArr.count)
        {
            static NSString *cellId = @"WorkPlanMainCell";
            WorkPlanMainCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
            if (cell == nil){
                cell = [[WorkPlanMainCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
            }
            
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            
            if(indexPath.row < [mArr count])
            {
                Mission * mis = mArr[indexPath.row];
                
                cell.titleLbl.text = [NSString stringWithFormat:@"%ld. %@",indexPath.row + 1, mis.title];
                
                //-3:已超时  -2删除   -1停用   0：未开始 1进行中   2：已完成
                NSString * statusStr = @"未开始";
                
                if(mis.status == 1)
                {
                    statusStr = @"进行中";
                }
                else if (mis.status == 2)
                {
                    statusStr = @"已完成";
                }
                else if (mis.status == -3)
                {
                    statusStr = @"超时";
                    
                    cell.statusLbl.textColor = [UIColor redTextColor];
                }
                
                cell.statusLbl.text = statusStr;
                
                return cell;
            }
            else if (indexPath.row == mArr.count && mArr.count > 0)
            {
                static NSString *cellId = @"Cell";
                UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
                if (cell == nil){
                    cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
                    cell.frame = CGRectMake(0, 0, SCREENWIDTH, 84);
                }
                
                for(UIView *view in cell.contentView.subviews) {
                    [view removeFromSuperview];
                }
                
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                
                UILabel * titleLbl = [[UILabel alloc] initWithFrame:CGRectMake((SCREENWIDTH - 200) / 2, 0, 200, 44)];
                titleLbl.backgroundColor = [UIColor grayMarkColor];
                titleLbl.textColor = [UIColor whiteColor];
                titleLbl.font = Font(15);
                titleLbl.text = @"+  添加任务";
                titleLbl.textAlignment = NSTextAlignmentCenter;
                [titleLbl setRoundColorCorner:3.3 withColor:[UIColor grayLineColor]];

                [cell.contentView addSubview:titleLbl];
                
//                UIImageView * icon = [[UIImageView alloc] initWithFrame:CGRectMake(14, 0, 14, 14)];
//                icon.image = [UIImage imageNamed:@"icon_tianjiarenwu"];
//                [cell.contentView addSubview:icon];
                
                cell.backgroundColor = [UIColor backgroundColor];
                
                return cell;

            }
        }
        else
        {
            if (indexPath.row == 1)
            {
                static NSString *cellId = @"Cell";
                UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
                if (cell == nil){
                    cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
                    cell.frame = CGRectMake(0, 0, SCREENWIDTH, 84);
                }
                
                for(UIView *view in cell.contentView.subviews) {
                    [view removeFromSuperview];
                }
                
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                
                UILabel * titleLbl = [[UILabel alloc] initWithFrame:CGRectMake((SCREENWIDTH - 200) / 2, 0, 200, 44)];
                titleLbl.backgroundColor = [UIColor grayMarkColor];
                titleLbl.textColor = [UIColor whiteColor];
                titleLbl.font = Font(15);
                titleLbl.text = @"+  添加任务";
                titleLbl.textAlignment = NSTextAlignmentCenter;
                [titleLbl setRoundColorCorner:3.3 withColor:[UIColor grayLineColor]];
                
                [cell.contentView addSubview:titleLbl];
                
                //                UIImageView * icon = [[UIImageView alloc] initWithFrame:CGRectMake(14, 0, 14, 14)];
                //                icon.image = [UIImage imageNamed:@"icon_tianjiarenwu"];
                //                [cell.contentView addSubview:icon];
                
                cell.backgroundColor = [UIColor backgroundColor];
                
                return cell;
                
            }
            else
            {
                static NSString *cellId = @"Cell";
                UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
                if (cell == nil){
                    cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
                    cell.frame = CGRectMake(0, 0, SCREENWIDTH, 34);
                }
                
                for(UIView *view in cell.contentView.subviews) {
                    [view removeFromSuperview];
                }
                
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                
                UILabel * titleLbl = [[UILabel alloc] initWithFrame:CGRectMake(14, -2, 200, 16)];
                titleLbl.backgroundColor = [UIColor clearColor];
                titleLbl.textColor = [UIColor whiteColor];
                titleLbl.font = Font(15);
                titleLbl.text = @"无";
                [cell.contentView addSubview:titleLbl];
                
//                UIImageView * icon = [[UIImageView alloc] initWithFrame:CGRectMake(14, 0, 14, 14)];
//                icon.image = [UIImage imageNamed:@"icon_tianjiarenwu"];
//                [cell.contentView addSubview:icon];
                
                cell.backgroundColor = [UIColor backgroundColor];
                
                return cell;
            }
        }
    }
    else
    {
        static NSString *cellId = @"Cell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
        if (cell == nil){
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
            cell.frame = CGRectMake(0, 0, SCREENWIDTH, 34);
        }
        
        for(UIView *view in cell.contentView.subviews) {
            [view removeFromSuperview];
        }
        
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        Mark * ma = _tags[indexPath.section];

        NSArray * mArr = [_rows[indexPath.section] objectForKey:ma.labelId];

        if(mArr.count)
        {
            if(indexPath.row < [mArr count])
            {
                Mission * mis = mArr[indexPath.row];
                
                UILabel * titleLbl = [[UILabel alloc] initWithFrame:CGRectMake(14, 0, SCREENWIDTH - 14 - 38, 16)];
                titleLbl.text = [NSString stringWithFormat:@"%ld. %@",indexPath.row + 1, mis.title];
                titleLbl.height = [UICommon getSizeFromString:titleLbl.text withSize:CGSizeMake(SCREENWIDTH - 14 - 38, 70) withFont:Font(14)].height;
                
                if(titleLbl.height > 70)
                {
                    titleLbl.height = 70;
                }
                titleLbl.backgroundColor = [UIColor clearColor];
                titleLbl.textColor = [UIColor whiteColor];
                titleLbl.numberOfLines = 3;
                titleLbl.font = Font(14);
                [cell.contentView addSubview:titleLbl];
                
                UIImageView * icon = [[UIImageView alloc]initWithFrame:CGRectMake(SCREENWIDTH - 14 - 10, 4, 10, 10)];
                icon.image = [UIImage imageNamed:@"icon_jiantou_3"];
                [cell.contentView addSubview:icon];
                
                //-3:已超时  -2删除   -1停用   0：未开始 1进行中   2：已完成
                NSString * statusStr = @"未开始";
                
                if(mis.status == 1)
                {
                    statusStr = @"进行中";
                }
                else if (mis.status == 2)
                {
                    statusStr = @"已完成";
                }
                else if (mis.status == -3)
                {
                    statusStr = @"超时";
                    
                }
                
                UILabel * statusLbl = [[UILabel alloc] initWithFrame:CGRectMake(30, titleLbl.bottom + 7, 54, 24)];
                statusLbl.backgroundColor = [UIColor grayMarkColor];
                [statusLbl setRoundCorner:1.7];
                statusLbl.textColor = [UIColor grayTitleColor];
                statusLbl.font = Font(14);
                statusLbl.textAlignment = NSTextAlignmentCenter;
                statusLbl.text = statusStr;
                
                UILabel * dateLbl = [[UILabel alloc] initWithFrame:CGRectMake(statusLbl.right + 7, titleLbl.bottom + 7, 148, 24)];
                
                dateLbl.backgroundColor = [UIColor grayMarkColor];
                [dateLbl setRoundCorner:1.7];
                dateLbl.textColor = [UIColor grayTitleColor];
                dateLbl.font = Font(14);
                dateLbl.textAlignment = NSTextAlignmentCenter;
                dateLbl.text = [NSString stringWithFormat:@"%@      %@", [LoginUser loginUserName], mis.finishTime];
                
                [cell.contentView addSubview:dateLbl];
                
                if(mis.status != -3)
                {
                    [cell.contentView addSubview:statusLbl];
                }
                else
                {
                    UIView * statusView = [[UIView alloc] initWithFrame:CGRectMake(30, titleLbl.bottom + 7, 54, 24)];
                    statusView.backgroundColor = [UIColor grayMarkColor];
                    [statusView setRoundCorner:1.7];
                    
                    UIImageView * icon = [[UIImageView alloc] initWithFrame:CGRectMake(7, 7, 9, 9)];
                    icon.image = [UIImage imageNamed:@"icon_chaoshi_hong"];
                    [statusView addSubview:icon];
                    
                    statusLbl.left = icon.right - 8;
                    statusLbl.top = 0;
                    statusLbl.backgroundColor = [UIColor clearColor];
                    statusLbl.textColor = [UIColor redTextColor];
                    [statusView addSubview:statusLbl];
                    
                    [cell.contentView addSubview:statusView];
                    
                    dateLbl.left = statusView.right + 7;
                    
                }
                
                CGFloat he = dateLbl.bottom + 20;
                
                CGRect rect = cell.frame;
                rect.size.height = he;
                cell.frame = rect;
                
                cell.contentView.backgroundColor = [UIColor backgroundColor];
                
                return cell;
                
            }
            else if (indexPath.row == mArr.count && mArr.count > 0)
            {
                static NSString *cellId = @"Cell";
                UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
                if (cell == nil){
                    cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
                    cell.frame = CGRectMake(0, 0, SCREENWIDTH, 84);
                }
                
                for(UIView *view in cell.contentView.subviews) {
                    [view removeFromSuperview];
                }
                
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                
                UILabel * titleLbl = [[UILabel alloc] initWithFrame:CGRectMake((SCREENWIDTH - 200) / 2, 0, 200, 44)];
                titleLbl.backgroundColor = [UIColor grayMarkColor];
                titleLbl.textColor = [UIColor whiteColor];
                titleLbl.font = Font(15);
                titleLbl.text = @"+  添加任务";
                titleLbl.textAlignment = NSTextAlignmentCenter;
                [titleLbl setRoundColorCorner:3.3 withColor:[UIColor grayLineColor]];
                
                [cell.contentView addSubview:titleLbl];
                
                //                UIImageView * icon = [[UIImageView alloc] initWithFrame:CGRectMake(14, 0, 14, 14)];
                //                icon.image = [UIImage imageNamed:@"icon_tianjiarenwu"];
                //                [cell.contentView addSubview:icon];
                
                cell.backgroundColor = [UIColor backgroundColor];
                
                return cell;
                
            }
        }
        else
        {
            if (indexPath.row == 1)
            {
                static NSString *cellId = @"Cell";
                UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
                if (cell == nil){
                    cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
                    cell.frame = CGRectMake(0, 0, SCREENWIDTH, 84);
                }
                
                for(UIView *view in cell.contentView.subviews) {
                    [view removeFromSuperview];
                }
                
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                
                UILabel * titleLbl = [[UILabel alloc] initWithFrame:CGRectMake((SCREENWIDTH - 200) / 2, 0, 200, 44)];
                titleLbl.backgroundColor = [UIColor grayMarkColor];
                titleLbl.textColor = [UIColor whiteColor];
                titleLbl.font = Font(15);
                titleLbl.text = @"+  添加任务";
                titleLbl.textAlignment = NSTextAlignmentCenter;
                [titleLbl setRoundColorCorner:3.3 withColor:[UIColor grayLineColor]];
                
                [cell.contentView addSubview:titleLbl];
                
                //                UIImageView * icon = [[UIImageView alloc] initWithFrame:CGRectMake(14, 0, 14, 14)];
                //                icon.image = [UIImage imageNamed:@"icon_tianjiarenwu"];
                //                [cell.contentView addSubview:icon];
                
                cell.backgroundColor = [UIColor backgroundColor];
                
                return cell;
            }
            else
            {
                static NSString *cellId = @"Cell";
                UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
                if (cell == nil){
                    cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
                    cell.frame = CGRectMake(0, 0, SCREENWIDTH, 84);
                }
                
                for(UIView *view in cell.contentView.subviews) {
                    [view removeFromSuperview];
                }
                
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                
                UILabel * titleLbl = [[UILabel alloc] initWithFrame:CGRectMake(14, -2, 200, 16)];
                titleLbl.textColor = [UIColor whiteColor];
                titleLbl.font = Font(15);
                titleLbl.backgroundColor = [UIColor clearColor];
                titleLbl.text = @"无";
                [cell.contentView addSubview:titleLbl];
                
//                UIImageView * icon = [[UIImageView alloc] initWithFrame:CGRectMake(14, 0, 14, 14)];
//                icon.image = [UIImage imageNamed:@"icon_tianjiarenwu"];
//                [cell.contentView addSubview:icon];
                
                cell.backgroundColor = [UIColor backgroundColor];
                
                CGRect rect = cell.frame;
                rect.size.height = 34;
                cell.frame = rect;
                
                return cell;
            }
        }
    }
    
    return nil;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    Mark * ma = _tags[indexPath.section];
    
    NSInteger count = [[_rows[indexPath.section] objectForKey:ma.labelId] count];

    if((count == indexPath.row && count > 0) || (indexPath.row == 1 && indexPath.section == _tags.count - 1))
    {
        UIStoryboard* mainStory = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        
        UIViewController* vc = [mainStory instantiateViewControllerWithIdentifier:@"WorkPlanAddMissionController"];
        ((WorkPlanAddMissionController*)vc).workGroupId = _workGroupId;
        ((WorkPlanAddMissionController*)vc).workGroupName = _workGroupName;
        
//        Mark * ma = _tags[indexPath.section];
        NSString * labelIdStr = @"";
        for(int i = 0; i < _tags.count; i ++)
        {
            Mark * ma = _tags[i];
            labelIdStr = [labelIdStr stringByAppendingString:[NSString stringWithFormat:@"%@,",ma.labelId]];
        }
        
        if(labelIdStr.length > 1)
        {
            labelIdStr = [labelIdStr substringToIndex:labelIdStr.length - 1];
        }
        
        ((WorkPlanAddMissionController*)vc).labelIdStr = labelIdStr;
        
        NSMutableArray * selectArr = [NSMutableArray array];
        for(NSDictionary * dic in _rows)
        {
            NSNumber *num = [NSNumber numberWithInteger:[[dic allKeys][0] integerValue]];
            NSArray * nArr = [dic objectForKey:num];
            
            [selectArr addObjectsFromArray:nArr];
        }
        ((WorkPlanAddMissionController*)vc).selectedIndexList = selectArr;
        ((WorkPlanAddMissionController*)vc).selectedRows = _rows;
        
        ((WorkPlanAddMissionController*)vc).MQPlanEditVC = self;
//        ((WorkPlanAddMissionController*)vc).selectedIndexList = _rows[indexPath.section];

        [self.navigationController pushViewController:vc animated:YES];
    }
}

- (void)didSelectGroup:(Group*)group
{
    _workGroupNameLbl.text = group.workGroupName;
}

- (void)didSelectTime:(WorkPlanTime *)time
{
    NSString * timeStr = @"";
    
    if(time.week == 0)
    {
        timeStr = [NSString stringWithFormat:@"无  %ld月  %ld年", time.month, time.year];
    }
    else
    {
        timeStr = [NSString stringWithFormat:@"第%ld周  %ld月  %ld年", time.week, time.month, time.year];
    }
    
    _timeLbl.text = timeStr;

}

@end
