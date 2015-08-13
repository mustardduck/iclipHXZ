//
//  ICMemberInvitationTableViewController.m
//  CommonFrame_Pro
//
//  Created by ionitech on 15/6/26.
//  Copyright (c) 2015年 ionitech. All rights reserved.
//

#import "ICMemberInvitationTableViewController.h"
#import <AddressBookUI/AddressBookUI.h>

@interface ICMemberInvitationTableViewController() <UITableViewDataSource,UITableViewDelegate,ABPeoplePickerNavigationControllerDelegate>
{
    __weak IBOutlet UITableView* _tableView;
}

@end

@implementation ICMemberInvitationTableViewController

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
    
    
    _tableView.delegate = self;
    _tableView.dataSource = self;
    [_tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    [self setExtraCellLineHidden:_tableView];
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if (_ccopyToMembersArray != nil) {
        NSString* idArrayStr = @"";
        int i = 0;
        for (Member* m in _ccopyToMembersArray) {
            i++;
            idArrayStr = [NSString stringWithFormat:@"%@%@",idArrayStr,m.orgcontactId];
            if (i < _ccopyToMembersArray.count) {
                idArrayStr = [NSString stringWithFormat:@"%@%@",idArrayStr,@","];
            }
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            NSString* loginUserId = [LoginUser loginUserID];
            //NSString* idStr = _txtGroupName.text;
            BOOL isOk = [Group inviteNewUser:loginUserId workGroupId:_workGroupId source:3 sourceValue:idArrayStr];
            if (isOk) {
                UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"已邀请群组成员!" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                [alert show];
                _ccopyToMembersArray = nil;
            }
            
        });

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

#pragma mark -
#pragma mark Table View Action

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 3;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger index = indexPath.row;
    
    NSString *cellId = @"MemberInvitationTableViewCellId";
    UITableViewCell *cell;
    
    if (index == 0) {
        cellId = @"MemberInvitationTableViewCellId";
        cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    }
    else if (index == 1) {
        cellId = @"MemberInvitationTableViewCellId1";
        cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    }
    else if (index == 2) {
        cellId = @"MemberInvitationTableViewCellId2";
        cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    }
    
    if (cell == nil){
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
        
    }
    
    UILabel* bottomLine = [[UILabel alloc] initWithFrame:CGRectMake(0, 59, [UIScreen mainScreen].bounds.size.width, 0.5)];
    [bottomLine setBackgroundColor:[UIColor grayColor]];
    
    [cell.contentView addSubview:bottomLine];

    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger index = indexPath.row;
    if (index == 0) {
        [self showAddressBook];
    }
    else if (index == 1)
    {
        UIStoryboard* mainStory = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        UIViewController* vc;
      
        vc  = [mainStory instantiateViewControllerWithIdentifier:@"ICCreateMarkViewController"];
        ((ICCreateMarkViewController*)vc).viewType = ViewTypeEmail;
        ((ICCreateMarkViewController*)vc).workGroupId = _workGroupId;
        [self.navigationController pushViewController:vc animated:YES];
    }
    else if (index == 2)
    {
        UIStoryboard* mainStory = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        UIViewController* vc = [mainStory instantiateViewControllerWithIdentifier:@"ICMemberTableViewController"];
        ((ICMemberTableViewController*)vc).controllerType = MemberViewFromControllerCopyTo;
        ((ICMemberTableViewController*)vc).icPublishMisonController = self;
        
        ((ICMemberTableViewController*)vc).workgid = self.workGroupId;
        
        [self.navigationController pushViewController:vc animated:YES];
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

-(void)setExtraCellLineHidden: (UITableView *)tableView
{
    UIView *view = [UIView new];
    view.backgroundColor = [UIColor clearColor];
    [tableView setTableFooterView:view];
    
    tableView.tableHeaderView = ({
        
        UIView* view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 100, 30)];
        [view setBackgroundColor:[UIColor clearColor]];
        UILabel* bottomLine = [[UILabel alloc] initWithFrame:CGRectMake(0, 29, [UIScreen mainScreen].bounds.size.width, 0.5)];
        [bottomLine setBackgroundColor:[UIColor grayColor]];
        
        [view addSubview:bottomLine];
        view;
    });
}

-(void)showAddressBook
{
    ABPeoplePickerNavigationController *peoplePicker = [[ABPeoplePickerNavigationController alloc] init];
    peoplePicker.peoplePickerDelegate = self;
    [self presentViewController:peoplePicker animated:YES completion:nil];
}

#pragma mark -- ABPeoplePickerNavigationControllerDelegate

- (void)peoplePickerNavigationController:(ABPeoplePickerNavigationController *)peoplePicker didSelectPerson:(ABRecordRef)person property:(ABPropertyID)property identifier:(ABMultiValueIdentifier)identifier
{
    

    ABMultiValueRef valuesRef = ABRecordCopyValue(person, kABPersonPhoneProperty);
    CFIndex index = ABMultiValueGetIndexForIdentifier(valuesRef,identifier);
    CFStringRef phone = ABMultiValueCopyValueAtIndex(valuesRef,index);
    CFStringRef last=ABRecordCopyValue(person, kABPersonLastNameProperty);
    CFStringRef fist=ABRecordCopyValue(person, kABPersonFirstNameProperty);
    
    
    dispatch_async(dispatch_get_main_queue(), ^{
        NSString* loginUserId = [LoginUser loginUserID];
        BOOL isOk = [Group inviteNewUser:loginUserId workGroupId:_workGroupId source:1 sourceValue:(__bridge NSString*)phone];
        if (isOk) {
            UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"提示" message:[NSString stringWithFormat:@"已邀请手机号为 %@ 的用户加入群组!",phone] delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            [alert show];
            
        }
    });
    
    
    
    [self dismissViewControllerAnimated:YES completion:^{
        //self.textField.text = (__bridge NSString*)value;
        NSLog(@"People:%@ %@  :: %@",fist,last,phone);
    }];
    
    
}

@end
