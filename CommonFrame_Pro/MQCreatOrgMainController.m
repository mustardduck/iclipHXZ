//
//  MQCreatOrgMainController.m
//  CommonFrame_Pro
//
//  Created by 倩 莫 on 15/12/15.
//  Copyright © 2015年 ionitech. All rights reserved.
//

#import "MQCreatOrgMainController.h"
#import "UICommon.h"
#import "Organization.h"
#import "MQOrgSearchController.h"
#import "MQCreateOrgController.h"
#import "LoginUser.h"
#import "APService.h"

@interface MQCreatOrgMainController ()<UITableViewDataSource, UITableViewDelegate>
{
    UITableView * _mainTableView;
    
    NSArray * _orgArr;
}
@property (weak, nonatomic) IBOutlet UINavigationBar *navBar;

@end

@implementation MQCreatOrgMainController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    UIView* tb = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREENWIDTH, 20)];
    [tb setBackgroundColor:[UIColor blackColor]];
    [self.view addSubview:tb];
    
    if(_isFromRegister || _isFromLogin)
    {
        UIButton *leftButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 70, 20)];
        [leftButton addTarget:self action:@selector(btnBackButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
//        UIImageView* imgview = [[UIImageView alloc] initWithFrame:CGRectMake(0, 1, 10, 18)];
//        [imgview setImage:[UIImage imageNamed:@"btn_fanhui"]];
//        [leftButton addSubview:imgview];
        UILabel* ti = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 80, 20)];
        [ti setBackgroundColor:[UIColor clearColor]];
        [ti setTextColor:[UIColor whiteColor]];
        [ti setText:@"返回登录"];
        [ti setFont:[UIFont systemFontOfSize:17]];
        [leftButton addSubview:ti];
        
        UIBarButtonItem *leftBarButton = [[UIBarButtonItem alloc]initWithCustomView:leftButton];
        UINavigationItem *item = [[UINavigationItem alloc] initWithTitle:@"创建/加入企业"];
        [item setLeftBarButtonItem:leftBarButton];
        [_navBar pushNavigationItem:item animated:YES];
    }
    
    [self initTableView];
}

- (void)btnBackButtonClicked:(id)sender
{
    if(_isFromRegister)
    {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
    else
    {
        BOOL isQuit = [LoginUser quit];
        if (isQuit) {
            
            __autoreleasing NSMutableSet *tags = [NSMutableSet set];
            [APService setTags:tags
                         alias:@""
              callbackSelector:@selector(tagsAliasCallback:tags:alias:)
                        target:self];
            
            UIStoryboard* mainStory = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
            UIViewController* controller  = [mainStory instantiateViewControllerWithIdentifier:@"ViewController"];
            [self presentViewController:controller animated:YES completion:nil];
        }
    }
}


- (void)tagsAliasCallback:(int)iResCode
                     tags:(NSSet *)tags
                    alias:(NSString *)alias
{
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

- (void) viewWillAppear:(BOOL)animated
{
    [self layoutHeaderView];
}

- (void) layoutHeaderView
{
    NSString * userId = [LoginUser loginUserID];
    
    _orgArr = [Organization fineExamOrg: userId];
    
    BOOL cleanTableHeader = NO;
    
    for (Organization * org in _orgArr)
    {
        if([org.status intValue] == 0)//待审核
        {
            cleanTableHeader = YES;
            
            break;
        }
    }
    
    if(cleanTableHeader)
    {
        _mainTableView.tableHeaderView = nil;
        
    }
    else
    {
        _mainTableView.tableHeaderView = ({
            [self setHeaderView];
        });
    }
    
    [_mainTableView reloadData];

}

- (UIView *) setHeaderView
{
    UIView * topView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREENWIDTH, 128)];
    topView.backgroundColor = [UIColor backgroundColor];
    
    UIView * mainView = [[UIView alloc] initWithFrame:CGRectMake(0, 14, SCREENWIDTH, 100)];
    mainView.backgroundColor = [UIColor grayMarkColor];
    [topView addSubview:mainView];
    
    UIView * line = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREENWIDTH, 0.5)];
    line.backgroundColor = [UIColor grayLineColor];
    [mainView addSubview:line];
    
    line = [[UIView alloc] initWithFrame:CGRectMake(14, 49.5, SCREENWIDTH, 0.5)];
    line.backgroundColor = [UIColor grayLineColor];
    [mainView addSubview:line];
    
    line = [[UIView alloc] initWithFrame:CGRectMake(0, 99.5, SCREENWIDTH, 0.5)];
    line.backgroundColor = [UIColor grayLineColor];
    [mainView addSubview:line];
    
    UIImageView * icon = [[UIImageView alloc] initWithFrame:CGRectMake(13, 18, 14, 14)];
    icon.image = [UIImage imageNamed:@"icon_sousuo"];
    [mainView addSubview:icon];
    
    UIButton * searchBtn = [[UIButton alloc] initWithFrame:CGRectMake(32, 0, SCREENWIDTH - 32 , 50)];
    searchBtn.backgroundColor = [UIColor clearColor];
    [searchBtn setTitle:@"申请加入已经注册的企业" forState:UIControlStateNormal];
    [searchBtn setTitleColor:[UIColor grayLineColor] forState:UIControlStateNormal];
    searchBtn.titleLabel.font = Font(15);
    searchBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    [searchBtn addTarget:self action:@selector(searchBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    [mainView addSubview:searchBtn];
    
    icon = [[UIImageView alloc] initWithFrame:CGRectMake(13, YH(icon) + 38, 14, 14)];
    icon.image = [UIImage imageNamed:@"icon_xinjianqiye"];
    [mainView addSubview:icon];
    
    searchBtn = [[UIButton alloc] initWithFrame:CGRectMake(32, 50, SCREENWIDTH - 32 , 50)];
    searchBtn.backgroundColor = [UIColor clearColor];
    [searchBtn setTitle:@"新建一个企业" forState:UIControlStateNormal];
    [searchBtn setTitleColor:[UIColor grayLineColor] forState:UIControlStateNormal];
    searchBtn.titleLabel.font = Font(15);
    searchBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    [searchBtn addTarget:self action:@selector(createOrgBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    [mainView addSubview:searchBtn];
    
    return topView;
}

- (void)searchBtnClicked:(id)sender
{
    UIStoryboard* mainStory = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    UIViewController* controller  = [mainStory instantiateViewControllerWithIdentifier:@"MQOrgSearchController"];
    [self presentViewController:controller animated:YES completion:nil];
}

- (void)createOrgBtnClicked:(id)sender
{
    UIStoryboard* mainStory = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    UIViewController* controller  = [mainStory instantiateViewControllerWithIdentifier:@"MQCreateOrgController"];
    [self presentViewController:controller animated:YES completion:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
    else if ([org.status intValue] == -2)
    {
            str = @"审核不通过";
            txtColor = [UIColor grayTitleColor];
    }
//    else if ([org.status intValue] == -2 ||
//             [org.status intValue] == -1)
//    {
//        UIButton * addOrgBtn = [[UIButton alloc] initWithFrame:CGRectMake(SCREENWIDTH - 94, 0, 94, 78)];
//        addOrgBtn.backgroundColor = [UIColor clearColor];
//        [addOrgBtn addTarget:self action:@selector(addOrgClicked:) forControlEvents:UIControlEventTouchUpInside];
//        addOrgBtn.tag = indexPath.row;
//        [cell.contentView addSubview:addOrgBtn];
//    }
    
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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
