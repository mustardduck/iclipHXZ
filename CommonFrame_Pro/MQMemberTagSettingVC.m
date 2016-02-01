//
//  MQMemberTagSettingVC.m
//  CommonFrame_Pro
//
//  Created by 倩 莫 on 16/2/1.
//  Copyright © 2016年 ionitech. All rights reserved.
//

#import "MQMemberTagSettingVC.h"
#import "UICommon.h"
#import "SVProgressHUD.h"
#import "Mark.h"
#import "LoginUser.h"

@interface MQMemberTagSettingVC ()
{
    __weak IBOutlet UITableView* _tableView;
    NSArray*        _dataArray;
    NSMutableArray*         _selectedIndexList;
    
    NSMutableArray*         _selectedTagList;

}

@end

@implementation MQMemberTagSettingVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    UIButton *leftButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 70, 20)];
    [leftButton addTarget:self action:@selector(backButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
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
    
    self.navigationItem.title = @"标签分配";
    
    _tableView.dataSource = self;
    _tableView.delegate = self;
    
    [_tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    [_tableView setBackgroundColor:[UIColor backgroundColor]];
    
    NSMutableArray * arr = [NSMutableArray array];
    
    _dataArray = [Mark findWgLabelForUpdate:_workGroupId workContactsId:_workContactsId];

    if(arr.count)
    {
        _selectedIndexList = arr;
    }
    
    _selectedTagList = [[NSMutableArray alloc] init];
    
    [_tableView reloadData];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)backButtonClicked:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}


#pragma mark -
#pragma mark Table View Action
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _dataArray.count;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellId = @"GroupMainLabelSettingCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    if (cell == nil){
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
        
    }
    
    for(UIView *view in cell.contentView.subviews) {
        [view removeFromSuperview];
    }
    
    Mark* ms = [_dataArray objectAtIndex:indexPath.row];
    
    UILabel* lbl = [[UILabel alloc] initWithFrame:CGRectMake(14, 12, SCREENWIDTH - 28 - 100, 18)];
    lbl.text = ms.labelName;
    lbl.textColor = [UIColor whiteColor];
    lbl.font = Font(15);
    lbl.backgroundColor = [UIColor clearColor];
    [cell.contentView addSubview:lbl];
    
    UILabel* usedCountLbl = [[UILabel alloc] initWithFrame:CGRectMake(14, lbl.bottom + 2, SCREENWIDTH - 28 - 100, 18)];
    usedCountLbl.text = [NSString stringWithFormat:@"被使用 %@      %@ 创建", ms.labelNum, ms.createName];
    usedCountLbl.textColor = [UIColor grayTitleColor];
    usedCountLbl.font = Font(12);
    usedCountLbl.backgroundColor = [UIColor clearColor];
    [cell.contentView addSubview:usedCountLbl];
    
    UISwitch * swiBtn = [[UISwitch alloc] init];
    swiBtn.frame = CGRectMake(SCREENWIDTH - W(swiBtn) - 14, (60 - H(swiBtn)) / 2, 100, 20);
    if(!_selectedIndexList.count)
    {
        swiBtn.on = ms.isHave;
        
        if(swiBtn.on)
        {
            [_selectedTagList addObject:ms];
        }
    }
    else
    {
        swiBtn.on = NO;
    }
    
    [swiBtn addTarget:self action:@selector(switchAction:) forControlEvents:UIControlEventValueChanged];
    
    [cell.contentView addSubview:swiBtn];
    
    UILabel* bottomLine = [[UILabel alloc] initWithFrame:CGRectMake(0, 60 - 0.5, [UIScreen mainScreen].bounds.size.width, 0.5)];
    [bottomLine setBackgroundColor:[UIColor grayColor]];
    [cell.contentView addSubview:bottomLine];
    
    cell.tag = indexPath.row;
    
    cell.backgroundColor = [UIColor grayMarkColor];
    [cell.contentView setBackgroundColor:[UIColor clearColor]];
    
    for(Mark * me in _selectedIndexList)
    {
        if(ms.labelId == me.labelId)
        {
            swiBtn.on = YES;
            
            break;
        }
    }
    
    return cell;
}

- (void) switchAction:(id)sender
{
    UISwitch *swiBtn = (UISwitch *) sender;
    
    UIView *v = [sender superview];//获取父类view（鼠标点击）
    UITableViewCell *cell = (UITableViewCell *)[v superview];//获取cell
    NSIndexPath *indexPath = [_tableView indexPathForCell:cell];//获取cell对应的section
    
    Mark* ms = [_dataArray objectAtIndex:indexPath.row];
    
    BOOL switchStatus = swiBtn.on;
    
    if(switchStatus)
    {
        [self addIndexPathToCopyToArray:indexPath andArray:_selectedIndexList];
        
        [self addIndexPathToCopyToArray:indexPath andArray:_selectedTagList];

    }
    else
    {
        [self removeIndexPathFromCopyToArray:indexPath andArray:_selectedIndexList];
        
        [self removeIndexPathFromCopyToArray:indexPath andArray:_selectedTagList];
    }
    
    NSString * tagStr = @"";
    
    int i = 0;
    for(Mark * mark in _selectedTagList)
    {
        i ++;
        tagStr = [tagStr stringByAppendingString:[NSString stringWithFormat:@"%@", mark.labelId]];
        
        if(i < _selectedTagList.count)
        {
            tagStr = [tagStr stringByAppendingString:@","];
        }
    }
    
    BOOL isOk = [Mark updateWgPeopleLabelNew:tagStr workContactsId:_workContactsId];
    
    if(isOk)
    {
        NSString * str = @"设置为可见标签成功";
        
        if(!switchStatus)
        {
            str = @"取消成功";
        }
        
        [SVProgressHUD showSuccessWithStatus:str];
    }
    else
    {
        swiBtn.on = switchStatus;
        
        [SVProgressHUD showSuccessWithStatus:@"可见标签设置失败"];
        
    }
}

- (void)addIndexPathToCopyToArray:(NSIndexPath*)indexPath andArray:(NSMutableArray *)selectedArray
{
    NSInteger row = indexPath.row;
    
    BOOL isEx = NO;
    
    Mark* me = _dataArray[row];
    
    if (selectedArray.count > 0) {
        for (Mark* ip in selectedArray) {
            if (ip.labelId == me.labelId) {
                isEx = YES;
                break;
            }
        }
        if (!isEx) {
            [selectedArray addObject:me];
        }
    }
    else{
        [selectedArray addObject:me];
    }
}

- (void)removeIndexPathFromCopyToArray:(NSIndexPath*)indexPath andArray:(NSMutableArray *)selectedArray
{
    NSInteger row = indexPath.row;
    
    Mark* me = _dataArray[row];
    
    if (selectedArray.count > 0) {
        for (Mark* ip in selectedArray) {
            if (ip.labelId == me.labelId) {
                [selectedArray removeObject:ip];
                break;
            }
        }
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 30;
}

- (UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView* myView = [[UIView alloc] init];
    myView.backgroundColor = [UIColor backgroundColor];
    
    UIView * titleView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREENWIDTH, 30)];
    titleView.backgroundColor = [UIColor clearColor];//
    [myView addSubview:titleView];
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(14, 0, 200, 30)];
    titleLabel.textColor=[UIColor whiteColor];
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.font = Font(15);
    
    titleLabel.text= @"所有标签";
    [titleView addSubview:titleLabel];
    
    return myView;
}

@end
