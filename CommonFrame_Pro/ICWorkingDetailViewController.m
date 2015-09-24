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
#import "RRAttributedString.h"
#import "UICommon.h"

@interface ICWorkingDetailViewController() <UITableViewDataSource, UITableViewDelegate,YFInputBarDelegate,UITextViewDelegate,CMPopTipViewDelegate,UIAlertViewDelegate,UIGestureRecognizerDelegate,UIActionSheetDelegate>
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
    BOOL                        _showDelete;
    
    UIActivityIndicatorView* acInd ;

}


- (IBAction)btnBackButtonClicked:(id)sender;
- (IBAction)btnCommentButtonClicked:(id)sender;


@end

@implementation ICWorkingDetailViewController

- (void)notiForJumpToMissionDetail:(NSNotification *)note {
        
    NSDictionary * dic = note.object;
    
    _commentsId = [dic valueForKey:@"commentId"];
    
    _taskId = [dic valueForKey:@"taskId"];
    
    [self loadData];
    
    [_tableView reloadData];

    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(notiForJumpToMissionDetail:) name:@"jumpToMissionDetail"
                                               object:nil];
    
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
            
            UILongPressGestureRecognizer *lpgr = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPress:)];
            lpgr.minimumPressDuration = 1.0; //seconds	设置响应时间
            lpgr.delegate = self;
            [_tableView addGestureRecognizer:lpgr];	//启用长按事件
            
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

-(void)handleLongPress:(UILongPressGestureRecognizer *)gestureRecognizer  //长按响应函数
{
    CGPoint p = [gestureRecognizer locationInView:_tableView ];

    NSIndexPath *indexPath = [_tableView indexPathForRowAtPoint:p];//获取响应的长按的indexpath
    if (indexPath == nil)
        NSLog(@"long press on table view but not on a row");
    else
        NSLog(@"long press on table view at row %d", indexPath.row);
    
    if(gestureRecognizer.state == UIGestureRecognizerStateBegan)
    {
        NSInteger index = indexPath.row;
        
        if(index >= 1)
        {
            Comment* comm = [_commentArray objectAtIndex:index - 1];
            
            NSString * loginUserId = [LoginUser loginUserID];
            
            if(loginUserId == comm.userId)
            {
                UIActionSheet* as = [[UIActionSheet alloc] initWithTitle:nil
                                                                delegate:self
                                                       cancelButtonTitle:@"取消"
                                                  destructiveButtonTitle:nil
                                                       otherButtonTitles:@"删除", @"复制", nil];
                as.tag = indexPath.row;
                _showDelete = YES;
                [as showInView:self.view];
            }
            else
            {
                UIActionSheet* as = [[UIActionSheet alloc] initWithTitle:nil
                                                                delegate:self
                                                       cancelButtonTitle:@"取消"
                                                  destructiveButtonTitle:nil
                                                       otherButtonTitles:@"复制", nil];
                as.tag = indexPath.row;
                _showDelete = NO;
                [as showInView:self.view];
            }
            

        }
    }
    //else if(gestureRecognizer.state == UIGestureRecognizerStateEnded)
    //{
    //NSLog(@"UIGestureRecognizerStateEnded");
    //}
    //else if(gestureRecognizer.state == UIGestureRecognizerStateChanged)
    //{
    //NSLog(@"UIGestureRecognizerStateChanged");
    //}
    //else if(gestureRecognizer.state == UIGestureRecognizerStateCancelled)
    //{
    //NSLog(@"UIGestureRecognizerStateCancelled");
    //}
    //else if(gestureRecognizer.state ==UIGestureRecognizerStateFailed )
    //{
    //NSLog(@"UIGestureRecognizerStateFailed");
    //}
}

- (void) actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSInteger cIndex = actionSheet.tag;
    
    Comment* comm = [_commentArray objectAtIndex:cIndex - 1];
    
    if(_showDelete)
    {
        if(buttonIndex == 0)//delete
        {
            UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"提示"
                                                            message:@"确定删除该条评论吗？"
                                                           delegate:self
                                                  cancelButtonTitle:@"不，请保留！"
                                                  otherButtonTitles:@"是的", nil];
            alert.tag = cIndex;
            [alert show];
        }
        else if (buttonIndex == 1)//copy
        {
            UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
            pasteboard.string = comm.main;
        }
    }
    else
    {
        if(buttonIndex == 0)//copy
        {
            UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
            pasteboard.string = comm.main;
        }
    }
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
//            UIButton *rightButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 29, 20)];
//            [rightButton setImage:[UIImage imageNamed:@"btn_gengduo"] forState:UIControlStateNormal];
//            [rightButton addTarget:self action:@selector(btnMenu) forControlEvents:UIControlEventTouchUpInside];
//            
//            UIBarButtonItem *rightBarButton = [[UIBarButtonItem alloc]initWithCustomView:rightButton];
//            self.navigationItem.rightBarButtonItem = rightBarButton;
        }
        
        if (commentsArray.count > 0)
        {
            _commentArray = [NSMutableArray arrayWithArray:commentsArray];
            
            int i = 0;
            
            for (Comment* pComment in commentsArray) {
                
                [_replyList addObject:pComment];
                
                if (pComment.hasChild) {
                    
                    [_commentArray addObjectsFromArray:pComment.comments];
                    
                    for (Comment* cComment in pComment.comments)
                    {
                        [_replyList addObject:cComment];
                    }
                    
//                    NSString* key = [NSString stringWithFormat:@"ReIndex%d",i];
//                    NSMutableArray* childCommentsArray = [NSMutableArray array];
//                    for (Comment* cComment in pComment.comments) {
//                        [childCommentsArray addObject:cComment.main];
//                    }
//                    
//                    [_reReplyDic setObject:childCommentsArray forKey:key];
                    
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
            ((ICPublishMissionViewController*)vc).workGroupId = m.workGroupId;
            ((ICPublishMissionViewController*)vc).userId = [LoginUser loginUserID];
            
            ((ICPublishMissionViewController*)vc).responsibleDic = responsibleA;
            ((ICPublishMissionViewController*)vc).participantsIndexPathArray = participantA;//参与人
            ((ICPublishMissionViewController*)vc).ccopyToMembersArray = copyToA;
            ((ICPublishMissionViewController*)vc).cMarkAarry = labelA;
            ((ICPublishMissionViewController*)vc).cAccessoryArray = accessoryA;
            ((ICPublishMissionViewController*)vc).strFinishTime = m.finishTime;
            ((ICPublishMissionViewController*)vc).strRemindTime = m.remindTime;
            ((ICPublishMissionViewController*)vc).titleName = m.title;
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
    NSInteger cIndex = alertView.tag;
    
    if(cIndex >= 1)
    {
        Comment* comm = [_commentArray objectAtIndex:cIndex - 1];
        
        if (buttonIndex == 1)
        {
            BOOL isOk = [comm deleteTaskComment:comm.commentsId taskId:comm.taskId];
            
            if(isOk)
            {
                [self loadData];
                [_tableView reloadData];
            }
        }
    }
    else
    {
        if (buttonIndex == 1) {
            BOOL isRemoved = [Mission reomveMission:_currentMission.taskId];
            if (isRemoved) {
                _hasDel = YES;
                [self.navigationController popViewControllerAnimated:YES];
            }
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

-(void) tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if([indexPath row] == ((NSIndexPath*)[[tableView indexPathsForVisibleRows] lastObject]).row){
        //end of loading
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            NSLog(@"uitableview 加载完了");
            
            if(_commentsId.length > 0)
            {
                for(NSInteger i = 0; i < _commentArray.count; i ++)
                {
                    Comment * cm = _commentArray[i];
                    
                    NSString * cmId = [NSString stringWithFormat:@"%@", cm.commentsId];
                    
                    if([_commentsId isEqualToString:cmId])
                    {
                        NSIndexPath* buttomIndexPath = [NSIndexPath indexPathForRow:i + 3 inSection:0];
                        [_tableView scrollToRowAtIndexPath:buttomIndexPath atScrollPosition:UITableViewScrollPositionTop animated:YES];
                        
                        _commentsId = @"";
                    }
                }
            }
            
        });
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat height = 44;
    
    UITableViewCell *cell = [self tableView:_tableView cellForRowAtIndexPath:indexPath];
    if(cell)
    {
        return cell.frame.size.height;
    }
    else
    {
        return height;
    }
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

    if (index == 0)
    {
        CGFloat newcHeight = [self tableView:tableView heightForRowAtIndexPath:indexPath];

        UILabel* bottomLine = [[UILabel alloc] initWithFrame:CGRectMake(0, newcHeight - 1, cWidth, 0.5)];
        [bottomLine setBackgroundColor:[UIColor grayColor]];
        [cell.selectedBackgroundView addSubview:bottomLine];
    }
    else if (index > 0)
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
        
        UIImageView* photo = [[UIImageView alloc] initWithFrame:CGRectMake(14, 14, 50, 50)];
        [photo setBackgroundColor:[UIColor clearColor]];
        //[photo setImage:[UIImage imageNamed:@"icon_chengyuan"]];
        [photo setImageWithURL:[NSURL URLWithString:_currentMission.userImg] placeholderImage:[UIImage imageNamed:@"icon_chengyuan"] options:SDWebImageDelayPlaceholder usingActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        [cell.contentView addSubview:photo];
        
        CGFloat titleWidth = [UICommon getSizeFromString:_currentMission.userName withSize:CGSizeMake(100, H(photo)) withFont:Font(16)].width;
        
        UILabel* userTitle = [[UILabel alloc] initWithFrame:CGRectMake(XW(photo) + 14, 17, titleWidth, H(photo))];
        [userTitle setBackgroundColor:[UIColor clearColor]];
        userTitle.text = _currentMission.userName;
        //        [title setText:[NSString stringWithFormat:@"%@  %@",_currentMission.userName,_currentMission.workGroupName]];
        [userTitle setTextColor:RGBCOLOR(53, 159, 219)];
        [userTitle setFont:Font(16)];
        
        [cell.contentView addSubview:userTitle];
        
        
        NSString * tagStr = @"";
        
        for (NSDictionary * dic in _currentMission.labelList)
        {
            NSString * lblName = [dic valueForKey:@"labelName"];
            if(_currentMission.labelList.count == 1)
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
        
        NSString * nameStr = [NSString stringWithFormat:@"%@   %@", _currentMission.workGroupName, tagStr];
        
        CGFloat tagWidth = SCREENWIDTH - 26 - 120;
        
        //        CGFloat tagHeight = [UICommon getSizeFromString:nameStr withSize:CGSizeMake(tagWidth, 1000) withFont:Font(10)].height;
        
        UILabel* tagLbl = [[UILabel alloc] initWithFrame:CGRectMake(XW(userTitle) + 14, Y(userTitle), tagWidth , H(photo))];
        [tagLbl setBackgroundColor:[UIColor clearColor]];
        [tagLbl setTextColor:RGBCOLOR(172, 172, 173)];
        [tagLbl setFont:Font(10)];
        [tagLbl setNumberOfLines:0];
        tagLbl.minimumScaleFactor = 0.7;
        //        tagLbl.textAlignment = NSTextAlignmentCenter;
        
        tagLbl.text = nameStr;
        
        [cell.contentView addSubview:tagLbl];
        
        //标题
        UILabel* title = [[UILabel alloc] initWithFrame:CGRectMake(26, YH(photo) + 18, SCREENWIDTH - 26 * 2, 38)];
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
        [title setFont:Font(17)];
        
        [cell.contentView addSubview:title];
        
        NSString* content = _currentMission.main;
        CGFloat contentWidth = cWidth - 26 * 2;
        UIFont* font = Font(14);
        
        CGFloat contentHeight = [UICommon getSizeFromString:content withSize:CGSizeMake(contentWidth, 1000) withFont:font].height;

        //描述
        UILabel* desLbl = [[UILabel alloc] initWithFrame:CGRectMake(X(title), YH(title), contentWidth, contentHeight)];
        [desLbl setBackgroundColor:[UIColor clearColor]];
        [desLbl setNumberOfLines:0];
        [desLbl setText:content];
        [desLbl setTextColor:RGBCOLOR(172, 172, 173)];
        [desLbl setFont:font];
        [cell.contentView addSubview:desLbl];

        
        CGFloat duiImgWidth = SCREENWIDTH - 14 * 2;

        //文件
        BOOL hasAccessory = _currentMission.isAccessory;
        
        CGFloat accHeight = (duiImgWidth - 40) / 3;
        CGFloat intevalHeight = 8;
        
        NSArray* accArr = [NSArray arrayWithArray:_currentMission.accessoryList];

        CGFloat attchHeight = ((accArr.count - 1) / 3 + 1) * (accHeight + intevalHeight);
        UIView* attchView = [[UIView alloc] init];
        if(accArr.count)
        {
            attchView.frame = CGRectMake(14, YH(desLbl) + 23, duiImgWidth, attchHeight);
        }
        else
        {
            attchView.frame = CGRectMake(14, YH(desLbl) + 23, duiImgWidth, 0);
        }
            
        [attchView setBackgroundColor:[UIColor clearColor]];

        if (hasAccessory) {

            for (int i = 0;i < accArr.count; i++)
            {
                int j = i / 3;
                
                int k = i % 3;
                
                Accessory * acc = accArr[i];

                UIImageView* attachment;
                attachment = [[UIImageView alloc] initWithFrame:CGRectMake(12 + (accHeight + intevalHeight) * k, (accHeight + intevalHeight) * j, accHeight, accHeight)];
                // 1: doc/docx  2: xls/xlsx 3: ppt/pptx 4: pdf 5: png/jpg
                int fileType = [acc.fileType intValue];
                if(fileType == 5)
                {
                    [attachment setImageWithURL:[NSURL URLWithString:acc.address]
                               placeholderImage:[UIImage imageNamed:@"bimg.jpg"]
                                        options:SDWebImageDelayPlaceholder
                    usingActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
                }
                else
                {
                    NSString * imgName = @"";
                    if(fileType == 1)
                    {
                        imgName = @"btn_word";
                        
                        attachment.backgroundColor = [UIColor blueColor];
                    }
                    else if (fileType == 2)
                    {
                        imgName = @"btn_excel";
                        
                        attachment.backgroundColor = [UIColor greenColor];
                    }
                    else if (fileType == 3)
                    {
                        imgName = @"btn_word";//ppt logo
                        
                        attachment.backgroundColor = [UIColor orangeColor];

                    }
                    else if (fileType == 4)
                    {
                        imgName = @"btn_pdf";
                        
                        attachment.backgroundColor = [UIColor purpleColor];

                    }
                    
                    UIImageView * fileIcon = [[UIImageView alloc] initWithFrame:CGRectMake((accHeight - 40) / 2, 14, 40, 60)];
                    fileIcon.image = [UIImage imageNamed:imgName];
                    
                    [attachment addSubview:fileIcon];
                    
                    UILabel * fileNameLbl = [[UILabel alloc] initWithFrame:CGRectMake(14, YH(fileIcon) + 14, (accHeight - 14 * 2) , 32)];
                    fileNameLbl.backgroundColor = [UIColor clearColor];
                    fileNameLbl.textColor = [UIColor whiteColor];
                    fileNameLbl.numberOfLines = 2;
                    fileNameLbl.font = Font(14);
                    fileNameLbl.text = acc.name;
                    
                    [attachment addSubview:fileNameLbl];
                }

                
                [attachment.layer setMasksToBounds:YES];

                [attchView addSubview:attachment];
                
            }
            
            [cell.contentView addSubview:attchView];
        }
        
        //日期
        UIView* bView = [[UIView alloc] initWithFrame:CGRectMake(14, YH(attchView) - intevalHeight, duiImgWidth, 38)];
        [bView setBackgroundColor:[UIColor clearColor]];
        
        UILabel* time = [[UILabel alloc] initWithFrame:CGRectMake(12, 14, 73, 12)];
        [time setBackgroundColor:[UIColor clearColor]];
        [time setNumberOfLines:0];
        [time setText:[NSString stringWithFormat:@"%@ %@",_currentMission.monthAndDay,_currentMission.hour]];
        [time setTextAlignment:NSTextAlignmentLeft];
        [time setTextColor:[UIColor whiteColor]];
        [time setFont:Font(10)];
        [bView addSubview:time];
        
        if (_currentMission != nil) {
            
            if(_currentMission.createUserId == [LoginUser loginUserID])
            {
                UIButton* btnDelete = [[UIButton alloc] initWithFrame:CGRectMake(XW(time), 14, 28, 12)];
                [btnDelete setBackgroundColor:[UIColor clearColor]];
                NSMutableAttributedString* attriNormal = [[NSMutableAttributedString alloc]
                                                          initWithString:@"删除"
                                                          attributes:@{
                                                                       NSFontAttributeName:[UIFont systemFontOfSize:12],
                                                                       NSForegroundColorAttributeName:[UIColor colorWithHexString:@"#3c9ed7"]}];
                NSMutableAttributedString* attriHig = [[NSMutableAttributedString alloc]
                                                       initWithString:@"删除" attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:12],NSForegroundColorAttributeName:[UIColor grayColor]}];
                [btnDelete setAttributedTitle:attriNormal forState:UIControlStateNormal];
                [btnDelete setAttributedTitle:attriHig forState:UIControlStateHighlighted];
                [btnDelete addTarget:self action:@selector(btnRemoveClicked:) forControlEvents:UIControlEventTouchUpInside];
                [bView addSubview:btnDelete];
                
                
                UIButton* btnEdit = [[UIButton alloc] initWithFrame:CGRectMake(XW(time) + 38, 14, 28, 12)];
                [btnEdit setBackgroundColor:[UIColor clearColor]];
                NSMutableAttributedString* eattriNormal = [[NSMutableAttributedString alloc]
                                                           initWithString:@"编辑" attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:12],NSForegroundColorAttributeName:[UIColor colorWithRed:[self colorWithRGB:60] green:[self colorWithRGB:159] blue:[self colorWithRGB:215] alpha:1.0f]}];
                NSMutableAttributedString* eattriHig = [[NSMutableAttributedString alloc]
                                                        initWithString:@"编辑" attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:12],NSForegroundColorAttributeName:[UIColor grayColor]}];
                [btnEdit setAttributedTitle:eattriNormal forState:UIControlStateNormal];
                [btnEdit setAttributedTitle:eattriHig forState:UIControlStateHighlighted];
                [btnEdit addTarget:self action:@selector(btnEditClicked:) forControlEvents:UIControlEventTouchUpInside];
                [bView addSubview:btnEdit];

            }
        }

        UIButton* btnComment = [[UIButton alloc] initWithFrame:CGRectMake(duiImgWidth - 15 - 12, 14, 15, 15)];
        [btnComment setBackgroundColor:[UIColor clearColor]];
        [btnComment setImage:[UIImage imageNamed:@"btn_pinglun"] forState:UIControlStateNormal];
        [btnComment addTarget:self action:@selector(btnCommentButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        [bView addSubview:btnComment];
        
        [cell.contentView addSubview:bView];
        
        CGFloat duiImgHeight = 52 + contentHeight + 38 + H(attchView) + 23 - intevalHeight;
        CGFloat newcHeight = 70 + duiImgHeight ;
        
        UIImageView * duiImageView = [[UIImageView alloc] initWithFrame:CGRectMake(14, YH(photo) + 7, duiImgWidth, duiImgHeight )];
        duiImageView.image= [[UIImage imageNamed:@"bg_duihuakuang2"] stretchableImageWithLeftCapWidth:40 topCapHeight:30];
        
        [cell.contentView addSubview:duiImageView];
        [cell.contentView sendSubviewToBack:duiImageView];

        [cell setFrame:CGRectMake(0, 0, cWidth ,newcHeight + 34)];
        
        UILabel* bottomLine = [[UILabel alloc] initWithFrame:CGRectMake(0, newcHeight + 34 - 1, cWidth, 0.5)];
        [bottomLine setBackgroundColor:[UIColor grayColor]];
        [cell.contentView addSubview:bottomLine];
    }
    else if (index > 0)
    {
        //cell.textLabel.text = [_dataList objectAtIndex:index];
        if (cell.contentView.subviews.count < 4) {
            
            NSInteger cIndex = index - 1;
            
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
                        
//                        cStr = [@"\t\t\t" stringByAppendingString:cStr];
                        
//                        CGFloat height = [self contentHeight:cStr vWidth:reContentWidth contentFont:font];
                        
                        CGFloat height = [UICommon getSizeFromString:cStr withSize:CGSizeMake(reContentWidth, 1000) withFont:Font(14)].height;

                        
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
            
//            UILabel* rev = [[UILabel alloc] initWithFrame:CGRectMake(name.frame.origin.x, 34, 50, height)];
//
//            [rev setBackgroundColor:[UIColor clearColor]];
//            [rev setText:(comm.level == 1?@"批示：":(reCount < 0 ? [NSString stringWithFormat:@"%@:",comm.userName] : @""))];
//            [rev setTextColor:comm.level == 1?[UIColor colorWithHexString:@"#09f4a6"]:[UIColor colorWithHexString:@"#3c9ed7"]];
//            [rev setFont:font];
//            [rev setTextAlignment:NSTextAlignmentLeft];
//            
//            [cell.contentView addSubview:rev];
            
            NSString * mainStr = comm.main;
            
            BOOL isBlue = NO;
            
            BOOL isGreen = NO;
            
            if(comm.level == 2 && comm.parentName.length > 0)//评论
            {
                mainStr = [NSString stringWithFormat:@"回复 %@ %@", comm.parentName, comm.main];
                
                isBlue = YES;
            }
            else if (comm.level == 1)//批示
            {
                mainStr = [NSString stringWithFormat:@"批示：%@", comm.main];
                
                isGreen = YES;
            }
            
            height = [UICommon getSizeFromString:mainStr withSize:CGSizeMake(reContentWidth, 1000) withFont:Font(14)].height;
            
            CGFloat y = 30;
            
            UILabel* revContent = [[UILabel alloc] initWithFrame:CGRectMake(X(name), y, reContentWidth, height)];
            [revContent setBackgroundColor:[UIColor clearColor]];
            [revContent setTextColor:[UIColor whiteColor]];
            [revContent setFont:font];
            [revContent setTextAlignment:NSTextAlignmentLeft];
            [revContent setNumberOfLines:0];

            
            [revContent setText:mainStr];//momo todo

            if(mainStr.length > 0 && isBlue)
            {
                NSAttributedString *attrStr = [RRAttributedString setText:mainStr color:[UIColor colorWithHexString:@"#3c9ed7"] range:NSMakeRange(2, mainStr.length - 2 - comm.main.length)];
                
                [revContent setAttributedText:attrStr];
            }
            else if (mainStr.length > 0 && isGreen)
            {
                NSAttributedString *attrStr = [RRAttributedString setText:mainStr color:[UIColor colorWithHexString:@"#09f4a6"] range:NSMakeRange(0, 3)];
                
                [revContent setAttributedText:attrStr];
            }

            [cell.contentView addSubview:revContent];
            
            UILabel* date = [[UILabel alloc] initWithFrame:CGRectMake(cWidth - 60, 7, 45, 15)];
            [date setBackgroundColor:[UIColor clearColor]];
            [date setText:comm.hourStr];
            [date setTextColor:[UIColor colorWithRed:[self colorWithRGB:122] green:[self colorWithRGB:122] blue:[self colorWithRGB:122] alpha:1.0f]];
            [date setFont:[UIFont systemFontOfSize:8]];
            [date setTextAlignment:NSTextAlignmentRight];
            
            //[cell.contentView addSubview:date];
            
            if(comm.level == 2)
            {
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

            }
            
            if(height < 34)
            {
                height = 60;
            }
            else
            {
                height = height + 35;
            }
            [cell setFrame:CGRectMake(0, 0, cWidth ,height)];
            
            UILabel* bottomLine = [[UILabel alloc] initWithFrame:CGRectMake(0, height - 1, cWidth, 0.5)];
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
                    
                    _commentsId = [NSString stringWithFormat:@"%@", newCommentId];
                    [self loadData];
                    [_tableView reloadData];
                    return;
                    
                    cm.parentId = newCommentId;
                    NSMutableArray* tAr = [NSMutableArray array];
                    [tAr addObject:cm];
                    pc.comments = tAr;
                    isChild = YES;
                }
                
                [_commentArray addObject:pc];
                [_replyList addObject:pc];
            }
            
            NSString* newCommentId = @"";
            BOOL isOk = [cm sendComment:&newCommentId];
            //BOOL isOk = [cm sendComment];
            if(isOk){
                
                _commentsId = [NSString stringWithFormat:@"%@", newCommentId];
                [self loadData];
                [_tableView reloadData];
                return;
                
                cm.commentsId = newCommentId;
                [_commentArray addObject:cm];
                if (!isChild) {
                    [_replyList addObject:cm];
                }
                
                NSLog(@"New Child Comment!!");
                
                NSInteger index = _replyList.count - 1;
                
                NSString* key = [NSString stringWithFormat:@"ReIndex%d",(int)(index - 1)];
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

                    NSString* newCommentId = @"";
                    BOOL isOk = [cm sendComment:&newCommentId];
                    BOOL isChild = NO;
                    if(isOk)
                    {
                        _commentsId = [NSString stringWithFormat:@"%@", newCommentId];
                        [self loadData];
                        [_tableView reloadData];
                        return;
                        
                        cm.commentsId = newCommentId;
                        [_commentArray addObject:cm];
                        if (!isChild) {
                            [_replyList addObject:cm];
                        }
                        
                        NSLog(@"New Child Comment!!");
                        
                        NSInteger index = _replyList.count - 1;
                        
                        NSIndexPath* indexPath = [NSIndexPath indexPathForRow:index inSection:0];
                        NSMutableArray* indexPaths = [NSMutableArray arrayWithObject:indexPath];
                        
                        [_tableView beginUpdates];
                        [_tableView insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationMiddle];
                        [_tableView reloadData];
                        [_tableView endUpdates];
                        
                        
                        NSIndexPath* buttomIndexPath = [NSIndexPath indexPathForRow:index inSection:0];
                        [_tableView scrollToRowAtIndexPath:buttomIndexPath atScrollPosition:UITableViewScrollPositionBottom animated:YES];
                        
                        /* momo todo
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
                         */
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
