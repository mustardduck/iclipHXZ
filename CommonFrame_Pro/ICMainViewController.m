//
//  ICMainViewController.m
//  CommonFrame_Pro
//
//  Created by ionitech on 15/6/2.
//  Copyright (c) 2015年 ionitech. All rights reserved.
//

#import "ICMainViewController.h"
#import "ICMemberTableViewController.h"
#import "ICAccountViewController.h"
#import <MJRefresh.h>
#import <UIActivityIndicator-for-SDWebImage+UIButton/UIImageView+UIActivityIndicatorForSDWebImage.h>
#import <UIImageView+UIActivityIndicatorForSDWebImage.h>
#import "PPDragDropBadgeView.h"
#import "UICommon.h"
#import <Reachability.h>
//#import <AVOSCloud/AVOSCloud.h>
#import "APService.h"

@interface ICMainViewController () <UITableViewDelegate,UITableViewDataSource>
{
    CDSideBarController*    _sideBar;
    ICSideMenuController*   _sideMenu;
    ICSideTopMenuController* _topMenuController;
    
    __weak IBOutlet UITableView*   _tableView;
    IBOutlet UIView*        _smView;
    IBOutlet UIView*        _topMenuView;
    IBOutlet UIButton*      mbutton;
    IBOutlet UIView*        _tbgView;
    
    BOOL                    _isTopMenuSharedButtonClicked;
    
    CGFloat _screenWidth;
    CGFloat _screenHeight;
    
    NSInteger               _pageNo;
    NSInteger               _pageRowCount;
    NSString*               _workGroupId;
    NSMutableArray*         _contentArray;
    NSMutableArray*         _badges;
    NSArray*                _bottomArray;
    NSString*               _TermString;
    NSArray*                _icSideRightMarkArray;
    
    
    NSInteger               _minVal;
    NSInteger               _maxVal;
    
    UIView*                 _markHeadView;
    //    UIView*                 groupHeadView;
    
    Reachability  *hostReach;
    
    Group                   *_currentGroup;
    
    BOOL                    _isMarkShow;
    NSString *              _markNameStr;
    NSInteger               _tagNum;
    
}

- (IBAction)barButtonClicked:(id)sender;


@end

@implementation ICMainViewController

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

- (void)reachabilityChanged:(NSNotification *)note {
    Reachability* curReach = [note object];
    NSParameterAssert([curReach isKindOfClass: [Reachability class]]);
    NetworkStatus status = [hostReach currentReachabilityStatus];
    
    if (status == NotReachable) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示"
                                                        message:@"网络连接异常"
                                                       delegate:nil
                                              cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
    
    if (![LoginUser isKeepLogined]) {
        UIStoryboard* mainStory = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        UIViewController* controller  = [mainStory instantiateViewControllerWithIdentifier:@"ViewController"];
        [self presentViewController:controller animated:YES completion:nil];
        return;
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(reachabilityChanged:)
                                                 name: kReachabilityChangedNotification
                                               object: nil];
    
    hostReach = [Reachability reachabilityWithHostName:@"www.baidu.com"];
    [hostReach startNotifier];
    
    self.loginUserID = [LoginUser loginUserID];
    
    _pageNo = 1;
    _pageRowCount = 5;
    _contentArray = [NSMutableArray array];
    _workGroupId = @"0";
    
    _isTopMenuSharedButtonClicked = NO;
    
    _screenWidth = [UIScreen mainScreen].bounds.size.width;
    _screenHeight = [UIScreen mainScreen].bounds.size.height;
    _TermString = @"";
    
    _minVal = 0;
    _maxVal = 0;
    
    [self addRefrish];
    
    NSArray* markArray = [self loadBottomMenuView:nil isSearchBarOne:YES];
    [self loadTopToolBarView:markArray];
    
    _tableView.delegate = self;
    _tableView.dataSource = self;
    
    /*
    //保存登录用户的通讯录ID
    AVInstallation *currentInstallation = [AVInstallation currentInstallation];
    [currentInstallation addUniqueObject:@"HXZ_loginUsers" forKey:@"channels"];
    [currentInstallation setObject:[LoginUser loginUserID] forKey:@"HXZ_userId"];
    [currentInstallation setObject:[LoginUser loginUserName] forKey:@"HXZ_userName"];
    [currentInstallation saveInBackground];
    */
    
    __autoreleasing NSMutableSet *tags = [NSMutableSet set];
    long long alias = [[LoginUser loginUserID] longLongValue];
    
    NSString * aliStr = [NSString stringWithFormat:@"%lld", alias];
    
    [APService setTags:tags
                 alias:aliStr
      callbackSelector:@selector(tagsAliasCallback:tags:alias:)
                target:self];
}

- (void)tagsAliasCallback:(int)iResCode
                     tags:(NSSet *)tags
                    alias:(NSString *)alias {
    NSString *callbackString =
    [NSString stringWithFormat:@"%d, \ntags: %@, \nalias: %@\n", iResCode,
     [self logSet:tags], alias];
    NSLog(@"TagsAlias回调:%@", callbackString);
}

- (NSString *)logSet:(NSSet *)dic {
    if (![dic count]) {
        return nil;
    }
    NSString *tempStr1 =
    [[dic description] stringByReplacingOccurrencesOfString:@"\\u"
                                                 withString:@"\\U"];
    NSString *tempStr2 =
    [tempStr1 stringByReplacingOccurrencesOfString:@"\"" withString:@"\\\""];
    NSString *tempStr3 =
    [[@"\"" stringByAppendingString:tempStr2] stringByAppendingString:@"\""];
    NSData *tempData = [tempStr3 dataUsingEncoding:NSUTF8StringEncoding];
    NSString *str =
    [NSPropertyListSerialization propertyListFromData:tempData
                                     mutabilityOption:NSPropertyListImmutable
                                               format:NULL
                                     errorDescription:NULL];
    return str;
}

#pragma mark -
#pragma init view

- (NSArray*)loadBottomMenuView:(NSString*)searchString isSearchBarOne:(BOOL)isBarOne
{
    BOOL isSearch = NO;
    if ([searchString isEqualToString:@"-101"]) {
        searchString = nil;
        isSearch = YES;
    }
    
    NSArray* nameList = @[@"群组",@"群组",@"群组",@"群组",@"群组",@"群组",@"群组",@"群组",@"群组",@"申请"];
    NSArray *imageListBottom = @[@"icon_touxiang", @"icon_touxiang",@"icon_touxiang", @"icon_touxiang", @"icon_touxiang",@"icon_touxiang", @"icon_touxiang",@"icon_touxiang",@"icon_touxiang", @"icon_touxiang"];
    NSArray* badgeList =@[@"0",@"0",@"0",@"0",@"0",@"0",@"0",@"0",@"0",@"0"];
    
    if(_sideMenu != nil)
        _sideMenu = nil;
    for (UIControl* control in _smView.subviews) {
        [control removeFromSuperview];
    }
    
    [_smView setFrame:CGRectMake(0, 0, _screenWidth, _screenHeight)];
    
    NSArray* markArray = [NSArray array];
    NSMutableArray * muArr = [[NSMutableArray alloc] init];
    Group * gr = [[Group alloc] init];
    gr.workGroupId = @"0";
    gr.workGroupName = @"全部";
    gr.messageCount = @"0";
    
    [muArr addObject:gr];
    
    [muArr addObjectsFromArray:[Group getGroupsByUserID:self.loginUserID marks:&markArray workGroupId:_workGroupId searchString:(isBarOne ? searchString : nil)]];
    
    _bottomArray = [NSArray arrayWithArray:muArr];
    
    if (_bottomArray.count > 0) {
        NSMutableArray* imgs = [NSMutableArray array];
        NSMutableArray* names = [NSMutableArray array];
        _badges = [NSMutableArray array];
        
        for (Group* gp in _bottomArray) {
            if (gp.workGroupImg == nil) {
                gp.workGroupImg = @"";
            }
            [imgs addObject:gp.workGroupImg];
            [names addObject:gp.workGroupName];
            [_badges addObject:gp.messageCount];
        }
        _sideMenu = [[ICSideMenuController alloc] initWithImages:imgs menusName:names badgeValue:_badges  onView:_smView searchText:searchString isFirstSearchBar:isBarOne];
        
    }
    else
        _sideMenu = [[ICSideMenuController alloc] initWithImages:imageListBottom menusName:nameList badgeValue:badgeList  onView:_smView searchText:searchString  isFirstSearchBar:isBarOne];
    
    NSMutableArray* sectionArray = [NSMutableArray array];
    NSArray*        memberArray = [Member getAllMembers:&sectionArray searchText:((!isBarOne && searchString != nil) ? searchString : nil)];
    
    _sideMenu.indexBarSectionArray = sectionArray;
    _sideMenu.dataArray = memberArray;
    
    _sideMenu.delegate = self;
    
    if (searchString != nil || isSearch) {
        [_sideMenu showMenu];
        if (!isBarOne) {
            [_sideMenu btnShowAllGroup:nil];
        }
    }
    
    return markArray;
}

- (UIBarButtonItem*)loadTopMenusView
{
    UIButton* btn2 = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 50, 30)];
    btn2.titleLabel.textColor = [UIColor whiteColor];
    [btn2 setBackgroundColor:[UIColor clearColor]];
    [btn2 setImage:[UIImage imageNamed:@"btn_fabu"] forState:UIControlStateNormal];
    
    NSArray* topMenuImageList = @[[UIImage imageNamed:@"btn_renwu"], [UIImage imageNamed:@"btn_wenti"], [UIImage imageNamed:@"btn_jianyi"], [UIImage imageNamed:@"btn_qita"]];
    NSArray* topMenuNameList = @[@"任务",@"问题",@"建议", @"其它"];
    
    _topMenuController = [[ICSideTopMenuController alloc] initWithMenuNameList:topMenuNameList menuImageList:topMenuImageList actionControl:btn2 parentView:_topMenuView];
    _topMenuController.delegate = self;
    
    UIBarButtonItem* b2btn = [[UIBarButtonItem alloc] initWithCustomView:btn2];
    
    return b2btn;
}

- (UIBarButtonItem *)loadRightMarkMenusView:(NSArray*)markArray;
{
    //Right Menu
    UIButton *button  = [[UIButton alloc] initWithFrame:CGRectMake(100, 100, 30, 30)];
    [button setBackgroundColor:[UIColor clearColor]];
    
    
    UIBarButtonItem* barButton = [[UIBarButtonItem alloc] initWithCustomView:button];
    
    _icSideRightMarkArray = [NSArray array];
    
    if (markArray.count > 0) {
        _icSideRightMarkArray = [NSArray arrayWithArray:markArray];
    }
    
    _sideBar = [[CDSideBarController alloc] initWithImages:nil  names:_icSideRightMarkArray  menuButton:button];
    _sideBar.delegate = self;
    
    return barButton;
}

- (void)loadTopToolBarView:(NSArray*)markArray
{
    NSMutableArray *tright = [NSMutableArray array];
    
    UIBarButtonItem* barButton = [self loadRightMarkMenusView:markArray];
    UIBarButtonItem* b2btn = [self loadTopMenusView];
    
    [tright addObject:barButton];
    [tright addObject:b2btn];
    
    self.navigationItem.rightBarButtonItems = tright;
    
    [self setNaviLeftBarItem:@"回形针"];
}

- (void) setNaviLeftBarItem:(NSString *)titleName
{
    UIButton* left = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 28, 28)];
    left.titleLabel.textColor = [UIColor whiteColor];
    [left setBackgroundColor:[UIColor clearColor]];
    [left setImage:[UIImage imageNamed:@"icon_logo"] forState:UIControlStateNormal];
    [left addTarget:self action:@selector(btnIconClicked) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem* bLeft = [[UIBarButtonItem alloc] initWithCustomView:left];
    
    UIBarButtonItem* barLeftButton = [[UIBarButtonItem alloc] init];
    [barLeftButton setTitle: titleName];
    [barLeftButton setTarget:self];
    
    NSMutableDictionary *textAttrs=[NSMutableDictionary dictionary];
    textAttrs[NSForegroundColorAttributeName]=[UIColor whiteColor];
    [barLeftButton setTitleTextAttributes:textAttrs forState:UIControlStateNormal];
    
    NSMutableArray *tList = [NSMutableArray array];
    [tList addObject:bLeft];
    [tList addObject:barLeftButton];
    
    self.navigationItem.leftBarButtonItems= tList;
}

- (void)btnPhotoClicked:(id)sender
{
    //    if (_group.isAdmin) {
    UIStoryboard* mainStrory = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    UIViewController* controller = [mainStrory instantiateViewControllerWithIdentifier:@"ICSettingGroupViewController"];
    ((ICSettingGroupViewController*)controller).workGroupId = _currentGroup.workGroupId;
    ((ICSettingGroupViewController*)controller).workGroup = _currentGroup;
    ((ICSettingGroupViewController*)controller).icGroupDetailController = self;
    [self.navigationController pushViewController:controller animated:YES];
    //    }
    //    else
    //    {
    //        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"权限不足，因为您不是该工作组创建者！" delegate:self
    //                                              cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    //        [alert show];
    //    }
    
    
}

- (void) fillCurrentGroup:(NSDictionary *) dataDic
{
    _currentGroup = nil;
    
    if([_workGroupId integerValue])
    {
        Group * gr = [Group new];
        
        id dDic = [dataDic valueForKey:@"work"];
        if ([dDic isKindOfClass:[NSDictionary class]])
        {
            NSDictionary * dic = (NSDictionary *)dDic;
            
            gr.userName = [dic valueForKey:@"userName"];
            gr.workGroupName = [dic valueForKey:@"workGroupName"];
            gr.workGroupId = [dic valueForKey:@"workGroupId"];
            gr.workGroupImg = [dic valueForKey:@"workGroupImg"];
            gr.workGroupMain = [dic valueForKey:@"workGroupMain"];
            
            _currentGroup = gr;
        }
    }
    
    [self resetHeaderView];
}

- (NSMutableArray *)fillContentArr:(NSDictionary *)dataDic
{
    NSMutableArray * array = [NSMutableArray array];
    
    NSInteger totalPages = [[dataDic valueForKey:@"totalPages"] integerValue];
    
    id dataArr = [dataDic valueForKey:@"datalist"];
    if ([dataArr isKindOfClass:[NSArray class]])
    {
        NSArray* dArr = (NSArray*)dataArr;
        
        for (id data in dArr) {
            if ([data isKindOfClass:[NSDictionary class]]) {
                
                NSDictionary* di = (NSDictionary*)data;
                
                Mission* cm = [Mission new];
                
                cm.monthAndDay = [NSString stringWithFormat:@"%@/%@",[di valueForKey:@"monthStr"],[di valueForKey:@"dayStr"]];
                cm.hour = [di valueForKey:@"hourStr"];
                cm.planExecTime = [di valueForKey:@"planExecTime"];
                cm.type = [[di valueForKey:@"type"] integerValue];
                cm.isPlanTask = [[di valueForKey:@"isPlanTask"] boolValue];
                cm.finishTime = [di valueForKey:@"finishTime"];
                cm.createUserId = [di valueForKey:@"createUserId"];
                cm.taskId = [di valueForKey:@"taskId"];
                cm.workGroupId = [di valueForKey:@"workGroupId"];
                cm.workGroupName = [di valueForKey:@"wgName"];
                cm.main = [di valueForKey:@"main"];
                cm.title = [di valueForKey:@"title"];
                cm.userImg = [di valueForKey:@"userImg"];
                cm.status = [[di valueForKey:@"status"] integerValue];
                cm.userName = [di valueForKey:@"userName"];
                cm.isAccessory = [[di valueForKey:@"isAccessory"] boolValue];
                cm.totalPages = totalPages;
                cm.isRead = [[di valueForKey:@"isRead"] boolValue];
                cm.accessoryNum = [[di valueForKey:@"accessoryNum"] intValue];
                cm.replayNum = [[di valueForKey:@"replayNum"] intValue];
                cm.labelList = [di objectForKey:@"labelList"];
                
                [array addObject:cm];
                
            }
        }
        
    }
    
    return array;
}

- (void)addRefrish
{
    if ([_tableView.header isRefreshing]) {
        return;
    }
    if ([_tableView.footer isRefreshing]) {
        return;
    }
    
    [_tableView addLegendHeaderWithRefreshingBlock:^{
        
        _pageNo = 1;
        
        NSDictionary * dic = [Mission getMssionListbyUserID:self.loginUserID currentPageIndex:_pageNo pageSize:_pageRowCount workGroupId:_workGroupId termString:_TermString];
        
        NSMutableArray * newArr = [self fillContentArr:dic];
        
        [self fillCurrentGroup:dic];
        
        _contentArray = newArr;
        
        NSLog(@"Header:%@",_contentArray);
        
        [_tableView reloadData];
        
        [_tableView.header endRefreshing];
        
    }];
    
    
    [_tableView.header beginRefreshing];
    
    [_tableView addLegendFooterWithRefreshingBlock:^{
        
        _pageNo++;
        
        NSDictionary * dic = [Mission getMssionListbyUserID:self.loginUserID currentPageIndex:_pageNo pageSize:_pageRowCount workGroupId:_workGroupId termString:_TermString];
        NSMutableArray * newArr = [self fillContentArr:dic];
        
        if (newArr.count > 0) {
            [_contentArray addObjectsFromArray:newArr];
            
            NSLog(@"%@",_contentArray);
            
            [_tableView reloadData];
            
            Mission* m = [newArr objectAtIndex:0];
            if (_pageNo >= m.totalPages) {
                [_tableView.footer endRefreshing];
                
                [_tableView.footer noticeNoMoreData];
            }
            else
            {
                [_tableView.footer endRefreshing];
            }
        }
        else
        {
            [_tableView.footer endRefreshing];
            [_tableView.footer noticeNoMoreData];
        }
    }];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if (_strIndexForDetail != nil) {
        NSInteger index = [self.strIndexForDetail  integerValue];
        [_contentArray removeObjectAtIndex:index];
        
        [_tableView beginUpdates];
        [_tableView deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:index inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];
        [_tableView endUpdates];
    }
    
    
    if (_pubGroupId != nil )
    {
        _workGroupId = _pubGroupId;
        _TermString = @"";
        [_tableView.header beginRefreshing];
    }
    
    /*
    if (_hasCreatedNewGroup != nil) {
        if (![_hasCreatedNewGroup isEqualToString:@"0"])
        {
            _pubGroupId = nil;
            
            _tableView.tableHeaderView = nil;
            _markHeadView = nil;
            
            UIButton* button = (UIButton*)sender;
            NSInteger index = button.tag;
            
            Mission* mi = [_bottomArray objectAtIndex:index];
            _workGroupId = _hasCreatedNewGroup;
            
            if(![_workGroupId integerValue])//全部
            {
                
            }
            
            [self setNaviLeftBarItem:mi.workGroupName];
            
            _TermString = @"";
            [self addRefrish];
            
            _sideMenu.clickedButtonTag = button.tag;
            
            if (!_sideMenu.isOpen) {
                [_sideMenu showMenu];
            }
            
            [self resetRightMarkView];
            
        }

//        if ([_hasCreatedNewGroup isEqualToString:@"1"]) {
//            
//            UIStoryboard* mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
//            UIViewController* vc = [mainStoryboard instantiateViewControllerWithIdentifier:@"ICGroupListViewController"];
//            ((ICGroupListViewController*)vc).icMainViewController = self;
//            [self.navigationController pushViewController:vc animated:YES];
//        }
    }
     */
    
    [self resetRightMarkView];//刷新主页右边的标签
    
    [self loadBottomMenuView:nil isSearchBarOne:YES];//刷新主页底部的群组

}

- (void)resetRightMarkView
{
    NSMutableArray * markArray = [NSMutableArray arrayWithArray:[self loadBottomMenuView:nil isSearchBarOne:YES]];
    _icSideRightMarkArray = markArray;
    _sideBar.nameList = markArray;
    [_sideBar.mainTableView reloadData];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}


- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [_sideBar insertMenuButtonOnView:[UIApplication sharedApplication].delegate.window atPosition:CGPointMake(self.view.frame.size.width - 70, 50)];
}


- (IBAction)barButtonClicked:(id)sender
{
    
}

- (void)btnIconClicked
{
    UIStoryboard* mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    UIViewController* vc = [mainStoryboard instantiateViewControllerWithIdentifier:@"ICSettingViewController"];
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma make -
#pragma  Side Top Menu Controller Action

- (void)icSideTopMenuButtonClicked:(id)sender
{
    // Execute code
    UIButton* button = (UIButton*)sender;
    NSInteger index = button.tag;
    
    if (index == 0) {//任务
        
        UIStoryboard* mainStory = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        UIViewController* vc = [mainStory instantiateViewControllerWithIdentifier:@"ICGroupListViewController"];
        ((ICGroupListViewController*)vc).currentViewGroupType = GroupTypeMission;
        ((ICGroupListViewController*)vc).icMainViewController = self;
        /*
         ((ICGroupListViewController*)vc).currentViewGroupType = GroupTypeMission;
         ((ICGroupListViewController*)vc).icPublishMissionResponsibleController = self;
         ((ICGroupListViewController*)vc).responsibleDictionaryToPublish = _responsibleDic;
         ((ICGroupListViewController*)vc).hasValue = @"0";
         */
        
        [self.navigationController pushViewController:vc animated:YES];
    }
    else if (index == 1) {//问题
        _isTopMenuSharedButtonClicked = YES;
        
        UIStoryboard* mainStory = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        UIViewController* vc = [mainStory instantiateViewControllerWithIdentifier:@"ICGroupListViewController"];
        ((ICGroupListViewController*)vc).currentViewGroupType = GroupTypeSharedAndNotify;
        ((ICGroupListViewController*)vc).icMainViewController = self;
        ((ICGroupListViewController*)vc).isShared = 1;
        [self.navigationController pushViewController:vc animated:YES];
        
    }
    else if (index == 2) {//建议
        _isTopMenuSharedButtonClicked = NO;
        UIStoryboard* mainStory = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        UIViewController* vc = [mainStory instantiateViewControllerWithIdentifier:@"ICGroupListViewController"];
        ((ICGroupListViewController*)vc).currentViewGroupType = GroupTypeSharedAndNotify;
        ((ICGroupListViewController*)vc).icMainViewController = self;
        ((ICGroupListViewController*)vc).isShared = 2;
        [self.navigationController pushViewController:vc animated:YES];
        
    }
    else if (index == 3) {//其它
        _isTopMenuSharedButtonClicked = NO;
        UIStoryboard* mainStory = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        UIViewController* vc = [mainStory instantiateViewControllerWithIdentifier:@"ICGroupListViewController"];
        ((ICGroupListViewController*)vc).currentViewGroupType = GroupTypeSharedAndNotify;
        ((ICGroupListViewController*)vc).icMainViewController = self;
        ((ICGroupListViewController*)vc).isShared = 3;
        [self.navigationController pushViewController:vc animated:YES];
        
    }
}

- (void) resetHeaderView
{
    _tableView.tableHeaderView = nil;
    
    if(!_currentGroup && _isMarkShow)
    {
        _tableView.tableHeaderView = ({
            [self markHeaderView];
        });
    }
    else if (_currentGroup && !_isMarkShow)
    {
        _tableView.tableHeaderView = ({
            [self groupHeaderView];
        });
    }
    else if(_currentGroup && _isMarkShow)
    {
        _tableView.tableHeaderView = ({
            [self groupAndMarkHeaderView];
        });
    }
    
    [_tableView.header beginRefreshing];
}

#pragma make -
#pragma  Side Bar Controller Action

- (void)cdSliderCellClicked:(NSIndexPath *)indexPath
{
    NSInteger tag = 0;
    
    Mark *m = _icSideRightMarkArray[indexPath.section][indexPath.row][indexPath.subRow];
    
    if(indexPath.row == 0)
    {
        tag = 1;
        
        _minVal = - [m.labelId integerValue];
    }
    else if (indexPath.row == 1)
    {
        tag = 3;
        
        _minVal = - [m.labelId integerValue];
    }
    else if (indexPath.row == 2)
    {
        tag = 2;
        _maxVal = [m.labelId integerValue];
    }
    
    if (_minVal != 0 && _maxVal == 0) {
        _TermString = [NSString stringWithFormat:@"%ld",(NSInteger)_minVal];
    }
    else if (_minVal == 0 && _maxVal != 0) {
        _TermString = [NSString stringWithFormat:@"%ld",(NSInteger)_maxVal];
    }
    else if (_minVal != 0 && _maxVal != 0) {
        _TermString = [NSString stringWithFormat:@"%ld,%ld",(NSInteger)_minVal,(NSInteger)_maxVal];
    }
    
    [self loadTopMarkView:m.labelName markTag:tag];
    
    [_tableView.header beginRefreshing];

}

- (void)loadTopMarkView:(NSString*)markName markTag:(NSInteger)tag
{
    _isMarkShow = YES;

    _markNameStr = markName;
    
    _tagNum = tag;
    
//    [self resetHeaderView];
    
}

- (UIView *) groupAndMarkHeaderView
{
    CGFloat tableWidth = [UIScreen mainScreen].bounds.size.width;
    
    UIView * mainHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableWidth, 129 + 40)];
    
    mainHeaderView.backgroundColor = [UIColor clearColor];
    
    UIView * groupHeadView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableWidth, 300 - 171)];
    
    
    //groupHeader
    
    if(_currentGroup)
    {
        
        [groupHeadView setBackgroundColor:[UIColor greyStatusBarColor]];
        
        UIImageView* bgImage = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, tableWidth, 256 - 171)];
        [bgImage setBackgroundColor:[UIColor clearColor]];
        //[bgImage setImage:[UIImage imageNamed:@"bimg.jpg"]];
        [bgImage setImageWithURL:[NSURL URLWithString:_currentGroup.workGroupImg] placeholderImage:[UIImage imageNamed:@"bg_qunzutou_1"] options:SDWebImageDelayPlaceholder usingActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        
        [groupHeadView addSubview:bgImage];
        
        UIView* sView = [[UIView alloc] initWithFrame:CGRectMake(tableWidth - 90, 196 - 171, 80, 80)];
        [sView setBackgroundColor:[UIColor colorWithHexString:@"#393b48"]];
        
        UIImageView* sImage = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 60, 60)];
        [sImage setBackgroundColor:[UIColor clearColor]];
        [sImage setImage:[UIImage imageNamed:@"icon_touxiang"]];
        [sImage setImageWithURL:[NSURL URLWithString:_currentGroup.workGroupImg] placeholderImage:[UIImage imageNamed:@"icon_touxiang"] options:SDWebImageDelayPlaceholder usingActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        
        UIButton* btnPhoto = [[UIButton alloc] initWithFrame:CGRectMake(5, 5, 70, 70)];
        [btnPhoto setBackgroundColor:[UIColor clearColor]];
        [btnPhoto setBackgroundImage:sImage.image forState:UIControlStateNormal];
        [btnPhoto addTarget:self action:@selector(btnPhotoClicked:) forControlEvents:UIControlEventTouchUpInside];
        
        [sView addSubview:btnPhoto];
        
        [groupHeadView addSubview:sView];
        
        UILabel* gName = [[UILabel alloc ] initWithFrame:CGRectMake(20, 219 - 171, 190, 20)];
        [gName setBackgroundColor:[UIColor clearColor]];
        [gName setFont:[UIFont boldSystemFontOfSize:19]];
        [gName setTextAlignment:NSTextAlignmentRight];
        [gName setTextColor:[UIColor whiteColor]];
        [gName setNumberOfLines:1];
        
        [gName setText:_currentGroup.workGroupName];
        
        [groupHeadView addSubview:gName];
        
        
        
        UILabel* lbl = [[UILabel alloc ] initWithFrame:CGRectMake(15, 276 - 171, tableWidth - 30, 20)];
        [lbl setBackgroundColor:[UIColor clearColor]];
        [lbl setFont:[UIFont systemFontOfSize:15]];
        [lbl setTextAlignment:NSTextAlignmentRight];
        [lbl setTextColor:[UIColor grayColor]];
        [lbl setNumberOfLines:1];
        
        [lbl setText:_currentGroup.workGroupMain];
        
        [groupHeadView addSubview:lbl];
        
        //        [mainHeaderView addSubview:groupHeadView];
        
    }
    
    //    [mainHeaderView addSubview:_markHeadView];
    
    //markHeaderView
    /*
     if (!_markHeadView) {
     _markHeadView = [[UIView alloc] initWithFrame:CGRectMake(0, 129, tableWidth, 40)];
     [_markHeadView setBackgroundColor:[UIColor colorWithRed:0.15f green:0.15f blue:0.15f alpha:1.0f]];
     
     UILabel* name = [[UILabel alloc] initWithFrame:CGRectMake(12, 8, 80, 24)];
     [name setText:_markNameStr];
     [name setTextColor:[UIColor whiteColor]];
     [name setTextAlignment:NSTextAlignmentCenter];
     [name setBackgroundColor:[UIColor colorWithRed:0.40 green:0.48 blue:0.94 alpha:1.0]];
     [name setFont:[UIFont systemFontOfSize:13]];
     name.tag = _tagNum;
     [_markHeadView addSubview:name];
     
     
     UIButton* close = [[UIButton alloc] initWithFrame:CGRectMake(tableWidth - 40, 0, 40, 36)];
     [close setImage:[UIImage imageNamed:@"btn_guanbi_1"] forState:UIControlStateNormal];
     [close addTarget:self action:@selector(btnCloseClicked:) forControlEvents:UIControlEventTouchUpInside];
     [_markHeadView addSubview:close];
     
     
     UILabel* bottomLine = [[UILabel alloc] initWithFrame:CGRectMake(0, 39.5, tableWidth, 0.5)];
     [bottomLine setBackgroundColor:[UIColor grayColor]];
     [_markHeadView addSubview:bottomLine];
     
     }
     else
     {
     BOOL hasEx = NO;
     for (UIControl* control in _markHeadView.subviews) {
     if ([control isKindOfClass:[UILabel class]]) {
     UILabel* lbl = (UILabel*)control;
     if (lbl.tag == _tagNum) {
     hasEx = YES;
     lbl.text = _markNameStr;
     break;
     }
     }
     }
     if (!hasEx) {
     
     UILabel* name = [[UILabel alloc] initWithFrame:CGRectMake(102, 8, 80, 24)];
     [name setText:_markNameStr];
     [name setTextColor:[UIColor whiteColor]];
     [name setTextAlignment:NSTextAlignmentCenter];
     [name setBackgroundColor:[UIColor colorWithRed:0.40 green:0.48 blue:0.94 alpha:1.0]];
     [name setFont:[UIFont systemFontOfSize:13]];
     name.tag = _tagNum;
     [_markHeadView addSubview:name];
     }
     }
     */
    return groupHeadView;
    
}

- (UIView *)groupHeaderView
{
    CGFloat tableWidth = [UIScreen mainScreen].bounds.size.width;
    
    UIView * groupHeadView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableWidth, 300 - 171)];
    
    [groupHeadView setBackgroundColor:[UIColor greyStatusBarColor]];
    
    UIImageView* bgImage = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, tableWidth, 256 - 171)];
    [bgImage setBackgroundColor:[UIColor clearColor]];
    //[bgImage setImage:[UIImage imageNamed:@"bimg.jpg"]];
    [bgImage setImageWithURL:[NSURL URLWithString:_currentGroup.workGroupImg] placeholderImage:[UIImage imageNamed:@"bg_qunzutou_1"] options:SDWebImageDelayPlaceholder usingActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    
    [groupHeadView addSubview:bgImage];
    
    UIView* sView = [[UIView alloc] initWithFrame:CGRectMake(tableWidth - 90, 196 - 171, 80, 80)];
    [sView setBackgroundColor:[UIColor colorWithHexString:@"#393b48"]];
    
    UIImageView* sImage = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 60, 60)];
    [sImage setBackgroundColor:[UIColor clearColor]];
    [sImage setImage:[UIImage imageNamed:@"icon_touxiang"]];
    [sImage setImageWithURL:[NSURL URLWithString:_currentGroup.workGroupImg] placeholderImage:[UIImage imageNamed:@"icon_touxiang"] options:SDWebImageDelayPlaceholder usingActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    
    UIButton* btnPhoto = [[UIButton alloc] initWithFrame:CGRectMake(5, 5, 70, 70)];
    [btnPhoto setBackgroundColor:[UIColor clearColor]];
    [btnPhoto setBackgroundImage:sImage.image forState:UIControlStateNormal];
    [btnPhoto addTarget:self action:@selector(btnPhotoClicked:) forControlEvents:UIControlEventTouchUpInside];
    
    [sView addSubview:btnPhoto];
    
    [groupHeadView addSubview:sView];
    
    UILabel* gName = [[UILabel alloc ] initWithFrame:CGRectMake(20, 219 - 171, 190, 20)];
    [gName setBackgroundColor:[UIColor clearColor]];
    [gName setFont:[UIFont boldSystemFontOfSize:19]];
    [gName setTextAlignment:NSTextAlignmentRight];
    [gName setTextColor:[UIColor whiteColor]];
    [gName setNumberOfLines:1];
    
    [gName setText:_currentGroup.workGroupName];
    
    [groupHeadView addSubview:gName];
    
    
    
    UILabel* lbl = [[UILabel alloc ] initWithFrame:CGRectMake(15, 276 - 171, tableWidth - 30, 20)];
    [lbl setBackgroundColor:[UIColor clearColor]];
    [lbl setFont:[UIFont systemFontOfSize:15]];
    [lbl setTextAlignment:NSTextAlignmentRight];
    [lbl setTextColor:[UIColor grayColor]];
    [lbl setNumberOfLines:1];
    
    [lbl setText:_currentGroup.workGroupMain];
    
    [groupHeadView addSubview:lbl];
    
    return groupHeadView;
}

- (UIView *) markHeaderView
{
    CGFloat sWidth = [UIScreen mainScreen].bounds.size.width;
    
    if(_isMarkShow)
    {
        if (!_markHeadView) {
            _markHeadView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, sWidth, 40)];
            [_markHeadView setBackgroundColor:[UIColor colorWithRed:0.15f green:0.15f blue:0.15f alpha:1.0f]];
            
            UILabel* name = [[UILabel alloc] initWithFrame:CGRectMake(12, 8, 80, 24)];
            [name setText:_markNameStr];
            [name setTextColor:[UIColor whiteColor]];
            [name setTextAlignment:NSTextAlignmentCenter];
            [name setBackgroundColor:[UIColor colorWithRed:0.40 green:0.48 blue:0.94 alpha:1.0]];
            [name setFont:[UIFont systemFontOfSize:13]];
            name.tag = _tagNum;
            [_markHeadView addSubview:name];
            
            
            UIButton* close = [[UIButton alloc] initWithFrame:CGRectMake(sWidth - 40, 0, 40, 36)];
            [close setImage:[UIImage imageNamed:@"btn_guanbi_1"] forState:UIControlStateNormal];
            [close addTarget:self action:@selector(btnCloseClicked:) forControlEvents:UIControlEventTouchUpInside];
            [_markHeadView addSubview:close];
            
            
            UILabel* bottomLine = [[UILabel alloc] initWithFrame:CGRectMake(0, 39.5, sWidth, 0.5)];
            [bottomLine setBackgroundColor:[UIColor grayColor]];
            [_markHeadView addSubview:bottomLine];
            
        }
        else
        {
            BOOL hasEx = NO;
            for (UIControl* control in _markHeadView.subviews) {
                if ([control isKindOfClass:[UILabel class]]) {
                    UILabel* lbl = (UILabel*)control;
                    if (lbl.tag == _tagNum) {
                        hasEx = YES;
                        lbl.text = _markNameStr;
                        break;
                    }
                }
            }
            if (!hasEx) {
                
                UILabel* name = [[UILabel alloc] initWithFrame:CGRectMake(102, 8, 80, 24)];
                [name setText:_markNameStr];
                [name setTextColor:[UIColor whiteColor]];
                [name setTextAlignment:NSTextAlignmentCenter];
                [name setBackgroundColor:[UIColor colorWithRed:0.40 green:0.48 blue:0.94 alpha:1.0]];
                [name setFont:[UIFont systemFontOfSize:13]];
                name.tag = _tagNum;
                [_markHeadView addSubview:name];
            }
        }
    }
    
    return _markHeadView;
}

- (void)btnCloseClicked:(UIButton*)btn
{
    _tableView.tableHeaderView = nil;
    _isMarkShow = NO;
    _markHeadView = nil;
    _TermString = @"";
    [_tableView.header beginRefreshing];
}


#pragma -
#pragma Side Menu delegate

- (void)partfarmButtonClicked:(NSString*)val
{
    NSInteger index = [val integerValue];
    switch (index) {
        case 1:
            
            if (_topMenuController.isOpen) {
                [_topMenuController showTopMenu:@"1"];
            }
            else
            {
                _topMenuController.isOpen = NO;
                [_topMenuController showTopMenu:@"1"];
            }
            
            if (_sideBar.isOpen) {
                [_sideBar dismissMenu];
            }
            
            if (!_sideMenu.isOpen) {
                [_sideMenu showMenu];
            }
            break;
        case 2:
            
            if (_topMenuController.isOpen) {
                [_topMenuController showTopMenu:@"1"];
            }
            
            if (!_sideMenu.isOpen) {
                [_sideMenu showMenu];
            }
            break;
        case 3:
            
            
            if (_topMenuController.isOpen) {
                [_topMenuController showTopMenu:@"1"];
            }
            
            if (_sideBar.isOpen) {
                [_sideBar dismissMenu];
            }
            
            [_sideMenu showMenu];
            
            break;
        default:
            break;
    }
}


- (void)icSideMenuClicked:(id)sender
{
    _pubGroupId = nil;
    
    _tableView.tableHeaderView = nil;
    _markHeadView = nil;
    
    UIButton* button = (UIButton*)sender;
    NSInteger index = button.tag;
    
    Mission* mi = [_bottomArray objectAtIndex:index];
    _workGroupId = mi.workGroupId;
    
    if(![_workGroupId integerValue])//全部
    {
        
    }
    
    [self setNaviLeftBarItem:mi.workGroupName];
    
    _TermString = @"";
    [self addRefrish];
    
    //_sideMenu.isOpen = FALSE;
    _sideMenu.clickedButtonTag = button.tag;
    
    if (!_sideMenu.isOpen) {
        [_sideMenu showMenu];
    }
    
    [self resetRightMarkView];
    
    NSLog(@"Clicked !!");
}

- (void)bottomSideViewSearchTextPageOneSubmitEvent:(NSString*)searchTextFieldStr
{
    NSLog(@"value : %@",searchTextFieldStr);
    
    if (searchTextFieldStr != nil && ![searchTextFieldStr isEqualToString:@""]) {
        [self loadBottomMenuView:searchTextFieldStr isSearchBarOne:YES];
    }
    else
    {
        [self loadBottomMenuView:@"-101" isSearchBarOne:YES];
    }
    
    
    //UIStoryboard* mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    //UIViewController* vc = [mainStoryboard instantiateViewControllerWithIdentifier:@"ICSearchViewController"];
    
    //[self.navigationController pushViewController:vc animated:YES];
}

- (void)bottomSideViewSearchTextPageTwoSubmitEvent:(NSString*)searchTextFieldStr
{
    NSLog(@"value : %@",searchTextFieldStr);
    if (searchTextFieldStr != nil && ![searchTextFieldStr isEqualToString:@""]) {
        [self loadBottomMenuView:searchTextFieldStr isSearchBarOne:NO];
    }
    else
    {
        [self loadBottomMenuView:@"-101" isSearchBarOne:NO];
    }
}

#pragma mark - bottom side menu bar
- (void)leftTopBarButtonClicked:(id)sender
{
    UIStoryboard* mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    UIViewController* vc = [mainStoryboard instantiateViewControllerWithIdentifier:@"ICMemberTableViewController"];
    ((ICMemberTableViewController*)vc).controllerType = MemberViewFromControllerGroupList;
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)btnCreateNewGroup:(id)sender
{
    UIStoryboard* mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    UIViewController* vc = [mainStoryboard instantiateViewControllerWithIdentifier:@"ICCreateNewGroupViewController"];
    ((ICCreateNewGroupViewController*)vc).icMainController = self;
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

- (void)tableViewCellDidClicked:(UITableView*)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    Member* m = _sideMenu.dataArray[indexPath.section][indexPath.row];
    m.workGroupId = @"0";//查找工作组成员动态
    
    if (m != nil) {
        UIStoryboard* mainStory = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        UIViewController* vc;
        vc = [mainStory instantiateViewControllerWithIdentifier:@"ICMemberInfoViewController"];
        ((ICMemberInfoViewController*)vc).memberObj = m;
        [self.navigationController pushViewController:vc animated:YES];
    }
    
}

#pragma mark - SlideNavigationController Methods -

- (BOOL)slideNavigationControllerShouldDisplayLeftMenu
{
    return YES;
}


#pragma -
#pragma mark Table View Delegate Action

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //    CGFloat cellHeight = _screenHeight * 0.321;
    
    Mission* ms = [_contentArray objectAtIndex:indexPath.row];
    
    CGFloat contentH = [UICommon getSizeFromString:ms.main withSize:CGSizeMake(_screenWidth - (77.5 + 39), 80) withFont:18].height;
    
    CGFloat cellHeight = contentH + 70 + 42 + 28;
    
    if (indexPath.row == 0) {
        cellHeight = cellHeight + 37;
    }
    
    return cellHeight;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _contentArray.count;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger index = indexPath.row;
    
    static NSString *cellId = @"MainTableViewCellIdentitifer";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
    }
    
    for(UIView *view in cell.contentView.subviews) {
        [view removeFromSuperview];
    }
    
    if (cell.contentView.subviews.count == 0) {
        
        //        CGFloat cellHeight = _screenHeight * 0.321;
        Mission* ms = [_contentArray objectAtIndex:indexPath.row];
        
        CGFloat contentH = [UICommon getSizeFromString:ms.main withSize:CGSizeMake(_screenWidth - (77.5 + 39), 80) withFont:18].height;
        
        CGFloat cellHeight = contentH + 70 + 42 + 28;
        
        if (indexPath.row == 0) {
            cellHeight = cellHeight + 37;
        }
        
        CGFloat contentHeight = cellHeight;
        CGFloat contentWidth = _screenWidth;
        
        UIView* dirLine = [[UIView alloc] init];
        
        BOOL isFristIndex = NO;
        
        if (index == 0) {
            isFristIndex = YES;
            UIImageView* timeIcon = [[UIImageView alloc] initWithFrame:CGRectMake(50, 19, 15, 15)];
            [timeIcon setImage:[UIImage imageNamed:@"icon_shijian"]];
            [timeIcon setBackgroundColor:[UIColor clearColor]];
            [cell.contentView addSubview:timeIcon];
            //[menuButton setImageWithURL:[NSURL URLWithString:[_imageList objectAtIndex:index]]  forState:UIControlStateNormal placeholderImage:[UIImage imageNamed:@"icon_touxiang"] usingActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
            
            dirLine.frame = CGRectMake(timeIcon.frame.origin.x + 7.5, timeIcon.frame.origin.y + 15, 0.5, contentHeight - timeIcon.frame.origin.y - timeIcon.frame.size.height);
        }
        else
        {
            dirLine.frame = CGRectMake(57.5, 0, 0.5, contentHeight);
        }
        
        [dirLine setBackgroundColor:[UIColor whiteColor]];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [cell.contentView addSubview:dirLine];
        });
        
        CGRect dateFrame = CGRectMake(0, isFristIndex?64:30, 50, 12);
        UILabel* dateMon = [[UILabel alloc] initWithFrame:dateFrame];
        dateMon.font = [UIFont boldSystemFontOfSize:15];
        dateMon.textAlignment = NSTextAlignmentRight;
        dateMon.textColor = [UIColor whiteColor];
        dateMon.text = ms.monthAndDay;
        [cell.contentView addSubview:dateMon];
        
        UILabel* dateHour = [[UILabel alloc] initWithFrame:CGRectMake(0, dateMon.frame.origin.y + 12 + 4, 50, 8)];
        dateHour.font = [UIFont systemFontOfSize:8];
        dateHour.textAlignment = NSTextAlignmentRight;
        dateHour.textColor = [UIColor whiteColor];
        dateHour.text = ms.hour;
        [cell.contentView addSubview:dateHour];
        
        //读
        BOOL isRead = ms.isRead;
        
        UILabel* readLbl = [[UILabel alloc] initWithFrame:CGRectMake(1, dateHour.frame.origin.y + 13, 50, 8)];
        readLbl.font = [UIFont systemFontOfSize:12];
        readLbl.textAlignment = NSTextAlignmentRight;
        readLbl.textColor = [UIColor whiteColor];
        
        if(!isRead)
        {
            readLbl.text = @"未读";
            [cell.contentView addSubview:readLbl];
            
            UIImageView * iconView = [[UIImageView alloc] initWithFrame:CGRectMake(18, dateHour.frame.origin.y + 17 , 5, 5)];
            iconView.image = [UIImage imageNamed:@"icon_du"];
            [cell.contentView addSubview:iconView];
        }
        else
        {
            readLbl.text = @"已读";
            [cell.contentView addSubview:readLbl];
        }
        
        UILabel* corner = [[UILabel alloc] initWithFrame:CGRectMake(55, isFristIndex?68:34, 5, 5)];
        corner.layer.cornerRadius = 2;
        corner.backgroundColor = [UIColor whiteColor];
        corner.layer.borderColor = [UIColor whiteColor].CGColor;
        corner.layer.borderWidth = 1.0f;
        corner.layer.rasterizationScale = [UIScreen mainScreen].scale;
        corner.layer.masksToBounds = YES;
        corner.clipsToBounds = YES;
        [cell.contentView addSubview:corner];
        
        
        UILabel* bottomLine = [[UILabel alloc] initWithFrame:CGRectMake(0.156 * contentWidth + 15, contentHeight - 1, contentWidth - (0.156 * contentWidth + 15) - 12, 0.5)];
        [bottomLine setBackgroundColor:[UIColor whiteColor]];
        [cell.contentView addSubview:bottomLine];
        
        UIImageView* photo = [[UIImageView alloc] initWithFrame:CGRectMake(dirLine.frame.origin.x + 20, isFristIndex?52:15, 36, 36)];
        //[photo setImage:[UIImage imageNamed:@"icon_chengyuan"]];
        [photo setImageWithURL:[NSURL URLWithString:ms.userImg] placeholderImage:[UIImage imageNamed:@"icon_chengyuan"] options:SDWebImageDelayPlaceholder usingActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        
        [photo setBackgroundColor:[UIColor clearColor]];
        [cell.contentView addSubview:photo];
        
        
        CGRect nameFrame =CGRectMake(photo.frame.origin.x + photo.frame.size.width + 11, photo.frame.origin.y + 2,
                                     contentWidth - (photo.frame.origin.x + photo.frame.size.width + 6 + 39) , 16);
        UILabel* name = [[UILabel alloc] initWithFrame: nameFrame];
        name.text  = ms.userName;
        name.textColor = [UIColor whiteColor];
        name.font = [UIFont boldSystemFontOfSize:14];
        [cell.contentView addSubview:name];
        
        CGRect tagFrame = nameFrame;
        tagFrame.origin.y = YH(name) + 3;
        tagFrame.size.width = 184;
        
        UILabel* tag = [[UILabel alloc] initWithFrame: tagFrame];
        NSString * tagStr = @"";
        
        for (NSDictionary * dic in ms.labelList)
        {
            NSString * lblName = [dic valueForKey:@"labelName"];
            if(ms.labelList.count == 1)
            {
                tagStr = lblName;
            }
            else
            {
                tagStr = [tagStr stringByAppendingString:[NSString stringWithFormat:@"%@ · ", lblName]];
            }
        }
        
        if(tagStr.length >= 3)
        {
            NSString * pointTagStr = [tagStr substringFromIndex:tagStr.length - 3];
            if([pointTagStr isEqualToString:@" · "])
            {
                tagStr = [tagStr substringToIndex:tagStr.length - 3];
            }
        }
        
        tag.text  = [NSString stringWithFormat:@"%@   %@", ms.workGroupName, tagStr];
        tag.textColor = [UIColor grayColor];
        tag.font = [UIFont systemFontOfSize:10];
        [cell.contentView addSubview:tag];
        
        
        CGRect titleFrame = CGRectMake(photo.frame.origin.x, YH(photo) + 10,
                                       contentWidth - (X(photo) + 39),
                                       16);
        UILabel * titleLbl = [[UILabel alloc] init];
        titleLbl.frame = titleFrame;
        titleLbl.backgroundColor = [UIColor clearColor];
        titleLbl.textColor = [UIColor whiteColor];
        titleLbl.font = [UIFont boldSystemFontOfSize:14];
        if(ms.title.length)
        {
            titleLbl.text = ms.title;
        }
        else
        {
            titleLbl.text = @"无标题";
        }
        
        [cell.contentView addSubview:titleLbl];
        
        CGRect contentFrame = CGRectMake(X(photo), YH(titleLbl) + 6,
                                         contentWidth - (X(photo) + 39),
                                         contentH);
        UILabel* content = [[UILabel alloc] init];
        content.frame = contentFrame;
        [content setNumberOfLines:0];
        content.textColor = [UIColor grayColor];
        content.font = [UIFont boldSystemFontOfSize:14];
        content.text = ms.main;
        [content setBackgroundColor:[UIColor clearColor]];
        [cell.contentView addSubview:content];
        
        
        //        if (ms.isAccessory) {
        
        UIImageView* attachment = [[UIImageView alloc] initWithFrame:CGRectMake(X(content), YH(content) + 20 , 12, 10)];
        attachment.image = [UIImage imageNamed:@"btn_fujianIcon"];
        [cell.contentView addSubview:attachment];
        
        UILabel* fujianLbl = [[UILabel alloc] init];
        fujianLbl.textColor = [UIColor grayColor];
        fujianLbl.font = [UIFont boldSystemFontOfSize:10];
        [fujianLbl setBackgroundColor:[UIColor clearColor]];
        fujianLbl.text = [NSString stringWithFormat:@"附件 (%d)", ms.accessoryNum];
        
        fujianLbl.frame = CGRectMake(XW(attachment) + 5, Y(attachment) - 2, [UICommon getWidthFromLabel:fujianLbl].width, 14);
        [cell.contentView addSubview:fujianLbl];
        
        UIImageView* plIcon = [[UIImageView alloc] initWithFrame:CGRectMake(XW(fujianLbl) + 21, YH(content) + 20 , 12, 10)];
        plIcon.image = [UIImage imageNamed:@"btn_pinglun"];
        [cell.contentView addSubview:plIcon];
        
        UILabel* plLbl = [[UILabel alloc] init];
        plLbl.textColor = [UIColor grayColor];
        plLbl.font = [UIFont boldSystemFontOfSize:10];
        [plLbl setBackgroundColor:[UIColor clearColor]];
        plLbl.text = [NSString stringWithFormat:@"评论 (%d)", ms.replayNum];
        
        plLbl.frame = CGRectMake(XW(plIcon) + 5, Y(attachment) - 2, [UICommon getWidthFromLabel:plLbl].width, 14);
        [cell.contentView addSubview:plLbl];
        
        //[cell.contentView addSubview:pView];
        
        [cell.contentView setBackgroundColor:[UIColor clearColor]];
        
        CGRect rect = cell.frame;
        rect.size.height = contentHeight - 10;
        
    }
    
    
    
    // 0.156 0.321  365
    
    //[cell.imageView setImageWithURL:[NSURL URLWithString:@"http://img0.bdstatic.com/img/image/shouye/mingxing0605.jpg"] placeholderImage:[UIImage imageNamed:@"menuUsers"] options:SDWebImageContinueInBackground usingActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    
    //cell.textLabel.text = @"aaáâ";
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    Mission* ms = [_contentArray objectAtIndex:indexPath.row];
    
    UIStoryboard* mainStory = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    UIViewController* vc = [mainStory instantiateViewControllerWithIdentifier:@"ICWorkingDetailViewController"];
    ((ICWorkingDetailViewController*)vc).taskId = ms.taskId;
    ((ICWorkingDetailViewController*)vc).indexInMainArray = indexPath.row;
    ((ICWorkingDetailViewController*)vc).icMainViewController = self;
    
    [self.navigationController pushViewController:vc animated:YES];
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = (UITableViewCell *)[tableView cellForRowAtIndexPath:indexPath];
    
    UIView *selectionColor = [[UIView alloc] init];
    selectionColor.backgroundColor = [UIColor cellHoverBackgroundColor];
    cell.selectedBackgroundView = selectionColor;
    
    UIView* dirLine = [[UIView alloc] init];
    NSInteger ind = indexPath.row;
    
    CGFloat contentHeight = [self tableView:tableView heightForRowAtIndexPath:indexPath];
    
    if (ind == 0) {
        dirLine.frame = CGRectMake(50 + 7.5, 19 + 15, 0.5, contentHeight - 19 - 15 + 1);
    }
    else
    {
        dirLine.frame = CGRectMake(57.5, 0, 0.5, contentHeight + 1);
    }
    [dirLine setBackgroundColor:[UIColor whiteColor]];
    [cell.selectedBackgroundView addSubview:dirLine];
    
    
    UILabel* bottomLine = [[UILabel alloc] initWithFrame:CGRectMake(0.156 * _screenWidth + 15, contentHeight - 1, _screenWidth - (0.156 * _screenWidth + 15) - 12, 0.5)];
    [bottomLine setBackgroundColor:[UIColor whiteColor]];
    [cell.selectedBackgroundView addSubview:bottomLine];
    
    return YES;
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    /*
     NSString* data = @"12112";
     UIViewController* vc = segue.destinationViewController;
     if ([vc respondsToSelector:@selector(setParam:)]) {
     [vc setValue:data forKey:@"param"];
     }
     
     if ([vc respondsToSelector:@selector(setIsshared:)]) {
     if (_isTopMenuSharedButtonClicked) {
     [vc setValue:@"0" forKey:@"isshared"];
     }
     else
     {
     [vc setValue:@"1" forKey:@"isShared"];
     }
     }
     
     if ([vc respondsToSelector:@selector(setIcMainViewController:)]) {
     [vc setValue:self forKey:@"icMainViewController"];
     }
     */
}

@end
