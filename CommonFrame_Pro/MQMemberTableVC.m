//
//  MQMemberTableVC.m
//  CommonFrame_Pro
//
//  Created by 倩 莫 on 16/1/29.
//  Copyright © 2016年 ionitech. All rights reserved.
//

#import "MQMemberTableVC.h"
#import "ICMemberTableViewController.h"
#import <AIMTableViewIndexBar.h>
#import "InputText.h"
#import "UIImageView+UIActivityIndicatorForSDWebImage.h"
#import "MQMemberDetailVC.h"

@interface MQMemberTableVC ()<UITableViewDataSource,UITableViewDelegate, AIMTableViewIndexBarDelegate,InputTextDelegate, UITextFieldDelegate>
{
    AIMTableViewIndexBar*  _indexBar;
    UITableView*           _tableView;
    
    NSArray* _sections;
    NSArray* _rows;
    
    //Search bar
    UILabel*        _lblSearch;
    UITextField*    _txtSearch;

    //Group Members
    UITableViewCellEditingStyle _editingStyle;
}

@property (nonatomic,assign) BOOL chang;

@end

@implementation MQMemberTableVC

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
    
    [self fillAllMember];

    CGFloat tableWidth = [UIScreen mainScreen].bounds.size.width;
    
    CGFloat THeight = [UIScreen mainScreen].bounds.size.height - 68;
    
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, tableWidth - 30, THeight)];
    [_tableView setBackgroundColor:RGBCOLOR(31, 31, 31)];
    _tableView.showsVerticalScrollIndicator = NO;
    [_tableView setSectionIndexColor:[UIColor blueColor]];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    
    [_tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    
    [self.view addSubview:_tableView];
    
    _indexBar = [[AIMTableViewIndexBar alloc] initWithFrame:CGRectMake(tableWidth - 30, 0, 30, THeight)];
    [_indexBar setBackgroundColor:[UIColor blackColor]];
    _indexBar.delegate = self;
    
    [self.view addSubview:_indexBar];
    
    _editingStyle = UITableViewCellEditingStyleNone;

    
    _tableView.tableHeaderView = ({
        
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableWidth, 40)];
        [view setBackgroundColor:RGBCOLOR(31, 31, 31)];
        
        UIView* searchView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableWidth, 40)];
        [searchView setBackgroundColor: [UIColor blackColor]];
        
        UIImageView* sImageView = [[UIImageView alloc] initWithFrame:CGRectMake(10, 12, 14, 14)];
        [sImageView setBackgroundColor:[UIColor clearColor]];
        [sImageView setImage:[UIImage imageNamed:@"icon_sousuo"]];
        [searchView addSubview:sImageView];
        
        InputText *inputText = [[InputText alloc] init];
        inputText.delegate = self;
        
        _txtSearch = [[UITextField alloc] initWithFrame:CGRectMake(30, 5, tableWidth - 75, 30)];
        [_txtSearch setBackgroundColor:[UIColor orangeColor]];
        [_txtSearch setBorderStyle:UITextBorderStyleNone];
        [_txtSearch setFont:[UIFont systemFontOfSize:17]];
        [_txtSearch setTextColor:[UIColor whiteColor]];
        _txtSearch.returnKeyType = UIReturnKeySearch;
        [_txtSearch addTarget:self action:@selector(textFieldDidChange) forControlEvents:UIControlEventEditingChanged];
        _txtSearch.delegate = self;
        
        _txtSearch = [inputText setupWithIcon:nil  point:nil  textFieldControl:_txtSearch showBottomLine:NO];
        
        _lblSearch = [[UILabel alloc] init];
        _lblSearch.text = @"搜索";
        _lblSearch.font = [UIFont systemFontOfSize:16];
        _lblSearch.textColor = [UIColor grayColor];
        _lblSearch.frame = _txtSearch.frame;
        
        [searchView addSubview:_txtSearch];
        [searchView addSubview:_lblSearch];
        
        //            [view addSubview:searchView];
        
        view;
    });
    
    [_tableView setFrame: CGRectMake(0, 0, tableWidth - 30, THeight)];
}

- (void) fillAllMember
{
    NSMutableArray* sectionArray = [NSMutableArray array];
    NSNumber * totalCount = [NSNumber numberWithInteger:0];
    NSArray * memberArray = [Member getAllMembersByWorkGroupID:&sectionArray workGroupID:_workGroup.workGroupId totalMemeberCount:&totalCount];

    
    if([totalCount integerValue] > 0)
    {
        self.navigationItem.title = [NSString stringWithFormat:@"组群成员(%@)", totalCount];
    }
    
    if (sectionArray.count == 0 || memberArray.count == 0) {
        
    }
    else
    {
        _sections = sectionArray;
        
        _rows = memberArray;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (IBAction)btnBackButtonClicked:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)btnDoneButtonClicked:(id)sender
{
    UIStoryboard* mainStory = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    UIViewController* vc = [mainStory instantiateViewControllerWithIdentifier:@"ICMemberTableViewController"];
    ((ICMemberTableViewController*)vc).controllerType = MemberViewFromControllerCopyTo;
    ((ICMemberTableViewController*)vc).icPublishMisonController = self;
    
    ((ICMemberTableViewController*)vc).workgid = _workGroup.workGroupId;
    
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
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
            BOOL isOk = [Group inviteNewUser:loginUserId workGroupId:_workGroup.workGroupId source:3 sourceValue:idArrayStr];
            if (isOk) {
                
                UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"已邀请群组成员!" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                [alert show];
                _ccopyToMembersArray = nil;
            }
            
        });
        
    }
}

#pragma mark -
#pragma mark AIM Table View Index Bar Action
- (void)tableViewIndexBar:(AIMTableViewIndexBar*)indexBar didSelectSectionAtIndex:(NSInteger)index
{
    if ([_tableView numberOfSections] > index && index > -1){
        [_tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:index]
                          atScrollPosition:UITableViewScrollPositionTop
                                  animated:YES];
    }
}

#pragma mark -
#pragma mark Table View Action
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    [_indexBar setIndexes:_sections];
    return [_sections count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_rows[section] count];
}

- (NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return _sections[section];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 18;
}

- (UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView* myView = [[UIView alloc] init];
    myView.backgroundColor = [UIColor colorWithRed:0.40 green:0.48 blue:0.94 alpha:1.0];
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(5, 2, 90, 15)];
    titleLabel.textColor=[UIColor whiteColor];
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.text=_sections[section];
    [titleLabel setFont:[UIFont systemFontOfSize:10]];
    [myView addSubview:titleLabel];
    
    return myView;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    Member* mem = _rows[indexPath.section][indexPath.row];
    
    if(mem.userId == [LoginUser loginUserID])
    {
        _editingStyle = UITableViewCellEditingStyleNone;
    }
    
    if(!_justRead)
    {
        _editingStyle = UITableViewCellEditingStyleDelete;
    }
    
    return _editingStyle;
}

- (NSString*)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return @"移除";
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (self.controllerType == MemberViewFromControllerGroupMembers) {
        // 删除操作
        if (editingStyle == UITableViewCellEditingStyleDelete) {
            
            Member* mem = _rows[indexPath.section][indexPath.row];
            
            BOOL isDeleted = [Member memberUpdateWgPeopleStrtus:mem.workContractsId status:@"-1"];
            if(isDeleted)
            {
                [self fillAllMember];
                
                [tableView reloadData];
            }
        }
    }
}

- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = (UITableViewCell *)[tableView cellForRowAtIndexPath:indexPath];
    UIView *selectionColor = [[UIView alloc] init];
    selectionColor.backgroundColor = [UIColor cellHoverBackgroundColor];
    cell.selectedBackgroundView = selectionColor;
    
    UILabel* bottomLine = [[UILabel alloc] initWithFrame:CGRectMake(0, 59.5,  [UIScreen mainScreen].bounds.size.width, 0.5)];
    [bottomLine setBackgroundColor:[UIColor grayColor]];
    [cell.selectedBackgroundView addSubview:bottomLine];
    
    return YES;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellId = @"MemberTableViewCellId";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    if (cell == nil){
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
        
    }
    
    for(UIView *view in cell.contentView.subviews) {
        [view removeFromSuperview];
    }
    
    NSInteger index = indexPath.row;
    NSInteger section = indexPath.section;
    
    CGFloat x = 12;
    
    UIImageView* choseImg = [[UIImageView alloc] initWithFrame:CGRectMake(x, 20, 17, 17)];
    if (self.controllerType == MemberViewFromControllerCopyTo)
    {
        choseImg.image = [UIImage imageNamed:@"btn_xuanze_1"];
        choseImg.tag = 1010;

        x = x * 2 + 17;
    }
    
    Member* mem = _rows[indexPath.section][indexPath.row];
    
    UIImageView* photoImageView = [[UIImageView alloc] initWithFrame:CGRectMake(x, 12, 36, 36)];
    photoImageView.tag = 777;
    
    if(mem.img.length)
    {
        [photoImageView setImageWithURL:[NSURL URLWithString:mem.img] placeholderImage:[UIImage imageNamed:@"icon_chengyuan"] options:SDWebImageDelayPlaceholder usingActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    }
    UILabel* name = [[UILabel alloc] initWithFrame:CGRectMake(x + 36 + 6, 15, 150, 30)];
    name.textColor = [UIColor whiteColor];
    name.textAlignment = NSTextAlignmentLeft;
    name.text = mem.name;
    name.font = [UIFont systemFontOfSize:15];
    
    if (cell.contentView.subviews.count < 2) {
        [cell.contentView addSubview:photoImageView];
        [cell.contentView addSubview:name];
    }

    cell.backgroundColor = RGBCOLOR(31, 31, 31);
    [cell.contentView setBackgroundColor:[UIColor clearColor]];
    
    UILabel* bottomLine = [[UILabel alloc] initWithFrame:CGRectMake(0, 59.5,  [UIScreen mainScreen].bounds.size.width, 0.5)];
    [bottomLine setBackgroundColor:[UIColor grayColor]];
    [cell.contentView addSubview:bottomLine];
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self restoreTextName:_lblSearch textField:_txtSearch];
    
    if (self.controllerType == MemberViewFromControllerAuthority) {
        
        Member* m = _rows[indexPath.section][indexPath.row];
        UIStoryboard* mainStory = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        UIViewController* vc;
//        vc = [mainStory instantiateViewControllerWithIdentifier:@"ICMemberAccessControlViewContoller"];
//        ((ICMemberAccessControlViewContoller*)vc).workContractID = m.workContractsId;
//        ((ICMemberAccessControlViewContoller*)vc).workGroupID = m.workGroupId;
        
        vc = [mainStory instantiateViewControllerWithIdentifier:@"MQMemberDetailVC"];
        ((MQMemberDetailVC*)vc).member = m;
        
        [self.navigationController pushViewController:vc animated:YES];
    }
    else
    {
        Member* m = _rows[indexPath.section][indexPath.row];
        if(!m.workGroupId)
        {
            m.workGroupId = @"0";
        }
        if (m != nil) {
            UIStoryboard* mainStory = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
            UIViewController* vc;
            vc = [mainStory instantiateViewControllerWithIdentifier:@"ICMemberInfoViewController"];
            ((ICMemberInfoViewController*)vc).memberObj = m;
            [self.navigationController pushViewController:vc animated:YES];
        }
        
        
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)restoreTextName:(UILabel *)label textField:(UITextField *)textFieled
{
    [textFieled resignFirstResponder];
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

@end
