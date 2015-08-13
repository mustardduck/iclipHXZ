//
//  ICMemberRegisterViewController.m
//  CommonFrame_Pro
//
//  Created by ionitech on 15/6/29.
//  Copyright (c) 2015年 ionitech. All rights reserved.
//

#import "ICMemberRegisterViewController.h"
#import "InputText.h"

@interface ICMemberRegisterViewController() <InputTextDelegate,UITextFieldDelegate>
{
    UILabel*        _lblUserName;
    UITextField*    _txtUserName;
    
    UILabel*        _lblPwd;
    UITextField*    _txtPwd;
    
    UILabel*        _lblInvitation;
    UITextField*    _txtInvitation;
    
    IBOutlet  UIButton*       _btnSubmit;
    
    IBOutlet UINavigationBar*       _navBar;

}

@property (nonatomic,assign) BOOL chang;

@end

@implementation ICMemberRegisterViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    UIButton *leftButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 70, 20)];
    [leftButton addTarget:self action:@selector(backButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    UIImageView* imgview = [[UIImageView alloc] initWithFrame:CGRectMake(0, 1, 10, 18)];
    [imgview setImage:[UIImage imageNamed:@"btn_fanhui"]];
    [leftButton addSubview:imgview];
    UILabel* ti = [[UILabel alloc] initWithFrame:CGRectMake(18, 0, 80, 20)];
    [ti setBackgroundColor:[UIColor clearColor]];
    [ti setTextColor:[UIColor whiteColor]];
    [ti setText:@"返回登录"];
    [ti setFont:[UIFont systemFontOfSize:17]];
    [leftButton addSubview:ti];
    
    UIBarButtonItem *leftBarButton = [[UIBarButtonItem alloc]initWithCustomView:leftButton];
    UINavigationItem *item = [[UINavigationItem alloc] initWithTitle:@"注册"];
    [item setLeftBarButtonItem:leftBarButton];
    [_navBar pushNavigationItem:item animated:YES];
    
    CGFloat width = [UIScreen mainScreen].bounds.size.width;
    CGFloat height = 66;
    
    
    
    InputText *inputText = [[InputText alloc] init];
    inputText.delegate = self;
    
    UILabel* bottomLine1 = [[UILabel alloc] initWithFrame:CGRectMake(0,  height - 1, width, 0.5)];
    [bottomLine1 setBackgroundColor:[UIColor grayColor]];
    [self.view addSubview:bottomLine1];
    
    UIImageView* imgName = [[UIImageView alloc] initWithFrame:CGRectMake(10, height + 12, 17, 20)];
    [imgName setImage:[UIImage imageNamed:@"btn_renwu_1"]];
    [self.view addSubview:imgName];
    
    _txtUserName = [[UITextField alloc] initWithFrame:CGRectMake(40, height, width - 20, 44)];
    [_txtUserName setBackgroundColor:[UIColor orangeColor]];
    [_txtUserName setBorderStyle:UITextBorderStyleNone];
    [_txtUserName setFont:[UIFont systemFontOfSize:17]];
    [_txtUserName setTextColor:[UIColor whiteColor]];
    [_txtUserName addTarget:self action:@selector(textFieldDidChange) forControlEvents:UIControlEventEditingChanged];
    _txtUserName.delegate = self;
    
    _txtUserName = [inputText setupWithIcon:nil  point:nil  textFieldControl:_txtUserName showBottomLine:NO];
    
    _lblUserName = [[UILabel alloc] init];
    _lblUserName.text = @"输入邮箱/手机号";
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

-(void)btnRegClicked:(id)sender
{
    __block BOOL reg = NO;
    dispatch_queue_t queue = dispatch_queue_create("lqueue", NULL);
    dispatch_async(queue, ^{
        reg = [LoginUser registeNewUser:2 sourceVale:_txtUserName.text inviteCode:_txtInvitation.text password:_txtPwd.text];
        if (reg) {
            [self dismissViewControllerAnimated:YES completion:nil];
        }
    });
    
    if (reg) {
        NSLog(@"SUCC");
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
    
    if (textField == _txtUserName)
    {
        [self diminishTextName:_lblUserName];
        [self restoreTextName:_lblPwd textField:_txtPwd];
        [self restoreTextName:_lblInvitation textField:_txtInvitation];
    }
    else if (textField == _txtPwd)
    {
        [self diminishTextName:_lblPwd];
        [self restoreTextName:_lblUserName textField:_txtUserName];
        [self restoreTextName:_lblInvitation textField:_txtInvitation];
    }
    else if (textField == _txtInvitation)
    {
        [self diminishTextName:_lblInvitation];
        [self restoreTextName:_lblPwd textField:_txtPwd];
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

- (IBAction)backButtonClicked:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}


@end
