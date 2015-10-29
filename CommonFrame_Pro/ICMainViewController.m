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
#import "UIImageView+UIActivityIndicatorForSDWebImage.h"
#import "PPDragDropBadgeView.h"
#import "UICommon.h"
#import <Reachability.h>
//#import <AVOSCloud/AVOSCloud.h>
#import "APService.h"
#import "ICMemberInfoViewController.h"
#import "RRAttributedString.h"
#import "MQPublishMissionController.h"
#import "MegListController.h"
#import "MQPublishMissionMainController.h"

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
    NSInteger               _midVal;
    NSInteger               _maxVal;
    
    UIView*                 _markHeadView;
    //    UIView*                 groupHeadView;
    
    Reachability  *hostReach;
    
    Group                   *_currentGroup;
    
    BOOL                    _isMarkShow;
    NSString *              _markNameStr;
    NSInteger               _tagNum;
    
    NSString * _allNum;
    
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
    _midVal = 0;
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

//    _smView.transform = CGAffineTransformTranslate(CGAffineTransformIdentity, 0, _screenHeight - 64 - 120);

    
    NSArray* markArray = [NSArray array];
    NSMutableArray * muArr = [[NSMutableArray alloc] init];
    Group * gr = [[Group alloc] init];
    gr.workGroupId = @"0";
    gr.workGroupName = @"全部";
    gr.messageCount = @"0";
    
    [muArr addObject:gr];
    
    NSString * allnum = @"";
    
    [muArr addObjectsFromArray:[Group getGroupsByUserID:self.loginUserID marks:&markArray workGroupId:_workGroupId searchString:(isBarOne ? searchString : nil) allNum:&allnum]];
    
    _allNum = allnum;
    
    Group * gc = [[Group alloc] init];
    gc.workGroupId = @"-1";
    gc.workGroupName = @"创建群组";
    gc.messageCount = @"0";
    [muArr addObject:gc];
    
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
    [btn2 setTitle:@"发布" forState:UIControlStateNormal];
//    [btn2 setImage:[UIImage imageNamed:@"btn_fabu"] forState:UIControlStateNormal];
    
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
    UIButton *button  = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 50, 30)];//30
    [button setBackgroundColor:[UIColor clearColor]];
    button.titleLabel.textColor = [UIColor whiteColor];
    [button setTitle:@"查找" forState:UIControlStateNormal];

    
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
                cm.isNewCom = [[di valueForKey:@"isNewCom"] boolValue];
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
        
        [self resetRightMarkView];

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
    }
    
    [_tableView.header beginRefreshing];
    
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
    
}

- (void)resetRightMarkView
{
    NSMutableArray * markArray = [NSMutableArray arrayWithArray:[self loadBottomMenuView:nil isSearchBarOne:YES]];
    _icSideRightMarkArray = markArray;
    _sideBar.nameList = markArray;
    
    [_sideBar.mainTableView refreshData];
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
        
//        UIStoryboard* mainStory = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
//        
//        UIViewController* vc = [mainStory instantiateViewControllerWithIdentifier:@"MQPublishMissionMainController"];
//        if (_currentGroup) {
//            ((MQPublishMissionMainController*)vc).workGroupId = _currentGroup.workGroupId;
//            ((MQPublishMissionMainController*)vc).workGroupName = _currentGroup.workGroupName;
//        }
//        
//        [self.navigationController pushViewController:vc animated:YES];

        UIStoryboard* mainStory = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        UIViewController* vc = [mainStory instantiateViewControllerWithIdentifier:@"ICGroupListViewController"];
        ((ICGroupListViewController*)vc).currentViewGroupType = GroupTypeMission;
        ((ICGroupListViewController*)vc).icMainViewController = self;
        [self.navigationController pushViewController:vc animated:YES];

    }
    else if (index == 1) {//问题
        _isTopMenuSharedButtonClicked = YES;
        
        UIStoryboard* mainStory = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        UIViewController* vc = [mainStory instantiateViewControllerWithIdentifier:@"ICGroupListViewController"];
        ((ICGroupListViewController*)vc).currentViewGroupType = GroupTypeSharedAndNotify;
//        ((ICGroupListViewController*)vc).icMainViewController = self;
        ((ICGroupListViewController*)vc).isShared = 1;
        [self.navigationController pushViewController:vc animated:YES];
        
    }
    else if (index == 2) {//建议
        _isTopMenuSharedButtonClicked = NO;
        UIStoryboard* mainStory = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        UIViewController* vc = [mainStory instantiateViewControllerWithIdentifier:@"ICGroupListViewController"];
        ((ICGroupListViewController*)vc).currentViewGroupType = GroupTypeSharedAndNotify;
//        ((ICGroupListViewController*)vc).icMainViewController = self;
        ((ICGroupListViewController*)vc).isShared = 2;
        [self.navigationController pushViewController:vc animated:YES];
        
    }
    else if (index == 3) {//其它
        _isTopMenuSharedButtonClicked = NO;
        UIStoryboard* mainStory = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        UIViewController* vc = [mainStory instantiateViewControllerWithIdentifier:@"ICGroupListViewController"];
        ((ICGroupListViewController*)vc).currentViewGroupType = GroupTypeSharedAndNotify;
//        ((ICGroupListViewController*)vc).icMainViewController = self;
        ((ICGroupListViewController*)vc).isShared = 3;
        [self.navigationController pushViewController:vc animated:YES];
        
    }
}

- (void) resetHeaderView
{
//    _tableView.tableHeaderView = nil;
//    _isMarkShow = NO;
//    _markHeadView = nil;
//    _TermString = @"";
//    [_tableView.header beginRefreshing];
    
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
            [self groupHeaderView2];
        });
    }
    else if(_currentGroup && _isMarkShow)
    {
        _tableView.tableHeaderView = ({
            [self markHeaderView];
        });
    }
    else
    {
        if([_allNum integerValue] > 0)
        {
            _tableView.tableHeaderView = ({
                [self messageHeadView];
            });
        }
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
        
        _minVal = [m.labelId integerValue];
    }
    else if (indexPath.row == 1)
    {
        tag = 3;
        
        _midVal = [m.labelId integerValue];
    }
    else if (indexPath.row == 2)
    {
        tag = 2;
        _maxVal = [m.labelId integerValue];
    }
    
    if (_minVal != 0 && _maxVal == 0 && _midVal == 0) {
        _TermString = [NSString stringWithFormat:@"%ld",(NSInteger)_minVal];
    }
    else if (_minVal == 0 && _maxVal != 0 && _midVal == 0) {
        _TermString = [NSString stringWithFormat:@"%ld",(NSInteger)_maxVal];
    }
    else if (_minVal == 0 && _maxVal == 0 && _midVal != 0) {
        _TermString = [NSString stringWithFormat:@"%ld",(NSInteger)_midVal];
    }
    else if (_minVal != 0 && _maxVal != 0 && _midVal == 0) {
        _TermString = [NSString stringWithFormat:@"%ld,%ld",(NSInteger)_minVal,(NSInteger)_maxVal];
    }
    else if (_minVal != 0 && _maxVal == 0 && _midVal != 0) {
        _TermString = [NSString stringWithFormat:@"%ld,%ld",(NSInteger)_minVal,(NSInteger)_midVal];
    }
    else if (_minVal == 0 && _maxVal != 0 && _midVal != 0) {
        _TermString = [NSString stringWithFormat:@"%ld,%ld",(NSInteger)_midVal,(NSInteger)_maxVal];
    }
    else if (_minVal != 0 && _maxVal != 0 && _midVal != 0) {
        _TermString = [NSString stringWithFormat:@"%ld,%ld,%ld",(NSInteger)_minVal, (NSInteger)_midVal,(NSInteger)_maxVal];
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

    return groupHeadView;
    
}

- (void) jumpToMesView
{
    UIStoryboard* mainStory = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    UIViewController* vc = [mainStory instantiateViewControllerWithIdentifier:@"MegListController"];
    
    [self.navigationController pushViewController:vc animated:YES];
}

- (UIView *)groupHeaderView2
{
    CGFloat width = SCREENWIDTH;

    UIView * groupHeadView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREENWIDTH, 95)];
    
    [groupHeadView setBackgroundColor:[UIColor greyStatusBarColor]];
    
    UIImageView* imgView = [[UIImageView alloc] initWithFrame:CGRectMake(11, 11, 67, 67)];
    //[imgView setImage:[UIImage imageNamed:@"icon_touxiang"]];
    [imgView setImageWithURL:[NSURL URLWithString:_currentGroup.workGroupImg] placeholderImage:[UIImage imageNamed:@"icon_touxiang"] options:SDWebImageDelayPlaceholder usingActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    
    [groupHeadView addSubview:imgView];
    

    
    UIImageView * jiantou = [[UIImageView alloc] init];
    jiantou.frame = CGRectMake(SCREENWIDTH - 12 - 11, 42, 12, 12);
    jiantou.image = [UIImage imageNamed:@"icon_jiantou"];
    
    [groupHeadView addSubview:jiantou];
    
    UIFont* font = Font(14);
    
    UILabel* lbl = [[UILabel alloc] initWithFrame:CGRectMake(imgView.frame.size.width + imgView.frame.origin.x + 18, 13, 50 , 13)];
    lbl.text = @"名称";
    lbl.textColor = [UIColor grayColor];
    lbl.font = font;
    lbl.backgroundColor = [UIColor clearColor];
    
    [groupHeadView addSubview:lbl];
    
    UILabel* lbl1 = [[UILabel alloc] initWithFrame:CGRectMake(lbl.frame.origin.x, lbl.frame.origin.y + lbl.frame.size.height + 12, 50 , 13)];
    lbl1.text = @"创建人";
    lbl1.textColor = [UIColor grayColor];
    lbl1.font = font;
    lbl1.backgroundColor = [UIColor clearColor];
    
    [groupHeadView addSubview:lbl1];
    
    UILabel* lbl2 = [[UILabel alloc] initWithFrame:CGRectMake(lbl.frame.origin.x, lbl1.frame.origin.y + lbl1.frame.size.height + 12, 50 , 13)];
    lbl2.text = @"签名";
    lbl2.textColor = [UIColor grayColor];
    lbl2.font = font;
    lbl2.backgroundColor = [UIColor clearColor];
    
    [groupHeadView addSubview:lbl2];
    
    
    UILabel* text = [[UILabel alloc] initWithFrame:CGRectMake(lbl.frame.origin.x + lbl.frame.size.width + 20, 13, width/2 - 10 , 13)];
    text.text = _currentGroup.workGroupName;
    text.textColor = [UIColor whiteColor];
    text.font = font;
    text.backgroundColor = [UIColor clearColor];
    
    [groupHeadView addSubview:text];
    
    UILabel* text1 = [[UILabel alloc] initWithFrame:CGRectMake(lbl.frame.origin.x + lbl.frame.size.width + 20, 38, width/2 - 10, 13)];
    text1.text = _currentGroup.userName;
    text1.textColor = [UIColor whiteColor];
    text1.font = font;
    text1.backgroundColor = [UIColor clearColor];
    
    [groupHeadView addSubview:text1];
    
    UILabel* text2 = [[UILabel alloc] initWithFrame:CGRectMake(lbl.frame.origin.x + lbl.frame.size.width + 20, 63, width/2 - 10, 13)];
    text2.text = _currentGroup.workGroupMain;
    text2.textColor = [UIColor whiteColor];
    text2.font = font;
    text2.backgroundColor = [UIColor clearColor];
    
    [groupHeadView addSubview:text2];
    
    UILabel* bottomLine = [[UILabel alloc] init];
    
    [bottomLine setFrame:CGRectMake(0, 94, [UIScreen mainScreen].bounds.size.width, 0.5)];
    [bottomLine setBackgroundColor:[UIColor grayColor]];

    [groupHeadView addSubview:bottomLine];
    
    UIButton* btnPhoto = [[UIButton alloc] initWithFrame:groupHeadView.frame];
    [btnPhoto setBackgroundColor:[UIColor clearColor]];
    [btnPhoto addTarget:self action:@selector(btnPhotoClicked:) forControlEvents:UIControlEventTouchUpInside];
    
    [groupHeadView addSubview:btnPhoto];
    
    
    UIView * groupAndMegView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREENWIDTH, 95 + 30)];
    
    [groupAndMegView setBackgroundColor:[UIColor greyStatusBarColor]];
    
    UIView * megView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREENWIDTH, 30)];
    [megView setBackgroundColor:RGBCOLOR(90, 112, 223)];
    UIButton * msgBtn = [[UIButton alloc] init];
    msgBtn.frame = megView.frame;
    msgBtn.backgroundColor = [UIColor clearColor];
    msgBtn.titleLabel.textColor = [UIColor whiteColor];
    msgBtn.titleLabel.font = Font(15);
    NSString * str = [NSString stringWithFormat:@"您有 %@ 条新消息", _allNum];
    [msgBtn setTitle:str forState:UIControlStateNormal];
    [msgBtn addTarget:self action:@selector(jumpToMesView) forControlEvents:UIControlEventTouchUpInside];
    [megView addSubview:msgBtn];
    
    if([_allNum integerValue] > 0)
    {
        groupHeadView.top = 30;
        
        [groupAndMegView addSubview:groupHeadView];
        
        [groupAndMegView addSubview:megView];
        
        return groupAndMegView;
    }
    else
    {
        return groupHeadView;
    }
}

- (UIView *) messageHeadView
{
    UIView * megView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREENWIDTH, 30)];
    [megView setBackgroundColor:RGBCOLOR(90, 112, 223)];
    UIButton * msgBtn = [[UIButton alloc] init];
    msgBtn.frame = megView.frame;
    msgBtn.backgroundColor = [UIColor clearColor];
    msgBtn.titleLabel.textColor = [UIColor whiteColor];
    msgBtn.titleLabel.font = Font(15);
    NSString * str = [NSString stringWithFormat:@"您有 %@ 条新消息", _allNum];
    [msgBtn setTitle:str forState:UIControlStateNormal];
    [msgBtn addTarget:self action:@selector(jumpToMesView) forControlEvents:UIControlEventTouchUpInside];
    [megView addSubview:msgBtn];
    
    return megView;
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
            int count = 0;
            for (UIControl* control in _markHeadView.subviews) {
                if ([control isKindOfClass:[UILabel class]]) {
                    UILabel* lbl = (UILabel*)control;
                    count ++;
                    if (lbl.tag == _tagNum) {
                        hasEx = YES;
                        lbl.text = _markNameStr;
                        break;
                    }
                }
            }
            if (!hasEx) {
                
                CGFloat x = 102;
                
                if(count == 3)
                {
                    x = 102 + 90;
                }
                
                UILabel* name = [[UILabel alloc] initWithFrame:CGRectMake(x, 8, 80, 24)];
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
    
    UIView * markAndMegView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREENWIDTH, 40 + 30)];
    
    [markAndMegView setBackgroundColor:[UIColor greyStatusBarColor]];
    
    UIView * megView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREENWIDTH, 30)];
    [megView setBackgroundColor:RGBCOLOR(90, 112, 223)];
    UIButton * msgBtn = [[UIButton alloc] init];
    msgBtn.frame = megView.frame;
    msgBtn.backgroundColor = [UIColor clearColor];
    msgBtn.titleLabel.textColor = [UIColor whiteColor];
    msgBtn.titleLabel.font = Font(15);
    NSString * str = [NSString stringWithFormat:@"您有 %@ 条新消息", _allNum];
    [msgBtn setTitle:str forState:UIControlStateNormal];
    [msgBtn addTarget:self action:@selector(jumpToMesView) forControlEvents:UIControlEventTouchUpInside];
    [megView addSubview:msgBtn];
    
    if([_allNum integerValue] > 0)
    {
        _markHeadView.top = 30;
        
        [markAndMegView addSubview:_markHeadView];
        
        [markAndMegView addSubview:megView];
        
        return markAndMegView;
    }
    else
    {
        return _markHeadView;
    }
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
    UIButton * btn = (UIButton *)sender;
    
    if(btn.tag == _bottomArray.count - 1)
    {
        [self btnCreateNewGroup:nil];
        
        return;
    }
    
    _pubGroupId = nil;

    _tableView.tableHeaderView = nil;
    _isMarkShow = NO;
    _markHeadView = nil;
    _TermString = @"";
    [_tableView.header beginRefreshing];
    
    [_tableView.footer resetNoMoreData];
    
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

- (void) jumpToPersonalInfo:(id)sender
{
    UIView *v = [sender superview];//获取父类view
    UITableViewCell *cell = (UITableViewCell *)[v superview];//获取cell
    NSIndexPath *indexPath = [_tableView indexPathForCell:cell];//获取cell对应的section
    
    Mission * mi = _contentArray[indexPath.row];
    
    Member * me = [Member new];
    
    me.workGroupId = @"0";
    
    NSMutableArray * dataArr = [NSMutableArray array];
    
    BOOL isOk = [Mission findWgPeopleTrends:mi.createUserId workGroupId:@"0" currentPageIndex:1 pageSize:5 dataListArr:&dataArr member:&me];
    
    if(isOk)
    {
        UIStoryboard* mainStory = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        UIViewController* vc;
        vc = [mainStory instantiateViewControllerWithIdentifier:@"ICMemberInfoViewController"];
        ((ICMemberInfoViewController*)vc).memberObj = me;
        ((ICMemberInfoViewController*)vc).dataListArr = dataArr;

        [self.navigationController pushViewController:vc animated:YES];

    }
    
//    m.workGroupId = @"0";//查找工作组成员动态
//    
//    if (m != nil) {
//        UIStoryboard* mainStory = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
//        UIViewController* vc;
//        vc = [mainStory instantiateViewControllerWithIdentifier:@"ICMemberInfoViewController"];
//        ((ICMemberInfoViewController*)vc).memberObj = m;
//        [self.navigationController pushViewController:vc animated:YES];
//    }
    
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
    
//    Mission* ms = [_contentArray objectAtIndex:indexPath.row];
//    
//    CGFloat contentH = [UICommon getSizeFromString:ms.main withSize:CGSizeMake(_screenWidth - (77.5 + 39), 80) withFont:18].height;
    
//    CGFloat cellHeight = contentH + 70 + 42 + 28;
    CGFloat cellHeight = 244;
    
    if (indexPath.row == 0) {
        cellHeight += 33;
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
//        
//        CGFloat contentH = [UICommon getSizeFromString:ms.main withSize:CGSizeMake(_screenWidth - (77.5 + 39), 80) withFont:Font(18)].height;
//
//        CGFloat cellHeight = contentH + 70 + 42 + 28;
        CGFloat cellHeight = 244;
        
        if (indexPath.row == 0) {
            cellHeight = cellHeight + 33;
        }
        
        CGFloat contentHeight = cellHeight;
        CGFloat contentWidth = _screenWidth;
        
        UIView* dirLine = [[UIView alloc] init];
        
        BOOL isFristIndex = NO;
        
        if (index == 0) {
            isFristIndex = YES;
            UIImageView* timeIcon = [[UIImageView alloc] initWithFrame:CGRectMake(62, 14, 18, 18)];
            [timeIcon setImage:[UIImage imageNamed:@"icon_shijian"]];
            [timeIcon setBackgroundColor:[UIColor clearColor]];
            [cell.contentView addSubview:timeIcon];
            //[menuButton setImageWithURL:[NSURL URLWithString:[_imageList objectAtIndex:index]]  forState:UIControlStateNormal placeholderImage:[UIImage imageNamed:@"icon_touxiang"] usingActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
            
            dirLine.frame = CGRectMake(timeIcon.frame.origin.x + 9, timeIcon.frame.origin.y + 18, 1, contentHeight - timeIcon.frame.origin.y - timeIcon.frame.size.height);
        }
        else
        {
            dirLine.frame = CGRectMake(71, 0, 1, contentHeight);
        }
        
        [dirLine setBackgroundColor:RGBCOLOR(119, 119, 119)];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [cell.contentView addSubview:dirLine];
        });
        
        CGRect dateFrame = CGRectMake(0, isFristIndex?45:10, 56, 24);
        UILabel* dateMon = [[UILabel alloc] initWithFrame:dateFrame];
        dateMon.font = BFont(10);
        dateMon.textAlignment = NSTextAlignmentRight;
        dateMon.textColor = [UIColor whiteColor];
        
        if(ms.monthAndDay.length > 2)
        {
            NSRange range = [ms.monthAndDay rangeOfString:@"/"]; //现获取要截取的字符串位置
            NSInteger month = [[ms.monthAndDay substringToIndex:range.location] integerValue];
            NSString * day = [ms.monthAndDay substringFromIndex:range.location + 1];
            NSString * dateStr = [NSString stringWithFormat:@"%@ %ld月", day, month];
            
            NSAttributedString *attrStr = [RRAttributedString setText:dateStr font:BFont(23) range:NSMakeRange(0, 2)];
            
            dateMon.attributedText = attrStr;
        }
        
        [cell.contentView addSubview:dateMon];
        
        UILabel* dateHour = [[UILabel alloc] initWithFrame:CGRectMake(0, YH(dateMon)+ 7, 56, 14)];
        dateHour.font = Font(12);
        dateHour.textAlignment = NSTextAlignmentRight;
        dateHour.textColor = [UIColor whiteColor];
        dateHour.text = ms.hour;
        [cell.contentView addSubview:dateHour];
        
        //读
        BOOL isRead = ms.isRead;
        
        UILabel* readLbl = [[UILabel alloc] initWithFrame:CGRectMake(1, YH(dateHour) + 7, 56, 18)];
        readLbl.font = Font(16);
        readLbl.textAlignment = NSTextAlignmentRight;
        
        if(!isRead)
        {
            readLbl.text = @"未读";
            readLbl.textColor = RGBCOLOR(53, 159, 219);
            [cell.contentView addSubview:readLbl];
            
            
            UIImageView * iconView = [[UIImageView alloc] initWithFrame:CGRectMake(14, YH(dateHour) + 13 , 5, 5)];
            iconView.image = [UIImage imageNamed:@"icon_du"];
            [cell.contentView addSubview:iconView];
        }
        else
        {
            readLbl.text = @"已读";
            readLbl.textColor = RGBCOLOR(122, 122, 122);
            [cell.contentView addSubview:readLbl];
        }
        
        //新评论
        
        BOOL isNewCom = ms.isNewCom;
//        BOOL isNewCom = YES;
        
        UILabel* comLbl = [[UILabel alloc] initWithFrame:CGRectMake(1, YH(readLbl) + 7, 56, 18)];
        comLbl.font = Font(16);
        comLbl.textAlignment = NSTextAlignmentRight;
        
        if(isNewCom)
        {
            comLbl.text = @"新评论";
            comLbl.font = Font(10);
            comLbl.textColor = RGBCOLOR(76, 216, 100);
            [cell.contentView addSubview:comLbl];
            
            UILabel* corner = [[UILabel alloc] initWithFrame:CGRectMake(14,YH(readLbl) + 13, 5, 5)];
            corner.layer.cornerRadius = 2;
            corner.backgroundColor = RGBCOLOR(76, 216, 100);
            corner.layer.borderColor = RGBCOLOR(76, 216, 100).CGColor;
            corner.layer.borderWidth = 1.0f;
            corner.layer.rasterizationScale = [UIScreen mainScreen].scale;
            corner.layer.masksToBounds = YES;
            corner.clipsToBounds = YES;
            [cell.contentView addSubview:corner];
        }

        //灰点
        UILabel* corner = [[UILabel alloc] initWithFrame:CGRectMake(69, isFristIndex?72:40, 5, 5)];
        corner.layer.cornerRadius = 2;
        corner.backgroundColor = RGBCOLOR(119, 119, 119);
        corner.layer.borderColor = RGBCOLOR(119, 119, 119).CGColor;
        corner.layer.borderWidth = 1.0f;
        corner.layer.rasterizationScale = [UIScreen mainScreen].scale;
        corner.layer.masksToBounds = YES;
        corner.clipsToBounds = YES;
        [cell.contentView addSubview:corner];
        
        CGFloat bianKuangWidth = SCREENWIDTH - 14 - 82;
        
        UIImageView * backImgView = [[UIImageView alloc] initWithFrame:CGRectMake(XW(corner) + 8, isFristIndex?34:0, bianKuangWidth, 217)];
        backImgView.image = [UIImage imageNamed:@"bg_duihuakuang"];
        [cell.contentView addSubview:backImgView];
        
        UIImageView* photo = [[UIImageView alloc] initWithFrame:CGRectMake(X(dirLine) + 20 + 14, isFristIndex?47:14, 50, 50)];
        //[photo setImage:[UIImage imageNamed:@"icon_chengyuan"]];
        [photo setImageWithURL:[NSURL URLWithString:ms.userImg] placeholderImage:[UIImage imageNamed:@"icon_chengyuan"] options:SDWebImageDelayPlaceholder usingActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        
        [photo setBackgroundColor:[UIColor clearColor]];
        photo.layer.cornerRadius = 5.0f;
        photo.clipsToBounds = YES;
        
        [cell.contentView addSubview:photo];
        
        UIButton * photoBtn = [[UIButton alloc] initWithFrame:photo.frame];
        [photoBtn addTarget:self action:@selector(jumpToPersonalInfo:) forControlEvents:UIControlEventTouchUpInside];
        photoBtn.backgroundColor = [UIColor clearColor];
        [cell.contentView addSubview:photoBtn];
        
        CGRect nameFrame =CGRectMake(XW(photo)+ 14, Y(photo), SCREENWIDTH - 196, 50);
        UILabel* name = [[UILabel alloc] initWithFrame: nameFrame];
        name.textColor = RGBCOLOR(172, 172, 173);
        name.font = Font(10);
        
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
        
        NSString * nameStr = [NSString stringWithFormat:@"%@   %@   %@",ms.userName, ms.workGroupName, tagStr];
        
        NSAttributedString *nameAttrStr = [RRAttributedString setText:nameStr font:Font(16) color:RGBCOLOR(53, 159, 219) range:NSMakeRange(0, ms.userName.length)];
        
        name.attributedText = nameAttrStr;

        [cell.contentView addSubview:name];
        
        CGFloat width = [UICommon getSizeFromString:ms.userName withSize:CGSizeMake(100, name.frame.size.height) withFont:Font(16)].width;
        
        CGRect btnRect = name.frame;
        btnRect.origin.y = 0;
        btnRect.size.width = width;
        btnRect.size.height = YH(name);
        
        photoBtn = [[UIButton alloc] initWithFrame:btnRect];
        [photoBtn addTarget:self action:@selector(jumpToPersonalInfo:) forControlEvents:UIControlEventTouchUpInside];
        photoBtn.backgroundColor = [UIColor clearColor];
        [cell.contentView addSubview:photoBtn];
        
        
        //跳转到群组详细页
//        photoBtn = [[UIButton alloc] initWithFrame:tag.frame];
//        [photoBtn addTarget:self action:@selector(jumpToPersonalInfo:) forControlEvents:UIControlEventTouchUpInside];
//        photoBtn.backgroundColor = [UIColor clearColor];
//        [cell.contentView addSubview:photoBtn];
        NSString * type = @"";
       
        switch (ms.type) {
            case 1:
                type = @"任务";
                break;
            case 2:
                type = @"问题";
                break;
            case 3:
                type = @"其他";
                break;
            case 8:
                type = @"建议";
                break;
            default:
                break;
        }
        
        CGRect titleFrame = CGRectMake(X(photo), YH(photo) + 14,
                                       SCREENWIDTH - 14 -107,
                                       18);
        UILabel * titleLbl = [[UILabel alloc] init];
        titleLbl.frame = titleFrame;
        titleLbl.backgroundColor = [UIColor clearColor];
        titleLbl.textColor = RGBCOLOR(251, 251, 251);
        titleLbl.font = Font(16);
        NSString * title = @"";
        if(ms.title.length)
        {
            title = ms.title;
        }
        else
        {
            title = @"无标题";
        }
        
        titleLbl.text = [NSString stringWithFormat:@"%@   %@",type, title];
        
        [cell.contentView addSubview:titleLbl];
        
        CGSize maxSize = CGSizeMake(contentWidth - (X(photo) + 39),
                                    20 * 4 + 8);
        CGRect contentFrame = CGRectMake(X(photo), YH(titleLbl) + 14,
                                         maxSize.width,
                                         maxSize.height);
        
        UILabel* content = [[UILabel alloc] init];
        content.textColor = [UIColor grayColor];
        content.font = Font(14);
        
        CGSize cSize = [UICommon getSizeFromString:ms.main withSize:maxSize withFont:Font(14)];
        content.frame = CGRectMake(contentFrame.origin.x, contentFrame.origin.y, contentFrame.size.width, cSize.height);
        content.numberOfLines = 4;
        content.text = ms.main;
        
        [content setBackgroundColor:[UIColor clearColor]];
        [cell.contentView addSubview:content];
        
        
        //        if (ms.isAccessory) {
        
        UILabel* plLbl = [[UILabel alloc] init];
        plLbl.textColor = RGBCOLOR(172, 172, 173);
        plLbl.font = Font(10);
        [plLbl setBackgroundColor:[UIColor clearColor]];
        plLbl.text = [NSString stringWithFormat:@"评论 (%d)", ms.replayNum];
        
        CGFloat plWidth = [UICommon getWidthFromLabel:plLbl].width;
        plLbl.frame = CGRectMake(SCREENWIDTH - 25 - plWidth, isFristIndex?192 + 34:192,plWidth, 12);
        
        [cell.contentView addSubview:plLbl];
        
        UIImageView* plIcon = [[UIImageView alloc] initWithFrame:CGRectMake(X(plLbl) - 4 - 12, Y(plLbl) - 2 , 12, 10)];
        plIcon.image = [UIImage imageNamed:@"btn_pinglun"];
        [cell.contentView addSubview:plIcon];
        
        
        UILabel* fujianLbl = [[UILabel alloc] init];
        fujianLbl.textColor = RGBCOLOR(172, 172, 173);
        fujianLbl.font = Font(10);
        [fujianLbl setBackgroundColor:[UIColor clearColor]];
        fujianLbl.text = [NSString stringWithFormat:@"附件 (%d)", ms.accessoryNum];
        
        CGFloat fujianWidth = [UICommon getWidthFromLabel:fujianLbl].width;
        fujianLbl.frame = CGRectMake(X(plIcon) - 26 - fujianWidth, Y(plLbl), fujianWidth, 12);
        [cell.contentView addSubview:fujianLbl];
        
        UIImageView* attachment = [[UIImageView alloc] initWithFrame:CGRectMake(X(fujianLbl) - 4 - 12, Y(plLbl) - 2, 12, 10)];
        attachment.image = [UIImage imageNamed:@"btn_fujianIcon"];
        [cell.contentView addSubview:attachment];
        
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
    ((ICWorkingDetailViewController*)vc).workGroupId = _workGroupId;
    
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
        dirLine.frame = CGRectMake(71, 19 + 15, 1, contentHeight - 19 - 15 + 1);
    }
    else
    {
        dirLine.frame = CGRectMake(71, 0, 1, contentHeight + 1);
    }
    [dirLine setBackgroundColor:RGBCOLOR(119, 119, 119)];
    [cell.selectedBackgroundView addSubview:dirLine];
    
//    
//    UILabel* bottomLine = [[UILabel alloc] initWithFrame:CGRectMake(0.156 * _screenWidth + 15, contentHeight - 1, _screenWidth - (0.156 * _screenWidth + 15) - 12, 0.5)];
//    [bottomLine setBackgroundColor:[UIColor whiteColor]];
//    [cell.selectedBackgroundView addSubview:bottomLine];
    
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
