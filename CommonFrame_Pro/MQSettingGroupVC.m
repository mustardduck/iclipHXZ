//
//  MQSettingGroupVC.m
//  CommonFrame_Pro
//
//  Created by 倩 莫 on 16/1/28.
//  Copyright © 2016年 ionitech. All rights reserved.
//

#import "MQSettingGroupVC.h"
#import "UICommon.h"
#import "ICCreateNewGroupViewController.h"
#import "MQCreateNewGroupVC.h"
#import "WorkPlanMainController.h"
#import "MQMemberTableVC.h"
#import "MQTagEditVC.h"

@interface MQSettingGroupVC ()
{
    NSArray*                _authroyArray;

    BOOL                    _isAdmin;

}
@property (weak, nonatomic) IBOutlet UILabel *groupNameLbl;
@property (weak, nonatomic) IBOutlet UILabel *memberLbl;
@property (weak, nonatomic) IBOutlet UILabel *sloganLbl;
@property (weak, nonatomic) IBOutlet UILabel *memCountLbl;
@property (weak, nonatomic) IBOutlet UILabel *tagCountLbl;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *memberCons;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *tagCons;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *fileCons;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *planCons;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *sloganTopCons;
@property (weak, nonatomic) IBOutlet UIImageView *editGroupIcon;

@property (weak, nonatomic) IBOutlet UIButton *editGroupBtn;

@end

@implementation MQSettingGroupVC

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
    UIBarButtonItem *leftBarButton = [[UIBarButtonItem alloc]initWithCustomView:leftButton];
    self.navigationItem.leftBarButtonItem = leftBarButton;
    
    _groupNameLbl.text = _workGroup.workGroupName;
    _memberLbl.text = [NSString stringWithFormat:@"成员：%@人", _workGroup.workGroupPeopleNum];
    _sloganLbl.text = _workGroup.workGroupMain;
    
    CGSize size = CGSizeMake(SCREENWIDTH - 110, 52);
    
    CGFloat sloganH = [UICommon getSizeFromString:_sloganLbl.text withSize:size withFont:_sloganLbl.font].height;
    
    if(sloganH < 20)
    {
        _sloganTopCons.constant = -7;
    }
    
    _memCountLbl.text = [NSString stringWithFormat:@"成员(%@)", _workGroup.workGroupPeopleNum];
    
    _tagCountLbl.text = [NSString stringWithFormat:@"标签(%@)", _workGroup.workGroupLabelNum];
    
    if(SCREENWIDTH == 375)
    {
        _memberCons.constant = SCREENWIDTH / 4;
    }
    else if (SCREENWIDTH == 414)
    {
        _memberCons.constant = SCREENWIDTH / 4;
    }
    
    _tagCons.constant = _memberCons.constant;
    _fileCons.constant = _memberCons.constant;
    _planCons.constant = _memberCons.constant;
    
    dispatch_sync(dispatch_queue_create("qu", nil), ^{
        NSString* isAdmin = @"";
        
        NSDictionary * dic = [Group groupDicByWorkGroupId:_workGroup.workGroupId isAdmin:&isAdmin];
        
        NSArray * arr = [self fillAuthroyArr:dic];
        
        if(arr.count)
        {
            _authroyArray = arr;
        }
        
        _isAdmin = ([[NSString stringWithFormat:@"%@",isAdmin] isEqualToString:@""]?NO:[isAdmin boolValue]);
        
        if(!_isAdmin)
        {
            _editGroupBtn.hidden = YES;
            _editGroupIcon.hidden = YES;
        }
        
    });
}

- (NSArray *)fillAuthroyArr:(NSDictionary *)dArr
{
    NSMutableArray * array = [NSMutableArray array];
    
    id listArr = [dArr valueForKey:@"list"];
    
    if ([listArr isKindOfClass:[NSArray class]])
    {
        for (id data in listArr) {
            if ([data isKindOfClass:[NSDictionary class]]) {
                
                NSDictionary* di = (NSDictionary*)data;
                
                Group* cm = [Group new];
                
                cm.workGroupId = [di valueForKey:@"wgRoleId"];
                cm.workGroupName = [di valueForKey:@"wgRoleName"];
                
                [array addObject:cm];
                
            }
        }
    }
    
    return array;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)backButtonClicked:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)clickEditGroup:(id)sender {
    
//    UIStoryboard* mainStory = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
//    UIViewController* controller  = [mainStory instantiateViewControllerWithIdentifier:@"ICCreateNewGroupViewController"];
//    ((ICCreateNewGroupViewController*)controller).viewType = ViewTypeEdit;
//    ((ICCreateNewGroupViewController*)controller).workGroup = _workGroup;
//    ((ICCreateNewGroupViewController*)controller).icSettingController = self;
//    [self.navigationController pushViewController:controller animated:YES];
    
    UIStoryboard* mainStory = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    UIViewController* controller  = [mainStory instantiateViewControllerWithIdentifier:@"MQCreateNewGroupVC"];
    ((MQCreateNewGroupVC*)controller).viewType = ViewTypeEdit;
    ((MQCreateNewGroupVC*)controller).workGroup = _workGroup;
    ((MQCreateNewGroupVC*)controller).icSettingController = self;
    [self.navigationController pushViewController:controller animated:YES];
    
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    if(_workGroup)
    {
        _groupNameLbl.text = _workGroup.workGroupName;
        _memberLbl.text = [NSString stringWithFormat:@"成员：%@人", _workGroup.workGroupPeopleNum];
        _sloganLbl.text = _workGroup.workGroupMain;
    }
}

- (IBAction)clickMember:(id)sender {
    
    UIStoryboard* mainStory = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    UIViewController* vc = [mainStory instantiateViewControllerWithIdentifier:@"MQMemberTableVC"];
    if ([self hasAuthory:@"5"])
    {
        ((MQMemberTableVC*)vc).canDelete = YES;
        ((MQMemberTableVC*)vc).canSetAuth = YES;
    }
    if ([self hasAuthory:@"1"])
    {
        ((MQMemberTableVC*)vc).canInvite = YES;
    }
    if ([self hasAuthory:@"7"])
    {
        ((MQMemberTableVC*)vc).canSetTagAuth = YES;
    }
    
    ((MQMemberTableVC*)vc).controllerType = MemberViewFromControllerAuthority;
    ((MQMemberTableVC*)vc).workGroup = _workGroup;
    [self.navigationController pushViewController:vc animated:YES];
}

- (BOOL)hasAuthory:(NSString*)auid
{
    for (Group* g in _authroyArray) {
        if ([[NSString stringWithFormat:@"%@",g.workGroupId] isEqualToString:auid]) {
            return YES;
        }
    }
    return NO;
}

- (IBAction)clickTag:(id)sender {
    

    
    UIStoryboard* mainStory = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    UIViewController* vc = [mainStory instantiateViewControllerWithIdentifier:@"MQTagEditVC"];
    
    if ([self hasAuthory:@"3"])//可以新增标签
    {
        ((MQTagEditVC*)vc).canCreate = YES;
    }
    if ([self hasAuthory:@"6"])//可以编辑标签
    {
        ((MQTagEditVC*)vc).canEdit = YES;
    }
    
    ((MQTagEditVC*)vc).workGroup = _workGroup;
    [self.navigationController pushViewController:vc animated:YES];
    
}
- (IBAction)clickFile:(id)sender {
    UIStoryboard* mainStory = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    UIViewController* vc = [mainStory instantiateViewControllerWithIdentifier:@"ICFileViewController"];
    ((ICFileViewController *)vc).workGroupId = _workGroup.workGroupId;
    ((ICFileViewController *)vc).isRead = YES;

    [self.navigationController pushViewController:vc animated:YES];
}

- (IBAction)clickPlan:(id)sender {
    
    UIStoryboard* mainStory = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    UIViewController* controller  = [mainStory instantiateViewControllerWithIdentifier:@"WorkPlanMainController"];
    ((WorkPlanMainController*)controller).workGroupName = _workGroup.workGroupName;
    ((WorkPlanMainController*)controller).workGroupId = _workGroup.workGroupId;
    [self.navigationController pushViewController:controller animated:YES];
    
}


@end
