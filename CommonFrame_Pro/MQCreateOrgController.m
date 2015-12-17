//
//  MQCreateOrgController.m
//  CommonFrame_Pro
//
//  Created by 倩 莫 on 15/12/15.
//  Copyright © 2015年 ionitech. All rights reserved.
//

#import "MQCreateOrgController.h"
#import "UICommon.h"
#import "LoginUser.h"
#import "SVProgressHUD.h"
#import "Organization.h"
#import "ViewController.h"
#import "ICMainViewController.h"

@interface MQCreateOrgController ()<UITextFieldDelegate>
{
    
    __weak IBOutlet UINavigationBar *_navBar;
    
}

@property (weak, nonatomic) IBOutlet UILabel *orgCreateNameLbl;
@property (weak, nonatomic) IBOutlet UITextField *orgNameTxtField;
@property (weak, nonatomic) IBOutlet UIButton *okBtn;
@property (weak, nonatomic) IBOutlet UIScrollView *mainScrollView;

@end

@implementation MQCreateOrgController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    UIButton *leftButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 70, 20)];
    [leftButton addTarget:self action:@selector(btnBackButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    UIImageView* imgview = [[UIImageView alloc] initWithFrame:CGRectMake(0, 1, 10, 18)];
    [imgview setImage:[UIImage imageNamed:@"btn_fanhui"]];
    [leftButton addSubview:imgview];
    UILabel* ti = [[UILabel alloc] initWithFrame:CGRectMake(18, 0, 80, 20)];
    [ti setBackgroundColor:[UIColor clearColor]];
    [ti setTextColor:[UIColor whiteColor]];
    [ti setText:@"返回"];
    [ti setFont:[UIFont systemFontOfSize:17]];
    [leftButton addSubview:ti];
    
    UIBarButtonItem *leftBarButton = [[UIBarButtonItem alloc]initWithCustomView:leftButton];
    UINavigationItem *item = [[UINavigationItem alloc] initWithTitle:@"新建企业"];
    [item setLeftBarButtonItem:leftBarButton];
    [_navBar pushNavigationItem:item animated:YES];
    
    UIView* tb = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREENWIDTH, 20)];
    [tb setBackgroundColor:[UIColor blackColor]];
    [self.view addSubview:tb];
    
    _orgCreateNameLbl.text = [NSString stringWithFormat:@"企业创建人：%@", [LoginUser loginUserName]];
    
    [self addDoneToKeyboard:_orgNameTxtField];

}

- (void) hiddenKeyboard
{
    [_orgNameTxtField resignFirstResponder];
}

#pragma mark - UITextFieldDelegate

- (void) textFieldDidBeginEditing:(UITextField *)textField
{
    [_mainScrollView setContentOffset:CGPointMake(0, 100) animated:YES];
}

- (void) textFieldDidEndEditing:(UITextField *)textField
{
    [_mainScrollView setContentOffset:CGPointMake(0, 0) animated:YES];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)okBtnClicked:(id)sender
{
    if(!_orgNameTxtField.text.length)
    {
        [SVProgressHUD showErrorWithStatus:@"企业名称不能为空"];
    }
    else
    {
        BOOL isOk = [Organization addOrg:[LoginUser loginUserID] orgName:_orgNameTxtField.text];
        
        if(isOk)
        {//跳到登录页面
            ViewController *loginVc = (ViewController*)self.presentingViewController.presentingViewController.presentingViewController;
            
            [_orgNameTxtField resignFirstResponder];

            if(loginVc)
            {
                [loginVc dismissViewControllerAnimated:YES completion:nil];
            }
            else
            {
                UIStoryboard* mainStory = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
                UIViewController* controller  = [mainStory instantiateViewControllerWithIdentifier:@"ViewController"];
                [self presentViewController:controller animated:YES completion:nil];
            }
        }
        else
        {
            [SVProgressHUD showErrorWithStatus:@"创建企业失败"];
        }
    }
}

- (IBAction) btnBackButtonClicked:(id)sender
{
    [_orgNameTxtField resignFirstResponder];

    [self dismissViewControllerAnimated:YES completion:nil];
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
