//
//  WorkPlanAddMissionController.m
//  CommonFrame_Pro
//
//  Created by 倩 莫 on 15/12/29.
//  Copyright © 2015年 ionitech. All rights reserved.
//

#import "WorkPlanAddMissionController.h"
#import "UICommon.h"
#import "WorkPlanMainSelectCell.h"
#import "Group.h"
#import "Mission.h"
#import "ICWorkingDetailViewController.h"
#import "MQPublishMissionController.h"
#import "WorkPlanEditController.h"

@interface WorkPlanAddMissionController ()<UITableViewDataSource, UITableViewDelegate>
{
    NSArray* _rows;
    
    BOOL _statusLayoutShow;
    
}

@property (weak, nonatomic) IBOutlet UIView *jiaView;
@property (weak, nonatomic) IBOutlet UIButton *jiaBtn;
@property (weak, nonatomic) IBOutlet UIButton *layoutBtn;
@property (weak, nonatomic) IBOutlet UITableView *mainTableView;

@end

@implementation WorkPlanAddMissionController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    if(!_selectedIndexList)
    {
        _selectedIndexList = [[NSMutableArray alloc] init];
    }
    
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

    [_jiaView setRoundColorCorner:3.3 withColor:[UIColor grayLineColor]];
}

- (void) viewWillAppear:(BOOL)animated
{
    _rows = [Group findUserMainLabelTask:[LoginUser loginUserID] workGroupId:_workGroupId labelId:_labelIdStr];

    [_mainTableView reloadData];
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
    if([self.MQPlanEditVC respondsToSelector:@selector(setRows:)])
    {
        NSMutableArray * arr = [NSMutableArray array];
        
        [arr addObjectsFromArray:_selectedRows];
        
        for(int i = 0; i < arr.count; i ++)
        {
            NSDictionary * dic = arr[i];
            
            NSMutableArray * keyArr = [NSMutableArray array];
            
            NSNumber * num = 0;
            if(_isEdit)
            {
                num = [NSNumber numberWithInteger:[[dic objectForKey:@"labelId"] integerValue]];
            }
            else
            {
                num = [NSNumber numberWithInteger:[[dic allKeys][0] integerValue]];
            }

            for(Mission * mi in _selectedIndexList)
            {
                if(mi.labelId == num)
                {
                    [keyArr addObject:mi];
                }
            }
            
            NSMutableDictionary * ddic = [NSMutableDictionary dictionary];
            
            if(_isEdit)
            {
                [ddic setObject:keyArr forKey:@"taskList"];
                NSString * labelId =[NSString stringWithFormat:@"%@", [dic objectForKey:@"labelId"]];
                
                [ddic setObject:labelId forKey:@"labelId"];
                [ddic setObject:[dic objectForKey:@"labelName"] forKey:@"labelName"];
                [ddic setObject:[dic objectForKey:@"workGroupId"] forKey:@"workGroupId"];

            }
            else
            {
                [ddic setObject:keyArr forKey:num];

            }
            
            [arr replaceObjectAtIndex:i withObject:ddic];
            
        }
        
        if(arr.count)
        {
            [self.MQPlanEditVC setValue:arr forKey:@"rows"];
        }
        
        [self.navigationController popViewControllerAnimated:YES];
    }

}

- (IBAction)btnJiaButtonClicked:(id)sender
{
    UIStoryboard* mainStory = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    
    UIViewController* vc = [mainStory instantiateViewControllerWithIdentifier:@"MQPublishMissionController"];
    ((MQPublishMissionController*)vc).workGroupId = _workGroupId;
    ((MQPublishMissionController*)vc).workGroupName = _workGroupName;
    
    ((MQPublishMissionController*)vc).userId = [LoginUser loginUserID];
    ((MQPublishMissionController*)vc).isMainMission = NO;
    
    ((MQPublishMissionController*)vc).isEditMission = NO;//新增主任务
    ((MQPublishMissionController*)vc).isFromWorkPlanToCreateMission = YES;

    [self.navigationController pushViewController:vc animated:YES];

}

- (void)selectBtnClick:(id)sender
{
    UIButton * btn = (UIButton *)sender;
    
    UITableView *  mTableView = (UITableView *)[[[[btn superview] superview] superview] superview];
    UITableViewCell *  cell = (UITableViewCell *)[[btn superview] superview];
    NSIndexPath * indexPath = [mTableView indexPathForCell:cell];
    
    for (UIControl* control in cell.contentView.subviews) {
        if (control.tag == 1010) {
            UIImageView* img = (UIImageView*)control;
            img.tag = 1011;
            img.image = [UIImage imageNamed:@"btn_gou"];
            [self addIndexPathToSelectArray:indexPath];
            break;
        }
        else if (control.tag == 1011)
        {
            UIImageView* img = (UIImageView*)control;
            img.tag = 1010;
            img.image = [UIImage imageNamed:@"btn_kuang"];
            [self removeIndexPathFromSelectArray:indexPath];
            break;
        }
    }
}

- (void)jumpBtnClick:(id)sender
{
    UIButton * btn = (UIButton *)sender;
    
    UITableView *  mTableView = (UITableView *)[[[[btn superview] superview] superview] superview];
    UITableViewCell *  cell = (UITableViewCell *)[[btn superview] superview];
    NSIndexPath * indexPath = [mTableView indexPathForCell:cell];
    
    NSNumber * numKey = [NSNumber numberWithInteger:[[[_rows[indexPath.section] valueForKey:@"label"] valueForKey:@"labelId"] integerValue]];
    
    NSArray * arr = [_rows[indexPath.section] objectForKey:numKey];
    
    if(arr.count)
    {
        Mission * ms = arr[indexPath.row];
        
        UIStoryboard* mainStory = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        UIViewController* vc = [mainStory instantiateViewControllerWithIdentifier:@"ICWorkingDetailViewController"];
        ((ICWorkingDetailViewController*)vc).taskId = ms.taskId;
        ((ICWorkingDetailViewController*)vc).workGroupId = _workGroupId;
        
        [self.navigationController pushViewController:vc animated:YES];
    }
    
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
        return 34;
    }
    else
    {
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
    return _rows.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSNumber * numKey = [NSNumber numberWithInteger:[[[_rows[section] valueForKey:@"label"] valueForKey:@"labelId"] integerValue]];

    NSArray * arr = [_rows[section] objectForKey:numKey];
    
    NSInteger count = [arr count];
    
    if(count == 0)
    {
        count = 1;
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
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(27, -4, 200, 18)];
    titleLabel.textColor=[UIColor whiteColor];
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.font = Font(15);
    
    NSDictionary * titleDic = [_rows[section] objectForKey:@"label"];

    titleLabel.text = [titleDic valueForKey:@"labelName"];
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
        static NSString *cellId = @"WorkPlanMainSelectCell";
        WorkPlanMainSelectCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
        if (cell == nil){
            cell = [[WorkPlanMainSelectCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
        }
        
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        NSNumber * numKey = [NSNumber numberWithInteger:[[[_rows[indexPath.section] valueForKey:@"label"] valueForKey:@"labelId"] integerValue]];
        
        NSArray * arr = [_rows[indexPath.section] objectForKey:numKey];
        
        if(arr.count)
        {
            Mission * mis = arr[indexPath.row];
            
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
            
            if ([self hasExitsInSelectArray:indexPath])
            {
                cell.selectIcon.tag = 1011;
                cell.selectIcon.image = [UIImage imageNamed:@"btn_gou"];
            }
            else
            {
                cell.selectIcon.tag = 1010;
                cell.selectIcon.image = [UIImage imageNamed:@"btn_kuang"];
            }
            
            cell.selectIcon.hidden = NO;
        }
        else
        {
            cell.selectIcon.tag = 1012;
            cell.selectIcon.hidden = YES;
            cell.icon.hidden = YES;
            cell.titleLbl.text = @"无";
        }
        
        [cell.selectBtn addTarget:self action:@selector(selectBtnClick:) forControlEvents:UIControlEventTouchUpInside];
        [cell.jumpBtn addTarget:self action:@selector(jumpBtnClick:) forControlEvents:UIControlEventTouchUpInside];
        
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
        
        NSNumber * numKey = [NSNumber numberWithInteger:[[[_rows[indexPath.section] valueForKey:@"label"] valueForKey:@"labelId"] integerValue]];
        
        NSArray * misArr = [_rows[indexPath.section] objectForKey:numKey];
        
        if(misArr.count)
        {
            Mission * mis = misArr[indexPath.row];
            
            UILabel * titleLbl = [[UILabel alloc] initWithFrame:CGRectMake(40, 0, SCREENWIDTH - 40 - 38, 16)];
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
            
            UIImageView * choseImg = [[UIImageView alloc] initWithFrame:CGRectMake(14, 2, 16, 14)];
            choseImg.image = [UIImage imageNamed:@"btn_kuang"];
            
            if ([self hasExitsInSelectArray:indexPath])
            {
                choseImg.image = [UIImage imageNamed:@"btn_gou"];
                choseImg.tag = 1011;
            }
            else
            {
                choseImg.image = [UIImage imageNamed:@"btn_kuang"];
                choseImg.tag = 1010;
            }
            
            [cell.contentView addSubview:choseImg];
            
            
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
            
            UILabel * statusLbl = [[UILabel alloc] initWithFrame:CGRectMake(30 + 10, titleLbl.bottom + 7, 54, 24)];
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
            dateLbl.text = [NSString stringWithFormat:@"%@      %@", mis.lableUserName, mis.finishTime];
            
            [cell.contentView addSubview:dateLbl];
            
            if(mis.status != -3)
            {
                [cell.contentView addSubview:statusLbl];
            }
            else
            {
                UIView * statusView = [[UIView alloc] initWithFrame:CGRectMake(30 + 10, titleLbl.bottom + 7, 54, 24)];
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
            
            UIButton * selectBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 50, he)];
            selectBtn.backgroundColor = [UIColor clearColor];
            UIButton * jumpBtn = [[UIButton alloc] initWithFrame:CGRectMake(50, 0, SCREENWIDTH, he)];
            jumpBtn.backgroundColor = [UIColor clearColor];
            
            [selectBtn addTarget:self action:@selector(selectBtnClick:) forControlEvents:UIControlEventTouchUpInside];
            [jumpBtn addTarget:self action:@selector(jumpBtnClick:) forControlEvents:UIControlEventTouchUpInside];
            
            [cell.contentView addSubview:selectBtn];
            [cell.contentView addSubview:jumpBtn];
            
            cell.contentView.backgroundColor = [UIColor backgroundColor];
            
            return cell;
        }
        else
        {
            UILabel * titleLbl = [[UILabel alloc] initWithFrame:CGRectMake(14, 0, 100, 16)];
            titleLbl.text = @"无";
            titleLbl.backgroundColor = [UIColor clearColor];
            titleLbl.textColor = [UIColor whiteColor];
            titleLbl.font = Font(14);
            [cell.contentView addSubview:titleLbl];
            
            CGRect rect = cell.frame;
            rect.size.height = 34;
            cell.frame = rect;
            
            cell.contentView.backgroundColor = [UIColor backgroundColor];
            
            return cell;
        }
        
    }
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
//    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)addIndexPathToSelectArray:(NSIndexPath*)indexPath
{
    NSInteger row = indexPath.row;
    
    BOOL isEx = NO;
    
    NSString * labId = [[_rows[indexPath.section] valueForKey:@"label"] valueForKey:@"labelId"];
    
    NSNumber * numKey = [NSNumber numberWithInteger:[labId integerValue]];
    
    Mission* mi = [_rows[indexPath.section] objectForKey:numKey][row];
    
    mi.labelId = numKey;
    
    if (_selectedIndexList.count > 0) {
        for (Mission* ip in _selectedIndexList) {
            if (ip.taskId == mi.taskId) {
                isEx = YES;
                break;
            }
        }
        if (!isEx) {
            [_selectedIndexList addObject:mi];
        }
    }
    else{
        [_selectedIndexList addObject:mi];
    }
}

- (void)removeIndexPathFromSelectArray:(NSIndexPath*)indexPath
{
    NSInteger row = indexPath.row;
    
    NSNumber * numKey = [NSNumber numberWithInteger:[[[_rows[indexPath.section] valueForKey:@"label"] valueForKey:@"labelId"] integerValue]];
    
    Mission* mi = [_rows[indexPath.section] objectForKey:numKey][row];
    
    if (_selectedIndexList.count > 0) {
        
        NSMutableArray * selArr = [[NSMutableArray alloc]initWithArray:_selectedIndexList];
        
        for (Mission* ip in selArr) {
            if (ip.taskId == mi.taskId) {
                [_selectedIndexList removeObject:ip];
            }
        }
    }
}

- (BOOL)hasExitsInSelectArray:(NSIndexPath*)indexPath
{
    NSInteger row = indexPath.row;
    NSNumber * numKey = [NSNumber numberWithInteger:[[[_rows[indexPath.section] valueForKey:@"label"] valueForKey:@"labelId"] integerValue]];
    
    Mission* mi = [_rows[indexPath.section] objectForKey:numKey][row];
    BOOL isEx = NO;
    if (_selectedIndexList.count > 0) {
        for (Mission* ip in _selectedIndexList) {
            if (ip.taskId == mi.taskId) {
                isEx = YES;
                break;
            }
            
        }
    }
    
    return isEx;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
