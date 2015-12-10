//
//  MQCreateGroupSecondController.m
//  CommonFrame_Pro
//
//  Created by 倩 莫 on 15/12/3.
//  Copyright © 2015年 ionitech. All rights reserved.
//

#import "MQCreateGroupSecondController.h"

#import "MQCreateGroupFirstController.h"
#import "ICMemberTableViewController.h"
#import "PartiCell.h"
#import "UICommon.h"
#import "MQInviteAddressBookController.h"
#import "SVProgressHUD.h"
#import "ZLPeoplePickerViewController.h"

#import <AddressBook/AddressBook.h>
#import <AddressBookUI/AddressBookUI.h>

@interface MQCreateGroupSecondController ()<UITableViewDataSource, UITableViewDelegate, UICollectionViewDataSource, UICollectionViewDelegate, ABPeoplePickerNavigationControllerDelegate, ABPersonViewControllerDelegate,
ZLPeoplePickerViewControllerDelegate>
{
    UITableView*            _tableView;
    
    UICollectionView * _inviteCollView;
}

@end

@implementation MQCreateGroupSecondController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.inviteArr = [NSMutableArray array];
    
    _addressBookRef = ABAddressBookCreateWithOptions(NULL, NULL);
    [ZLPeoplePickerViewController initializeAddressBook];
    
    [self initTableView];
    
    [self initInviteCollView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - ZLPeoplePickerViewControllerDelegate
- (void)peoplePickerViewController:(ZLPeoplePickerViewController *)peoplePicker
                   didSelectPerson:(NSNumber *)recordId {
    if (peoplePicker.numberOfSelectedPeople == ZLNumSelectionMax) {
        {
//            NSArray * arr = [UICommon phonesArrForPerson:recordId withAddressBookRef:self.addressBookRef];
            
            
        }
    }
}

- (UIAlertController *)alertControllerWithTitle:(NSString *)title
                                        Message:(NSString *)message {
    UIAlertController *alert = [UIAlertController
                                alertControllerWithTitle:title
                                message:message
                                preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *ok = [UIAlertAction
                         actionWithTitle:@"OK"
                         style:UIAlertActionStyleDefault
                         handler:^(UIAlertAction *action) {
                             [alert dismissViewControllerAnimated:YES completion:nil];
                         }];
    [alert addAction:ok];
    return alert;
}



- (void) initInviteCollView
{
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    
    layout.minimumInteritemSpacing = 12.f;
    layout.minimumLineSpacing = 0;
    UIEdgeInsets insets = {.top = 14,.left = 14,.bottom = 14,.right = 14};
    layout.sectionInset = insets;
    
    _inviteCollView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, SCREENWIDTH, 14 + 80) collectionViewLayout:layout];
    _inviteCollView.delegate = self;
    _inviteCollView.dataSource = self;
    _inviteCollView.scrollEnabled = NO;
    _inviteCollView.backgroundColor = [UIColor clearColor];
    
    [_inviteCollView registerClass:[PartiCell class] forCellWithReuseIdentifier:@"PartiCell"];
    
    _inviteCollView.hidden = YES;
}

- (void) initTableView
{
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 25, SCREENWIDTH, SCREENHEIGHT - 25 - 64)];
    _tableView.backgroundColor = [UIColor backgroundColor];
    _tableView.dataSource = self;
    _tableView.delegate = self;
//    _tableView.tag = 101;
    [_tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    [self.view addSubview:_tableView];
    
    [self.view sendSubviewToBack:_tableView];
}

- (IBAction)backButtonClicked:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)doneButtonClicked:(id)sender
{
    
}

- (void) viewWillAppear:(BOOL)animated
{
//    if(_peoplePicker.selectedPeople.count)
//    {
//        Member * me = [Member new];
//        
//        for (NSString * recordId in _peoplePicker.selectedPeople)
//        {
//            NSString * name = [self compositeNameForPerson:recordId];
//            me.name = name;
//        }
//        
//    }
    
    if(_inviteArr.count)
    {
        _inviteCollView.hidden = NO;
        
        [_inviteCollView reloadData];
        
        [_tableView reloadData];
    }
    else
    {
        _inviteCollView.hidden = YES;
    }
}

- (void) viewWillDisappear:(BOOL)animated
{
    if([self.icCreateGroupFirstController respondsToSelector:@selector(setViewType:)])
    {
        [self.icCreateGroupFirstController setValue:@"1" forKey:@"viewType"];
    }
    if([self.icCreateGroupFirstController respondsToSelector:@selector(setWorkGroup:)])
    {
        if(_workGroup)
        {
            [self.icCreateGroupFirstController setValue:_workGroup forKey:@"workGroup"];
        }
    }

}

#pragma -
#pragma Table View

- (CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 44.0;
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    for(UIView *view in cell.contentView.subviews) {
        [view removeFromSuperview];
    }
    
    NSInteger row = indexPath.row;
    NSInteger section = indexPath.section;
    CGFloat tableWidth = SCREENWIDTH;
    CGFloat cellHeight = [self tableView:tableView heightForRowAtIndexPath:indexPath];
    
    UILabel* titleLbl = [[UILabel alloc] initWithFrame:CGRectMake(14, 0, SCREENWIDTH - 14 * 2, 40)];
    [titleLbl setBackgroundColor:[UIColor clearColor]];
    [titleLbl setTextColor:[UIColor whiteColor]];
    [titleLbl setFont:Font(15)];
    [titleLbl setTextAlignment:NSTextAlignmentLeft];
    
    UILabel* subLbl = [[UILabel alloc] initWithFrame:CGRectMake(14, YH(titleLbl) - 4, W(titleLbl), 14)];
    [subLbl setBackgroundColor:[UIColor clearColor]];
    [subLbl setTextColor:[UIColor grayTitleColor]];
    [subLbl setFont:Font(12)];
    [subLbl setTextAlignment:NSTextAlignmentLeft];
    
    if(section == 0 && row == 0)
    {
        UILabel* line1 = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, tableWidth, 0.5)];
        [line1 setBackgroundColor:[UIColor grayLineColor]];
        [cell.contentView addSubview:line1];
        
        titleLbl.text = @"手机通讯录";
        
        subLbl.text = @"从手机通讯录添加成员";
    }
    else if (section == 1 && row == 0)
    {
        UILabel* line1 = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, tableWidth, 0.5)];
        [line1 setBackgroundColor:[UIColor grayLineColor]];
        [cell.contentView addSubview:line1];
        
        titleLbl.text = @"内部成员";
        
        subLbl.text = @"从内部选择需要添加的成员";
    }
    else if (section == 2 && row == 0)
    {
        _inviteCollView.height = cellHeight;
        [cell.contentView addSubview:_inviteCollView];
        cell.backgroundColor = [UIColor backgroundColor];
    }
    
    if (!(section == 2 && row == 0))
    {
        [cell.contentView addSubview:titleLbl];
        [cell.contentView addSubview:subLbl];

        UILabel* line3 = [[UILabel alloc] init];
        line3.frame = CGRectMake(0, cellHeight - 1, tableWidth, 0.5);
        
        [line3 setBackgroundColor:[UIColor grayLineColor]];
        [cell.contentView addSubview:line3];
        
        UIImageView * photo = [[UIImageView alloc] init];
        [photo setFrame:CGRectMake(SCREENWIDTH - 12 - 14, (cellHeight - 12) / 2, 12, 12)];
        [photo setImage:[UIImage imageNamed:@"icon_jiantou"]];
        [cell.contentView addSubview:photo];
        
        cell.backgroundColor = [UIColor grayMarkColor];

    }
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger row = indexPath.row;
    NSInteger section = indexPath.section;
    
    if(section == 0 && row == 0)
    {//手机通讯录
        
        [UICommon CheckAddressBookAuthorization:^(bool isAuthorized){
            if(isAuthorized)
            {
                self.peoplePicker = [[ZLPeoplePickerViewController alloc] init];
                self.peoplePicker.delegate = self;
                self.peoplePicker.numberOfSelectedPeople = ZLNumSelectionMax;
                self.peoplePicker.icCreateGroupSecondController = self;
                [self.navigationController pushViewController:self.peoplePicker
                                                     animated:YES];
                
//                UIStoryboard* mainStory = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
//                UIViewController* vc = [mainStory instantiateViewControllerWithIdentifier:@"MQInviteAddressBookController"];
                //        ((MQInviteAddressBookController*)vc).controllerType = MemberViewFromControllerCopyTo;
                //        ((MQInviteAddressBookController*)vc).icCreateGroupSecondController = self;
                //        ((MQInviteAddressBookController*)vc).isFromCreatGroupInvite = YES;
                //        ((MQInviteAddressBookController*)vc).invitedArray = _inviteArr;
                
//                [self.navigationController pushViewController:vc animated:YES];
            }
            else
            {
                [SVProgressHUD showErrorWithStatus:@"请到设置>隐私>通讯录打开本应用的权限设置"];
            }
        }];
        

    }
    else if (section == 1 && row == 0)
    {//内部成员
        UIStoryboard* mainStory = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        UIViewController* vc = [mainStory instantiateViewControllerWithIdentifier:@"ICMemberTableViewController"];
        ((ICMemberTableViewController*)vc).controllerType = MemberViewFromControllerCopyTo;
        ((ICMemberTableViewController*)vc).icCreateGroupSecondController = self;
        ((ICMemberTableViewController*)vc).isFromCreatGroupInvite = YES;
        ((ICMemberTableViewController*)vc).workgid = @"1015082511440001";
        ((ICMemberTableViewController*)vc).invitedArray = _inviteArr;
        ((ICMemberTableViewController*)vc).justRead = YES;

        [self.navigationController pushViewController:vc animated:YES];
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger section = indexPath.section;
    
    CGFloat height = 60;
    
    if(section == 0 || section == 1)
    {
        return height;
    }
    else
    {
        NSInteger lineCount = 6;
        NSInteger count = _inviteArr.count;
        NSInteger row = 1;
        CGFloat inviteCellHeight = 80;

        if(SCREENWIDTH == 320 || SCREENWIDTH == 375)
        {
            lineCount = 4;
        }
        
        row = (count % lineCount) ? count / lineCount + 1: count / lineCount;
        
        height = 14 + row * inviteCellHeight;
        
        return height;
    }
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {
        return 1;
    }
    else if (section == 1) {
        return 1;
    }
    else if (section == 2) {
        return 1;
    }
    return 0;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if(_inviteArr.count)
    {
        return 3;
    }
    else
    {
        return 2;
    }
}

- (UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView* customView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREENWIDTH, 44)];
    customView.backgroundColor = [UIColor backgroundColor];
    
    UILabel * headerLabel = [[UILabel alloc] initWithFrame:CGRectMake(14, 24, 100, 14)];
    headerLabel.backgroundColor = [UIColor clearColor];
    headerLabel.textColor = [UIColor grayTitleColor];
    headerLabel.font = Font(12);
    
    NSString * title = @"";
    
    if (section == 0) {
        title = @"邀请应用外";
    }
    else if (section == 1)
    {
        title = @"邀请应用内";
    }
    else if (section == 2)
    {
        title = @"已邀请";
    }
    
    headerLabel.text = title;
    
    [customView addSubview:headerLabel];
    
    return customView;
}

#pragma mark - collectionview delegate / datasource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return _inviteArr.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"PartiCell";
    PartiCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:CellIdentifier forIndexPath:indexPath];
    
    Member * member = _inviteArr[indexPath.row];
    
    if(member.image)
    {
        cell.photoView.image = member.image;
    }
    else
    {
        cell.photoView.image = [UIImage imageNamed:@"icon_morentouxiang"];
    }
    
    
    [cell.photoView setRoundCorner:3.3];
    
    cell.titleLbl.text = member.name;
    
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewFlowLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake(50, 50 + 30);
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
