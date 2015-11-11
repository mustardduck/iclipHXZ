//
//  ICMemberTableViewController.m
//  CommonFrame_Pro
//
//  Created by ionitech on 15/6/5.
//  Copyright (c) 2015年 ionitech. All rights reserved.
//

#import "ICMemberTableViewController.h"
#import <AIMTableViewIndexBar.h>
#import "InputText.h"
#import "UIImageView+UIActivityIndicatorForSDWebImage.h"
#import "UICommon.h"

@interface ICMemberTableViewController() <UITableViewDataSource,UITableViewDelegate, AIMTableViewIndexBarDelegate,InputTextDelegate,UITextFieldDelegate>
{
     AIMTableViewIndexBar*  _indexBar;
     UITableView*           _tableView;
    
    NSArray* _sections;
    NSArray* _rows;
    
    IBOutlet UINavigationBar*   _navBar;
    
    //PublisMission
    NSIndexPath*            _selectedIndexPath;
    NSMutableArray*         _selectedIndexList;
    NSMutableArray*         _selectedDictionary;
    //PublishMission Participants
    NSIndexPath*            _responsibleIndexPath;
    
    
    //Search bar
    UILabel*        _lblSearch;
    UITextField*    _txtSearch;
    
    //Group Members
    UITableViewCellEditingStyle _editingStyle;
    
    NSMutableArray * _partiIndexPathArr;
    
    UIButton * _selectBtn;
    
    NSInteger _totalMemberCount;
    
}

@property (nonatomic,assign) BOOL chang;


- (IBAction)backButtonClicked:(id)sender;

@end



@implementation ICMemberTableViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    _partiIndexPathArr = [NSMutableArray array];
    
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
    
//    if (self.controllerType == MemberViewFromControllerPublishMissionParticipants) {
//        UIBarButtonItem* rightBarButton = [[UIBarButtonItem alloc] initWithTitle:@"完成" style:UIBarButtonItemStyleDone target:self action:@selector(backButtonClicked:)];
//        [rightBarButton setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor whiteColor],NSFontAttributeName:[UIFont systemFontOfSize:17]} forState:UIControlStateNormal];
//        self.navigationItem.rightBarButtonItem = rightBarButton;
//    }
    
    NSString* wgid = _workgid;
    //wgid = @"1015070410020001";
    
    if(self.controllerType == MemberViewFromControllerCopyTo)
    {
        if(_isCC)
        {
            [self fillAllMember];

//            NSMutableArray* sectionArray = [NSMutableArray array];
//            NSArray*        memberArray = [Member getAllMembers:&sectionArray participantsArray:self.selectedParticipantsDictionary];
//
//            _sections = sectionArray;
//            _rows = memberArray;
        }
        else
        {
            if(_isKJFW)
            {
                [self fillAllMember];
            }
            else
            {
                if (self.selectedParticipantsDictionary.count > 0) {
                    NSMutableArray* sectionArray = [NSMutableArray array];
                    NSArray*        memberArray = [Member getAllMembers:&sectionArray participantsArray:self.selectedParticipantsDictionary];
                    
                    _sections = sectionArray;
                    _rows = memberArray;
                }
                else
                {//邀请时用的
                    NSMutableArray* sectionArray = [NSMutableArray array];
                    NSArray*        memberArray = [Member getAllMembersExceptMe:&sectionArray searchText:nil workGroupId:_workgid];
                    
                    _sections = sectionArray;
                    _rows = memberArray;
                }
            }

        }      
    }
    else
    {
        [self fillAllMember];
    }
    
     CGFloat tableWidth = [UIScreen mainScreen].bounds.size.width;
    
    CGFloat THeight = [UIScreen mainScreen].bounds.size.height - 68 - 66;
    
    if(self.controllerType == MemberViewFromControllerPublishMissionResponsible)
    {
        THeight = [UIScreen mainScreen].bounds.size.height - 68;
    }
    
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, tableWidth - 30, THeight)];
    [_tableView setBackgroundColor:RGBCOLOR(31, 31, 31)];
     _tableView.showsVerticalScrollIndicator = NO;
    [_tableView setSectionIndexColor:[UIColor blueColor]];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    
    [_tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    
    [self.view addSubview:_tableView];
    
//    [self.view setBackgroundColor:RGBCOLOR(31, 31, 31)];
    
    //全选+完成按钮
    
    if(self.controllerType == MemberViewFromControllerCopyTo || self.controllerType == MemberViewFromControllerPublishMissionParticipants)
    {
        CGRect selectFrame = CGRectMake(40, H(self.view) - 42 - 13 - 66, (SCREENWIDTH - 40 * 3)/2, 42);
        
        _selectBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _selectBtn.frame = selectFrame;
        [_selectBtn setBackgroundImage:[UIImage imageNamed:@"btn_anniu"] forState:UIControlStateNormal];
        [_selectBtn setBackgroundImage:[UIImage imageNamed:@"btn_anniu2"] forState:UIControlStateHighlighted];
        
        BOOL showCancel = NO;
        if(self.controllerType == MemberViewFromControllerCopyTo)
        {
            showCancel = _selectedCopyToMembersArray.count ? YES : NO;
        }
        else
        {
            showCancel = _selectedParticipantsDictionary.count ? YES : NO;

        }
        if(showCancel)
        {
            [_selectBtn setTitle:@"取消" forState:UIControlStateNormal];
        }
        else
        {
            [_selectBtn setTitle:@"全选" forState:UIControlStateNormal];
        }
        _selectBtn.titleLabel.font = Font(14);
        [_selectBtn setTitleColor:RGBCOLOR(79, 79, 79) forState:UIControlStateHighlighted];
        [_selectBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_selectBtn addTarget:self action:@selector(selectBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
        
        [self.view addSubview:_selectBtn];
        
        UIButton * selectOkBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        selectFrame.origin.x = SCREENWIDTH - 40 - selectFrame.size.width;
        selectOkBtn.frame = selectFrame;
        [selectOkBtn setBackgroundImage:[UIImage imageNamed:@"btn_anniu"] forState:UIControlStateNormal];
        [selectOkBtn setBackgroundImage:[UIImage imageNamed:@"btn_anniu2"] forState:UIControlStateHighlighted];
        [selectOkBtn setTitle:@"完成" forState:UIControlStateNormal];
        selectOkBtn.titleLabel.font = Font(14);
        [selectOkBtn setTitleColor:RGBCOLOR(79, 79, 79) forState:UIControlStateHighlighted];
        [selectOkBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [selectOkBtn addTarget:self action:@selector(selectOkBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
        
//        self.view.backgroundColor = [UIColor redColor];
        
        [self.view addSubview:selectOkBtn];
        
    }
    
    _indexBar = [[AIMTableViewIndexBar alloc] initWithFrame:CGRectMake(tableWidth - 30, 0, 30, THeight)];
    [_indexBar setBackgroundColor:[UIColor blackColor]];
    _indexBar.delegate = self;
    
    //[self.navigationController setNavigationBarHidden:YES];
    
    [self.view addSubview:_indexBar];
    
    _editingStyle = UITableViewCellEditingStyleNone;
    
    if(self.controllerType == MemberViewFromControllerPublishMissionResponsible)
    {
        _selectedDictionary = [NSMutableArray array];
        
        if (self.selectedResponsibleDictionary != nil) {
            _selectedDictionary = [NSMutableArray arrayWithArray:self.selectedResponsibleDictionary];
        }

    }
    else if(self.controllerType == MemberViewFromControllerPublishMissionParticipants)
    {
        _selectedIndexList = [NSMutableArray array];
        _selectedDictionary = [NSMutableArray array];
        if (self.selectedParticipantsDictionary != nil) {
            _selectedIndexList = [NSMutableArray arrayWithArray:self.selectedParticipantsDictionary];
        }
        
        if (self.selectedResponsibleDictionary != nil) {
            
            NSMutableArray* arr = (NSMutableArray*)self.selectedResponsibleDictionary;
            
            if (arr.count == 1) {
                Member* m = [arr objectAtIndex:0];
                BOOL hasFinded = NO;
                for (int i=0; i<_sections.count; i++) {
                    
                    for (int j= 0; j< ((NSArray*)_rows[i]).count;j++) {
                        if (((Member*)_rows[i][j]).userId == m.userId) {
                            hasFinded = YES;
                            _responsibleIndexPath = [NSIndexPath indexPathForRow:j inSection:i];
                            break;
                        }
                    }
                    if (hasFinded) {
                        break;
                    }
                }
            }
            
        }
    }
    else if(self.controllerType == MemberViewFromControllerCopyTo)
    {
        _selectedIndexList = [NSMutableArray array];
        _selectedDictionary = [NSMutableArray array];
        if (self.selectedCopyToMembersArray != nil) {
            _selectedIndexList = [NSMutableArray arrayWithArray:self.selectedCopyToMembersArray];
        }
        
        if (self.selectedResponsibleDictionary != nil) {
            
            NSMutableArray* arr = (NSMutableArray*)self.selectedResponsibleDictionary;
            
            if (arr.count == 1) {
                Member* m = [arr objectAtIndex:0];
                BOOL hasFinded = NO;
                for (int i=0; i<_sections.count; i++) {
                    
                    for (int j= 0; j< ((NSArray*)_rows[i]).count;j++) {
                        if (((Member*)_rows[i][j]).userId == m.userId) {
                            hasFinded = YES;
                            _responsibleIndexPath = [NSIndexPath indexPathForRow:j inSection:i];
                            break;
                        }
                    }
                    if (hasFinded) {
                        break;
                    }
                }
            }
        }
        //标记参与人indexpath
        if (self.selectedResponsibleDictionary != nil) {
            
            NSMutableArray* arr = (NSMutableArray*)self.selectedParticipantsDictionary;
            
            for(Member * m in arr)
            {
                BOOL hasFinded = NO;
                for (int i=0; i<_sections.count; i++) {
                    for (int j= 0; j< ((NSArray*)_rows[i]).count;j++) {
                        if (((Member*)_rows[i][j]).userId == m.userId) {
                            hasFinded = YES;
                            NSIndexPath * indexP = [NSIndexPath indexPathForRow:j inSection:i];
                            
                            [_partiIndexPathArr addObject:indexP];
                        }
                    }
                }
            }
        }
    }
    else if(self.controllerType == MemberViewFromControllerGroupMembers)
    {
        if(!_justRead)
        {
            _editingStyle = UITableViewCellEditingStyleDelete;
        }
    }
    
    if (self.controllerType == MemberViewFromControllerGroupList) {
        
        UIView* tBg = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableWidth, 66)];
        [tBg setBackgroundColor:[UIColor blackColor]];
        [self.view addSubview:tBg];
        
        UINavigationItem *item = [[UINavigationItem alloc] initWithTitle:@"所有群组"];
        UIBarButtonItem* rightBarButton = [[UIBarButtonItem alloc] initWithTitle:@"创建群组" style:UIBarButtonItemStylePlain target:self action:@selector(btnCreateNewGroup:)];
        [rightBarButton setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor whiteColor],NSFontAttributeName:[UIFont systemFontOfSize:14]} forState:UIControlStateNormal];
        [item setRightBarButtonItem:rightBarButton];
        
        UIBarButtonItem* leftBarButton = [[UIBarButtonItem alloc] initWithTitle:@"返回" style:UIBarButtonItemStylePlain target:self action:@selector(backButtonClicked:)];
        [leftBarButton setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor whiteColor],NSFontAttributeName:[UIFont systemFontOfSize:14]} forState:UIControlStateNormal];
        [item setLeftBarButtonItem:leftBarButton];
        
        [self.navigationItem setTitle:@"所有群组"];
        [self.navigationItem setRightBarButtonItem:rightBarButton];
        
        //[_navBar pushNavigationItem:item animated:NO];

        
        _tableView.tableHeaderView = ({
            
            UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableWidth, 220)];
            [view setBackgroundColor:RGBCOLOR(31, 31, 31)];
            
            UIView* searchView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableWidth, 40)];
            [searchView setBackgroundColor: [UIColor clearColor]];
            
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
            
            UILabel* bottomLine3 = [[UILabel alloc] initWithFrame:CGRectMake(0, searchView.frame.origin.y + searchView.frame.size.height -1,  [UIScreen mainScreen].bounds.size.width, 0.5f)];
            [bottomLine3 setBackgroundColor:[UIColor grayColor]];
            [view addSubview:bottomLine3];
            
            
            
            UIView* messageView = [[UIView alloc] initWithFrame:CGRectMake(-1, 41, tableWidth + 2, 66)];
            [messageView setBackgroundColor: [UIColor clearColor]];
            
            UIButton* mBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, tableWidth, 66)];
            [mBtn setBackgroundColor:[UIColor clearColor]];
            [mBtn addTarget:self action:@selector(btnGroupMessageClicked:) forControlEvents:UIControlEventTouchUpInside];
            
            UIImageView* mImage = [[UIImageView alloc] initWithFrame:CGRectMake(12, 12, 42, 42)];
            [mImage setBackgroundColor:[UIColor clearColor]];
            [mImage setImage:[UIImage imageNamed:@"icon_xiaoxi"]];
            [mBtn addSubview:mImage];
            
            UILabel* mlbl = [[UILabel alloc] initWithFrame:CGRectMake(68, 22, 120, 19)];
            [mlbl setBackgroundColor:[UIColor clearColor]];
            [mlbl setTextAlignment:NSTextAlignmentLeft];
            [mlbl setTextColor:[UIColor whiteColor]];
            [mlbl setFont:[UIFont boldSystemFontOfSize:15]];
            [mlbl setText:@"群组消息"];
            [mBtn addSubview:mlbl];
            
            [messageView addSubview:mBtn];
            
            UILabel* bottomLine = [[UILabel alloc] initWithFrame:CGRectMake(0, messageView.frame.origin.y + messageView.frame.size.height -1,  [UIScreen mainScreen].bounds.size.width, 0.5f)];
            [bottomLine setBackgroundColor:[UIColor grayColor]];
            [view addSubview:bottomLine];
            
            
            
            UIView* projectView = [[UIView alloc] initWithFrame:CGRectMake(-1, 101, tableWidth + 2, 66)];
            [projectView setBackgroundColor: [UIColor clearColor]];
            
            UIButton* pBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, tableWidth, 66)];
            [pBtn setBackgroundColor:[UIColor clearColor]];
            [pBtn addTarget:self action:@selector(btnGroupProjectClicked:) forControlEvents:UIControlEventTouchUpInside];
            
            UIImageView* pImage = [[UIImageView alloc] initWithFrame:CGRectMake(12, 12, 42, 42)];
            [pImage setBackgroundColor:[UIColor clearColor]];
            [pImage setImage:[UIImage imageNamed:@"icon_xiangmu"]];
            [pBtn addSubview:pImage];
            
            UILabel* plbl = [[UILabel alloc] initWithFrame:CGRectMake(68, 22, 120, 19)];
            [plbl setBackgroundColor:[UIColor clearColor]];
            [plbl setTextAlignment:NSTextAlignmentLeft];
            [plbl setTextColor:[UIColor whiteColor]];
            [plbl setFont:[UIFont boldSystemFontOfSize:15]];
            [plbl setText:@"项目群组"];
            [pBtn addSubview:plbl];
            
            [projectView addSubview:pBtn];
            
            UILabel* bottomLine1 = [[UILabel alloc] initWithFrame:CGRectMake(0, projectView.frame.origin.y + projectView.frame.size.height -1,  [UIScreen mainScreen].bounds.size.width, 0.5)];
            [bottomLine1 setBackgroundColor:[UIColor grayColor]];
            [view addSubview:bottomLine1];
            
            
            
            UIView* departmentView = [[UIView alloc] initWithFrame:CGRectMake(-1, 161, tableWidth + 2, 66)];
            [departmentView setBackgroundColor: [UIColor clearColor]];
            
            UIButton* dBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, tableWidth, 66)];
            [dBtn setBackgroundColor:[UIColor clearColor]];
            [dBtn addTarget:self action:@selector(btnGroupDepartmentClicked:) forControlEvents:UIControlEventTouchUpInside];
            
            UIImageView* dImage = [[UIImageView alloc] initWithFrame:CGRectMake(12, 12, 42, 42)];
            [dImage setBackgroundColor:[UIColor clearColor]];
            [dImage setImage:[UIImage imageNamed:@"icon_bumen"]];
            [dBtn addSubview:dImage];
            
            UILabel* dlbl = [[UILabel alloc] initWithFrame:CGRectMake(68, 22, 120, 19)];
            [dlbl setBackgroundColor:[UIColor clearColor]];
            [dlbl setTextAlignment:NSTextAlignmentLeft];
            [dlbl setTextColor:[UIColor whiteColor]];
            [dlbl setFont:[UIFont boldSystemFontOfSize:15]];
            [dlbl setText:@"部门群组"];
            [dBtn addSubview:dlbl];
            
            [departmentView addSubview:dBtn];
            
            
            UILabel* bottomLine2 = [[UILabel alloc] initWithFrame:CGRectMake(0, departmentView.frame.origin.y + departmentView.frame.size.height -1, [UIScreen mainScreen].bounds.size.width, 0.5)];
            [bottomLine2 setBackgroundColor:[UIColor grayColor]];
            [view addSubview:bottomLine2];
            
            
            [view addSubview:searchView];
            [view addSubview:messageView];
            [view addSubview:projectView];
            [view addSubview:departmentView];
            
            [view setBackgroundColor:[UIColor blackColor]];
            view;
        });
        NSLog(@"height:%f",[UIScreen mainScreen].bounds.size.height);
        [_tableView setFrame:CGRectMake(0, 0, tableWidth - 30, [UIScreen mainScreen].bounds.size.height)];
    }
    else
    {
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
        
        CGFloat THeight = [UIScreen mainScreen].bounds.size.height - 68 - 66;
        
        if(self.controllerType == MemberViewFromControllerPublishMissionResponsible)
        {
            THeight = [UIScreen mainScreen].bounds.size.height - 68;
        }
        
        [_tableView setFrame: CGRectMake(0, 0, tableWidth - 30, THeight)];
        
       
    }
}

- (void) fillAllMember
{    
    NSMutableArray* sectionArray = [NSMutableArray array];
    NSNumber * totalCount = [NSNumber numberWithInteger:0];
    NSArray*        memberArray = [Member getAllMembersByWorkGroupID:&sectionArray workGroupID:_workgid totalMemeberCount:&totalCount];
    
    if([totalCount integerValue] > 0)
    {
        self.navigationItem.title = [NSString stringWithFormat:@"成员(%@)", totalCount];
    }
    
    if (sectionArray.count == 0 || memberArray.count == 0) {
        _sections = @[@"A", @"D", @"F", @"M", @"N", @"O", @"Z"];
        
        _rows = @[@[@"adam", @"alfred", @"ain", @"abdul", @"anastazja", @"angelica"],
                  @[@"dennis" , @"deamon", @"destiny", @"dragon", @"dry", @"debug", @"drums"],
                  @[@"Fredric", @"France", @"friends", @"family", @"fatish", @"funeral"],
                  @[@"Mark", @"Madeline"],
                  @[@"Nemesis", @"nemo", @"name"],
                  @[@"Obama", @"Oprah", @"Omen", @"OMG OMG OMG", @"O-Zone", @"Ontario"],
                  @[@"Zeus", @"Zebra", @"zed"]];
    }
    else
    {
        _sections = sectionArray;
        
        _rows = memberArray;
    }
}

- (void) selectBtnClicked:(id)sender
{
    UIButton * btn = (UIButton *)sender;
    
    if([btn.titleLabel.text isEqualToString:@"全选"])
    {
        for(int section= 0; section < _sections.count; section ++)
        {
            for (int row=0; row<[_rows[section] count]; row++)
            {
                NSIndexPath * indexPath = [NSIndexPath indexPathForRow:row inSection:section];
                
                if (_responsibleIndexPath != nil) {
                    if (indexPath.section == _responsibleIndexPath.section && indexPath.row == _responsibleIndexPath.row)
                    {
                    }
                    else
                    {
                        if(_partiIndexPathArr.count)
                        {
                            for (NSIndexPath * indP in _partiIndexPathArr)
                            {
                                if(indexPath.section == indP.section && indexPath.row == indP.row)
                                {
                                    [self removeIndexPathFromCopyToArray:indexPath];
                                }
                                else
                                {
                                    [self addIndexPathToCopyToArray:indexPath];
                                }
                            }
                        }
                        else
                        {
                            [self addIndexPathToCopyToArray:indexPath];
                        }
                    }
                }
                else
                {
                    [self addIndexPathToCopyToArray:indexPath];
                }
            }
        }
        
        [btn setTitle:@"取消" forState:UIControlStateNormal];
        
    }
    else
    {
        for(int section= 0; section < _sections.count; section ++)
        {
            for (int row=0; row<[_rows[section] count]; row++)
            {
                NSIndexPath * indexPath = [NSIndexPath indexPathForRow:row inSection:section];
                
                [self removeIndexPathFromCopyToArray:indexPath];
                
            }
        }
        
        [btn setTitle:@"全选" forState:UIControlStateNormal];
    }
    
    [_tableView reloadData];

}

- (void) selectOkBtnClicked:(id)sender
{
    if(self.controllerType == MemberViewFromControllerCopyTo)
    {
        if ([self.icPublishMisonController respondsToSelector:@selector(setCcopyToMembersArray:)]) {
            [self.icPublishMisonController setValue:_selectedIndexList forKey:@"ccopyToMembersArray"];
        }
    }
    if(self.controllerType == MemberViewFromControllerPublishMissionParticipants)
    {
        if ([self.icPublishMisonController respondsToSelector:@selector(setParticipantsIndexPathArray:)]) {
            [self.icPublishMisonController setValue:_selectedIndexList forKey:@"participantsIndexPathArray"];
        }
    }

    [self.navigationController popViewControllerAnimated:YES];
}


- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];

    
    if(self.controllerType == MemberViewFromControllerPublishMissionResponsible)
    {
        if ([self.icGroupListController respondsToSelector:@selector(setResponsibleDic:)]) {
            [self.icGroupListController setValue:_selectedDictionary forKey:@"responsibleDic"];
        }

    }
//    else if(self.controllerType == MemberViewFromControllerPublishMissionParticipants)
//    {
//        if ([self.icPublishMisonController respondsToSelector:@selector(setParticipantsIndexPathArray:)]) {
//            [self.icPublishMisonController setValue:_selectedIndexList forKey:@"participantsIndexPathArray"];
//        }
//    }
//    else if(self.controllerType == MemberViewFromControllerCopyTo)
//    {
//        if ([self.icPublishMisonController respondsToSelector:@selector(setCcopyToMembersArray:)]) {
//            [self.icPublishMisonController setValue:_selectedIndexList forKey:@"ccopyToMembersArray"];
//        }
//    }
    
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
#pragma mark MemberViewFromControllerGroupList
- (void)btnCreateNewGroup:(id)sender
{
    UIStoryboard* mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    UIViewController* vc = [mainStoryboard instantiateViewControllerWithIdentifier:@"ICCreateNewGroupViewController"];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)btnGroupMessageClicked:(id)sender
{
    UIStoryboard* mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    UIViewController* vc = [mainStoryboard instantiateViewControllerWithIdentifier:@"ICGroupListViewController"];
    [self.navigationController pushViewController:vc animated:YES];    
}

- (void)btnGroupProjectClicked:(id)sender
{
    UIStoryboard* mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    UIViewController* vc = [mainStoryboard instantiateViewControllerWithIdentifier:@"ICGroupListViewController"];
    ((ICGroupListViewController*)vc).currentViewGroupType = GroupTypeProject;
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)btnGroupDepartmentClicked:(id)sender
{
    UIStoryboard* mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    UIViewController* vc = [mainStoryboard instantiateViewControllerWithIdentifier:@"ICGroupListViewController"];
    ((ICGroupListViewController*)vc).currentViewGroupType = GroupTypeDepartment;
    [self.navigationController pushViewController:vc animated:YES];
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
    return [_sections count];;
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

                

//                [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
        
            
            // 1.删除数据
//            [self.data removeObjectAtIndex:indexPath.row];
//
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
    if (self.controllerType == MemberViewFromControllerPublishMissionParticipants || self.controllerType == MemberViewFromControllerCopyTo)
    {
//        BOOL isResponsible = NO;
//        if (_responsibleIndexPath != nil) {
//            if (section == _responsibleIndexPath.section && index == _responsibleIndexPath.row) {
//                isResponsible = YES;
//            }
//        }

        choseImg.image = [UIImage imageNamed:@"btn_xuanze_1"];
        choseImg.tag = 1010;
//        if (!isResponsible)
//            [cell.contentView addSubview:choseImg];
        
        x = x * 2 + 17;
    }
    
    Member* mem = _rows[indexPath.section][indexPath.row];
    
    UIImageView* photoImageView = [[UIImageView alloc] initWithFrame:CGRectMake(x, 12, 36, 36)];
    //photoImageView.image = [UIImage imageNamed:@"icon_chengyuan"];
    [photoImageView setImageWithURL:[NSURL URLWithString:mem.img] placeholderImage:[UIImage imageNamed:@"icon_chengyuan"] options:SDWebImageDelayPlaceholder usingActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    
    UILabel* name = [[UILabel alloc] initWithFrame:CGRectMake(x + 36 + 6, 15, 150, 30)];
    name.textColor = [UIColor whiteColor];
    name.textAlignment = NSTextAlignmentLeft;
    name.text = mem.name;
    name.font = [UIFont systemFontOfSize:15];
    
    if (cell.contentView.subviews.count < 2) {
        [cell.contentView addSubview:photoImageView];
        [cell.contentView addSubview:name];
    }
    
    if(self.controllerType == MemberViewFromControllerPublishMissionResponsible)
    {
        cell.contentView.tag = indexPath.section;
        
    }
    else if(self.controllerType == MemberViewFromControllerCopyTo || self.controllerType == MemberViewFromControllerPublishMissionParticipants)
    {
        CGFloat width = [UIScreen mainScreen].bounds.size.width;
        
        BOOL isResponsible = NO;

        if (_responsibleIndexPath != nil) {
            if (section == _responsibleIndexPath.section && index == _responsibleIndexPath.row) {
                
                UILabel* name = [[UILabel alloc] initWithFrame:CGRectMake(width - 140, 22, 100, 15)];
                [name setBackgroundColor:[UIColor clearColor]];
                [name setText:@"已定责任人"];
                [name setTextColor:[UIColor grayColor]];
                [name setFont:[UIFont systemFontOfSize:15]];
                [name setTag:112];
                
                [cell.contentView addSubview:name];
                
                isResponsible = YES;
            }
        }
        
        BOOL isParti = NO;
        
        if (_partiIndexPathArr != nil) {
            
            for (NSIndexPath * indexP in _partiIndexPathArr)
            {
                if(indexP.section == section && indexP.row == index)
                {
                    UILabel* name = [[UILabel alloc] initWithFrame:CGRectMake(width - 140, 22, 100, 15)];
                    [name setBackgroundColor:[UIColor clearColor]];
                    [name setText:@"已定参与人"];
                    [name setTextColor:[UIColor grayColor]];
                    [name setFont:[UIFont systemFontOfSize:15]];
                    [name setTag:345];//112
                    
                    [cell.contentView addSubview:name];
                    
                    isParti = YES;
                    
                    break;
                }
            }
            
            if (isResponsible || isParti)
            {
            }
            else
            {
                [cell.contentView addSubview:choseImg];

                if ([self hasExitsInPartcipathsArray:indexPath])
                    choseImg.image = [UIImage imageNamed:@"btn_xuanze_2"];
                else
                    choseImg.image = [UIImage imageNamed:@"btn_xuanze_1"];
                
                
                cell.contentView.tag = indexPath.section;
            }
        }
        

    }
    
    //[cell.contentView setBackgroundColor:[UIColor colorWithRed:0.15f green:0.15f blue:0.15f alpha:1.0f]];
    
    cell.backgroundColor = RGBCOLOR(31, 31, 31);
    [cell.contentView setBackgroundColor:[UIColor clearColor]];
    
    UILabel* bottomLine = [[UILabel alloc] initWithFrame:CGRectMake(0, 59.5,  [UIScreen mainScreen].bounds.size.width, 0.5)];
    [bottomLine setBackgroundColor:[UIColor grayColor]];
    [cell.contentView addSubview:bottomLine];
    

    for (UIControl* control in cell.contentView.subviews) {
        if (control.tag == 1010) {
            for(Member * me in _selectedIndexList)
            {
                if(mem.userId == me.userId)
                {
                    UIImageView* img = (UIImageView*)control;
                    img.tag = 1011;
                    img.image = [UIImage imageNamed:@"btn_xuanze_2"];
                    break;
                }
            }
        }
        else if (control.tag == 1011)
        {
            for(Member * me in _selectedIndexList)
            {
                if(mem.userId == me.userId)
                {
                    UIImageView* img = (UIImageView*)control;
                    img.tag = 1010;
                    img.image = [UIImage imageNamed:@"btn_xuanze_1"];
                    break;
                }
            }

        }
    }


    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self restoreTextName:_lblSearch textField:_txtSearch];
    
    if (self.controllerType == MemberViewFromControllerAuthority) {
        
        Member* m = _rows[indexPath.section][indexPath.row];
        UIStoryboard* mainStory = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        UIViewController* vc;
        vc = [mainStory instantiateViewControllerWithIdentifier:@"ICMemberAccessControlViewContoller"];
        ((ICMemberAccessControlViewContoller*)vc).workContractID = m.workContractsId;
        ((ICMemberAccessControlViewContoller*)vc).workGroupID = m.workGroupId;
        
        [self.navigationController pushViewController:vc animated:YES];
    }
    else if (self.controllerType == MemberViewFromControllerPublishMissionResponsible)
    {
        [self relativeToDictionary:indexPath];
        [self.navigationController popViewControllerAnimated:YES];
        
    }
    else if(self.controllerType == MemberViewFromControllerPublishMissionParticipants)
    {
        
        UITableViewCell* cell = [_tableView cellForRowAtIndexPath:indexPath];
        for (UIControl* control in cell.contentView.subviews) {
            if (control.tag == 1010) {
                UIImageView* img = (UIImageView*)control;
                img.tag = 1011;
                img.image = [UIImage imageNamed:@"btn_xuanze_2"];
                [self addIndexPathToParticipantsArray:indexPath];
                break;
            }
            else if (control.tag == 1011)
            {
                UIImageView* img = (UIImageView*)control;
                img.tag = 1010;
                img.image = [UIImage imageNamed:@"btn_xuanze_1"];
                [self removeIndexPathFromParticipantsArray:indexPath];
                break;
            }
        }
        
        //[self relativeToDictionary:indexPath.section row:indexPath.row];
        
    }
    else if(self.controllerType == MemberViewFromControllerCopyTo)
    {
        
        UITableViewCell* cell = [_tableView cellForRowAtIndexPath:indexPath];
        for (UIControl* control in cell.contentView.subviews) {
            if (control.tag == 1010) {
                UIImageView* img = (UIImageView*)control;
                img.tag = 1011;
                img.image = [UIImage imageNamed:@"btn_xuanze_2"];
                [self addIndexPathToCopyToArray:indexPath];
                break;
            }
            else if (control.tag == 1011)
            {
                UIImageView* img = (UIImageView*)control;
                img.tag = 1010;
                img.image = [UIImage imageNamed:@"btn_xuanze_1"];
                [self removeIndexPathFromCopyToArray:indexPath];
                break;
            }
        }
        
        //[self relativeToDictionary:indexPath.section row:indexPath.row];
        
    }
    else
    {
        Member* m = _rows[indexPath.section][indexPath.row];
        
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

//Publish Mission Responsible
-(void)switchChanged:(id)sender
{
    
    UISwitch* swi = (UISwitch*)sender;
    if (swi.on == YES) {
        
        if (_selectedIndexPath != nil) {
            UITableViewCell* cell = [_tableView cellForRowAtIndexPath:_selectedIndexPath];
            for (UIControl* control in cell.contentView.subviews) {
                if ([control isKindOfClass:[UISwitch class]]) {
                    ((UISwitch*)control).on = NO;
                    //[self relativeToDictionary:_selectedIndexPath.section row:_selectedIndexPath.row];
                    break;
                }
            }
        }
        
        id pControl = swi.superview;
        NSInteger section = ((UIView*)pControl).tag;
        NSInteger row = swi.tag;
        
        
        NSIndexPath* indexPath = [NSIndexPath indexPathForRow:row inSection:section];
        _selectedIndexPath = indexPath;

        //[self relativeToDictionary:_selectedIndexPath.section row:_selectedIndexPath.row];

    }
    else
    {
        //[self relativeToDictionary:_selectedIndexPath.section row:_selectedIndexPath.row];
        _selectedIndexPath = nil;
    }
    
}

//Publish Mission Participants
-(void)participantsSwitchChanged:(id)sender
{
    UISwitch* swi = (UISwitch*)sender;
    
    id pControl = swi.superview;
    NSInteger section = ((UIView*)pControl).tag;
    NSInteger row = swi.tag;
    NSIndexPath* indexPath = [NSIndexPath indexPathForRow:row inSection:section];
    
    if (swi.on == YES){
        [self addIndexPathToParticipantsArray:indexPath];
    }
    else{
        [self removeIndexPathFromParticipantsArray:indexPath];
    }
}




#pragma -
#pragma Action
- (void)relativeToDictionary:(NSIndexPath*)indexPath
{
    Member* me = _rows[indexPath.section][indexPath.row];
    
    if ( _selectedDictionary.count > 0) {
        
            for (id ip in _selectedDictionary) {
                [_selectedDictionary removeObject:ip];
            }
            
            [_selectedDictionary addObject:me];
    }
    else
    {
        _selectedDictionary = [NSMutableArray array];
        [_selectedDictionary addObject:me];
        
    }
}

- (BOOL)hasInDictionary:(NSInteger)section row:(NSInteger)row
{
    BOOL hasExits = NO;
    
    id val = [_selectedDictionary valueForKey:[NSString stringWithFormat:@"%ld",section]];
    if ( val != nil) {
        if ([val isKindOfClass:[NSArray class]]) {
            NSMutableArray* arr = (NSMutableArray*)val;
            NSString* rVal = [NSString stringWithFormat:@"%ld",row];
            for (NSString* r in arr) {
                if ([r isEqualToString:rVal]) {
                    hasExits = YES;
                    _selectedIndexPath = [NSIndexPath indexPathForRow:row inSection:section];
                    break;
                }
            }
        }
    }
    
    return hasExits;
}

- (BOOL)hasExitsInPartcipathsArray:(NSIndexPath*)indexPath
{
    NSInteger section = indexPath.section;
    NSInteger row = indexPath.row;
    
    Member* me = _rows[section][row];
    BOOL isEx = NO;
    if (_selectedIndexList.count > 0) {
        for (Member* ip in _selectedIndexList) {
            if (ip.userId == me.userId) {
                isEx = YES;
                break;
            }
        }
    }
    
    return isEx;
}


- (void)addIndexPathToParticipantsArray:(NSIndexPath*)indexPath
{
    NSInteger section = indexPath.section;
    NSInteger row = indexPath.row;
    
    BOOL isEx = NO;
    
    Member* me = _rows[section][row];
    
    if (_selectedIndexList.count > 0) {
        for (Member* ip in _selectedIndexList) {
            if (ip.userId == me.userId) {
                isEx = YES;
                break;
            }
        }
        if (!isEx) {
            [_selectedIndexList addObject:me];
        }
    }
    else{
        [_selectedIndexList addObject:me];
    }
}

- (void)removeIndexPathFromParticipantsArray:(NSIndexPath*)indexPath
{
    NSInteger section = indexPath.section;
    NSInteger row = indexPath.row;

    Member* me = _rows[section][row];
    
    if (_selectedIndexList.count > 0) {
        for (Member* ip in _selectedIndexList) {
            if (ip.userId == me.userId) {
                [_selectedIndexList removeObject:ip];
                break;
            }
        }
    }
}


- (void)addIndexPathToCopyToArray:(NSIndexPath*)indexPath
{
    NSInteger section = indexPath.section;
    NSInteger row = indexPath.row;
    
    BOOL isEx = NO;
    
    Member* me = _rows[section][row];
    
    if (_selectedIndexList.count > 0) {
        for (Member* ip in _selectedIndexList) {
            if (ip.userId == me.userId) {
                isEx = YES;
                break;
            }
        }
        if (!isEx) {
            [_selectedIndexList addObject:me];
        }
    }
    else{
        [_selectedIndexList addObject:me];
    }
}

- (void)removeIndexPathFromCopyToArray:(NSIndexPath*)indexPath
{
    NSInteger section = indexPath.section;
    NSInteger row = indexPath.row;
    
    Member* me = _rows[section][row];
    
    if (_selectedIndexList.count > 0) {
        for (Member* ip in _selectedIndexList) {
            if (ip.userId == me.userId) {
                [_selectedIndexList removeObject:ip];
                break;
            }
        }
    }
}

#pragma mark - UITextFieldDelegate
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    //[self diminishTextName:_lblSearch];
    
    if (textField == _txtSearch)
    {
        [self diminishTextName:_lblSearch];

    }
    return YES;
}
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField == _txtSearch)
    {
        [self restoreTextName:_lblSearch textField:_txtSearch];
        if (textField.text != nil && ![textField.text isEqualToString:@""]) {
            
            NSLog(@"Value:");
            
        }
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
- (void)textFieldDidChange
{
    
}

#pragma mark - touchesBegan
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.view endEditing:YES];
    [self restoreTextName:_lblSearch textField:_txtSearch];
}


@end
