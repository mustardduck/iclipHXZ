//
//  ICAccountViewController.m
//  CommonFrame_Pro
//
//  Created by ionitech on 15/6/4.
//  Copyright (c) 2015年 ionitech. All rights reserved.
//

#import "ICAccountViewController.h"

@interface ICAccountViewController ()<InputTextDelegate,UITextFieldDelegate>
{
     UILabel*        _lblOldPwd;
     UITextField*    _txtOldPwd;
    
     UILabel*        _lblNewPwd;
     UITextField*    _txtNewPwd;
    
     UILabel*        _lblConformNewPwd;
     UITextField*    _txtConformNewPwd;
    
    UIButton*       _btnSubmit;
    
}

@property (nonatomic,assign) BOOL chang;


@end

@implementation ICAccountViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
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
    
    
    CGFloat width = [UIScreen mainScreen].bounds.size.width;
    CGFloat height = 66;
    

    InputText *inputText = [[InputText alloc] init];
    inputText.delegate = self;
    
    UILabel* bottomLine1 = [[UILabel alloc] initWithFrame:CGRectMake(0,  height - 0.5, width, 0.5)];
    [bottomLine1 setBackgroundColor:[UIColor whiteColor]];
    [self.view addSubview:bottomLine1];
    
    _txtOldPwd = [[UITextField alloc] initWithFrame:CGRectMake(10, height, width - 20, 44)];
    [_txtOldPwd setBackgroundColor:[UIColor orangeColor]];
    [_txtOldPwd setBorderStyle:UITextBorderStyleNone];
    [_txtOldPwd setFont:[UIFont systemFontOfSize:17]];
    [_txtOldPwd setTextColor:[UIColor whiteColor]];
    [_txtOldPwd setSecureTextEntry:YES];
    [_txtOldPwd addTarget:self action:@selector(textFieldDidChange) forControlEvents:UIControlEventEditingChanged];
    _txtOldPwd.delegate = self;
    
    _txtOldPwd = [inputText setupWithIcon:nil  point:nil  textFieldControl:_txtOldPwd showBottomLine:NO];

    _lblOldPwd = [[UILabel alloc] init];
    _lblOldPwd.text = @"旧密码";
    _lblOldPwd.font = [UIFont systemFontOfSize:16];
    _lblOldPwd.textColor = [UIColor grayColor];
    _lblOldPwd.frame = _txtOldPwd.frame;
    
    [self.view addSubview:_txtOldPwd];
    [self.view addSubview:_lblOldPwd];
    
    UILabel* bottomLine = [[UILabel alloc] initWithFrame:CGRectMake(0,  _txtOldPwd.frame.size.height + height, width, 0.5)];
    [bottomLine setBackgroundColor:[UIColor whiteColor]];
    [self.view addSubview:bottomLine];
    
    _txtNewPwd = [[UITextField alloc] initWithFrame:CGRectMake(10, _txtOldPwd.frame.size.height + height + 0.5, width - 20, 44)];
    [_txtNewPwd setBackgroundColor:[UIColor orangeColor]];
    [_txtNewPwd setBorderStyle:UITextBorderStyleNone];
    [_txtNewPwd setFont:[UIFont systemFontOfSize:17]];
    [_txtNewPwd setTextColor:[UIColor whiteColor]];
     [_txtNewPwd setSecureTextEntry:YES];
    [_txtNewPwd addTarget:self action:@selector(textFieldDidChange) forControlEvents:UIControlEventEditingChanged];
    _txtNewPwd.delegate = self;
    
    _txtNewPwd = [inputText setupWithIcon:nil  point:nil  textFieldControl:_txtNewPwd showBottomLine:NO];
    
    _lblNewPwd = [[UILabel alloc] init];
    _lblNewPwd.text = @"新密码";
    _lblNewPwd.font = [UIFont systemFontOfSize:16];
    _lblNewPwd.textColor = [UIColor grayColor];
    _lblNewPwd.frame = _txtNewPwd.frame;
    
    [self.view addSubview:_txtNewPwd];
    [self.view addSubview:_lblNewPwd];
    
    
    UILabel* bottomLine2 = [[UILabel alloc] initWithFrame:CGRectMake(0,  _txtNewPwd.frame.origin.y  + 43.5, width, 0.5)];
    [bottomLine2 setBackgroundColor:[UIColor whiteColor]];
    [self.view addSubview:bottomLine2];
    
    _txtConformNewPwd = [[UITextField alloc] initWithFrame:CGRectMake(10, _txtNewPwd.frame.origin.y + 45, width - 20, 44)];
    [_txtConformNewPwd setBackgroundColor:[UIColor orangeColor]];
    [_txtConformNewPwd setBorderStyle:UITextBorderStyleNone];
    [_txtConformNewPwd setFont:[UIFont systemFontOfSize:17]];
    [_txtConformNewPwd setTextColor:[UIColor whiteColor]];
     [_txtConformNewPwd setSecureTextEntry:YES];
    [_txtConformNewPwd addTarget:self action:@selector(textFieldDidChange) forControlEvents:UIControlEventEditingChanged];
    _txtConformNewPwd.delegate = self;
    
    _txtConformNewPwd = [inputText setupWithIcon:nil  point:nil  textFieldControl:_txtConformNewPwd showBottomLine:NO];
    
    _lblConformNewPwd = [[UILabel alloc] init];
    _lblConformNewPwd.text = @"确认密码";
    _lblConformNewPwd.font = [UIFont systemFontOfSize:16];
    _lblConformNewPwd.textColor = [UIColor grayColor];
    _lblConformNewPwd.frame = _txtConformNewPwd.frame;
    
    [self.view addSubview:_txtConformNewPwd];
    [self.view addSubview:_lblConformNewPwd];
    
    
    UILabel* bottomLine3 = [[UILabel alloc] initWithFrame:CGRectMake(0,  _txtConformNewPwd.frame.origin.y + 45.5, width, 0.5)];
    [bottomLine3 setBackgroundColor:[UIColor whiteColor]];
    [self.view addSubview:bottomLine3];
    
    
    _btnSubmit = [[UIButton alloc] initWithFrame:CGRectMake(0, bottomLine3.frame.origin.y + 100, width, 44)];
    [_btnSubmit setBackgroundColor:[UIColor colorWithRed:0.16f green:0.29f blue:0.47f alpha:1.0f]];
    [_btnSubmit setTitle:@"确认" forState:UIControlStateNormal];
    [_btnSubmit setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_btnSubmit setTitleColor:[UIColor grayColor] forState:UIControlStateHighlighted];
    [_btnSubmit addTarget: self action:@selector(btnSubmitClicked) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:_btnSubmit];
}

- (void)btnSubmitClicked
{
    NSString* old = _txtOldPwd.text;
    NSString* pwd1 = _txtNewPwd.text;
    NSString* pwd2 = _txtConformNewPwd.text;
    
    if ((old == nil || [old isEqualToString:@""]) || (pwd1 == nil || [pwd1 isEqualToString:@""]) || (pwd2 == nil || [pwd2 isEqualToString:@""]) ) {
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"密码输入错误" message:@"密码不能为空!" delegate:self
                                              cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
        return;
    }
    
    if (![pwd1 isEqualToString:pwd2]) {
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"密码输入错误" message:@"两次密码输入不一致!请重新输入!" delegate:self
                                              cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
        _txtNewPwd.text = @"";
        _txtConformNewPwd.text = @"";
        
        return;
    }
    
    BOOL isOk = [LoginUser changePwd:old newPassword:pwd1];
    
    if (isOk) {
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"成功" message:@"密码修改成功!" delegate:self
                                              cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
        
        _txtOldPwd.text = @"";
        _txtNewPwd.text = @"";
        _txtConformNewPwd.text = @"";
    }
    
    NSLog(@"btn clicked");
}

- (void)setupTextName:(NSString *)textName frame:(CGRect)frame lblControl:(UILabel*)textNameLabel
{
    textNameLabel = [[UILabel alloc] init];
    textNameLabel.text = textName;
    textNameLabel.font = [UIFont systemFontOfSize:16];
    textNameLabel.textColor = [UIColor whiteColor];
    textNameLabel.frame = frame;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (IBAction)backButtonClicked:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - UITextFieldDelegate
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    //[self diminishTextName:_lblOldPwd];
    
    if (textField == _txtOldPwd)
    {
        [self diminishTextName:_lblOldPwd];
        [self restoreTextName:_lblNewPwd textField:_txtNewPwd];
        [self restoreTextName:_lblConformNewPwd textField:_txtConformNewPwd];
    }
    else if (textField == _txtNewPwd)
    {
        [self diminishTextName:_lblNewPwd];
        [self restoreTextName:_lblOldPwd textField:_txtOldPwd];
        [self restoreTextName:_lblConformNewPwd textField:_txtConformNewPwd];
    }
    else if (textField == _txtConformNewPwd)
    {
        [self diminishTextName:_lblConformNewPwd];
        [self restoreTextName:_lblNewPwd textField:_txtNewPwd];
        [self restoreTextName:_lblOldPwd textField:_txtOldPwd];
    }
    
    return YES;
}
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField == _txtOldPwd)
    {
        return [_txtNewPwd becomeFirstResponder];
    }
    else if (textField == _txtNewPwd)
    {
        return [_txtConformNewPwd becomeFirstResponder];
    }
    else {
        [self restoreTextName:_lblConformNewPwd textField:_txtConformNewPwd];
        return [_txtConformNewPwd resignFirstResponder];
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
    if (_txtOldPwd.text.length != 0 && _txtNewPwd.text.length != 0 && _txtConformNewPwd.text.length != 0) {
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
    [self restoreTextName:_lblOldPwd textField:_txtOldPwd];
    [self restoreTextName:_lblNewPwd textField:_txtNewPwd];
    [self restoreTextName:_lblConformNewPwd textField:_txtConformNewPwd];
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
