//
//  WorkPlanDetailController.m
//  CommonFrame_Pro
//
//  Created by 倩 莫 on 16/1/12.
//  Copyright © 2016年 ionitech. All rights reserved.
//

#import "WorkPlanDetailController.h"
#import "UIImageView+UIActivityIndicatorForSDWebImage.h"
#import <MJRefresh.h>
#import <CMPopTipView.h>
#import "RRAttributedString.h"
#import "UICommon.h"
#import "PreviewViewController.h"
#import "XNDownload.h"
#import "SVProgressHUD.h"
#import "DashesLineView.h"
#import "PartiCell.h"
#import "MQPublishMissionController.h"
#import "MQPublishMissionMainController.h"
#import "MQPublishSharedAndNotifyController.h"
#import "ICMainViewController.h"
#import "MQMyMessageListController.h"
#import "WorkPlanMainCell.h"
#import "WorkPlanEditController.h"
#import "SVProgressHUD.h"

@interface WorkPlanDetailController ()<UITableViewDataSource, UITableViewDelegate,YFInputBarDelegate,UITextViewDelegate,UINavigationControllerDelegate,UIImagePickerControllerDelegate,ZYQAssetPickerControllerDelegate,CMPopTipViewDelegate,UIAlertViewDelegate,UIGestureRecognizerDelegate, UIActionSheetDelegate, UIDocumentInteractionControllerDelegate, UITextFieldDelegate>
{
    NSMutableDictionary*        _reReplyDic;
    Mission*                    _currentMission;
    
    IBOutlet YFInputBar*        _inputBar;
    
    NSInteger                   _oriIndexRow;
    NSMutableArray*             _commentArray;
    NSMutableArray*                   _imageArray;
    NSMutableArray*             _attachmentImageHeightArray;
    BOOL                        _hasLoaded;
    CMPopTipView*               _navBarLeftButtonPopTipView;
    
    BOOL                        _hasDel;
    BOOL                        _showDelete;
    
    UIActivityIndicatorView* acInd ;
    
    UIImageView * _duiimageview;
    
    UITableView * _planTableView;
    
    BOOL _isMainMission;
    
    NSInteger _sendButtonTag;
    
    BOOL _isDeleteMission;
    
    NSArray* _rows;
    BOOL _statusLayoutShow;
    UIButton *  _layoutBtn;
    
    CGFloat _layoutHeight;
    CGFloat _layoutReasonHeight;

    
    NSArray * _finishArr;
    NSArray * _unfinishArr;
    
    UITextField * _currentTextField;
    
    NSArray* _reasonZJRows;

    BOOL _isCreater;
}

@property (strong, nonatomic) UIDocumentInteractionController *documentInteractionController;

- (IBAction)btnBackButtonClicked:(id)sender;
- (IBAction)btnCommentButtonClicked:(id)sender;

@end

@implementation WorkPlanDetailController

- (void)notiForJumpToWorkPlanDetail:(NSNotification *)note {
    
    NSDictionary * dic = note.object;
    
    _commentsId = [dic valueForKey:@"commentId"];
    
    _taskId = [dic valueForKey:@"taskId"];
    
    [self reloadTableView];
}

- (void) jumpToMissionMainEdit
{
    UIStoryboard* mainStory = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    
    UIViewController* vc = [mainStory instantiateViewControllerWithIdentifier:@"MQPublishMissionMainController"];
    ((MQPublishMissionMainController*)vc).isEdit = YES;
    ((MQPublishMissionMainController*)vc).taskId = _taskId;
    ((MQPublishMissionMainController*)vc).workGroupId = _currentMission.workGroupId;
    ((MQPublishMissionMainController*)vc).workGroupName = _currentMission.workGroupName;
    ((MQPublishMissionMainController*)vc).icDetailViewController = self;
    
    
    [self.navigationController pushViewController:vc animated:YES];
    
}


- (void) jumpToCreaterPersonInfo:(id)sender
{
    Member * me = [Member new];
    
    me.workGroupId = @"0";
    
    NSMutableArray * dataArr = [NSMutableArray array];
    
    BOOL isOk = [Mission findWgPeopleTrends:_currentMission.createUserId workGroupId:@"0" currentPageIndex:1 pageSize:30 dataListArr:&dataArr member:&me];
    if(!me.workGroupId)
    {
        me.workGroupId = @"0";
    }
    if(isOk)
    {
        UIStoryboard* mainStory = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        UIViewController* vc;
        vc = [mainStory instantiateViewControllerWithIdentifier:@"ICMemberInfoViewController"];
        ((ICMemberInfoViewController*)vc).memberObj = me;
        ((ICMemberInfoViewController*)vc).dataListArr = dataArr;
        
        [self.navigationController pushViewController:vc animated:YES];
        
    }
}

- (void) jumpToPersonInfo:(id)sender
{
    UIView *v = [sender superview];//获取父类view
    UITableViewCell *cell = (UITableViewCell *)[v superview];//获取cell
    NSIndexPath *indexPath = [_tableView indexPathForCell:cell];//获取cell对应的section
    
    Comment * mi = _commentArray[indexPath.row - 1];
    
    Member * me = [Member new];
    
    me.workGroupId = @"0";
    
    NSMutableArray * dataArr = [NSMutableArray array];
    
    NSString * userId = mi.userId;
    
    BOOL isOk = [Mission findWgPeopleTrends:userId workGroupId:@"0" currentPageIndex:1 pageSize:30 dataListArr:&dataArr member:&me];
    
    if(isOk)
    {
        UIStoryboard* mainStory = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        UIViewController* vc;
        vc = [mainStory instantiateViewControllerWithIdentifier:@"ICMemberInfoViewController"];
        ((ICMemberInfoViewController*)vc).memberObj = me;
        ((ICMemberInfoViewController*)vc).dataListArr = dataArr;
        
        [self.navigationController pushViewController:vc animated:YES];
        
    }
}

- (void) jumpToShareEdit
{
    UIStoryboard* mainStory = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    
    UIViewController* vc = [mainStory instantiateViewControllerWithIdentifier:@"MQPublishSharedAndNotifyController"];
    ((MQPublishSharedAndNotifyController*)vc).isEditMission = YES;
    ((MQPublishSharedAndNotifyController*)vc).taskId = _currentMission.taskId;
    ((MQPublishSharedAndNotifyController*)vc).workGroupId = _currentMission.workGroupId;
    ((MQPublishSharedAndNotifyController*)vc).workGroupName = _currentMission.workGroupName;
    ((MQPublishSharedAndNotifyController*)vc).userId = [LoginUser loginUserID];
    ((MQPublishSharedAndNotifyController*)vc).icDetailViewController = self;
    NSInteger isShared = TaskTypeMission;
    if(_currentMission.type == TaskTypeNoitification)
    {
        isShared = 2;
    }
    else if (_currentMission.type == TaskTypeJianYi)
    {
        isShared = 3;
    }
    ((MQPublishSharedAndNotifyController*)vc).isShared = isShared;
    
    
    [self.navigationController pushViewController:vc animated:YES];
}


- (void) jumpToMissionEdit
{
    UIStoryboard* mainStory = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    
    UIViewController* vc = [mainStory instantiateViewControllerWithIdentifier:@"MQPublishMissionController"];
    ((MQPublishMissionController*)vc).isEditMission = YES;
    ((MQPublishMissionController*)vc).taskId = _currentMission.taskId;
    ((MQPublishMissionController*)vc).workGroupId = _currentMission.workGroupId;
    ((MQPublishMissionController*)vc).workGroupName = _currentMission.workGroupName;
    ((MQPublishMissionController*)vc).userId = [LoginUser loginUserID];
    ((MQPublishMissionController*)vc).icDetailViewController = self;
    //    ((MQPublishMissionController*)vc).icMainViewController = _icMainViewController;
    //    ((MQPublishMissionController*)vc).indexInMainArray = _indexInMainArray;
    
    [self.navigationController pushViewController:vc animated:YES];
    
}

- (void) actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(actionSheet.tag == 111)//3项
    {
        if(buttonIndex == 0)
        {
            NSInteger status = _currentMission.status;
            NSString * Dstr = @"";
            if(status == 0)
            {
                Dstr = @"开始";
            }
            else if (status == 1 || status == -3)
            {
                Dstr = @"完成";
            }
            
            UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"" message:[NSString stringWithFormat:@"是否%@该任务？", Dstr] delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
            alert.tag = 10;
            [alert show];
            
        }
        else if (buttonIndex == 1)//编辑
        {
            _isMainMission = [_currentMission.parentId isEqualToString:@"0"];//为0 主任务
            
            if(_isMainMission)
            {
                [self jumpToMissionMainEdit];
            }
            else
            {
                [self jumpToMissionEdit];
            }
        }
        else if (buttonIndex == 2)//删除
        {
            UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"" message:[NSString stringWithFormat:@"是否删除该任务？"] delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
            alert.tag = 11;
            [alert show];
        }
    }
    else if (actionSheet.tag == 112)//2项
    {
        if (buttonIndex == 0)//编辑
        {
            NSInteger type = _currentMission.type;
            
            if(type == 1)
            {
                _isMainMission = [_currentMission.parentId isEqualToString:@"0"];//为0 主任务
                
                if(_isMainMission)
                {
                    [self jumpToMissionMainEdit];
                }
                else
                {
                    [self jumpToMissionEdit];
                }
            }
            else
            {
                [self jumpToShareEdit];
            }
            
        }
        else if (buttonIndex == 1)//删除
        {
            UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"" message:[NSString stringWithFormat:@"是否删除该任务？"] delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
            alert.tag = 11;
            [alert show];
        }
    }
    else
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
                alert.tag = cIndex + 100;
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
}

- (void) jumpToPlanEdit
{
    UIStoryboard* mainStrory = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    UIViewController* vc = [mainStrory instantiateViewControllerWithIdentifier:@"WorkPlanEditController"];
    ((WorkPlanEditController*)vc).workGroupId = _currentMission.workGroupId;
    ((WorkPlanEditController*)vc).workGroupName = _currentMission.workGroupName;
    ((WorkPlanEditController*)vc).taskId = _currentMission.taskId;
    ((WorkPlanEditController*)vc).startTime = _currentMission.startTime;
    ((WorkPlanEditController*)vc).finishTime = _currentMission.finishTime;
    ((WorkPlanEditController*)vc).rows = [NSMutableArray arrayWithArray:_currentMission.labelList];
    ((WorkPlanEditController*)vc).isEdit = YES;
    ((WorkPlanEditController*)vc).icDetailViewController = self;
    
    [self.navigationController pushViewController:vc animated:YES];
    
}

- (void) btnRightEditClicked:(id)sender
{
    [self hiddenKeyboard];
    
    [self jumpToPlanEdit];
}

- (void) btnRightMoreClicked:(id)sender
{
    [self hiddenKeyboard];
    
    if(_currentMission.type == 1)//任务
    {
        //-3:已超时  -2删除   -1停用   0：未开始 1进行中   2：已完成
        NSString *statusStr = @"";
        
        if(_currentMission.status == 0)
        {
            statusStr = @"开始";
        }
        else if (_currentMission.status == 1 || _currentMission.status == -3)
        {
            statusStr = @"完成";
        }
        
        if(statusStr.length)
        {
            UIActionSheet* as = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:statusStr, @"编辑",@"删除", nil];
            as.destructiveButtonIndex= 2;
            as.tag = 111;
            [as showInView:self.view];
            
        }
        else
        {
            UIActionSheet* as = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"编辑",@"删除", nil];
            as.destructiveButtonIndex= 1;
            as.tag = 112;
            [as showInView:self.view];
        }
    }
    else
    {
        UIActionSheet* as = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"编辑",@"删除", nil];
        as.destructiveButtonIndex= 1;
        as.tag = 112;
        [as showInView:self.view];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    _layoutHeight = 0;
    _layoutReasonHeight = 0;

    _finishArr = [NSMutableArray array];
    _unfinishArr = [NSMutableArray array];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(notiForJumpToWorkPlanDetail:) name:@"jumpToWorkPlanDetail"
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
            
            NSArray* typeList = @[@"批示", @"拍照", @"照片", @"群组文件夹"];
            _inputBar = [[YFInputBar alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY([UIScreen mainScreen].bounds) - 50 - 66, [UIScreen mainScreen].bounds.size.width, 54)];
            //[inputBar setFrame:CGRectMake(0, CGRectGetMaxY([UIScreen mainScreen].bounds) + 100, 320, 44)];
            _inputBar.delegate = self;
            _inputBar.resignFirstResponderWhenSend = YES;
            _inputBar.relativeControl = (UIControl*)_tableView;
            _inputBar.typeList = typeList;
            _inputBar.parentController = self;
            _inputBar.dataCount = _replyList.count - 1;
            _inputBar.textField.placeholder = @"点击回复";
            _inputBar.isWorkPlanDetail = YES;
            
            [_inputBar.sendCommentBtn addTarget:self action:@selector(btnSendCommentPress:) forControlEvents:UIControlEventTouchUpInside];
            
            //            [self addSendToKeyboard:_inputBar.textField];
            
            [self.view addSubview:_inputBar];
            
            [acInd stopAnimating];
        });
    });
    
    //_dataList = [NSMutableArray arrayWithObjects:@"1",@"2",@"3",@"4",@"5",@"6",@"7",@"8",@"9",@"10", nil];
    //_replyList = [NSMutableArray arrayWithObjects:@" ",@" ",@"回形针工具上线申请1！",@"回形针工具上线申请2！",@"回形针工具上线申请3！",@"回形针工具上线申请！",@"回形针工具上线申请！",@"回形针工具上线申请8！",@"回形针工具上线申请9！",@"回形针工具上线申请10！", nil];
    
}

-(void)btnSendCommentPress:(id)sender
{
    [self sendComment];
}


- (void) inputBarWithFile:(YFInputBar *)inputBar
{
    NSInteger tag = inputBar.sendBtn.tag;
    
    if(tag == 0)//指示
    {
        if(_sendButtonTag == 0)
        {
            [self setPishi:100 pishiClicked:YES placeHolderText:@"批示:"];//选中
            
        }
        else
        {
            [self setPishi:0 pishiClicked:NO placeHolderText:@"点击回复"];
            
        }
    }
    else if(tag == 3)
    {
        [self setPishi:0 pishiClicked:NO placeHolderText:@"点击回复"];
        
        UIStoryboard* mainStory = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        UIViewController* vc = [mainStory instantiateViewControllerWithIdentifier:@"ICFileViewController"];
        ((ICFileViewController *)vc).workGroupId = _currentMission.workGroupId;
        ((ICFileViewController*)vc).icWorkDetailController = self;
        
        [self.navigationController pushViewController:vc animated:YES];
    }
    else if(tag == 1)
    {
        [self setPishi:0 pishiClicked:NO placeHolderText:@"点击回复"];
        
        UIImagePickerController *ctrl = [[UIImagePickerController alloc] init];
        ctrl.delegate = self;
        ctrl.sourceType = UIImagePickerControllerSourceTypeCamera;
        [self presentViewController:ctrl animated:YES completion:nil];
    }
    else if(tag == 2)
    {
        [self setPishi:0 pishiClicked:NO placeHolderText:@"点击回复"];
        
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
    //        UIActionSheet* as = [[UIActionSheet alloc] initWithTitle:@"选取附件" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"群组文件夹", @"拍照", @"从相册选取", nil];
    //        as.tag = 113;
    //        [as showInView:self.view];
}

- (void) setPishi:(NSInteger)tag pishiClicked:(BOOL)cliked placeHolderText:(NSString *)placeholder
{
    _sendButtonTag = tag;
    _inputBar.pishiClicked = cliked;
    _inputBar.textField.placeHolderLabel.text = placeholder;
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

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if (_tableView != nil) {
        CGRect frmae = _tableView.frame;
        if (frmae.size.width == 0 && frmae.size.height == 0) {
            _tableView.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height - 44 - 66);
        }
        if (_content != nil) {
            
            [self reloadTableView];
            
        }
    }
    
    [self showAccessory];
    
}

- (void) showAccessory
{
    if(_cAccessoryArray.count)
    {
        Comment* cm = [Comment new];
        cm.main = @"";
        cm.parentId = @"0";
        cm.level = 2;
        cm.userId = [LoginUser loginUserID];
        cm.taskId = _taskId;
        
        NSMutableDictionary * dic = [NSMutableDictionary dictionary];
        BOOL isOk = [cm createCommentAccessoryId:&dic];
        
        if(isOk)
        {
            NSMutableDictionary * cdic = [NSMutableDictionary dictionary];
            
            NSMutableDictionary * ccdic = [NSMutableDictionary dictionary];
            [ccdic setObject:dic forKey:@"vo"];
            [cdic setDictionary:ccdic];
            
            NSMutableArray* tA = [NSMutableArray array];
            for (int i = 0; i < _cAccessoryArray.count; i++) {
                NSMutableDictionary* di = [NSMutableDictionary dictionary];
                
                Accessory* acc = _cAccessoryArray[i];
                
                [di setObject:acc.name forKey:@"name"];
                [di setObject:acc.address forKey:@"address"];
                [di setObject:[NSString stringWithFormat:@"%ld",acc.source] forKey:@"source"];
                [tA addObject:di];
            }
            
            [cdic setObject:tA forKey:@"accessoryList"];
            BOOL isOk = [cm createCommentAccessory:cdic];
            if(isOk)
            {
                [_inputBar removeType];
                _inputBar.btnTypeHasClicked = NO;
                
                [self reloadTableView];
                
            }
        }
    }
}


- (void)requesetData
{
    NSArray* commentsArray = [NSArray array];
    NSArray * imgArr = [NSArray array];
    

    NSArray * finishArr = [NSArray array];
    NSArray * unfinishArr = [NSArray array];

    _currentMission = [Mission findWorkPlanDetailTx:_taskId commentArray:&commentsArray finishArray:&finishArr unfinishArray:&unfinishArr];
    _rows = _currentMission.labelList;
    
    _finishArr = finishArr;
    _unfinishArr = unfinishArr;

    _commentsArr = commentsArray;
    _imageArr = imgArr;
}

- (void)loadData
{
    _replyList = [NSMutableArray array];
    [_replyList addObject:@""];
    
    _reReplyDic = [NSMutableDictionary dictionary];
    
    //self.taskId = @"1015072218310001";
    //self.taskId = @"1015072215290001";
    _commentArray = [NSMutableArray array];
    _imageArray = [NSMutableArray array];
    
    NSArray* commentsArray = [NSArray array];
    NSArray * imgArr = [NSArray array];
    self.cAccessoryArray = [NSMutableArray array];
    
    if(!_currentMission)
    {
        _currentMission = [Mission new];
        
        NSArray * finishArr = [NSArray array];
        NSArray * unfinishArr = [NSArray array];
        
        _currentMission = [Mission findWorkPlanDetailTx:_taskId commentArray:&commentsArray finishArray:&finishArr unfinishArray:&unfinishArr];
        _rows = _currentMission.labelList;
        
        _finishArr = finishArr;
        _unfinishArr = unfinishArr;
        
    }
    else
    {
        if(_isZJ)
        {
            _currentMission = [Mission new];
            
            NSArray * finishArr = [NSArray array];
            NSArray * unfinishArr = [NSArray array];
            
            _currentMission = [Mission findWorkPlanDetailTx:_taskId commentArray:&commentsArray finishArray:&finishArr unfinishArray:&unfinishArr];
            _rows = _currentMission.labelList;
            
            _finishArr = finishArr;
            _unfinishArr = unfinishArr;
        }
        else
        {
            commentsArray = _commentsArr;
            imgArr = _imageArr;
        }

    }
    
    if (_currentMission != nil) {
        
        NSString * title = @"工作计划详情";
        if(_currentMission.type == 5)
        {
            self.isZJReason = YES;
            
            title = @"工作计划总结";
        }
        else
        {
            self.isZJReason = NO;
        }
        
        self.navigationItem.title = title;
        
        NSString * loginStr = [NSString stringWithFormat:@"%@", [LoginUser loginUserID]];
        
        if(_currentMission.createUserId == [LoginUser loginUserID] || [_currentMission.liableUserId isEqualToString:loginStr])
        {
            if(_currentMission.createUserId == [LoginUser loginUserID])
            {
                _isCreater = YES;
            }
            else
            {
                _isCreater = NO;
            }
            
            if(_currentMission.type != 5)
            {
                UIBarButtonItem* rightBarButton = [[UIBarButtonItem alloc] initWithTitle:@"编辑" style:UIBarButtonItemStyleDone target:self action:@selector(btnRightEditClicked:)];
                [rightBarButton setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor whiteColor],NSFontAttributeName:[UIFont systemFontOfSize:17]} forState:UIControlStateNormal];
                self.navigationItem.rightBarButtonItem = rightBarButton;
            }
            else
            {
                self.navigationItem.rightBarButtonItem = nil;
            }
        }
    }
    
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
        if(imgArr.count)
        {
            for(Accessory * ac in imgArr)
            {
                NSMutableDictionary * dic = [NSMutableDictionary dictionary];
                [dic setObject:ac.address forKey:@"PictureUrl"];
                if(ac.allUrl)
                {
                    [dic setObject:ac.allUrl forKey:@"OriginUrl"];
                }
                if(ac.originImageSize)
                {
                    [dic setObject:ac.originImageSize forKey:@"OriginSize"];
                }
                
                [_imageArray addObject:dic];
            }
        }
        
        if (commentsArray.count > 0)
        {
            _commentArray = [NSMutableArray arrayWithArray:commentsArray];
            
            //            _imageArray = [NSMutableArray arrayWithArray:imgArr];
            
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

- (void) textFieldDidBeginEditing:(UITextField *)textField
{
    _inputBar.hidden = YES;
    _currentTextField = textField;
    
    textField.returnKeyType = UIReturnKeyDone;
}

- (BOOL) textFieldShouldReturn:(UITextField *)textField
{
    [_currentTextField resignFirstResponder];

    return YES;
}

- (void) textFieldDidEndEditing:(UITextField *)textField
{
    _inputBar.hidden = NO;
    
    UITableViewCell *cell  = (UITableViewCell *)[[[textField superview] superview] superview];
    
    UITableView * mainTableView =(UITableView *) [[cell superview] superview];
    NSIndexPath *indexPath = [mainTableView indexPathForCell:cell];
    NSInteger section = indexPath.section;
    
    NSInteger index = section - _finishArr.count;
    if(!_finishArr.count)
    {
        index = section - 1;
    }
    
//    NSMutableArray * unfinishArr = [NSMutableArray array];
//    [unfinishArr addObjectsFromArray:_unfinishArr];
    ((Mission *)[_unfinishArr[index] objectForKey:@"taskList"][indexPath.row]).reason = textField.text;
//    Mission * mis = [_unfinishArr[0] objectForKey:@"taskList"][0];
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

- (void) doneZJClick:(id)sender
{
    [SVProgressHUD showWithStatus:@"工作总结发布中..."];

    UIButton * btn = (UIButton *)sender;
    
    UITableView *mTableView = (UITableView *)[[[[btn superview] superview] superview] superview];//获取tableview
    
    NSInteger section = [mTableView numberOfSections];
    
    NSInteger unfinishCount = _unfinishArr.count;
    
    NSInteger index = section - unfinishCount;
    
    for(NSInteger i = index; i < section; i ++)
    {
        NSInteger countRow = [mTableView numberOfRowsInSection:i];
        
        for (NSInteger j = 0; j < countRow ; j ++) {
            NSIndexPath * indp = [NSIndexPath indexPathForRow:j inSection:i];
            
            UITableViewCell *cell = [self tableView:mTableView cellForRowAtIndexPath:indp];
            
            if(cell.tag != 123)
            {
                UITextField * reasonTxt = (UITextField *)[cell viewWithTag: 100 + j];
                
                if(!reasonTxt.text.length)
                {
                    [SVProgressHUD showErrorWithStatus:@"还有未总结的原因"];
                    
                    return;
                }
            }
        }
    }
    
    NSMutableArray * ZJArr = [NSMutableArray array];
    
    for (int i = 0; i < _unfinishArr.count; i ++)
    {
        NSDictionary * dic = _unfinishArr[i];
        
        NSArray * arr = [dic objectForKey:@"taskList"];
        
        NSString * labelId = [dic valueForKey:@"labelId"];
        
        if(_finishArr.count)
        {
            for(int j = 0; j < _finishArr.count; j ++)
            {
                NSDictionary * fDic = _finishArr[j];
                
                NSArray * farr = [dic objectForKey:@"taskList"];
                
                NSString * flabelId = [fDic valueForKey:@"labelId"];
                
                if(flabelId == labelId)
                {
                    NSMutableDictionary * mmdic = [NSMutableDictionary dictionaryWithDictionary:fDic];
                    
                    NSMutableArray * mmarr = [NSMutableArray array];
                    
                    if(arr.count)
                    {
                        [mmarr addObjectsFromArray:arr];//未完成
                    }
                    if(farr.count)
                    {
                        [mmarr addObjectsFromArray:farr];//已完成
                    }
                    
                    [mmdic removeObjectForKey:@"taskList"];
                    
                    [mmdic setObject:mmarr forKey:@"taskList"];
                    
                    [ZJArr addObject:mmdic];
                    
                    break;
                }
            }
        }
        else
        {
            [ZJArr addObjectsFromArray:_unfinishArr];
        }
        
        NSMutableArray * taskList = [NSMutableArray array];
        
        for(NSDictionary * dic in ZJArr)
        {
            NSMutableDictionary * taskDic = [NSMutableDictionary dictionary];
            
            NSArray * nArr = [dic objectForKey:@"taskList"];

            NSMutableArray * taskArr = [NSMutableArray array];
            
            for(Mission * mi in nArr)
            {
                NSMutableDictionary * mdic = [NSMutableDictionary dictionary];
                
                [mdic setObject:mi.taskId forKey:@"taskId"];
                [mdic setObject:mi.labelId forKey:@"labelId"];
                [mdic setObject:mi.reason forKey:@"reason"];
                
                [taskArr addObject:mdic];
            }
            
            if(taskArr.count)
            {
                [taskDic setObject:[NSString stringWithFormat:@"%@", [dic valueForKey:@"labelId"]] forKey:@"labelId"];
                
                [taskDic setObject:taskArr forKey:@"taskReasonList"];
                
            }
            
            if(taskDic.allKeys.count)
            {
                [taskList addObject:taskDic];
            }
        }
        
        NSString * title = _currentMission.title;
        
        title = [title substringToIndex:title.length - 2];
        
        title = [NSString stringWithFormat:@"%@总结", title];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            BOOL isOk = [Mission updateWorkPlan:[LoginUser loginUserID] taskId:_taskId workGroupId:_workGroupId workPlanTitle:title startTime:_currentMission.startTime finishTime:_currentMission.finishTime taskList:taskList andType:@"5"];
            
            if(isOk)
            {
                _isZJ = YES;
                
                _isZJReason = YES;
                
                [self loadData];
                
                [_tableView reloadData];
                
                [SVProgressHUD showSuccessWithStatus:@"工作总结发布成功"];
            }
            else
            {
                [SVProgressHUD showErrorWithStatus:@"工作总结发布失败"];
            }
        });
    }
    
}

- (void) cancelZJClick:(id)sender
{
    _isZJ = NO;
    
    self.navigationItem.title = @"工作计划详情";
    
    [_tableView reloadData];
}

- (void) reloadTableView
{
    [self requesetData];
    [self loadData];
    [_tableView reloadData];
    
    NSIndexPath* newIndexPath = [NSIndexPath indexPathForRow:_commentArray.count inSection:0];
    [_tableView scrollToRowAtIndexPath:newIndexPath atScrollPosition:UITableViewScrollPositionBottom animated:YES];
    
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(alertView.tag > 100)
    {
        NSInteger cIndex = alertView.tag - 100;
        
        if(cIndex >= 1)
        {
            Comment* comm = [_commentArray objectAtIndex:cIndex - 1];
            
            if (buttonIndex == 1)
            {
                BOOL isOk = [comm deleteTaskComment:comm.commentsId taskId:comm.taskId];
                
                if(isOk)
                {
                    [self reloadTableView];
                }
            }
        }
    }
    else if(alertView.tag == 10)
    {
        if (buttonIndex == 1)
        {
            NSInteger status = _currentMission.status;
            if(status == 0)
            {
                status = 1;
            }
            else if (status == 1 || status == -3)
            {
                status = 2;
            }
            
            BOOL isOK = [Mission updateTaskStatus:_currentMission.taskId status:status];
            
            if(isOK)
            {
                [SVProgressHUD showSuccessWithStatus:@"更新任务状态成功"];
                
                if ([self.icMyMegListController respondsToSelector:@selector(setSysMegEdit:)]) {
                    [self.icMyMegListController setValue:@"1" forKey:@"sysMegEdit"];
                }
                
                [self reloadTableView];
                
            }
        }
    }
    else if (alertView.tag == 11)
    {
        if (buttonIndex == 1) {
            BOOL isRemoved = [Mission reomveMission:_currentMission.taskId];
            if (isRemoved) {
                _hasDel = YES;
                
                if(_contentArr.count)
                {
                    _isDeleteMission = YES;
                    
                    [_contentArr removeObjectAtIndex:_indexInMainArray];
                    
                    if ([self.icMainViewController respondsToSelector:@selector(setContentArray:)]) {
                        [self.icMainViewController setValue:_contentArr forKey:@"contentArray"];
                    }
                }
                
                if ([self.icMyMegListController respondsToSelector:@selector(setSysMegEdit:)]) {
                    [self.icMyMegListController setValue:@"1" forKey:@"sysMegEdit"];
                }
                
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
            {
                iVal--;
            }
            else
            {
                iVal++;
            }
            btn.titleLabel.text = [NSString stringWithFormat:@"%ld",iVal];
            NSMutableAttributedString* parNor = [[NSMutableAttributedString alloc]
                                                 initWithString:[NSString stringWithFormat:@"%ld",iVal] attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:10],NSForegroundColorAttributeName:[UIColor whiteColor]}];
            [btn setAttributedTitle:parNor forState:UIControlStateNormal];
            if(iVal == 0)
            {
                [btn setBackgroundImage:[UIImage imageNamed:@"btn_zan"] forState:UIControlStateNormal];
            }
            else
            {
                [btn setBackgroundImage:[UIImage imageNamed:@"btn_zan2"] forState:UIControlStateNormal];
            }
            
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

/*
-(void) tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if([indexPath row] == ((NSIndexPath*)[[tableView indexPathsForVisibleRows] lastObject]).row){
        //end of loading
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            NSLog(@"uitableview 加载完了");
            
            //            if(_commentsId.length > 0)
            //            {
            //                for(NSInteger i = 0; i < _commentArray.count; i ++)
            //                {
            //                    Comment * cm = _commentArray[i];
            //
            //                    NSString * cmId = [NSString stringWithFormat:@"%@", cm.commentsId];
            //
            //                    if([_commentsId isEqualToString:cmId])
            //                    {
            //                        NSIndexPath* buttomIndexPath = [NSIndexPath indexPathForRow:i + 3 inSection:0];
            //                        [_tableView scrollToRowAtIndexPath:buttomIndexPath atScrollPosition:UITableViewScrollPositionTop animated:YES];
            //
            //                        _commentsId = @"";
            //                    }
            //                }
            //            }
            
        });
    }
}*/

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

- (void) previewCommentFile:(id)sender
{
    UIButton * btn = (UIButton *)sender;
    
    NSInteger index = btn.tag;
    
    UIView *v = [sender superview];//获取父类view
    UITableViewCell *cell = (UITableViewCell *)[[[v superview] superview] superview];//获取cell
    NSIndexPath *indexPath = [_tableView indexPathForCell:cell];//获取cell对应的section
    NSInteger cIndex = indexPath.row;
    if(cIndex >= 1)
    {
        cIndex = cIndex - 1;
        
        Comment* comm = [_commentArray objectAtIndex:cIndex];
        
        NSArray* accArr = [NSArray arrayWithArray:comm.accessoryList];
        
        Accessory * acc = accArr[index];
        
        // 1: doc/docx  2: xls/xlsx 3: ppt/pptx 4: pdf 0: png/jpg 6:其他
        int fileType = [[UICommon findFileType:acc.name] intValue];
        
        if(fileType == 0)
        {
            UIStoryboard* mainStory = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
            UIViewController* vc = [mainStory instantiateViewControllerWithIdentifier:@"PreviewViewController"];
            
            NSMutableArray * imageArr = [NSMutableArray array];
            
            NSMutableDictionary * dic = [NSMutableDictionary dictionary];
            [dic setObject:acc.address forKey:@"PictureUrl"];
            if(acc.allUrl)
            {
                [dic setObject:acc.allUrl forKey:@"OriginUrl"];
            }
            if(acc.originImageSize)
            {
                [dic setObject:acc.originImageSize forKey:@"OriginSize"];
            }
            
            [imageArr addObject:dic];
            
            if(imageArr.count)
            {
                ((PreviewViewController*)vc).dataArray = imageArr;
            }
            //            ((PreviewViewController*)vc).currentPage = btn.tag;
            
            [self.navigationController presentViewController:vc animated:YES completion:nil];
        }
        else
        {
            NSURL * fileUrl = [NSURL URLWithString:acc.address];
            
            XNDownload * d = [[XNDownload alloc] init];
            
            [d downloadWithURL:fileUrl progress:^(float progress) {
                
                if(progress < 1)
                {
                    int prog = progress * 100;
                    
                    [SVProgressHUD showProgress:progress status:[NSString stringWithFormat:@"%d%@", prog, @"%"]];
                }
                
                if(progress == 1)
                {
                    [SVProgressHUD dismiss];
                    
                    NSURL *URL=[NSURL fileURLWithPath:d.cachePath];
                    
                    if (URL) {
                        // Initialize Document Interaction Controller
                        self.documentInteractionController = [UIDocumentInteractionController interactionControllerWithURL:URL];
                        
                        // Configure Document Interaction Controller
                        [self.documentInteractionController setDelegate:self];
                        
                        // Preview PDF
                        [self.documentInteractionController presentPreviewAnimated:YES];
                    }
                }
            }];
        }
    }
}

- (IBAction)btnLayoutButtonClicked:(id)sender
{
    if(!_statusLayoutShow)
    {
        _statusLayoutShow = YES;
    }
    else
    {
        _statusLayoutShow = NO;
    }
    
    [_tableView reloadData];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if(tableView == _tableView)
    {
        return 1;
    }
    else
    {
        if(_isZJ)
        {
            NSInteger finishCount = _finishArr.count;
            NSInteger unfinishCount = _unfinishArr.count;

            if(_finishArr.count == 0)
            {
                finishCount += 1;
            }
            if(_unfinishArr.count == 0)
            {
                unfinishCount += 1;
            }

            return finishCount + unfinishCount;
        }
        else
        {
            return _rows.count;
        }
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(tableView == _tableView)
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
    else
    {
        if(!_statusLayoutShow)
        {
            if(_isZJ)
            {
                NSInteger section = indexPath.section;
                
                if(section >= _finishArr.count&& section != 0)//未完成
                {
                    NSInteger index = section - _finishArr.count;
                    
                    if(!_finishArr.count)
                    {
                        index = section - 1;
                    }
                    
                    if(index == _unfinishArr.count - 1)
                    {
                        if(_isZJReason)
                        {
                            return 51;
                        }
                        else
                        {
                            return 72;
                        }
                    }
                    else if (index < _unfinishArr.count - 1)
                    {
                        if(_isZJReason)
                        {
                            return 51;
                        }
                        else
                        {
                            return 72;
                        }
                    }
                    else//未完成为空->写上“无” + “完成总结”
                    {
                        return 34;
                    }
                }
                else if(section >= 0)//已完成
                {
                    return 34;
                }
            }
            else
            {
                _layoutHeight = 0;
                
                _layoutReasonHeight = 0;

                return 34;
            }
        }
        else
        {
//            if(_isZJ)
//            {
//                if(indexPath.row == 0 && indexPath.section == [_planTableView numberOfSections] - 1)
//                {
//                    _layoutReasonHeight = 0;
//                }
//            }
//            else
//            {
//                if(indexPath.row == 0 && indexPath.section == _rows.count - 1)
//                {
//                    _layoutHeight = 0;
//                }
//            }
            
            UITableViewCell *cell = [self tableView:tableView cellForRowAtIndexPath:indexPath];
            if(cell)
            {
//                if(_isZJ)
//                {
//                    _layoutReasonHeight += cell.frame.size.height;
//                }
//                else
//                {
//                    _layoutHeight += cell.frame.size.height;
//                }
                
                return cell.frame.size.height;
            }
        }
        
        return 34;
    }
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(tableView == _tableView)
    {
        return _replyList.count;
    }
    else
    {
        if(_isZJ)
        {
            if(section >= _finishArr.count&& section != 0)//未完成
            {
                NSInteger index = section - _finishArr.count;

                if(!_finishArr.count)
                {
                    index = section - 1;
                }

                if(index == _unfinishArr.count - 1)
                {
                    NSArray * arr = [_unfinishArr[index] objectForKey:@"taskList"];
                    
                    NSInteger count = [arr count];
                    
                    if(_isZJReason)
                    {
                        return count;
                    }
                    if(!_isCreater)
                    {
                        return count;
                    }
                    
                    count += 1;

                    return count;
                }
                else if (index < _unfinishArr.count - 1)
                {
                    NSArray * arr = [_unfinishArr[index] objectForKey:@"taskList"];
                    
                    NSInteger count = [arr count];
                    
                    return count;
                }
                else//未完成为空->写上“无” + “完成总结”
                {
                    if(_isZJReason)
                    {
                        return 1;
                    }
                    else
                    {
                        return 2;
                    }
                }
            }
            else if(section >= 0)//已完成
            {
                if(section < _finishArr.count)
                {
                    NSArray * arr = [_finishArr[section] objectForKey:@"taskList"];
                    
                    NSInteger count = [arr count];
                    
                    return count;
                }
                else//已完成为空->写上“无”
                {
                    return 1;
                }
            }
            
            return 0;
        }
        else
        {
            if(section < _rows.count)
            {
                NSArray * arr = [_rows[section] objectForKey:@"taskList"];
                
                NSInteger count = [arr count];

                if(section == _rows.count - 1)
                {
                    if(!_isCreater)
                    {
                        return count;
                    }
                    
                    count += 1;
                }
                
                return count;
            }
            else
            {
                return 0;
            }
        }
        
    }
}


- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(tableView == _tableView)
    {
        if(indexPath.row == 0 && indexPath.section == 0)
        {
            return NO;
        }
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
    else
    {
        return YES;
    }
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if(tableView == _tableView)
    {
        return 0;
    }
    else
    {
        if(_isZJ)
        {
            if(section >= _finishArr.count&& section != 0)//未完成
            {
                NSInteger index = section - _finishArr.count;
                
                if(!_finishArr.count)
                {
                    index = section - 1;
                }
                
                if(index == _unfinishArr.count - 1)
                {
                    if(_unfinishArr.count == 1)
                    {
                        return 74;
                    }
                    else
                    {
                        return 34;
                    }
                }
                else if (index < _unfinishArr.count - 1)
                {
                    if(index == 0)
                    {
                        return 74;
                    }
                    return 34;
                }
                else//未完成为空->写上“无” + “完成总结”
                {
                    return 34;
                }
            }
            else if(section >= 0)//已完成
            {
                if(section < _finishArr.count)
                {
                    return 60;
                }
                else//已完成为空->写上“无”
                {
                    return 34;
                }
            }
            return 34;
        }
        else
        {
            return 34;
        }
    }
}

- (UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if(tableView == _tableView)
    {
        return nil;
    }
    else
    {
        if(_isZJ)
        {
            if(section >= _finishArr.count&& section != 0)//未完成
            {
                NSInteger index = section - _finishArr.count;
                
                if(!_finishArr.count)
                {
                    index = section - 1;
                }
                
                if(index == _unfinishArr.count - 1)
                {
                    if(_unfinishArr.count == 1)
                    {
                        UIView* myView = [[UIView alloc] init];
                        myView.backgroundColor = [UIColor backgroundColor];
                        
                        //未完成线
                        UIView * line = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREENWIDTH, 0.5)];
                        line.backgroundColor = [UIColor grayLineColor];
                        [myView addSubview:line];
                        
                        UILabel * titleLbl = [[UILabel alloc] initWithFrame:CGRectMake(14, 14, 100, 18)];
                        titleLbl.backgroundColor = [UIColor clearColor];
                        titleLbl.textColor = [UIColor whiteColor];
                        titleLbl.font = Font(17);
                        
                        [myView addSubview:titleLbl];
                        
                        UIView * titleView = [[UIView alloc] initWithFrame:CGRectMake(0, 28 + Y(titleLbl), SCREENWIDTH, 28)];
                        titleView.backgroundColor = [UIColor clearColor];
                        [myView addSubview:titleView];
                        
                        UIImageView * icon = [[UIImageView alloc] initWithFrame:CGRectMake(14, 2, 8, 11)];
                        icon.image = [UIImage imageNamed:@"icon_zhuyaogongzu"];
                        [titleView addSubview:icon];
                        
                        UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(27, -2, 200, 18)];
                        titleLabel.textColor=[UIColor whiteColor];
                        titleLabel.backgroundColor = [UIColor clearColor];
                        titleLabel.font = Font(15);
                        
                        titleLbl.text = @"未完成";
                        titleLabel.text = [_unfinishArr[index] valueForKey:@"labelName"];
                        
                        [titleView addSubview:titleLabel];
                        
                        return myView;
                    }
                    else
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
                        
                        titleLabel.text = [_unfinishArr[index] valueForKey:@"labelName"];
                        [titleView addSubview:titleLabel];
                        
                        return myView;
                    }

                }
                else if (index < _unfinishArr.count - 1)
                {
                    if(index == 0)
                    {
                        UIView* myView = [[UIView alloc] init];
                        myView.backgroundColor = [UIColor backgroundColor];
                        
                        //未完成线
                        UIView * line = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREENWIDTH, 0.5)];
                        line.backgroundColor = [UIColor grayLineColor];
                        [myView addSubview:line];
                        
                        UILabel * titleLbl = [[UILabel alloc] initWithFrame:CGRectMake(14, 14, 100, 18)];
                        titleLbl.backgroundColor = [UIColor clearColor];
                        titleLbl.textColor = [UIColor whiteColor];
                        titleLbl.font = Font(17);

                        [myView addSubview:titleLbl];
                        
                        UIView * titleView = [[UIView alloc] initWithFrame:CGRectMake(0, 28 + Y(titleLbl), SCREENWIDTH, 28)];
                        titleView.backgroundColor = [UIColor clearColor];
                        [myView addSubview:titleView];
                        
                        UIImageView * icon = [[UIImageView alloc] initWithFrame:CGRectMake(14, 2, 8, 11)];
                        icon.image = [UIImage imageNamed:@"icon_zhuyaogongzu"];
                        [titleView addSubview:icon];
                        
                        UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(27, -2, 200, 18)];
                        titleLabel.textColor=[UIColor whiteColor];
                        titleLabel.backgroundColor = [UIColor clearColor];
                        titleLabel.font = Font(15);
                        
                        titleLbl.text = @"未完成";
                        titleLabel.text = [_unfinishArr[index] valueForKey:@"labelName"];
                        
                        [titleView addSubview:titleLabel];
                        
                        return myView;
                    }
                    else
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
                        
                        titleLabel.text = [_unfinishArr[index] valueForKey:@"labelName"];
                        [titleView addSubview:titleLabel];
                        
                        return myView;

                    }
                    return nil;
                }
                else//未完成为空->写上“无” + “完成总结”
                {
                    UIView* myView = [[UIView alloc] init];
                    myView.backgroundColor = [UIColor backgroundColor];
                    
                    UILabel * titleLbl = [[UILabel alloc] initWithFrame:CGRectMake(14, 0, 100, 18)];
                    titleLbl.backgroundColor = [UIColor clearColor];
                    titleLbl.textColor = [UIColor whiteColor];
                    titleLbl.font = Font(17);
                    titleLbl.text = @"未完成";
                    
                    [myView addSubview:titleLbl];
                    return myView;
                }
            }
            else if(section >= 0)//已完成
            {
                if(section < _finishArr.count)
                {
                    UIView* myView = [[UIView alloc] init];
                    myView.backgroundColor = [UIColor backgroundColor];
                    
                    UILabel * titleLbl = [[UILabel alloc] initWithFrame:CGRectMake(14, 0, 100, 18)];
                    titleLbl.backgroundColor = [UIColor clearColor];
                    titleLbl.textColor = [UIColor whiteColor];
                    titleLbl.font = Font(17);
                    
                    [myView addSubview:titleLbl];
                    
                    UIView * titleView = [[UIView alloc] initWithFrame:CGRectMake(0, 28, SCREENWIDTH, 28)];
                    titleView.backgroundColor = [UIColor clearColor];
                    [myView addSubview:titleView];
                    
                    UIImageView * icon = [[UIImageView alloc] initWithFrame:CGRectMake(14, 2, 8, 11)];
                    icon.image = [UIImage imageNamed:@"icon_zhuyaogongzu"];
                    [titleView addSubview:icon];
                    
                    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(27, -2, 200, 18)];
                    titleLabel.textColor=[UIColor whiteColor];
                    titleLabel.backgroundColor = [UIColor clearColor];
                    titleLabel.font = Font(15);
                    
                    titleLbl.text = @"已完成";
                    titleLabel.text = [_finishArr[section] valueForKey:@"labelName"];
                    
                    [titleView addSubview:titleLabel];
                    
                    return myView;
                }
                else//已完成为空->写上“无”
                {
                    UIView* myView = [[UIView alloc] init];
                    myView.backgroundColor = [UIColor backgroundColor];
                    
                    UILabel * titleLbl = [[UILabel alloc] initWithFrame:CGRectMake(14, 0, 100, 18)];
                    titleLbl.backgroundColor = [UIColor clearColor];
                    titleLbl.textColor = [UIColor whiteColor];
                    titleLbl.font = Font(17);
                    titleLbl.text = @"已完成";
                    
                    [myView addSubview:titleLbl];
                    return myView;
                }
            }
            return nil;
        }
        else
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
            
            titleLabel.text = [_rows[section] valueForKey:@"labelName"];
            [titleView addSubview:titleLabel];
            
            return myView;
        }

    }
}


- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(tableView == _tableView)
    {
        NSInteger index = indexPath.row;
        
        static NSString *cellId = @"WorkPlanCell";
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
            
            UIImageView* photo = [cell.contentView viewWithTag:100];
            if(!photo)
            {
                photo = [[UIImageView alloc] initWithFrame:CGRectMake(14, 14, 50, 50)];
                
                [photo setBackgroundColor:[UIColor clearColor]];
                //[photo setImage:[UIImage imageNamed:@"icon_chengyuan"]];
                photo.layer.cornerRadius = 5.0f;
                photo.clipsToBounds = YES;
                photo.tag = 100;
                [cell.contentView addSubview:photo];
            }
            
            [photo setImageWithURL:[NSURL URLWithString:_currentMission.userImg] placeholderImage:[UIImage imageNamed:@"icon_chengyuan"] options:SDWebImageDelayPlaceholder usingActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
            
            
            UIButton * photoBtn = [cell.contentView viewWithTag:101];
            if(!photoBtn)
            {
                photoBtn = [[UIButton alloc]init];
                photoBtn.backgroundColor = [UIColor clearColor];
                photoBtn.frame = photo.frame;
                [photoBtn addTarget:self action:@selector(jumpToCreaterPersonInfo:) forControlEvents:UIControlEventTouchUpInside];
                photoBtn.tag = 101;
                [cell.contentView addSubview:photoBtn];
            }
            
            
            CGFloat titleWidth = [UICommon getSizeFromString:_currentMission.userName withSize:CGSizeMake(100, H(photo)) withFont:Font(16)].width;
            
            UILabel* userTitle = [[UILabel alloc] initWithFrame:CGRectMake(XW(photo) + 14, 14, titleWidth, 18)];
            [userTitle setBackgroundColor:[UIColor clearColor]];
            userTitle.text = _currentMission.userName;
            [userTitle setTextColor:RGBCOLOR(53, 159, 219)];
            [userTitle setFont:Font(16)];
            
            [cell.contentView addSubview:userTitle];
            
            //创建时间
            UILabel* tagLbl = [[UILabel alloc] initWithFrame:CGRectMake(X(userTitle), YH(userTitle) + 17, 250 , 14)];
            [tagLbl setBackgroundColor:[UIColor clearColor]];
            [tagLbl setTextColor:[UIColor grayTitleColor]];
            [tagLbl setFont:Font(12)];
            //        [tagLbl setNumberOfLines:0];
            tagLbl.minimumScaleFactor = 0.7;
            //        tagLbl.textAlignment = NSTextAlignmentCenter;
            
            //        tagLbl.text = nameStr;
            
            NSString * createStr = [UICommon dayAndHourFromString:_currentMission.createTime formatStyle:@"yyyy年MM月dd日 HH:mm"];
            
            tagLbl.text = [NSString stringWithFormat:@"创建时间：%@", createStr];
            
            [cell.contentView addSubview:tagLbl];
            
            
            //标题
            
            NSString* titleStr = _currentMission.title;

            if(_isZJ)
            {
                titleStr = [titleStr substringToIndex:titleStr.length - 2];
                
                titleStr = [NSString stringWithFormat:@"%@总结", titleStr];
            }
            
            CGFloat contentWidth = cWidth - 27 * 2;
            UIFont* font = Font(14);
            
            CGFloat contentHeight = [UICommon getSizeFromString:titleStr withSize:CGSizeMake(contentWidth, 1000) withFont:font].height;
            
            UILabel* title = [[UILabel alloc] initWithFrame:CGRectMake(27, YH(photo) + 18 + 10, contentWidth, contentHeight)];
            [title setBackgroundColor:[UIColor clearColor]];
            [title setTextColor:[UIColor whiteColor]];
            [title setFont:font];
            
            if(titleStr.length)
            {
                [title setNumberOfLines:1000];
            }
            else
            {
                titleStr = @"无标题";
            }
            [title setText:titleStr];
            [cell.contentView addSubview:title];
            
            UILabel * leftLbl = [[UILabel alloc] initWithFrame:CGRectMake(X(title), YH(title) + 20, 100, 18)];
            leftLbl.backgroundColor = [UIColor clearColor];
            leftLbl.text = @"主要工作";
            leftLbl.textColor = [UIColor whiteColor];
            leftLbl.font = Font(15);
            [cell.contentView addSubview:leftLbl];
            
            _layoutBtn = [[UIButton alloc] initWithFrame:CGRectMake(SCREENWIDTH - 76 - 14 - 13, YH(title) + 7, 76, 46)];
            _layoutBtn.backgroundColor = [UIColor clearColor];
            [_layoutBtn setTitleColor:[UIColor blueTextColor] forState:UIControlStateNormal];
            [_layoutBtn setContentHorizontalAlignment:UIControlContentHorizontalAlignmentRight];
            _layoutBtn.titleLabel.font = Font(15);
            
            NSString * statusTitle = @"状态视图";
            if(_statusLayoutShow)
            {
                statusTitle = @"简易视图";
            }
            [_layoutBtn setTitle:statusTitle forState:UIControlStateNormal];
            [_layoutBtn addTarget:self action:@selector(btnLayoutButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
            [cell.contentView addSubview:_layoutBtn];
            
            _planTableView = [[UITableView alloc] initWithFrame:CGRectMake(15, YH(leftLbl) + 18, SCREENWIDTH - 13 * 2 - 2, 34 * 3)];
            _planTableView.scrollEnabled = NO;
            _planTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
            _planTableView.backgroundColor = [UIColor clearColor];
            _planTableView.delegate = self;
            _planTableView.dataSource = self;
            
            if(!_statusLayoutShow)
            {
                if(_isZJ)
                {
                    NSInteger finishCount = 0;
                    NSInteger unfinishCount = 0;

                    for(int i = 0; i < _finishArr.count; i ++)
                    {
                        NSArray * arr = [_finishArr[i] objectForKey:@"taskList"];
                        
                        finishCount += arr.count;
                    }
                    for(int i = 0; i < _unfinishArr.count; i ++)
                    {
                        NSArray * arr = [_unfinishArr[i] objectForKey:@"taskList"];
                        
                        unfinishCount += arr.count;
                    }
                    CGFloat finishHeaderHeight = _finishArr.count ? 60 + (_finishArr.count - 1) * 34 : 34;
                    CGFloat unfinishHeaderHeight = _unfinishArr.count ? 74 + (_unfinishArr.count - 1) * 34 : 34;
                    
                    CGFloat planTableHeight = 0;
                    if(_isZJReason)
                    {
                        planTableHeight = unfinishCount * 51 + finishCount * 34 + finishHeaderHeight + unfinishHeaderHeight;
                        if(!finishCount)
                        {
                            planTableHeight += 34;
                        }
                        if(!unfinishCount)
                        {
                            planTableHeight += 34;
                        }
                    }
                    else
                    {
                        planTableHeight = unfinishCount * 72 + finishCount * 34 + finishHeaderHeight + unfinishHeaderHeight + 34;
                        if(!finishCount)
                        {
                            planTableHeight += 34;
                        }
                        if(!unfinishCount)
                        {
                            planTableHeight += 34;
                        }
                    }

                    _planTableView.height = planTableHeight;

                }
                else
                {
                    NSInteger count = 0;
                    for(int i = 0; i < _rows.count; i ++)
                    {
                        NSArray * arr = [_rows[i] objectForKey:@"taskList"];
                        
                        count += arr.count;
                    }
                    CGFloat planTableHeight = count * 34 + _rows.count * 34 + 34;
                    _planTableView.height = planTableHeight;
                }
            }
            else
            {
                if(_isZJ)
                {
                    CGFloat unfinishHe = 0;
                    CGFloat finishHe = 0;
                    
                    NSInteger finishCount = 0;
                    NSInteger unfinishCount = 0;

                    CGFloat finishHeaderHeight = _finishArr.count ? 60 + (_finishArr.count - 1) * 34 : 34;
                    CGFloat unfinishHeaderHeight = _unfinishArr.count ? 74 + (_unfinishArr.count - 1) * 34 : 34;
                    
                    for(NSDictionary * dic in _unfinishArr)
                    {
                        NSArray * ddArr = [dic objectForKey:@"taskList"];
                        
                        unfinishCount += ddArr.count;

                        for(int i = 0; i < ddArr.count; i ++)
                        {
                            Mission * mis = ddArr[i];
                            
                            NSString * title = [NSString stringWithFormat:@"%d. %@",i + 1, mis.title];
                            
                            CGFloat height = [UICommon getSizeFromString:title withSize:CGSizeMake(SCREENWIDTH - 14 - 38 - 13 * 2, 70) withFont:Font(14)].height;
                            
                            if(height > 70)
                            {
                                height = 70;
                            }
                            
                            if(_isZJReason)
                            {
                                height += 69;
                            }
                            else
                            {
                                height += 91;
                            }
                            
                            unfinishHe += height;
                            
                        }
                    }
                    
                    for(NSDictionary * dic in _finishArr)
                    {
                        NSArray * ddArr = [dic objectForKey:@"taskList"];
                        
                        finishCount += ddArr.count;

                        for(int i = 0; i < ddArr.count; i ++)
                        {
                            Mission * mis = ddArr[i];
                            
                            NSString * title = [NSString stringWithFormat:@"%d. %@",i + 1, mis.title];
                            
                            CGFloat height = [UICommon getSizeFromString:title withSize:CGSizeMake(SCREENWIDTH - 14 - 38 - 13 * 2, 70) withFont:Font(14)].height;
                            
                            if(height > 70)
                            {
                                height = 70;
                            }
                            
                            height += 51;
                            
                            finishHe += height;
                        }
                    }
                    
                    CGFloat planTableHeight = 0;
                    if(_isZJReason)
                    {
                        planTableHeight = unfinishHe + finishHe + finishHeaderHeight + unfinishHeaderHeight;
                        
                        if(!finishCount)
                        {
                            planTableHeight += 34;
                        }
                        if(!unfinishCount)
                        {
                            planTableHeight += 34;
                        }
                    }
                    else
                    {
                        planTableHeight = unfinishHe + finishHe + finishHeaderHeight + unfinishHeaderHeight + 34;
                        if(!finishCount)
                        {
                            planTableHeight += 34;
                        }
                        if(!unfinishCount)
                        {
                            planTableHeight += 34;
                        }
                    }
                    
                    _planTableView.height = planTableHeight;

                    
                    /*
                    CGFloat he = _layoutReasonHeight + 18;
                    
                    CGFloat he = rHe + 18;
                    
                    NSInteger finishCount = 0;
                    
                    for(int i = 0; i < _finishArr.count; i ++)
                    {
                        NSArray * arr = [_finishArr[i] objectForKey:@"taskList"];
                        
                        finishCount += arr.count;
                    }
                    
                    if(_finishArr.count)
                    {
                        he += finishCount * 34;
                    }
                    else
                    {
                        he += 34 * 3;
                    }
                    
                    _planTableView.height = he;*/
                }
                else
                {
//                    _planTableView.height = _layoutHeight + 18;
                    
                    CGFloat rowsHe = 0;
                    
                    for(NSDictionary * dic in _rows)
                    {
                        NSArray * ddArr = [dic objectForKey:@"taskList"];
                        
                        for(int i = 0; i < ddArr.count; i ++)
                        {
                            Mission * mis = ddArr[i];
                            
                            NSString * title = [NSString stringWithFormat:@"%d. %@",i + 1, mis.title];
                            
                            CGFloat height = [UICommon getSizeFromString:title withSize:CGSizeMake(SCREENWIDTH - 14 - 38 - 13 * 2, 70) withFont:Font(14)].height;
                            
                            if(height > 70)
                            {
                                height = 70;
                            }
                            
                            if(_isZJReason)
                            {
                                height += 69;
                            }
                            else
                            {
                                height += 51;
                            }
                            
                            rowsHe += height;
                        }
                    }
                    
                    CGFloat planTableHeight = 0;
//                    if(_isZJReason)
//                    {
//                            planTableHeight = unfinishCount * 51 + finishCount * 34 + finishHeaderHeight + unfinishHeaderHeight + 34;
//                    }
//                    else
                    {
                       planTableHeight = rowsHe + _rows.count * 34 + 34;
                    }
                    
                    _planTableView.height = planTableHeight;
                    

                }
            }
            
            if(!_isCreater)
            {
                CGFloat planHe = _planTableView.height;
                
                if(!_isZJReason)
                {
                    planHe -= 34;
                }

                _planTableView.height = planHe;
            }
            
            [cell.contentView addSubview:_planTableView];
            
            CGFloat newcHeight;
            CGFloat duiImgWidth = SCREENWIDTH - 13 * 2;
            CGFloat duiImgHeight;
            
            //对话框
            _duiimageview = [[UIImageView alloc] init];
            _duiimageview.image= [[UIImage imageNamed:@"bg_duihuakuang2"] stretchableImageWithLeftCapWidth:40 topCapHeight:30];
            
            duiImgHeight = YH(_planTableView) - 64;
            
            _duiimageview.frame = CGRectMake(14, YH(photo) + 7, duiImgWidth, duiImgHeight );
            
            newcHeight = YH(_duiimageview) + 14;
            
            [cell.contentView addSubview:_duiimageview];
            [cell.contentView sendSubviewToBack:_duiimageview];
            
            //设置cell的高度
            [cell setFrame:CGRectMake(0, 0, cWidth ,newcHeight)];
            
            UILabel* bottomLine = [[UILabel alloc] initWithFrame:CGRectMake(0, newcHeight - 1, cWidth, 0.5)];
            [bottomLine setBackgroundColor:[UIColor grayColor]];
            [cell.contentView addSubview:bottomLine];
        }
        else if (index > 0)
        {
            //cell.textLabel.text = [_dataList objectAtIndex:index];
            if (cell.contentView.subviews.count < 4) {
                
                NSInteger cIndex = index - 1;
                
                Comment* comm = [_commentArray objectAtIndex:cIndex];
                
                UIImageView* photo = [[UIImageView alloc] initWithFrame:CGRectMake(14, 14, 50, 50)];
                //[photo setImage:[UIImage imageNamed:@"icon_chengyuan"]];
                [photo setImageWithURL:[NSURL URLWithString:comm.userImg] placeholderImage:[UIImage imageNamed:@"icon_chengyuan"] options:SDWebImageDelayPlaceholder usingActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
                photo.layer.cornerRadius = 5.0f;
                photo.clipsToBounds = YES;
                [cell.contentView addSubview:photo];
                
                UIButton * photoBtn = [[UIButton alloc] init];
                photoBtn.frame = photo.frame;
                photoBtn.backgroundColor = [UIColor clearColor];
                [photoBtn addTarget:self action:@selector(jumpToPersonInfo:) forControlEvents:UIControlEventTouchUpInside];
                
                [cell.contentView addSubview:photoBtn];
                
                UIFont* font = [UIFont systemFontOfSize:14];
                
                UILabel* name = [[UILabel alloc] initWithFrame:CGRectMake(XW(photo) + 7, 20, 100, 15)];
                [name setBackgroundColor:[UIColor clearColor]];
                [name setText:comm.userName];
                [name setTextColor:[UIColor colorWithHexString:@"#3c9ed7"]];
                [name setFont:font];
                [name setTextAlignment:NSTextAlignmentLeft];
                
                [cell.contentView addSubview:name];
                
                CGFloat reContentWidth = cWidth - 70 - 52;
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
                
                if(comm.level == 2 && comm.parentName.length > 0 && ![comm.userName isEqualToString:comm.parentName])//评论
                {
                    mainStr = [NSString stringWithFormat:@"回复：%@  %@", comm.parentName, comm.main];
                    
                    isBlue = YES;
                }
                else if (comm.level == 1)//批示
                {
                    mainStr = [NSString stringWithFormat:@"批示：%@", comm.main];
                    
                    isGreen = YES;
                }
                
                mainStr = [mainStr stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];  //去除掉首尾的空白字符和换行字符
                
                height = [UICommon getSizeFromString:mainStr withSize:CGSizeMake(reContentWidth, 1000) withFont:Font(14)].height;
                
                CGFloat y = YH(name) + 8;
                
                UILabel* revContent = [[UILabel alloc] initWithFrame:CGRectMake(X(name), y, reContentWidth, height)];
                [revContent setBackgroundColor:[UIColor clearColor]];
                [revContent setTextColor:[UIColor whiteColor]];
                [revContent setFont:font];
                [revContent setTextAlignment:NSTextAlignmentLeft];
                [revContent setNumberOfLines:0];
                
                
                [revContent setText:mainStr];//momo todo
                
                if(mainStr.length > 0 && isBlue)
                {
                    NSAttributedString *attrStr = [RRAttributedString setText:mainStr color:[UIColor colorWithHexString:@"#3c9ed7"] range:NSMakeRange(3, mainStr.length - 3 - comm.main.length)];
                    
                    [revContent setAttributedText:attrStr];
                }
                else if (mainStr.length > 0 && isGreen)
                {
                    NSAttributedString *attrStr = [RRAttributedString setText:mainStr color:[UIColor colorWithHexString:@"#09f4a6"] range:NSMakeRange(0, 3)];
                    
                    [revContent setAttributedText:attrStr];
                }
                
                UILabel* date = [[UILabel alloc] initWithFrame:CGRectMake(cWidth - 60 - 40, 10, 86, 12)];
                [date setBackgroundColor:[UIColor clearColor]];
                
                NSString * timeStr = [UICommon dayAndHourFromString:comm.createTime formatStyle:@"MM月dd日 HH:mm"];
                [date setText:timeStr];
                [date setTextColor:[UIColor colorWithRed:[self colorWithRGB:122] green:[self colorWithRGB:122] blue:[self colorWithRGB:122] alpha:1.0f]];
                [date setFont:[UIFont systemFontOfSize:10]];
                [date setTextAlignment:NSTextAlignmentRight];
                
                [cell.contentView addSubview:date];
                
                if(comm.accessoryList.count)
                {
                    UILabel * fileLbl = [[UILabel alloc] initWithFrame:CGRectMake(XW(photo) + 22, YH(name) + 14, 200, 14)];
                    fileLbl.text = [NSString stringWithFormat:@"附件(%ld)", comm.accessoryList.count];
                    fileLbl.textColor = [UIColor grayTitleColor];
                    fileLbl.font = Font(12);
                    
                    UIImageView* fileIcon = [[UIImageView alloc] initWithFrame:CGRectMake(XW(photo) + 7, Y(fileLbl) + 2, 12, 10)];
                    fileIcon.image = [UIImage imageNamed:@"btn_fujianIcon"];
                    [cell.contentView addSubview:fileIcon];
                    
                    [cell.contentView addSubview:fileLbl];
                    
                    int lineCount = 4;
                    
                    if(SCREENWIDTH == 320)
                    {
                        lineCount = 3;
                    }
                    
                    CGFloat accHeight = 94;
                    CGFloat imgHeight = 50;
                    CGFloat accWidth = 68;
                    CGFloat intevalHeight = (SCREENWIDTH - (XW(photo) + 6) - accWidth * lineCount - 14) / (lineCount - 1);
                    if(intevalHeight < 0)
                    {
                        intevalHeight = 0;
                    }
                    
                    CGFloat attchHeight = ((comm.accessoryList.count - 1) / lineCount + 1) * accHeight;
                    
                    UIView* attchView = [[UIView alloc] init];
                    attchView.frame = CGRectMake(XW(photo) + 6, YH(fileLbl) + 10, SCREENWIDTH - (XW(photo) + 6), attchHeight);
                    [attchView setBackgroundColor:[UIColor clearColor]];
                    
                    for(int i = 0; i < comm.accessoryList.count; i ++)
                    {
                        int j = i / lineCount;
                        
                        int k = i % lineCount;
                        
                        Accessory * acc = comm.accessoryList[i];
                        
                        CGRect attaFrame = CGRectMake(9 + (accWidth + intevalHeight) * k, accHeight * j, imgHeight, imgHeight);
                        
                        UIImageView* attachment = [[UIImageView alloc] initWithFrame:attaFrame];
                        UILabel * fileNameLbl = [[UILabel alloc] init];
                        fileNameLbl.frame = CGRectMake(X(attachment) - 9, YH(attachment), accWidth, 40);
                        fileNameLbl.backgroundColor = [UIColor clearColor];
                        fileNameLbl.textColor = [UIColor whiteColor];
                        fileNameLbl.numberOfLines = 2;
                        fileNameLbl.text = acc.name;
                        fileNameLbl.font = Font(10);
                        [attachment addSubview:fileNameLbl];
                        // 1: doc/docx  2: xls/xlsx 3: ppt/pptx 4: pdf 0: png/jpg 6:其他
                        
                        int fileType = [[UICommon findFileType:acc.name] intValue];
                        //                        int fileType = [acc.fileType intValue];
                        
                        attachment.userInteractionEnabled = YES;
                        
                        if(fileType == 0)//to do
                        {
                            [attachment setImageWithURL:[NSURL URLWithString:acc.address]
                                       placeholderImage:[UIImage imageNamed:@"bimg.jpg"]
                                                options:SDWebImageDelayPlaceholder
                            usingActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
                            
                            //                            UIButton * imgBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, W(attachment), H(attachment))];
                            //                            imgBtn.backgroundColor = [UIColor clearColor];
                            
                            //                            NSInteger fileCount = comm.accessoryList.count - _imageArray.count;
                            //                            imgBtn.tag = fileCount > 0 ? i - fileCount : i;
                            //
                            //                            [imgBtn addTarget:self action:@selector(seeFullScreenImg:) forControlEvents:UIControlEventTouchUpInside];
                            //                            [attachment addSubview:imgBtn];
                        }
                        else
                        {
                            NSString * imgName = @"";
                            if(fileType == 1)//to do
                            {
                                imgName = @"icon_word_xiao";
                            }
                            else if (fileType == 2)
                            {
                                imgName = @"icon_excel_xiao";
                            }
                            else if (fileType == 3)
                            {
                                imgName = @"icon_ppt_xiao";
                            }
                            else if (fileType == 4)
                            {
                                imgName = @"icon_pdf_xiao";
                            }
                            else if(fileType == 6)
                            {
                                imgName = @"icon_other_xiao";
                            }
                            attachment.image = [UIImage imageNamed:imgName];
                        }
                        
                        UIButton * imgBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, W(attachment), H(attachment))];
                        imgBtn.backgroundColor = [UIColor clearColor];
                        imgBtn.tag = i;
                        [imgBtn addTarget:self action:@selector(previewCommentFile:) forControlEvents:UIControlEventTouchUpInside];
                        [attachment addSubview:imgBtn];
                        
                        [attchView addSubview:attachment];
                        [attchView addSubview:fileNameLbl];
                    }
                    
                    [cell.contentView addSubview:attchView];
                    
                    height = YH(attchView);
                    
                }
                else
                {
                    [cell.contentView addSubview:revContent];
                    
                    if(comm.level == 2)
                    {
                        UIButton* par = [[UIButton alloc] initWithFrame:CGRectMake(cWidth - 39, YH(date) + 20, 25, 20)];
                        //[par setTitle:@"20" forState:UIControlStateNormal];
                        [par setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
                        [par setBackgroundColor:[UIColor clearColor]];
                        if(comm.praiseNum > 0)
                        {
                            [par setBackgroundImage:[UIImage imageNamed:@"btn_zan2"] forState:UIControlStateNormal];
                        }
                        else
                        {
                            [par setBackgroundImage:[UIImage imageNamed:@"btn_zan"] forState:UIControlStateNormal];
                        }
                        //                [par.layer setBorderWidth:0.5f];
                        //                [par.layer setCornerRadius:10];
                        //                [par.layer setBorderColor:[[UIColor whiteColor] CGColor]];
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
                    
                    if(height < 33)
                    {
                        height = 78;
                    }
                    else
                    {
                        height = height + 35 + 24;
                    }
                }
                
                [cell setFrame:CGRectMake(0, 0, cWidth ,height)];
                
                UILabel* bottomLine = [[UILabel alloc] initWithFrame:CGRectMake(0, height - 1, cWidth, 0.5)];
                [bottomLine setBackgroundColor:[UIColor grayColor]];
                [cell.contentView addSubview:bottomLine];
                
            }
            
        }
        
        //    [cell.contentView setBackgroundColor:[UIColor colorWithRed:0.15f green:0.15f blue:0.15f alpha:1.0f]];
        [cell.contentView setBackgroundColor:RGBCOLOR(47, 47, 47)];
        
        return cell;
    }
    else
    {
        if(!_statusLayoutShow)
        {
            static NSString *cellId = @"Cell";
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
            if (cell == nil){
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
                cell.frame = CGRectMake(0, 0, SCREENWIDTH - 13 * 2, 34);
            }
            
            for(UIView *view in cell.contentView.subviews) {
                [view removeFromSuperview];
            }
            
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            
            if(_isZJ)
            {
                NSInteger section = indexPath.section;
                
                if(section >= _finishArr.count && section != 0)//未完成
                {
                    NSInteger index = section - _finishArr.count;
                    
                    if(!_finishArr.count)
                    {
                        index = section - 1;
                    }
                    
                    if(_unfinishArr.count)
                    {
                        NSArray * arr = [_unfinishArr[index] objectForKey:@"taskList"];

                        if(indexPath.row == arr.count)
                        {
                            UIButton * titleBtn = [[UIButton alloc] initWithFrame:CGRectMake(28, 0, 85, 20)];
                            titleBtn.backgroundColor = [UIColor clearColor];
                            [titleBtn setTitleColor:[UIColor blueTextColor] forState:UIControlStateNormal];
                            titleBtn.titleLabel.font = Font(17);
                            [titleBtn setTitle:@"完成总结" forState:UIControlStateNormal];
                            titleBtn.titleLabel.textAlignment = NSTextAlignmentLeft;
                            [titleBtn addTarget:self action:@selector(doneZJClick:) forControlEvents:UIControlEventTouchUpInside];
                            
                            UIImageView * icon = [[UIImageView alloc] initWithFrame:CGRectMake(14, 2 + Y(titleBtn), 15, 15)];
                            icon.image = [UIImage imageNamed:@"icon_gongzuozongjie"];
                            
                            UIButton * cancelBtn = [[UIButton alloc] initWithFrame:CGRectMake(SCREENWIDTH - 13 - 60 - 14, Y(titleBtn), 60, 20)];
                            cancelBtn.backgroundColor = [UIColor clearColor];
                            [cancelBtn setTitleColor:[UIColor blueTextColor] forState:UIControlStateNormal];
                            cancelBtn.titleLabel.font = Font(17);
                            [cancelBtn setTitle:@"取消" forState:UIControlStateNormal];
                            cancelBtn.titleLabel.textAlignment = NSTextAlignmentRight;
                            [cancelBtn addTarget:self action:@selector(cancelZJClick:) forControlEvents:UIControlEventTouchUpInside];
                            
                            [cell.contentView addSubview:icon];
                            [cell.contentView addSubview:titleBtn];
                            [cell.contentView addSubview:cancelBtn];
     
                            cell.contentView.backgroundColor = [UIColor backgroundColor];
                            cell.tag = 123;
                            
                            return cell;

                        }
                        else if (indexPath.row < arr.count)
                        {
                            Mission * mis = arr[indexPath.row];
                            
                            UILabel * titleLbl = [[UILabel alloc] initWithFrame:CGRectMake(14, -2, SCREENWIDTH - 13 * 2 - 95 - 14, 16)];
                            titleLbl.text = [NSString stringWithFormat:@"%ld. %@",indexPath.row + 1, mis.title];
                            titleLbl.font = Font(14);
                            titleLbl.textColor = [UIColor whiteColor];
                            titleLbl.backgroundColor = [UIColor clearColor];
                            [cell.contentView addSubview:titleLbl];
                            
                            
                            //-3:已超时  -2删除   -1停用   0：未开始 1进行中   2：已完成
                            
                            UILabel * statusLbl = [[UILabel alloc] initWithFrame:CGRectMake(SCREENWIDTH - 13 * 2 - 32 - 50, -2, 50, 16)];
                            statusLbl.backgroundColor = [UIColor clearColor];
                            statusLbl.textColor = [UIColor grayTitleColor];
                            statusLbl.font = Font(14);
                            statusLbl.textAlignment = NSTextAlignmentRight;
                            
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
                                
                                statusLbl.textColor = [UIColor redTextColor];
                            }
                            
                            statusLbl.text = statusStr;
                            [cell.contentView addSubview:statusLbl];
                            
                            UIImageView * icon = [[UIImageView alloc] initWithFrame:CGRectMake(SCREENWIDTH - 13 * 2 - 14 - 10, 2, 10, 10)];
                            icon.image = [UIImage imageNamed:@"icon_jiantou_3"];
                            [cell.contentView addSubview:icon];
                            
                            if(_isZJReason)
                            {
                                UILabel * reasonLbl = [[UILabel alloc] initWithFrame:CGRectMake(28, YH(titleLbl) + 5, SCREENWIDTH - 13 * 2 - 30 * 2, 16)];
                                reasonLbl.backgroundColor = [UIColor clearColor];
                                reasonLbl.font = Font(14);
                                reasonLbl.textColor = [UIColor whiteColor];
                                
                                NSString * nameStr = [NSString stringWithFormat:@"原因：%@。", mis.reason];
                                NSAttributedString *nameAttrStr = [RRAttributedString setText:nameStr font:Font(14) color:RGBCOLOR(249, 223, 100) range:NSMakeRange(0, 3)];

                                reasonLbl.attributedText = nameAttrStr;
                                
                                [cell.contentView addSubview:reasonLbl];
                            }
                            else
                            {
                                UITextField * reasonTxt = [[UITextField alloc] initWithFrame:CGRectMake(7, 0, SCREENWIDTH - 13 * 2 - 30 * 2 - 7, 33)];
                                reasonTxt.placeholder = @"请总结未完成原因";
                                [reasonTxt setValue:[UIColor grayTitleColor] forKeyPath:@"_placeholderLabel.textColor"];
                                reasonTxt.font = Font(14);
                                reasonTxt.text = mis.reason;
                                reasonTxt.textColor = [UIColor blackColor];
                                reasonTxt.backgroundColor = [UIColor clearColor];
                                reasonTxt.textAlignment = NSTextAlignmentLeft;
                                [self addDoneToKeyboard:reasonTxt];
                                reasonTxt.delegate = self;
                                reasonTxt.tag = 100 + indexPath.row;
                                
                                UIView * txtView = [[UIView alloc] initWithFrame:CGRectMake(30, YH(titleLbl) + 6, SCREENWIDTH - 13 * 2 - 30 * 2, 33)];
                                txtView.backgroundColor = [UIColor whiteColor];
                                [txtView setRoundColorCorner:5 withColor:[UIColor grayLineColor]];
                                
                                [txtView addSubview:reasonTxt];
                                [cell.contentView addSubview:txtView];
                            }
                            
                            cell.backgroundColor = [UIColor backgroundColor];
                            
                            return cell;
                        }
                    }
                    else//未完成为空->写上“无” + “完成总结”
                    {
                        if(indexPath.row == 0)
                        {
                            UILabel * titleLbl = [[UILabel alloc] initWithFrame:CGRectMake(14, 0, 100, 16)];
                            titleLbl.text = @"无";
                            titleLbl.backgroundColor = [UIColor clearColor];
                            titleLbl.textColor = [UIColor whiteColor];
                            titleLbl.font = Font(14);
                            [cell.contentView addSubview:titleLbl];
                            
                            cell.contentView.backgroundColor = [UIColor backgroundColor];
                            
                            return cell;
                        }
                        else
                        {
                            UIButton * titleBtn = [[UIButton alloc] initWithFrame:CGRectMake(28, 0, 85, 20)];
                            titleBtn.backgroundColor = [UIColor clearColor];
                            [titleBtn setTitleColor:[UIColor blueTextColor] forState:UIControlStateNormal];
                            titleBtn.titleLabel.font = Font(17);
                            [titleBtn setTitle:@"完成总结" forState:UIControlStateNormal];
                            titleBtn.titleLabel.textAlignment = NSTextAlignmentLeft;
                            [titleBtn addTarget:self action:@selector(doneZJClick:) forControlEvents:UIControlEventTouchUpInside];
                            
                            UIImageView * icon = [[UIImageView alloc] initWithFrame:CGRectMake(14, 2 + Y(titleBtn), 15, 15)];
                            icon.image = [UIImage imageNamed:@"icon_gongzuozongjie"];
                            
                            UIButton * cancelBtn = [[UIButton alloc] initWithFrame:CGRectMake(SCREENWIDTH - 13 - 60 - 14, Y(titleBtn), 60, 20)];
                            cancelBtn.backgroundColor = [UIColor clearColor];
                            [cancelBtn setTitleColor:[UIColor blueTextColor] forState:UIControlStateNormal];
                            cancelBtn.titleLabel.font = Font(17);
                            [cancelBtn setTitle:@"取消" forState:UIControlStateNormal];
                            cancelBtn.titleLabel.textAlignment = NSTextAlignmentRight;
                            [cancelBtn addTarget:self action:@selector(cancelZJClick:) forControlEvents:UIControlEventTouchUpInside];
                            
                            [cell.contentView addSubview:icon];
                            [cell.contentView addSubview:titleBtn];
                            [cell.contentView addSubview:cancelBtn];
                            
                            cell.contentView.backgroundColor = [UIColor backgroundColor];
                            cell.tag = 123;
                            
                            return cell;
                            
                        }
                    }
                }
                else if(section >= 0)//已完成
                {
                    if(section < _finishArr.count)
                    {
                        NSArray * arr = [_finishArr[indexPath.section] objectForKey:@"taskList"];
                        
                        if(arr.count)
                        {
                            if(indexPath.row < arr.count)
                            {
                                Mission * mis = arr[indexPath.row];
                                
                                UILabel * titleLbl = [[UILabel alloc] initWithFrame:CGRectMake(14, -2, SCREENWIDTH - 13 * 2 - 95 - 14, 16)];
                                titleLbl.text = [NSString stringWithFormat:@"%ld. %@",indexPath.row + 1, mis.title];
                                titleLbl.font = Font(14);
                                titleLbl.textColor = [UIColor whiteColor];
                                titleLbl.backgroundColor = [UIColor clearColor];
                                [cell.contentView addSubview:titleLbl];
                                
                                
                                //-3:已超时  -2删除   -1停用   0：未开始 1进行中   2：已完成
                                
                                UILabel * statusLbl = [[UILabel alloc] initWithFrame:CGRectMake(SCREENWIDTH - 13 * 2 - 32 - 50, -2, 50, 16)];
                                statusLbl.backgroundColor = [UIColor clearColor];
                                statusLbl.textColor = [UIColor grayTitleColor];
                                statusLbl.font = Font(14);
                                statusLbl.textAlignment = NSTextAlignmentRight;
                                
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
                                    
                                    statusLbl.textColor = [UIColor redTextColor];
                                }
                                
                                statusLbl.text = statusStr;
                                [cell.contentView addSubview:statusLbl];
                                
                                UIImageView * icon = [[UIImageView alloc] initWithFrame:CGRectMake(SCREENWIDTH - 13 * 2 - 14 - 10, 2, 10, 10)];
                                icon.image = [UIImage imageNamed:@"icon_jiantou_3"];
                                [cell.contentView addSubview:icon];
                                
                                cell.backgroundColor = [UIColor backgroundColor];
                                
                                return cell;
                            }
                        }
                    }
                    else//已完成为空->写上“无”
                    {
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
                    }
                }
                
                return cell;
            }
            else
            {
                if(indexPath.section < _rows.count)
                {
                    NSArray * arr = [_rows[indexPath.section] objectForKey:@"taskList"];
                    
                    if(arr.count)
                    {
                        if(indexPath.row < arr.count)
                        {
                            Mission * mis = arr[indexPath.row];
                            
                            UILabel * titleLbl = [[UILabel alloc] initWithFrame:CGRectMake(14, -2, SCREENWIDTH - 13 * 2 - 95 - 14, 16)];
                            titleLbl.text = [NSString stringWithFormat:@"%ld. %@",indexPath.row + 1, mis.title];
                            titleLbl.font = Font(14);
                            titleLbl.textColor = [UIColor whiteColor];
                            titleLbl.backgroundColor = [UIColor clearColor];
                            [cell.contentView addSubview:titleLbl];
                            
                            
                            //-3:已超时  -2删除   -1停用   0：未开始 1进行中   2：已完成
                            
                            UILabel * statusLbl = [[UILabel alloc] initWithFrame:CGRectMake(SCREENWIDTH - 13 * 2 - 32 - 50, -2, 50, 16)];
                            statusLbl.backgroundColor = [UIColor clearColor];
                            statusLbl.textColor = [UIColor grayTitleColor];
                            statusLbl.font = Font(14);
                            statusLbl.textAlignment = NSTextAlignmentRight;
                            
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
                                
                                statusLbl.textColor = [UIColor redTextColor];
                            }
                            
                            statusLbl.text = statusStr;
                            [cell.contentView addSubview:statusLbl];
                            
                            UIImageView * icon = [[UIImageView alloc] initWithFrame:CGRectMake(SCREENWIDTH - 13 * 2 - 14 - 10, 2, 10, 10)];
                            icon.image = [UIImage imageNamed:@"icon_jiantou_3"];
                            [cell.contentView addSubview:icon];
                            
                            cell.backgroundColor = [UIColor backgroundColor];
                            
                            return cell;
                        }
                        else if (indexPath.row == arr.count)
                        {
                            static NSString *cellId = @"Cell";
                            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
                            if (cell == nil){
                                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
                                cell.frame = CGRectMake(0, 0, SCREENWIDTH - 13 * 2, 84);
                            }
                            
                            for(UIView *view in cell.contentView.subviews) {
                                [view removeFromSuperview];
                            }
                            
                            cell.selectionStyle = UITableViewCellSelectionStyleNone;
                            
                            UILabel * titleLbl = [[UILabel alloc] initWithFrame:CGRectMake(35, 0, 200, 20)];
                            titleLbl.backgroundColor = [UIColor clearColor];
                            titleLbl.textColor = [UIColor blueTextColor];
                            titleLbl.font = Font(17);
                            titleLbl.text = @"工作总结";
                            
                            UIImageView * icon = [[UIImageView alloc] initWithFrame:CGRectMake(14, 2, 15, 15)];
                            icon.image = [UIImage imageNamed:@"icon_gongzuozongjie"];
                            [cell.contentView addSubview:icon];
                            
                            [cell.contentView addSubview:titleLbl];
                            cell.backgroundColor = [UIColor backgroundColor];
                            
                            return cell;
                            
                        }
                    }
                    else if(arr.count == 0 && indexPath.section == _rows.count - 1)
                    {
                        static NSString *cellId = @"Cell";
                        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
                        if (cell == nil){
                            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
                            cell.frame = CGRectMake(0, 0, SCREENWIDTH - 13 * 2, 84);
                        }
                        
                        for(UIView *view in cell.contentView.subviews) {
                            [view removeFromSuperview];
                        }
                        
                        cell.selectionStyle = UITableViewCellSelectionStyleNone;
                        
                        UILabel * titleLbl = [[UILabel alloc] initWithFrame:CGRectMake(35, 0, 200, 20)];
                        titleLbl.backgroundColor = [UIColor clearColor];
                        titleLbl.textColor = [UIColor blueTextColor];
                        titleLbl.font = Font(17);
                        titleLbl.text = @"工作总结";
                        
                        UIImageView * icon = [[UIImageView alloc] initWithFrame:CGRectMake(14, 2, 15, 15)];
                        icon.image = [UIImage imageNamed:@"icon_gongzuozongjie"];
                        [cell.contentView addSubview:icon];
                        
                        [cell.contentView addSubview:titleLbl];
                        cell.backgroundColor = [UIColor backgroundColor];
                        
                        return cell;
                        
                    }
                    return cell;
                }
            }
            

        }
        else
        {
            static NSString *cellId = @"Cell";
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
            if (cell == nil){
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
                cell.frame = CGRectMake(0, 0, SCREENWIDTH - 13 * 2, 34);
            }
            
            for(UIView *view in cell.contentView.subviews) {
                [view removeFromSuperview];
            }
            
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            
            if(_isZJ)
            {
                NSInteger section = indexPath.section;
                
                if(section >= _finishArr.count && section != 0)//未完成
                {
                    NSInteger index = section - _finishArr.count;
                    
                    if(!_finishArr.count)
                    {
                        index = section - 1;
                    }
                    
                    if(_unfinishArr.count)
                    {
                        NSArray * arr = [_unfinishArr[index] objectForKey:@"taskList"];
                        
                        if(indexPath.row == arr.count)
                        {
                            UIButton * titleBtn = [[UIButton alloc] initWithFrame:CGRectMake(28, 0, 85, 20)];
                            titleBtn.backgroundColor = [UIColor clearColor];
                            [titleBtn setTitleColor:[UIColor blueTextColor] forState:UIControlStateNormal];
                            titleBtn.titleLabel.font = Font(17);
                            [titleBtn setTitle:@"完成总结" forState:UIControlStateNormal];
                            titleBtn.titleLabel.textAlignment = NSTextAlignmentLeft;
                            [titleBtn addTarget:self action:@selector(doneZJClick:) forControlEvents:UIControlEventTouchUpInside];
                            
                            UIImageView * icon = [[UIImageView alloc] initWithFrame:CGRectMake(14, 2 + Y(titleBtn), 15, 15)];
                            icon.image = [UIImage imageNamed:@"icon_gongzuozongjie"];
                            
                            UIButton * cancelBtn = [[UIButton alloc] initWithFrame:CGRectMake(SCREENWIDTH - 13 - 60 - 14, Y(titleBtn), 60, 20)];
                            cancelBtn.backgroundColor = [UIColor clearColor];
                            [cancelBtn setTitleColor:[UIColor blueTextColor] forState:UIControlStateNormal];
                            cancelBtn.titleLabel.font = Font(17);
                            [cancelBtn setTitle:@"取消" forState:UIControlStateNormal];
                            cancelBtn.titleLabel.textAlignment = NSTextAlignmentRight;
                            [cancelBtn addTarget:self action:@selector(cancelZJClick:) forControlEvents:UIControlEventTouchUpInside];
                            
                            [cell.contentView addSubview:icon];
                            [cell.contentView addSubview:titleBtn];
                            [cell.contentView addSubview:cancelBtn];
                            
                            cell.contentView.backgroundColor = [UIColor backgroundColor];
                            cell.tag = 123;
                            
                            return cell;
                            
                        }
                        else if (indexPath.row < arr.count)
                        {
                            Mission *mis = arr[indexPath.row];
                            
                            UILabel * titleLbl = [[UILabel alloc] initWithFrame:CGRectMake(14, 0, SCREENWIDTH - 14 - 38 - 13 * 2, 16)];
                            titleLbl.text = [NSString stringWithFormat:@"%ld. %@",indexPath.row + 1, mis.title];
                            titleLbl.height = [UICommon getSizeFromString:titleLbl.text withSize:CGSizeMake(SCREENWIDTH - 14 - 38 - 13 * 2, 70) withFont:Font(14)].height;
                            
                            if(titleLbl.height > 70)
                            {
                                titleLbl.height = 70;
                            }
                            titleLbl.backgroundColor = [UIColor clearColor];
                            titleLbl.textColor = [UIColor whiteColor];
                            titleLbl.numberOfLines = 3;
                            titleLbl.font = Font(14);
                            [cell.contentView addSubview:titleLbl];
                            
                            UIImageView * icon = [[UIImageView alloc]initWithFrame:CGRectMake(SCREENWIDTH - 14 - 10 - 13 * 2, 4, 10, 10)];
                            icon.image = [UIImage imageNamed:@"icon_jiantou_3"];
                            [cell.contentView addSubview:icon];
                            
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
                            
                            UILabel * statusLbl = [[UILabel alloc] initWithFrame:CGRectMake(30, titleLbl.bottom + 7, 54, 24)];
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
                                UIView * statusView = [[UIView alloc] initWithFrame:CGRectMake(30, titleLbl.bottom + 7, 54, 24)];
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
                            
                            if(_isZJReason)
                            {
                                UILabel * reasonLbl = [[UILabel alloc] initWithFrame:CGRectMake(28, YH(dateLbl) + 5, SCREENWIDTH - 13 * 2 - 30 * 2, 16)];
                                reasonLbl.backgroundColor = [UIColor clearColor];
                                reasonLbl.font = Font(14);
                                reasonLbl.textColor = [UIColor whiteColor];
                                
                                NSString * nameStr = [NSString stringWithFormat:@"原因：%@。", mis.reason];
                                NSAttributedString *nameAttrStr = [RRAttributedString setText:nameStr font:Font(14) color:RGBCOLOR(249, 223, 100) range:NSMakeRange(0, 3)];
                                
                                reasonLbl.attributedText = nameAttrStr;
                                
                                [cell.contentView addSubview:reasonLbl];
                                
                                CGFloat he = dateLbl.bottom + 38;
                                
                                CGRect rect = cell.frame;
                                rect.size.height = he;
                                cell.frame = rect;
                            }
                            else
                            {
                                UITextField * reasonTxt = [[UITextField alloc] initWithFrame:CGRectMake(7, 0, SCREENWIDTH - 13 * 2 - 30 * 2 - 7, 33)];
                                reasonTxt.placeholder = @"请总结未完成原因";
                                [reasonTxt setValue:[UIColor grayTitleColor] forKeyPath:@"_placeholderLabel.textColor"];
                                reasonTxt.font = Font(14);
                                reasonTxt.text = mis.reason;
                                reasonTxt.textColor = [UIColor blackColor];
                                reasonTxt.backgroundColor = [UIColor clearColor];
                                reasonTxt.textAlignment = NSTextAlignmentLeft;
                                [self addDoneToKeyboard:reasonTxt];
                                reasonTxt.delegate = self;
                                reasonTxt.tag = 100 + indexPath.row;
                                
                                UIView * txtView = [[UIView alloc] initWithFrame:CGRectMake(30, YH(dateLbl) + 6, SCREENWIDTH - 13 * 2 - 30 * 2, 33)];
                                txtView.backgroundColor = [UIColor whiteColor];
                                [txtView setRoundColorCorner:5 withColor:[UIColor grayLineColor]];
                                
                                [txtView addSubview:reasonTxt];
                                [cell.contentView addSubview:txtView];
                                
                                CGFloat he = dateLbl.bottom + 60;
                                
                                CGRect rect = cell.frame;
                                rect.size.height = he;
                                cell.frame = rect;
                            }

                            cell.backgroundColor = [UIColor backgroundColor];
                            
                            return cell;
                        }
                    }
                    else//未完成为空->写上“无” + “完成总结”
                    {
                        if(indexPath.row == 0)
                        {
                            UILabel * titleLbl = [[UILabel alloc] initWithFrame:CGRectMake(14, 0, 100, 16)];
                            titleLbl.text = @"无";
                            titleLbl.backgroundColor = [UIColor clearColor];
                            titleLbl.textColor = [UIColor whiteColor];
                            titleLbl.font = Font(14);
                            [cell.contentView addSubview:titleLbl];
                            
                            cell.contentView.backgroundColor = [UIColor backgroundColor];
                            
                            return cell;
                        }
                        else
                        {
                            UIButton * titleBtn = [[UIButton alloc] initWithFrame:CGRectMake(28, 0, 85, 20)];
                            titleBtn.backgroundColor = [UIColor clearColor];
                            [titleBtn setTitleColor:[UIColor blueTextColor] forState:UIControlStateNormal];
                            titleBtn.titleLabel.font = Font(17);
                            [titleBtn setTitle:@"完成总结" forState:UIControlStateNormal];
                            titleBtn.titleLabel.textAlignment = NSTextAlignmentLeft;
                            [titleBtn addTarget:self action:@selector(doneZJClick:) forControlEvents:UIControlEventTouchUpInside];
                            
                            UIImageView * icon = [[UIImageView alloc] initWithFrame:CGRectMake(14, 2 + Y(titleBtn), 15, 15)];
                            icon.image = [UIImage imageNamed:@"icon_gongzuozongjie"];
                            
                            UIButton * cancelBtn = [[UIButton alloc] initWithFrame:CGRectMake(SCREENWIDTH - 13 - 60 - 14, Y(titleBtn), 60, 20)];
                            cancelBtn.backgroundColor = [UIColor clearColor];
                            [cancelBtn setTitleColor:[UIColor blueTextColor] forState:UIControlStateNormal];
                            cancelBtn.titleLabel.font = Font(17);
                            [cancelBtn setTitle:@"取消" forState:UIControlStateNormal];
                            cancelBtn.titleLabel.textAlignment = NSTextAlignmentRight;
                            [cancelBtn addTarget:self action:@selector(cancelZJClick:) forControlEvents:UIControlEventTouchUpInside];
                            
                            [cell.contentView addSubview:icon];
                            [cell.contentView addSubview:titleBtn];
                            [cell.contentView addSubview:cancelBtn];
                            
                            cell.contentView.backgroundColor = [UIColor backgroundColor];
                            cell.tag = 123;
                            
                            return cell;
                            
                        }
                    }
                }
                else if(section >= 0)//已完成
                {
                    if(section < _finishArr.count)
                    {
                        NSArray * arr = [_finishArr[indexPath.section] objectForKey:@"taskList"];
                        
                        if(arr.count)
                        {
                            if(indexPath.row < arr.count)
                            {
                                Mission *mis = arr[indexPath.row];
                                
                                UILabel * titleLbl = [[UILabel alloc] initWithFrame:CGRectMake(14, 0, SCREENWIDTH - 14 - 38 - 13 * 2, 16)];
                                titleLbl.text = [NSString stringWithFormat:@"%ld. %@",indexPath.row + 1, mis.title];
                                titleLbl.height = [UICommon getSizeFromString:titleLbl.text withSize:CGSizeMake(SCREENWIDTH - 14 - 38 - 13 * 2, 70) withFont:Font(14)].height;
                                
                                if(titleLbl.height > 70)
                                {
                                    titleLbl.height = 70;
                                }
                                titleLbl.backgroundColor = [UIColor clearColor];
                                titleLbl.textColor = [UIColor whiteColor];
                                titleLbl.numberOfLines = 3;
                                titleLbl.font = Font(14);
                                [cell.contentView addSubview:titleLbl];
                                
                                UIImageView * icon = [[UIImageView alloc]initWithFrame:CGRectMake(SCREENWIDTH - 14 - 10 - 13 * 2, 4, 10, 10)];
                                icon.image = [UIImage imageNamed:@"icon_jiantou_3"];
                                [cell.contentView addSubview:icon];
                                
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
                                
                                UILabel * statusLbl = [[UILabel alloc] initWithFrame:CGRectMake(30, titleLbl.bottom + 7, 54, 24)];
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
                                    UIView * statusView = [[UIView alloc] initWithFrame:CGRectMake(30, titleLbl.bottom + 7, 54, 24)];
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
                                
                                cell.contentView.backgroundColor = [UIColor backgroundColor];
                                
                                return cell;
                            }
                        }
                    }
                    else//已完成为空->写上“无”
                    {
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
                    }
                }
                
                return cell;
            }
            else
            {
                if(indexPath.section < _rows.count)
                {
                    
                    NSArray * arr = [_rows[indexPath.section] objectForKey:@"taskList"];
                    
                    if(arr.count)
                    {
                        if(indexPath.row < arr.count)
                        {
                            Mission *mis = arr[indexPath.row];
                            
                            UILabel * titleLbl = [[UILabel alloc] initWithFrame:CGRectMake(14, 0, SCREENWIDTH - 14 - 38 - 13 * 2, 16)];
                            titleLbl.text = [NSString stringWithFormat:@"%ld. %@",indexPath.row + 1, mis.title];
                            titleLbl.height = [UICommon getSizeFromString:titleLbl.text withSize:CGSizeMake(SCREENWIDTH - 14 - 38 - 13 * 2, 70) withFont:Font(14)].height;
                            
                            if(titleLbl.height > 70)
                            {
                                titleLbl.height = 70;
                            }
                            titleLbl.backgroundColor = [UIColor clearColor];
                            titleLbl.textColor = [UIColor whiteColor];
                            titleLbl.numberOfLines = 3;
                            titleLbl.font = Font(14);
                            [cell.contentView addSubview:titleLbl];
                            
                            UIImageView * icon = [[UIImageView alloc]initWithFrame:CGRectMake(SCREENWIDTH - 14 - 10 - 13 * 2, 4, 10, 10)];
                            icon.image = [UIImage imageNamed:@"icon_jiantou_3"];
                            [cell.contentView addSubview:icon];
                            
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
                            
                            UILabel * statusLbl = [[UILabel alloc] initWithFrame:CGRectMake(30, titleLbl.bottom + 7, 54, 24)];
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
                                UIView * statusView = [[UIView alloc] initWithFrame:CGRectMake(30, titleLbl.bottom + 7, 54, 24)];
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
                            
                            cell.contentView.backgroundColor = [UIColor backgroundColor];
                            
                            return cell;
                        }
                        else if (indexPath.row == arr.count)
                        {
                            static NSString *cellId = @"Cell";
                            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
                            if (cell == nil){
                                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
                                cell.frame = CGRectMake(0, 0, SCREENWIDTH - 13 * 2, 84);
                            }
                            
                            for(UIView *view in cell.contentView.subviews) {
                                [view removeFromSuperview];
                            }
                            
                            cell.selectionStyle = UITableViewCellSelectionStyleNone;
                            
                            UILabel * titleLbl = [[UILabel alloc] initWithFrame:CGRectMake(35, 0, 200, 20)];
                            titleLbl.backgroundColor = [UIColor clearColor];
                            titleLbl.textColor = [UIColor blueTextColor];
                            titleLbl.font = Font(17);
                            titleLbl.text = @"工作总结";
                            
                            UIImageView * icon = [[UIImageView alloc] initWithFrame:CGRectMake(14, 2, 15, 15)];
                            icon.image = [UIImage imageNamed:@"icon_gongzuozongjie"];
                            [cell.contentView addSubview:icon];
                            
                            [cell.contentView addSubview:titleLbl];
                            cell.backgroundColor = [UIColor backgroundColor];
                            
                            return cell;
                        }
                    }
                }
            }

        }
    }
    
    return nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(tableView == _tableView)
    {
        if(indexPath.row == 0 && indexPath.section == 0)
        {
            return;
        }
        if (_navBarLeftButtonPopTipView.hasShadow) {
            [_navBarLeftButtonPopTipView dismissAnimated:YES];
        }
        
        _oriIndexRow = 0;
        
        if (indexPath.row < 1) {
            //NSIndexPath* buttomIndexPath = [NSIndexPath indexPathForRow:_replyList.count-1 inSection:0];
            
            
            //        NSIndexPath* buttomIndexPath = [NSIndexPath indexPathForRow:1 inSection:0];
            //        [_inputBar.textField becomeFirstResponder];
            //        [_tableView scrollToRowAtIndexPath:buttomIndexPath atScrollPosition:UITableViewScrollPositionBottom animated:YES];
            //
            //        _indexRow = 1099;
        }
        else
        {
            NSInteger index = indexPath.row;
            
            NSInteger cIndex = index - 1;
            
            Comment* comm = [_commentArray objectAtIndex:cIndex];
            
            _inputBar.textField.placeHolderLabel.width = 200;
            _inputBar.textField.placeHolderLabel.text = [NSString stringWithFormat:@"回复 %@", comm.userName];
            
            _indexRow = indexPath.row;
            BOOL hasLoad = NO;
            NSString* key = [NSString stringWithFormat:@"ReIndex%d",(int)(_indexRow - 1)];
            id obj = [_reReplyDic valueForKey:key];
            
            //        NSInteger cIndex = _indexRow - 1;
            //        Comment* comm = [_commentArray objectAtIndex:cIndex];
            //        [textf setPlaceholder:[NSString stringWithFormat:@"回复:%@",comm.userName]];
            
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
    }
    else
    {
        if(_isZJ)
        {
            NSInteger section = indexPath.section;
            
            Mission * ms;
            
            if(section >= _finishArr.count&& section != 0)//未完成
            {
                NSInteger index = section - _finishArr.count;
                
                if(!_finishArr.count)
                {
                    index = section - 1;
                }
                
                if(index <= _unfinishArr.count - 1)
                {
                    NSArray * arr = [_unfinishArr[index] objectForKey:@"taskList"];
                    
                    ms = arr[index];
                    
                }
            }
            else if(section >= 0)//已完成
            {
                if(section < _finishArr.count)
                {
                    NSArray * arr = [_finishArr[section] objectForKey:@"taskList"];
                    
                    ms = arr[indexPath.row];
                }
            }
            
            if(ms)
            {
                UIStoryboard* mainStory = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
                UIViewController* vc = [mainStory instantiateViewControllerWithIdentifier:@"ICWorkingDetailViewController"];
                ((ICWorkingDetailViewController*)vc).taskId = ms.taskId;
                ((ICWorkingDetailViewController*)vc).workGroupId = _workGroupId;
                
                [self.navigationController pushViewController:vc animated:YES];
            }

        }
        else
        {
            NSArray * arr = [_rows[indexPath.section] objectForKey:@"taskList"];
            
            if(indexPath.section == _rows.count - 1 && indexPath.row == arr.count)
            {//工作总结
                self.isZJ = YES;
                
                self.navigationItem.title = @"工作总结详情";

                
                [_tableView reloadData];
            }
            else
            {
                NSArray * arr = [_rows[indexPath.section] objectForKey:@"taskList"];
                
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

    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma -
#pragma mark Input Bar Action
-(void)inputBar:(YFInputBar *)inputBar sendBtnPress:(UIButton *)sendBtn withInputString:(NSString *)str
{
    if(inputBar.tag > 0)
    {
        _sendButtonTag = sendBtn.tag;
    }
    
    NSLog(@"Type:%ld",(long)_sendButtonTag);
    
    if (str == nil || [str isEqualToString:@""]) {
        return;
    }
    
    if (_indexRow == 1099) {
        
        Comment* cm = [Comment new];
        cm.main = str;
        cm.parentId = @"0";
        cm.level = _sendButtonTag == 100 ? 1 : 2;
        cm.userName = [LoginUser loginUserName];
        cm.userImg = [LoginUser loginUserPhoto];
        cm.userId = [LoginUser loginUserID];
        cm.taskId = _taskId;
        
        [SVProgressHUD showWithStatus:@"发送评论中..."];
        dispatch_async(dispatch_get_main_queue(), ^{
            BOOL isChild = NO;
            if (_oriIndexRow > 0) {
                
                Comment* pc = ((Comment*)[_commentArray objectAtIndex:(_oriIndexRow - 1)]);
                pc.commentsId = @"0";
                
                NSString* newCommentId = @"";
                BOOL isOk = [pc sendComment:&newCommentId];
                
                if (isOk) {
                    
                    [SVProgressHUD dismiss];
                    _inputBar.textField.text = @"";
                    _inputBar.textField.placeHolderLabel.text = @"点击回复";
                    _sendButtonTag = 0;
                    _inputBar.pishiClicked = NO;
                    
                    _commentsId = [NSString stringWithFormat:@"%@", newCommentId];
                    [self reloadTableView];
                    
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
                [SVProgressHUD dismiss];
                _inputBar.textField.text = @"";
                _inputBar.textField.placeHolderLabel.text = @"点击回复";
                _sendButtonTag = 0;
                _inputBar.pishiClicked = NO;
                
                _commentsId = [NSString stringWithFormat:@"%@", newCommentId];
                [self reloadTableView];
                
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
        if (_indexRow > 0) {
            NSString * pid = ((Comment*)[_commentArray objectAtIndex:(_indexRow - 1)]).commentsId;
            Comment* cm = [Comment new];
            cm.main = str;
            cm.parentId = pid==nil?@"0":pid;
            cm.level = _sendButtonTag == 100 ? 1 : 2;
            cm.userName = [LoginUser loginUserName];
            cm.userImg = [LoginUser loginUserPhoto];
            cm.userId = [LoginUser loginUserID];
            cm.taskId = _taskId;
            
            [SVProgressHUD showWithStatus:@"发送评论中..."];
            
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
                        [SVProgressHUD dismiss];
                        
                        _inputBar.textField.text = @"";
                        _inputBar.textField.placeHolderLabel.text = @"点击回复";
                        _sendButtonTag = 0;
                        _inputBar.pishiClicked = NO;
                        
                        _commentsId = [NSString stringWithFormat:@"%@", newCommentId];
                        [self reloadTableView];
                        
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
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    if ([self.icMainViewController respondsToSelector:@selector(setIsRefreshBottom:)]) {
        [self.icMainViewController setValue:@"1" forKey:@"isRefreshBottom"];
    }
    
    if ([self.icMainViewController respondsToSelector:@selector(setIsSetting:)]) {
        [self.icMainViewController setValue:@"1" forKey:@"isSetting"];
    }
    
    if ([self.icDetaiVC respondsToSelector:@selector(setContent:)]) {
        [self.icDetaiVC setValue:@"1" forKey:@"content"];
    }
    
    if (_currentMission && !_isDeleteMission) {
        
        Mission * ms = _contentArr[_indexInMainArray];
        
        _currentMission.isRead = YES;
        _currentMission.isNewCom = NO;
        _currentMission.monthAndDay = ms.monthAndDay;
        _currentMission.hour = ms.hour;
        _currentMission.accessoryNum = (int)_currentMission.accessoryList.count;
        _currentMission.replayNum = (int)_commentArray.count;
        _currentMission.childNum = (int)ms.childTaskList.count;
       
        NSMutableArray * childTaskArr = [NSMutableArray array];
        for (NSDictionary * dic in _currentMission.labelList)
        {
            NSArray * arr = [dic objectForKey:@"taskList"];
            
            for(Mission * mis in arr)
            {
                NSMutableDictionary * mdic = [NSMutableDictionary dictionary];
                [mdic setObject:mis.title forKey:@"title"];
                [mdic setObject:mis.taskId forKey:@"taskId"];
                if(mis.parentId.length)
                {
                    [mdic setObject:mis.parentId forKey:@"parentId"];
                }
                [mdic setObject:mis.lableUserName forKey:@"lableUserName"];
                if(mis.lableUserImg.length)
                {
                    [mdic setObject:mis.lableUserImg forKey:@"lableUserImg"];
                }
                [mdic setObject:mis.isRead ? @"1" : @"0" forKey:@"isRead"];
                [mdic setObject:mis.isNewCom ? @"1" : @"0" forKey:@"isCom"];
                
                [childTaskArr addObject:mdic];
            }
        }

        _currentMission.childTaskList = childTaskArr;
        
        [_contentArr replaceObjectAtIndex:_indexInMainArray withObject:_currentMission];
        
        if ([self.icMainViewController respondsToSelector:@selector(setContentArray:)]) {
            [self.icMainViewController setValue:_contentArr forKey:@"contentArray"];
        }
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

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    _inputBar.textField.placeHolderLabel.width = 200;
    _inputBar.textField.placeHolderLabel.text = @"点击回复";
    _indexRow = 1099;
    
    _inputBar.clearInputWhenSend = NO;
    
    if(_inputBar.btnTypeHasClicked)
    {
        [_inputBar removeType];
        _inputBar.btnTypeHasClicked = NO;
    }
    
    [self hiddenKeyboard];
}

- (void)sendComment
{
    if(_inputBar.textField.text.length)
    {
        [self inputBar:_inputBar sendBtnPress:_inputBar.sendBtn withInputString:_inputBar.textField.text];
        [_inputBar.textField resignFirstResponder];
    }
    else
    {
        [SVProgressHUD showErrorWithStatus:@"请输入内容"];
    }
}

- (void)hiddenKeyboard
{
    [_inputBar.textField resignFirstResponder];
    
    [_currentTextField resignFirstResponder];
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
            
            NSString * currentFileName = [NSString stringWithFormat:@"%@.png", dateTime];
            
            NSMutableDictionary * imageDic = [NSMutableDictionary dictionary];
            
            BOOL isOk = [LoginUser uploadImageWithScale:image fileName:currentFileName imageDic:&imageDic];
            
            if(isOk)
            {
                [SVProgressHUD dismiss];
                
                Accessory * acc = [Accessory new];
                acc.address = [imageDic valueForKey:@"path"];
                acc.name = [imageDic valueForKey:@"oldName"];
                acc.originImageSize = [imageDic valueForKey:@"size"];
                
                [self.cAccessoryArray addObject:acc];
                
                [self showAccessory];
                
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
        
        for(int i = 0; i < assets.count; i ++)
        {
            ALAsset * ass = assets[i];
            
            ALAssetRepresentation* representation = [ass defaultRepresentation];
            UIImage* portraitImg = [UIImage imageWithCGImage:[representation fullResolutionImage]];
            portraitImg = [UIImage
                           imageWithCGImage:[representation fullScreenImage]
                           scale:[representation scale]
                           orientation:UIImageOrientationUp];
            
            NSString * currentFileName = [representation filename];
            
            //            portraitImg = [UICommon imageByScalingToMaxSize:portraitImg];
            
            NSMutableDictionary * imageDic = [NSMutableDictionary dictionary];
            
            BOOL isOk = [LoginUser uploadImageWithScale:portraitImg fileName:currentFileName imageDic:&imageDic];
            
            if(isOk)
            {
                //                    NSMutableDictionary * dic = [[NSMutableDictionary alloc] init];
                //                    [dic setObject:userImgPath forKey:@"url"];
                
                Accessory * acc = [Accessory new];
                acc.address = [imageDic valueForKey:@"path"];
                acc.name = [imageDic valueForKey:@"oldName"];
                acc.originImageSize = [imageDic valueForKey:@"size"];
                
                [self.cAccessoryArray addObject:acc];
            }
            
            if(i == assets.count - 1)
            {
                if(isOk)
                {
                    [SVProgressHUD dismiss];
                    
                    [self showAccessory];
                }
                else
                {
                    [SVProgressHUD showErrorWithStatus:@"图片上传失败"];
                }
            }
        }
    }
}

@end
