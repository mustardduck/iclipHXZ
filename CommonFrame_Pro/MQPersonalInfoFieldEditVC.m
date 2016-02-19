//
//  MQPersonalInfoFieldEditVC.m
//  CommonFrame_Pro
//
//  Created by 倩 莫 on 16/2/18.
//  Copyright © 2016年 ionitech. All rights reserved.
//

#import "MQPersonalInfoFieldEditVC.h"
#import "UICommon.h"
#import "SVProgressHUD.h"

@interface MQPersonalInfoFieldEditVC ()
@property (weak, nonatomic) IBOutlet UITextField *txtField;

@end

@implementation MQPersonalInfoFieldEditVC

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
    
    UIBarButtonItem *leftBarButton = [[UIBarButtonItem alloc]initWithCustomView:leftButton];
    self.navigationItem.leftBarButtonItem = leftBarButton;
    
    UIBarButtonItem* rightBarButton = [[UIBarButtonItem alloc] initWithTitle:@"保存" style:UIBarButtonItemStyleDone target:self action:@selector(doneButtonClicked:)];
    [rightBarButton setTitleTextAttributes:@{NSForegroundColorAttributeName:RGBCOLOR(76, 215, 100),NSFontAttributeName:[UIFont systemFontOfSize:17]} forState:UIControlStateNormal];
    self.navigationItem.rightBarButtonItem = rightBarButton;
    
    NSString * title = @"名字";
    NSString * text = _user.name;

    if(_type == 3)
    {
        title = @"手机";
        text = _user.mobile;
        
        _txtField.keyboardType = UIKeyboardTypePhonePad;
    }
    else if(_type == 4)
    {
        title = @"邮箱";
        text = _user.email;
    }
    
    self.navigationItem.title = title;
    
    _txtField.text = text;
}

- (IBAction)btnBackButtonClicked:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)doneButtonClicked:(id)sender
{
    
    NSString* lblName = _txtField.text;
    
    if (lblName == nil || [lblName isEqualToString:@""])
    {
        [SVProgressHUD showErrorWithStatus:@"请输入需要录入的内容"];
        
        [_txtField becomeFirstResponder];
        
        return;
    }
    else if (_type == 3 && lblName.length > 11)
    {
        [SVProgressHUD showErrorWithStatus:@"请输入11位的号码"];
        
        [_txtField becomeFirstResponder];
        
        return;
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        NSString * name = _user.name;
        NSString * phone = _user.mobile;
        NSString * email = _user.email;
        NSString * photo = _user.img;
        
        if(_type == 2)
        {
            name = _txtField.text;
        }
        else if (_type == 3)
        {
            phone = _txtField.text;
        }
        else if (_type == 4)
        {
            email = _txtField.text;
        }
        
        BOOL isOk = [LoginUser updateInfo:name phone:phone email:email photo:photo];
        if (isOk) {
            
            [_txtField resignFirstResponder];
            
            [SVProgressHUD showSuccessWithStatus:@"更新资料成功"];
            
            _user = [LoginUser getLoginInfo];
            
            [self.navigationController popViewControllerAnimated:YES];
        }
        else
        {
            [SVProgressHUD showErrorWithStatus:@"更新资料失败"];
        }
        
    });

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) viewWillDisappear:(BOOL)animated
{
    if ([self.MQPerInfoVC respondsToSelector:@selector(setUser:)]) {
        [self.MQPerInfoVC setValue:_user forKey:@"user"];
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
