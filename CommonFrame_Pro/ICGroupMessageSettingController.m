//
//  ICGroupMessageSettingController.m
//  CommonFrame_Pro
//
//  Created by 倩 莫 on 15/9/18.
//  Copyright (c) 2015年 ionitech. All rights reserved.
//

#import "ICGroupMessageSettingController.h"
#import "UIColor+HexString.h"
#import "Group.h"
#import "UIImageView+UIActivityIndicatorForSDWebImage.h"
#import "UICommon.h"
#import "SVProgressHUD.h"

@interface ICGroupMessageSettingController ()
{
    __weak IBOutlet UITableView* _tableView;
    NSArray*        _dataArray;
    NSMutableArray*         _selectedIndexList;
}

@end

@implementation ICGroupMessageSettingController

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
    
    [self.navigationItem setTitle:@"消息设置"];
    
    _tableView.dataSource = self;
    _tableView.delegate = self;
    
    [_tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    [_tableView setBackgroundColor:[UIColor colorWithHexString:@"#2f2e33"]];
    
    NSMutableArray * arr = [NSMutableArray array];
    
    _dataArray = [Group getWorkGroupListByUserID:[LoginUser loginUserID] selectArr:&arr];
    
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
    return 66;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _dataArray.count;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellId = @"GroupMesSettingTableViewCellId";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    if (cell == nil){
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
        
    }
    
    for(UIView *view in cell.contentView.subviews) {
        [view removeFromSuperview];
    }
    
    Group* ms = [_dataArray objectAtIndex:indexPath.row];
    
    UIImageView* imgView = [[UIImageView alloc] initWithFrame:CGRectMake(12, 10, 46, 46)];
    //[imgView setImage:[UIImage imageNamed:@"icon_touxiang"]];
    [imgView setImageWithURL:[NSURL URLWithString:ms.workGroupImg] placeholderImage:[UIImage imageNamed:@"icon_touxiang"] options:SDWebImageDelayPlaceholder usingActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    [cell.contentView addSubview:imgView];
    
    UILabel* lbl = [[UILabel alloc] initWithFrame:CGRectMake(72, 22, 120, 20)];
    lbl.text = ms.workGroupName;
    lbl.textColor = [UIColor whiteColor];
    lbl.font = [UIFont systemFontOfSize:15];
    lbl.backgroundColor = [UIColor clearColor];
    
    [cell.contentView addSubview:lbl];
    
    UISwitch * swiBtn = [[UISwitch alloc] init];
    swiBtn.frame = CGRectMake(SCREENWIDTH - W(swiBtn) - 14, (66 - H(swiBtn)) / 2, 100, 20);
    if(!_selectedIndexList.count)
    {
        swiBtn.on = ms.isReceive;
    }
    else
    {
        swiBtn.on = NO;
    }
    
    [swiBtn addTarget:self action:@selector(switchAction:) forControlEvents:UIControlEventValueChanged];

    [cell.contentView addSubview:swiBtn];
    
    UILabel* bottomLine = [[UILabel alloc] initWithFrame:CGRectMake(0, 65, [UIScreen mainScreen].bounds.size.width, 0.5)];
    [bottomLine setBackgroundColor:[UIColor grayColor]];
    [cell.contentView addSubview:bottomLine];
    
    cell.tag = indexPath.row;
    
    cell.backgroundColor = [UIColor colorWithHexString:@"#2f2e33"];
    [cell.contentView setBackgroundColor:[UIColor clearColor]];
    
    for(Group * me in _selectedIndexList)
    {
        if(ms.workGroupId == me.workGroupId)
        {
            swiBtn.on = YES;
            
            break;
        }
    }
    
    return cell;
}

- (void)addIndexPathToCopyToArray:(NSIndexPath*)indexPath
{
    NSInteger row = indexPath.row;
    
    BOOL isEx = NO;
    
    Group* me = _dataArray[row];
    
    if (_selectedIndexList.count > 0) {
        for (Group* ip in _selectedIndexList) {
            if (ip.workGroupId == me.workGroupId) {
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
    
    Group* me = _dataArray[row];
    
    if (_selectedIndexList.count > 0) {
        for (Group* ip in _selectedIndexList) {
            if (ip.workGroupId == me.workGroupId) {
                [_selectedIndexList removeObject:ip];
                break;
            }
        }
    }
}

- (void) switchAction:(id)sender
{
    UISwitch *swiBtn = (UISwitch *) sender;
    
    UIView *v = [sender superview];//获取父类view（鼠标点击）
    UITableViewCell *cell = (UITableViewCell *)[v superview];//获取cell
    NSIndexPath *indexPath = [_tableView indexPathForCell:cell];//获取cell对应的section
    
    Group* ms = [_dataArray objectAtIndex:indexPath.row];
    
    BOOL switchStatus = swiBtn.on;
    
    if(switchStatus)
    {
        [self addIndexPathToCopyToArray:indexPath];
    }
    else
    {
        [self removeIndexPathFromCopyToArray:indexPath];
    }
    
    BOOL isOk = [Group updateWgSubscribeStatus:ms.workGroupId isReceive:switchStatus];

    if(isOk)
    {
        NSString * str = @"接收该群组消息设置成功";
        
        if(!switchStatus)
        {
            str = @"不接收该群组消息设置成功";
        }
        
        [SVProgressHUD showSuccessWithStatus:str];
    }
    else
    {
        swiBtn.on = switchStatus;
        
        [SVProgressHUD showSuccessWithStatus:@"该群组消息设置失败"];

    }
}

- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = (UITableViewCell *)[tableView cellForRowAtIndexPath:indexPath];
    UIView *selectionColor = [[UIView alloc] init];
    selectionColor.backgroundColor = [UIColor cellHoverBackgroundColor];
    cell.selectedBackgroundView = selectionColor;
    
    UILabel* bottomLine = [[UILabel alloc] initWithFrame:CGRectMake(0, 65, [UIScreen mainScreen].bounds.size.width, 0.5)];
    [bottomLine setBackgroundColor:[UIColor grayColor]];
    [cell.selectedBackgroundView addSubview:bottomLine];
    
    return YES;
}

-(void)setExtraCellLineHidden: (UITableView *)tableView
{
    UIView *view = [UIView new];
    view.backgroundColor = [UIColor clearColor];
    [tableView setTableFooterView:view];
}

@end
