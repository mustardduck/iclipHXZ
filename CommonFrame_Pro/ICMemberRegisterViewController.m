//
//  ICMemberRegisterViewController.m
//  CommonFrame_Pro
//
//  Created by ionitech on 15/6/29.
//  Copyright (c) 2015年 ionitech. All rights reserved.
//

#import "ICMemberRegisterViewController.h"
#import "InputText.h"
#import "UICommon.h"
#import "SVProgressHUD.h"
#import "LoginUser.h"
#import "MQCreatOrgMainController.h"

@interface ICMemberRegisterViewController() <InputTextDelegate,UITextFieldDelegate>
{
    UILabel*        _lblUserName;
    UITextField*    _txtUserName;
    
    UITextField*    _smsCode;
    UIButton * _getSMSCodeBtn;
    
    UITextField*    _accountName;

    UILabel*        _lblPwd;
    UITextField*    _txtPwd;
    
    UILabel*        _lblInvitation;
    UITextField*    _txtInvitation;
    
    IBOutlet  UIButton*       _btnSubmit;
    
    IBOutlet UINavigationBar*       _navBar;
    
    UITextField * _currentField;

}

@property (nonatomic,assign) BOOL chang;
@property (weak, nonatomic) IBOutlet UIView *mainView;
@property (weak, nonatomic) IBOutlet UIScrollView *mainScrollView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *mainViewHeight;
@property (weak, nonatomic) IBOutlet UIImageView *topbgImgView;

@end

@implementation ICMemberRegisterViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor backgroundColor];
    
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
    UINavigationItem *item = [[UINavigationItem alloc] initWithTitle:@"注册"];
    [item setLeftBarButtonItem:leftBarButton];    
    [_navBar pushNavigationItem:item animated:YES];
    
    UIView* tb = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREENWIDTH, 20)];
    [tb setBackgroundColor:[UIColor blackColor]];
    [self.view addSubview:tb];
    
    [self layoutTxtView];
    
}

- (void) layoutTxtView2
{
    CGFloat width = SCREENWIDTH;
    CGFloat height = 66;
    
    InputText *inputText = [[InputText alloc] init];
    inputText.delegate = self;
    
     UILabel* bottomLine1 = [[UILabel alloc] initWithFrame:CGRectMake(0,  height - 1, width, 0.5)];
     [bottomLine1 setBackgroundColor:[UIColor grayColor]];
     [self.view addSubview:bottomLine1];
     
     UIImageView* imgName = [[UIImageView alloc] initWithFrame:CGRectMake(10, height + 12, 17, 20)];
     [imgName setImage:[UIImage imageNamed:@"btn_renwu_1"]];
     [self.view addSubview:imgName];
     
     _txtUserName = [[UITextField alloc] initWithFrame:CGRectMake(36, height, width - 20, 50)];
     [_txtUserName setBackgroundColor:[UIColor orangeColor]];
     [_txtUserName setBorderStyle:UITextBorderStyleNone];
     [_txtUserName setFont:[UIFont systemFontOfSize:17]];
     [_txtUserName setTextColor:[UIColor whiteColor]];
     [_txtUserName addTarget:self action:@selector(textFieldDidChange) forControlEvents:UIControlEventEditingChanged];
     _txtUserName.delegate = self;
     
     _txtUserName = [inputText setupWithIcon:nil  point:nil  textFieldControl:_txtUserName showBottomLine:NO];
     
     _lblUserName = [[UILabel alloc] init];
     _lblUserName.text = @"您的手机号";
     _lblUserName.font = [UIFont systemFontOfSize:16];
     _lblUserName.textColor = [UIColor grayColor];
     _lblUserName.frame = _txtUserName.frame;
     
     [self.view addSubview:_txtUserName];
     [self.view addSubview:_lblUserName];
     
     UILabel* bottomLine = [[UILabel alloc] initWithFrame:CGRectMake(0,  _txtUserName.frame.size.height + height, width, 0.5)];
     [bottomLine setBackgroundColor:[UIColor grayColor]];
     [self.view addSubview:bottomLine];
     
     UIImageView* imgPwd = [[UIImageView alloc] initWithFrame:CGRectMake(10, _txtUserName.frame.size.height + height + 12, 17, 20)];
     [imgPwd setImage:[UIImage imageNamed:@"icon_mima"]];
     [self.view addSubview:imgPwd];
     
     _txtPwd = [[UITextField alloc] initWithFrame:CGRectMake(40, _txtUserName.frame.size.height + height + 1, width - 20, 44)];
     [_txtPwd setBackgroundColor:[UIColor orangeColor]];
     [_txtPwd setBorderStyle:UITextBorderStyleNone];
     [_txtPwd setFont:[UIFont systemFontOfSize:17]];
     [_txtPwd setTextColor:[UIColor whiteColor]];
     [_txtPwd setSecureTextEntry:YES];
     [_txtPwd addTarget:self action:@selector(textFieldDidChange) forControlEvents:UIControlEventEditingChanged];
     _txtPwd.delegate = self;
     
     _txtPwd = [inputText setupWithIcon:nil  point:nil  textFieldControl:_txtPwd showBottomLine:NO];
     
     _lblPwd = [[UILabel alloc] init];
     _lblPwd.text = @"密码";
     _lblPwd.font = [UIFont systemFontOfSize:16];
     _lblPwd.textColor = [UIColor grayColor];
     _lblPwd.frame = _txtPwd.frame;
     
     [self.view addSubview:_txtPwd];
     [self.view addSubview:_lblPwd];
     
     
     UILabel* bottomLine2 = [[UILabel alloc] initWithFrame:CGRectMake(0,  _txtPwd.frame.origin.y  + 43, width, 0.5)];
     [bottomLine2 setBackgroundColor:[UIColor grayColor]];
     [self.view addSubview:bottomLine2];
     
     
     UILabel* bottomLine3 = [[UILabel alloc] initWithFrame:CGRectMake(0,  bottomLine2.frame.origin.y  + 30, width, 0.5)];
     [bottomLine3 setBackgroundColor:[UIColor grayColor]];
     [self.view addSubview:bottomLine3];
     
     UIImageView* imgInvitation = [[UIImageView alloc] initWithFrame:CGRectMake(10, bottomLine3.frame.origin.y + 12, 17, 19)];
     [imgInvitation setImage:[UIImage imageNamed:@"icon_yaoqingma"]];
     [self.view addSubview:imgInvitation];
     
     _txtInvitation = [[UITextField alloc] initWithFrame:CGRectMake(40, bottomLine3.frame.origin.y + 1, width - 20, 44)];
     [_txtInvitation setBackgroundColor:[UIColor orangeColor]];
     [_txtInvitation setBorderStyle:UITextBorderStyleNone];
     [_txtInvitation setFont:[UIFont systemFontOfSize:17]];
     [_txtInvitation setTextColor:[UIColor whiteColor]];
     [_txtInvitation addTarget:self action:@selector(textFieldDidChange) forControlEvents:UIControlEventEditingChanged];
     _txtInvitation.delegate = self;
     
     _txtInvitation = [inputText setupWithIcon:nil  point:nil  textFieldControl:_txtInvitation showBottomLine:NO];
     
     _lblInvitation = [[UILabel alloc] init];
     _lblInvitation.text = @"邀请码";
     _lblInvitation.font = [UIFont systemFontOfSize:16];
     _lblInvitation.textColor = [UIColor grayColor];
     _lblInvitation.frame = _txtInvitation.frame;
     
     [self.view addSubview:_txtInvitation];
     [self.view addSubview:_lblInvitation];
     
     
     UILabel* bottomLine4 = [[UILabel alloc] initWithFrame:CGRectMake(0,  _txtInvitation.frame.origin.y + 45, width, 0.5)];
     [bottomLine4 setBackgroundColor:[UIColor grayColor]];
     [self.view addSubview:bottomLine4];
     
     UIButton* btnReg = [[UIButton alloc] initWithFrame:CGRectMake(0, bottomLine4.frame.origin.y + 80, [UIScreen mainScreen].bounds.size.width, 40)];
     [btnReg setBackgroundColor:[UIColor colorWithHexString:@"#2d4778"]];
     [btnReg setTitle:@"注册" forState:UIControlStateNormal];
     [btnReg setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
     [btnReg addTarget:self action:@selector(btnRegClicked:) forControlEvents:UIControlEventTouchUpInside];
     
     [self.view addSubview:btnReg];

}

- (void) layoutTxtView
{
    CGFloat width = SCREENWIDTH;
    CGFloat height = 200;
    
    UIView * txtView = [[UIView alloc] init];
    txtView.backgroundColor = [UIColor grayMarkColor];
    txtView.frame = CGRectMake(0, height, SCREENWIDTH, 50 * 4);
    
    UILabel* bottomLine = [[UILabel alloc] initWithFrame:CGRectMake(0,  0, width, 0.5)];
    [bottomLine setBackgroundColor:[UIColor grayLineColor]];
    [txtView addSubview:bottomLine];
    
    
    UIImageView* imgName = [[UIImageView alloc] initWithFrame:CGRectMake(14, 18, 13, 15)];
    [imgName setImage:[UIImage imageNamed:@"icon_shouji"]];
    [txtView addSubview:imgName];
    //手机号
    _txtUserName = [[UITextField alloc] initWithFrame:CGRectMake(36, 0, width - 36 * 2, 50)];
    [_txtUserName setBackgroundColor:[UIColor clearColor]];
    [_txtUserName setFont:Font(16)];
    [_txtUserName setTextColor:[UIColor whiteColor]];
    _txtUserName.delegate = self;
    _txtUserName.placeholder = @"您的手机号";
    _txtUserName.keyboardType = UIKeyboardTypePhonePad;
    [_txtUserName setValue:[UIColor grayTitleColor] forKeyPath:@"_placeholderLabel.textColor"];
    [self addDoneToKeyboard:_txtUserName];
    
    [txtView addSubview:_txtUserName];
    
    bottomLine = [[UILabel alloc] initWithFrame:CGRectMake(14,  H(_txtUserName), width - 14, 0.5)];
    [bottomLine setBackgroundColor:[UIColor grayLineColor]];
    [txtView addSubview:bottomLine];
    
    //短信验证码
    
    imgName = [[UIImageView alloc] initWithFrame:CGRectMake(14, 50 + 18, 13, 15)];
    [imgName setImage:[UIImage imageNamed:@"icon_duanxinyanzheng"]];
    [txtView addSubview:imgName];
    
    _smsCode = [[UITextField alloc] initWithFrame:CGRectMake(36, _txtUserName.bottom, width - 36 - 14 - 100 , 50)];
    [_smsCode setBackgroundColor:[UIColor clearColor]];
    [_smsCode setFont:Font(16)];
    [_smsCode setTextColor:[UIColor whiteColor]];
    _smsCode.delegate = self;
    _smsCode.placeholder = @"短信验证码";
    _smsCode.keyboardType = UIKeyboardTypeNumberPad;
    [_smsCode setValue:[UIColor grayTitleColor] forKeyPath:@"_placeholderLabel.textColor"];
    [self addDoneToKeyboard:_smsCode];
    
    [txtView addSubview:_smsCode];
    
    _getSMSCodeBtn = [[UIButton alloc] initWithFrame:CGRectMake(SCREENWIDTH - 14 - 100, _txtUserName.bottom + 10, 100, 30)];
    _getSMSCodeBtn.backgroundColor = [UIColor grayLineColor];
    [_getSMSCodeBtn setRoundCorner:3.3];
    [_getSMSCodeBtn setTitle:@"点击获取" forState:UIControlStateNormal];
    _getSMSCodeBtn.titleLabel.font = Font(14);
    _getSMSCodeBtn.titleLabel.textColor = [UIColor whiteColor];
    [_getSMSCodeBtn addTarget:self action:@selector(startTime) forControlEvents:UIControlEventTouchUpInside];
    
    [txtView addSubview:_getSMSCodeBtn];
    
    bottomLine = [[UILabel alloc] initWithFrame:CGRectMake(14, _smsCode.bottom, width - 14, 0.5)];
    [bottomLine setBackgroundColor:[UIColor grayLineColor]];
    [txtView addSubview:bottomLine];
    
    //姓名
    
    imgName = [[UIImageView alloc] initWithFrame:CGRectMake(14, 50 * 2 + 18, 13, 15)];
    

    [txtView addSubview:imgName];
    
    _accountName = [[UITextField alloc] initWithFrame:CGRectMake(36, _smsCode.bottom,width - 36 * 2, 50)];
    [_accountName setBackgroundColor:[UIColor clearColor]];
    [_accountName setFont:Font(16)];
    [_accountName setTextColor:[UIColor whiteColor]];
    _accountName.delegate = self;
    if(_isForgetPWD)
    {
        [imgName setImage:[UIImage imageNamed:@"icon_mima_1"]];
        _accountName.placeholder = @"请输入密码";
        [_accountName setSecureTextEntry:YES];
    }
    else
    {
        [imgName setImage:[UIImage imageNamed:@"icon_xingming"]];
        _accountName.placeholder = @"您的姓名";
    }
    [_accountName setValue:[UIColor grayTitleColor] forKeyPath:@"_placeholderLabel.textColor"];
    [self addDoneToKeyboard:_accountName];
    
    [txtView addSubview:_accountName];
    
    bottomLine = [[UILabel alloc] initWithFrame:CGRectMake(14,  _accountName.bottom, width - 14, 0.5)];
    [bottomLine setBackgroundColor:[UIColor grayLineColor]];
    [txtView addSubview:bottomLine];
    
    //密码
    UIImageView* imgPwd = [[UIImageView alloc] initWithFrame:CGRectMake(14, 50 * 3 + 18, 13, 15)];
    [imgPwd setImage:[UIImage imageNamed:@"icon_mima_1"]];
    [txtView addSubview:imgPwd];
    
    _txtPwd = [[UITextField alloc] initWithFrame:CGRectMake(36, 50 * 3, width - 36 * 2, 50)];
    [_txtPwd setBackgroundColor:[UIColor clearColor]];
    [_txtPwd setFont:Font(15)];
    [_txtPwd setTextColor:[UIColor whiteColor]];
    [_txtPwd setSecureTextEntry:YES];
    _txtPwd.delegate = self;
    if(_isForgetPWD)
    {
        _topbgImgView.image = [UIImage imageNamed:@"bg_wanjimima"];

        _txtPwd.placeholder = @"请再次输入密码";
    }
    else
    {
        _topbgImgView.image = [UIImage imageNamed:@"bg_zhuchetu"];

        _txtPwd.placeholder = @"密码";
    }
    [_txtPwd setValue:[UIColor grayTitleColor] forKeyPath:@"_placeholderLabel.textColor"];
    [self addDoneToKeyboard:_txtPwd];
    
    [txtView addSubview:_txtPwd];
    
    bottomLine = [[UILabel alloc] initWithFrame:CGRectMake(0, 50 * 3 + 49.5, width, 0.5)];
    [bottomLine setBackgroundColor:[UIColor grayLineColor]];
    [txtView addSubview:bottomLine];
    
    [self.mainView addSubview:txtView];
    
    UIButton* btnReg = [[UIButton alloc] initWithFrame:CGRectMake(0, txtView.bottom + 83, SCREENWIDTH, 50)];
    btnReg.titleLabel.font = Font(18);
    [btnReg setBackgroundColor:[UIColor tagBlueBackColor]];
    if(_isForgetPWD)
    {
        [btnReg setTitle:@"确认" forState:UIControlStateNormal];
    }
    else
    {
        [btnReg setTitle:@"注册" forState:UIControlStateNormal];
    }
    [btnReg setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [btnReg addTarget:self action:@selector(btnRegClicked:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.mainView addSubview:btnReg];
    
    _mainViewHeight.constant = btnReg.bottom + 80;
    
}

-(void)startTime{
    if(_txtUserName.text.length && _txtUserName.text.length == 11)
    {
        [_smsCode becomeFirstResponder];
        
        NSString * status = @"";
        NSString * msg = @"";
        
        NSInteger source = 1;
        
        if(_isForgetPWD)
        {
            source = 2;
        }
        
        BOOL isOK = [LoginUser sendSMS:source mobile:_txtUserName.text status:&status msg:&msg];
        
        if(isOK)
        {
            [SVProgressHUD showSuccessWithStatus:msg];
        }
        else
        {
            [SVProgressHUD showErrorWithStatus:msg];
            
            [_smsCode resignFirstResponder];
            
            return;
        }
    }
    else if(!_txtUserName.text.length)
    {
        [SVProgressHUD showErrorWithStatus:@"您的手机号不能为空"];
        
        [_txtUserName becomeFirstResponder];
        
        return;
    }
    else if(_txtUserName.text.length != 11)
    {
        [SVProgressHUD showErrorWithStatus:@"请输入11位的手机号"];
        
        [_txtUserName becomeFirstResponder];
        
        return;
    }
    __block int timeout=59; //倒计时时间
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_source_t _timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0,queue);
    dispatch_source_set_timer(_timer,dispatch_walltime(NULL, 0),1.0*NSEC_PER_SEC, 0); //每秒执行
    dispatch_source_set_event_handler(_timer, ^{
        if(timeout<=0){ //倒计时结束，关闭
            dispatch_source_cancel(_timer);
            dispatch_async(dispatch_get_main_queue(), ^{
                //设置界面的按钮显示 根据自己需求设置
                [_getSMSCodeBtn setTitle:@"点击获取" forState:UIControlStateNormal];
                _getSMSCodeBtn.userInteractionEnabled = YES;
            });
        }else{
            int seconds = timeout % 60;
            NSString *strTime = [NSString stringWithFormat:@"%.2d", seconds];
            dispatch_async(dispatch_get_main_queue(), ^{
                //设置界面的按钮显示 根据自己需求设置
                //NSLog(@"____%@",strTime);
                [UIView beginAnimations:nil context:nil];
                [UIView setAnimationDuration:1];
                [_getSMSCodeBtn setTitle:[NSString stringWithFormat:@"%@秒",strTime] forState:UIControlStateNormal];
                [UIView commitAnimations];
                _getSMSCodeBtn.userInteractionEnabled = NO;
            });
            timeout--;
        }
    });
    dispatch_resume(_timer);
}

- (void) hiddenKeyboard
{
    [_mainScrollView setContentOffset:CGPointMake(0, 0) animated:YES];

    [_currentField resignFirstResponder];
}

- (void) layoutTxtView3
{
    CGFloat width = SCREENWIDTH;
    CGFloat height = 264;
    
    UIView * txtView = [[UIView alloc] init];
    txtView.backgroundColor = [UIColor grayMarkColor];
    txtView.frame = CGRectMake(0, height, SCREENWIDTH, 50 * 4);
    
    InputText *inputText = [[InputText alloc] init];
    inputText.delegate = self;
    
    UILabel* bottomLine = [[UILabel alloc] initWithFrame:CGRectMake(0,  0, width, 0.5)];
    [bottomLine setBackgroundColor:[UIColor grayLineColor]];
    [txtView addSubview:bottomLine];
    
    
    UIImageView* imgName = [[UIImageView alloc] initWithFrame:CGRectMake(14, 18, 13, 15)];
    [imgName setImage:[UIImage imageNamed:@"icon_shouji"]];
    [txtView addSubview:imgName];
    
    
    _txtUserName = [[UITextField alloc] initWithFrame:CGRectMake(36, 0, width - 20, 50)];
    [_txtUserName setBackgroundColor:[UIColor orangeColor]];
    [_txtUserName setBorderStyle:UITextBorderStyleNone];
    [_txtUserName setFont:Font(16)];
    [_txtUserName setTextColor:[UIColor whiteColor]];
    [_txtUserName addTarget:self action:@selector(textFieldDidChange) forControlEvents:UIControlEventEditingChanged];
    _txtUserName.delegate = self;
    
    _txtUserName = [inputText setupWithIcon:nil  point:nil  textFieldControl:_txtUserName showBottomLine:NO];
    
    _lblUserName = [[UILabel alloc] init];
    _lblUserName.text = @"您的手机号";
    _lblUserName.font = Font(15);
    _lblUserName.textColor = [UIColor grayTitleColor];
    _lblUserName.frame = _txtUserName.frame;
    
    
    [txtView addSubview:_txtUserName];
    [txtView addSubview:_lblUserName];
    
    bottomLine = [[UILabel alloc] initWithFrame:CGRectMake(14,  _txtUserName.frame.size.height, width - 14, 0.5)];
    [bottomLine setBackgroundColor:[UIColor grayLineColor]];
    [txtView addSubview:bottomLine];
    
    
    UIImageView* imgPwd = [[UIImageView alloc] initWithFrame:CGRectMake(14, 50 * 3 + 18, 13, 15)];
    [imgPwd setImage:[UIImage imageNamed:@"icon_mima_1"]];
    [txtView addSubview:imgPwd];
    
    _txtPwd = [[UITextField alloc] initWithFrame:CGRectMake(36, 50 * 3, width - 20, 50)];
    [_txtPwd setBackgroundColor:[UIColor orangeColor]];
    [_txtPwd setBorderStyle:UITextBorderStyleNone];
    [_txtPwd setFont:Font(15)];
    [_txtPwd setTextColor:[UIColor whiteColor]];
    [_txtPwd setSecureTextEntry:YES];
    [_txtPwd addTarget:self action:@selector(textFieldDidChange) forControlEvents:UIControlEventEditingChanged];
    _txtPwd.delegate = self;
    
    _txtPwd = [inputText setupWithIcon:nil  point:nil  textFieldControl:_txtPwd showBottomLine:NO];
    
    _lblPwd = [[UILabel alloc] init];
    _lblPwd.text = @"密码";
    _lblPwd.font = Font(15);
    _lblPwd.textColor = [UIColor grayTitleColor];
    _lblPwd.frame = _txtPwd.frame;
    
    [txtView addSubview:_txtPwd];
    [txtView addSubview:_lblPwd];
    
    bottomLine = [[UILabel alloc] initWithFrame:CGRectMake(0, 50 * 3 + 49.5, width, 0.5)];
    [bottomLine setBackgroundColor:[UIColor grayLineColor]];
    [txtView addSubview:bottomLine];
    
    [self.mainView addSubview:txtView];
    
    UIButton* btnReg = [[UIButton alloc] initWithFrame:CGRectMake(0, txtView.bottom + 83, SCREENWIDTH, 40)];
    btnReg.titleLabel.font = Font(18);
    [btnReg setBackgroundColor:[UIColor tagBlueBackColor]];
    [btnReg setTitle:@"注册" forState:UIControlStateNormal];
    [btnReg setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [btnReg addTarget:self action:@selector(btnRegClicked:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.mainView addSubview:btnReg];
}

- (IBAction)btnBackButtonClicked:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (BOOL) varifyTxtField
{
    if(!_txtUserName.text.length)
    {
        [SVProgressHUD showErrorWithStatus:@"请输入手机号"];
        
        [_txtUserName becomeFirstResponder];
        
        return NO;
    }
    if(_txtUserName.text.length != 11)
    {
        [SVProgressHUD showErrorWithStatus:@"请输入11位手机号"];
        
        [_txtUserName becomeFirstResponder];
        
        return NO;
    }
    if(!_smsCode.text.length)
    {
        [SVProgressHUD showErrorWithStatus:@"请输入短信验证码"];
        
        [_smsCode becomeFirstResponder];
        
        return NO;
    }
    if(_isForgetPWD)
    {
        if(!_accountName.text.length)
        {
            [SVProgressHUD showErrorWithStatus:@"请输入密码"];
            
            [_accountName becomeFirstResponder];
            
            return NO;
        }
        if(!_txtPwd.text.length)
        {
            [SVProgressHUD showErrorWithStatus:@"请再次输入密码"];
            
            [_txtPwd becomeFirstResponder];
            
            return NO;
        }
        if(![_txtPwd.text isEqualToString:_accountName.text])
        {
            [SVProgressHUD showErrorWithStatus:@"两次输入的密码不一致"];
            
            [_accountName becomeFirstResponder];
            
            return NO;
        }
    }
    else
    {
        if(!_accountName.text.length)
        {
            [SVProgressHUD showErrorWithStatus:@"请输入姓名"];
            
            [_accountName becomeFirstResponder];
            
            return NO;
        }
        if(!_txtPwd.text.length)
        {
            [SVProgressHUD showErrorWithStatus:@"请输入密码"];
            
            [_txtPwd becomeFirstResponder];
            
            return NO;
        }
    }

    return YES;
}

-(void)btnRegClicked:(id)sender
{
    UIButton * btn = (UIButton *)sender;
    
    if(![self varifyTxtField])
    {
        return;
    }
    
    if([btn.titleLabel.text isEqualToString:@"确认"])
    {
        __block BOOL reg = NO;
        dispatch_queue_t queue = dispatch_queue_create("lqueue", NULL);
        dispatch_async(queue, ^{

            reg = [LoginUser updatePwd:_txtUserName.text code:_smsCode.text password:_txtPwd.text];
            if (reg) {
                
//                UIStoryboard* mainStory = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
//                UIViewController* controller  = [mainStory instantiateViewControllerWithIdentifier:@"MQCreatOrgMainController"];
//                [self presentViewController:controller animated:YES completion:nil];
                [self dismissViewControllerAnimated:YES completion:nil];
                
            }
            else
            {
                [SVProgressHUD showErrorWithStatus:@"修改密码失败"];
            }
        });
        
        if (reg) {
            NSLog(@"SUCC");
        }
    }
    else
    {
        UIStoryboard* mainStory = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        UIViewController* controller  = [mainStory instantiateViewControllerWithIdentifier:@"MQCreatOrgMainController"];
        [self presentViewController:controller animated:YES completion:nil];
        
        return;//todo
        
        __block BOOL reg = NO;
        dispatch_queue_t queue = dispatch_queue_create("lqueue", NULL);
        dispatch_async(queue, ^{
            reg = [LoginUser registeUser:_accountName.text mobile:_txtUserName.text code:_smsCode.text password:_txtPwd.text];
            if (reg) {
                
                UIStoryboard* mainStory = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
                UIViewController* controller  = [mainStory instantiateViewControllerWithIdentifier:@"MQCreatOrgMainController"];
                [self presentViewController:controller animated:YES completion:nil];
                
            }
        });
        
        if (reg) {
            NSLog(@"SUCC");
        }

    }

}

- (void)setupTextName:(NSString *)textName frame:(CGRect)frame lblControl:(UILabel*)textNameLabel
{
    textNameLabel.text = textName;
    textNameLabel.font = [UIFont systemFontOfSize:16];
    textNameLabel.textColor = [UIColor whiteColor];
    textNameLabel.frame = frame;
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    //[self diminishTextName:_lblUserName];
    
    _currentField = textField;
    
    if (textField == _txtUserName)
    {
        [_mainScrollView setContentOffset:CGPointMake(0, 100) animated:YES];
        
//        [self diminishTextName:_lblUserName];
//        [self restoreTextName:_lblPwd textField:_txtPwd];
//        [self restoreTextName:_lblInvitation textField:_txtInvitation];
    }
    else if (textField == _txtPwd)
    {
        [_mainScrollView setContentOffset:CGPointMake(0, 100 + 50 * 3 + 30) animated:YES];

//        [self diminishTextName:_lblPwd];
//        [self restoreTextName:_lblUserName textField:_txtUserName];
//        [self restoreTextName:_lblInvitation textField:_txtInvitation];
    }
    else if (textField == _smsCode)
    {
        [_mainScrollView setContentOffset:CGPointMake(0, 100 + 50 + 30) animated:YES];

    }
    else if (textField == _accountName)
    {
        [_mainScrollView setContentOffset:CGPointMake(0, 100 + 50 * 2 + 30) animated:YES];
        
    }
    else if (textField == _txtInvitation)
    {
//        [self diminishTextName:_lblInvitation];
//        [self restoreTextName:_lblPwd textField:_txtPwd];
//        [self restoreTextName:_lblUserName textField:_txtUserName];
    }
    
    return YES;
}
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField == _txtUserName)
    {
        return [_txtPwd becomeFirstResponder];
    }
    else if (textField == _txtPwd)
    {
        return [_txtInvitation becomeFirstResponder];
    }
    else {
        [self restoreTextName:_lblInvitation textField:_txtInvitation];
        return [_txtInvitation resignFirstResponder];
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
            label.font = [UIFont systemFontOfSize:16];
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
    if (_txtUserName.text.length != 0 && _txtPwd.text.length != 0 && _txtInvitation.text.length != 0) {
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
    [self restoreTextName:_lblInvitation textField:_txtInvitation];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
