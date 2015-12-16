//
//  MQOrgSearchController.m
//  CommonFrame_Pro
//
//  Created by 倩 莫 on 15/12/15.
//  Copyright © 2015年 ionitech. All rights reserved.
//

#import "MQOrgSearchController.h"
#import "UICommon.h"
#import "SVProgressHUD.h"
#import "Organization.h"
#import "LoginUser.h"
#import "UIImageView+UIActivityIndicatorForSDWebImage.h"

@interface MQOrgSearchController ()<UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate, UIAlertViewDelegate>
{
    UITableView * _mainTableView;
    NSArray * _orgArr;
    BOOL _isJoinOrg;
}
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;

@end

@implementation MQOrgSearchController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
   
    UIView* tb = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREENWIDTH, 20)];
    [tb setBackgroundColor:[UIColor blackColor]];
    [self.view addSubview:tb];
    
    [_searchBar becomeFirstResponder];
    
    [self initTableView];
    
}

- (void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(buttonIndex == 0)
    {
        [self dismissView];
    }
}

- (void) initTableView
{
    _mainTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 64, SCREENWIDTH , SCREENHEIGHT - 64)];
    _mainTableView.delegate = self;
    _mainTableView.dataSource = self;
    [_mainTableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    [_mainTableView setBackgroundColor:[UIColor backgroundColor]];
    
    [self.view addSubview:_mainTableView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) dismissView
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    [self dismissView];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    if(!searchBar.text.length)
    {
        [SVProgressHUD showErrorWithStatus:@"查找内容不能为空"];

        return;
    }
    else
    {
        [searchBar resignFirstResponder];
        
        NSString * userId = [LoginUser loginUserID];
        
        _orgArr = [Organization findOrgbyStr:userId str:searchBar.text];
        
        [_mainTableView reloadData];
    }
}


#pragma mark -
#pragma mark Table View Action

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 78;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _orgArr.count;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellId = @"MQOrgCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    if (cell == nil){
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
    }
    
    for(UIView *view in cell.contentView.subviews) {
        [view removeFromSuperview];
    }
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    Organization * org = _orgArr[indexPath.row];
    
    UIImageView* imgView = [[UIImageView alloc] initWithFrame:CGRectMake(14, 14, 50, 50)];
    imgView.image = [UIImage imageNamed:@"icon_qiyetu"];
    [imgView setRoundCorner:3.3];
//    [imgView setImageWithURL:[NSURL URLWithString:org.logo] placeholderImage:nil options:SDWebImageDelayPlaceholder usingActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    [cell.contentView addSubview:imgView];
    
    
    UILabel* lbl = [[UILabel alloc] initWithFrame:CGRectMake(XW(imgView) + 14, 18, SCREENWIDTH - XW(imgView) - 14 - 94, 16)];
    lbl.text = org.name;
    lbl.textColor = [UIColor whiteColor];
    lbl.font = Font(15);
    lbl.backgroundColor = [UIColor clearColor];
    [cell.contentView addSubview:lbl];
    
    UILabel* createlbl = [[UILabel alloc] initWithFrame:CGRectMake(XW(imgView) + 14, YH(lbl) + 11, W(lbl), 14)];
    createlbl.text = [NSString stringWithFormat:@"创建人: %@", org.createName];
    createlbl.textColor = [UIColor grayTitleColor];
    createlbl.font = Font(12);
    createlbl.backgroundColor = [UIColor clearColor];
    [cell.contentView addSubview:createlbl];
    
    
    UILabel* statusLbl = [[UILabel alloc] initWithFrame:CGRectMake(SCREENWIDTH - 80 - 14, 30, 80, 16)];
    statusLbl.textAlignment = NSTextAlignmentRight;
    
    NSString * str = @"申请加入";
    UIColor * txtColor = [UIColor blueTextColor];

    if([org.status intValue] == 0)// 状态  -2：审核不过  -1：已忽略(暂无）  0:待审核  1:审核通过
    {
        str = @"等待审核";
        txtColor = [UIColor grayTitleColor];

    }
//    else if ([org.status intValue] == -2)
//    {
//        str = @"审核不通过";
//        txtColor = [UIColor redTextColor];
//    }
    else if ([org.status intValue] == -2 ||
             [org.status intValue] == -1)
    {
        UIButton * addOrgBtn = [[UIButton alloc] initWithFrame:CGRectMake(SCREENWIDTH - 94, 0, 94, 78)];
        addOrgBtn.backgroundColor = [UIColor clearColor];
        [addOrgBtn addTarget:self action:@selector(addOrgClicked:) forControlEvents:UIControlEventTouchUpInside];
        addOrgBtn.tag = indexPath.row;
        [cell.contentView addSubview:addOrgBtn];
    }
    
    statusLbl.text = str;    
    statusLbl.textColor = txtColor;
    statusLbl.font = Font(14);
    statusLbl.backgroundColor = [UIColor clearColor];
    [cell.contentView addSubview:statusLbl];
    
    UILabel* bottomLine = [[UILabel alloc] initWithFrame:CGRectMake(14, 77.5, SCREENWIDTH, 0.5)];
    [bottomLine setBackgroundColor:[UIColor grayLineColor]];
    [cell.contentView addSubview:bottomLine];
    
    if(indexPath.row == _orgArr.count - 1)
    {
        bottomLine.left = 0;
    }

    cell.contentView.backgroundColor = [UIColor grayMarkColor];
    
    return cell;
}

- (void)addOrgClicked:(id)sender
{
    NSString * userId = [LoginUser loginUserID];
    
    UIButton * btn = (UIButton *) sender;
    
    NSInteger index = btn.tag;
    
    Organization * org = _orgArr[index];
    
    BOOL isOk = [Organization addOrgUser:userId orgId:org.orgId];
    
    if(isOk)
    {
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil
                                                        message:@"申请已提交，等待管理员审批。"
                                                       delegate:self
                                              cancelButtonTitle:@"确定"
                                              otherButtonTitles:nil];
        [alert show];

    }
    else
    {
        [SVProgressHUD showErrorWithStatus:@"加入企业失败"];
    }
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
