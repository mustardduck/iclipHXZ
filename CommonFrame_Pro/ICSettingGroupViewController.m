//
//  ICSettingGroupViewController.m
//  CommonFrame_Pro
//
//  Created by ionitech on 15/6/25.
//  Copyright (c) 2015年 ionitech. All rights reserved.
//

#import "ICSettingGroupViewController.h"
#import "UIColor+HexString.h"
#import "UIImageView+UIActivityIndicatorForSDWebImage.h"
//#import <AVOSCloud/AVOSCloud.h>

@interface ICSettingGroupViewController()<UITableViewDataSource,UITableViewDelegate>
{
    IBOutlet UITableView*   _tableView;
    
    NSArray*                _authroyArray;
    BOOL                    _isAdmin;
}

@end

@implementation ICSettingGroupViewController

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
    
    _tableView.dataSource = self;
    _tableView.delegate = self;
    [_tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    

    dispatch_sync(dispatch_queue_create("qu", nil), ^{
        NSString* isAdmin = @"";
        
        NSDictionary * dic = [Group groupDicByWorkGroupId:_workGroup.workGroupId isAdmin:&isAdmin];
        
        NSArray * arr = [self fillAuthroyArr:dic];
        
        if(arr.count)
        {
            _authroyArray = arr;
        }
        
        _isAdmin = ([[NSString stringWithFormat:@"%@",isAdmin] isEqualToString:@""]?NO:[isAdmin boolValue]);
        
        _workGroup.userName = [dic valueForKey:@"userName"];
    });
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if (_workGroup != nil) {
        [_tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
    }
    
    if (_ccopyToMembersArray != nil) {
        NSString* idArrayStr = @"";
        NSString * userArrayStr = @"";
        int i = 0;
        for (Member* m in _ccopyToMembersArray) {
            i++;
            idArrayStr = [NSString stringWithFormat:@"%@%@",idArrayStr,m.orgcontactId];
            userArrayStr = [NSString stringWithFormat:@"%@%@",userArrayStr,m.userId];
            if (i < _ccopyToMembersArray.count) {
                idArrayStr = [NSString stringWithFormat:@"%@%@",idArrayStr,@","];
                userArrayStr = [NSString stringWithFormat:@"%@%@",userArrayStr,@","];

            }
        }
        NSArray *invitedArr = nil;
        if(userArrayStr.length)
        {
            invitedArr = [userArrayStr componentsSeparatedByString:@","];//被邀请的用户ID
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            NSString* loginUserId = [LoginUser loginUserID];
            //NSString* idStr = _txtGroupName.text;
            BOOL isOk = [Group inviteNewUser:loginUserId workGroupId:_workGroupId source:3 sourceValue:idArrayStr];
            if (isOk) {
                
//                1，被邀请加入某一个群组时：
//                （你被XX(用户名)加入了XX(群组名)。）
//                - 点击进入时，进入该群组。
                /*
                NSString * alertStr = [NSString stringWithFormat:@"你被 %@ 加入了 %@ ", [LoginUser loginUserName], _workGroup.workGroupName];
                
                NSDictionary *data = [NSDictionary dictionaryWithObjectsAndKeys:
                                      alertStr, @"alert",
                                      @"Increment", @"badge",
                                      _workGroup.workGroupId, @"workGroupId",
                                      @"inviteToGroup", @"inviteToGroup",
                                      nil];
                
   

                long long usId = 0;
                
                NSMutableArray * userArr = [NSMutableArray array];
                
                for(int i = 0; i < invitedArr.count; i ++)
                {
                    usId = [invitedArr[i] longLongValue];
                    [userArr addObject:@(usId)];
                }
                
                AVPush *push = [[AVPush alloc] init];
                [AVPush setProductionMode:NO];
                
                AVQuery *pushQuery = [AVInstallation query];
                [pushQuery whereKey:@"HXZ_userId" containedIn:userArr];
                [pushQuery whereKey:@"deviceType" equalTo:@"ios"];
                
                [push setChannel:@"HXZ_loginUsers"];
                [push setQuery:pushQuery];
                [push setData:data];
                [push sendPushInBackground];
                 */
                
                UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"已邀请群组成员!" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                [alert show];
                _ccopyToMembersArray = nil;
            }
            
        });
        
    }
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

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    if ([self.icGroupDetailController respondsToSelector:@selector(setGroup:)]) {
        [self.icGroupDetailController setValue:_workGroup forKey:@"group"];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (IBAction)backButtonClicked:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
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

#pragma mark -
#pragma mark Table View Action
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        return 95;
    }
    return 40;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {
        return 1;
    }
    return 3;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 3;
}

- (NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    
    return @"    ";
}

- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = (UITableViewCell *)[tableView cellForRowAtIndexPath:indexPath];
    UIView *selectionColor = [[UIView alloc] init];
    selectionColor.backgroundColor = [UIColor cellHoverBackgroundColor];
    cell.selectedBackgroundView = selectionColor;
    
    CGFloat y = 39;
    
    if(indexPath.row == 0 && indexPath.section == 0)
    {
        y = 94;
    }
    
    UILabel* bottomLine = [[UILabel alloc] initWithFrame:CGRectMake(0, y, [UIScreen mainScreen].bounds.size.width, 0.5)];
    [bottomLine setBackgroundColor:[UIColor grayColor]];
    
    [cell.selectedBackgroundView addSubview:bottomLine];
    
    return YES;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger index = indexPath.row;
    NSInteger section = indexPath.section;
    
    NSString *cellId = @"SettingGroupTableViewCellId";
    UITableViewCell *cell;
    
    if (index == 0 && section == 0) {
        cellId = @"ccSettingGroupTableViewCellId";
        cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    }
    else if (index == 0 && section == 1) {
        cellId = @"SettingGroupTableViewCellIdTo1";
        cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    }
    else if (index == 1 && section == 1) {
        cellId = @"SettingGroupTableViewCellId2";
       cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    }
    else if (index == 2 && section == 1) {
        cellId = @"SettingGroupTableViewCellId3";
        cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    }
    else if (index == 0 && section == 2) {
        cellId = @"SettingGroupTableViewCellId4";
        cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    }
    else if (index == 1 && section == 2) {
        cellId = @"SettingGroupTableViewCellId5";
        cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    }
    else if (index == 2 && section == 2) {
        cellId = @"SettingGroupTableViewCellId6";
        cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    }
    
    if (cell == nil){
           cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
        
        
        UILabel* bottomLine = [[UILabel alloc] initWithFrame:CGRectMake(0, 39, [UIScreen mainScreen].bounds.size.width, 0.5)];
        [bottomLine setBackgroundColor:[UIColor grayColor]];
        
        [cell.contentView addSubview:bottomLine];
        
        UIFont* font = [UIFont systemFontOfSize:14];
        if (index == 0 && section == 0) {
            //cell.textLabel.text = @"SettingGroupTableViewCellId";
            
            CGFloat width = [UIScreen mainScreen].bounds.size.width;
            
            UIImageView* imgView = [[UIImageView alloc] initWithFrame:CGRectMake(11, 11, 67, 67)];
            //[imgView setImage:[UIImage imageNamed:@"icon_touxiang"]];
            [imgView setImageWithURL:[NSURL URLWithString:_workGroup.workGroupImg] placeholderImage:[UIImage imageNamed:@"icon_touxiang"] options:SDWebImageDelayPlaceholder usingActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
            
            [cell.contentView addSubview:imgView];
            
            UILabel* lbl = [[UILabel alloc] initWithFrame:CGRectMake(imgView.frame.size.width + imgView.frame.origin.x + 18, 13, 50 , 13)];
            lbl.text = @"名称";
            lbl.textColor = [UIColor grayColor];
            lbl.font = font;
            lbl.backgroundColor = [UIColor clearColor];
            
            [cell.contentView addSubview:lbl];
            
            UILabel* lbl1 = [[UILabel alloc] initWithFrame:CGRectMake(lbl.frame.origin.x, lbl.frame.origin.y + lbl.frame.size.height + 12, 50 , 13)];
            lbl1.text = @"创建人";
            lbl1.textColor = [UIColor grayColor];
            lbl1.font = font;
            lbl1.backgroundColor = [UIColor clearColor];
            
            [cell.contentView addSubview:lbl1];
            
            UILabel* lbl2 = [[UILabel alloc] initWithFrame:CGRectMake(lbl.frame.origin.x, lbl1.frame.origin.y + lbl1.frame.size.height + 12, 50 , 13)];
            lbl2.text = @"签名";
            lbl2.textColor = [UIColor grayColor];
            lbl2.font = font;
            lbl2.backgroundColor = [UIColor clearColor];
            
            [cell.contentView addSubview:lbl2];
            
            
            UILabel* text = [[UILabel alloc] initWithFrame:CGRectMake(lbl.frame.origin.x + lbl.frame.size.width + 20, 13, width/2 - 10 , 13)];
            text.text = _workGroup.workGroupName;
            text.textColor = [UIColor whiteColor];
            text.font = font;
            text.backgroundColor = [UIColor clearColor];
            
            [cell.contentView addSubview:text];
            
            UILabel* text1 = [[UILabel alloc] initWithFrame:CGRectMake(lbl.frame.origin.x + lbl.frame.size.width + 20, 38, width/2 - 10, 13)];
            text1.text = _workGroup.userName;
            text1.textColor = [UIColor whiteColor];
            text1.font = font;
            text1.backgroundColor = [UIColor clearColor];
            
            [cell.contentView addSubview:text1];
            
            UILabel* text2 = [[UILabel alloc] initWithFrame:CGRectMake(lbl.frame.origin.x + lbl.frame.size.width + 20, 63, width/2 - 10, 13)];
            text2.text = _workGroup.workGroupMain;
            text2.textColor = [UIColor whiteColor];
            text2.font = font;
            text2.backgroundColor = [UIColor clearColor];
            
            [cell.contentView addSubview:text2];
            
            [bottomLine setFrame:CGRectMake(0, 94, [UIScreen mainScreen].bounds.size.width, 0.5)];
            
        }
        else if (index == 0 && section == 1) {
            UILabel* text = [[UILabel alloc] initWithFrame:CGRectMake(12, 13, 120, 13)];
            text.text = @"现有成员";
            text.textColor = [UIColor whiteColor];
            text.font = font;
            text.backgroundColor = [UIColor clearColor];
            
            [cell.contentView addSubview:text];

        }
        else if (index == 1 && section == 1) {
            UILabel* text = [[UILabel alloc] initWithFrame:CGRectMake(12, 13, 120, 13)];
            text.text = @"邀请";
            text.textColor = [UIColor whiteColor];
            text.font = font;
            text.backgroundColor = [UIColor clearColor];
            
            [cell.contentView addSubview:text];
        }
        else if (index == 2 && section == 1) {
            
            UILabel* text = [[UILabel alloc] initWithFrame:CGRectMake(12, 13, 120, 13)];
            text.text = @"成员权限";
            text.textColor = [UIColor whiteColor];
            text.font = font;
            text.backgroundColor = [UIColor clearColor];
            
            [cell.contentView addSubview:text];
        }
        else if (index == 0 && section == 2) {
            UILabel* text = [[UILabel alloc] initWithFrame:CGRectMake(12, 13, 120, 13)];
            text.text = @"新建标签";
            text.textColor = [UIColor whiteColor];
            text.font = font;
            text.backgroundColor = [UIColor clearColor];
            
            [cell.contentView addSubview:text];
        }
        else if (index == 1 && section == 2) {
            UILabel* text = [[UILabel alloc] initWithFrame:CGRectMake(12, 13, 120, 13)];
            text.text = @"现有标签";
            text.textColor = [UIColor whiteColor];
            text.font = font;
            text.backgroundColor = [UIColor clearColor];
            
            [cell.contentView addSubview:text];
        }
        else if (index == 2 && section == 2) {
            UILabel* text = [[UILabel alloc] initWithFrame:CGRectMake(12, 13, 120, 13)];
            text.text = @"标签可见管理";
            text.textColor = [UIColor whiteColor];
            text.font = font;
            text.backgroundColor = [UIColor clearColor];
            
            [cell.contentView addSubview:text];
        }
        
        
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        [cell setBackgroundColor:[UIColor colorWithRed:0.19 green:0.19 blue:0.26 alpha:1.0]];
    }
    
    
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger index = indexPath.row;
    NSInteger section = indexPath.section;
    
    UIStoryboard* mainStory = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    UIViewController* controller;
    if (index == 0 && section == 0) {
        if (_isAdmin) {
            controller  = [mainStory instantiateViewControllerWithIdentifier:@"ICCreateNewGroupViewController"];
            ((ICCreateNewGroupViewController*)controller).viewType = ViewTypeEdit;
            ((ICCreateNewGroupViewController*)controller).workGroup = _workGroup;
            ((ICCreateNewGroupViewController*)controller).icSettingController = self;
            [self.navigationController pushViewController:controller animated:YES];
        }
    }
    else if (index == 0 && section == 1) {
        // 2
        //现有成员
        
        controller = [mainStory instantiateViewControllerWithIdentifier:@"ICMemberTableViewController"];
        ((ICMemberTableViewController*)controller).controllerType = MemberViewFromControllerGroupMembers;
        ((ICMemberTableViewController*)controller).workgid = _workGroupId;
        
        ((ICMemberTableViewController *) controller).justRead = ![self hasAuthory:@"2"];
        
        [self.navigationController pushViewController:controller animated:YES];
        

    }
    else if (index == 1 && section == 1) {
        // 1
        if ([self hasAuthory:@"1"]) {
//            controller  = [mainStory instantiateViewControllerWithIdentifier:@"ICMemberInvitationTableViewController"];
//            ((ICMemberInvitationTableViewController*)controller).workGroupId = _workGroupId;
//            
//            [self.navigationController pushViewController:controller animated:YES];
            
            UIStoryboard* mainStory = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
            UIViewController* vc = [mainStory instantiateViewControllerWithIdentifier:@"ICMemberTableViewController"];
            ((ICMemberTableViewController*)vc).controllerType = MemberViewFromControllerCopyTo;
            ((ICMemberTableViewController*)vc).icPublishMisonController = self;
            
            ((ICMemberTableViewController*)vc).workgid = self.workGroupId;
            
            [self.navigationController pushViewController:vc animated:YES];
        }
        else
        {
            UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"权限不足，因为您不是该工作组创建者！" delegate:self
                                                  cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            [alert show];
        }
    }
    else if (index == 2 && section == 1) {
        // 5
        if ([self hasAuthory:@"5"]) {
            controller  = [mainStory instantiateViewControllerWithIdentifier:@"ICMemberTableViewController"];
            ((ICMemberTableViewController*)controller).controllerType = MemberViewFromControllerAuthority;
            ((ICMemberTableViewController*)controller).workgid = _workGroupId;
            [self.navigationController pushViewController:controller animated:YES];
        }
        else
        {
            UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"权限不足，因为您不是该工作组创建者！" delegate:self
                                                  cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            [alert show];
        }

    }
    else if (index == 0 && section == 2) {
        // 3
        if ([self hasAuthory:@"3"]) {
            controller  = [mainStory instantiateViewControllerWithIdentifier:@"ICCreateMarkViewController"];
            ((ICCreateMarkViewController*)controller).workGroupId = _workGroupId;
            [self.navigationController pushViewController:controller animated:YES];
        }
        else
        {
            UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"权限不足，因为您不是该工作组创建者！" delegate:self
                                                  cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            [alert show];
        }
    }
    else if (index == 1 && section == 2) {
        // 6
        //现有标签
        controller  = [mainStory instantiateViewControllerWithIdentifier:@"ICMarkManagementViewController"];
        ((ICMarkManagementViewController*)controller).workGroupId = _workGroupId;
        ((ICMarkManagementViewController *) controller).justRead = ![self hasAuthory:@"6"];
        [self.navigationController pushViewController:controller animated:YES];
 
    }
    else if (index == 2 && section == 2) {
        // 7
        if ([self hasAuthory:@"7"]) {
            controller  = [mainStory instantiateViewControllerWithIdentifier:@"ICMarkListViewController"];
            ((ICMarkListViewController*)controller).workGroupId = _workGroupId;
            ((ICMarkListViewController*)controller).isSetting = YES;
            [self.navigationController pushViewController:controller animated:YES];
        }
        else
        {
            UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"权限不足，因为您不是该工作组创建者！" delegate:self
                                                  cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            [alert show];
        }
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 20;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 24;
}


- (UIView*)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    UIView* myView = [[UIView alloc] init];
    
    return myView;
}

- (UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView* myView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 24)];
    myView.backgroundColor = tableView.backgroundColor;
    
    if (section != 0) {
        myView.backgroundColor = [UIColor colorWithRed:0.36 green:0.48 blue:0.84 alpha:1.0];
        UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 1, 120, 22)];
        titleLabel.textColor=[UIColor whiteColor];
        titleLabel.backgroundColor = [UIColor clearColor];
        titleLabel.font = [UIFont systemFontOfSize:14];
        if (section == 1) {
            titleLabel.text=@"成员管理";
        }
        else if (section == 2) {
            titleLabel.text=@"群组标签管理";
        }
        [myView addSubview:titleLabel];
        
        myView.backgroundColor = [UIColor colorWithHexString:@"#5a70df"];
    }
    
    UILabel* bottomLine = [[UILabel alloc] initWithFrame:CGRectMake(0, 23.5, [UIScreen mainScreen].bounds.size.width, 0.5)];
    [bottomLine setBackgroundColor:[UIColor grayColor]];
    
    [myView addSubview:bottomLine];
    
    return myView;
}

@end
