//
//  ViewController.m
//  CommonFrame_Pro
//
//  Created by ionitech on 15/5/22.
//  Copyright (c) 2015年 ionitech. All rights reserved.
//

#import "ViewController.h"
#import "InputText.h"
//#import <AVOSCloud/AVOSCloud.h>
#import "APService.h"
#import "UICommon.h"
#import "ICMemberRegisterViewController.h"

@interface ViewController ()<InputTextDelegate,UITextFieldDelegate,UIGestureRecognizerDelegate>
{
    UILabel*        _lblUserName;
    UITextField*    _txtUserName;
    
    UILabel*        _lblPwd;
    UITextField*    _txtPwd;
    
    IBOutlet UIButton* _btnSubmit;
    
    BOOL            _isConformed;
    BOOL            _isKeepLogin;
}

@property (nonatomic,assign) BOOL chang;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib
    
    self.view.backgroundColor = [UIColor backgroundColor];
    
    CGFloat width = [UIScreen mainScreen].bounds.size.width;
    CGFloat height = 278;//172
    
    UIView* tb = [[UIView alloc] initWithFrame:CGRectMake(0, 0, width, 20)];
    [tb setBackgroundColor:[UIColor blackColor]];
    [self.view addSubview:tb];

    
    UIView * txtView = [[UIView alloc] init];
    txtView.backgroundColor = [UIColor grayMarkColor];
    txtView.frame = CGRectMake(0, height, SCREENWIDTH, 100);
    
    InputText *inputText = [[InputText alloc] init];
    inputText.delegate = self;
    
    UILabel* bottomLine1 = [[UILabel alloc] initWithFrame:CGRectMake(0,  0, width, 0.5)];
    [bottomLine1 setBackgroundColor:[UIColor grayLineColor]];
    [txtView addSubview:bottomLine1];
    
    
    UIImageView* imgName = [[UIImageView alloc] initWithFrame:CGRectMake(14, 18, 13, 15)];
    [imgName setImage:[UIImage imageNamed:@"icon_shouji"]];
    [txtView addSubview:imgName];
    
    
    _txtUserName = [[UITextField alloc] initWithFrame:CGRectMake(36, 0, width - 20, 50)];
    [_txtUserName setBackgroundColor:[UIColor orangeColor]];
    [_txtUserName setBorderStyle:UITextBorderStyleNone];
    [_txtUserName setFont:Font(15)];
    [_txtUserName setTextColor:[UIColor whiteColor]];
    [_txtUserName addTarget:self action:@selector(textFieldDidChange) forControlEvents:UIControlEventEditingChanged];
    _txtUserName.delegate = self;
    
    _txtUserName = [inputText setupWithIcon:nil  point:nil  textFieldControl:_txtUserName showBottomLine:NO];
    
    _lblUserName = [[UILabel alloc] init];
    _lblUserName.text = @"请输入您的手机号";
    _lblUserName.font = Font(15);
    _lblUserName.textColor = [UIColor grayTitleColor];
    _lblUserName.frame = _txtUserName.frame;
    

    [txtView addSubview:_txtUserName];
    [txtView addSubview:_lblUserName];
    
    UILabel* bottomLine = [[UILabel alloc] initWithFrame:CGRectMake(14,  _txtUserName.frame.size.height, width - 14, 0.5)];
    [bottomLine setBackgroundColor:[UIColor grayLineColor]];
    [txtView addSubview:bottomLine];
    
    
    UIImageView* imgPwd = [[UIImageView alloc] initWithFrame:CGRectMake(14, _txtUserName.frame.size.height + 18, 13, 15)];
    [imgPwd setImage:[UIImage imageNamed:@"icon_mima_1"]];
    [txtView addSubview:imgPwd];
    
    _txtPwd = [[UITextField alloc] initWithFrame:CGRectMake(36, _txtUserName.frame.size.height, width - 20, 50)];
    [_txtPwd setBackgroundColor:[UIColor orangeColor]];
    [_txtPwd setBorderStyle:UITextBorderStyleNone];
    [_txtPwd setFont:Font(15)];
    [_txtPwd setTextColor:[UIColor whiteColor]];
    [_txtPwd setSecureTextEntry:YES];
    [_txtPwd addTarget:self action:@selector(textFieldDidChange) forControlEvents:UIControlEventEditingChanged];
    _txtPwd.delegate = self;
    
    _txtPwd = [inputText setupWithIcon:nil  point:nil  textFieldControl:_txtPwd showBottomLine:NO];
    
    _lblPwd = [[UILabel alloc] init];
    _lblPwd.text = @"请输入密码";
    _lblPwd.font = Font(15);
    _lblPwd.textColor = [UIColor grayTitleColor];
    _lblPwd.frame = _txtPwd.frame;
    
    [txtView addSubview:_txtPwd];
    [txtView addSubview:_lblPwd];
    
    UILabel* bottomLine2 = [[UILabel alloc] initWithFrame:CGRectMake(0,  _txtPwd.frame.origin.y  + 49, width, 0.5)];
    [bottomLine2 setBackgroundColor:[UIColor grayLineColor]];
    [txtView addSubview:bottomLine2];
    
    [self.view addSubview:txtView];
    
    [_btnSubmit setBackgroundColor:[UIColor tagBlueBackColor]];
    
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if ([LoginUser isKeepLogined]) {
        _isKeepLogin = YES;
        _txtUserName.text = [LoginUser loginUserName];
        _txtPwd.text = @"111111";
        
        if (_txtUserName.text != nil) {
            [self diminishTextName:_lblUserName];
        }
        if (_txtPwd.text != nil) {
            [self diminishTextName:_lblPwd];
        }
    }
    
//    [self setNeedsStatusBarAppearanceUpdate];

}

//- (UIStatusBarStyle)preferredStatusBarStyle
//{
//    return UIStatusBarStyleLightContent;
//}

#pragma mark - UITextFieldDelegate
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    //[self diminishTextName:_lblUserName];
    
    if (textField == _txtUserName)
    {
        [self diminishTextName:_lblUserName];
        [self restoreTextName:_lblPwd textField:_txtPwd];
    }
    else if (textField == _txtPwd)
    {
        [self diminishTextName:_lblPwd];
        [self restoreTextName:_lblUserName textField:_txtUserName];
    }
    
    return YES;
}
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField == _txtUserName)
    {
        return [_txtPwd becomeFirstResponder];
    }
    else {
        [self restoreTextName:_lblPwd textField:_txtPwd];
        return [_txtPwd resignFirstResponder];
    }
    return YES;
}
- (void)diminishTextName:(UILabel *)label
{
    [UIView animateWithDuration:0.5 animations:^{
        label.transform = CGAffineTransformMakeTranslation(0, -16);
        label.font = [UIFont systemFontOfSize:9];
    }];
}
- (void)restoreTextName:(UILabel *)label textField:(UITextField *)textFieled
{
    [self textFieldTextChange:textFieled];
    if (self.chang) {
        [UIView animateWithDuration:0.5 animations:^{
            label.transform = CGAffineTransformIdentity;
            label.font = [UIFont systemFontOfSize:15];
        }];
    }
}
- (void)textFieldTextChange:(UITextField *)textField
{
    if (textField.text.length != 0) {
        self.chang = NO;
    } else {
        self.chang = YES;
    }
}
- (void)textFieldDidChange
{
    if (_txtUserName.text.length != 0 && _txtPwd.text.length != 0 ) {
        _btnSubmit.enabled = YES;
        [_btnSubmit setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    } else {
        [_btnSubmit setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
        _btnSubmit.enabled = NO;
    }
}

#pragma mark - touchesBegan
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.view endEditing:YES];
    [self restoreTextName:_lblUserName textField:_txtUserName];
    [self restoreTextName:_lblPwd textField:_txtPwd];
}


-(IBAction)btnSubmit:(id)sender
{
    if (![_txtUserName.text isEqualToString:@""] && ![_txtUserName.text isEqualToString:[LoginUser loginUserName]]) {
        _isKeepLogin = NO;
    }
    
    if (_isKeepLogin) {
        UIView* v  = [[UIView alloc] init];
        v.frame = self.view.frame;
        v.tag = 201;
        [v setBackgroundColor:[UIColor blackColor]];
        [self.view addSubview:v];
        _isConformed = YES;
        return;
    }
    
    NSString* name = _txtUserName.text;
    NSString* pwd = _txtPwd.text;
    
    if (name == nil || [name isEqualToString:@""]) {
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"请输入账号信息!" delegate:self
                                              cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
        
        return;
    }
    else if (pwd == nil || [pwd isEqualToString:@""]) {
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"请输入密码!" delegate:self
                                              cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
        
        return;
    }
    
    LoginUser* lg = [LoginUser new];
    
    lg.loginName = name;
    lg.password = pwd;
    
    //lg.loginName = @"13212567779";
    //lg.password = @"111111";
    
    lg.type = 2;
    lg.source = 2;
    lg.productId = 1;
    lg.version = @"1.0.0";
    lg.systemVersion = @"1.0.0";
    _isConformed = [lg hasLogin];
    
    if (_isConformed) {
        UIView* v  = [[UIView alloc] init];
        v.frame = self.view.frame;
        v.tag = 201;
        [v setBackgroundColor:[UIColor blackColor]];
        [self.view addSubview:v];
        
        _txtUserName.text = @"";
        _txtPwd.text = @"";
        [self restoreTextName:_lblUserName textField:_txtUserName];
        [self restoreTextName:_lblPwd textField:_txtPwd];
        
        /*
        //保存登录用户的通讯录ID
        AVInstallation *currentInstallation = [AVInstallation currentInstallation];
        [currentInstallation addUniqueObject:@"HXZ_loginUsers" forKey:@"channels"];
        [currentInstallation setObject:[LoginUser loginUserID] forKey:@"HXZ_userId"];
        [currentInstallation setObject:[LoginUser loginUserName] forKey:@"HXZ_userName"];
        [currentInstallation saveInBackground];
         */
        
        __autoreleasing NSMutableSet *tags = [NSMutableSet set];
        [APService setTags:tags
                     alias:[LoginUser loginUserID]
          callbackSelector:@selector(tagsAliasCallback:tags:alias:)
                    target:self];
    }
    else
    {
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"登录失败" message:@"用户名或密码输入有误!" delegate:self
                                              cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
    }
}

- (void)tagsAliasCallback:(int)iResCode
                     tags:(NSSet *)tags
                    alias:(NSString *)alias
{
}

- (IBAction)btnRegister:(id)sender
{
    UIStoryboard* mainStory = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    UIViewController* controller  = [mainStory instantiateViewControllerWithIdentifier:@"ICMemberRegisterViewController"];
    [self presentViewController:controller animated:YES completion:nil];
}

- (IBAction)btnForgotPasswordClicked:(id)sender
{
    UIStoryboard* mainStory = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    UIViewController* controller  = [mainStory instantiateViewControllerWithIdentifier:@"ICMemberRegisterViewController"];
    
    ((ICMemberRegisterViewController *)controller).isForgetPWD = YES;
    
    [self presentViewController:controller animated:YES completion:nil];
    /*
    NSString* source = _txtUserName.text;
    if (source == nil || [source isEqualToString:@""]) {
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"账号输入错误" message:@"找回密码前，请在账号处输入需要找回密码的账号!" delegate:self
                                              cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
        
        return;
    }
    
    dispatch_queue_t queue = dispatch_queue_create("lqueue", NULL);
    dispatch_async(queue, ^{
        BOOL isSend = [LoginUser findPassword:2 sourceValue:source];
        
        if (isSend) {
            UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"信息已发送至对应的账号，请注意查阅！" delegate:self
                                                  cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            [alert show];
        }

        
    });
    */
}

#pragma mark - Navigation

- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender
{
    return _isConformed;
}

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
 
     UIViewController* vc = segue.destinationViewController;
     
     if ([vc respondsToSelector:@selector(setIcLoginViewController:)]) {
         [vc setValue:self forKey:@"icLoginViewController"];
     }
    
}


@end
