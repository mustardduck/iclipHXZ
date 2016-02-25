//
//  WorkPlanEditController.m
//  CommonFrame_Pro
//
//  Created by 倩 莫 on 15/12/29.
//  Copyright © 2015年 ionitech. All rights reserved.
//

#import "WorkPlanEditMainController.h"
#import "UICommon.h"
#import "WorkPlanMainCell.h"
#import "Mission.h"
#import "WorkPlanAddMissionController.h"
#import "MQworkGroupSelectVC.h"
#import "MQworkTimeSelectVC.h"
#import "NSDate+DateTools.h"
#import "WorkPlanTime.h"
#import "SVProgressHUD.h"
#import "ICSettingGroupViewController.h"
#import "ICWorkingDetailViewController.h"
#import "MQSettingGroupVC.h"
#import "WorkPlanMainSelectCell.h"
#import "MQPublishMissionController.h"

@interface WorkPlanEditMainController ()<UITableViewDataSource, UITableViewDelegate, MQworkGroupSelectDelegate, MQworkTimeSelectDelegate, UIAlertViewDelegate, UITextFieldDelegate>
{
    NSArray * _tags;
    
    BOOL _statusLayoutShow;
    
    MQworkGroupSelectVC * _MQworkGroupSelectVC;
    MQworkTimeSelectVC * _MQworkTimeSelectVC;
    
    IBOutlet UIView*      _leftMenuView;
    IBOutlet UIView*      _rightpMenuView;
    
    UILabel  *  _workGroupNameLbl;
    UIButton *  _groupBtn;
    
    UILabel  *  _timeLbl;
    UIButton *  _timeBtn;
    UIButton *  _layoutBtn;
    
    UILabel * _titleLeftLbl;
    
    WorkPlanTime * _selectedWPT;
    
    NSString * _labelIdStr;
    
    UITextField * _currentField;
    
    UIView * _settingView;
    UIButton * _settBtn;
    UIButton * _doneBtn;
    
    NSString * _currentLabelId;
}

@property (weak, nonatomic) IBOutlet UITableView *mainTableView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *leftViewWidthCons;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *rightViewWidthCons;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *rightBarBtnItem;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *leftViewHeightCons;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *rightViewHeightCons;

@end

@implementation WorkPlanEditMainController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    if(!_selectedIndexList)
    {
        _selectedIndexList = [[NSMutableArray alloc] init];
    }
    
    //注册键盘通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidShow:) name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textChanged:) name:UITextFieldTextDidChangeNotification object:nil];
    
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
    UIBarButtonItem *leftBarButton = [[UIBarButtonItem alloc]initWithCustomView:leftButton];
    self.navigationItem.leftBarButtonItem = leftBarButton;
    
    NSDate * nowDate = [NSDate date];

    UIView * tView = [self layoutTopView];
    
//    [self initGroupSelectView];
    
    [self initTimeSelectView:nowDate];
    
    [self setTopView:tView];
    
    _rightBarBtnItem.enabled = _selectedIndexList.count;
    
    [self initSettingView];
    
}

- (void) initSettingView
{
    _settingView = [[UIView alloc] initWithFrame:CGRectMake(0, 375, SCREENWIDTH, 44)];
    _settingView.backgroundColor = RGBCOLOR(240, 241, 243);
    _settingView.tag = 1000;
    
    _settBtn = [[UIButton alloc] initWithFrame:CGRectMake(14 - 22, 0, 160, H(_settingView))];
    _settBtn.backgroundColor = [UIColor clearColor];
    [_settBtn setTitleColor:[UIColor qitaBackColor] forState:UIControlStateNormal];
    [_settBtn setTitle:@"设置负责人、时间" forState:UIControlStateNormal];
    _settBtn.titleLabel.font = Font(15);
    _settBtn.titleLabel.textAlignment = NSTextAlignmentLeft;
    
    [_settBtn addTarget:self action:@selector(rightBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    [_settingView addSubview:_settBtn];
    
    _doneBtn = [[UIButton alloc] initWithFrame:CGRectMake(SCREENWIDTH - 56, 0, 56, H(_settingView))];
    _doneBtn.backgroundColor = [UIColor clearColor];
    [_doneBtn setTitleColor:[UIColor blueTextColor] forState:UIControlStateNormal];
    [_doneBtn setTitle:@"完成" forState:UIControlStateNormal];
    _doneBtn.titleLabel.font = Font(15);
    [_doneBtn addTarget:self action:@selector(hiddenKeyboard) forControlEvents:UIControlEventTouchUpInside];
    [_settingView addSubview:_doneBtn];
    
    [self.view addSubview:_settingView];
    _settingView.hidden = YES;
}

- (void) dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UITextFieldTextDidChangeNotification object:nil];
}


-(void)keyboardWillHide:(NSNotification *)notification
{
    _settingView.hidden = YES;
}

-(void)keyboardDidShow:(NSNotification *)notification
{
    //获取键盘高度
    
    NSValue *keyboardObject = [[notification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey];
    
    CGRect keyboardRect;
    
    [keyboardObject getValue:&keyboardRect];
    
    
    //调整放置有textView的view的位置

    //设置动画
//    [UIView beginAnimations:nil context:nil];
    
    
    //定义动画时间
    
//    [UIView setAnimationDuration:1];
    
    //设置view的frame，往上平移
    
    CGFloat kViewHeight = 44;
    
    _settingView.hidden = NO;
    
    [_settingView setFrame:CGRectMake(0, self.view.frame.size.height-keyboardRect.size.height- kViewHeight, SCREENWIDTH, kViewHeight)];
}


/*
- (void) addInputAcceToKeyboard:(UIView *)activeView
{
    //定义完成按钮
    _topView = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, SCREENWIDTH, 44)];
    [_topView setBarStyle:UIBarStyleBlack];
    [_topView setBarTintColor:RGBCOLOR(240, 241, 243)];
    
//    //设置整个项目的item状态
//    UIBarButtonItem *item = [UIBarButtonItem appearance];
//    
//    //设置item普通状态
//    NSMutableDictionary *attrs = [NSMutableDictionary dictionary];
//    attrs[NSFontAttributeName] = Font(15);
//    attrs[NSForegroundColorAttributeName] = [UIColor blueTextColor];
//    [item setTitleTextAttributes:attrs forState:UIControlStateNormal];
//    
//    //设置item不可用状态
//    NSMutableDictionary *disabledAttrs = [NSMutableDictionary dictionary];
//    disabledAttrs[NSFontAttributeName] = Font(15);
//    disabledAttrs[NSForegroundColorAttributeName] = [UIColor qitaBackColor];
//    [item setTitleTextAttributes:disabledAttrs forState:UIControlStateDisabled];

    
    _settingBtn = [[UIBarButtonItem alloc] initWithTitle:@"设置负责人、时间" style:UIBarButtonItemStyleDone target:self action:@selector(rightBtnClicked:)];
    _settingBtn.enabled = NO;
    _settingBtn.tintColor = [UIColor blueTextColor];
    
    UIBarButtonItem * button2 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem: UIBarButtonSystemItemFlexibleSpace target:self action:nil];
    
    _doneButton = [[UIBarButtonItem alloc] initWithTitle:@"完成" style:UIBarButtonItemStyleDone target:self action:@selector(hiddenKeyboard)];
    _doneButton.tintColor = [UIColor blueTextColor];
    
    
    NSArray * buttonsArray = [NSArray arrayWithObjects:_settingBtn, button2, _doneButton, nil];
    
    [_topView setItems:buttonsArray];
    
    if([activeView isKindOfClass:[UITextField class]])
    {
        UITextField * text = (UITextField *)activeView;
        
        [text setInputAccessoryView:_topView];
    }
}
 */

- (void)textChanged:(id)sender
{
    UITextField * txtField = (UITextField *)[sender object];
    
    if(txtField.text.length)
    {
        _settBtn.enabled = YES;
        [_settBtn setTitleColor:[UIColor blueTextColor] forState:UIControlStateNormal];
    }
    else
    {
        _settBtn.enabled = NO;
        [_settBtn setTitleColor:[UIColor qitaBackColor] forState:UIControlStateNormal];
    }
}


- (void) textFieldDidBeginEditing:(UITextField *)textField
{
    UITextField * txt = (UITextField *)textField;
    
    UITableView *  mTableView =(UITableView *) [[[[[txt superview] superview] superview] superview] superview];
    UITableViewCell *  cell = (UITableViewCell *)[[[txt superview] superview] superview];
    NSIndexPath * indexPath = [mTableView indexPathForCell:cell];
    
    if(cell)
    {
        UIView * addView = (UIView *) [cell viewWithTag:101 + indexPath.row];
        if(addView)
        {
            addView.hidden = YES;
            
            UITextField * txtField = (UITextField *) [cell viewWithTag:100 + indexPath.row];
            if(txtField)
            {
                [txtField becomeFirstResponder];
                
                _currentField = txtField;
                
//                [_currentField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventValueChanged];
                
                [_mainTableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionNone animated:YES];
                
            }
        }
    }

}

- (UIView *)layoutTopView
{
    UIView * topView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREENWIDTH, 44)];
    /*
    _groupBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, SCREENWIDTH / 2, 44)];
    _groupBtn.backgroundColor = [UIColor grayMarkColor];
    [_groupBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_groupBtn setContentHorizontalAlignment:UIControlContentHorizontalAlignmentRight];
    [_groupBtn addTarget:self action:@selector(groupBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    [_groupBtn setImage:[UIImage imageNamed:@"btn_jiantou_up"] forState:UIControlStateNormal];
    
    //    [_groupBtn setImage:[UIImage imageNamed:@"btn_jiantou_2"] forState:UIControlStateNormal];
    [_groupBtn setImageEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 10)];
    
    [topView addSubview:_groupBtn];
    
    UIView * line = [[UIView alloc] initWithFrame:CGRectMake(SCREENWIDTH / 2, 7, 1, 30)];
    line.backgroundColor = [UIColor grayLineColor];
    [topView addSubview:line];
     
    
    UILabel * userNameLbl = [[UILabel alloc] initWithFrame:CGRectMake( X(line) - 28 - 46, 0, 46, 44)];
    userNameLbl.backgroundColor = [UIColor clearColor];
    userNameLbl.font = Font(15);
    userNameLbl.textColor = [UIColor whiteColor];
    userNameLbl.textAlignment = NSTextAlignmentCenter;
    userNameLbl.text = [LoginUser loginUserName];
    [topView addSubview:userNameLbl];
    
    _workGroupNameLbl = [[UILabel alloc] initWithFrame:CGRectMake(7, 0, X(userNameLbl) - 9 * 2, 44)];
    _workGroupNameLbl.backgroundColor = [UIColor clearColor];
    _workGroupNameLbl.font = Font(15);
    _workGroupNameLbl.textColor = [UIColor whiteColor];
    _workGroupNameLbl.text = _workGroupName;
    _workGroupNameLbl.textAlignment = NSTextAlignmentCenter;
    [topView addSubview:_workGroupNameLbl];
     */
    
    _timeBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, SCREENWIDTH, H(topView))];
    _timeBtn.backgroundColor = RGBCOLOR(47, 47, 47);
    [_timeBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_timeBtn setContentHorizontalAlignment:UIControlContentHorizontalAlignmentRight];
    [_timeBtn setImage:[UIImage imageNamed:@"btn_jiantou_1"] forState:UIControlStateNormal];
    [_timeBtn addTarget:self action:@selector(timeBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    [_timeBtn setImageEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 10)];
    [topView addSubview:_timeBtn];
    
    CGFloat wi = SCREENWIDTH - 146 - 14 - 28;
    
    if(wi < 142)
    {
        wi = 142 - 14;
    }
    UILabel * groupNameLbl = [[UILabel alloc] initWithFrame:CGRectMake(20, 0, wi, H(topView))];
    groupNameLbl.backgroundColor = [UIColor clearColor];
    if(!_isEdit)
    {
        _userName = [LoginUser loginUserName];
    }
    groupNameLbl.text = [NSString stringWithFormat:@"%@   %@",_userName, _workGroupName ];
    groupNameLbl.textColor = [UIColor whiteColor];
    groupNameLbl.font = Font(15);
    [topView addSubview:groupNameLbl];
    
    CGFloat txtWi = [UICommon getSizeFromString:groupNameLbl.text withSize:CGSizeMake(wi, H(groupNameLbl)) withFont:groupNameLbl.font].width;
    
    if(txtWi > 142)
    {
        txtWi = 142 + 20;
    }
    
    groupNameLbl.width = txtWi;
    
    _timeLbl = [[UILabel alloc] initWithFrame:CGRectMake(groupNameLbl.right + 14, 0, 146, H(topView))];
    _timeLbl.backgroundColor = [UIColor clearColor];
    _timeLbl.font = Font(15);
    _timeLbl.textColor = [UIColor blueTextColor];
    [topView addSubview:_timeLbl];
    
    _titleLeftLbl = [[UILabel alloc] initWithFrame:CGRectMake(14, 44, 76, 46)];
    _titleLeftLbl.backgroundColor = [UIColor clearColor];
    _titleLeftLbl.font = Font(15);
    _titleLeftLbl.textColor = [UIColor whiteColor];
    _titleLeftLbl.text = @"主要工作";
    [self.view addSubview:_titleLeftLbl];
    
    _layoutBtn = [[UIButton alloc] initWithFrame:CGRectMake(SCREENWIDTH - 76 - 14, 44, 76, 46)];
    _layoutBtn.backgroundColor = [UIColor clearColor];
    [_layoutBtn setTitleColor:[UIColor blueTextColor] forState:UIControlStateNormal];
    [_layoutBtn setContentHorizontalAlignment:UIControlContentHorizontalAlignmentRight];
    _layoutBtn.titleLabel.font = Font(15);
    [_layoutBtn setTitle:@"状态视图" forState:UIControlStateNormal];
    [_layoutBtn addTarget:self action:@selector(btnLayoutButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:_layoutBtn];
    
    UIView * line = [[UIView alloc] initWithFrame:CGRectMake(0, 43.5, SCREENWIDTH, 0.5)];
    line.backgroundColor = [UIColor grayLineColor];
    [topView addSubview:line];
    
    topView.backgroundColor = [UIColor grayMarkColor];
    
    return topView;
}

- (void) setTopView:(UIView *)topView
{
    [self.view addSubview:topView];
}

- (void) initGroupSelectView
{
    NSArray * groupList = [Group findMeWgListByUserID:[LoginUser loginUserID]];
    
    //    _leftViewWidthCons.constant = SCREENWIDTH / 2;
    _leftViewWidthCons.constant = SCREENWIDTH;
    _leftViewHeightCons.constant = SCREENHEIGHT;
    
    _MQworkGroupSelectVC = [[MQworkGroupSelectVC alloc] initWithMenuNameList:groupList actionControl:_groupBtn parentView:_leftMenuView];//_groupBtn
    _MQworkGroupSelectVC.wgId = _workGroupId;
    _MQworkGroupSelectVC.delegate = self;
    
    
}

- (void) initTimeSelectView:(NSDate *)nowDate
{
    NSArray * timeList = [self getTimeArr:nowDate];
    
    WorkPlanTime * wpt = timeList[0];
    
    if(_isEdit)
    {
        wpt = [UICommon WPTFromStartTime:_startTime andFinishTime:_finishTime];
    }
    
    _selectedWPT = wpt;
    
    NSString * timeStr = @"";
    
    if(wpt.week == 0)
    {
        timeStr = [NSString stringWithFormat:@"无  %ld月  %ld年", wpt.month, wpt.year];
    }
    else
    {
        timeStr = [NSString stringWithFormat:@"第%ld周  %ld月  %ld年", wpt.week, wpt.month, wpt.year];
    }
    
    _timeLbl.text = timeStr;
    
    _rightViewWidthCons.constant = SCREENWIDTH;
    _rightViewHeightCons.constant = SCREENHEIGHT;
    
    _MQworkTimeSelectVC = [[MQworkTimeSelectVC alloc] initWithMenuNameList:timeList actionControl:_timeBtn parentView:_rightpMenuView];
    _MQworkTimeSelectVC.currentWPT = _selectedWPT;
    _MQworkTimeSelectVC.delegate = self;
    
}

- (NSMutableArray * ) getTimeArr:(NSDate *)nowDate
{
    NSMutableArray * timeArr = [NSMutableArray array];
    
    NSLog(@"星期%ld", nowDate.weekday);//1：周天 2：周一 3：周二 4：周三 5：周四 6：周五 7：周六
    
    NSInteger weekday = [UICommon weekday:nowDate];
    
    NSInteger weekdayOrdinal = 1;//第一个星期几
    
    NSDate *newDate = nowDate;
    
    if(weekday == 1)//今天是周一
    {
    }
    else
    {
        newDate = [nowDate dateBySubtractingDays:weekday - 1];//本周的周一
    }
    
    NSDate * fiveYearsLaterDate = [newDate dateByAddingYears:5];
    
    while ([newDate isEarlierThanOrEqualTo:fiveYearsLaterDate]) {
        
        weekdayOrdinal = newDate.weekdayOrdinal;//第几周的周一
        
        if(newDate.day <= newDate.daysInMonth)//小于或等于最后一天
        {
            if(weekdayOrdinal == 1)
            {
                WorkPlanTime *wpt = [WorkPlanTime new];
                wpt.year = newDate.year;
                wpt.month = newDate.month;
                wpt.week = 0;
                [timeArr addObject:wpt];
            }
            
            WorkPlanTime *wpt = [WorkPlanTime new];
            wpt.year = newDate.year;
            wpt.month = newDate.month;
            wpt.week = weekdayOrdinal;
            [timeArr addObject:wpt];
            
            newDate = [newDate dateByAddingWeeks:1];//下一周的周一
            
        }
        
        WorkPlanTime * wop = timeArr[0];
        if(wop.week == 0)
        {
            [timeArr removeObjectAtIndex:0];
        }
    }
    
    WorkPlanTime * wop = timeArr[0];
    
    return timeArr;
}

#pragma -
#pragma Side Menu delegate

- (void)partfarmButtonClicked:(NSString*)val
{
    NSInteger index = [val integerValue];
    if(index == 1)
    {
        if(_timeBtn.tag == 1)
        {
            _timeBtn.tag = 0;
            [_timeBtn setImage:[UIImage imageNamed:@"btn_jiantou_1"] forState:UIControlStateNormal];
        }
        
        if (_MQworkTimeSelectVC.isOpen) {
            
            [_MQworkTimeSelectVC showTopMenu:@"2"];
            _layoutBtn.hidden = NO;
            _titleLeftLbl.hidden = NO;
        }
        if (_MQworkGroupSelectVC.isOpen) {
            
            [_MQworkGroupSelectVC showTopMenu:@"1"];
            _titleLeftLbl.hidden = NO;
        }
        else
        {
            _titleLeftLbl.hidden = YES;
            _MQworkGroupSelectVC.isOpen = NO;
            [_MQworkGroupSelectVC showTopMenu:@"1"];
        }
    }
    if(index == 2)
    {
        if(_groupBtn.tag == 1)
        {
            _groupBtn.tag = 0;
            [_groupBtn setImage:[UIImage imageNamed:@"btn_jiantou_up"] forState:UIControlStateNormal];
        }
        
        if (_MQworkGroupSelectVC.isOpen) {
            
            [_MQworkGroupSelectVC showTopMenu:@"1"];
            _titleLeftLbl.hidden = NO;
        }
        if (_MQworkTimeSelectVC.isOpen) {
            
            [_MQworkTimeSelectVC showTopMenu:@"2"];
            _layoutBtn.hidden = NO;
            _titleLeftLbl.hidden = NO;
        }
        else
        {
            _layoutBtn.hidden = YES;
            _titleLeftLbl.hidden = YES;

            _MQworkTimeSelectVC.isOpen = NO;
            [_MQworkTimeSelectVC showTopMenu:@"2"];
        }
    }
}

- (void) viewWillDisappear:(BOOL)animated
{
    if ([self.icDetailViewController respondsToSelector:@selector(setContent:)]) {
        [self.icDetailViewController setValue:@"1" forKey:@"content"];
    }
    
    if ([self.icMainVC respondsToSelector:@selector(setIsNotRefreshMain:)]) {
        [self.icMainVC setValue:@"1" forKey:@"isNotRefreshMain"];
    }
}


- (void) viewWillAppear:(BOOL)animated
{
    _settBtn.enabled = NO;
    [_settBtn setTitleColor:[UIColor qitaBackColor] forState:UIControlStateNormal];
    
    _tags = [Group findUserMainLabel:[LoginUser loginUserID] workGroupId:_workGroupId];
    _labelIdStr = @"";
    
    for(int i = 0; i < _tags.count; i ++)
    {
        Mark * ma = _tags[i];
        _labelIdStr = [_labelIdStr stringByAppendingString:[NSString stringWithFormat:@"%@,",ma.labelId]];
    }
    
    if(_labelIdStr.length > 1)
    {
        _labelIdStr = [_labelIdStr substringToIndex:_labelIdStr.length - 1];
    }
    
    if(_tags.count)
    {
        if(!_isEdit)
        {
            _taskId = @"0";
        }
        _rows = [Group findUserMainLabelTask:[LoginUser loginUserID] workGroupId:_workGroupId labelId:_labelIdStr taskId:_taskId];
        
        [_mainTableView reloadData];
    }
    else
    {
        [self showAlertView];

    }
}

- (IBAction)groupBtnClicked:(id)sender
{
    if(_groupBtn.tag != 1)
    {
        _groupBtn.tag = 1;
        [_groupBtn setImage:[UIImage imageNamed:@"btn_jiantou_2"] forState:UIControlStateNormal];
    }
    else
    {
        _groupBtn.tag = 0;
        [_groupBtn setImage:[UIImage imageNamed:@"btn_jiantou_up"] forState:UIControlStateNormal];
        
    }
}

- (IBAction)timeBtnClicked:(id)sender
{
    if(_timeBtn.tag != 1)
    {
        _timeBtn.tag = 1;
        [_timeBtn setImage:[UIImage imageNamed:@"btn_jiantou_2"] forState:UIControlStateNormal];
    }
    else
    {
        _timeBtn.tag = 0;
        [_timeBtn setImage:[UIImage imageNamed:@"btn_jiantou_1"] forState:UIControlStateNormal];
        
    }
    
    [_MQworkTimeSelectVC.mainTableView reloadData];
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
    NSMutableArray * arr = [NSMutableArray array];
    
    [arr addObjectsFromArray:_rows];
    
    for(int i = 0; i < arr.count; i ++)
    {
        NSDictionary * dic = arr[i];
        
        NSNumber * num = [NSNumber numberWithInteger:[[dic allKeys][1] integerValue]];
        
        NSMutableArray * keyArr = [NSMutableArray array];
        
        for(Mission * mi in _selectedIndexList)
        {
            if(mi.labelId == num)
            {
                [keyArr addObject:mi];
            }
        }
        
        NSMutableDictionary * ddic = [NSMutableDictionary dictionary];
        
        [ddic setObject:[dic objectForKey:@"label"] forKey:@"label"];
        [ddic setObject:keyArr forKey:num];
        
        [arr replaceObjectAtIndex:i withObject:ddic];
        
    }

    
    [SVProgressHUD showWithStatus:@"工作计划发布中..."];
    
    NSMutableArray * taskList = [NSMutableArray array];
    
    for(NSDictionary * dic in arr)
    {
        NSMutableDictionary * taskDic = [NSMutableDictionary dictionary];
        
        NSNumber *num = [NSNumber numberWithInteger:[[dic allKeys][1] integerValue]];
        
        NSArray * nArr = [dic objectForKey:num];
        
        NSMutableArray * taskArr = [NSMutableArray array];
        
        for(Mission * mi in nArr)
        {
            NSMutableDictionary * mdic = [NSMutableDictionary dictionary];
            
            [mdic setObject:mi.taskId forKey:@"taskId"];
            [mdic setObject:mi.labelId forKey:@"labelId"];
            [mdic setObject:@"" forKey:@"reason"];
            
            [taskArr addObject:mdic];
        }
        
        if(taskArr.count)
        {
            [taskDic setObject:[NSString stringWithFormat:@"%ld", [[dic allKeys][1] integerValue]] forKey:@"labelId"];
            
            [taskDic setObject:taskArr forKey:@"taskReasonList"];
            
        }
        
        if(taskDic.allKeys.count)
        {
            [taskList addObject:taskDic];
        }
    }
    
    NSString * title = @"";
    
    if(_selectedWPT.week == 0)
    {
        title = [NSString stringWithFormat:@"%ld年%ld月工作计划", _selectedWPT.year, _selectedWPT.month];
    }
    else
    {
        title = [NSString stringWithFormat:@"%ld年%ld月第%ld周工作计划", _selectedWPT.year, _selectedWPT.month, _selectedWPT.week];
        
    }
    
    NSDate * selectedStartDate = [UICommon mondayDateFromWPT:_selectedWPT];
    NSDate * selectedFinishDate = [UICommon weekendDateFromWPT:_selectedWPT];
    
    NSString * startTime = [UICommon stringFromDate:selectedStartDate];
    NSString * finishTime = [UICommon stringFromDate:selectedFinishDate];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        BOOL isOk;
        
        if(_isEdit)
        {
            isOk = [Mission updateWorkPlan:[LoginUser loginUserID] taskId:_taskId workGroupId:_workGroupId workPlanTitle:title startTime:startTime finishTime:finishTime taskList:taskList andType:@"4"];
        }
        else
        {
            isOk = [Mission createWorkPlan:[LoginUser loginUserID] workGroupId:_workGroupId workPlanTitle:title startTime:startTime finishTime:finishTime taskList:taskList];
        }
        
        if(isOk)
        {
            [SVProgressHUD showSuccessWithStatus:@"工作计划发布成功"];
            
            [self.navigationController popViewControllerAnimated:YES];
        }
        else
        {
            [SVProgressHUD showErrorWithStatus:@"发布工作计划失败"];
        }
        
    });
    
}

- (void)selectBtnClick:(id)sender
{
    UIButton * btn = (UIButton *)sender;
    
    UITableView *  mTableView = (UITableView *)[[[[btn superview] superview] superview] superview];
    UITableViewCell *  cell = (UITableViewCell *)[[btn superview] superview];
    NSIndexPath * indexPath = [mTableView indexPathForCell:cell];
    
    for (UIControl* control in cell.contentView.subviews) {
        if (control.tag == 1010) {
            UIImageView* img = (UIImageView*)control;
            img.tag = 1011;
            img.image = [UIImage imageNamed:@"btn_gou"];
            [self addIndexPathToSelectArray:indexPath];
            break;
        }
        else if (control.tag == 1011)
        {
            UIImageView* img = (UIImageView*)control;
            img.tag = 1010;
            img.image = [UIImage imageNamed:@"btn_kuang"];
            [self removeIndexPathFromSelectArray:indexPath];
            break;
        }
    }
}

- (void)jumpBtnClick:(id)sender
{
    UIButton * btn = (UIButton *)sender;
    
    UITableView *  mTableView = (UITableView *)[[[[btn superview] superview] superview] superview];
    UITableViewCell *  cell = (UITableViewCell *)[[btn superview] superview];
    NSIndexPath * indexPath = [mTableView indexPathForCell:cell];
    
    NSNumber * numKey = [NSNumber numberWithInteger:[[[_rows[indexPath.section] valueForKey:@"label"] valueForKey:@"labelId"] integerValue]];
    
    NSArray * arr = [_rows[indexPath.section] objectForKey:numKey];
    
    if(arr.count)
    {
        Mission * ms = arr[indexPath.row];
        
        UIStoryboard* mainStory = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        UIViewController* vc = [mainStory instantiateViewControllerWithIdentifier:@"ICWorkingDetailViewController"];
        ((ICWorkingDetailViewController*)vc).taskId = ms.taskId;
        ((ICWorkingDetailViewController*)vc).workGroupId = _workGroupId;
        
        [self.navigationController pushViewController:vc animated:YES];
    }
    
}

- (IBAction)btnLayoutButtonClicked:(id)sender
{
    if(!_statusLayoutShow)
    {
        _statusLayoutShow = YES;
        [_layoutBtn setTitle:@"简易视图" forState:UIControlStateNormal];
    }
    else
    {
        _statusLayoutShow = NO;
        [_layoutBtn setTitle:@"状态视图" forState:UIControlStateNormal];
    }
    
    [_mainTableView reloadData];
}

- (void)addIndexPathToSelectArray:(NSIndexPath*)indexPath
{
    NSInteger row = indexPath.row;
    
    BOOL isEx = NO;
    
    NSString * labId = [[_rows[indexPath.section] valueForKey:@"label"] valueForKey:@"labelId"];
    
    NSNumber * numKey = [NSNumber numberWithInteger:[labId integerValue]];
    
    Mission* mi = [_rows[indexPath.section] objectForKey:numKey][row];
    mi.labelId = numKey;
    
    if (_selectedIndexList.count > 0) {
        for (Mission* ip in _selectedIndexList) {
            if (ip.taskId == mi.taskId && ip.labelId == mi.labelId) {
                isEx = YES;
                break;
            }
        }
        if (!isEx) {
            [_selectedIndexList addObject:mi];
        }
    }
    else{
        [_selectedIndexList addObject:mi];
    }
    
    if(_selectedIndexList.count)
    {
        _rightBarBtnItem.enabled = YES;
    }
    else
    {
        _rightBarBtnItem.enabled = NO;
    }
}

- (void)removeIndexPathFromSelectArray:(NSIndexPath*)indexPath
{
    NSInteger row = indexPath.row;
    
    NSNumber * numKey = [NSNumber numberWithInteger:[[[_rows[indexPath.section] valueForKey:@"label"] valueForKey:@"labelId"] integerValue]];
    
    Mission* mi = [_rows[indexPath.section] objectForKey:numKey][row];
    mi.labelId = numKey;
    
    if (_selectedIndexList.count > 0) {
        
        NSMutableArray * selArr = [[NSMutableArray alloc]initWithArray:_selectedIndexList];
        
        for (Mission* ip in selArr) {
            if (ip.taskId == mi.taskId && ip.labelId == mi.labelId) {
                [_selectedIndexList removeObject:ip];
            }
        }
    }
    
    if(_selectedIndexList.count)
    {
        _rightBarBtnItem.enabled = YES;
    }
    else
    {
        _rightBarBtnItem.enabled = NO;
    }
}

- (BOOL)hasExitsInSelectArray:(NSIndexPath*)indexPath
{
    NSInteger row = indexPath.row;
    NSNumber * numKey = [NSNumber numberWithInteger:[[[_rows[indexPath.section] valueForKey:@"label"] valueForKey:@"labelId"] integerValue]];
    
    Mission* mi = [_rows[indexPath.section] objectForKey:numKey][row];
    mi.labelId = numKey;
    BOOL isEx = NO;
    if (_selectedIndexList.count > 0) {
        for (Mission* ip in _selectedIndexList) {
            if (ip.taskId == mi.taskId && ip.labelId == mi.labelId) {
                isEx = YES;
                break;
            }
            
        }
    }
    
    return isEx;
}


- (void) addMissionClicked:(id) sender
{
    UIButton * btn = (UIButton *)sender;
    
    UITableView *  mTableView =(UITableView *) [[[[[[btn superview] superview] superview] superview] superview] superview];
    UITableViewCell *  cell = (UITableViewCell *)[[[[btn superview] superview] superview] superview];
    NSIndexPath * indexPath = [mTableView indexPathForCell:cell];
    
    if(cell)
    {
        UIView * addView = (UIView *) [cell viewWithTag:101 + indexPath.row];
        if(addView)
        {
            addView.hidden = YES;
            
            UITextField * txtField = (UITextField *) [cell viewWithTag:100 + indexPath.row];
            if(txtField)
            {
                [txtField becomeFirstResponder];
                
                _currentField = txtField;
                
                NSDictionary * titleDic = [_rows[indexPath.section] objectForKey:@"label"];
                
                _currentLabelId = [titleDic valueForKey:@"labelId"];
                
                [_mainTableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionTop animated:YES];
                
            }
        }
    }
    
}

- (void) rightBtnClicked:(id) sender
{
    UIStoryboard* mainStory = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    
    UIViewController* vc = [mainStory instantiateViewControllerWithIdentifier:@"MQPublishMissionController"];
    ((MQPublishMissionController*)vc).workGroupId = _workGroupId;
    ((MQPublishMissionController*)vc).workGroupName = _workGroupName;
    
    ((MQPublishMissionController*)vc).userId = [LoginUser loginUserID];
    ((MQPublishMissionController*)vc).titleName = _currentField.text;
    
    ((MQPublishMissionController*)vc).isMainMission = NO;
    
    ((MQPublishMissionController*)vc).isEditMission = NO;//新增主任务
    ((MQPublishMissionController*)vc).isFromWorkPlanToCreateMission = YES;
    
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)didSelectGroup:(Group*)group
{
    if(_groupBtn.tag == 1)
    {
        _groupBtn.tag = 0;
        [_groupBtn setImage:[UIImage imageNamed:@"btn_jiantou_up"] forState:UIControlStateNormal];
    }
    
    _currentGroup = group;
    
    _workGroupNameLbl.text = group.workGroupName;
    
    _workGroupName = group.workGroupName;
    _workGroupId = group.workGroupId;
    
    _rows = nil;
    
    _rightBarBtnItem.enabled = NO;
    _titleLeftLbl.hidden = NO;
    
    _tags = [Group findUserMainLabel:[LoginUser loginUserID] workGroupId:_workGroupId];
    
    _labelIdStr = @"";
    
    for(int i = 0; i < _tags.count; i ++)
    {
        Mark * ma = _tags[i];
        _labelIdStr = [_labelIdStr stringByAppendingString:[NSString stringWithFormat:@"%@,",ma.labelId]];
    }
    
    if(_labelIdStr.length > 1)
    {
        _labelIdStr = [_labelIdStr substringToIndex:_labelIdStr.length - 1];
    }
    
    if(_tags.count)
    {
        //        [self resetRowsEditData];
        [_mainTableView reloadData];
    }
    else
    {
        [self showAlertView];
    }
    
}

- (void) showAlertView
{
    UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"没有主要工作标签"
                                                    message:@"请先去添加!" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"去添加", nil];
    [alert show];
}

- (void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1)
    {
        UIStoryboard* mainStrory = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        UIViewController* controller = [mainStrory instantiateViewControllerWithIdentifier:@"MQSettingGroupVC"];
        ((MQSettingGroupVC*)controller).workGroup = _currentGroup;
        [self.navigationController pushViewController:controller animated:YES];
    }
}

- (void)didSelectTime:(WorkPlanTime *)time
{
    if(_timeBtn.tag == 1)
    {
        _timeBtn.tag = 0;
        [_timeBtn setImage:[UIImage imageNamed:@"btn_jiantou_1"] forState:UIControlStateNormal];
    }
    
    _layoutBtn.hidden = NO;
    _titleLeftLbl.hidden = NO;
    
    NSString * timeStr = @"";
    
    if(time.week == 0)
    {
        timeStr = [NSString stringWithFormat:@"无  %ld月  %ld年", time.month, time.year];
    }
    else
    {
        timeStr = [NSString stringWithFormat:@"第%ld周  %ld月  %ld年", time.week, time.month, time.year];
    }
    
    _timeLbl.text = timeStr;
    
    _selectedWPT = time;
    
}

- (void) hiddenKeyboard
{
    if(_currentField.text.length)
    {
        Mission* m = [Mission new];
        
        m.createUserId = [LoginUser loginUserID];
        m.workGroupId = _workGroupId;
        m.liableUserId = [LoginUser loginUserID];
        m.type = TaskTypeMission;
        m.title = _currentField.text;
        
        m.isLabel = 1;
        NSMutableArray* tAr = [NSMutableArray array];
        
        [tAr addObject:_currentLabelId];
        m.labelList = [NSArray arrayWithArray:tAr];
        
        m.isAccessory = 0;
        
        [SVProgressHUD showWithStatus:@"任务添加中..."];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            NSString * taskId = @"";
            
            BOOL isSendOK = [m sendMissionFromWorkPlan:YES taksId:&taskId];
            
            if (isSendOK) {
                
                [SVProgressHUD showSuccessWithStatus:@"任务添加成功"];
                
                _currentField.text = @"";
                
                [_currentField resignFirstResponder];
                
                _settBtn.enabled = NO;
                [_settBtn setTitleColor:[UIColor qitaBackColor] forState:UIControlStateNormal];
                
                _rows = [Group findUserMainLabelTask:[LoginUser loginUserID] workGroupId:_workGroupId labelId:_labelIdStr taskId:_taskId];
                
                [_mainTableView reloadData];
            }
            else
            {
                [SVProgressHUD showSuccessWithStatus:@"任务添加失败"];
            }
            
        });
    }
    else
    {
        [_currentField resignFirstResponder];
    }
}

#pragma mark -
#pragma mark Table View Action
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(!_statusLayoutShow)
    {
        NSNumber * numKey = [NSNumber numberWithInteger:[[[_rows[indexPath.section] valueForKey:@"label"] valueForKey:@"labelId"] integerValue]];
        
        NSArray * arr = [_rows[indexPath.section] objectForKey:numKey];
        
        if(arr.count)
        {
            if(indexPath.row == arr.count)
            {
                if(indexPath.section == _rows.count - 1)
                {
                    return 70 + 280;
                }
                return 70;
            }
        }
        else
        {
            if(indexPath.section == _rows.count - 1 && indexPath.row == arr.count)
            {
                return 70 + 280;
            }
            return 70;
        }
        
        return 34;
    }
    else
    {
        UITableViewCell *cell = [self tableView:tableView cellForRowAtIndexPath:indexPath];
        if(cell)
        {
            NSNumber * numKey = [NSNumber numberWithInteger:[[[_rows[indexPath.section] valueForKey:@"label"] valueForKey:@"labelId"] integerValue]];
            
            NSArray * arr = [_rows[indexPath.section] objectForKey:numKey];
            
            if(indexPath.section == _rows.count - 1 && indexPath.row == arr.count)
            {
                return cell.frame.size.height + 280;
            }

            return cell.frame.size.height;
        }
    }
    
    return 34;
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return _rows.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSNumber * numKey = [NSNumber numberWithInteger:[[[_rows[section] valueForKey:@"label"] valueForKey:@"labelId"] integerValue]];
    
    NSArray * arr = [_rows[section] objectForKey:numKey];
    
    NSInteger count = [arr count];
    
    count += 1;
    
    return count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 34;
}

- (UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView* myView = [[UIView alloc] init];
    myView.backgroundColor = [UIColor backgroundColor];
    
    UIView * titleView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREENWIDTH, 28)];
    titleView.backgroundColor = [UIColor clearColor];
    [myView addSubview:titleView];
    
    UIImageView * icon = [[UIImageView alloc] initWithFrame:CGRectMake(14, 2, 8, 11)];
    icon.image = [UIImage imageNamed:@"icon_zhuyaogongzu"];
    [titleView addSubview:icon];
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(27, -2, 200, 18)];
    titleLabel.textColor=[UIColor whiteColor];
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.font = Font(15);
    
    NSDictionary * titleDic = [_rows[section] objectForKey:@"label"];
    
    NSDictionary * keydic = _rows[section];
    
    NSNumber *num = [NSNumber numberWithInteger:[[keydic allKeys][1] integerValue]];
    
    NSArray * nArr = [keydic objectForKey:num];
    
    titleLabel.text = [NSString stringWithFormat:@"%@ (%ld)",[titleDic valueForKey:@"labelName"], nArr.count];
    [titleView addSubview:titleLabel];
    
    return myView;
}

- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(!_statusLayoutShow)
    {
        static NSString *cellId = @"WorkPlanMainSelectCell";
        WorkPlanMainSelectCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
        if (cell == nil){
            cell = [[WorkPlanMainSelectCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
        }
        
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        NSNumber * numKey = [NSNumber numberWithInteger:[[[_rows[indexPath.section] valueForKey:@"label"] valueForKey:@"labelId"] integerValue]];
        
        NSArray * arr = [_rows[indexPath.section] objectForKey:numKey];

        if(arr.count)
        {
            if(indexPath.row < arr.count)
            {
                Mission * mis = arr[indexPath.row];
                
                cell.titleLbl.text = [NSString stringWithFormat:@"%ld. %@",indexPath.row + 1, mis.title];
                
                //-3:已超时  -2删除   -1停用   0：未开始 1进行中   2：已完成
                NSString * statusStr = @"未开始";
                
                cell.statusLbl.textColor = [UIColor grayTitleColor];
                
                if(mis.status == 1)
                {
                    statusStr = @"进行中";
                }
                else if (mis.status == 2)
                {
                    statusStr = @"已完成";
                }
                else if (mis.status == -3)
                {
                    statusStr = @"超时";
                    
                    cell.statusLbl.textColor = [UIColor redTextColor];
                }
                
                cell.statusLbl.text = statusStr;
                
                if ([self hasExitsInSelectArray:indexPath])
                {
                    cell.selectIcon.tag = 1011;
                    cell.selectIcon.image = [UIImage imageNamed:@"btn_gou"];
                }
                else
                {
                    cell.selectIcon.tag = 1010;
                    cell.selectIcon.image = [UIImage imageNamed:@"btn_kuang"];
                }
                
                cell.selectIcon.hidden = NO;
                cell.titleLblleftCons.constant = 40;
                cell.icon.hidden = NO;
                cell.statusLbl.hidden = NO;
            }
            else if (indexPath.row == arr.count)
            {
                static NSString *cellId = @"Cell";
                UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
                if (cell == nil){
                    cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
                    cell.frame = CGRectMake(0, 0, SCREENWIDTH, 70);
                }
                
                for(UIView *view in cell.contentView.subviews) {
                    [view removeFromSuperview];
                }
                
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                
                UIView * addMissionView = [[UIView alloc] initWithFrame:CGRectMake(7 + 14, 0, SCREENWIDTH - 7 * 2 - 14 * 2, 44)];
                addMissionView.backgroundColor = [UIColor grayMarkColor];
                [addMissionView setRoundColorCorner:3.3 withColor:[UIColor grayLineColor]];
                
                UIView * addView = [[UIView alloc] initWithFrame:CGRectMake(14, 0, W(addMissionView) - 18, H(addMissionView) )];
                
                addView.backgroundColor = [UIColor grayMarkColor];
                addView.tag = 101 + indexPath.row;
                
                
                UIButton * addBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, W(addView), H(addView))];
                addBtn.backgroundColor = [UIColor clearColor];
                
                [addBtn addTarget:self action:@selector(addMissionClicked:) forControlEvents:UIControlEventTouchUpInside];
                [addView addSubview:addBtn];
                
                UIImageView * addIcon = [[UIImageView alloc] initWithFrame:CGRectMake(0, 15, 14, 14)];
                addIcon.image = [UIImage imageNamed:@"btn_xinjianrenwu"];
                [addView addSubview:addIcon];
                
                UILabel * addLbl = [[UILabel alloc] initWithFrame:CGRectMake(addIcon.right + 7, 0, 100, H(addView))];
                addLbl.backgroundColor = [UIColor clearColor];
                addLbl.text = @"新建任务";
                addLbl.textColor = [UIColor whiteColor];
                addLbl.font = Font(15);
                [addView addSubview:addLbl];
                
                UITextField * txtField = [[UITextField alloc] initWithFrame:CGRectMake(14, 0, W(addMissionView) - 14 - 50, H(addMissionView))];
                txtField.backgroundColor = [UIColor clearColor];
                txtField.font = Font(15);
                txtField.textColor = [UIColor whiteColor];
                txtField.tag = 100 + indexPath.row;
                txtField.placeholder = @"请输入任务名称";
                txtField.delegate = self;
                [txtField setValue:[UIColor grayTitleColor] forKeyPath:@"_placeholderLabel.textColor"];
                
                [addMissionView addSubview:txtField];
                
                UIButton * rightBtn = [[UIButton alloc] initWithFrame:CGRectMake(W(addMissionView) - 50, 0, 50, H(addMissionView))];
                rightBtn.backgroundColor = [UIColor clearColor];
                [rightBtn addTarget:self action:@selector(rightBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
                [addMissionView addSubview:rightBtn];
                
                UIView * line = [[UIView alloc] initWithFrame:CGRectMake(W(addMissionView) - 32, 0, 0.5, H(addMissionView))];
                line.backgroundColor = [UIColor grayLineColor];
                [addMissionView addSubview:line];
                
                UIImageView * rightIcon = [[UIImageView alloc] initWithFrame:CGRectMake(X(line) + 14, 17, 10, 10)];
                rightIcon.image = [UIImage imageNamed:@"btn_jiantou_1"];
                [addMissionView addSubview:rightIcon];
                
                [addMissionView addSubview:addView];

                [cell.contentView addSubview:addMissionView];
                
                cell.contentView.backgroundColor = [UIColor backgroundColor];
                
                return cell;
                
            }
        }
        else
        {
            static NSString *cellId = @"Cell";
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
            if (cell == nil){
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
                cell.frame = CGRectMake(0, 0, SCREENWIDTH, 70);
            }
            
            for(UIView *view in cell.contentView.subviews) {
                [view removeFromSuperview];
            }
            
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            
            UIView * addMissionView = [[UIView alloc] initWithFrame:CGRectMake(7 + 14, 0, SCREENWIDTH - 7 * 2 - 14 * 2, 44)];
            addMissionView.backgroundColor = [UIColor grayMarkColor];
            [addMissionView setRoundColorCorner:3.3 withColor:[UIColor grayLineColor]];
            
            UIView * addView = [[UIView alloc] initWithFrame:CGRectMake(14, 0, W(addMissionView) - 18, H(addMissionView) )];
            
            addView.backgroundColor = [UIColor grayMarkColor];
            addView.tag = 101 + indexPath.row;
            
            
            UIButton * addBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, W(addView), H(addView))];
            addBtn.backgroundColor = [UIColor clearColor];
            
            [addBtn addTarget:self action:@selector(addMissionClicked:) forControlEvents:UIControlEventTouchUpInside];
            [addView addSubview:addBtn];
            
            UIImageView * addIcon = [[UIImageView alloc] initWithFrame:CGRectMake(0, 15, 14, 14)];
            addIcon.image = [UIImage imageNamed:@"btn_xinjianrenwu"];
            [addView addSubview:addIcon];
            
            UILabel * addLbl = [[UILabel alloc] initWithFrame:CGRectMake(addIcon.right + 7, 0, 100, H(addView))];
            addLbl.backgroundColor = [UIColor clearColor];
            addLbl.text = @"新建任务";
            addLbl.textColor = [UIColor whiteColor];
            addLbl.font = Font(15);
            [addView addSubview:addLbl];
            
            UITextField * txtField = [[UITextField alloc] initWithFrame:CGRectMake(14, 0, W(addMissionView) - 14 - 50, H(addMissionView))];
            txtField.backgroundColor = [UIColor clearColor];
            txtField.font = Font(15);
            txtField.textColor = [UIColor whiteColor];
            txtField.tag = 100 + indexPath.row;
            txtField.placeholder = @"请输入任务名称";
            txtField.delegate = self;
            [txtField setValue:[UIColor grayTitleColor] forKeyPath:@"_placeholderLabel.textColor"];
            
            [addMissionView addSubview:txtField];
            
            UIButton * rightBtn = [[UIButton alloc] initWithFrame:CGRectMake(W(addMissionView) - 50, 0, 50, H(addMissionView))];
            rightBtn.backgroundColor = [UIColor clearColor];
            [rightBtn addTarget:self action:@selector(rightBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
            [addMissionView addSubview:rightBtn];
            
            UIView * line = [[UIView alloc] initWithFrame:CGRectMake(W(addMissionView) - 32, 0, 0.5, H(addMissionView))];
            line.backgroundColor = [UIColor grayLineColor];
            [addMissionView addSubview:line];
            
            UIImageView * rightIcon = [[UIImageView alloc] initWithFrame:CGRectMake(X(line) + 14, 17, 10, 10)];
            rightIcon.image = [UIImage imageNamed:@"btn_jiantou_1"];
            [addMissionView addSubview:rightIcon];
            
            [addMissionView addSubview:addView];
            
            [cell.contentView addSubview:addMissionView];
            
            cell.contentView.backgroundColor = [UIColor backgroundColor];
            
            return cell;
            
        }
            /*
        {
            cell.selectIcon.tag = 1012;
            cell.selectIcon.hidden = YES;
            cell.icon.hidden = YES;
            cell.statusLbl.hidden = YES;
            cell.titleLbl.text = @"无";
            
            cell.titleLblleftCons.constant = 14;
        }*/
        
        [cell.selectBtn addTarget:self action:@selector(selectBtnClick:) forControlEvents:UIControlEventTouchUpInside];
        [cell.jumpBtn addTarget:self action:@selector(jumpBtnClick:) forControlEvents:UIControlEventTouchUpInside];
        
        return cell;
    }
    else
    {
        static NSString *cellId = @"Cell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
        if (cell == nil){
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
            cell.frame = CGRectMake(0, 0, SCREENWIDTH, 34);
        }
        
        for(UIView *view in cell.contentView.subviews) {
            [view removeFromSuperview];
        }
        
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        NSNumber * numKey = [NSNumber numberWithInteger:[[[_rows[indexPath.section] valueForKey:@"label"] valueForKey:@"labelId"] integerValue]];
        
        NSArray * misArr = [_rows[indexPath.section] objectForKey:numKey];
        
        if(misArr.count)
        {
            if(indexPath.row < misArr.count)
            {
                Mission * mis = misArr[indexPath.row];
                
                UILabel * titleLbl = [[UILabel alloc] initWithFrame:CGRectMake(40, 0, SCREENWIDTH - 40 - 38, 16)];
                titleLbl.text = [NSString stringWithFormat:@"%ld. %@",indexPath.row + 1, mis.title];
                titleLbl.height = [UICommon getSizeFromString:titleLbl.text withSize:CGSizeMake(SCREENWIDTH - 14 - 38, 70) withFont:Font(14)].height;
                
                if(titleLbl.height > 70)
                {
                    titleLbl.height = 70;
                }
                titleLbl.backgroundColor = [UIColor clearColor];
                titleLbl.textColor = [UIColor whiteColor];
                titleLbl.numberOfLines = 3;
                titleLbl.font = Font(14);
                [cell.contentView addSubview:titleLbl];
                
                UIImageView * icon = [[UIImageView alloc]initWithFrame:CGRectMake(SCREENWIDTH - 14 - 10, 4, 10, 10)];
                icon.image = [UIImage imageNamed:@"btn_jiantou_1"];
                [cell.contentView addSubview:icon];
                
                UIImageView * choseImg = [[UIImageView alloc] initWithFrame:CGRectMake(14, 2, 16, 14)];
                choseImg.image = [UIImage imageNamed:@"btn_kuang"];
                
                if ([self hasExitsInSelectArray:indexPath])
                {
                    choseImg.image = [UIImage imageNamed:@"btn_gou"];
                    choseImg.tag = 1011;
                }
                else
                {
                    choseImg.image = [UIImage imageNamed:@"btn_kuang"];
                    choseImg.tag = 1010;
                }
                
                [cell.contentView addSubview:choseImg];
                
                
                //-3:已超时  -2删除   -1停用   0：未开始 1进行中   2：已完成
                NSString * statusStr = @"未开始";
                
                if(mis.status == 1)
                {
                    statusStr = @"进行中";
                }
                else if (mis.status == 2)
                {
                    statusStr = @"已完成";
                }
                else if (mis.status == -3)
                {
                    statusStr = @"超时";
                    
                }
                
                UILabel * statusLbl = [[UILabel alloc] initWithFrame:CGRectMake(30 + 10, titleLbl.bottom + 7, 54, 24)];
                statusLbl.backgroundColor = [UIColor grayMarkColor];
                [statusLbl setRoundCorner:1.7];
                statusLbl.textColor = [UIColor grayTitleColor];
                statusLbl.font = Font(14);
                statusLbl.textAlignment = NSTextAlignmentCenter;
                statusLbl.text = statusStr;
                
                UILabel * dateLbl = [[UILabel alloc] initWithFrame:CGRectMake(statusLbl.right + 7, titleLbl.bottom + 7, 148, 24)];
                
                dateLbl.backgroundColor = [UIColor grayMarkColor];
                [dateLbl setRoundCorner:1.7];
                dateLbl.textColor = [UIColor grayTitleColor];
                dateLbl.font = Font(14);
                dateLbl.textAlignment = NSTextAlignmentCenter;
                dateLbl.text = [NSString stringWithFormat:@"%@      %@", mis.lableUserName, mis.finishTime];
                
                [cell.contentView addSubview:dateLbl];
                
                if(mis.status != -3)
                {
                    [cell.contentView addSubview:statusLbl];
                }
                else
                {
                    UIView * statusView = [[UIView alloc] initWithFrame:CGRectMake(30 + 10, titleLbl.bottom + 7, 54, 24)];
                    statusView.backgroundColor = [UIColor grayMarkColor];
                    [statusView setRoundCorner:1.7];
                    
                    UIImageView * icon = [[UIImageView alloc] initWithFrame:CGRectMake(7, 7, 9, 9)];
                    icon.image = [UIImage imageNamed:@"icon_chaoshi_hong"];
                    [statusView addSubview:icon];
                    
                    statusLbl.left = icon.right - 8;
                    statusLbl.top = 0;
                    statusLbl.backgroundColor = [UIColor clearColor];
                    statusLbl.textColor = [UIColor redTextColor];
                    [statusView addSubview:statusLbl];
                    
                    [cell.contentView addSubview:statusView];
                    
                    dateLbl.left = statusView.right + 7;
                    
                }
                
                CGFloat he = dateLbl.bottom + 20;
                
                CGRect rect = cell.frame;
                rect.size.height = he;
                cell.frame = rect;
                
                UIButton * selectBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 50, he)];
                selectBtn.backgroundColor = [UIColor clearColor];
                UIButton * jumpBtn = [[UIButton alloc] initWithFrame:CGRectMake(50, 0, SCREENWIDTH, he)];
                jumpBtn.backgroundColor = [UIColor clearColor];
                
                [selectBtn addTarget:self action:@selector(selectBtnClick:) forControlEvents:UIControlEventTouchUpInside];
                [jumpBtn addTarget:self action:@selector(jumpBtnClick:) forControlEvents:UIControlEventTouchUpInside];
                
                [cell.contentView addSubview:selectBtn];
                [cell.contentView addSubview:jumpBtn];
                
                cell.contentView.backgroundColor = [UIColor backgroundColor];
                
                return cell;
            }
            else if (indexPath.row == misArr.count)
            {
                static NSString *cellId = @"Cell";
                UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
                if (cell == nil){
                    cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
                    cell.frame = CGRectMake(0, 0, SCREENWIDTH, 70);
                }
                
                for(UIView *view in cell.contentView.subviews) {
                    [view removeFromSuperview];
                }
                
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                
                UIView * addMissionView = [[UIView alloc] initWithFrame:CGRectMake(7 + 14, 0, SCREENWIDTH - 7 * 2 - 14 * 2, 44)];
                addMissionView.backgroundColor = [UIColor grayMarkColor];
                [addMissionView setRoundColorCorner:3.3 withColor:[UIColor grayLineColor]];
                
                UIView * addView = [[UIView alloc] initWithFrame:CGRectMake(14, 0, W(addMissionView) - 18, H(addMissionView) )];
                
                addView.backgroundColor = [UIColor grayMarkColor];
                addView.tag = 101 + indexPath.row;
                
                
                UIButton * addBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, W(addView), H(addView))];
                addBtn.backgroundColor = [UIColor clearColor];
                
                [addBtn addTarget:self action:@selector(addMissionClicked:) forControlEvents:UIControlEventTouchUpInside];
                [addView addSubview:addBtn];
                
                UIImageView * addIcon = [[UIImageView alloc] initWithFrame:CGRectMake(0, 15, 14, 14)];
                addIcon.image = [UIImage imageNamed:@"btn_xinjianrenwu"];
                [addView addSubview:addIcon];
                
                UILabel * addLbl = [[UILabel alloc] initWithFrame:CGRectMake(addIcon.right + 7, 0, 100, H(addView))];
                addLbl.backgroundColor = [UIColor clearColor];
                addLbl.text = @"新建任务";
                addLbl.textColor = [UIColor whiteColor];
                addLbl.font = Font(15);
                [addView addSubview:addLbl];
                
                UITextField * txtField = [[UITextField alloc] initWithFrame:CGRectMake(14, 0, W(addMissionView) - 14 - 50, H(addMissionView))];
                txtField.backgroundColor = [UIColor clearColor];
                txtField.font = Font(15);
                txtField.textColor = [UIColor whiteColor];
                txtField.tag = 100 + indexPath.row;
                txtField.placeholder = @"请输入任务名称";
                txtField.delegate = self;
                [txtField setValue:[UIColor grayTitleColor] forKeyPath:@"_placeholderLabel.textColor"];
                
                [addMissionView addSubview:txtField];
                
                UIButton * rightBtn = [[UIButton alloc] initWithFrame:CGRectMake(W(addMissionView) - 50, 0, 50, H(addMissionView))];
                rightBtn.backgroundColor = [UIColor clearColor];
                [rightBtn addTarget:self action:@selector(rightBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
                [addMissionView addSubview:rightBtn];
                
                UIView * line = [[UIView alloc] initWithFrame:CGRectMake(W(addMissionView) - 32, 0, 0.5, H(addMissionView))];
                line.backgroundColor = [UIColor grayLineColor];
                [addMissionView addSubview:line];
                
                UIImageView * rightIcon = [[UIImageView alloc] initWithFrame:CGRectMake(X(line) + 14, 17, 10, 10)];
                rightIcon.image = [UIImage imageNamed:@"btn_jiantou_1"];
                [addMissionView addSubview:rightIcon];
                
                [addMissionView addSubview:addView];
                
                [cell.contentView addSubview:addMissionView];
                
                cell.contentView.backgroundColor = [UIColor backgroundColor];
                
                return cell;
                
            }
        }
        else
        {
            static NSString *cellId = @"Cell";
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
            if (cell == nil){
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
                cell.frame = CGRectMake(0, 0, SCREENWIDTH, 70);
            }
            
            for(UIView *view in cell.contentView.subviews) {
                [view removeFromSuperview];
            }
            
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            
            UIView * addMissionView = [[UIView alloc] initWithFrame:CGRectMake(7 + 14, 0, SCREENWIDTH - 7 * 2 - 14 * 2, 44)];
            addMissionView.backgroundColor = [UIColor grayMarkColor];
            [addMissionView setRoundColorCorner:3.3 withColor:[UIColor grayLineColor]];
            
            UIView * addView = [[UIView alloc] initWithFrame:CGRectMake(14, 0, W(addMissionView) - 18, H(addMissionView) )];
            
            addView.backgroundColor = [UIColor grayMarkColor];
            addView.tag = 101 + indexPath.row;
            
            
            UIButton * addBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, W(addView), H(addView))];
            addBtn.backgroundColor = [UIColor clearColor];
            
            [addBtn addTarget:self action:@selector(addMissionClicked:) forControlEvents:UIControlEventTouchUpInside];
            [addView addSubview:addBtn];
            
            UIImageView * addIcon = [[UIImageView alloc] initWithFrame:CGRectMake(0, 15, 14, 14)];
            addIcon.image = [UIImage imageNamed:@"btn_xinjianrenwu"];
            [addView addSubview:addIcon];
            
            UILabel * addLbl = [[UILabel alloc] initWithFrame:CGRectMake(addIcon.right + 7, 0, 100, H(addView))];
            addLbl.backgroundColor = [UIColor clearColor];
            addLbl.text = @"新建任务";
            addLbl.textColor = [UIColor whiteColor];
            addLbl.font = Font(15);
            [addView addSubview:addLbl];
            
            UITextField * txtField = [[UITextField alloc] initWithFrame:CGRectMake(14, 0, W(addMissionView) - 14 - 50, H(addMissionView))];
            txtField.backgroundColor = [UIColor clearColor];
            txtField.font = Font(15);
            txtField.textColor = [UIColor whiteColor];
            txtField.tag = 100 + indexPath.row;
            txtField.placeholder = @"请输入任务名称";
            txtField.delegate = self;
            [txtField setValue:[UIColor grayTitleColor] forKeyPath:@"_placeholderLabel.textColor"];
            
            [addMissionView addSubview:txtField];
            
            UIButton * rightBtn = [[UIButton alloc] initWithFrame:CGRectMake(W(addMissionView) - 50, 0, 50, H(addMissionView))];
            rightBtn.backgroundColor = [UIColor clearColor];
            [rightBtn addTarget:self action:@selector(rightBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
            [addMissionView addSubview:rightBtn];
            
            UIView * line = [[UIView alloc] initWithFrame:CGRectMake(W(addMissionView) - 32, 0, 0.5, H(addMissionView))];
            line.backgroundColor = [UIColor grayLineColor];
            [addMissionView addSubview:line];
            
            UIImageView * rightIcon = [[UIImageView alloc] initWithFrame:CGRectMake(X(line) + 14, 17, 10, 10)];
            rightIcon.image = [UIImage imageNamed:@"btn_jiantou_1"];
            [addMissionView addSubview:rightIcon];
            
            [addMissionView addSubview:addView];
            
            [cell.contentView addSubview:addMissionView];
            
            cell.contentView.backgroundColor = [UIColor backgroundColor];
            
            return cell;
            
        }
        /*{
            UILabel * titleLbl = [[UILabel alloc] initWithFrame:CGRectMake(14, 0, 100, 16)];
            titleLbl.text = @"无";
            titleLbl.backgroundColor = [UIColor clearColor];
            titleLbl.textColor = [UIColor whiteColor];
            titleLbl.font = Font(14);
            [cell.contentView addSubview:titleLbl];
            
            CGRect rect = cell.frame;
            rect.size.height = 34;
            cell.frame = rect;
            
            cell.contentView.backgroundColor = [UIColor backgroundColor];
            
            return cell;
        }*/
        
        return cell;
    }
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    NSInteger count = 0;
    if(_isEdit)
    {
        if(_rows.count)
        {
            count = [[_rows[indexPath.section] objectForKey:@"taskList"] count];
        }
    }
    else
    {
        if(_tags.count)
        {
            Mark * ma = _tags[indexPath.section];
            
            if(_rows.count)
            {
                count = [[_rows[indexPath.section] objectForKey:ma.labelId] count];
            }
        }
        
    }
    
    NSInteger sectionCount = 0;
    
    if(_isEdit)
    {
        sectionCount = _rows.count;
    }
    else
    {
        sectionCount = _tags.count;
    }
    
    if((count == indexPath.row && count > 0) || (indexPath.row == 1 && indexPath.section == sectionCount - 1))
    {
        UIStoryboard* mainStory = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        
        UIViewController* vc = [mainStory instantiateViewControllerWithIdentifier:@"WorkPlanAddMissionController"];
        ((WorkPlanAddMissionController*)vc).workGroupId = _workGroupId;
        ((WorkPlanAddMissionController*)vc).workGroupName = _workGroupName;

        ((WorkPlanAddMissionController*)vc).labelIdStr = _labelIdStr;
        
        NSMutableArray * selectArr = [NSMutableArray array];
        
        for(NSDictionary * dic in _rows)
        {
            NSArray * nArr;
            if(_isEdit)
            {
                nArr = [dic objectForKey:@"taskList"];
            }
            else
            {
                NSNumber *num = [NSNumber numberWithInteger:[[dic allKeys][0] integerValue]];
                nArr = [dic objectForKey:num];
                
            }
            
            [selectArr addObjectsFromArray:nArr];
            
        }
        ((WorkPlanAddMissionController*)vc).selectedIndexList = selectArr;
        ((WorkPlanAddMissionController*)vc).selectedRows = _rows;
        
        ((WorkPlanAddMissionController*)vc).MQPlanEditVC = self;
        ((WorkPlanAddMissionController*)vc).isEdit = _isEdit;
        
        
        [self.navigationController pushViewController:vc animated:YES];
    }
    else
    {
        NSNumber * numKey;
        NSArray * arr;
        if(_isEdit)
        {
            if(_rows.count)
            {
                arr = [_rows[indexPath.section] objectForKey:@"taskList"];
            }
        }
        else
        {
            if(_rows.count)
            {
                numKey = [NSNumber numberWithInteger:[[_rows[indexPath.section] allKeys][0] integerValue]];
                
                arr = [_rows[indexPath.section] objectForKey:numKey];
            }
        }
        
        if(arr.count)
        {
            Mission * ms = arr[indexPath.row];
            
            UIStoryboard* mainStory = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
            UIViewController* vc = [mainStory instantiateViewControllerWithIdentifier:@"ICWorkingDetailViewController"];
            ((ICWorkingDetailViewController*)vc).taskId = ms.taskId;
            ((ICWorkingDetailViewController*)vc).workGroupId = _workGroupId;
            
            [self.navigationController pushViewController:vc animated:YES];
        }
    }
}

@end
