//
//  WorkPlanMainController.m
//  CommonFrame_Pro
//
//  Created by 倩 莫 on 15/12/29.
//  Copyright © 2015年 ionitech. All rights reserved.
//

#import "WorkPlanMainController.h"
#import "UICommon.h"
#import "WorkPlanMainCell.h"
#import "Group.h"
#import "Mission.h"
#import "ICWorkingDetailViewController.h"
#import "MQPublishMissionMainController.h"
#import "WorkPlanEditController.h"
#import "WorkPlanEditMainController.h"

@interface WorkPlanMainController ()<UITableViewDataSource, UITableViewDelegate>
{
    NSArray* _rows;
    
    BOOL _statusLayoutShow;
}

@property (weak, nonatomic) IBOutlet UIView *jiaView;
@property (weak, nonatomic) IBOutlet UIButton *jiaBtn;
@property (weak, nonatomic) IBOutlet UIButton *layoutBtn;
@property (weak, nonatomic) IBOutlet UITableView *mainTableView;

@end

@implementation WorkPlanMainController

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
    
    _rows = [Group findUserTaskByTime:[LoginUser loginUserID] workGroupId:_workGroupId];
    
    [_jiaView setRoundColorCorner:3.3 withColor:[UIColor grayLineColor]];
}


- (IBAction)btnBackButtonClicked:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)btnDoneButtonClicked:(id)sender
{
    UIStoryboard* mainStory = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    
    UIViewController* vc = [mainStory instantiateViewControllerWithIdentifier:@"WorkPlanEditMainController"];
    ((WorkPlanEditMainController*)vc).workGroupId = _workGroupId;
    ((WorkPlanEditMainController*)vc).workGroupName = _workGroupName;
    
    [self.navigationController pushViewController:vc animated:YES];
}

- (IBAction)btnJiaButtonClicked:(id)sender
{
    UIStoryboard* mainStory = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    
    UIViewController* vc = [mainStory instantiateViewControllerWithIdentifier:@"MQPublishMissionMainController"];
    ((MQPublishMissionMainController*)vc).workGroupId = _workGroupId;
    ((MQPublishMissionMainController*)vc).workGroupName = _workGroupName;
    
    [self.navigationController pushViewController:vc animated:YES];
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

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
    NSInteger count = [_rows[section] count];
    
    if(count == 0)
    {
        count = 1;
    }
    
    return count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 48;
}

- (UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView* myView = [[UIView alloc] init];
    myView.backgroundColor = [UIColor backgroundColor];
    
    UIView * titleView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREENWIDTH, 28)];
    titleView.backgroundColor = [UIColor grayMarkColor];
    [myView addSubview:titleView];
    
    UIView * line = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREENWIDTH, 0.5)];
    line.backgroundColor = [UIColor grayLineColor];
    [titleView addSubview:line];
    
    line = [[UIView alloc] initWithFrame:CGRectMake(0, H(titleView) - 0.5, SCREENWIDTH, 0.5)];
    line.backgroundColor = [UIColor grayLineColor];
    [titleView addSubview:line];
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(14, 0, 200, 28)];
    titleLabel.textColor=[UIColor whiteColor];
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.font = Font(14);
    
    NSString * title = @"今天";
    if(section == 1)
    {
        title = @"未来7天";
    }
    else if (section == 2)
    {
        title = @"7天以后";
    }
    else if (section == 3)
    {
        title = @"未分配";
    }
    
    titleLabel.text= title;
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
        static NSString *cellId = @"WorkPlanMainCell";
        WorkPlanMainCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
        if (cell == nil){
            cell = [[WorkPlanMainCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
        }
        
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        NSArray * mArr = _rows[indexPath.section];
        
        if(mArr.count)
        {
            Mission * mis = _rows[indexPath.section][indexPath.row];
            
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
        }
        else
        {
            cell.titleLbl.text = @"暂无任务";
            
            cell.statusLbl.hidden = YES;
            cell.icon.hidden = YES;
            
        }
        
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
        
        NSArray * mArr = _rows[indexPath.section];
        
        if(mArr.count)
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
            
        }
        else
        {
            UILabel * titleLbl = [[UILabel alloc] initWithFrame:CGRectMake(14, -2, SCREENWIDTH - 28, 16)];
            titleLbl.textColor = [UIColor whiteColor];
            titleLbl.font = Font(14);
            titleLbl.text = @"暂无任务";

            [cell.contentView addSubview:titleLbl];
            
            CGRect rect = cell.frame;
            rect.size.height = 34;
            cell.frame = rect;
        }
        
        cell.contentView.backgroundColor = [UIColor backgroundColor];
        
        return cell;
    }
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSArray * mArr = _rows[indexPath.section];
    
    if(mArr.count)
    {
        Mission *ms = mArr[indexPath.row];
        
        UIStoryboard* mainStory = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        UIViewController* vc = [mainStory instantiateViewControllerWithIdentifier:@"ICWorkingDetailViewController"];
        ((ICWorkingDetailViewController*)vc).taskId = ms.taskId;
        ((ICWorkingDetailViewController*)vc).workGroupId = _workGroupId;
        
        [self.navigationController pushViewController:vc animated:YES];
        
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
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
