//
//  MQMemberAuthSettingVC.m
//  CommonFrame_Pro
//
//  Created by 倩 莫 on 16/2/1.
//  Copyright © 2016年 ionitech. All rights reserved.
//

#import "MQMemberAuthSettingVC.h"
#import "UICommon.h"
#import "SVProgressHUD.h"
#import "LoginUser.h"
#import "Authority.h"
#import "UIImageView+UIActivityIndicatorForSDWebImage.h"


@interface MQMemberAuthSettingVC ()
{
    __weak IBOutlet UITableView* _tableView;
    NSArray*        _dataArray;
    NSMutableArray*         _selectedIndexList;
    
    NSMutableArray*         _selectedTagList;
    
}

@property (weak, nonatomic) IBOutlet UIImageView *wgImgView;
@property (weak, nonatomic) IBOutlet UIImageView *memberImgView;
@property (weak, nonatomic) IBOutlet UILabel *wgNameLbl;
@property (weak, nonatomic) IBOutlet UILabel *memberNameLbl;

@end

@implementation MQMemberAuthSettingVC

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
    
    self.navigationItem.title = @"权限分配";
    
    _tableView.dataSource = self;
    _tableView.delegate = self;
    
    [_tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    [_tableView setBackgroundColor:[UIColor backgroundColor]];
    
    NSMutableArray * arr = [NSMutableArray array];
    
    _dataArray = [Authority getMemberRoleArrayByWorkGroupIDAndWorkContractID:_workGroupId WorkContractID:_workContactsId];
    
    if(arr.count)
    {
        _selectedIndexList = arr;
    }
    
    _selectedTagList = [[NSMutableArray alloc] init];
    
    [_wgImgView setImageWithURL:[NSURL URLWithString:_workGroup.workGroupImg] placeholderImage:[UIImage imageNamed:@"icon_touxiang"] options:SDWebImageDelayPlaceholder usingActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    [_wgImgView setRoundCorner:3.3];
    _wgNameLbl.text = _workGroup.workGroupName;
    
    [_memberImgView setImageWithURL:[NSURL URLWithString:_member.img] placeholderImage:[UIImage imageNamed:@"icon_chengyuan"] options:SDWebImageDelayPlaceholder usingActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    [_memberImgView setRoundCorner:3.3];
    _memberNameLbl.text = _member.name;
    
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
    
    Authority* au = [_dataArray objectAtIndex:indexPath.row];
    
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
    
    UISwitch * swiBtn = [[UISwitch alloc] init];
    swiBtn.frame = CGRectMake(SCREENWIDTH - W(swiBtn) - 14, (60 - H(swiBtn)) / 2, 100, 20);
    if(!_selectedIndexList.count)
    {
        swiBtn.on = au.isHave;
        
        if(swiBtn.on)
        {
            [_selectedTagList addObject:au];
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
    
    for(Authority * me in _selectedIndexList)
    {
        if(au.wgRoleId == me.wgRoleId)
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
    
    Authority* au = [_dataArray objectAtIndex:indexPath.row];
    
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

    BOOL isOk = [Authority changeMemberAuthority:_selectedTagList workContractID:_workContactsId];
    
    if(isOk)
    {
        NSString * str = @"此权限已开启";
        
        if(!switchStatus)
        {
            str = @"取消成功";
        }
        
        [SVProgressHUD showSuccessWithStatus:str];
    }
    else
    {
        swiBtn.on = switchStatus;
        
        [SVProgressHUD showSuccessWithStatus:@"权限设置失败"];
        
    }
}

- (void)addIndexPathToCopyToArray:(NSIndexPath*)indexPath andArray:(NSMutableArray *)selectedArray
{
    NSInteger row = indexPath.row;
    
    BOOL isEx = NO;
    
    Authority* au = _dataArray[row];
    
    if (selectedArray.count > 0) {
        for (Authority* ip in selectedArray) {
            if (ip.wgRoleId == au.wgRoleId) {
                isEx = YES;
                break;
            }
        }
        if (!isEx) {
            [selectedArray addObject:au];
        }
    }
    else{
        [selectedArray addObject:au];
    }
}

- (void)removeIndexPathFromCopyToArray:(NSIndexPath*)indexPath andArray:(NSMutableArray *)selectedArray
{
    NSInteger row = indexPath.row;
    
    Authority* au = _dataArray[row];
    
    if (selectedArray.count > 0) {
        for (Authority* ip in selectedArray) {
            if (ip.wgRoleId == au.wgRoleId) {
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
    
    titleLabel.text= @"可分配下列权限";
    [titleView addSubview:titleLabel];
    
    return myView;
}

@end
