//
//  MQMemberDetailVC.m
//  CommonFrame_Pro
//
//  Created by 倩 莫 on 16/2/1.
//  Copyright © 2016年 ionitech. All rights reserved.
//

#import "MQMemberDetailVC.h"
#import "UIImageView+UIActivityIndicatorForSDWebImage.h"
#import "UICommon.h"
#import "ICMemberInfoViewController.h"
#import "MQMemberTagSettingVC.h"
#import "MQMemberAuthSettingVC.h"

@interface MQMemberDetailVC ()

@property (weak, nonatomic) IBOutlet UIImageView *photoImgView;
@property (weak, nonatomic) IBOutlet UILabel *userNameLbl;
@property (weak, nonatomic) IBOutlet UILabel *jobLbl;
@property (weak, nonatomic) IBOutlet UILabel *telLbl;
@property (weak, nonatomic) IBOutlet UILabel *emailLbl;
@property (weak, nonatomic) IBOutlet UIButton *phoneBtn;
@property (weak, nonatomic) IBOutlet UIButton *personInfoBtn;
@property (weak, nonatomic) IBOutlet UIButton *tagBtn;
@property (weak, nonatomic) IBOutlet UIButton *authorityBtn;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *phoneBtnWidthCons;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *personInfoBtnWidthCons;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *tagBtnWidthCons;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *authorityBtnWidthCons;

@end

@implementation MQMemberDetailVC

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

    [self setViewData];
}

- (void) setViewData
{
    [_photoImgView setImageWithURL:[NSURL URLWithString:_member.img] placeholderImage:[UIImage imageNamed:@"icon_touxiang"] options:SDWebImageDelayPlaceholder usingActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    
    [_photoImgView setRoundCorner:3.3];
    
    _jobLbl.text = _member.duty;
    _userNameLbl.text = _member.name;
    _telLbl.text = _member.mobile;
    _emailLbl.text = _member.email.length ? _member.email : @"未填写";
    
    [_phoneBtn setRoundColorCorner:3.3 withColor:[UIColor grayLineColor]];
    [_personInfoBtn setRoundColorCorner:3.3 withColor:[UIColor grayLineColor]];
    [_tagBtn setRoundColorCorner:3.3 withColor:[UIColor grayLineColor]];
    [_authorityBtn setRoundColorCorner:3.3 withColor:[UIColor grayLineColor]];
    
    _phoneBtnWidthCons.constant = (SCREENWIDTH - 14 * 5) / 4;
    _personInfoBtnWidthCons.constant = _phoneBtnWidthCons.constant;
    _tagBtnWidthCons.constant = _phoneBtnWidthCons.constant;
    _authorityBtnWidthCons.constant = _phoneBtnWidthCons.constant;
    
    if(SCREENWIDTH == 320)
    {
        _phoneBtn.titleLabel.font = Font(14);
        _personInfoBtn.titleLabel.font = Font(14);
        _tagBtn.titleLabel.font = Font(14);
        _authorityBtn.titleLabel.font = Font(14);

    }
    
    _tagBtn.hidden = !_canSetTagAuth;
    _authorityBtn.hidden = !_canSetAuth;
}

- (IBAction)btnBackButtonClicked:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)touchUpInsideOnBtn:(id)sender
{
    UIStoryboard* mainStory = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    
    if(sender == _phoneBtn)
    {
        NSString * telStr = [NSString stringWithFormat:@"tel://%@", _member.mobile];
        
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:telStr]];
    }
    else if (sender == _personInfoBtn)
    {
        UIViewController* vc = [mainStory instantiateViewControllerWithIdentifier:@"ICMemberInfoViewController"];
        ((ICMemberInfoViewController*)vc).memberObj = _member;
        [self.navigationController pushViewController:vc animated:YES];
    }
    else if (sender == _tagBtn)
    {
        UIViewController* vc = [mainStory instantiateViewControllerWithIdentifier:@"MQMemberTagSettingVC"];
        ((MQMemberTagSettingVC*)vc).workGroupId = _member.workGroupId;
        ((MQMemberTagSettingVC*)vc).workContactsId = _member.workContractsId;
        [self.navigationController pushViewController:vc animated:YES];
    }
    else if (sender == _authorityBtn)
    {
        UIViewController* vc = [mainStory instantiateViewControllerWithIdentifier:@"MQMemberAuthSettingVC"];

        ((MQMemberAuthSettingVC*)vc).workGroupId = _member.workGroupId;
        ((MQMemberAuthSettingVC*)vc).workContactsId = _member.workContractsId;
        ((MQMemberAuthSettingVC*)vc).member = _member;
        ((MQMemberAuthSettingVC*)vc).workGroup = _workGroup;

        [self.navigationController pushViewController:vc animated:YES];
        
    }
}

@end
