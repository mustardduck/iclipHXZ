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

@interface MQCreatOrgMainController ()<UITableViewDataSource, UITableViewDelegate>
{
    UITableView * _mainTableView;
    
    NSArray * _orgArr;
}

@end

@implementation MQCreatOrgMainController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    UIView* tb = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREENWIDTH, 20)];
    [tb setBackgroundColor:[UIColor blackColor]];
    [self.view addSubview:tb];
    
    [self initTableView];
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
//    NSString * userId = [LoginUser loginUserID];
    
    NSString * userId = @"1015042910350001";
    
    _orgArr = [Organization fineExamOrg: userId];
    
    if(_orgArr.count)
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
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
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
