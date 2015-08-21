//
//  ICWorkingDetailViewController.m
//  CommonFrame_Pro
//
//  Created by ionitech on 15/6/16.
//  Copyright (c) 2015年 ionitech. All rights reserved.
//

#import "ICWorkingDetailViewController.h"
#import <UIImageView+UIActivityIndicatorForSDWebImage.h>
#import <MJRefresh.h>
#import <CMPopTipView.h>

@interface ICWorkingDetailViewController() <UITableViewDataSource, UITableViewDelegate,YFInputBarDelegate,UITextViewDelegate,CMPopTipViewDelegate,UIAlertViewDelegate>
{
    
    

    NSMutableDictionary*        _reReplyDic;
    Mission*                    _currentMission;
    
    IBOutlet YFInputBar*        _inputBar;
    
    NSInteger                   _oriIndexRow;
    NSMutableArray*             _commentArray;
    NSMutableArray*             _attachmentImageHeightArray;
    BOOL                        _hasLoaded;
    CMPopTipView*               _navBarLeftButtonPopTipView;
    
    BOOL                        _hasDel;
    
    UIActivityIndicatorView* acInd ;

}


- (IBAction)btnBackButtonClicked:(id)sender;
- (IBAction)btnCommentButtonClicked:(id)sender;


@end

@implementation ICWorkingDetailViewController


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
    UIBarButtonItem *leftBarButton = [[UIBarButtonItem alloc]initWithCustomView:leftButton];
    self.navigationItem.leftBarButtonItem = leftBarButton;
    
    acInd = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(([UIScreen mainScreen].bounds.size.width - 40) / 2, [UIScreen mainScreen].bounds.size.height/ 2 - 80 , 40, 40)];
    [acInd setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleWhiteLarge];
    [acInd setHidesWhenStopped:YES];
    [self.view addSubview:acInd];
    
    [acInd startAnimating];
    dispatch_async(dispatch_queue_create("mcc", nil), ^{
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self loadData];
            
            _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height - 44 - 66) style:UITableViewStylePlain];
            [_tableView setBackgroundColor:[UIColor blackColor]];
            _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
            _tableView.dataSource = self;
            _tableView.delegate = self;
            _indexRow = 1099;
            _oriIndexRow = 0;
            [self.view addSubview:_tableView];
            
            
            NSArray* typeList = @[@"批示",@"评论"];
            _inputBar = [[YFInputBar alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY([UIScreen mainScreen].bounds) - 44 - 66, [UIScreen mainScreen].bounds.size.width, 44)];
            //[inputBar setFrame:CGRectMake(0, CGRectGetMaxY([UIScreen mainScreen].bounds) + 100, 320, 44)];
            _inputBar.delegate = self;
            _inputBar.clearInputWhenSend = YES;
            _inputBar.resignFirstResponderWhenSend = YES;
            _inputBar.relativeControl = (UIControl*)_tableView;
            _inputBar.typeList = typeList;
            _inputBar.parentController = self;
            _inputBar.dataCount = _replyList.count - 1;
            
            [self.view addSubview:_inputBar];
            
            [acInd stopAnimating];
        });
    });

    //_dataList = [NSMutableArray arrayWithObjects:@"1",@"2",@"3",@"4",@"5",@"6",@"7",@"8",@"9",@"10", nil];
    //_replyList = [NSMutableArray arrayWithObjects:@" ",@" ",@"回形针工具上线申请1！",@"回形针工具上线申请2！",@"回形针工具上线申请3！",@"回形针工具上线申请！",@"回形针工具上线申请！",@"回形针工具上线申请8！",@"回形针工具上线申请9！",@"回形针工具上线申请10！", nil];

    
   
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if (_tableView != nil) {
        CGRect frmae = _tableView.frame;
        if (frmae.size.width == 0 && frmae.size.height == 0) {
            _tableView.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height - 44 - 66);
        }
        if (_content != nil) {
            [self loadData];
            [_tableView reloadData];
        }
    }
}

- (void)loadData
{
    _replyList = [NSMutableArray array];
    [_replyList addObject:@""];
    [_replyList addObject:@""];
    [_replyList addObject:@""];
    
    
    _reReplyDic = [NSMutableDictionary dictionary];
    _currentMission = [Mission new];
    
    //self.taskId = @"1015072218310001";
    //self.taskId = @"1015072215290001";
    _commentArray = [NSMutableArray array];
    NSArray* commentsArray = [NSArray array];
    _currentMission = [Mission detail:_taskId commentArray:&commentsArray];
    
    if (_currentMission != nil) {
        
        if(_currentMission.createUserId == [LoginUser loginUserID])
        {
            UIButton *rightButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 29, 20)];
            [rightButton setImage:[UIImage imageNamed:@"btn_gengduo"] forState:UIControlStateNormal];
            [rightButton addTarget:self action:@selector(btnMenu) forControlEvents:UIControlEventTouchUpInside];
            
            UIBarButtonItem *rightBarButton = [[UIBarButtonItem alloc]initWithCustomView:rightButton];
            self.navigationItem.rightBarButtonItem = rightBarButton;
        }
        
        if (commentsArray.count > 0) {
            _commentArray = [NSMutableArray arrayWithArray:commentsArray];
            int i = 0;
            
            for (Comment* pComment in commentsArray) {
                
                [_replyList addObject:pComment.main];
                
                if (pComment.hasChild) {
                    
                    NSString* key = [NSString stringWithFormat:@"ReIndex%d",i];
                    NSMutableArray* childCommentsArray = [NSMutableArray array];
                    for (Comment* cComment in pComment.comments) {
                        [childCommentsArray addObject:cComment.main];
                    }
                    
                    [_reReplyDic setObject:childCommentsArray forKey:key];
                    
                }
                i++;
            }
            
        }
        
    }
    
}

- (void)btnMenu
{
    if (_navBarLeftButtonPopTipView == nil) {
        UIView* view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 100, 150)];
        [view setBackgroundColor:[UIColor blackColor]];
        
        UILabel* line1 = [[UILabel alloc] initWithFrame:CGRectMake(5, 14.5, view.frame.size.width - 10, 0.5)];
        [line1 setBackgroundColor:[UIColor grayColor]];
        //[view addSubview:line1];
        
        UIButton* edit = [[UIButton alloc] initWithFrame:CGRectMake(0, 5, view.frame.size.width, 44)];
        [edit setBackgroundColor:[UIColor clearColor]];
        NSMutableAttributedString* attriNormal = [[NSMutableAttributedString alloc]
                                                  initWithString:@"编辑"
                                                  attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:15],
                                                               NSForegroundColorAttributeName:[UIColor colorWithHexString:@"#3c9ed7"]}];
        [edit setAttributedTitle:attriNormal forState:UIControlStateNormal];
        [edit addTarget:self action:@selector(btnEditClicked:) forControlEvents:UIControlEventTouchUpInside];
        [view addSubview:edit];
        
        UILabel* line2 = [[UILabel alloc] initWithFrame:CGRectMake(5, edit.frame.origin.y + edit.frame.size.height + 0.5, view.frame.size.width - 10, 0.5)];
        [line2 setBackgroundColor:[UIColor grayColor]];
        [view addSubview:line2];
        
        UIButton* delete = [[UIButton alloc] initWithFrame:CGRectMake(0, edit.frame.origin.y + edit.frame.size.height + 1, view.frame.size.width, 44)];
        [delete setBackgroundColor:[UIColor clearColor]];
        NSMutableAttributedString* dattriNormal = [[NSMutableAttributedString alloc]
                                                  initWithString:@"删除"
                                                  attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:15],
                                                               NSForegroundColorAttributeName:[UIColor colorWithHexString:@"#3c9ed7"]}];
        [delete setAttributedTitle:dattriNormal forState:UIControlStateNormal];
        [delete addTarget:self action:@selector(btnRemoveClicked:) forControlEvents:UIControlEventTouchUpInside];
        [view addSubview:delete];
        
        UILabel* line3 = [[UILabel alloc] initWithFrame:CGRectMake(5, delete.frame.origin.y + delete.frame.size.height + 0.5, view.frame.size.width - 10, 0.5)];
        [line3 setBackgroundColor:[UIColor grayColor]];
        [view addSubview:line3];
        
        UILabel* close = [[UILabel alloc] initWithFrame:CGRectMake(0, delete.frame.origin.y + delete.frame.size.height + 15, view.frame.size.width, 20)];
        [close setBackgroundColor:[UIColor clearColor]];
        [close setText:@"关闭"];
        [close setFont:[UIFont systemFontOfSize:14]];
        [close setTextColor:[UIColor whiteColor]];
        [close setTextAlignment:NSTextAlignmentCenter];
        [view addSubview:close];
        
        _navBarLeftButtonPopTipView = [[CMPopTipView alloc] initWithCustomView:view];
        [_navBarLeftButtonPopTipView setHas3DStyle:NO];
        [_navBarLeftButtonPopTipView setBackgroundColor:[UIColor blackColor]];
        [_navBarLeftButtonPopTipView setBorderColor:[UIColor clearColor]];
        [_navBarLeftButtonPopTipView setCornerRadius:3.0f];
        _navBarLeftButtonPopTipView.delegate = self;
        [_navBarLeftButtonPopTipView presentPointingAtBarButtonItem:self.navigationItem.rightBarButtonItem animated:YES];
        
        // Dismiss a CMPopTipView
        //[_navBarLeftButtonPopTipView dismissAnimated:YES];
    }
    else
        [_navBarLeftButtonPopTipView presentPointingAtBarButtonItem:self.navigationItem.rightBarButtonItem animated:YES];
}

- (IBAction)btnBackButtonClicked:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)btnCommentButtonClicked:(id)sender
{
    //NSInteger index = _replyList.count;
    
    //NSIndexPath* indexPath = [NSIndexPath indexPathForRow:index inSection:0];
    //NSMutableArray* indexPaths = [NSMutableArray arrayWithObject:indexPath];
    
     //[_dataList addObject:@"11"];
    
    //[_tableView beginUpdates];
    //[_tableView insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationMiddle];
    //[_tableView endUpdates];
    
    NSIndexPath* buttomIndexPath = [NSIndexPath indexPathForRow:_replyList.count-1 inSection:0];
    [_tableView scrollToRowAtIndexPath:buttomIndexPath atScrollPosition:UITableViewScrollPositionBottom animated:YES];
   
    [_inputBar.textField becomeFirstResponder];
    
    _indexRow = 1099;
    
}

#pragma -
#pragma CMPopDelegate Action

- (void)btnEditClicked:(id)sender
{
    NSArray* responsibleA = [NSArray array];
    NSArray* participantA = [NSArray array];
    NSArray* copyToA = [NSArray array];
    NSArray* labelA = [NSArray array];
    NSArray* accessoryA = [NSArray array];
    Mission* m = [Mission missionInfo:_currentMission.taskId responsible:&responsibleA participants:&participantA copyTo:&copyToA labels:&labelA accessories:&accessoryA];
    
    switch (_currentMission.type) {
        case 1:
        {
            UIStoryboard* mainStory = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
            UIViewController* vc;
            vc = [mainStory instantiateViewControllerWithIdentifier:@"ICPublishMissionViewController"];
            ((ICPublishMissionViewController*)vc).workGroupId = _currentMission.workGroupId;
            ((ICPublishMissionViewController*)vc).userId = [LoginUser loginUserID];
            
            ((ICPublishMissionViewController*)vc).responsibleDic = responsibleA;
            ((ICPublishMissionViewController*)vc).participantsIndexPathArray = participantA;
            ((ICPublishMissionViewController*)vc).ccopyToMembersArray = copyToA;
            ((ICPublishMissionViewController*)vc).cMarkAarry = labelA;
            ((ICPublishMissionViewController*)vc).cAccessoryArray = accessoryA;
            ((ICPublishMissionViewController*)vc).strFinishTime = _currentMission.finishTime;
            ((ICPublishMissionViewController*)vc).strRemindTime = _currentMission.remindTime;
            ((ICPublishMissionViewController*)vc).title = m.title;
            ((ICPublishMissionViewController*)vc).content = m.main;
            ((ICPublishMissionViewController*)vc).taskId = m.taskId;
            ((ICPublishMissionViewController*)vc).workGroupId = m.workGroupId;
            ((ICPublishMissionViewController*)vc).icDetailViewController = self;
            [self.navigationController pushViewController:vc animated:YES];
            break;
        }
        case 2:
        {
            UIStoryboard* mainStory = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
            UIViewController* vc;
            vc = [mainStory instantiateViewControllerWithIdentifier:@"ICPublishSharedAndNotifyViewController"];
            ((ICPublishSharedAndNotifyViewController*)vc).isShared = 1;
            ((ICPublishSharedAndNotifyViewController*)vc).ccopyToMembersArray = copyToA;
            ((ICPublishSharedAndNotifyViewController*)vc).cAccessoryArray = accessoryA;
            ((ICPublishSharedAndNotifyViewController*)vc).cMarkAarry = labelA;
            ((ICPublishSharedAndNotifyViewController*)vc).titleName = m.title;
            ((ICPublishSharedAndNotifyViewController*)vc).content = m.main;
            ((ICPublishSharedAndNotifyViewController*)vc).taskId = m.taskId;
            ((ICPublishSharedAndNotifyViewController*)vc).workGroupId = m.workGroupId;
            ((ICPublishSharedAndNotifyViewController*)vc).icDetailViewController = self;
            [self.navigationController pushViewController:vc animated:YES];
            break;
        }
        case 3:
        {
            UIStoryboard* mainStory = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
            UIViewController* vc;
            vc = [mainStory instantiateViewControllerWithIdentifier:@"ICPublishSharedAndNotifyViewController"];
            ((ICPublishSharedAndNotifyViewController*)vc).isShared = 3;
            ((ICPublishSharedAndNotifyViewController*)vc).ccopyToMembersArray = copyToA;
            ((ICPublishSharedAndNotifyViewController*)vc).cAccessoryArray = accessoryA;
            ((ICPublishSharedAndNotifyViewController*)vc).cMarkAarry = labelA;
            ((ICPublishSharedAndNotifyViewController*)vc).titleName = m.title;
            ((ICPublishSharedAndNotifyViewController*)vc).content = m.main;
            ((ICPublishSharedAndNotifyViewController*)vc).taskId = m.taskId;
            ((ICPublishSharedAndNotifyViewController*)vc).workGroupId = m.workGroupId;
            ((ICPublishSharedAndNotifyViewController*)vc).icDetailViewController = self;
            [self.navigationController pushViewController:vc animated:YES];
            break;
        }
        case 8:
        {
            UIStoryboard* mainStory = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
            UIViewController* vc;
            vc = [mainStory instantiateViewControllerWithIdentifier:@"ICPublishSharedAndNotifyViewController"];
            ((ICPublishSharedAndNotifyViewController*)vc).isShared = 2;
            ((ICPublishSharedAndNotifyViewController*)vc).ccopyToMembersArray = copyToA;
            ((ICPublishSharedAndNotifyViewController*)vc).cAccessoryArray = accessoryA;
            ((ICPublishSharedAndNotifyViewController*)vc).cMarkAarry = labelA;
            ((ICPublishSharedAndNotifyViewController*)vc).titleName = m.title;
            ((ICPublishSharedAndNotifyViewController*)vc).content = m.main;
            ((ICPublishSharedAndNotifyViewController*)vc).taskId = m.taskId;
            ((ICPublishSharedAndNotifyViewController*)vc).workGroupId = m.workGroupId;
            ((ICPublishSharedAndNotifyViewController*)vc).icDetailViewController = self;
            [self.navigationController pushViewController:vc animated:YES];
            break;
        }
        default:
            break;
    }
    [_navBarLeftButtonPopTipView dismissAnimated:YES];
}

- (void)btnRemoveClicked:(id)sender
{
    [_navBarLeftButtonPopTipView dismissAnimated:YES];
    
    UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"确定删除该条任务吗？" delegate:self cancelButtonTitle:@"不，请保留！" otherButtonTitles:@"是的", nil];
    [alert show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1) {
        BOOL isRemoved = [Mission reomveMission:_currentMission.taskId];
        if (isRemoved) {
            _hasDel = YES;
            [self.navigationController popViewControllerAnimated:YES];
        }
    }
}

- (void)btnPraiseClicked:(UIButton*)btn
{
    NSInteger cIndex = btn.tag;

    Comment* comm = [_commentArray objectAtIndex:cIndex];
    
    dispatch_sync(dispatch_queue_create("praise", nil), ^{
        BOOL hasPraised = [Comment praise:comm.commentsId workGroupId:_currentMission.workGroupId hasPraised:!comm.isPraised];
        if (hasPraised) {
            //NSString* txt = btn.titleLabel.text;
            NSInteger iVal = comm.praiseNum;
            if (comm.isPraised)
                iVal--;
            else
                iVal++;
            btn.titleLabel.text = [NSString stringWithFormat:@"%ld",iVal];
            NSMutableAttributedString* parNor = [[NSMutableAttributedString alloc]
                                                 initWithString:[NSString stringWithFormat:@"%ld",iVal] attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:10],NSForegroundColorAttributeName:[UIColor whiteColor]}];
            [btn setAttributedTitle:parNor forState:UIControlStateNormal];
            
            comm.praiseNum = iVal;
            comm.isPraised = !comm.isPraised;
            
            [_commentArray insertObject:comm atIndex:cIndex];
            [_commentArray removeObjectAtIndex:(cIndex + 1)];
        }
    });
    
    
}


- (void)popTipViewWasDismissedByUser:(CMPopTipView *)popTipView
{
    NSLog(@"a");
}


#pragma -  
#pragma TableView Action

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat height = 44;
    
    NSInteger index = indexPath.row;
    if (index == 0) {
        height = 58;
    }
    else if (index == 1)
    {
        height = 38;
    }
    else if (index == 2) {
        
        
        UITableViewCell *cell = [self tableView:_tableView cellForRowAtIndexPath:indexPath];
        return cell.frame.size.height;
        
        //height = 280;
    }
    else
    {
        //CGFloat contentWidth = _tableView.frame.size.width;
        CGFloat contentWidth = [UIScreen mainScreen].bounds.size.width - 45 - 60;
        NSString *content = [_replyList objectAtIndex:index];
        content = [@"\t\t\t" stringByAppendingString:content];
        UIFont *font = [UIFont systemFontOfSize:14];

        height = [self contentHeight:content vWidth:contentWidth contentFont:font];
        
        NSString* key = [NSString stringWithFormat:@"ReIndex%d",(int)(index - 3)];
        id obj = [_reReplyDic valueForKey:key];
        if ([obj isKindOfClass:[NSArray class]]) {
            NSArray* reArray = [NSArray arrayWithArray:(NSArray *)obj];
            if (reArray.count > 0) {
                BOOL isAppend = NO;
                
                height = 60 + 8 * reArray.count;
                
                for (int i = 0; i< reArray.count; i++) {
                    NSString* cc = [reArray objectAtIndex:i];
                    CGFloat ch = [self contentHeight:cc vWidth:contentWidth contentFont:font];
                    height = height + ch;
                    
                    if (ch > 20 && reArray.count == 1) {
                        isAppend = YES;
                    }
                    
                    //reHeight = reHeight + (reLabelHeight* (i + 1)) + height * i;
                }
                
                if (isAppend) {
                    height = height + 10;
                }
                
                //height = height + 10;
            }
        }
        
        if (height < 60) {
            height = 60;
        }
        
    }
 
    return height;
}

-(CGFloat)contentHeight:(NSString*)content vWidth:(CGFloat)width contentFont:(UIFont*)font
{
    CGFloat height = 1;
    NSDictionary *attribute = @{NSFontAttributeName: font};
    CGSize size = [content boundingRectWithSize:CGSizeMake(width, 0) options:NSStringDrawingTruncatesLastVisibleLine |
                   NSStringDrawingUsesLineFragmentOrigin |
                   NSStringDrawingUsesFontLeading attributes:attribute context:nil].size;
    
    return height + size.height;
}

- (CGFloat)colorWithRGB:(NSInteger)value
{
    CGFloat re = 0;
    
    re = value / 255.0f;
    
    return re;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _replyList.count;
}

- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = (UITableViewCell *)[tableView cellForRowAtIndexPath:indexPath];
    UIView *selectionColor = [[UIView alloc] init];
    selectionColor.backgroundColor = [UIColor cellHoverBackgroundColor];
    cell.selectedBackgroundView = selectionColor;
    
    NSInteger index = indexPath.row;
    CGFloat cWidth = [UIScreen mainScreen].bounds.size.width;

    if (index == 0) {
        UILabel* bottomLine = [[UILabel alloc] initWithFrame:CGRectMake(0, 58 - 0.5, cWidth, 0.5)];
        [bottomLine setBackgroundColor:[UIColor grayColor]];
        [cell.selectedBackgroundView addSubview:bottomLine];
    }
    else if (index == 1)
    {
        UILabel* bottomLine = [[UILabel alloc] initWithFrame:CGRectMake(0, 38 - 0.5, cWidth, 0.5)];
        [bottomLine setBackgroundColor:[UIColor grayColor]];
        [cell.selectedBackgroundView addSubview:bottomLine];
    }
    else if (index == 2)
    {
        CGFloat newcHeight = [self tableView:tableView heightForRowAtIndexPath:indexPath];

        UILabel* bottomLine = [[UILabel alloc] initWithFrame:CGRectMake(0, newcHeight - 1, cWidth, 0.5)];
        [bottomLine setBackgroundColor:[UIColor grayColor]];
        [cell.selectedBackgroundView addSubview:bottomLine];
    }
    else if (index > 2)
    {
        CGFloat cHeight = [self tableView:_tableView heightForRowAtIndexPath:indexPath];

        UILabel* bottomLine = [[UILabel alloc] initWithFrame:CGRectMake(0, cHeight - 1, cWidth, 0.5)];
        [bottomLine setBackgroundColor:[UIColor grayColor]];
        [cell.selectedBackgroundView addSubview:bottomLine];
    }
    return YES;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger index = indexPath.row;
    
    static NSString *cellId = @"WorkingDetailTableViewCellIdentitifer";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];

    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
    }
    
    
    for(UIView *view in cell.contentView.subviews) {
        [view removeFromSuperview];
    }
    
    CGFloat cWidth = [UIScreen mainScreen].bounds.size.width;
    //CGFloat cHeight = [self tableView:_tableView heightForRowAtIndexPath:indexPath];
    
    if (index == 0) {
        UIImageView* photo = [[UIImageView alloc] initWithFrame:CGRectMake(11, 11, 36, 36)];
        [photo setBackgroundColor:[UIColor clearColor]];
        //[photo setImage:[UIImage imageNamed:@"icon_chengyuan"]];
        [photo setImageWithURL:[NSURL URLWithString:_currentMission.userImg] placeholderImage:[UIImage imageNamed:@"icon_chengyuan"] options:SDWebImageDelayPlaceholder usingActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        [cell.contentView addSubview:photo];
        
        UILabel* title = [[UILabel alloc] initWithFrame:CGRectMake(52, 20, cWidth - 62, 20)];
        [title setBackgroundColor:[UIColor clearColor]];
        [title setText:[NSString stringWithFormat:@"%@  %@",_currentMission.userName,_currentMission.workGroupName]];
        [title setTextColor:[UIColor whiteColor]];
        [title setFont:[UIFont boldSystemFontOfSize:15]];
        
        [cell.contentView addSubview:title];
        
        UILabel* bottomLine = [[UILabel alloc] initWithFrame:CGRectMake(0, 58 - 1, cWidth, 0.5)];
        [bottomLine setBackgroundColor:[UIColor grayColor]];
        [cell.contentView addSubview:bottomLine];
    }
    else if (index == 1)
    {
        UILabel* title = [[UILabel alloc] initWithFrame:CGRectMake(11, 0, cWidth - 11, 38)];
        [title setBackgroundColor:[UIColor clearColor]];
        if(!_currentMission.title.length)
        {
            title.text = @"无标题";
        }
        else
        {
            [title setText:_currentMission.title];
        }
        [title setTextColor:[UIColor whiteColor]];
        [title setFont:[UIFont boldSystemFontOfSize:14]];
        
        [cell.contentView addSubview:title];
        
        UILabel* bottomLine = [[UILabel alloc] initWithFrame:CGRectMake(0, 38 - 0.5, cWidth, 0.5)];
        [bottomLine setBackgroundColor:[UIColor grayColor]];
        [cell.contentView addSubview:bottomLine];
    }
    else if (index == 2) {
        
        NSString* content = _currentMission.main;
        CGFloat contentWidth = cWidth - 22;
        UIFont* font = [UIFont systemFontOfSize:13];
        
        CGFloat contentHeight = [self contentHeight:content vWidth:contentWidth contentFont:font];
        
        __block CGFloat newcHeight = contentHeight + 35 + 16;
        
        UILabel* title = [[UILabel alloc] initWithFrame:CGRectMake(11, 11, contentWidth, contentHeight)];
        [title setBackgroundColor:[UIColor clearColor]];
        [title setNumberOfLines:0];
        [title setText:content];
        [title setTextColor:[UIColor grayColor]];
        [title setFont:font];
        [cell.contentView addSubview:title];
        
        BOOL hasAccessory = _currentMission.isAccessory;
        
        if (hasAccessory) {
            NSArray* accArr = [NSArray arrayWithArray:_currentMission.accessoryList];
            
            CGFloat accHeight = 200;
            CGFloat intevalHeight = 7;
            
            UIView* attchView = [[UIView alloc] initWithFrame:CGRectMake(11, contentHeight + title.frame.origin.y + 4, cWidth - 22, accArr.count * (accHeight + intevalHeight))];
            [attchView setBackgroundColor:[UIColor clearColor]];
            
            __block CGFloat nextHeight = 0;
            __block int i = 0;
            for (Accessory* acc in accArr) {
                
                UIView* acView = [[UIView alloc] initWithFrame:CGRectMake(0, (accHeight + intevalHeight) * i, attchView.frame.size.width, accHeight + intevalHeight)];
                [acView setBackgroundColor:[UIColor clearColor]];
                
                
                UIImageView* attachment;
                attachment = [[UIImageView alloc] initWithFrame:CGRectMake(0, intevalHeight, acView.frame.size.width, accHeight)];
                __weak typeof(attachment) attachmentWeak = attachment;
                //[attachment setImageWithURL:[NSURL URLWithString:acc.address] placeholderImage:[UIImage imageNamed:@"bimg.jpg"] options:SDWebImageDelayPlaceholder usingActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
                __weak typeof (_tableView) _weakTable = _tableView;
                [attachment setImageWithURL:[NSURL URLWithString:acc.address] placeholderImage:[UIImage imageNamed:@"bimg.jpg"] options:SDWebImageDelayPlaceholder
                                  completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                                      
                                      CGSize size = image.size;
                                      CGFloat w2h = size.width / size.height;
                                      int nh = (cWidth - 22) / w2h;
                                      
                                      attachmentWeak.frame = CGRectMake(0, intevalHeight, attchView.frame.size.width, nh + intevalHeight);
                                      acView.frame = CGRectMake(0, nextHeight, attchView.frame.size.width, nh + intevalHeight);
                                      newcHeight =  newcHeight  + intevalHeight + nh + intevalHeight;
                                      nextHeight = acView.frame.origin.y + intevalHeight + nh + intevalHeight;
                                      
                                      i++;
                                      if (i == accArr.count) {
                                          if (!_hasLoaded) {
                                              _hasLoaded = YES;
                                              [cell setFrame:CGRectMake(0, 0, attchView.frame.size.width, newcHeight)];
                                              [_weakTable reloadRowsAtIndexPaths:[NSArray arrayWithObjects:indexPath,nil] withRowAnimation:UITableViewRowAnimationMiddle];
                                          }
                                          
                                      }
                                      
                                  } usingActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
                [attachment.layer setMasksToBounds:YES];
                
                /*
                int nh = 0;
                if (_attachmentImageHeightArray.count > 0) {
                    nh = [[_attachmentImageHeightArray objectAtIndex:i] intValue];
                }
                else
                {
                    CGImageSourceRef cImageSource = CGImageSourceCreateWithURL((__bridge CFURLRef)[NSURL URLWithString:acc.address], NULL);
                    CGImageRef ir = CGImageSourceCreateImageAtIndex(cImageSource, 0, NULL);
                    UIImage* ig = [UIImage imageWithCGImage:ir];
                    
                    CGSize size = ig.size;
                    
                    CGFloat w2h = size.width / size.height;
                    nh = (cWidth - 22) / w2h;
                }
                attachment.frame = CGRectMake(0, (accHeight + intevalHeight) * i, attchView.frame.size.width, nh + intevalHeight);
                */
                
                [acView addSubview:attachment];
                
//                UIImageView* attachmentIcon = [[UIImageView alloc] initWithFrame:CGRectMake(5, 0, 15, 13)];
//                [attachmentIcon setImage:[UIImage imageNamed:@"icon_fujian"]];
//                [acView addSubview:attachmentIcon];
                
                [attchView addSubview:acView];
                
            }
            
            [cell.contentView addSubview:attchView];
        }
        
        //日期
        UIView* bView = [[UIView alloc] initWithFrame:CGRectMake(0, newcHeight - 35, cWidth, 35)];
        [bView setBackgroundColor:[UIColor clearColor]];
        
        UILabel* time = [[UILabel alloc] initWithFrame:CGRectMake(11, 14, 60, 12)];
        [time setBackgroundColor:[UIColor clearColor]];
        [time setNumberOfLines:0];
        [time setText:[NSString stringWithFormat:@"%@ %@",_currentMission.monthAndDay,_currentMission.hour]];
        [time setTextAlignment:NSTextAlignmentRight];
        [time setTextColor:[UIColor whiteColor]];
        [time setFont:[UIFont systemFontOfSize:10]];
        [bView addSubview:time];
        
        UIButton* btnDelete = [[UIButton alloc] initWithFrame:CGRectMake(time.frame.origin.x + time.frame.size.width + 15, 14, 28, 12)];
        [btnDelete setBackgroundColor:[UIColor clearColor]];
        NSMutableAttributedString* attriNormal = [[NSMutableAttributedString alloc]
                                                  initWithString:@"删除"
                                                  attributes:@{
                                                               NSFontAttributeName:[UIFont systemFontOfSize:13],
                                                               NSForegroundColorAttributeName:[UIColor colorWithHexString:@"#3c9ed7"]}];
        NSMutableAttributedString* attriHig = [[NSMutableAttributedString alloc]
                                               initWithString:@"删除" attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:10],NSForegroundColorAttributeName:[UIColor grayColor]}];
        [btnDelete setAttributedTitle:attriNormal forState:UIControlStateNormal];
        [btnDelete setAttributedTitle:attriHig forState:UIControlStateHighlighted];
        //[bView addSubview:btnDelete];
        
        
        UIButton* btnEdit = [[UIButton alloc] initWithFrame:CGRectMake(btnDelete.frame.origin.x + btnDelete.frame.size.width + 15, 14, 28, 12)];
        [btnEdit setBackgroundColor:[UIColor clearColor]];
        NSMutableAttributedString* eattriNormal = [[NSMutableAttributedString alloc]
                                                  initWithString:@"编辑" attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:13],NSForegroundColorAttributeName:[UIColor colorWithRed:[self colorWithRGB:60] green:[self colorWithRGB:159] blue:[self colorWithRGB:215] alpha:1.0f]}];
        NSMutableAttributedString* eattriHig = [[NSMutableAttributedString alloc]
                                               initWithString:@"编辑" attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:10],NSForegroundColorAttributeName:[UIColor grayColor]}];
        [btnEdit setAttributedTitle:eattriNormal forState:UIControlStateNormal];
        [btnEdit setAttributedTitle:eattriHig forState:UIControlStateHighlighted];
        //[bView addSubview:btnEdit];
        
        
        UIButton* btnComment = [[UIButton alloc] initWithFrame:CGRectMake(cWidth - 27, 14, 15, 15)];
        [btnComment setBackgroundColor:[UIColor clearColor]];
        [btnComment setImage:[UIImage imageNamed:@"btn_pinglun"] forState:UIControlStateNormal];
        [btnComment addTarget:self action:@selector(btnCommentButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        [bView addSubview:btnComment];
        
        [cell.contentView addSubview:bView];
        
        UILabel* bottomLine = [[UILabel alloc] initWithFrame:CGRectMake(0, newcHeight - 1, cWidth, 0.5)];
        [bottomLine setBackgroundColor:[UIColor grayColor]];
        [cell.contentView addSubview:bottomLine];
        
        [cell setFrame:CGRectMake(0, 0, cWidth ,newcHeight)];
    }
    else if (index > 2)
    {
        //cell.textLabel.text = [_dataList objectAtIndex:index];
        if (cell.contentView.subviews.count < 4) {
            
            NSInteger cIndex = index - 3;
            
            Comment* comm = [_commentArray objectAtIndex:cIndex];
            
            UIImageView* photo = [[UIImageView alloc] initWithFrame:CGRectMake(11, 11, 36, 36)];
            //[photo setImage:[UIImage imageNamed:@"icon_chengyuan"]];
            [photo setImageWithURL:[NSURL URLWithString:comm.userImg] placeholderImage:[UIImage imageNamed:@"icon_chengyuan"] options:SDWebImageDelayPlaceholder usingActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
            [cell.contentView addSubview:photo];
            
            UIFont* font = [UIFont systemFontOfSize:14];
            
            UILabel* name = [[UILabel alloc] initWithFrame:CGRectMake(photo.frame.origin.x + photo.frame.size.width + 6, photo.frame.origin.y, 100, 15)];
            [name setBackgroundColor:[UIColor clearColor]];
            [name setText:comm.userName];
            [name setTextColor:[UIColor colorWithHexString:@"#3c9ed7"]];
            [name setFont:font];
            [name setTextAlignment:NSTextAlignmentLeft];
            
            [cell.contentView addSubview:name];
            
            CGFloat reContentWidth = cWidth - 45 - 60;
            CGFloat reHeight = name.frame.size.height + name.frame.origin.y;
            
            CGFloat reLabelHeight = 8;
            
            NSString* key = [NSString stringWithFormat:@"ReIndex%d",(int)cIndex];
            NSInteger reCount = 0;
            CGFloat height = 15;
            
            id obj = [_reReplyDic valueForKey:key];
            if ([obj isKindOfClass:[NSArray class]] && comm.comments.count > 0)
            {
                NSArray* reArray = [NSArray arrayWithArray:(NSArray *)obj];
                reCount = reArray.count;
                
                if (reCount > 0) {
                    
                    //[name setText:[LoginUser loginUserName]];
                    CGFloat teHeight = 0;
                    CGFloat preControlHeight = 0;
                    int j = 0;
                    for (int i = (int)reArray.count - 1; i >= 0 ; i--)
                    {
                        NSString* cStr = [reArray objectAtIndex:j];
                        
                        cStr = [@"\t\t\t" stringByAppendingString:cStr];
                        
                        CGFloat height = [self contentHeight:cStr vWidth:reContentWidth contentFont:font];
                        if (j == 0) {
                            teHeight = reHeight + (reLabelHeight* (j + 1)) + height * j + 20;
                        }
                        else
                        {
                            teHeight = teHeight + preControlHeight + 3;
                        }
                        
                        preControlHeight = height;
                        
                        Comment* cComm = [comm.comments objectAtIndex:i];
                        
                        UILabel* rev = [[UILabel alloc] initWithFrame:CGRectMake(name.frame.origin.x, teHeight, 90, 15)];
                        [rev setBackgroundColor:[UIColor clearColor]];
                        [rev setText:(cComm.level == 1 ? [NSString stringWithFormat:@"%@@批示:",cComm.userName]: [NSString stringWithFormat:@"%@@评论:",cComm.userName])];
                        [rev setTextColor:[UIColor colorWithHexString:@"#09f4a6"]];
                        [rev setFont:font];
                        [rev setTextAlignment:NSTextAlignmentRight];
                        
                        [cell.contentView addSubview:rev];
                        
                        
                        UILabel* revContent = [[UILabel alloc] initWithFrame:CGRectMake(rev.frame.origin.x + 15, teHeight - 2, reContentWidth, height)];
                        [revContent setBackgroundColor:[UIColor clearColor]];
                        [revContent setText:cStr];
                        [revContent setTextColor:[UIColor whiteColor]];
                        [revContent setFont:font];
                        [revContent setNumberOfLines:0];
                        [revContent setTextAlignment:NSTextAlignmentLeft];
                        
                        [cell.contentView addSubview:revContent];
                        
                        if (reCount == (j+1)) {
                            reHeight = teHeight;
                        }
                        j++;
                    }
                }
            }
            
            reHeight =  reCount == 0 ? 34 : reHeight + reLabelHeight + height;
            
            UILabel* rev = [[UILabel alloc] initWithFrame:CGRectMake(name.frame.origin.x, 34, 50, height)];

            [rev setBackgroundColor:[UIColor clearColor]];
            [rev setText:(comm.level == 1?@"批示：":(reCount < 0 ? [NSString stringWithFormat:@"%@:",comm.userName] : @""))];
            [rev setTextColor:comm.level == 1?[UIColor colorWithHexString:@"#09f4a6"]:[UIColor colorWithHexString:@"#3c9ed7"]];
            [rev setFont:font];
            [rev setTextAlignment:NSTextAlignmentRight];
            
            [cell.contentView addSubview:rev];
            
            
            UILabel* revContent = [[UILabel alloc] initWithFrame:CGRectMake(rev.frame.origin.x + 2 + ([rev.text isEqualToString:@""] ? 10 : rev.frame.size.width), 34, reContentWidth, height)];
            [revContent setBackgroundColor:[UIColor clearColor]];
            [revContent setText:[_replyList objectAtIndex:index]];
            [revContent setTextColor:[UIColor whiteColor]];
            [revContent setFont:font];
            [revContent setTextAlignment:NSTextAlignmentLeft];
            
            [cell.contentView addSubview:revContent];
            
            UILabel* date = [[UILabel alloc] initWithFrame:CGRectMake(cWidth - 60, 7, 45, 15)];
            [date setBackgroundColor:[UIColor clearColor]];
            [date setText:comm.hourStr];
            [date setTextColor:[UIColor colorWithRed:[self colorWithRGB:122] green:[self colorWithRGB:122] blue:[self colorWithRGB:122] alpha:1.0f]];
            [date setFont:[UIFont systemFontOfSize:8]];
            [date setTextAlignment:NSTextAlignmentRight];
            
            //[cell.contentView addSubview:date];
            
            UIButton* par = [[UIButton alloc] initWithFrame:CGRectMake(cWidth - 50, date.frame.origin.y + date.frame.size.height + 5, 30, 20)];
            //[par setTitle:@"20" forState:UIControlStateNormal];
            [par setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            [par setBackgroundColor:[UIColor clearColor]];
            [par.layer setBorderWidth:0.5f];
            [par.layer setCornerRadius:10];
            [par.layer setBorderColor:[[UIColor whiteColor] CGColor]];
            [par addTarget:self action:@selector(btnPraiseClicked:) forControlEvents:UIControlEventTouchUpInside];
            [par setTag:cIndex];
            
            NSMutableAttributedString* parHig = [[NSMutableAttributedString alloc]
                                                 initWithString:[NSString stringWithFormat:@"%ld",comm.praiseNum] attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:10],NSForegroundColorAttributeName:[UIColor grayColor]}];
            [par setAttributedTitle:parHig forState:UIControlStateHighlighted];
            
            NSMutableAttributedString* parNor = [[NSMutableAttributedString alloc]
                                                 initWithString:[NSString stringWithFormat:@"%ld",comm.praiseNum] attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:10],NSForegroundColorAttributeName:[UIColor whiteColor]}];
            [par setAttributedTitle:parNor forState:UIControlStateNormal];
            
            [cell.contentView addSubview:par];
            
            CGFloat cHeight = [self tableView:_tableView heightForRowAtIndexPath:indexPath];
            
            UILabel* bottomLine = [[UILabel alloc] initWithFrame:CGRectMake(0, cHeight - 1, cWidth, 0.5)];
            [bottomLine setBackgroundColor:[UIColor grayColor]];
            [cell.contentView addSubview:bottomLine];
            
        }
        
    }
    
    [cell.contentView setBackgroundColor:[UIColor colorWithRed:0.15f green:0.15f blue:0.15f alpha:1.0f]];
    //[cell.contentView setBackgroundColor:[UIColor colorWithHexString:@"2f2e33"]];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (_navBarLeftButtonPopTipView.hasShadow) {
        [_navBarLeftButtonPopTipView dismissAnimated:YES];
    }
    
    _oriIndexRow = 0;
    
    if (indexPath.row < 3) {
        //NSIndexPath* buttomIndexPath = [NSIndexPath indexPathForRow:_replyList.count-1 inSection:0];
        NSIndexPath* buttomIndexPath = [NSIndexPath indexPathForRow:1 inSection:0];
        [_inputBar.textField becomeFirstResponder];
        [_tableView scrollToRowAtIndexPath:buttomIndexPath atScrollPosition:UITableViewScrollPositionBottom animated:YES];
        
        _indexRow = 1099;
    }
    else
    {
        _indexRow = indexPath.row;
        BOOL hasLoad = NO;
         NSString* key = [NSString stringWithFormat:@"ReIndex%d",(int)(_indexRow - 3)];
        id obj = [_reReplyDic valueForKey:key];
        if ([obj isKindOfClass:[NSArray class]])
        {
            NSArray* reArray = [NSArray arrayWithArray:(NSArray *)obj];
            NSInteger reCount = reArray.count;
            
            if (reCount > 0) {
                NSIndexPath* newIndexPath = [NSIndexPath indexPathForRow:1 inSection:0];
                hasLoad = YES;
                [_inputBar.textField becomeFirstResponder];
                [_tableView scrollToRowAtIndexPath:newIndexPath atScrollPosition:UITableViewScrollPositionBottom animated:YES];
                _oriIndexRow = _indexRow;
                _indexRow = 1099;
            }
        }
        
        if (!hasLoad)
        {
            [_inputBar.textField becomeFirstResponder];
            [_tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionBottom animated:YES];
            _indexRow = indexPath.row;
        }
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma -   
#pragma mark Input Bar Action
-(void)inputBar:(YFInputBar *)inputBar sendBtnPress:(UIButton *)sendBtn withInputString:(NSString *)str
{
    
    NSInteger sendButtonTag = sendBtn.tag;
    
    NSLog(@"Type:%ld",(long)sendButtonTag);
    
    if (str == nil || [str isEqualToString:@""]) {
        return;
    }
    
    if (_indexRow == 1099) {
        
        Comment* cm = [Comment new];
        cm.main = str;
        cm.parentId = @"0";
        cm.level = sendButtonTag == 0 ? 1 : 2;
        cm.userName = [LoginUser loginUserName];
        cm.userImg = [LoginUser loginUserPhoto];
        cm.userId = [LoginUser loginUserID];
        cm.taskId = _taskId;
        
        dispatch_async(dispatch_get_main_queue(), ^{
            BOOL isChild = NO;
            if (_oriIndexRow > 2) {
                
                Comment* pc = ((Comment*)[_commentArray objectAtIndex:(_oriIndexRow-3)]);
                pc.commentsId = @"0";
                
                NSString* newCommentId = @"";
                BOOL isOk = [pc sendComment:&newCommentId];
                
                if (isOk) {
                    cm.parentId = newCommentId;
                    NSMutableArray* tAr = [NSMutableArray array];
                    [tAr addObject:cm];
                    pc.comments = tAr;
                    isChild = YES;
                }
                
                [_commentArray addObject:pc];
                [_replyList addObject:pc.main];
            }
            
            NSString* newCommentId = @"";
            BOOL isOk = [cm sendComment:&newCommentId];
            //BOOL isOk = [cm sendComment];
            if(isOk){
                cm.commentsId = newCommentId;
                [_commentArray addObject:cm];
                if (!isChild) {
                    [_replyList addObject:str];
                }
                
                NSLog(@"New Child Comment!!");
                
                NSInteger index = _replyList.count - 1;
                
                NSString* key = [NSString stringWithFormat:@"ReIndex%d",(int)(index - 3)];
                id obj = [_reReplyDic valueForKey:key];
                if ([obj isKindOfClass:[NSArray class]]) {
                    NSMutableArray* reArray = [NSMutableArray arrayWithArray:(NSArray *)obj];
                    if (reArray.count > 0) {
                        
                        [reArray addObject:str];
                        [_reReplyDic setObject:reArray forKey:key];
                    }
                }
                else
                {
                    NSMutableArray* reArray = [NSMutableArray array];
                    [reArray addObject:str];
                    if (_commentArray.count > 1) {
                        if (isChild) {
                            [_reReplyDic setObject:reArray forKey:key];
                        }
                    }
                    
                }
                
                NSIndexPath* indexPath = [NSIndexPath indexPathForRow:index inSection:0];
                NSMutableArray* indexPaths = [NSMutableArray arrayWithObject:indexPath];
                
                [_tableView beginUpdates];
                [_tableView insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationMiddle];
                [_tableView reloadData];
                [_tableView endUpdates];
                
                NSIndexPath* buttomIndexPath = [NSIndexPath indexPathForRow:index inSection:0];
                //NSIndexPath* buttomIndexPath = [NSIndexPath indexPathForRow:1 inSection:0];
                [_tableView scrollToRowAtIndexPath:buttomIndexPath atScrollPosition:UITableViewScrollPositionBottom animated:YES];
            }
        });
        
        
    }
    else
    {
        if (_indexRow > 2) {
            NSString * pid = ((Comment*)[_commentArray objectAtIndex:(_indexRow - 3)]).commentsId;
            Comment* cm = [Comment new];
            cm.main = str;
            cm.parentId = pid==nil?@"0":pid;
            cm.level = sendButtonTag == 0 ? 1 : 2;
            cm.userName = [LoginUser loginUserName];
            cm.userImg = [LoginUser loginUserPhoto];
            cm.userId = [LoginUser loginUserID];
            cm.taskId = _taskId;
            
            dispatch_async(dispatch_get_main_queue(), ^{
                for (Comment* pc in _commentArray) {
                    if (pc.commentsId == pid) {
                        NSMutableArray* tAr = [NSMutableArray arrayWithArray:pc.comments];
                        [tAr addObject:cm];
                        pc.comments = tAr;
                        break;
                    }
                }
                if (cm != nil) {
                    
                    
                    BOOL isOk = [cm sendComment];
                    if(isOk)
                    {
                        NSLog(@"New Child Comment!!");
                        
                        NSString* key = [NSString stringWithFormat:@"ReIndex%d",(int)(_indexRow - 3)];
                        id obj = [_reReplyDic valueForKey:key];
                        if ([obj isKindOfClass:[NSArray class]]) {
                            NSMutableArray* reArray = [NSMutableArray arrayWithArray:(NSArray *)obj];
                            if (reArray.count > 0) {
                                
                                
                                [reArray addObject:str];
                                [_reReplyDic setObject:reArray forKey:key];
                            }
                        }
                        else
                        {
                            NSMutableArray* reArray = [NSMutableArray array];
                            [reArray addObject:str];
                            [_reReplyDic setObject:reArray forKey:key];
                            
                        }
                        
                        [_tableView reloadData];
                        _indexRow = 1099;
                    }
                    
                }
            });
            
        }
    }
}


- (BOOL)textViewShouldBeginEditing:(UITextView *)textView
{
    return YES;
}

#pragma -
#pragma View Controller Action

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [_navBarLeftButtonPopTipView dismissAnimated:YES];
    
    if ([self.icMainViewController respondsToSelector:@selector(setStrIndexForDetail:)]) {
        if (_hasDel) {
            [self.icMainViewController setValue:[NSString stringWithFormat:@"%ld",(NSInteger)_indexInMainArray] forKey:@"strIndexForDetail"];
        }
        else
            [self.icMainViewController setValue:nil forKey:@"strIndexForDetail"];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [_inputBar.textField resignFirstResponder];
}


@end
