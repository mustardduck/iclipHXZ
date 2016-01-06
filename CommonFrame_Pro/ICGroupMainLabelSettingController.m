//
//  ICGroupMainLabelSettingController.m
//  CommonFrame_Pro
//
//  Created by 倩 莫 on 16/1/5.
//  Copyright © 2016年 ionitech. All rights reserved.
//

#import "ICGroupMainLabelSettingController.h"
#import "UICommon.h"
#import "SVProgressHUD.h"
#import "Mark.h"
#import "LoginUser.h"

@interface ICGroupMainLabelSettingController ()
{
    __weak IBOutlet UITableView* _tableView;
    NSArray*        _dataArray;
    NSMutableArray*         _selectedIndexList;
}

@end

@implementation ICGroupMainLabelSettingController

- (void)viewDidLoad {
    [super viewDidLoad];
    
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
    
    self.navigationItem.title = @"标签列表";
    
    _tableView.dataSource = self;
    _tableView.delegate = self;
    
    [_tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    [_tableView setBackgroundColor:[UIColor backgroundColor]];
    
    NSMutableArray * arr = [NSMutableArray array];

    _dataArray = [Mark getMarkListByWorkGroupID:_workGroupId loginUserID:[LoginUser loginUserID] andUrl:CURL selectArr:&arr];
    if(arr.count)
    {
        _selectedIndexList = arr;
    }
    
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
    return 54;
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
    
    UILabel* lbl = [[UILabel alloc] initWithFrame:CGRectMake(14, 0, SCREENWIDTH - 28 - 100, 54)];
    lbl.text = ms.labelName;
    lbl.textColor = [UIColor whiteColor];
    lbl.font = Font(15);
    lbl.backgroundColor = [UIColor clearColor];
    
    [cell.contentView addSubview:lbl];
    
    UISwitch * swiBtn = [[UISwitch alloc] init];
    swiBtn.frame = CGRectMake(SCREENWIDTH - W(swiBtn) - 14, (54 - H(swiBtn)) / 2, 100, 20);
    if(!_selectedIndexList.count)
    {
        swiBtn.on = ms.mainLabel;
    }
    else
    {
        swiBtn.on = NO;
    }
    
    [swiBtn addTarget:self action:@selector(switchAction:) forControlEvents:UIControlEventValueChanged];
    
    [cell.contentView addSubview:swiBtn];
    
    UILabel* bottomLine = [[UILabel alloc] initWithFrame:CGRectMake(0, 54 - 0.5, [UIScreen mainScreen].bounds.size.width, 0.5)];
    [bottomLine setBackgroundColor:[UIColor grayColor]];
    [cell.contentView addSubview:bottomLine];
    
    cell.tag = indexPath.row;
    
    cell.backgroundColor = RGBCOLOR(57, 59, 74);
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
        [self addIndexPathToCopyToArray:indexPath];
    }
    else
    {
        [self removeIndexPathFromCopyToArray:indexPath];
    }
    
    BOOL isOk = [Mark updateLabelMainWork:ms.labelId isMainLabel:switchStatus];
    
    if(isOk)
    {
        NSString * str = @"设置为主要工作成功";
        
        if(!switchStatus)
        {
            str = @"取消成功";
        }
        
        [SVProgressHUD showSuccessWithStatus:str];
    }
    else
    {
        swiBtn.on = switchStatus;
        
        [SVProgressHUD showSuccessWithStatus:@"主要工作设置失败"];
        
    }
}

- (void)addIndexPathToCopyToArray:(NSIndexPath*)indexPath
{
    NSInteger row = indexPath.row;
    
    BOOL isEx = NO;
    
    Mark* me = _dataArray[row];
    
    if (_selectedIndexList.count > 0) {
        for (Mark* ip in _selectedIndexList) {
            if (ip.labelId == me.labelId) {
                isEx = YES;
                break;
            }
        }
        if (!isEx) {
            [_selectedIndexList addObject:me];
        }
    }
    else{
        [_selectedIndexList addObject:me];
    }
}

- (void)removeIndexPathFromCopyToArray:(NSIndexPath*)indexPath
{
    NSInteger row = indexPath.row;
    
    Mark* me = _dataArray[row];
    
    if (_selectedIndexList.count > 0) {
        for (Mark* ip in _selectedIndexList) {
            if (ip.labelId == me.labelId) {
                [_selectedIndexList removeObject:ip];
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
    titleView.backgroundColor = [UIColor tagBlueBackColor];
    [myView addSubview:titleView];
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(14, 0, 200, 30)];
    titleLabel.textColor=[UIColor whiteColor];
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.font = Font(15);
    
    titleLabel.text= @"设置主要标签";
    [titleView addSubview:titleLabel];
    
    return myView;
}

@end
