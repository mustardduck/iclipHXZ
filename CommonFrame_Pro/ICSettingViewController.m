//
//  ICSettingViewController.m
//  CommonFrame_Pro
//
//  Created by ionitech on 15/7/1.
//  Copyright (c) 2015年 ionitech. All rights reserved.
//

#import "ICSettingViewController.h"
#import "UIColor+HexString.h"
#import "ICGroupMessageSettingController.h"
#import "APService.h"

@interface ICSettingViewController()<UITableViewDataSource,UITableViewDelegate>
{
    __weak IBOutlet UITableView* _tableView;
}

@end


@implementation ICSettingViewController

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
    
    UIBarButtonItem *rightBarButton = [[UIBarButtonItem alloc]initWithCustomView:leftButton];
    self.navigationItem.leftBarButtonItem = rightBarButton;
    
    _tableView.dataSource = self;
    _tableView.delegate = self;
    [self setExtraCellLineHidden:_tableView];
    
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _tableView.tableFooterView = ({
        UIView*  vi = [[UIView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height - 88 - 66)];
        [vi setBackgroundColor:[UIColor clearColor]];
        
        UIButton* quit = [[UIButton alloc] initWithFrame:CGRectMake(0, vi.bounds.size.width - 60, vi.bounds.size.width, 44)];
        [quit setBackgroundColor:[UIColor colorWithHexString:@"#fd3c3f"]];
        [quit addTarget:self action:@selector(quit) forControlEvents:UIControlEventTouchUpInside];
        [quit setTitle:@"退出登录" forState:UIControlStateNormal];
        
        NSMutableAttributedString* eattriNormal = [[NSMutableAttributedString alloc]
                                                initWithString:@"退出登录" attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:13],NSForegroundColorAttributeName:[UIColor whiteColor]}];
        [quit setAttributedTitle:eattriNormal forState:UIControlStateNormal];
        
        [vi addSubview:quit];
        
        vi;
    });
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)backButtonClicked:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)quit
{
    //dispatch_queue_t queue = dispatch_queue_create("lqueue", NULL);
    //dispatch_async(queue, ^{
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

    //});
    
}

- (void)tagsAliasCallback:(int)iResCode
                     tags:(NSSet *)tags
                    alias:(NSString *)alias
{
}

#pragma mark -
#pragma mark Table View Action
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 3;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellId = @"SettingTableViewCellId";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    if (cell == nil){
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
        
    }
    
    NSInteger index = indexPath.row;
    
    
    UILabel* lbl = [[UILabel alloc] initWithFrame:CGRectMake(38, 12, 120, 20)];
    lbl.textColor = [UIColor whiteColor];
    lbl.font = [UIFont systemFontOfSize:15];
    lbl.backgroundColor = [UIColor clearColor];
    
    if (index == 0) {
        UIImageView* imgView = [[UIImageView alloc] initWithFrame:CGRectMake(11, 12, 17, 20)];
        [imgView setImage:[UIImage imageNamed:@"btn_renwu_1.png"]];
        [cell.contentView addSubview:imgView];
        lbl.text = @"个人信息";
    }
    else if (index == 1) {
        UIImageView* imgView = [[UIImageView alloc] initWithFrame:CGRectMake(11, 14, 17, 17)];
        [imgView setImage:[UIImage imageNamed:@"icon_zhanghao"]];
        [cell.contentView addSubview:imgView];
        lbl.text = @"账号设置";
    }
    else if (index == 2)
    {
        UIImageView* imgView = [[UIImageView alloc] initWithFrame:CGRectMake(13, 18, 13, 10)];
        [imgView setImage:[UIImage imageNamed:@"icon_xiaoxitongzhi"]];
        [cell.contentView addSubview:imgView];
        lbl.text = @"消息设置";
    }
    
    [cell.contentView addSubview:lbl];
    
    UILabel* bottomLine = [[UILabel alloc] initWithFrame:CGRectMake(0, 43, [UIScreen mainScreen].bounds.size.width, 0.5)];
    [bottomLine setBackgroundColor:[UIColor grayColor]];
    [cell.contentView addSubview:bottomLine];
    
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger index = indexPath.row;
    UIStoryboard* mainStory = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    UIViewController* controller;
    if (index == 0) {
        controller = [mainStory instantiateViewControllerWithIdentifier:@"ICPersonalInfoViewController"];
    }
    else if (index == 1) {
        controller = [mainStory instantiateViewControllerWithIdentifier:@"ICAccountViewController"];
    }
    else if (index == 2)
    {
        controller = [mainStory instantiateViewControllerWithIdentifier:@"ICGroupMessageSettingController"];
    }
    
    [self.navigationController pushViewController:controller animated:YES];
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

-(void)setExtraCellLineHidden: (UITableView *)tableView
{
    UIView *view = [UIView new];
    view.backgroundColor = [UIColor clearColor];
    [tableView setTableFooterView:view];
}
@end
