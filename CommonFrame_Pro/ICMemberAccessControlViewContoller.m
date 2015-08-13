//
//  ICMemberAccessControlViewContoller.m
//  CommonFrame_Pro
//
//  Created by ionitech on 15/6/29.
//  Copyright (c) 2015年 ionitech. All rights reserved.
//

#import "ICMemberAccessControlViewContoller.h"
#import "Authority.h"
#import "UIColor+HexString.h"

@interface ICMemberAccessControlViewContoller() <UITableViewDataSource,UITableViewDelegate>
{
    __weak IBOutlet UITableView*    _tableView;
    NSArray*                        _dataArray;
    NSMutableArray*                 _changedAuthorityArray;
}

@end

@implementation ICMemberAccessControlViewContoller

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
    
    UIBarButtonItem* rightBarButton = [[UIBarButtonItem alloc] initWithTitle:@"完成" style:UIBarButtonItemStyleDone target:self action:@selector(btnFinishedClicked:)];
    [rightBarButton setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor whiteColor],NSFontAttributeName:[UIFont systemFontOfSize:17]} forState:UIControlStateNormal];
    self.navigationItem.rightBarButtonItem = rightBarButton;
    
    _dataArray = [NSArray array];
    if (_changedAuthorityArray == nil) {
        _changedAuthorityArray = [NSMutableArray array];
    }
    
    if (_workContractID != nil && _workGroupID != nil) {
        NSArray* tmArr = [Authority getMemberRoleArrayByWorkGroupIDAndWorkContractID:_workGroupID WorkContractID:_workContractID];
        if (tmArr.count > 0) {
            _dataArray = [NSArray arrayWithArray:tmArr];
        }
    }
    
    _tableView.dataSource = self;
    _tableView.delegate = self;
    [_tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    [_tableView setFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height)];
    [self setExtraCellLineHidden:_tableView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)backButtonClicked:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)btnFinishedClicked:(id)sender
{
    if (_changedAuthorityArray.count > 0) {
        BOOL isOk = [Authority changeMemberAuthority:_changedAuthorityArray workContractID:_workContractID];
        if(isOk)
            [self.navigationController popViewControllerAnimated:YES];
    }
}

#pragma mark -
#pragma mark Table View Action

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _dataArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 40;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger index = indexPath.row;
    
    NSString *cellId = @"MemberAccessControlTableViewCellId";
    UITableViewCell *cell;
    
    if (index == 0) {
        cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    }
    else if (index == 1) {
        cellId = @"MemberAccessControlTableViewCellId1";
        cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    }
    
    if (cell == nil){
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
    }
    
    for(UIView *view in cell.contentView.subviews) {
        [view removeFromSuperview];
    }
    
    CGFloat width = [UIScreen mainScreen].bounds.size.width;
    
    Authority* au = [_dataArray objectAtIndex:index];
    
    UILabel* lbl = [[UILabel alloc] initWithFrame:CGRectMake(12, 13, 120, 13)];
    lbl.text = au.wgRoleName;
    lbl.textColor = [UIColor whiteColor];
    lbl.font = [UIFont systemFontOfSize:15];
    lbl.backgroundColor = [UIColor clearColor];
    
    [cell.contentView addSubview:lbl];
    
    UILabel* lbl1 = [[UILabel alloc] initWithFrame:CGRectMake(12, 35, 150, 13)];
    lbl1.text = au.remark;
    lbl1.textColor = [UIColor grayColor];
    lbl1.font = [UIFont systemFontOfSize:10];
    lbl1.backgroundColor = [UIColor clearColor];
    
    [cell.contentView addSubview:lbl1];
    
    UISwitch* swi = [[UISwitch alloc] initWithFrame:CGRectMake(width - 65, 15, 60, 40)];
    if(au.isHave)
    {
        swi.on = YES;
        [_changedAuthorityArray addObject:[NSString stringWithFormat:@"%ld",au.wgRoleId]];
    }
    else
        swi.on = NO;
    swi.tag = au.wgRoleId;
    [swi addTarget:self action:@selector(switchChanged:) forControlEvents:UIControlEventValueChanged];
    
    [cell.contentView addSubview:swi];
    
    UILabel* bottomLine = [[UILabel alloc] initWithFrame:CGRectMake(0, 59, [UIScreen mainScreen].bounds.size.width, 0.5)];
    [bottomLine setBackgroundColor:[UIColor grayColor]];
    
    [cell.contentView addSubview:bottomLine];
    
    [cell setBackgroundColor:[UIColor colorWithHexString:@"#262630"]];
    
    return cell;
}

-(void)switchChanged:(id)sender
{
    UISwitch* swi = (UISwitch*)sender;
    NSInteger tag = swi.tag;
    
    if (swi.on == YES) {
        [_changedAuthorityArray addObject:[NSString stringWithFormat:@"%ld",tag]];
    }
    else{
        for (NSString* val in _changedAuthorityArray) {
            if ([val integerValue] == tag) {
                [_changedAuthorityArray removeObject:val];
                break;
            }
        }
    }
    
    NSLog(@"%ld",tag);
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView* myView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 40)];
    
    myView.backgroundColor = tableView.backgroundColor;
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 20, 120, 9)];
    titleLabel.textColor=[UIColor whiteColor];
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.text=@"可分配下列权限";
    [titleLabel setFont:[UIFont systemFontOfSize:10]];
    
    [myView addSubview:titleLabel];
    
    UILabel* bottomLine = [[UILabel alloc] initWithFrame:CGRectMake(0, 39, [UIScreen mainScreen].bounds.size.width, 0.5)];
    [bottomLine setBackgroundColor:[UIColor grayColor]];
    
    [myView addSubview:bottomLine];
    
    return myView;
}

-(void)setExtraCellLineHidden: (UITableView *)tableView
{
    UIView *view = [UIView new];
    view.backgroundColor = [UIColor clearColor];
    [tableView setTableFooterView:view];
    tableView.tableHeaderView = ({
        
        UIView* view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 100, 10)];
        [view setBackgroundColor:[UIColor clearColor]];
        view;
    });
    
}

@end
