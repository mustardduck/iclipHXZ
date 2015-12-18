//
//  MQPublishMissionController.m
//  CommonFrame_Pro
//
//  Created by 倩 莫 on 15/10/13.
//  Copyright © 2015年 ionitech. All rights reserved.
//

#import "MQPublishMissionController.h"
#import "UICommon.h"
#import "UIImageView+UIActivityIndicatorForSDWebImage.h"
#import "PH_UITextView.h"
#import "ICGroupListViewController.h"
#import "ICMarkListViewController.h"
#import <ZYQAssetPickerController.h>
#import "Mark.h"
#import "Mission.h"
#import "ICFileViewController.h"
#import "AddPicCell66.h"
#import "AddPicCell80.h"
#import "AddPicCell88.h"
#import "MarkCell.h"
#import "MarkTagCell.h"
#import "SVProgressHUD.h"
#import "MQPublishMissionMainController.h"

@interface MQPublishMissionController ()<UICollectionViewDelegate, UICollectionViewDataSource,UIActionSheetDelegate,UIImagePickerControllerDelegate,ZYQAssetPickerControllerDelegate,UITextViewDelegate, UITextFieldDelegate,UINavigationControllerDelegate, UITableViewDataSource, UITableViewDelegate>
{
    UICollectionView *_collectionview;
    NSInteger _deleteIndex;
    NSInteger _currentItem;//选择的某个图片
    
    UIDatePicker*           _datePicker;
    UIView*                 _datePickerView;
    NSMutableArray*         _accessoryArray;
    BOOL                    _btnDoneClicked;
    
    NSString *          _currentFileName;
    
    UITableView*            _tableView;
    
    UICollectionView * _markCollectionView;
    
    UICollectionView * _TagCollView;
    
    NSArray * _markList;
    
    NSMutableArray * _tagList;
    
//    NSMutableArray * _imgUrls;
//    NSMutableArray * _fileUrls;
    
    CGFloat _cellHeight;
    CGFloat _canyuHeight;
    CGFloat _chaosongHeight;
    
    NSMutableArray * _selectedIndexTagArr;
    
    NSString * _responName;
}

@property (weak, nonatomic) IBOutlet UITextField *titleTxt;
@property (weak, nonatomic) IBOutlet PH_UITextView *txtView;
@property (weak, nonatomic) IBOutlet UIView *timeView;
@property (weak, nonatomic) IBOutlet UIButton *jiezhiBtn;
@property (weak, nonatomic) IBOutlet UIButton *tixingBtn;
@property (weak, nonatomic) IBOutlet UIButton *fujianBtn;
@property (weak, nonatomic) IBOutlet UIView *jiezhiAndTixingView;
@property (weak, nonatomic) IBOutlet UIView *jiezhiView;
@property (weak, nonatomic) IBOutlet UIView *tixingView;
@property (weak, nonatomic) IBOutlet UILabel *jiezhiLbl;
@property (weak, nonatomic) IBOutlet UIButton *jiezhiDelBtn;
@property (weak, nonatomic) IBOutlet UILabel *tixingLbl;
@property (weak, nonatomic) IBOutlet UIButton *tixingDelBtn;

//@property (nonatomic, retain) NSMutableArray *pickedUrls;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *JTViewToTxtViewTopCons;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *timeToTxtViewTopCons;
@property (weak, nonatomic) IBOutlet UIScrollView *mainScrollView;
@property (weak, nonatomic) IBOutlet UIView *mainView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *mainViewHeightCons;

@end

@implementation MQPublishMissionController


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
    
    [self.view setBackgroundColor:[UIColor backgroundColor]];

    [self.mainScrollView setDelaysContentTouches:NO];
    
    [self setTextViewStyle];
    
    [self _initPstCollectionView];
    
    [self initMarkCollectionView];
    
    [self initTagCollectionView];
    
    [self initTableView];
    
    self.isShowAllSection = _workGroupName ? YES : NO;
    
    if(!_cAccessoryArray.count)
    {
        self.cAccessoryArray = [NSMutableArray array];
    }
    
    if(!_cMarkAarry)
    {
        self.cMarkAarry = [NSMutableArray array];
    }
    
    [_jiezhiView setRoundCorner:3.3];
    [_tixingView setRoundCorner:3.3];
    
    [self resetData];
    
}

- (void) resetData
{
    if(_missionDic)
    {
        _currentMissionDic = [_missionDic objectForKey:@"missionDic"];
        
        if(_currentMissionDic)
        {
            _titleTxt.text = [_currentMissionDic valueForKey:@"title"];
            
            _txtView.text = [_currentMissionDic valueForKey:@"main"];
            
            NSString * finishTimeStr = [_currentMissionDic valueForKey:@"finishTime"];
            NSString * remindTimeStr = [_currentMissionDic valueForKey:@"remindTime"];
            
            if(finishTimeStr.length)
            {
                self.strFinishTime = finishTimeStr;
                
                NSString * finishDateStr = [UICommon dayAndHourFromString:finishTimeStr formatStyle:@"yyyy年MM月dd日"];
                
                _jiezhiAndTixingView.hidden = NO;
                _jiezhiView.hidden = NO;
                _jiezhiLbl.text = [NSString stringWithFormat:@"截止时间：%@", finishDateStr];
            }
            if(remindTimeStr.length)
            {
                self.strRemindTime = remindTimeStr;
                
                NSString * remindDateStr = [UICommon dayAndHourFromString:remindTimeStr formatStyle:@"yyyy年MM月dd日 HH:mm"];
                
                _jiezhiAndTixingView.hidden = NO;
                _tixingView.hidden = NO;
                _tixingLbl.text = [NSString stringWithFormat:@"提醒时间：%@", remindDateStr];

            }
            
            self.cAccessoryArray = [_currentMissionDic objectForKey:@"accesList"];
            
            if (self.cAccessoryArray.count)
            {//附件
                _collectionview.hidden = NO;
                
                //            [self resetFileUrls];
                
                [self refreshCollectionView];
            }
            
            self.cMarkAarry = [_currentMissionDic objectForKey:@"cMarkList"];
            
            self.responsibleDic = [_currentMissionDic objectForKey:@"respoDic"];
            
            Member * m = _responsibleDic[0];
            
            if(!m.img && _lableUserImg)
            {
                m.img = _lableUserImg;
                
                NSMutableArray * reArr = [NSMutableArray array];
                
                [reArr addObject:m];
                
                self.responsibleDic = reArr;
            }

            self.participantsIndexPathArray = [_currentMissionDic objectForKey:@"partiArr"];
            self.ccopyToMembersArray = [_currentMissionDic objectForKey:@"ccopyArr"];
            
            [self resetAllViewLayout:_jiezhiAndTixingView];
        }
        else
        {
            _titleTxt.text = [_missionDic valueForKey:@"title"];
        }
    }
    else if(_isEditMission && _taskId)
    {
        _missionDic = [Mission missionInfo:_taskId];
        
        [self resetData];
    }
}

- (void) initTableView
{
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, _timeView.bottom, SCREENWIDTH, 390)];
    _tableView.backgroundColor = [UIColor backgroundColor];
    _tableView.dataSource = self;
    _tableView.delegate = self;
    _tableView.tag = 101;
    [_tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    _tableView.scrollEnabled = NO;
    [self.mainView addSubview:_tableView];
    
//    _tableView.hidden = YES;

}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];

    if(!_markList.count)
    {
        if(_workGroupId)
        {
            _markList = [Mark getMarkListByWorkGroupID:self.workGroupId loginUserID:self.userId andUrl:ME_LABEL_CURL];
        }
    }
    else if (_isRefreshMarkData && _workGroupId)
    {
        _markList = [Mark getMarkListByWorkGroupID:self.workGroupId loginUserID:self.userId andUrl:ME_LABEL_CURL];
        
        [_markCollectionView reloadData];
        
        self.isRefreshMarkData = NO;
    }
    
    if(_cMarkAarry.count)
    {
        if(!_selectedIndexTagArr)
        {
            _selectedIndexTagArr = [NSMutableArray array];
        }
        
        [_tagList removeAllObjects];
        [_selectedIndexTagArr removeAllObjects];
        
        for(NSInteger index = 0; index < _markList.count; index ++)
        {
            Mark * ma = _markList[index];
            for (Mark * markId in _cMarkAarry)
            {
                if(ma.labelId == markId.labelId)
                {
                    NSNumber * num = [NSNumber numberWithInteger:index];
                    
                    if(![_selectedIndexTagArr containsObject:num])
                    {
                        [_tagList addObject:ma];
                        
                        [_selectedIndexTagArr addObject:num];
                    }
                }
            }
        }
        
        [self refreshTagCollView];
        
        [_markCollectionView reloadData];
    }
    else if (_isChangeGroup)
    {
        if(!_cMarkAarry.count)
        {
            [_selectedIndexTagArr removeAllObjects];
            
            [_tagList removeAllObjects];
            
            [self refreshTagCollView];
            
            self.isChangeGroup = NO;
        }
        
        self.participantsIndexPathArray = nil;
        self.ccopyToMembersArray = nil;
        self.responsibleDic = nil;
    }
    
    if(_isShowAllSection)
    {
        [_tableView reloadData];
        
        _tableView.height = 390 - 44 * 2 + _canyuHeight + _chaosongHeight;
        
        _mainViewHeightCons.constant = YH(_tableView) - 1;

    }
    if(_workGroupName.length)
    {
        NSIndexPath* indexPath = [NSIndexPath indexPathForRow:(NSInteger)0 inSection:(NSInteger)0];
        UITableViewCell* cell = [_tableView cellForRowAtIndexPath:indexPath];
        BOOL isEx = NO;
        for (UIControl* control in cell.contentView.subviews) {
            if (control.tag == 112) {
                ((UILabel*)control).text = _workGroupName;
                isEx = YES;
                break;
            }
        }
        if(!isEx)
        {
            CGFloat lHeight = 26;
            UIFont * font = Font(14);
            CGSize size = [CommonFile contentSize:_workGroupName vWidth:0 vHeight:lHeight contentFont:font];
            CGFloat lwidth = size.width + 13;
            UILabel* name = [[UILabel alloc] initWithFrame:CGRectMake(86, 9, lwidth, lHeight)];
            [name setBackgroundColor:[UIColor tagBlueBackColor]];
            [name setText: _workGroupName];
            [name setTextColor:[UIColor whiteColor]];
            [name setTextAlignment:NSTextAlignmentCenter];
            [name setFont:font];
            name.tag = 112;
            [name setRoundCorner:3.3];
            
            [cell.contentView addSubview:name];
        }
    }
    
    if (self.responsibleDic.count > 0){
        NSLog(@"%@",self.responsibleDic);
        
        if (self.responsibleDic.count > 0) {
            NSMutableArray* arr = (NSMutableArray*)self.responsibleDic;
            
            if (arr.count == 1) {
                
                Member* mem = arr[0];
                
                NSMutableArray * arr = [NSMutableArray arrayWithArray:_participantsIndexPathArray];
                
                if(arr.count > 0)
                {
                    for (Member * meb in arr)
                    {
                        if(meb.userId == mem.userId)
                        {
                            [arr removeObject:meb];
                            
                            break;
                        }
                    }
                }
                
                self.participantsIndexPathArray = arr;
                
                NSMutableArray * ccArr = [NSMutableArray arrayWithArray:_ccopyToMembersArray];
                
                if(ccArr.count > 0)
                {
                    for (Member * meb in ccArr)
                    {
                        if(meb.userId == mem.userId)
                        {
                            [ccArr removeObject:meb];
                            
                            break;
                        }
                    }
                }
                
                self.ccopyToMembersArray = ccArr;
                
                NSIndexPath* indexPath = [NSIndexPath indexPathForRow:(NSInteger)0 inSection:(NSInteger)1];
                UITableViewCell* cell = [_tableView cellForRowAtIndexPath:indexPath];
                BOOL isEx = NO;
                for (UIControl* control in cell.contentView.subviews) {
                    if (control.tag == 112) {
                        ((UILabel*)control).text = mem.name;
                        isEx = YES;
                        break;
                    }
                }
                if (!isEx) {
                    CGFloat lHeight = 26;
                    UIFont * font = Font(14);
                    CGSize size = [CommonFile contentSize:mem.name vWidth:0 vHeight:lHeight contentFont:font];
                    CGFloat lwidth = size.width + 13;
                    UILabel* name = [[UILabel alloc] initWithFrame:CGRectMake(86, 9, lwidth, lHeight)];
                    [name setBackgroundColor:[UIColor tagBlueBackColor]];
                    [name setText: mem.name];
                    [name setTextColor:[UIColor whiteColor]];
                    [name setTextAlignment:NSTextAlignmentCenter];
                    [name setFont:font];
                    name.tag = 112;
                    [name setRoundCorner:3.3];
                    
                    [cell.contentView addSubview:name];
                }
            }
        }
    }
    if (self.participantsIndexPathArray != nil) {
        NSLog(@"%@",self.participantsIndexPathArray);
        
        NSMutableArray * arr = [NSMutableArray arrayWithArray:_ccopyToMembersArray];
        
        NSMutableArray * editArr = [NSMutableArray arrayWithArray:_ccopyToMembersArray];
        
        if(arr.count > 0)
        {
            for (int i = 0; i < arr.count; i ++)
            {
                Member * meb = arr[i];
                
                for(Member * mem in _participantsIndexPathArray)
                {
                    if(meb.userId == mem.userId)
                    {
                        [editArr removeObject:meb];
                        
                        break;
                    }
                }
            }
        }
        
        self.ccopyToMembersArray = editArr;
        
        NSIndexPath* indexPath = [NSIndexPath indexPathForRow:(NSInteger)1 inSection:(NSInteger)1];
        UITableViewCell* cell = [_tableView cellForRowAtIndexPath:indexPath];

        BOOL isEx = NO;
        for (UIControl* control in cell.contentView.subviews) {
            if (control.tag == 112) {
                [control removeFromSuperview];
            }
        }
        if (!isEx) {
            
            UIFont* font = Font(14);
            
            CGFloat cWidth = [UIScreen mainScreen].bounds.size.width;
            CGFloat x = 86;
            CGFloat y = 12;
            CGFloat intevalX = 14;
            CGFloat intevalY = 10;
            CGFloat lblTotalWidth = cWidth - x - 80;
            CGFloat nWidth = 0;
            CGFloat lHeight = 26;
            
            int row = 1;
            
            for (int i = 0; i< self.participantsIndexPathArray.count; i++) {
                Member* m = (Member*)[self.participantsIndexPathArray objectAtIndex:i];
                CGSize size = [CommonFile contentSize:m.name vWidth:0 vHeight:lHeight contentFont:font];
                CGFloat lwidth = size.width + 13;
                UILabel* name = [[UILabel alloc] initWithFrame:CGRectMake(x + nWidth,y + (lHeight + intevalY)* (row - 1), lwidth, lHeight)];
                [name setBackgroundColor:[UIColor tagBlueBackColor]];
                [name setText: m.name];
                [name setTextColor:[UIColor whiteColor]];
                [name setTextAlignment:NSTextAlignmentCenter];
                [name setFont:font];
                name.tag = 112;
                [name setRoundCorner:3.3];
                
                [cell.contentView addSubview:name];
                
                nWidth = lwidth + nWidth + intevalX;
                if (nWidth > lblTotalWidth) {
                    row++;
                    nWidth = 0;
                }
            }
        }
    }
    
    if (self.ccopyToMembersArray != nil)
    {
        NSLog(@"%@",self.ccopyToMembersArray);
        
        NSIndexPath* indexPath = [NSIndexPath indexPathForRow:(NSInteger)2 inSection:(NSInteger)1];
        UITableViewCell* cell = [_tableView cellForRowAtIndexPath:indexPath];
        BOOL isEx = NO;
        for (UIControl* control in cell.contentView.subviews) {
            if (control.tag == 112) {
                [control removeFromSuperview];
            }
        }
        if (!isEx) {
            UIFont* font = Font(14);
            
            CGFloat cWidth = [UIScreen mainScreen].bounds.size.width;
            CGFloat x = 86;
            CGFloat y = 12;
            CGFloat intevalX = 14;
            CGFloat intevalY = 10;
            CGFloat lblTotalWidth = cWidth - x - 80;
            CGFloat nWidth = 0;
            CGFloat lHeight = 26;
            
            int row = 1;
            
            for (int i = 0; i< self.ccopyToMembersArray.count; i++) {
                Member* m = (Member*)[self.ccopyToMembersArray objectAtIndex:i];
                CGSize size = [CommonFile contentSize:m.name vWidth:0 vHeight:lHeight contentFont:font];
                CGFloat lwidth = size.width + 13;
                UILabel* name = [[UILabel alloc] initWithFrame:CGRectMake(x + nWidth,y + (lHeight + intevalY)* (row - 1), lwidth, lHeight)];
                [name setBackgroundColor:[UIColor tagBlueBackColor]];
                [name setText: m.name];
                [name setTextColor:[UIColor whiteColor]];
                [name setTextAlignment:NSTextAlignmentCenter];
                [name setFont:font];
                name.tag = 112;
                [name setRoundCorner:3.3];

                [cell.contentView addSubview:name];
                
                nWidth = lwidth + nWidth + intevalX;
                if (nWidth > lblTotalWidth) {
                    row++;
                    nWidth = 0;
                }
            }
        }
    }
    
    if (self.cAccessoryArray.count)
    {//附件
        
        [self refreshCollectionView];
    }
    
}

- (void) resetFileUrls
{
//    [_fileUrls removeAllObjects];
//    [_imgUrls removeAllObjects];

    for(Accessory * acc in _cAccessoryArray)
    {
        NSMutableDictionary * dic = [[NSMutableDictionary alloc] init];
        [dic setObject:acc.address forKey:@"url"];
        if(acc.name)
        {
            [dic setObject:acc.name forKey:@"name"];
        }
        if(acc.type)
        {

            [dic setObject:[NSString stringWithFormat:@"%ld", acc.type] forKey:@"fileType"];
            
//            [_fileUrls addObject:dic];
        }
        else
        {
//            [_imgUrls addObject:dic];
        }
    }
}

#pragma -
#pragma Table View
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {
        return 1;
    }
    else if (section == 1) {
        return 3;
    }
    else if (section == 2) {
        return 1;
    }
    return 0;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if(_isShowAllSection)
    {
        return 3;
    }
    else
    {
        return 1;
    }
}

- (UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView* customView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREENWIDTH, 44)];
    customView.backgroundColor = [UIColor backgroundColor];
    
    UILabel * headerLabel = [[UILabel alloc] initWithFrame:CGRectMake(14, 26, 100, 14)];
    headerLabel.backgroundColor = [UIColor clearColor];
    headerLabel.textColor = [UIColor grayTitleColor];
    headerLabel.font = Font(12);
    
    NSString * title = @"";
    
    if (section == 0) {
        title = @"选择群组";
    }
    else if (section == 1)
    {
        title = @"选择成员";
    }
    else if (section == 2)
    {
        title = @"标签";
        
        UIButton * moreBtn = [[UIButton alloc] initWithFrame:CGRectMake(SCREENWIDTH - 48, 10, 48, 44)];
        moreBtn.backgroundColor = [UIColor clearColor];
        [moreBtn setTitle:@"更多" forState:UIControlStateNormal];
        moreBtn.titleLabel.font = Font(12);
        [moreBtn setTitleColor:[UIColor blueTextColor] forState:UIControlStateNormal];
        [moreBtn addTarget:self action:@selector(moreMarkClick:) forControlEvents:UIControlEventTouchUpInside];
        
        [customView addSubview:moreBtn];
    }
    headerLabel.text = title;
    
    [customView addSubview:headerLabel];
    
    return customView;
}

- (void) moreMarkClick:(id)sender
{
    UIStoryboard* mainStory = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    UIViewController* vc = [mainStory instantiateViewControllerWithIdentifier:@"ICMarkListViewController"];
    ((ICMarkListViewController*)vc).parentControllerType = ParentControllerTypePublishMission;
    ((ICMarkListViewController*)vc).parentController = self;
    if(!_cMarkAarry.count)
    {
//        NSArray * arr = [NSArray arrayWithArray:_tagList];
        NSMutableArray * arr = [NSMutableArray arrayWithArray:_tagList];
        
        _cMarkAarry = arr;
        
        ((ICMarkListViewController*)vc).selectedMarkArray = _cMarkAarry;

    }
    else
    {
        ((ICMarkListViewController*)vc).selectedMarkArray = _cMarkAarry;
    }
    ((ICMarkListViewController*)vc).workGroupId = self.workGroupId;
    ((ICMarkListViewController*)vc).userId = self.userId;
    
    [self.navigationController pushViewController:vc animated:YES];
}

- (CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 44.0;
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"MissionCellIdentitifer";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    for(UIView *view in cell.contentView.subviews) {
        [view removeFromSuperview];
    }

    NSInteger index = indexPath.row;
    NSInteger section = indexPath.section;
    CGFloat tableWidth = SCREENWIDTH;
    CGFloat cellHeight = [self tableView:tableView heightForRowAtIndexPath:indexPath];

    UIImageView* photo = [[UIImageView alloc] initWithFrame:CGRectMake(12, 11, 17, 20)];
    
    UILabel* lblText = [[UILabel alloc] initWithFrame:CGRectMake(40, 0, 100, 44)];
    [lblText setBackgroundColor:[UIColor clearColor]];
    [lblText setTextColor:[UIColor grayTitleColor]];
    [lblText setFont:Font(12)];
    [lblText setTextAlignment:NSTextAlignmentLeft];
    
    if (section == 0 && index == 0) {
        UILabel* line1 = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, tableWidth, 0.5)];
        [line1 setBackgroundColor:[UIColor grayLineColor]];
        [cell.contentView addSubview:line1];
        
        [photo setFrame:CGRectMake(14, 14, 13, 15)];
        [photo setImage:[UIImage imageNamed:@"icon_qunzu_white"]];
        
        [lblText setText:@"群组"];
        
//        UILabel* groupText = [[UILabel alloc] initWithFrame:CGRectMake(86, 0, SCREENWIDTH - 100, 44)];
//        [groupText setBackgroundColor:[UIColor clearColor]];
//        [groupText setTextColor:[UIColor whiteColor]];
//        [groupText setFont:Font(15)];
//        [groupText setTextAlignment:NSTextAlignmentLeft];
//        
//        [cell.contentView addSubview:groupText];
//        
//        if(_workGroupName)
//        {
//            [groupText setText:_workGroupName];
//        }
//        else
//        {
//            [groupText setText:@""];
//        }
    }
    else if(section == 1 && index == 0) {
        UILabel* line1 = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, tableWidth, 0.5)];
        [line1 setBackgroundColor:[UIColor grayColor]];
        [cell.contentView addSubview:line1];
        
        [photo setFrame:CGRectMake(14, 14, 13, 15)];
        [photo setImage:[UIImage imageNamed:@"icon_fuzeren_white"]];
        [lblText setText:@"负责人"];
    }
    else if (section == 1 && index == 1) {
        [photo setFrame:CGRectMake(14, 14, 13, 15)];
        [photo setImage:[UIImage imageNamed:@"icon_canyuren_white"]];
        [lblText setText:@"参与人"];
    }
    else if (section == 1 && index == 2) {
        [photo setFrame:CGRectMake(14, 14, 13, 17)];
        [photo setImage:[UIImage imageNamed:@"icon_chaosong_white"]];
        [lblText setText:@"抄送"];
    }
    else if (section == 2 && index == 0)
    {
        [cell.contentView addSubview:_markCollectionView];
        
        cell.backgroundColor = [UIColor clearColor];
    }
    
    if (!(section == 2 && index == 0))
    {
        
        [cell.contentView addSubview:photo];
        [cell.contentView addSubview:lblText];
        
        UILabel* line4 = [[UILabel alloc] init];
        
        if((section == 1 && index == 0) || (section == 1 && index == 1))
        {
            line4.frame = CGRectMake(14, cellHeight - 1, tableWidth, 0.5);
        }
        else
        {
            line4.frame = CGRectMake(0, cellHeight - 1, tableWidth, 0.5);
        }
        
        [line4 setBackgroundColor:[UIColor grayLineColor]];
        [cell.contentView addSubview:line4];
        
//        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        
        photo = [[UIImageView alloc] init];
        [photo setFrame:CGRectMake(SCREENWIDTH - 12 - 14, (cellHeight - 12) / 2, 12, 12)];
        [photo setImage:[UIImage imageNamed:@"icon_jiantou"]];
        [cell.contentView addSubview:photo];
        
        cell.backgroundColor = [UIColor grayMarkColor];

    }
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self hiddenKeyboard];
    
    NSInteger index = indexPath.row;
    NSInteger section = indexPath.section;
    
    if(section == 0 && index == 0)
    {
        NSString * taskId = [_currentMissionDic valueForKey:@"taskId"];
        
        if(taskId)
        {
            [SVProgressHUD showErrorWithStatus:@"不能修改群组"];
            
            [tableView deselectRowAtIndexPath:indexPath animated:YES];

            return;
        }
        
        UIStoryboard* mainStory = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        UIViewController* vc = [mainStory instantiateViewControllerWithIdentifier:@"ICGroupListViewController"];
        ((ICGroupListViewController*)vc).currentViewGroupType = GroupTypeMission;
        ((ICGroupListViewController*)vc).icMQPublishViewController = self;
        [self.navigationController pushViewController:vc animated:YES];


    }
    if(section == 1 && index == 0)
    {
        UIStoryboard* mainStory = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        UIViewController* vc = [mainStory instantiateViewControllerWithIdentifier:@"ICMemberTableViewController"];
        ((ICMemberTableViewController*)vc).controllerType = MemberViewFromControllerPublishMissionResponsible;
        ((ICMemberTableViewController*)vc).icGroupListController = self;
        ((ICMemberTableViewController*)vc).workgid =  self.workGroupId;
        ((ICMemberTableViewController*)vc).justRead =  YES;
        if (_responsibleDic != nil) {
            ((ICMemberTableViewController*)vc).selectedResponsibleDictionary = _responsibleDic;
        }
        
        [self.navigationController pushViewController:vc animated:YES];
    }
    else if(section == 1 && index == 1)
    {
        //if (_responsibleDic.count > 0) {
        UIStoryboard* mainStory = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        UIViewController* vc = [mainStory instantiateViewControllerWithIdentifier:@"ICMemberTableViewController"];
        ((ICMemberTableViewController*)vc).controllerType = MemberViewFromControllerPublishMissionParticipants;
        ((ICMemberTableViewController*)vc).icPublishMisonController = self;
        
        ((ICMemberTableViewController*)vc).selectedResponsibleDictionary = _responsibleDic;
        ((ICMemberTableViewController*)vc).workgid = self.workGroupId;
        ((ICMemberTableViewController*)vc).justRead = YES;

        if (_participantsIndexPathArray.count > 0) {
            ((ICMemberTableViewController*)vc).selectedParticipantsDictionary = _participantsIndexPathArray;
        }
        [self.navigationController pushViewController:vc animated:YES];
        
    }
    else if(section == 1 && index == 2)//抄送
    {
        //if (_participantsIndexPathArray.count > 0) {
        UIStoryboard* mainStory = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        UIViewController* vc = [mainStory instantiateViewControllerWithIdentifier:@"ICMemberTableViewController"];
        ((ICMemberTableViewController*)vc).controllerType = MemberViewFromControllerCopyTo;
        ((ICMemberTableViewController*)vc).icPublishMisonController = self;
        
        ((ICMemberTableViewController*)vc).selectedResponsibleDictionary = _responsibleDic;
        ((ICMemberTableViewController*)vc).workgid = self.workGroupId;
        ((ICMemberTableViewController*)vc).isCC = YES;
        ((ICMemberTableViewController*)vc).justRead = YES;

        if (_ccopyToMembersArray.count > 0) {
            ((ICMemberTableViewController*)vc).selectedCopyToMembersArray = _ccopyToMembersArray;
        }
        if (_participantsIndexPathArray.count > 0) {
            ((ICMemberTableViewController*)vc).selectedParticipantsDictionary = _participantsIndexPathArray;
        }
        [self.navigationController pushViewController:vc animated:YES];
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 1 && indexPath.section == 1) {
        if (self.participantsIndexPathArray.count > 0) {
            
            UIFont* font = Font(14);
            CGFloat cWidth = [UIScreen mainScreen].bounds.size.width;
            CGFloat x = 86;
            CGFloat y = 12;
            CGFloat intevalX = 14;
            CGFloat intevalY = 10;
            CGFloat lblTotalWidth = cWidth - x - 80;
            CGFloat nWidth = 0;
            CGFloat lHeight = 26;
            int row = 1;
            
            for (int i = 0; i< self.participantsIndexPathArray.count; i++) {
                Member* m = (Member*)[self.participantsIndexPathArray objectAtIndex:i];
                CGSize size = [CommonFile contentSize:m.name vWidth:0 vHeight:lHeight contentFont:font];
                CGFloat lwidth = size.width + 13;
                nWidth = lwidth + nWidth + intevalX;
                if (nWidth > lblTotalWidth) {
                    row++;
                    nWidth = 0;
                }
            }

            if (nWidth == 0) {
                row--;
                if (row < 1) {
                    row = 1;
                }
            }
            
            CGFloat cellHeight = y * 2 + row * lHeight + (row - 1) * intevalY;
            
            _canyuHeight = cellHeight;
            
            return cellHeight;
        }
        else
        {
            _canyuHeight = 44;
        }
        
    }
    else if (indexPath.row == 2 && indexPath.section == 1) {
        
        if (self.ccopyToMembersArray.count > 0) {
            
            UIFont* font = Font(14);
            CGFloat cWidth = [UIScreen mainScreen].bounds.size.width;
            CGFloat x = 86;
            CGFloat y = 12;
            CGFloat intevalX = 14;
            CGFloat intevalY = 10;
            CGFloat lblTotalWidth = cWidth - x - 80;
            CGFloat nWidth = 0;
            CGFloat lHeight = 26;
            int row = 1;
            
            for (int i = 0; i< self.ccopyToMembersArray.count; i++) {
                Member* m = (Member*)[self.ccopyToMembersArray objectAtIndex:i];
                CGSize size = [CommonFile contentSize:m.name vWidth:0 vHeight:lHeight contentFont:font];
                CGFloat lwidth = size.width + 13;
                nWidth = lwidth + nWidth + intevalX;
                if (nWidth > lblTotalWidth) {
                    row++;
                    nWidth = 0;
                }
            }
            
            if (nWidth == 0) {
                row--;
                if (row < 1) {
                    row = 1;
                }
            }
            
            CGFloat cellHeight = y * 2 + row * lHeight + (row - 1) * intevalY;
            
            _chaosongHeight = cellHeight;
            
            return cellHeight;
        }
        else
        {
            _chaosongHeight = 44;
        }
        
    }
    else if (indexPath.section == 2 && indexPath.row == 0)
    {
        return 80;
    }
    return 44;
}

- (void) initTagCollectionView
{
    _tagList = [[NSMutableArray alloc] init];
    
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    
    layout.minimumInteritemSpacing = 12.f;
    layout.minimumLineSpacing = 14.f;
    UIEdgeInsets insets = {.top = 0,.left = 14,.bottom = 14,.right = 14};
    layout.sectionInset = insets;
    
    _TagCollView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, SCREENWIDTH, 41) collectionViewLayout:layout];
    _TagCollView.delegate = self;
    _TagCollView.dataSource = self;
    _TagCollView.scrollEnabled = NO;
    _TagCollView.backgroundColor = [UIColor grayMarkColor];
    
    [_TagCollView registerClass:[MarkTagCell class] forCellWithReuseIdentifier:@"MarkTagCell"];
    
    [self.mainView addSubview:_TagCollView];

    _TagCollView.hidden = YES;
    
}

- (void) initMarkCollectionView
{
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    
    layout.minimumInteritemSpacing = 15.f;
    layout.minimumLineSpacing = 14.f;
    UIEdgeInsets insets = {.top = 0,.left = 12,.bottom = 0,.right = 12};
    layout.sectionInset = insets;

    _markCollectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, SCREENWIDTH, 80) collectionViewLayout:layout];
    _markCollectionView.delegate = self;
    _markCollectionView.dataSource = self;
    _markCollectionView.scrollEnabled = NO;
    _markCollectionView.backgroundColor = [UIColor clearColor];
    _markCollectionView.tag = 1112;
    
    [_markCollectionView registerClass:[MarkCell class] forCellWithReuseIdentifier:@"MarkCell"];

}

- (void)_initPstCollectionView
{
    _currentItem = -1;
    _deleteIndex = -1;
    
    self.cAccessoryArray = [NSMutableArray array];
    
//    self.pickedUrls = [NSMutableArray arrayWithCapacity:0];
    
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    
    layout.minimumInteritemSpacing = 12.f;
    layout.minimumLineSpacing = 14.f;
    UIEdgeInsets insets = {.top = 0,.left = 14,.bottom = 14,.right = 14};
    layout.sectionInset = insets;
    
    CGFloat pstH = (SCREENWIDTH - 14 * 2 - 12 * 3)/4;

    _collectionview = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, SCREENWIDTH, pstH + 14) collectionViewLayout:layout];
    _collectionview.delegate = self;
    _collectionview.dataSource = self;
    _collectionview.scrollEnabled = NO;
    _collectionview.backgroundColor = [UIColor grayMarkColor];
    NSString * idenStr = @"AddPicCell88";
    if(SCREENWIDTH == 375)
    {
        idenStr = @"AddPicCell80";
    }
    else if (SCREENWIDTH == 320)
    {
        idenStr = @"AddPicCell66";
    }
    [_collectionview registerNib:[UINib nibWithNibName:idenStr bundle:[NSBundle mainBundle]] forCellWithReuseIdentifier:idenStr];
    [self.mainView addSubview:_collectionview];
    
    _collectionview.hidden = YES;
}

#pragma mark - collectionview delegate / datasource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    if(collectionView == _collectionview)
    {
        return _cAccessoryArray.count + 1;
    }
    else if (collectionView == _markCollectionView)
    {
        return _markList.count > 4 ? 4 : _markList.count;
    }
    else if (collectionView == _TagCollView)
    {
        return _tagList.count;
    }
    return 0;
}

- (void) delTagItem:(id)button
{
    UIButton * btn = (UIButton *)button;

    NSInteger deleteIndex = btn.tag;
    
    Mark * mark = _tagList[deleteIndex];

    [_tagList removeObjectAtIndex:deleteIndex];
    
    NSInteger count = _markList.count > 4 ? 4 : _markList.count;
    
    for(int index = 0; index < count; index ++ )
    {
        Mark * m = _markList[index];
        
        if(mark.labelId == m.labelId)
        {
            [self resetMarkItem:index];
        }
    }
    
    [self refreshTagCollView];

}

//删除图片
- (void)clickDelImage:(UIButton *)button
{
    UIButton * btn = (UIButton *)button;
    
    NSInteger deleteIndex = btn.tag - 1000;
    
//    NSInteger cIndex = deleteIndex - _imgUrls.count;
//    
//    if(cIndex >= 0)
//    {
//        [self resetFileUrls];
//    }
//    else
//    {
//        [_imgUrls removeObjectAtIndex:deleteIndex];
//    }
    
    [_cAccessoryArray removeObjectAtIndex:deleteIndex];


    [self refreshCollectionView];
    
}


//点击add图片
- (void)clickImage:(UIButton *)button{
    [self.view endEditing:YES];
    _currentItem = -1;
    UIActionSheet* as = [[UIActionSheet alloc] initWithTitle:@"选取附件" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"群组文件夹", @"拍照", @"从相册选取", nil];
    [as showInView:self.view];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    if(collectionView == _collectionview)
    {
        NSString * idenStr = @"AddPicCell88";
        
        if(SCREENWIDTH == 375)
        {
            idenStr = @"AddPicCell80";
            
            AddPicCell80 *cell = [collectionView dequeueReusableCellWithReuseIdentifier:idenStr forIndexPath:indexPath];
            
            CGRect rect = cell.frame;
            rect.origin.x = 0;
            cell.contentView.frame = rect;
            if (indexPath.row == _cAccessoryArray.count) {
                cell.imageView.hidden = YES;
                cell.btnAdd.hidden = NO;
                cell.delBtn.hidden = YES;
                cell.fileVIew.hidden = YES;

                [cell.btnAdd addTarget:self action:@selector(clickImage:) forControlEvents:UIControlEventTouchUpInside];
            } else {
                cell.btnAdd.hidden = YES;
                cell.imageView.hidden = NO;
                cell.delBtn.hidden = NO;
                cell.delBtn.tag = 1000 + indexPath.row;
                [cell.delBtn addTarget:self action:@selector(clickDelImage:) forControlEvents:UIControlEventTouchUpInside];
                NSInteger index = indexPath.row;
                
//                NSDictionary * dic = _pickedUrls[index];
                Accessory * acc = _cAccessoryArray[index];
                
//                NSString * url = [dic valueForKey:@"url"];
//                
//                NSString * fileType = [dic valueForKey:@"fileType"];
//                NSString * name = [dic valueForKey:@"name"];
                //1: doc/docx  2: xls/xlsx 3: ppt/pptx 4: pdf 5: png/jpg 6:其他
                if(acc.type)
                {
                    NSInteger fileTypeNum = acc.type;
                    
                    cell.fileVIew.hidden = NO;
                    
                    NSString * iconName = @"";
                    
                    UIColor * color = [UIColor redColor];
                    
                    switch (fileTypeNum) {
                        case 1:
                            iconName = @"btn_word_edit";
                            color = [UIColor wordBackColor];
                            break;
                        case 2:
                            iconName = @"btn_excel_edit";
                            color = [UIColor excelBackColor];

                            break;
                        case 3:
                            iconName = @"btn_ppt_edit";
                            color = [UIColor pptBackColor];

                            break;
                        case 4:
                            iconName = @"btn_pdf_edit";
                            color = [UIColor pdfBackColor];

                            break;
                        case 6:
                            iconName = @"btn_qita_edit";
                            color = [UIColor qitaBackColor];

                            break;
                        default:
                            break;
                    }
                    cell.fileVIew.backgroundColor = color;
                    cell.fileLbl.text = acc.name;
                    cell.iconView.image = [UIImage imageNamed:iconName];
                }
                else
                {
                    cell.imageView.image = nil;

                    [cell.imageView setImageWithURL:[NSURL URLWithString:acc.address] placeholderImage:nil options:SDWebImageDelayPlaceholder usingActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
                    
                    cell.fileVIew.hidden = YES;
                }
                
            }
            
            //    [cell.imageView setBorderWithColor:AppColor(204)];
            
            return cell;
        }
        else if (SCREENWIDTH == 320)
        {
            idenStr = @"AddPicCell66";
            
            AddPicCell66 *cell = [collectionView dequeueReusableCellWithReuseIdentifier:idenStr forIndexPath:indexPath];
            
            CGRect rect = cell.frame;
            rect.origin.x = 0;
            cell.contentView.frame = rect;
            if (indexPath.row == _cAccessoryArray.count) {
                cell.imageView.hidden = YES;
                cell.btnAdd.hidden = NO;
                cell.delBtn.hidden = YES;
                cell.fileVIew.hidden = YES;
                
                [cell.btnAdd addTarget:self action:@selector(clickImage:) forControlEvents:UIControlEventTouchUpInside];
            } else {
                cell.btnAdd.hidden = YES;
                cell.imageView.hidden = NO;
                cell.delBtn.hidden = NO;
                cell.delBtn.tag = 1000 + indexPath.row;
                [cell.delBtn addTarget:self action:@selector(clickDelImage:) forControlEvents:UIControlEventTouchUpInside];
                
                NSInteger index = indexPath.row;
                
                Accessory * acc = _cAccessoryArray[index];
                
                cell.imageView.image = nil;
                
                [cell.imageView setImageWithURL:[NSURL URLWithString:acc.address] placeholderImage:nil options:SDWebImageDelayPlaceholder usingActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
            }
            
            //    [cell.imageView setBorderWithColor:AppColor(204)];
            
            return cell;
        }
        else
        {
            AddPicCell88 *cell = [collectionView dequeueReusableCellWithReuseIdentifier:idenStr forIndexPath:indexPath];
            CGRect rect = cell.frame;
            rect.origin.x = 0;
            cell.contentView.frame = rect;
            if (indexPath.row == _cAccessoryArray.count) {
                cell.imageView.hidden = YES;
                cell.btnAdd.hidden = NO;
                cell.delBtn.hidden = YES;
                cell.fileVIew.hidden = YES;
                
                [cell.btnAdd addTarget:self action:@selector(clickImage:) forControlEvents:UIControlEventTouchUpInside];
            } else {
                cell.btnAdd.hidden = YES;
                cell.imageView.hidden = NO;
                cell.delBtn.hidden = NO;
                cell.delBtn.tag = 1000 + indexPath.row;
                [cell.delBtn addTarget:self action:@selector(clickDelImage:) forControlEvents:UIControlEventTouchUpInside];
                NSInteger index = indexPath.row;
                
                Accessory * acc = _cAccessoryArray[index];
                
                cell.imageView.image = nil;

                [cell.imageView setImageWithURL:[NSURL URLWithString:acc.address] placeholderImage:nil options:SDWebImageDelayPlaceholder usingActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
            }
            
            //    [cell.imageView setBorderWithColor:AppColor(204)];
            
            return cell;
        }
    }
    else if (collectionView == _TagCollView)
    {
        static NSString *CellIdentifier = @"MarkTagCell";
        MarkTagCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:CellIdentifier forIndexPath:indexPath];
        
        Mark * mark = _tagList[indexPath.row];
        
        cell.titleLbl.text = mark.labelName;
        
        [cell.delBtn addTarget:self action:@selector(delTagItem:) forControlEvents:UIControlEventTouchUpInside];
        
        [cell setRoundCorner:3.3];
        
        return cell;
    }
    else if (collectionView == _markCollectionView)
    {
        static NSString *CellIdentifier = @"MarkCell";
        MarkCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:CellIdentifier forIndexPath:indexPath];
        
        Mark * mark = _markList[indexPath.row];
        
        [cell.markBtn setTitle:mark.labelName forState:UIControlStateNormal];
        
        [cell.markBtn addTarget:self action:@selector(clickMarkItem:) forControlEvents:UIControlEventTouchUpInside];
        
        cell.markBtn.tag = indexPath.row;
        
        [cell setRoundColorCorner:3.3];
        
        [cell setBorderWithColor:[UIColor grayLineColor]];
        
        cell.markBtn.selected = NO;
        
        [cell.markBtn setBackgroundColor:[UIColor grayMarkColor]];
        
        [cell.markBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        
        [cell setBorderWithColor:[UIColor grayLineColor]];
        
        if(_selectedIndexTagArr.count)
        {
            for(int i = 0; i < _selectedIndexTagArr.count; i ++)
            {
                NSInteger index = [_selectedIndexTagArr[i] integerValue];
                
                if(indexPath.row == index)
                {
                    cell.markBtn.selected = YES;
                    
                    [cell.markBtn setBackgroundColor:[UIColor grayMarkHoverBackgroundColor]];
                    
                    [cell.markBtn setTitleColor:[UIColor grayMarkHoverTitleColor] forState:UIControlStateNormal];
                    
                    [cell setBorderWithColor:[UIColor grayMarkLineColor]];
                    
                }
            }
        }
        
        return cell;

    }
    return nil;
}

- (void) resetMarkItem:(NSInteger)index
{
    
    Mark * mark = _markList[index];

    NSIndexPath * indexPath = [NSIndexPath indexPathForRow:index inSection:0];
    
    MarkCell * cell = (MarkCell *)[_markCollectionView cellForItemAtIndexPath:indexPath];
    
    if(cell)
    {
        cell.markBtn.selected = !cell.markBtn.selected;
        
        if(cell.markBtn.selected)
        {
            [cell.markBtn setBackgroundColor:[UIColor grayMarkHoverBackgroundColor]];
            
            [cell.markBtn setTitleColor:[UIColor grayMarkHoverTitleColor] forState:UIControlStateNormal];
            
            [cell setBorderWithColor:[UIColor grayMarkLineColor]];
            
            [_tagList addObject:mark];
            
            NSNumber * num = [NSNumber numberWithInteger:index];
            
            if(!_selectedIndexTagArr)
            {
                _selectedIndexTagArr = [NSMutableArray array];
            }
            
            [_selectedIndexTagArr addObject:num];
        }
        else
        {
            [cell.markBtn setBackgroundColor:[UIColor grayMarkColor]];
            
            [cell.markBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            
            [cell setBorderWithColor:[UIColor grayLineColor]];
            
            [_tagList removeObject:mark];
            
            NSNumber * num = [NSNumber numberWithInteger:index];
            if(!_selectedIndexTagArr)
            {
                _selectedIndexTagArr = [NSMutableArray array];
            }
            [_selectedIndexTagArr removeObject:num];
        }
        
        if(!_cMarkAarry)
        {
            self.cMarkAarry = [NSMutableArray array];
        }
        
        [_cMarkAarry removeAllObjects];
        [self.cMarkAarry addObjectsFromArray:_tagList];

    }
    
}

- (void) clickMarkItem:(id)sender
{
    UIButton * btn = (UIButton *)sender;
    
    NSInteger index = btn.tag;

    [self resetMarkItem:index];
    
    [self refreshTagCollView];

}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewFlowLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    if(collectionView == _collectionview)
    {
        CGFloat pstH = (SCREENWIDTH - 14 * 2 - 12 * 3)/4;
        
        if(pstH > 88)
        {
            pstH = 88;
        }
        
        return CGSizeMake(pstH, pstH);
    }
    else if (collectionView == _markCollectionView)
    {
        CGFloat pstH = (SCREENWIDTH - 12 * 2 - 15 * 3)/4;

        return CGSizeMake(pstH, 44);
    }
    else if (collectionView == _TagCollView)
    {
        NSInteger itemSpace = 22;
        
        if(SCREENWIDTH == 320)
        {
            itemSpace = 14;
        }
        else if (SCREENWIDTH == 375)
        {
            itemSpace = 12;
        }
        
        CGFloat pstH = (SCREENWIDTH - 14 * 2 - itemSpace * 3)/4;

        return CGSizeMake(pstH, 27);
    }
    return CGSizeZero;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    
}

- (void) setTextViewStyle
{
    [self addDoneToKeyboard:_titleTxt];
    [self addDoneToKeyboard:_txtView];
    
    _txtView.textContainerInset = UIEdgeInsetsMake(14.0f, 9.0f, 50.0f, 9.0f);
    _txtView.placeholder = @"描述";
    _txtView.placeholderColor = RGBCOLOR(172, 172, 172);
    _txtView.backgroundColor = [UIColor grayMarkColor];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)btnTodayClicked:(id)sender
{
    [_datePicker setDate:[NSDate date]];
}

- (void) resetAllViewLayout:(UIView *)view
{
    if(view == _jiezhiAndTixingView)
    {
        if(!_jiezhiView.hidden)
        {
            [_jiezhiBtn setImage:[UIImage imageNamed:@"btn_jiezhishijian_1"] forState:UIControlStateNormal];
            
//            if(_tixingView.hidden)
//            {
//                CGRect rect = _jiezhiView.frame;
//                _jiezhiView.frame = rect;
//                rect.origin.y += 41;
//                _jiezhiView.frame = rect;
//            }
        }
        else
        {
            [_jiezhiBtn setImage:[UIImage imageNamed:@"btn_jiezhishijian"] forState:UIControlStateNormal];
        }
        if(!_tixingView.hidden)
        {
            [_tixingBtn setImage:[UIImage imageNamed:@"btn_tixingshijian_1"] forState:UIControlStateNormal];
        }
        else
        {
            [_tixingBtn setImage:[UIImage imageNamed:@"btn_tixingshijian"] forState:UIControlStateNormal];
        }
        
        if(!view.hidden)
        {
            _JTViewToTxtViewTopCons.constant = 0;
        }
        
        if(_collectionview.hidden && _TagCollView.hidden)
        {
            _timeToTxtViewTopCons.constant = view.hidden ? 0 : H(view);
            
            _tableView.top = view.hidden ? _txtView.bottom + H(_timeView) : _txtView.bottom + H(view) + H(_timeView);
        }
        else if (!_collectionview.hidden && _TagCollView.hidden)
        {
            _collectionview.top = view.hidden ? _txtView.bottom : _txtView.bottom + H(view);
            
            _timeToTxtViewTopCons.constant = view.hidden ? H(_collectionview) : H(view) + H(_collectionview);
            
            _tableView.top = view.hidden ? _txtView.bottom + H(_timeView) + H(_collectionview): _txtView.bottom + H(view) + H(_timeView) + H(_collectionview);

        }
        else if (_collectionview.hidden && !_TagCollView.hidden)
        {
            _TagCollView.top = view.hidden ? _txtView.bottom : _txtView.bottom + H(view);
            
            _timeToTxtViewTopCons.constant = view.hidden ? H(_TagCollView) :H(view) + H(_TagCollView);
            
            _tableView.top = view.hidden ? _txtView.bottom + H(_timeView) + H(_TagCollView): _txtView.bottom + H(view) + H(_timeView) + H(_TagCollView);

        }
        else if (!_collectionview.hidden && !_TagCollView.hidden)
        {
            _collectionview.top = view.hidden ? _txtView.bottom : _txtView.bottom + H(view);
            
            _TagCollView.top = view.hidden ? _txtView.bottom + H(_collectionview):_txtView.bottom + H(view) + H(_collectionview)- 0.5;
            
            _timeToTxtViewTopCons.constant = view.hidden ? H(_collectionview) + H(_TagCollView) :H(view) + H(_collectionview) + H(_TagCollView)- 0.5;
            
            _tableView.top = view.hidden ? _txtView.bottom + H(_timeView) + H(_TagCollView) + H(_collectionview): _txtView.bottom + H(view) + H(_timeView) + H(_TagCollView)+ H(_collectionview)- 0.5;

        }
    }
    else if(view == _collectionview)
    {
        if(!_collectionview.hidden)
        {
            [_fujianBtn setImage:[UIImage imageNamed:@"btn_fujian_1"] forState:UIControlStateNormal];
        }
        else
        {
            [_fujianBtn setImage:[UIImage imageNamed:@"btn_fujian_2"] forState:UIControlStateNormal];
        }
        if(_jiezhiAndTixingView.hidden && _TagCollView.hidden)
        {
            view.top = view.hidden ? 0 : _txtView.bottom;

            _timeToTxtViewTopCons.constant = view.hidden ? 0 : H(view);
            
            _tableView.top = view.hidden ? _txtView.bottom + H(_timeView) : _txtView.bottom + H(view) + H(_timeView);
        }
        else if (!_jiezhiAndTixingView.hidden && _TagCollView.hidden)
        {
            view.top = view.hidden ? 0 : _txtView.bottom + H(_jiezhiAndTixingView);

            _timeToTxtViewTopCons.constant = view.hidden ? H(_jiezhiAndTixingView) : H(view) + H(_jiezhiAndTixingView);
            
            _tableView.top = view.hidden ? _txtView.bottom + H(_timeView) + H(_jiezhiAndTixingView): _txtView.bottom + H(view) + H(_timeView) + H(_jiezhiAndTixingView);
            
        }
        else if (_jiezhiAndTixingView.hidden && !_TagCollView.hidden)
        {
            view.top = view.hidden ? 0 : _txtView.bottom;

            _TagCollView.top = view.hidden ? _txtView.bottom : _txtView.bottom + H(view) - 0.5;
            
            _timeToTxtViewTopCons.constant = view.hidden ? H(_TagCollView) :H(view) + H(_TagCollView) - 0.5;
            
            _tableView.top = view.hidden ? _txtView.bottom + H(_timeView) + H(_TagCollView): _txtView.bottom + H(view) + H(_timeView) + H(_TagCollView) - 0.5;
            
        }
        else if (!_jiezhiAndTixingView.hidden && !_TagCollView.hidden)
        {
            view.top = view.hidden ? 0 : _txtView.bottom + H(_jiezhiAndTixingView);

            _TagCollView.top = view.hidden ? _txtView.bottom + H(_jiezhiAndTixingView):_txtView.bottom + H(view) + H(_jiezhiAndTixingView) - 0.5;
            
            _timeToTxtViewTopCons.constant = view.hidden ? H(_jiezhiAndTixingView) + H(_TagCollView) :H(view) + H(_jiezhiAndTixingView) + H(_TagCollView) - 0.5;
            
            _tableView.top = view.hidden ? _txtView.bottom + H(_timeView) + H(_TagCollView) + H(_jiezhiAndTixingView): _txtView.bottom + H(view) + H(_timeView) + H(_TagCollView)+ H(_jiezhiAndTixingView) - 0.5;
            
        }
    }
    else if (view == _TagCollView)
    {
        if(_jiezhiAndTixingView.hidden && _collectionview.hidden)
        {
            view.top = view.hidden ? 0 : _txtView.bottom;

            _timeToTxtViewTopCons.constant = view.hidden ? 0 : H(view);
            
            _tableView.top = view.hidden ? _txtView.bottom + H(_timeView) : _txtView.bottom + H(view) + H(_timeView);
        }
        else if (!_jiezhiAndTixingView.hidden && _collectionview.hidden)
        {
            view.top = view.hidden ? 0 : _txtView.bottom + H(_jiezhiAndTixingView);
            
            _timeToTxtViewTopCons.constant = view.hidden ? H(_jiezhiAndTixingView) : H(view) + H(_jiezhiAndTixingView);
            
            _tableView.top = view.hidden ? _txtView.bottom + H(_timeView) + H(_jiezhiAndTixingView): _txtView.bottom + H(view) + H(_timeView) + H(_jiezhiAndTixingView);
            
        }
        else if (_jiezhiAndTixingView.hidden && !_collectionview.hidden)
        {
            [self countHeight];
            
            view.top = view.hidden ? 0 : _txtView.bottom + H(_collectionview) - 0.5;

            _collectionview.top = view.hidden ? _txtView.bottom : _txtView.bottom;
            
            _timeToTxtViewTopCons.constant = view.hidden ? H(_collectionview) :H(view) + H(_collectionview) - 0.5;
            
            _tableView.top = view.hidden ? _txtView.bottom + H(_timeView) + H(_collectionview): _txtView.bottom + H(view) + H(_timeView) + H(_collectionview) - 0.5;
            
        }
        else if (!_jiezhiAndTixingView.hidden && !_collectionview.hidden)
        {
            [self countHeight];

            view.top = view.hidden ? 0 : _txtView.bottom + H(_collectionview) + H(_jiezhiAndTixingView) - 0.5;

            _collectionview.top = view.hidden ? _txtView.bottom + H(_jiezhiAndTixingView):_txtView.bottom + H(_jiezhiAndTixingView);
            
            _timeToTxtViewTopCons.constant = view.hidden ? H(_jiezhiAndTixingView) + H(_collectionview) :H(view) + H(_jiezhiAndTixingView) + H(_collectionview) - 0.5;
            
            _tableView.top = view.hidden ? _txtView.bottom + H(_timeView) + H(_collectionview) + H(_jiezhiAndTixingView): _txtView.bottom + H(view) + H(_timeView) + H(_collectionview)+ H(_jiezhiAndTixingView) - 0.5;
            
        }
    }
    
    _tableView.height = 390 - 44 * 2 + _canyuHeight + _chaosongHeight;
    _mainViewHeightCons.constant = YH(_tableView) - 1;
    
}

- (void)btnDatePickerClicked:(id)sender
{
    UIButton* btn = (UIButton*)sender;
    NSInteger tag = btn.tag;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [UIView animateWithDuration:0.2 animations:^{
            _datePickerView.transform = CGAffineTransformTranslate(CGAffineTransformIdentity, 0, 0);
        }];
    });
    
    NSDate* pickerDate = [_datePicker date];
    NSLog(@"%@",pickerDate);
    
    
    NSString *strDate = @"";
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    
    if (tag == 11) {//截止
        [dateFormatter setDateFormat:@"yyyy-MM-dd"];
        strDate = [dateFormatter stringFromDate:pickerDate];
        
        if(_strRemindTime)
        {
            [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];

            NSDate* fdate = [dateFormatter dateFromString:_strRemindTime];
            
            NSDate* tdate = nil;

            if(_strFinishTime.length > 10)
            {
                tdate =  [dateFormatter dateFromString:[NSString stringWithFormat:@"%@ 00:00:00",[UICommon formatTime:_strFinishTime withLength:10]]];
            }
            else
            {
                tdate = [dateFormatter dateFromString:[NSString stringWithFormat:@"%@ 00:00:00",_strFinishTime]];
            }
            NSComparisonResult  dataCompare= [tdate compare:fdate];
            if (dataCompare != NSOrderedDescending) {
//                UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"提醒时间必须在完成时间之前" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
//                [alert show];
//                return;
            }
            else
                _strFinishTime = strDate;
        }
        
        _strFinishTime = strDate;
        
        [dateFormatter setDateFormat:@"yyyy年MM月dd日"];
        strDate = [dateFormatter stringFromDate:pickerDate];
        
        _jiezhiLbl.text = [NSString stringWithFormat:@"截止时间：%@", strDate];
        
        _jiezhiAndTixingView.hidden = NO;
        _jiezhiView.hidden = NO;

    }
    else if (tag == 12)//提醒
    {
        [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        strDate = [dateFormatter stringFromDate:pickerDate];
        
        if (_strFinishTime != nil) {
            
            NSDate* fdate = [dateFormatter dateFromString:strDate];
            NSDate* tdate = nil;
            
            if(_strFinishTime.length > 10)
            {
                tdate =  [dateFormatter dateFromString:[NSString stringWithFormat:@"%@ 00:00:00",[UICommon formatTime:_strFinishTime withLength:10]]];
            }
            else
            {
                tdate = [dateFormatter dateFromString:[NSString stringWithFormat:@"%@ 00:00:00",_strFinishTime]];
            }
            NSComparisonResult  dataCompare= [tdate compare:fdate];
            if (dataCompare != NSOrderedDescending) {
//                UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"提醒时间必须在完成时间之前" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
//                [alert show];
//                return;
            }
            else
                _strRemindTime = strDate;
        }
        else
        {
            UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"请先选择完成时间" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            [alert show];
            return;
        }
        
        [dateFormatter setDateFormat:@"yyyy年MM月dd日 HH:mm"];
        strDate = [dateFormatter stringFromDate:pickerDate];
        
        _tixingLbl.text = [NSString stringWithFormat:@"提醒时间：%@", strDate];
        _jiezhiAndTixingView.hidden = NO;
        _tixingView.hidden = NO;
    }
    
    [self resetAllViewLayout:_jiezhiAndTixingView];
    
}

- (IBAction)touchUpInsideOnBtn:(id)sender
{
    [self hiddenKeyboard];
    
    UIButton * btn = (UIButton *)sender;
    
    if(btn == _jiezhiBtn || btn == _tixingBtn)
    {
        UIView *datePickView = [(UIView *)self.view viewWithTag: 1111];
        if(datePickView)
        {
            [datePickView removeFromSuperview];
        }
        
        _datePickerView = nil;
        _datePickerView = [[UIView alloc] initWithFrame:CGRectMake(0, [UIScreen mainScreen].bounds.size.height , [UIScreen mainScreen].bounds.size.width, 220)];
        [_datePickerView setBackgroundColor:[UIColor blackColor]];
        _datePickerView.tag = 1111;
        
        UIButton* btnChoicedDate = [[UIButton alloc] initWithFrame:CGRectMake(_datePickerView.bounds.size.width - 110, 2, 100, 35)];
        [btnChoicedDate setTitle:@"确定" forState:UIControlStateNormal];
        [btnChoicedDate setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [btnChoicedDate setBackgroundColor:[UIColor clearColor]];

        [btnChoicedDate addTarget:self action:@selector(btnDatePickerClicked:) forControlEvents:UIControlEventTouchUpInside];
        
        UIButton* btnToday = [[UIButton alloc] initWithFrame:CGRectMake(10, 2, 100, 35)];
        [btnToday setTitle:@"今天" forState:UIControlStateNormal];
        [btnToday setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [btnToday setBackgroundColor:[UIColor clearColor]];
        [btnToday addTarget:self action:@selector(btnTodayClicked:) forControlEvents:UIControlEventTouchUpInside];
        
        _datePicker = [[UIDatePicker alloc] initWithFrame:CGRectMake(0, 40, _datePickerView.bounds.size.width, 170)];
        //        _datePicker.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"zh_CN"];
        _datePicker.datePickerMode = UIDatePickerModeDate;
        [_datePicker setDate:[NSDate date]];
        [_datePicker setCalendar:[NSCalendar currentCalendar]];
        [_datePicker setTintColor:[UIColor whiteColor]];
        [_datePicker setBackgroundColor:[UIColor whiteColor]];
        
        if (btn == _jiezhiBtn) {
            [btnChoicedDate setTag:11];

            _datePicker.datePickerMode = UIDatePickerModeDate;
        }
        else if (btn == _tixingBtn) {
            [btnChoicedDate setTag:12];
            
            _datePicker.datePickerMode = UIDatePickerModeDateAndTime;
        }
        
        NSDate* min = [[NSDate alloc] initWithTimeInterval:1000 sinceDate:[NSDate date]];
        [_datePicker setMinimumDate:min];
        
        [_datePickerView addSubview:btnToday];
        [_datePickerView addSubview:btnChoicedDate];
        [_datePickerView addSubview:_datePicker];
        [self.view addSubview:_datePickerView];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [UIView animateWithDuration:0.2 animations:^{
                _datePickerView.transform = CGAffineTransformTranslate(CGAffineTransformIdentity, 0, -250);
            }];
        });
    }
    else if (btn == _fujianBtn)
    {
        if(_workGroupId)
        {
            UIActionSheet* as = [[UIActionSheet alloc] initWithTitle:@"选取附件" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"群组文件夹", @"拍照", @"从相册选取", nil];
            [as showInView:self.view];
        }
        else
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil
                                                            message:@"请先选择群组!"
                                                           delegate:self
                                                  cancelButtonTitle:@"确定"
                                                  otherButtonTitles:nil, nil];
            [alert show];
        }
    }
    else if (btn == _jiezhiDelBtn)
    {
        _jiezhiView.hidden = YES;
        
        if(_tixingView.hidden)
        {
            _jiezhiAndTixingView.hidden = YES;
            
        }
        
        [self resetAllViewLayout:_jiezhiAndTixingView];
        
        _strFinishTime = nil;
    }
    else if (btn == _tixingDelBtn)
    {
        _tixingView.hidden = YES;
        
        if(_jiezhiView.hidden)
        {
            _jiezhiAndTixingView.hidden = YES;
        }
        
        [self resetAllViewLayout:_jiezhiAndTixingView];
        
        _strRemindTime = nil;
    }
}

#pragma mark -
#pragma UIActionSheet Deleget
-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(buttonIndex == 0)
    {
        UIStoryboard* mainStory = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        UIViewController* vc = [mainStory instantiateViewControllerWithIdentifier:@"ICFileViewController"];
        ((ICFileViewController *)vc).workGroupId = _workGroupId;
        ((ICFileViewController*)vc).icPublishMissionController = self;
        ((ICFileViewController*)vc).hasUploadedFileArray = (_cAccessoryArray == nil? [NSMutableArray array] :[NSMutableArray arrayWithArray:_cAccessoryArray]);
        
        [self.navigationController pushViewController:vc animated:YES];
    }
    else if (buttonIndex == 1)
    {
        UIImagePickerController *ctrl = [[UIImagePickerController alloc] init];
        ctrl.delegate = self;
        ctrl.sourceType = UIImagePickerControllerSourceTypeCamera;
        [self presentViewController:ctrl animated:YES completion:nil];
    }
    else if (buttonIndex == 2)
    {
        ZYQAssetPickerController *picker = [[ZYQAssetPickerController alloc] init];
        picker.maximumNumberOfSelection = 9;
        picker.assetsFilter = [ALAssetsFilter allPhotos];
        picker.showEmptyGroups=NO;
        picker.delegate=self;
        picker.selectionFilter = [NSPredicate predicateWithBlock:^BOOL(id evaluatedObject, NSDictionary *bindings) {
            if ([[(ALAsset*)evaluatedObject valueForProperty:ALAssetPropertyType] isEqual:ALAssetTypeVideo]) {
                NSTimeInterval duration = [[(ALAsset*)evaluatedObject valueForProperty:ALAssetPropertyDuration] doubleValue];
                return duration >= 5;
            } else {
                return YES;
            }
        }];
        
        [self presentViewController:picker animated:YES completion:NULL];
    }
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        // 处理

        [SVProgressHUD showWithStatus:@"图片上传中"];
        
        [picker dismissViewControllerAnimated:YES completion:^() {
            
            UIImage *image = info[@"UIImagePickerControllerOriginalImage"];
            
            image = [UICommon changeImageOrientation:image];
            
            NSString * dateTime = [[info[@"UIImagePickerControllerMediaMetadata"] objectForKey:@"{TIFF}"] objectForKey:@"DateTime"];
            
            _currentFileName = [NSString stringWithFormat:@"%@.png", dateTime];
            
            NSString * userImgPath = @"";

            BOOL isOk = [LoginUser uploadImageWithScale:image fileName:_currentFileName userImgPath:&userImgPath];
            
            if(isOk)
            {
                [SVProgressHUD dismiss];
                
                NSMutableDictionary * dic = [[NSMutableDictionary alloc] init];
                [dic setObject:userImgPath forKey:@"url"];
                
                if (_currentItem == -1) {
                    Accessory * acc = [Accessory new];
                    acc.address = userImgPath;
                    acc.name = _currentFileName;
                    
                    [self.cAccessoryArray addObject:acc];
                    
                }
                
                [self refreshCollectionView];
            }
        }];
        
    }
    else if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary])
    {
        NSString *type = [info objectForKey:UIImagePickerControllerMediaType];
        //当选择的类型是图片
        if ([type isEqualToString:@"public.image"])
        {
            //先把图片转成NSData
            UIImage* image = [info objectForKey:@"UIImagePickerControllerOriginalImage"];
            NSData *data;
            if (UIImagePNGRepresentation(image) == nil)
            {
                data = UIImageJPEGRepresentation(image, 1.0);
            }
            else
            {
                data = UIImagePNGRepresentation(image);
            }
            
            //图片保存的路径
            //这里将图片放在沙盒的documents文件夹中
            NSString * DocumentsPath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
            
            //文件管理器
            NSFileManager *fileManager = [NSFileManager defaultManager];
            
            //把刚刚图片转换的data对象拷贝至沙盒中 并保存为image.png
            [fileManager createDirectoryAtPath:DocumentsPath withIntermediateDirectories:YES attributes:nil error:nil];
            [fileManager createFileAtPath:[DocumentsPath stringByAppendingString:@"/image.png"] contents:data attributes:nil];
            
            //得到选择后沙盒中图片的完整路径
            //filePath = [[NSString alloc]initWithFormat:@"%@%@",DocumentsPath,  @"/image.png"];
            
            //关闭相册界面
            [picker dismissViewControllerAnimated:YES completion:nil];
            
            
            
        }
    }
    else{
        NSLog(@"请在真机使用!");
    }
}

#pragma mark - ZYQAssetPickerController Delegate
-(void)assetPickerController:(ZYQAssetPickerController *)picker didFinishPickingAssets:(NSArray *)assets
{
    NSLog(@"%@",assets);
    
    if (assets.count > 0) {
        
        [SVProgressHUD showWithStatus:@"图片上传中"];
        
        [picker dismissViewControllerAnimated:YES completion:^() {
            //            UIImage *portraitImg = [info objectForKey:@"UIImagePickerControllerOriginalImage"];
            
            for(int i = 0; i < assets.count; i ++)
            {
                ALAsset * ass = assets[i];
                
                ALAssetRepresentation* representation = [ass defaultRepresentation];
                UIImage* portraitImg = [UIImage imageWithCGImage:[representation fullResolutionImage]];
                portraitImg = [UIImage
                               imageWithCGImage:[representation fullScreenImage]
                               scale:[representation scale]
                               orientation:UIImageOrientationUp];
                
                _currentFileName = [representation filename];
                
                //            portraitImg = [UICommon imageByScalingToMaxSize:portraitImg];
                
                NSString * userImgPath = @"";
                
                BOOL isOk = [LoginUser uploadImageWithScale:portraitImg fileName:_currentFileName userImgPath:&userImgPath];
                
                if(isOk)
                {
                    NSMutableDictionary * dic = [[NSMutableDictionary alloc] init];
                    [dic setObject:userImgPath forKey:@"url"];
                    
                    if (_currentItem == -1) {
                        //                    [_imgUrls addObject:dic];
                        
                        Accessory * acc = [Accessory new];
                        acc.address = userImgPath;
                        acc.name = _currentFileName;
                        
                        [self.cAccessoryArray addObject:acc];
                        
                    } else {
                        //                    [_imgUrls removeObjectAtIndex:_currentItem];
                        //                    [_imgUrls insertObject:dic atIndex:_currentItem];
                    }
                }
                
                if(i == assets.count - 1)
                {
                    if(isOk)
                    {
                        [SVProgressHUD dismiss];
                        
                        [self refreshCollectionView];
                    }
                }
            }

        }];
    }
}

- (void) refreshTagCollView
{
    _TagCollView.hidden = _tagList.count ? NO :YES;
    
    if(!_TagCollView.hidden)
    {
        [self countTagHeight];

        [_TagCollView reloadData];
        
    }
    
    [self resetAllViewLayout:_TagCollView];
}

- (void) countTagHeight
{
    NSInteger count = _tagList.count;
    NSInteger row = (count % 4) ? count / 4 + 1: count / 4;
    
    float height = row * (27 + 14);
    
    _TagCollView.height = height;
}

- (void) refreshCollectionView
{
    _collectionview.hidden = _cAccessoryArray.count ? NO : YES;

    if(!_collectionview.hidden)
    {
        [_collectionview reloadData];
        
        [self countHeight];
        
    }
    
    [self resetAllViewLayout:_collectionview];
}

- (void)countHeight{
    //计算高度
    
    NSInteger count = _cAccessoryArray.count + 1;
    NSInteger row = (count % 4) ? (count / 4 + 1) : count / 4;
    
    CGFloat pstH = (SCREENWIDTH - 14 * 2 - 12 * 3)/4;

    float height = row * (pstH + 14);
    
    _collectionview.height = height;

}

- (IBAction)btnDoneButtonClicked:(id)sender
{
    [self hiddenKeyboard];
    
    if(!_titleTxt.text.length)
    {
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"请填写标题！" delegate:self
                                              cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
        
        [_titleTxt becomeFirstResponder];
        return;
    }
    
    if(!_workGroupName.length)
    {
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"请选择发布至的群组！" delegate:self
                                              cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
        return;
    }

    if (_responsibleDic.count == 0) {
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"请选择任务负责人！" delegate:self
                                              cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
        return;
    }
    
    if (_strFinishTime == nil || [_strFinishTime isEqualToString:@""]) {
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"请选择任务完成时间！" delegate:self
                                              cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
        return;
    }
    if(!_cMarkAarry.count)
    {
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"请选择标签！" delegate:self
                                              cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
        return;
    }
    
    
    Mission* m = [Mission new];
    
    m.createUserId = [LoginUser loginUserID];
    m.workGroupId = self.workGroupId;
    m.main = _txtView.text;
    m.liableUserId = ((Member*)[_responsibleDic objectAtIndex:0]).userId;
    
    if(_strFinishTime.length > 10)
    {
        _strFinishTime = [NSString stringWithFormat:@"%@ 00:00:00",[UICommon formatTime:_strFinishTime withLength:10]];
    }
    else
    {
        _strFinishTime = [NSString stringWithFormat:@"%@ 00:00:00",_strFinishTime];
    }
    m.finishTime = _strFinishTime;
    
    m.remindTime = _strRemindTime;
    m.type = TaskTypeMission;
    m.title = _titleTxt.text;
    
    if (_taskId != nil) {
        m.taskId = _taskId;
    }
    
    if (self.participantsIndexPathArray.count > 0) {
        NSMutableArray* tAr = [NSMutableArray array];
        
        for (int i = 0; i < self.participantsIndexPathArray.count; i++) {
            Member * cM = [self.participantsIndexPathArray objectAtIndex:i];
            [tAr addObject:cM.userId];
        }
        m.partList = [NSArray arrayWithArray:tAr];
    }
    
    if (self.ccopyToMembersArray.count > 0) {
        m.cclist = [NSMutableArray array];
        NSMutableArray* tAr = [NSMutableArray array];
        for (int i = 0; i < self.ccopyToMembersArray.count; i++) {
            Member * cM = [self.ccopyToMembersArray objectAtIndex:i];
            [tAr addObject:cM.userId];
        }
        m.cclist = [NSArray arrayWithArray:tAr];
    }
    
    if (_tagList.count > 0) {
        m.isLabel = 1;
        NSMutableArray* tAr = [NSMutableArray array];
        if (_tagList.count > 0) {
            m.labelList = [NSMutableArray array];
            
            for (int i = 0; i < _tagList.count; i++) {
                Mark * cM = [_tagList objectAtIndex:i];
                [tAr addObject:cM.labelId];
            }
            m.labelList = [NSArray arrayWithArray:tAr];
        }
        
    }else
        m.isLabel = 0;
    
    if (_cAccessoryArray.count > 0) {
        m.isAccessory = 1;
        m.accessoryList = _cAccessoryArray;
    }
    else
        m.isAccessory = 0;
    
    
    if(_isEditMission)
    {
        
        [SVProgressHUD showWithStatus:@"任务修改中..."];

        dispatch_async(dispatch_get_main_queue(), ^{
            
            NSString * taskId = _taskId;
            
            BOOL isSendOK = [m sendMission:YES taksId:&taskId];
            
            if (isSendOK) {
                                
                [SVProgressHUD showSuccessWithStatus:@"任务修改成功"];
                
                [self hiddenKeyboard];
                _btnDoneClicked = YES;
                
                [self setData:m];
                
                [self.navigationController popViewControllerAnimated:YES];
            }
            else
            {
                [SVProgressHUD showSuccessWithStatus:@"任务修改失败"];
            }
            
        });
    }
    else
    {
        [self setData:m];
        
        [self.navigationController popViewControllerAnimated:YES];

    }
    

    
}

- (void)setData:(Mission *)mission
{
    NSMutableDictionary* dic = [NSMutableDictionary dictionary];
    
    [dic setObject:mission.createUserId forKey:@"userId"];
    
    if (mission.taskId != nil) {
        [dic setObject:self.taskId forKey:@"taskId"];
    }
    
    [dic setObject:mission.workGroupId forKey:@"workGroupId"];
    if(_workGroupName)
    {
        [dic setObject:_workGroupName forKey:@"workGroupName"];
    }

    [dic setObject:mission.main forKey:@"main"];
    [dic setObject:mission.title forKey:@"title"];
    
    BOOL isMission = YES;
    
    if (isMission) {
        [dic setObject:mission.liableUserId forKey:@"lableUserId"];
        if(mission.partList != nil)
            [dic setObject:mission.partList forKey:@"partList"];
        if(mission.cclist != nil)
            [dic setObject:mission.cclist forKey:@"ccList"];
        

        [dic setObject:mission.finishTime forKey:@"finishTime"];
        
        if(mission.remindTime != nil)
        {
            [dic setObject:mission.remindTime forKey:@"remindTime"];
        }
        else
        {
            [dic setObject:@"" forKey:@"remindTime"];
        }
    }
    
    [dic setObject:[NSString stringWithFormat:@"%d",mission.isLabel?1:0] forKey:@"isLabel"];

    if(mission.cclist.count > 0)
    {
        [dic setObject:mission.cclist forKey:@"ccList"];
    }
    
    if (mission.isLabel)
    {
        [dic setObject:mission.labelList forKey:@"labelList"];

        [dic setObject:_tagList forKey:@"cMarkList"];
    }
    
    [dic setObject:[NSString stringWithFormat:@"%d",mission.isAccessory?1:0]  forKey:@"isAccessory"];
    if (mission.isAccessory) {
        [dic setObject:mission.accessoryList forKey:@"accesList"];
        NSMutableArray* tA = [NSMutableArray array];
        for (int i = 0; i < mission.accessoryList.count; i++) {
            NSMutableDictionary* di = [NSMutableDictionary dictionary];
            
            Accessory* acc = [mission.accessoryList objectAtIndex:i];
            
            [di setObject:acc.name forKey:@"name"];
            [di setObject:acc.address forKey:@"address"];
            [di setObject:[NSString stringWithFormat:@"%ld",acc.source] forKey:@"source"];
            [tA addObject:di];
        }
        [dic setObject:tA forKey:@"accessoryList"];
    }
    [dic setObject:[NSString stringWithFormat:@"%ld",mission.type] forKey:@"type"];
    
    if(!mission.taskId)
    {
        [dic setObject:@"2" forKey:@"platform"];//来源平台：1：web  2：IOs  3：android  4:微信
    }

    if(_isMainMission)
    {
        [dic setObject:@"1" forKey:@"parentId"];//1是主任务 0子任务
    }
    else
    {
        [dic setObject:@"0" forKey:@"parentId"];//1是主任务 0子任务
    }
    
    if(_responsibleDic)
    {
        Member * m = _responsibleDic[0];
        
        [dic setObject:_responsibleDic forKey:@"respoDic"];
    }
    else if (_lableUserImg)
    {
        NSMutableArray * laArr = [NSMutableArray array];
        
        Member * m = [Member new];
        
        m.img = _lableUserImg;
//        m.userId = fd
    }
    if(_participantsIndexPathArray.count)
    {
        [dic setObject:_participantsIndexPathArray forKey:@"partiArr"];
    }
    if(_ccopyToMembersArray.count)
    {
        [dic setObject:_ccopyToMembersArray forKey:@"ccopyArr"];
    }
    
    [self saveData:dic];
}

- (void)saveData:(NSMutableDictionary *)dic
{
    NSMutableDictionary * misDic = [NSMutableDictionary dictionary];
    
    [misDic setObject:[dic valueForKey:@"title"] forKey:@"title"];
    
    if(!_isMainMission)
    {
        if(_parentId)
        {
            [dic setObject:_parentId forKey:@"parentId"];
        }
        
        [misDic setObject:dic forKey:@"missionDic"];
        
        [_savedChildMissionArr replaceObjectAtIndex:_currentEditChildIndex withObject:misDic];
        
        if(_savedChildMissionArr.count)
        {
            [self.icMissionMainViewController setValue:_savedChildMissionArr forKey:@"childMissionArr"];
        }
    }
    else
    {
        [misDic setObject:dic forKey:@"missionDic"];

        [self.icMissionMainViewController setValue:misDic forKey:@"mainMissionDic"];

    }

}

- (IBAction)btnBackButtonClicked:(id)sender
{
    [self hiddenKeyboard];
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (void) textFieldDidBeginEditing:(UITextField *)textField
{
    [self removeExistDatePickView];
}

- (void) removeExistDatePickView
{
    UIView *datePickView = [(UIView *)self.view viewWithTag: 1111];
    if(datePickView)
    {
        [datePickView removeFromSuperview];
    }
}

- (void) textViewDidBeginEditing:(UITextView *)textView
{
    [self removeExistDatePickView];
}

- (void) hiddenKeyboard
{
    [_titleTxt resignFirstResponder];
    [_txtView resignFirstResponder];
    
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    if (_btnDoneClicked) {
        if ([self.icGroupViewController respondsToSelector:@selector(setGroupId:)]) {
            [self.icGroupViewController setValue:_workGroupId forKey:@"groupId"];
        }
    }
    
    if ([self.icDetailViewController respondsToSelector:@selector(setContent:)]) {
        [self.icDetailViewController setValue:@"1" forKey:@"content"];
    }
    
    NSString * editStr = _isEditMission ? @"1" : @"0";
    
    if ([self.icMissionMainViewController respondsToSelector:@selector(setIsEdit:)]) {
        [self.icMissionMainViewController setValue:editStr forKey:@"isEdit"];
    }
    
    NSString * mainTaskId = @"";

    if(_isEditMission)
    {        
        if(_isMainMission)
        {
            mainTaskId = _taskId;
        }
        else
        {
            mainTaskId = [_currentMissionDic valueForKey:@"parentId"];
        }
    }
    if ([self.icMissionMainViewController respondsToSelector:@selector(setTaskId:)]) {
        [self.icMissionMainViewController setValue:mainTaskId forKey:@"taskId"];
    }
    if ([self.icMissionMainViewController respondsToSelector:@selector(setWorkGroupId:)]) {
        [self.icMissionMainViewController setValue:_workGroupId forKey:@"workGroupId"];
    }
    if ([self.icMissionMainViewController respondsToSelector:@selector(setWorkGroupName:)]) {
        [self.icMissionMainViewController setValue:_workGroupName forKey:@"workGroupName"];
    }

//    if ([self.icDetailViewController respondsToSelector:@selector(setIcMainViewController:)]) {
//        [self.icDetailViewController setValue:_icMainViewController forKey:@"icMainViewController"];
//    }
//    if ([self.icDetailViewController respondsToSelector:@selector(setIndexInMainArray:)]) {
//        [self.icDetailViewController setValue:[NSNumber numberWithInteger:_indexInMainArray] forKey:@"indexInMainArray"];
//    }
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
