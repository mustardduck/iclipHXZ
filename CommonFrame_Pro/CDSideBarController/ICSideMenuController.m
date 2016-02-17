                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                 //
//  ICSideMenuController.m
//  CDSideBar
//
//  Created by ionitech on 15/6/4.
//  Copyright (c) 2015年 Christophe Dellac. All rights reserved.
//

#import "ICSideMenuController.h"
#import "PPDragDropBadgeView.h"
#import "InputText.h"
#import <AIMTableViewIndexBar.h>
#import "UIColor+HexString.h"
#import "UIButton+UIActivityIndicatorForSDWebImage.h"

@interface ICSideMenuController()<UITableViewDataSource,UITableViewDelegate, AIMTableViewIndexBarDelegate,InputTextDelegate,UITextFieldDelegate,UIGestureRecognizerDelegate>
{
  
    UIView*     _mainView;
    NSInteger   _dataCount;
    CGFloat     _pViewHeight;
    CGFloat     _pViewWidth;
    
    NSArray*    _imageList;
    NSArray*    _nameList;
    NSArray*    _badgeList;
    NSArray *   _allNumBadgeList;
    
    //Search bar
    UILabel*        _lblSearch;
    UITextField*    _txtSearch;
    
    //Search bar
    UILabel*        _lblSearch1;
    UITextField*    _txtSearch1;
    
    
    AIMTableViewIndexBar*  _indexBar;
    UITableView*           _tableView;
    
    NSArray* _sections;
    NSArray* _rows;
    
    UIView*     _messageView;
    UIView*     _groupView;
    UINavigationBar* topBar;
    
    //Check search bar
    NSString*       _searchText;
    BOOL            _isFirstSearchBar;
    
    BOOL   _isUp;
}

@property (nonatomic,assign) BOOL chang;

@end

@implementation ICSideMenuController

- (ICSideMenuController*)initWithImages:(NSArray*)imageList menusName:(NSArray*)nameList badgeValue:(NSArray*)badgeList onView:(UIView*)parentView searchText:(NSString*)searchString isFirstSearchBar:(BOOL)isFirstBar allNumBadge:(NSArray *)allNumBadgeList isOpen:(BOOL)isOpen
{
    CGFloat vWidth = parentView.frame.size.width;
    
    _dataCount = nameList.count;
    _pViewHeight = parentView.frame.size.height;
    _pViewWidth = vWidth;
    
    _imageList = [[NSArray alloc] initWithArray:imageList];
    _nameList = [[NSArray alloc] initWithArray:nameList];
    _badgeList = [[NSArray alloc] initWithArray:badgeList];
    _allNumBadgeList = [[NSArray alloc] initWithArray:allNumBadgeList];

    
    _mainView = [[UIView alloc] initWithFrame:CGRectMake(0, 64, _pViewWidth, _pViewHeight -64)];
    //[_mainView setBackgroundColor:[UIColor colorWithRed:1 green:1 blue:1 alpha:1]];
    [_mainView setBackgroundColor:[UIColor greenColor]];

    CGFloat vHeight = 120;
    CGFloat dH = _pViewHeight - 64 - vHeight;
//    CGRect rect = parentView.frame;
//    rect.origin.y = dH;
//    parentView.frame = rect;
    
    _mainView = parentView;
    
//    CGRect rect = parentView.frame;
//    rect.origin.y = dH;
//    _mainView.frame = rect;
//    [parentView addSubview:_mainView];
//    [parentView sendSubviewToBack:_mainView];
    

    //创建手势
    UIPanGestureRecognizer *panGR =
    [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(objectDidDragged:)];
    //限定操作的触点数
    [panGR setMaximumNumberOfTouches:1];
    [panGR setMinimumNumberOfTouches:1];
    //将手势添加到draggableObj里
    [_mainView addGestureRecognizer:panGR];
    [_mainView setTag:100];
    
    
    _searchText = searchString;
    _isFirstSearchBar = isFirstBar;
    
    self.clickedButtonTag  = -1;

    _isOpen = !isOpen;
    
    [self sideMenuShow];

    parentView = _mainView;

    return self;
}

- (void)objectDidDragged:(UIPanGestureRecognizer *)sender {
    
    if ([self.delegate respondsToSelector:@selector(partfarmButtonClicked:)]) {
        [self.delegate partfarmButtonClicked:@"4"];
    }
    
    CGFloat vHeight = 120;
    
    CGFloat dH = _pViewHeight - 64 - vHeight;
    
    UIView *draggableObj = [_mainView viewWithTag:100];

    if (sender.state == UIGestureRecognizerStateChanged) {
        //注意，这里取得的参照坐标系是该对象的上层View的坐标。
        CGPoint offset = [sender translationInView:_mainView];
        
        CGPoint dragPoint = draggableObj.center;
        
        //通过计算偏移量来设定draggableObj的新坐标
        [draggableObj setCenter:CGPointMake(dragPoint.x, dragPoint.y + offset.y)];
        //初始化sender中的坐标位置。如果不初始化，移动坐标会一直积累起来。
        [sender setTranslation:CGPointMake(0, 0) inView:_mainView];
        
        _isUp = offset.y < 0 ? YES: NO;
        
        if(Y(_mainView) < 0)
        {
            CGRect rect = draggableObj.frame;
            rect.origin.y = 0;
            draggableObj.frame = rect;
            
        }
        else if (Y(_mainView) > dH)
        {
            CGRect rect = draggableObj.frame;
            rect.origin.y = dH;
            draggableObj.frame = rect;
            
        }
    }
    if (sender.state == UIGestureRecognizerStateEnded)
    {
        CGFloat vHeight = 120;
        
        CGFloat dH = _pViewHeight - 64 - vHeight;
        
        UIView *draggableObj = [_mainView viewWithTag:100];
        
        [UIView beginAnimations:@"move" context:nil];
        [UIView setAnimationDuration:0.4];
        [UIView setAnimationDelegate:self];//改变它的frame的x,y的值
        CGRect frame = draggableObj.frame;
        
        frame.origin.y = _isUp ? 0 : dH;
        
        draggableObj.frame = frame;
        [UIView commitAnimations];

        [self sideMenuShow];
    }
}

- (void)addGestureRecognizer:(UIControl*)targetView
{
    UISwipeGestureRecognizer* upGesture = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(sideMenuShow)];
    UISwipeGestureRecognizer* downGesture = [[UISwipeGestureRecognizer alloc ] initWithTarget:self action:@selector(sideMenuShow)];
    
    upGesture.direction = UISwipeGestureRecognizerDirectionUp;
    downGesture.direction = UISwipeGestureRecognizerDirectionDown;
    
    upGesture.delegate = self;
    downGesture.delegate = self;
    
    [targetView addGestureRecognizer:upGesture];
    [targetView addGestureRecognizer:downGesture];
    
}

- (void)testGesture:(UISwipeGestureRecognizer *)recognizer
{
    if(recognizer.direction==UISwipeGestureRecognizerDirectionDown) {
        NSLog(@"swipe down");
        [self sideMenuShow];
    }
    else if(recognizer.direction==UISwipeGestureRecognizerDirectionUp) {
        NSLog(@"swipe up");
        //执行程序
        [self sideMenuShow];
    }
    else
    {
        [_txtSearch1 resignFirstResponder];
        
    }
}

- (void)showMenu
{
    CGFloat vHeight = 120;
    
    CGFloat dH = _pViewHeight - 64 - vHeight;
    
    UIView *draggableObj = [_mainView viewWithTag:100];
    
    [UIView beginAnimations:@"move" context:nil];
    [UIView setAnimationDuration:0.4];
    [UIView setAnimationDelegate:self];//改变它的frame的x,y的值
    CGRect frame = draggableObj.frame;
    
    _isUp = _isOpen;
    
    frame.origin.y = _isUp ? 0 : dH;
    
    draggableObj.frame = frame;
    [UIView commitAnimations];
    
    [self sideMenuShow];
}

- (void)sideMenuShow
{
    //show
    int index = 0;
    int columeCount = 5;
    
    CGFloat top = 45;                                       //change main menu view top height
    CGFloat menuWidth = (_pViewWidth - 30)/columeCount;
    CGFloat menuHeight = 70;
    CGFloat vHeight = 120;
    NSInteger rowCount = _dataCount / columeCount;
    
    for (UIControl *control in _mainView.subviews) {
        [control removeFromSuperview];
    }
    
    UIButton* mbutton = [[UIButton alloc] initWithFrame:CGRectMake(0, 1, _pViewWidth, 28)];
    mbutton.backgroundColor = [UIColor clearColor];
    
    mbutton.titleLabel.textAlignment = NSTextAlignmentCenter;
    [mbutton addTarget:self action:@selector(menuClicked) forControlEvents:UIControlEventTouchUpInside];
    [mbutton setImage:[UIImage imageNamed:@"btn_caidan"] forState:UIControlStateNormal];
    
    
    [_mainView addSubview:mbutton];
    
    //    [self addGestureRecognizer:mbutton];
    
    if (_isOpen) {
        
        //        dispatch_async(dispatch_get_main_queue(), ^{
        //            [UIView animateWithDuration:0.4 animations:^{
        _mainView.transform = CGAffineTransformTranslate(CGAffineTransformIdentity, 0, 0);
        //            }];
        //        });
        
        topBar = [[UINavigationBar alloc] initWithFrame:CGRectMake(0, 28, [UIScreen mainScreen].bounds.size.width, 40)];
        topBar.barStyle = UIStatusBarStyleDefault;
        [topBar setTintColor:[UIColor whiteColor]];
        [topBar setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor whiteColor],
                                         NSFontAttributeName:[UIFont systemFontOfSize:15]
                                         }];
        [topBar setBarTintColor:[UIColor colorWithRed:0.10f green:0.10f blue:0.10f alpha:1.0f]];
        
        UINavigationItem *item = [[UINavigationItem alloc] initWithTitle:@"群组"];
        
        //        UIButton *leftButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 70, 20)];
        //        [leftButton addTarget:self action:@selector(btnShowAllGroup:) forControlEvents:UIControlEventTouchUpInside];
        //        UIImageView* imgview = [[UIImageView alloc] initWithFrame:CGRectMake(0, 2, 10, 18)];
        //        [imgview setImage:[UIImage imageNamed:@"btn_fanhui"]];
        //        [leftButton addSubview:imgview];
        //        UILabel* ti = [[UILabel alloc] initWithFrame:CGRectMake(18, 2, 80, 20)];
        //        [ti setBackgroundColor:[UIColor clearColor]];
        //        [ti setTextColor:[UIColor whiteColor]];
        //        [ti setText:@"所有群组"];
        //        [ti setFont:[UIFont systemFontOfSize:13]];
        //        [leftButton addSubview:ti];
        //
        //        UIBarButtonItem *leftBarButton = [[UIBarButtonItem alloc]initWithCustomView:leftButton];
        //        [leftBarButton setTitleTextAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:13]} forState:UIControlStateNormal];
        //
        //        [item setLeftBarButtonItem:leftBarButton];
        
        UIButton *rightBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 70, 20)];
        [rightBtn addTarget:self action:@selector(btnCreateNewGroup:) forControlEvents:UIControlEventTouchUpInside];
        
        UILabel* cti = [[UILabel alloc] initWithFrame:CGRectMake(6, 2, 80, 20)];
        [cti setBackgroundColor:[UIColor clearColor]];
        [cti setTextColor:[UIColor whiteColor]];
        [cti setText:@"创建群组"];
        [cti setFont:[UIFont systemFontOfSize:13]];
        [rightBtn addSubview:cti];
        
        UIBarButtonItem *rightBarButton = [[UIBarButtonItem alloc]initWithCustomView:rightBtn];
        [rightBarButton setTitleTextAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:13]} forState:UIControlStateNormal];
        
        [item setRightBarButtonItem:rightBarButton];
        [topBar pushNavigationItem:item animated:NO];
        
        [topBar setTitleTextAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:13],NSForegroundColorAttributeName:[UIColor whiteColor]}];
        
        [_mainView addSubview:topBar];
        
        
        _messageView = [[UIView alloc] initWithFrame:
                        CGRectMake(0,
                                   topBar.frame.size.height + topBar.frame.origin.y,
                                   _mainView.frame.size.width,
                                   _mainView.frame.size.height - topBar.frame.size.height - topBar.frame.origin.y)];
        [_messageView setBackgroundColor:[UIColor blackColor]];
        
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, _pViewWidth, 40)];
        [view setBackgroundColor:[UIColor colorWithRed:0.15f green:0.15f blue:0.15f alpha:1.0f]];
        
        
        UIView* searchView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, _pViewWidth, 40)];
        [searchView setBackgroundColor: [UIColor blackColor]];
        
        UIImageView* sImageView = [[UIImageView alloc] initWithFrame:CGRectMake(10, 10, 18, 18)];
        [sImageView setBackgroundColor:[UIColor clearColor]];
        [sImageView setImage:[UIImage imageNamed:@"icon_sousuo"]];
        [searchView addSubview:sImageView];
        
        InputText *inputText = [[InputText alloc] init];
        inputText.delegate = self;
        
        _txtSearch1 = [[UITextField alloc] initWithFrame:CGRectMake(34, 5, _pViewWidth - 79, 30)];
        [_txtSearch1 setBackgroundColor:[UIColor clearColor]];
        [_txtSearch1 setBorderStyle:UITextBorderStyleNone];
        [_txtSearch1 setFont:[UIFont systemFontOfSize:17]];
        [_txtSearch1 setTextColor:[UIColor whiteColor]];
        [_txtSearch1 setReturnKeyType:UIReturnKeySearch];
        [_txtSearch1 addTarget:self action:@selector(textFieldDidChange) forControlEvents:UIControlEventEditingChanged];
        _txtSearch1.delegate = self;
        
        
        _txtSearch1 = [inputText setupWithIcon:nil  point:nil  textFieldControl:_txtSearch1 showBottomLine:NO];
        
        _lblSearch1 = [[UILabel alloc] init];
        _lblSearch1.text = @"搜索";
        _lblSearch1.font = [UIFont boldSystemFontOfSize:14];
        _lblSearch1.textColor = [UIColor grayColor];
        _lblSearch1.frame = _txtSearch1.frame;
        
        [searchView addSubview:_txtSearch1];
        [searchView addSubview:_lblSearch1];
        
        [view addSubview:searchView];
        
        if (_isFirstSearchBar) {
            if (_searchText != nil) {
                _txtSearch1.text = _searchText;
                //[self restoreTextName:_lblSearch1 textField:_txtSearch1];
                [self diminishTextName:_lblSearch1];
            }
        }
        
        UILabel* bottomLine = [[UILabel alloc] initWithFrame:CGRectMake(0, 39, _pViewWidth, 0.5)];
        [bottomLine setBackgroundColor:[UIColor grayColor]];
        [view addSubview:bottomLine];
        
        //        [_messageView addSubview:view];
        
        
        if (_dataCount / columeCount > 0) {
            rowCount++;
        }
        else
            rowCount = 1;
        
        CGFloat svHeight = menuHeight * rowCount + 7;
        
        UIScrollView* sv = [[UIScrollView alloc] initWithFrame:CGRectMake(0, top, [UIScreen mainScreen].bounds.size.width, svHeight)];
        
        [sv setContentSize:CGSizeMake([UIScreen mainScreen].bounds.size.width, menuHeight * rowCount)];
        [sv setBounces:YES];
        [sv setScrollEnabled:YES];
        [sv setIndicatorStyle:UIScrollViewIndicatorStyleBlack];
        [sv setShowsVerticalScrollIndicator:YES];
        
        for (int i = 0; i < rowCount; i++) {
            
            int count = columeCount;
            
            if (i + 1 == rowCount) {
                count = (int)(_dataCount - i * columeCount);
            }
            
            for (int j = 0; j < count; j++)
            {
                index = i * columeCount + j;
                
                CGFloat x = j * menuWidth + (j+1) * 5;
                CGFloat y = i * menuHeight;
                y = y + 1;
                
                UIView* menuView = [[UIView alloc]
                                    initWithFrame:CGRectMake(x, y, menuWidth, menuHeight)];
                
                UIButton *menuButton = [[UIButton alloc] initWithFrame:CGRectMake((menuWidth - 44) / 2, 5, 44, 44)];
                
                //[menuButton setImage:[_imageList objectAtIndex:index] forState:UIControlStateNormal];
                
                if(index == _imageList.count - 1)
                {
                    [menuButton setBackgroundImage:[UIImage imageNamed:@"btn_chuangjianqunzu_1"] forState:UIControlStateNormal];
                    [menuButton setBackgroundImage:[UIImage imageNamed:@"btn_chuangjianqunzu_2"] forState:UIControlStateHighlighted];
                    
                }
                else
                {
                    [menuButton setImageWithURL:[NSURL URLWithString:[_imageList objectAtIndex:index]]  forState:UIControlStateNormal placeholderImage:[UIImage imageNamed:@"icon_touxiang"] usingActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
                }
                
                [menuButton setBackgroundColor:[UIColor clearColor]];
                [menuButton addTarget:self action:@selector(menuButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
                [menuButton setTag:index];
                
                
                
                UILabel* menuName = [[UILabel alloc] initWithFrame:CGRectMake(0, 50, menuWidth, 15)];
                
                [menuName setText:[_nameList objectAtIndex:index]];
                [menuName setBackgroundColor:[UIColor clearColor]];
                [menuName setTextAlignment:NSTextAlignmentCenter];
                [menuName setTextColor:[UIColor whiteColor]];
                [menuName setFont:[UIFont boldSystemFontOfSize:9]];
                
                [menuView addSubview:menuButton];
                [menuView addSubview:menuName];
                
                if (self.clickedButtonTag != index) {
                    NSString* badgeValueString = [_badgeList objectAtIndex:index];
                    NSString * allnumBadgeValueString = @"0";
                    if(_allNumBadgeList.count)
                    {
                        allnumBadgeValueString = [NSString stringWithFormat:@"%@", _allNumBadgeList[index]];
                    }
                    
                    //                    badgeValueString = @"100";
                    //                    allnumBadgeValueString = @"1";//momo
                    
                    if (![badgeValueString isEqualToString:@"0"]) {
                        [self addBadgeView:menuView parentView:menuView  showValue:badgeValueString isAllNum:NO withIndex:index];
                    }
                    else if(![allnumBadgeValueString isEqualToString:@"0"])
                    {
                        [self addBadgeView:menuView parentView:menuView  showValue:allnumBadgeValueString isAllNum:YES withIndex:index];
                    }
                    
                    UIButton *menuButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, W(menuView), H(menuView))];
                    [menuButton setBackgroundColor:[UIColor clearColor]];
                    [menuButton addTarget:self action:@selector(menuButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
                    [menuButton setTag:index];
                    [menuView addSubview:menuButton];
                    
                    [sv addSubview:menuView];
                }
                else
                {
                    self.clickedButtonTag = -1;
                    [self addBadgeView:menuView parentView:menuView  showValue:@"0" isAllNum:NO withIndex:index];
                    [sv addSubview:menuView];
                }
                
            }
        }
        
        [_messageView addSubview:sv];
        
        CGFloat width = [UIScreen mainScreen].bounds.size.width;
        
        //我的
        
        UIView * msgView = [[UIView alloc]initWithFrame:CGRectMake(0, YH(sv), width, 68)];
        [msgView setBackgroundColor:[UIColor clearColor]];
        [_messageView addSubview:msgView];
        
        bottomLine = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, width, 0.5f)];
        [bottomLine setBackgroundColor:[UIColor grayColor]];
        [msgView addSubview:bottomLine];
        
        bottomLine = [[UILabel alloc] initWithFrame:CGRectMake(0, H(msgView) - 0.5, width, 0.5f)];
        [bottomLine setBackgroundColor:[UIColor grayColor]];
        [msgView addSubview:bottomLine];
        
        UIImageView * photo = [[UIImageView alloc]initWithFrame:CGRectMake(12 + 5, 14, 40, 40)];
        photo.image = [UIImage imageNamed:@"icon_wode"];
        [msgView addSubview:photo];
        
        UILabel * titLbl = [[UILabel alloc] initWithFrame:CGRectMake(XW(photo) + 14, 0, width, H(msgView))];
        titLbl.backgroundColor = [UIColor clearColor];
        titLbl.text = @"我的";
        titLbl.font = [UIFont systemFontOfSize:16];
        titLbl.textColor = [UIColor whiteColor];
        [msgView addSubview:titLbl];
        
        UIButton * btn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, W(msgView), H(msgView))];
        [btn addTarget:self action:@selector(btnMyMessageClicked:) forControlEvents:UIControlEventTouchUpInside];
        btn.backgroundColor = [UIColor clearColor];
        [msgView addSubview:btn];
        
        
        //成员通讯录
        msgView = [[UIView alloc]initWithFrame:CGRectMake(0, YH(msgView), width, 68)];
        [msgView setBackgroundColor:[UIColor clearColor]];
        [_messageView addSubview:msgView];
        
        bottomLine = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, width, 0.5f)];
        [bottomLine setBackgroundColor:[UIColor grayColor]];
        [msgView addSubview:bottomLine];
        
        bottomLine = [[UILabel alloc] initWithFrame:CGRectMake(0, H(msgView) - 0.5, width, 0.5f)];
        [bottomLine setBackgroundColor:[UIColor grayColor]];
        [msgView addSubview:bottomLine];
        
        photo = [[UIImageView alloc]initWithFrame:CGRectMake(12 + 5, 14, 40, 40)];
        photo.image = [UIImage imageNamed:@"icon_chengyuantongxunlu"];
        [msgView addSubview:photo];
        
        titLbl = [[UILabel alloc] initWithFrame:CGRectMake(XW(photo) + 14, 0, width, H(msgView))];
        titLbl.backgroundColor = [UIColor clearColor];
        titLbl.text = @"成员通讯录";
        titLbl.font = [UIFont systemFontOfSize:16];
        titLbl.textColor = [UIColor whiteColor];
        [msgView addSubview:titLbl];
        
        btn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, W(msgView), H(msgView))];
        [btn addTarget:self action:@selector(jumpToMemberList:) forControlEvents:UIControlEventTouchUpInside];
        btn.backgroundColor = [UIColor clearColor];
        [msgView addSubview:btn];
        
        [_mainView addSubview:_messageView];
        
        [self loadTableView:_messageView.frame];
        
        _isOpen = NO;
    }
    else
    {
        //        dispatch_async(dispatch_get_main_queue(), ^{
        //            [UIView animateWithDuration:0.4 animations:^{
        _mainView.transform = CGAffineTransformTranslate(CGAffineTransformIdentity, 0, _pViewHeight - 64 - vHeight);
        //            }];
        //        });
        
        top = 20;
        
        if (_dataCount > 20) {
            columeCount = 20;
        }
        else
            columeCount = (int)_dataCount;
        //momo todo
        UIScrollView* sv = [[UIScrollView alloc] initWithFrame:CGRectMake(0, top, [UIScreen mainScreen].bounds.size.width, menuHeight)];
        
        [sv setContentSize:CGSizeMake((menuWidth + 5) * columeCount, menuHeight)];
        [sv setBounces:YES];
        [sv setScrollEnabled:YES];
        [sv setIndicatorStyle:UIScrollViewIndicatorStyleBlack];
        [sv setShowsHorizontalScrollIndicator:YES];
        
        
        for (int j = 0; j < columeCount; j++)
        {
            index = j;
            
            if (index == _nameList.count) {
                break;
            }
            
            CGFloat x = j * menuWidth + (j+1) * 5;
            CGFloat y = 0;
            y = y + top;
            
            UIView* menuView = [[UIView alloc]
                                initWithFrame:CGRectMake(x, 0, menuWidth, menuHeight)];
            
            UIButton *menuButton = [[UIButton alloc] initWithFrame:CGRectMake((menuWidth - 44) / 2, 5, 44, 44)];
            
            //[menuButton setImage:[_imageList objectAtIndex:index] forState:UIControlStateNormal];
            
            if(index == _imageList.count - 1)
            {
                [menuButton setBackgroundImage:[UIImage imageNamed:@"btn_chuangjianqunzu_1"] forState:UIControlStateNormal];
                [menuButton setBackgroundImage:[UIImage imageNamed:@"btn_chuangjianqunzu_2"] forState:UIControlStateHighlighted];
                
            }
            else
            {
                [menuButton setImageWithURL:[NSURL URLWithString:[_imageList objectAtIndex:index]]  forState:UIControlStateNormal placeholderImage:[UIImage imageNamed:@"icon_touxiang"] usingActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
            }
            
            [menuButton setBackgroundColor:[UIColor clearColor]];
            [menuButton addTarget:self action:@selector(menuButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
            [menuButton setTag:index];
            
            
            UILabel* menuName = [[UILabel alloc] initWithFrame:CGRectMake(0, 50, menuWidth, 15)];
            
            [menuName setText:[_nameList objectAtIndex:index]];
            [menuName setBackgroundColor:[UIColor clearColor]];
            [menuName setTextAlignment:NSTextAlignmentCenter];
            [menuName setTextColor:[UIColor whiteColor]];
            [menuName setFont:[UIFont boldSystemFontOfSize:9]];
            
            [menuView addSubview:menuButton];
            [menuView addSubview:menuName];
            
            if (self.clickedButtonTag != index) {
                NSString* badgeValueString = [_badgeList objectAtIndex:index];
                NSString * allnumBadgeValueString = @"0";
                if(_allNumBadgeList.count)
                {
                    allnumBadgeValueString = [NSString stringWithFormat:@"%@", _allNumBadgeList[index]];
                }
                //                badgeValueString = @"100";
                //                allnumBadgeValueString = @"1";//momo
                //todo
                if (![badgeValueString isEqualToString:@"0"]) {
                    [self addBadgeView:menuView parentView:menuView  showValue:badgeValueString isAllNum:NO withIndex:index];
                }
                else if(![allnumBadgeValueString isEqualToString:@"0"])
                {
                    [self addBadgeView:menuView parentView:menuView  showValue:allnumBadgeValueString isAllNum:YES withIndex:index];
                }
                
                UIButton *menuButton = [[UIButton alloc] initWithFrame:CGRectMake((menuWidth - 44) / 2, 5, 44, 44)];
                [menuButton setBackgroundColor:[UIColor clearColor]];
                [menuButton addTarget:self action:@selector(menuButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
                [menuButton setTag:index];
                
                [menuView addSubview:menuButton];
                
                [sv addSubview:menuView];
            }
            else
            {
                self.clickedButtonTag = -1;
            }
            
            [sv addSubview:menuView];
            
            
        }
        
        [_mainView addSubview:sv];
        
        UILabel* menuTitle = [[UILabel alloc] initWithFrame:CGRectMake((_pViewWidth - 120) / 2, top + menuHeight, 120, 28)];
        menuTitle.backgroundColor = [UIColor clearColor];
        menuTitle.text = @"群组";
        menuTitle.textColor = [UIColor grayColor];
        menuTitle.textAlignment = NSTextAlignmentCenter;
        menuTitle.font = [UIFont systemFontOfSize:13];
        
        [_mainView addSubview:menuTitle];
        
        _isOpen = YES;
    }
    
}

- (void)addBadgeView:(UIView*)control parentView:(UIView*)pview showValue:(NSString*)value isAllNum:(BOOL)isAllNum withIndex:(NSInteger)index
{
    CGPoint location = CGPointMake(control.bounds.size.width/9 * 7, control.bounds.size.height/7);

    PPDragDropBadgeView* badgeView = [[PPDragDropBadgeView alloc] initWithSuperView:control parentView:pview location:CGPointMake(0,0) radius:9.f dragdropCompletion:^{
        NSLog(@"Drag Done");
    }];
    
    if (![value isEqualToString:@"0"]&&![value isEqualToString:@""]&& value != nil) {
        badgeView.location = location;
        badgeView.tintColor = [UIColor redColor];
        badgeView.borderColor = [UIColor redColor];
        badgeView.borderWidth = 1;
        if(!isAllNum)
        {
            badgeView.text = value;
        }
        else
        {
            UIImageView * icon = [[UIImageView alloc]initWithFrame:CGRectMake(location.x - 4, location.y - 5 , 10, 10)];
            icon.image = [UIImage imageNamed:@"icon_liuyan_bai"];
            [badgeView addSubview:icon];
        }
    }
    else
    {
        badgeView.tintColor = [UIColor clearColor];
        badgeView.borderColor = [UIColor clearColor];
    }
}

- (void)menuClicked
{
    //[self showMenu];
    if ([self.delegate respondsToSelector:@selector(partfarmButtonClicked:)]) {
        [self.delegate partfarmButtonClicked:@"3"];
    }
}

- (void)menuButtonClicked:(id)sender
{
    UIButton* btn = (UIButton*)sender;
    NSInteger index = btn.tag;
    
    UIView* pButtonView = btn.superview;
    
    for (UIControl* control in pButtonView.subviews) {
        if ([control isKindOfClass:[PPDragDropBadgeView class]]) {
            ((PPDragDropBadgeView*)control).text = @"";
            [control removeFromSuperview];
        }
    }
    
    NSMutableArray* tmp = [NSMutableArray array];
    for (int i = 0;i < _badgeList.count; i++) {
        if (i == index) {
            [tmp addObject:@"0"];
        }
        else
        {
            [tmp addObject:[_badgeList objectAtIndex:i]];
        }
    }
    _badgeList =[NSMutableArray arrayWithArray:tmp];

    
    if ([self.delegate respondsToSelector:@selector(icSideMenuClicked:)]) {
        [self.delegate icSideMenuClicked:sender];
    }
}

- (void)btnShowAllGroup:(id)sender
{
    [self restoreTextName:_lblSearch1 textField:_txtSearch1];
    
    UINavigationItem *item = [[UINavigationItem alloc] initWithTitle:@"所有群组"];
    
    UIButton *rbtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 70, 20)];
    [rbtn addTarget:self action:@selector(btnGroupMessageClicked:) forControlEvents:UIControlEventTouchUpInside];
    
    UILabel* rti = [[UILabel alloc] initWithFrame:CGRectMake(6, 2, 80, 20)];
    [rti setBackgroundColor:[UIColor clearColor]];
    [rti setTextColor:[UIColor whiteColor]];
    [rti setText:@"返回"];
    [rti setFont:[UIFont systemFontOfSize:13]];
    [rbtn addSubview:rti];
    
    UIBarButtonItem *rightBarButton = [[UIBarButtonItem alloc]initWithCustomView:rbtn];
    [rightBarButton setTitleTextAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:13]} forState:UIControlStateNormal];
    
    
//    UIButton *leftButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 70, 20)];
//    [leftButton addTarget:self action:@selector(btnCreateNewGroup:) forControlEvents:UIControlEventTouchUpInside];
//
//    UILabel* ti = [[UILabel alloc] initWithFrame:CGRectMake(6, 2, 80, 20)];
//    [ti setBackgroundColor:[UIColor clearColor]];
//    [ti setTextColor:[UIColor whiteColor]];
//    [ti setText:@"创建群组"];
//    [ti setFont:[UIFont systemFontOfSize:13]];
//    [leftButton addSubview:ti];
//    
//    UIBarButtonItem *leftBarButton = [[UIBarButtonItem alloc]initWithCustomView:leftButton];
//    [leftBarButton setTitleTextAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:13]} forState:UIControlStateNormal];
//    
//    [item setRightBarButtonItem:leftBarButton];
    [item setLeftBarButtonItem:rightBarButton];
    [topBar pushNavigationItem:item animated:NO];
    
    
    CGFloat width = [UIScreen mainScreen].bounds.size.width;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [UIView animateWithDuration:0.4 animations:^{
            _messageView.transform = CGAffineTransformTranslate(CGAffineTransformIdentity, -width, 0);
            _groupView.transform = CGAffineTransformTranslate(CGAffineTransformIdentity, -width, 0);
        }];
    });
    
    
    if ([self.delegate respondsToSelector:@selector(leftTopBarButtonClicked:)]){
         //[self.delegate leftTopBarButtonClicked:sender];
    }
}



#pragma mark - UITextFieldDelegate
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    if (textField == _txtSearch1)
    {
        [self diminishTextName:_lblSearch1];
        
    }
    
    if (textField == _txtSearch)
    {
        [self diminishTextName:_lblSearch];
        
    }
    return YES;
}
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField == _txtSearch1)
    {
        [self restoreTextName:_lblSearch1 textField:_txtSearch1];
        
        if ([self.delegate respondsToSelector:@selector(bottomSideViewSearchTextPageOneSubmitEvent:)]) {
            [self.delegate bottomSideViewSearchTextPageOneSubmitEvent:textField.text];
        }
        
    }
   else if (textField == _txtSearch)
    {
        [self restoreTextName:_lblSearch textField:_txtSearch];
        
            if ([self.delegate respondsToSelector:@selector(bottomSideViewSearchTextPageTwoSubmitEvent:)]) {
                [self.delegate bottomSideViewSearchTextPageTwoSubmitEvent:textField.text];
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

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if ([string isEqualToString:@"\n"]){
        [self restoreTextName:_lblSearch textField:_txtSearch];
        return NO;
    }
    return YES;
    
}

#pragma mark - touchesBegan
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [_mainView endEditing:YES];
    [self restoreTextName:_lblSearch textField:_txtSearch];
}


#pragma -
#pragma mark - Table View 
- (void)loadTableView:(CGRect)frame
{
    CGRect nFrame = CGRectMake([UIScreen mainScreen].bounds.size.width, frame.origin.y , frame.size.width, frame.size.height - 40);
    
    _groupView = [[UIView alloc] initWithFrame:nFrame];
    [_groupView setBackgroundColor:[UIColor orangeColor]];
    
    /*
    _sections = @[@"A", @"D", @"F", @"M", @"N", @"O", @"Z"];
    
    _rows = @[@[@"adam", @"alfred", @"ain", @"abdul", @"anastazja", @"angelica"],
              @[@"dennis" , @"deamon", @"destiny", @"dragon", @"dry", @"debug", @"drums"],
              @[@"Fredric", @"France", @"friends", @"family", @"fatish", @"funeral"],
              @[@"Mark", @"Madeline"],
              @[@"Nemesis", @"nemo", @"name"],
              @[@"Obama", @"Oprah", @"Omen", @"OMG OMG OMG", @"O-Zone", @"Ontario"],
              @[@"Zeus", @"Zebra", @"zed"]];
    */
    
    _sections = self.indexBarSectionArray;
    _rows = self.dataArray;
    
    
    CGFloat tableWidth = [UIScreen mainScreen].bounds.size.width;
    
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, tableWidth - 30, frame.size.height)];
    [_tableView setBackgroundColor:[UIColor blackColor]];
    
    [_tableView setSectionIndexColor:[UIColor blueColor]];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    
    [_tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    
    
    _indexBar = [[AIMTableViewIndexBar alloc] initWithFrame:CGRectMake(tableWidth - 30, 0, 30, frame.size.height)];
    [_indexBar setBackgroundColor:[UIColor blackColor]];
    _indexBar.delegate = self;
    
    
    [_groupView addSubview:_tableView];
    [_groupView addSubview:_indexBar];
    
    [_mainView addSubview:_groupView];
    
    _tableView.tableHeaderView = ({
        
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableWidth, 167 - 66 - 66)];
        [view setBackgroundColor:[UIColor colorWithRed:0.15f green:0.15f blue:0.15f alpha:1.0f]];
        
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
        [_txtSearch setReturnKeyType:UIReturnKeySearch];
        [_txtSearch addTarget:self action:@selector(textFieldDidChange) forControlEvents:UIControlEventEditingChanged];
        _txtSearch.delegate = self;
        
        _txtSearch = [inputText setupWithIcon:nil  point:nil  textFieldControl:_txtSearch showBottomLine:NO];
        
        _lblSearch = [[UILabel alloc] init];
        _lblSearch.text = @"搜索";
        _lblSearch.font = [UIFont boldSystemFontOfSize:14];
        _lblSearch.textColor = [UIColor grayColor];
        _lblSearch.frame = _txtSearch.frame;
        
        [searchView addSubview:_txtSearch];
        [searchView addSubview:_lblSearch];
        
//        [view addSubview:searchView];
        
        if (!_isFirstSearchBar) {
            if (_searchText != nil) {
                _txtSearch.text = _searchText;
                [self diminishTextName:_lblSearch];
            }
        }
        
        
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
//        [mlbl setText:@"群组消息"];
        [mBtn addSubview:mlbl];
//
//        [messageView addSubview:mBtn];
        
        UILabel* bottomLine = [[UILabel alloc] initWithFrame:CGRectMake(0, searchView.frame.origin.y + searchView.frame.size.height -1,  [UIScreen mainScreen].bounds.size.width, 0.5f)];
        [bottomLine setBackgroundColor:[UIColor grayColor]];
        [view addSubview:bottomLine];
        
        UIView* projectView = [[UIView alloc] initWithFrame:CGRectMake(-1, 101 - H(messageView), tableWidth + 2, 66)];
        [projectView setBackgroundColor: [UIColor clearColor]];
        
        UIButton* pBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, tableWidth, 66)];
        [pBtn setBackgroundColor:[UIColor clearColor]];
        [pBtn addTarget:self action:@selector(btnGroupProjectClicked:) forControlEvents:UIControlEventTouchUpInside];
        
        UIImageView* pImage = [[UIImageView alloc] initWithFrame:CGRectMake(12, 15, 42, 42)];
        [pImage setBackgroundColor:[UIColor clearColor]];
        [pImage setImage:[UIImage imageNamed:@"icon_xiangmu"]];
        [pBtn addSubview:pImage];
        
        UILabel* plbl = [[UILabel alloc] initWithFrame:CGRectMake(68, 26, 120, 19)];
        [plbl setBackgroundColor:[UIColor clearColor]];
        [plbl setTextAlignment:NSTextAlignmentLeft];
        [plbl setTextColor:[UIColor whiteColor]];
        [plbl setFont:[UIFont boldSystemFontOfSize:15]];
        [plbl setText:@"群组"];
        [pBtn addSubview:plbl];
        
//        [projectView addSubview:pBtn];
        
//        UILabel* bottomLine1 = [[UILabel alloc] initWithFrame:CGRectMake(0, projectView.frame.origin.y + projectView.frame.size.height - 0.5,  [UIScreen mainScreen].bounds.size.width, 0.5)];
//        [bottomLine1 setBackgroundColor:[UIColor grayColor]];
//        [view addSubview:bottomLine1];

        
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
        
        //[departmentView addSubview:dBtn];
        
        
        UILabel* bottomLine2 = [[UILabel alloc] initWithFrame:CGRectMake(0, departmentView.frame.origin.y + departmentView.frame.size.height -1, [UIScreen mainScreen].bounds.size.width, 0.5)];
        [bottomLine2 setBackgroundColor:[UIColor grayColor]];
        //[view addSubview:bottomLine2];
        
        
//        [view addSubview:searchView];
//        [view addSubview:messageView];
        [view addSubview:projectView];
        [view addSubview:departmentView];
        
        [view setBackgroundColor:[UIColor blackColor]];
        view;
    });
    
}

#pragma mark -
#pragma mark MemberViewFromControllerGroupList
- (void)btnCreateNewGroup:(id)sender
{
    [self restoreTextName:_lblSearch textField:_txtSearch];
    if ([self.delegate respondsToSelector:@selector(btnCreateNewGroup:)])
        [self.delegate btnCreateNewGroup:sender];
}

- (void)btnMyMessageClicked:(id)sender
{
//    [self restoreTextName:_lblSearch textField:_txtSearch];
    if ([self.delegate respondsToSelector:@selector(btnMyMessageClicked:)])
        [self.delegate btnMyMessageClicked:sender];
}


- (void) jumpToMemberList:(id)sender
{
    UINavigationItem *item = [[UINavigationItem alloc] initWithTitle:@"群组"];
    
    UIButton *leftButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 70, 20)];
    [leftButton addTarget:self action:@selector(btnGroupBackClicked:) forControlEvents:UIControlEventTouchUpInside];
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
    [item setLeftBarButtonItem:leftBarButton];
    
    [topBar pushNavigationItem:item animated:NO];
    
    CGFloat width = [UIScreen mainScreen].bounds.size.width;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [UIView animateWithDuration:0.4 animations:^{
            _messageView.transform = CGAffineTransformTranslate(CGAffineTransformIdentity, -width, 0);
            _groupView.transform = CGAffineTransformTranslate(CGAffineTransformIdentity, -width, 0);
        }];
    });
}

- (void)btnGroupBackClicked:(id)sender
{
    UINavigationItem *item = [[UINavigationItem alloc] initWithTitle:@"群组"];

    UIButton *rightBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 70, 20)];
    [rightBtn addTarget:self action:@selector(btnCreateNewGroup:) forControlEvents:UIControlEventTouchUpInside];
    
    UILabel* cti = [[UILabel alloc] initWithFrame:CGRectMake(6, 2, 80, 20)];
    [cti setBackgroundColor:[UIColor clearColor]];
    [cti setTextColor:[UIColor whiteColor]];
    [cti setText:@"创建群组"];
    [cti setFont:[UIFont systemFontOfSize:13]];
    [rightBtn addSubview:cti];
    
    UIBarButtonItem *rightBarButton = [[UIBarButtonItem alloc]initWithCustomView:rightBtn];
    [rightBarButton setTitleTextAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:13]} forState:UIControlStateNormal];
    
    [item setRightBarButtonItem:rightBarButton];
    
    [item setHidesBackButton:TRUE animated:NO];

    [topBar pushNavigationItem:item animated:NO];
    
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [UIView animateWithDuration:0.4 animations:^{
            _messageView.transform = CGAffineTransformTranslate(CGAffineTransformIdentity, 0, 0);
            _groupView.transform = CGAffineTransformTranslate(CGAffineTransformIdentity, 0, 0);
        }];
    });

}

- (void)btnGroupMessageClicked:(id)sender
{
    //CGFloat width = [UIScreen mainScreen].bounds.size.width;
    
    [self restoreTextName:_lblSearch textField:_txtSearch];
    
    UINavigationItem *item = [[UINavigationItem alloc] initWithTitle:@"群组"];
    
    UIButton *leftButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 70, 20)];
    [leftButton addTarget:self action:@selector(btnShowAllGroup:) forControlEvents:UIControlEventTouchUpInside];
    UIImageView* imgview = [[UIImageView alloc] initWithFrame:CGRectMake(0, 2, 10, 18)];
    [imgview setImage:[UIImage imageNamed:@"btn_fanhui"]];
    [leftButton addSubview:imgview];
    UILabel* ti = [[UILabel alloc] initWithFrame:CGRectMake(18, 2, 80, 20)];
    [ti setBackgroundColor:[UIColor clearColor]];
    [ti setTextColor:[UIColor whiteColor]];
    [ti setText:@"所有群组"];
    [ti setFont:[UIFont systemFontOfSize:13]];
    [leftButton addSubview:ti];
    
    UIBarButtonItem *leftBarButton = [[UIBarButtonItem alloc]initWithCustomView:leftButton];
    [leftBarButton setTitleTextAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:13]} forState:UIControlStateNormal];
    
    [item setLeftBarButtonItem:leftBarButton];
    [topBar pushNavigationItem:item animated:NO];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [UIView animateWithDuration:0.4 animations:^{
            _messageView.transform = CGAffineTransformTranslate(CGAffineTransformIdentity, 0, 0);
            _groupView.transform = CGAffineTransformTranslate(CGAffineTransformIdentity, 0, 0);
        }];
    });
}

- (void)btnGroupProjectClicked:(id)sender
{
    [self restoreTextName:_lblSearch textField:_txtSearch];
    if ([self.delegate respondsToSelector:@selector(btnGroupProjectClicked:)])
        [self.delegate btnGroupProjectClicked:sender];
}

- (void)btnGroupDepartmentClicked:(id)sender
{
    [self restoreTextName:_lblSearch textField:_txtSearch];
    if ([self.delegate respondsToSelector:@selector(btnGroupDepartmentClicked:)])
        [self.delegate btnGroupDepartmentClicked:sender];
}

- (void)tableViewCellDidClicked:(UITableView*)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self restoreTextName:_lblSearch textField:_txtSearch];
    if ([self.delegate respondsToSelector:@selector(tableViewCellDidClicked:didSelectRowAtIndexPath:)])
        [self.delegate tableViewCellDidClicked:tableView didSelectRowAtIndexPath:indexPath];
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
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellId = @"MainTableViewCellIdentitifer";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    if (cell == nil){
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
        
    }
    
    for(UIView *view in cell.contentView.subviews) {
        [view removeFromSuperview];
    }
    
    NSArray* rowsArray = [_rows objectAtIndex:indexPath.section];
    
    Member* ms = [rowsArray objectAtIndex:indexPath.row];
    
    CGFloat x = 12;

    UIImageView* photoImageView = [[UIImageView alloc] initWithFrame:CGRectMake(x, 12, 36, 36)];
    //photoImageView.image = [UIImage imageNamed:@"icon_chengyuan"];
    [photoImageView setImageWithURL:[NSURL URLWithString:ms.img] placeholderImage:[UIImage imageNamed:@"icon_chengyuan"] options:SDWebImageDelayPlaceholder usingActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    
    UILabel* name = [[UILabel alloc] initWithFrame:CGRectMake(x + 36 + 6, 15, 150, 30)];
    name.textColor = [UIColor whiteColor];
    name.textAlignment = NSTextAlignmentLeft;
    name.text = ms.name;
    name.font = [UIFont systemFontOfSize:15];
    
    if (cell.contentView.subviews.count < 2) {
        [cell.contentView addSubview:photoImageView];
        [cell.contentView addSubview:name];
    }

    
    //[cell.contentView setBackgroundColor:[UIColor colorWithRed:0.15f green:0.15f blue:0.15f alpha:1.0f]];
    cell.backgroundColor = [UIColor blackColor];
    [cell.contentView setBackgroundColor:[UIColor clearColor]];
    
    UILabel* bottomLine = [[UILabel alloc] initWithFrame:CGRectMake(0, 59.5,  [UIScreen mainScreen].bounds.size.width, 0.5)];
    [bottomLine setBackgroundColor:[UIColor grayColor]];
    [cell.contentView addSubview:bottomLine];
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self restoreTextName:_lblSearch textField:_txtSearch];
    
    
    [self tableViewCellDidClicked:tableView didSelectRowAtIndexPath:indexPath];

    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = (UITableViewCell *)[tableView cellForRowAtIndexPath:indexPath];
    UIView *selectionColor = [[UIView alloc] init];
    selectionColor.backgroundColor = [UIColor cellHoverBackgroundColor];
    cell.selectedBackgroundView = selectionColor;
    
    return YES;
}

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
    myView.backgroundColor = [UIColor colorWithHexString:@"#2d4778"];
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(5, 2, 90, 15)];
    titleLabel.textColor=[UIColor whiteColor];
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.text=_sections[section];
    [titleLabel setFont:[UIFont systemFontOfSize:10]];
    [myView addSubview:titleLabel];
    
    return myView;
}



@end
