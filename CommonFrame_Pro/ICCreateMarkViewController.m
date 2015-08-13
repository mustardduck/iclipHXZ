//
//  ICCreateMarkViewController.m
//  CommonFrame_Pro
//
//  Created by ionitech on 15/6/26.
//  Copyright (c) 2015年 ionitech. All rights reserved.
//

#import "ICCreateMarkViewController.h"

#import "InputText.h"

@interface ICCreateMarkViewController()<InputTextDelegate,UITextFieldDelegate>
{
    IBOutlet UIView* _contentView;
    
    UILabel*        _lblGroupName;
    UITextField*    _txtGroupName;

}
@property (nonatomic,assign) BOOL chang;

@end

@implementation ICCreateMarkViewController

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
    UIBarButtonItem *leftBarButton = [[UIBarButtonItem alloc]initWithCustomView:leftButton];
    self.navigationItem.leftBarButtonItem = leftBarButton;
    
    if (self.viewType == ViewTypeEmail) {
        self.navigationItem.title = @"邮箱邀请";
        
        UIBarButtonItem* rightBarButton = [[UIBarButtonItem alloc] initWithTitle:@"提交" style:UIBarButtonItemStyleDone target:self action:@selector(doneButtonClicked:)];
        [rightBarButton setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor whiteColor],NSFontAttributeName:[UIFont systemFontOfSize:17]} forState:UIControlStateNormal];
        self.navigationItem.rightBarButtonItem = rightBarButton;
    }
    
    
    CGFloat width = [UIScreen mainScreen].bounds.size.width;
    CGFloat top = 0;
    
    UILabel* line = [[UILabel alloc] initWithFrame:CGRectMake(0, top, width, 0)];
    [line setBackgroundColor:[UIColor grayColor]];
    [_contentView addSubview:line];
    
    UILabel* line1 = [[UILabel alloc] initWithFrame:CGRectMake(0, top + 40.5, width, 0.5)];
    [line1 setBackgroundColor:[UIColor grayColor]];
    [_contentView addSubview:line1];
  
    
    UIImageView* img = [[UIImageView alloc] initWithFrame:CGRectMake(10, line.frame.origin.y + 14, 17, 15)];
    [img setBackgroundColor:[UIColor clearColor]];
    [img setImage:[UIImage imageNamed:@"btn_renwu_6"]];
    [_contentView addSubview:img];
    
    
    InputText *inputText = [[InputText alloc] init];
    inputText.delegate = self;
    
    _txtGroupName = [[UITextField alloc] initWithFrame:CGRectMake(35, line.frame.origin.y + 5, width - 45, 30)];
    [_txtGroupName setBackgroundColor:[UIColor orangeColor]];
    [_txtGroupName setBorderStyle:UITextBorderStyleNone];
    [_txtGroupName setFont:[UIFont systemFontOfSize:15]];
    [_txtGroupName setTextColor:[UIColor whiteColor]];
    [_txtGroupName addTarget:self action:@selector(textFieldDidChange) forControlEvents:UIControlEventEditingChanged];
    _txtGroupName.delegate = self;
    
    _txtGroupName = [inputText setupWithIcon:nil  point:nil  textFieldControl:_txtGroupName showBottomLine:NO];
    
    _lblGroupName = [[UILabel alloc] init];
    if (_viewType == ViewTypeMark)
        _lblGroupName.text = @"新建标签";
    else
        _lblGroupName.text = @"输入邮箱";
    _lblGroupName.font = [UIFont systemFontOfSize:14];
    _lblGroupName.textColor = [UIColor grayColor];
    _lblGroupName.frame = _txtGroupName.frame;
    
    [_contentView addSubview:_txtGroupName];
    [_contentView addSubview:_lblGroupName];

    
    [_contentView setBackgroundColor:[UIColor colorWithHexString:@"#2f2e33"]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)backButtonClicked:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)doneButtonClicked:(id)sender
{
   
    NSString* lblName = _txtGroupName.text;
    
    if (lblName == nil || [lblName isEqualToString:@""]) {
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"请输入需要录入的内容!" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
        return;
    }
    
    if (self.viewType == ViewTypeEmail) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
             NSString* loginUserId = [LoginUser loginUserID];
            BOOL isOk = [Group inviteNewUser:loginUserId workGroupId:_workGroupId source:2 sourceValue:lblName];
            if (isOk) {
                UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"提示" message:[NSString stringWithFormat:@"已邀请邮箱为 %@ 的用户加入群组!",lblName] delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                [alert show];
                
            }

        });
        
    }
    else
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            
            BOOL isOk = [Mark createNewMark:lblName workGroupID:_workGroupId];
            if (isOk) {
                UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"成功" message:[NSString stringWithFormat:@"已创建标签 %@!",lblName] delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                [alert show];
                
            }
            
        });
    }
    _txtGroupName.text = @"";
    [self.view endEditing:YES];
    [self restoreTextName:_lblGroupName textField:_txtGroupName];
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - UITextFieldDelegate
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    //[self diminishTextName:_lblGroupName];
    
    if (textField == _txtGroupName)
    {
        [self diminishTextName:_lblGroupName];
    }
    return YES;
}
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
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
    
}

#pragma mark - touchesBegan
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.view endEditing:YES];
    [self restoreTextName:_lblGroupName textField:_txtGroupName];
}

@end
