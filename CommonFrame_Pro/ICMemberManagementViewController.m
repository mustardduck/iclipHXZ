//
//  ICMemberManagementViewController.m
//  CommonFrame_Pro
//
//  Created by ionitech on 15/7/3.
//  Copyright (c) 2015年 ionitech. All rights reserved.
//

#import "ICMemberManagementViewController.h"

@implementation ICMemberManagementViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
    
    UILabel* line = [[UILabel alloc] initWithFrame:CGRectMake(0, 66 + 20, screenWidth, 0.5)];
    [line setBackgroundColor:[UIColor whiteColor]];
    [self.view addSubview:line];
    
    UILabel* lblRemove = [[UILabel alloc] initWithFrame:CGRectMake(20, line.frame.origin.y + 1, screenWidth - 20, 48)];
    [lblRemove setBackgroundColor:[UIColor clearColor]];
    [lblRemove setText:@"移除成员"];
    [lblRemove setTextColor:[UIColor whiteColor]];
    [lblRemove setTextAlignment:NSTextAlignmentLeft];
    [lblRemove setFont:[UIFont systemFontOfSize:17]];
    
    UIButton* btnRemove = [[UIButton alloc] initWithFrame:CGRectMake(0, line.frame.origin.y + 1, screenWidth, 48)];
    [btnRemove setBackgroundColor:[UIColor clearColor]];
    [btnRemove setTitle:@" " forState:UIControlStateNormal];
    [btnRemove setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [btnRemove setTitleColor:[UIColor grayColor] forState:UIControlStateHighlighted];
    [btnRemove addTarget:self action:@selector(btnRemoveClicked:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:lblRemove];
    [self.view addSubview:btnRemove];
    
    UILabel* line1 = [[UILabel alloc] initWithFrame:CGRectMake(0, btnRemove.frame.origin.y + 49, screenWidth, 0.5)];
    [line1 setBackgroundColor:[UIColor whiteColor]];
    [self.view addSubview:line1];
    
    
    UILabel* lblSection = [[UILabel alloc] initWithFrame:CGRectMake(10, line1.frame.origin.y + 35, screenWidth - 20, 15)];
    [lblSection setBackgroundColor:[UIColor clearColor]];
    [lblSection setText:@"邀请成员"];
    [lblSection setTextColor:[UIColor whiteColor]];
    [lblSection setTextAlignment:NSTextAlignmentLeft];
    [lblSection setFont:[UIFont systemFontOfSize:13]];
    [self.view addSubview:lblSection];
    
    UILabel* line2 = [[UILabel alloc] initWithFrame:CGRectMake(0, lblSection.frame.origin.y + 16, screenWidth, 0.5)];
    [line2 setBackgroundColor:[UIColor whiteColor]];
    [self.view addSubview:line2];
    
    
    UILabel* lblPhone = [[UILabel alloc] initWithFrame:CGRectMake(20, line2.frame.origin.y + 1, screenWidth - 20, 48)];
    [lblPhone setBackgroundColor:[UIColor clearColor]];
    [lblPhone setText:@"手机号码邀请"];
    [lblPhone setTextColor:[UIColor whiteColor]];
    [lblPhone setTextAlignment:NSTextAlignmentLeft];
    [lblPhone setFont:[UIFont systemFontOfSize:17]];
    
    UIButton* btnPhone = [[UIButton alloc] initWithFrame:CGRectMake(0, line2.frame.origin.y + 1, screenWidth, 48)];
    [btnPhone setBackgroundColor:[UIColor clearColor]];
    [btnPhone setTitle:@" " forState:UIControlStateNormal];
    [btnPhone setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [btnPhone setTitleColor:[UIColor grayColor] forState:UIControlStateHighlighted];
    [btnPhone addTarget:self action:@selector(btnPhoneClicked:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:lblPhone];
    [self.view addSubview:btnPhone];
    
    UILabel* line3 = [[UILabel alloc] initWithFrame:CGRectMake(0, btnPhone.frame.origin.y + 49, screenWidth, 0.5)];
    [line3 setBackgroundColor:[UIColor whiteColor]];
    [self.view addSubview:line3];
    
    
    UILabel* lblEmail = [[UILabel alloc] initWithFrame:CGRectMake(20, line3.frame.origin.y + 1, screenWidth - 20, 48)];
    [lblEmail setBackgroundColor:[UIColor clearColor]];
    [lblEmail setText:@"邮件邀请"];
    [lblEmail setTextColor:[UIColor whiteColor]];
    [lblEmail setTextAlignment:NSTextAlignmentLeft];
    [lblEmail setFont:[UIFont systemFontOfSize:17]];
    
    UIButton* btnEmail = [[UIButton alloc] initWithFrame:CGRectMake(0, line3.frame.origin.y + 1, screenWidth, 48)];
    [btnEmail setBackgroundColor:[UIColor clearColor]];
    [btnEmail setTitle:@" " forState:UIControlStateNormal];
    [btnEmail setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [btnEmail setTitleColor:[UIColor grayColor] forState:UIControlStateHighlighted];
    [btnEmail addTarget:self action:@selector(btnEmailClicked:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:lblEmail];
    [self.view addSubview:btnEmail];
    
    UILabel* line4 = [[UILabel alloc] initWithFrame:CGRectMake(0, btnEmail.frame.origin.y + 49, screenWidth, 0.5)];
    [line4 setBackgroundColor:[UIColor whiteColor]];
    [self.view addSubview:line4];
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)backButtonClicked:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)btnRemoveClicked:(id)sender
{

}

- (void)btnPhoneClicked:(id)sender
{
    
}

- (void)btnEmailClicked:(id)sender
{
    
}

@end
