//
//  MQMyMessageMainController.m
//  CommonFrame_Pro
//
//  Created by 倩 莫 on 15/12/21.
//  Copyright © 2015年 ionitech. All rights reserved.
//

#import "MQMyMessageMainController.h"
#import "MQMyMessageListController.h"
#import "UICommon.h"
#import "UIImageView+UIActivityIndicatorForSDWebImage.h"
#import "LoginUser.h"
#import "MessageCenter.h"

@interface MQMyMessageMainController ()
{
    NSString * _commentNum;//评论条数
    NSString * _sysNum;//系统消息条数
    NSString * _allNum;//所有消息条数

}

@property (weak, nonatomic) IBOutlet UIImageView *photoImg;
@property (weak, nonatomic) IBOutlet UILabel *titleLbl;
@property (weak, nonatomic) IBOutlet UILabel *jobLbl;
@property (weak, nonatomic) IBOutlet UIButton *megBtn;
@property (weak, nonatomic) IBOutlet UIView *redPoint;



@end

@implementation MQMyMessageMainController

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
    
    UIBarButtonItem *rightBarButton = [[UIBarButtonItem alloc]initWithCustomView:leftButton];
    self.navigationItem.leftBarButtonItem = rightBarButton;
    
    [_photoImg setRoundCorner:3.3];
    [_photoImg setImageWithURL:[NSURL URLWithString:[LoginUser loginUserPhoto]] placeholderImage:nil options:SDWebImageDelayPlaceholder usingActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    _titleLbl.text = [LoginUser loginUserName];
    _jobLbl.text = [LoginUser loginUserDuty];
    
    NSString * commentNum = @"";
    NSString * sysNum = @"";
    NSString * allNum = @"";

    BOOL isOk = [MessageCenter findCommentMessageNum:[LoginUser loginUserID] commentNum:&commentNum sysNum:&sysNum allNum:&allNum];
    if(isOk)
    {
        _commentNum = commentNum;
        _sysNum = sysNum;
        _allNum = allNum;
        
        if([_allNum intValue] > 0)
        {
            _redPoint.hidden = NO;
            [_redPoint setRoundCorner:W(_redPoint) / 2];
            _megBtn.hidden = NO;
        }
        else
        {
            _megBtn.hidden = YES;
        }
    }
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)btnBackButtonClicked:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)jumpToMegList:(id)sender
{
    UIStoryboard* mainStory = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    UIViewController* vc = [mainStory instantiateViewControllerWithIdentifier:@"MQMyMessageListController"];

    [self.navigationController pushViewController:vc animated:YES];
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
