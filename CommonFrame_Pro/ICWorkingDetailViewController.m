//
//  ICWorkingDetailViewController.m
//  CommonFrame_Pro
//
//  Created by ionitech on 15/6/16.
//  Copyright (c) 2015年 ionitech. All rights reserved.
//

#import "ICWorkingDetailViewController.h"
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

@interface ICWorkingDetailViewController() <UITableViewDataSource, UITableViewDelegate,YFInputBarDelegate,UITextViewDelegate,UINavigationControllerDelegate,UIImagePickerControllerDelegate,ZYQAssetPickerControllerDelegate,CMPopTipViewDelegate,UIAlertViewDelegate,UIGestureRecognizerDelegate,UIActionSheetDelegate, UIDocumentInteractionControllerDelegate,UICollectionViewDataSource, UICollectionViewDelegate, UIActionSheetDelegate>
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
    
    UICollectionView * _partCollView;
    
    UIImageView * _duiimageview;
    
    BOOL _isShowAllPart;
    NSArray * _partList;
    UIButton * _jianTouBtn;
    
    BOOL _isShowAllChildMission;
    NSArray * _childMissionList;
    
    UITableView * _childTableView;
    
    BOOL _isMainMission;
    
    NSInteger _sendButtonTag;
}

@property (strong, nonatomic) UIDocumentInteractionController *documentInteractionController;


- (IBAction)btnBackButtonClicked:(id)sender;
- (IBAction)btnCommentButtonClicked:(id)sender;


@end

@implementation ICWorkingDetailViewController

- (void)notiForJumpToMissionDetail:(NSNotification *)note {
        
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
            
//            _childTableView = [[UITableView alloc] init];
//            _childTableView.scrollEnabled = NO;
//            _childTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
//            _childTableView.backgroundColor = [UIColor clearColor];
//            _childTableView.dataSource = self;
//            _childTableView.delegate = self;
            
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
    
    _currentMission = [Mission detail:_taskId commentArray:&commentsArray imgArr:&imgArr messageId:_messageId];
    
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
        
        _currentMission = [Mission detail:_taskId commentArray:&commentsArray imgArr:&imgArr messageId:_messageId];
    }
    else
    {
        commentsArray = _commentsArr;
        imgArr = _imageArr;
    }
    
    if (_currentMission != nil) {
        
//        TaskTypeMission         = 1,//任务
//        TaskTypeShare           = 2,//异常
//        TaskTypeNoitification   = 8,//申请
//        TaskTypeJianYi          = 3//议题
        
        NSString * title = @"任务详情";
        if(_currentMission.type == TaskTypeShare)
        {
            title = @"异常详情";
        }
        else if (_currentMission.type == TaskTypeJianYi)
        {
            title = @"议题详情";
        }
        else if (_currentMission.type == TaskTypeNoitification)
        {
            title = @"申请详情";
        }
        else if (_currentMission.type == TaskTypeMission && _isChildMission)
        {
            title = @"子任务详情";
        }
        
        self.navigationItem.title = title;
        
        NSString * loginStr = [NSString stringWithFormat:@"%@", [LoginUser loginUserID]];
        
        if(_currentMission.createUserId == [LoginUser loginUserID] || [_currentMission.liableUserId isEqualToString:loginStr])
        {
            UIBarButtonItem* rightBarButton = [[UIBarButtonItem alloc] initWithTitle:@"更多操作" style:UIBarButtonItemStyleDone target:self action:@selector(btnRightMoreClicked:)];
            [rightBarButton setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor whiteColor],NSFontAttributeName:[UIFont systemFontOfSize:17]} forState:UIControlStateNormal];
            self.navigationItem.rightBarButtonItem = rightBarButton;
            
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
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(tableView == _childTableView)
    {
        return 40;
    }
    else
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
    if(tableView == _childTableView)
    {
        return _childMissionList.count;
    }
    else
    {
        return _replyList.count;
    }
}

- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(tableView == _childTableView)
    {
        return YES;
    }
    else
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


- (void) previewFile:(id)sender
{
    UIButton * btn = (UIButton *)sender;
    
    NSInteger index = btn.tag;
    
    NSArray* accArr = [NSArray arrayWithArray:_currentMission.accessoryList];
    
    Accessory * acc = accArr[index];
    
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

#pragma mark -
#pragma mark Document Interaction Controller Delegate Methods
- (UIViewController *) documentInteractionControllerViewControllerForPreview: (UIDocumentInteractionController *) controller {
    return self;
}

- (UIView*)documentInteractionControllerViewForPreview:(UIDocumentInteractionController*)controller

{
    return self.view;
}

- (CGRect)documentInteractionControllerRectForPreview:(UIDocumentInteractionController*)controller

{
    return self.view.frame;
}

- (void) seeFullScreenImg:(id)sender
{
    UIButton * btn = (UIButton *)sender;
    
    UIStoryboard* mainStory = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    UIViewController* vc = [mainStory instantiateViewControllerWithIdentifier:@"PreviewViewController"];
    if(_imageArray.count)
    {
        ((PreviewViewController*)vc).dataArray = _imageArray;
    }
    ((PreviewViewController*)vc).currentPage = btn.tag;
    
    [self.navigationController presentViewController:vc animated:YES completion:nil];
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

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(tableView == _childTableView)
    {
        static NSString *cellId = @"childMissCell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
        
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
        }
        
        for(UIView *view in cell.contentView.subviews) {
            [view removeFromSuperview];
        }
        
        NSDictionary * dic = _childMissionList[indexPath.row];
        
        UILabel * titleLbl = [[UILabel alloc] init];
        titleLbl.frame = CGRectMake(13, 0, SCREENWIDTH -  13 * 4 - 118, 40);
        titleLbl.backgroundColor = [UIColor clearColor];
        titleLbl.font = Font(14);
        titleLbl.textColor = [UIColor whiteColor];
        titleLbl.text = [dic valueForKey:@"lableUserName"];
        [cell.contentView addSubview:titleLbl];

        return cell;
    }
    else
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
            
            CGFloat contentWidth = cWidth - 26 * 2;
            UIFont* font = Font(14);
            
            CGFloat contentHeight = [UICommon getSizeFromString:titleStr withSize:CGSizeMake(contentWidth - 23, 1000) withFont:font].height;
            
            UILabel* title = [[UILabel alloc] initWithFrame:CGRectMake(26 + 23, YH(photo) + 18 + 10, contentWidth - 23, contentHeight)];
            [title setBackgroundColor:[UIColor clearColor]];
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
            
            //checkbox
            UIImageView * checkView = [[UIImageView alloc] init];
            checkView.frame = CGRectMake(26, Y(title) + 2, 16, 14);
            checkView.image = [UIImage imageNamed:@"btn_kuang"];
            if(_currentMission.status == 2)//完成
            {
                checkView.image = [UIImage imageNamed:@"btn_gou"];
                
                NSAttributedString *attrStr = [RRAttributedString setStrikeThroughText:titleStr font:font color:[UIColor whiteColor] range:NSMakeRange(0, titleStr.length)];
                
                title.attributedText = attrStr;
            }
            
            if(_currentMission.type == 1)
            {
                [cell.contentView addSubview:checkView];
            }
            else
            {
                title.left =  26;
            }
            
            //描述
            NSString* content = _currentMission.main;

            contentHeight = [UICommon getSizeFromString:content withSize:CGSizeMake(contentWidth, 1000) withFont:font].height;
            
            UILabel* desLbl = [[UILabel alloc] initWithFrame:CGRectMake(26, YH(title) + 16, contentWidth, contentHeight)];
            [desLbl setBackgroundColor:[UIColor clearColor]];
            [desLbl setBackgroundColor:[UIColor clearColor]];
            [desLbl setTextColor:RGBCOLOR(172, 172, 173)];
            [desLbl setFont:font];

            if(content.length)
            {
                [desLbl setNumberOfLines:0];
            }
            else
            {
                content = @"暂无描述";
            }
            [desLbl setText:content];

            [cell.contentView addSubview:desLbl];
            
            CGFloat duiImgWidth = SCREENWIDTH - 13 * 2;
            
            //文件
            BOOL hasAccessory = _currentMission.isAccessory;
            
            CGFloat accHeight = (duiImgWidth - 40) / 3;
            CGFloat intevalHeight = 8;
            
            NSArray* accArr = [NSArray arrayWithArray:_currentMission.accessoryList];
            
            CGFloat accY = 0;
            
            if (hasAccessory) {
                
                CGFloat attchHeight = ((accArr.count - 1) / 3 + 1) * (accHeight + intevalHeight);
                UIView* attchView = [[UIView alloc] init];
                
                CGFloat desY = YH(title) + 16;
                if(content.length)
                {
                    desY = YH(desLbl) + 23;
                }
                
                attchView.frame = CGRectMake(14, desY, duiImgWidth, attchHeight);
                
                [attchView setBackgroundColor:[UIColor clearColor]];
                
                for (int i = 0;i < accArr.count; i++)
                {
                    int j = i / 3;
                    
                    int k = i % 3;
                    
                    Accessory * acc = accArr[i];
                    
                    CGRect attaFrame = CGRectMake(12 + (accHeight + intevalHeight) * k, (accHeight + intevalHeight) * j, accHeight, accHeight);
                    
                    UIImageView* attachment = [[UIImageView alloc] initWithFrame:attaFrame];
                    // 1: doc/docx  2: xls/xlsx 3: ppt/pptx 4: pdf 5: png/jpg
                    int fileType = [acc.fileType intValue];
                    
                    attachment.userInteractionEnabled = YES;
                    
                    if(fileType == 5)//to do
                    {
                        [attachment setImageWithURL:[NSURL URLWithString:acc.address]
                                   placeholderImage:[UIImage imageNamed:@"bimg.jpg"]
                                            options:SDWebImageDelayPlaceholder
                        usingActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
                        
                        UIButton * imgBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, W(attachment), H(attachment))];
                        imgBtn.backgroundColor = [UIColor clearColor];
                        
                        NSInteger fileCount = accArr.count - _imageArray.count;
                        imgBtn.tag = fileCount > 0 ? i - fileCount : i;
                        
                        [imgBtn addTarget:self action:@selector(seeFullScreenImg:) forControlEvents:UIControlEventTouchUpInside];
                        [attachment addSubview:imgBtn];
                    }
                    else
                    {
                        NSString * imgName = @"";
                        if(fileType == 1)//to do
                        {
                            imgName = @"btn_word";
                            
                            attachment.backgroundColor = [UIColor wordBackColor];
                            
                        }
                        else if (fileType == 2)
                        {
                            imgName = @"btn_excel";
                            
                            attachment.backgroundColor = [UIColor excelBackColor];
                        }
                        else if (fileType == 3)
                        {
                            imgName = @"btn_ppt";
                            
                            attachment.backgroundColor = [UIColor pptBackColor];
                            
                        }
                        else if (fileType == 4)
                        {
                            imgName = @"btn_pdf";
                            
                            attachment.backgroundColor = [UIColor pdfBackColor];
                            
                        }
                        else if(fileType == 6)
                        {
                            imgName = @"btn_other";
                            
                            attachment.backgroundColor = [UIColor qitaBackColor];
                        }
                        
                        UIImageView * fileIcon = [[UIImageView alloc] init];
                        fileIcon.image = [UIImage imageNamed:imgName];
                        [attachment addSubview:fileIcon];
                        
                        UIButton * imgBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, W(attachment), H(attachment))];
                        imgBtn.backgroundColor = [UIColor clearColor];
                        imgBtn.tag = i;
                        //                    imgBtn.tag = fileType;//文件类型
                        [imgBtn addTarget:self action:@selector(previewFile:) forControlEvents:UIControlEventTouchUpInside];
                        [attachment addSubview:imgBtn];
                        
                        UILabel * fileNameLbl = [[UILabel alloc] init];
                        
                        if(SCREENWIDTH == 414)
                        {
                            fileIcon.frame = CGRectMake((accHeight - 37) / 2, 14, 37, 59);
                            
                            fileNameLbl.frame = CGRectMake(14, YH(fileIcon) + 11, (accHeight - 14 * 2) , 24);
                            
                            fileNameLbl.font = Font(10);
                            
                        }
                        else if (SCREENWIDTH == 375)
                        {
                            fileIcon.frame = CGRectMake((accHeight - 37) / 2, 13, 33, 54);
                            
                            fileNameLbl.frame = CGRectMake(14, YH(fileIcon) + 8, (accHeight - 14 * 2) , 22);
                            
                            fileNameLbl.font = Font(9);
                            
                        }
                        else if (SCREENWIDTH == 320)
                        {
                            fileIcon.frame = CGRectMake((accHeight - 31) / 2, 11, 28, 46);
                            
                            fileNameLbl.frame = CGRectMake(11, YH(fileIcon) + 5, (accHeight - 11 * 2) , 20);
                            
                            fileNameLbl.font = Font(8);
                            
                        }
                        
                        fileNameLbl.backgroundColor = [UIColor clearColor];
                        fileNameLbl.textColor = [UIColor whiteColor];
                        fileNameLbl.numberOfLines = 2;
                        fileNameLbl.text = acc.name;
                        
                        [attachment addSubview:fileNameLbl];
                    }
                    
                    
                    [attachment.layer setMasksToBounds:YES];
                    
                    [attchView addSubview:attachment];
                    
                }
                
                [cell.contentView addSubview:attchView];
                
                accY = YH(attchView) - intevalHeight;

            }
            else
            {
                accY = content.length ? YH(desLbl) + 23 : YH(title) + 16;
            }
            //日期
            
            UIView * bFirstView = [[UIView alloc] init];
            [bFirstView setBackgroundColor:[UIColor clearColor]];
            
            bFirstView.frame = CGRectMake(14, accY, duiImgWidth, 166);
            
            //        UIView* bFirstView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, duiImgWidth, 166)];
            //        [bFirstView setBackgroundColor:[UIColor clearColor]];
            //
            //        [bView addSubview:bFirstView];
            
            UIImageView * groupIcon = [[UIImageView alloc] initWithFrame:CGRectMake(13, 14, 13, 15)];
            groupIcon.image = [UIImage imageNamed:@"icon_qunzu_1"];
            [bFirstView addSubview:groupIcon];
            
            //        groupIcon = [[UIImageView alloc] initWithFrame:CGRectMake(13, 14, 14, 17)];
            //        groupIcon.image = [UIImage imageNamed:@"icon_canyuren"];
            //        [bView addSubview:groupIcon];
            
            
            UILabel* groupName = [[UILabel alloc] initWithFrame:CGRectMake(32, 14, 200, 14)];
            [groupName setBackgroundColor:[UIColor clearColor]];
            [groupName setText:_currentMission.workGroupName];
            [groupName setTextColor:[UIColor grayTitleColor]];
            [groupName setFont:Font(12)];
            [bFirstView addSubview:groupName];
            
            groupIcon = [[UIImageView alloc] initWithFrame:CGRectMake(13, YH(groupName) + 14, 13, 15)];
            groupIcon.image = [UIImage imageNamed:@"icon_biaoqian_2"];
            [bFirstView addSubview:groupIcon];
            
            //标签
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
            
            CGSize maxSize = CGSizeMake(duiImgWidth - X(groupName), 1000);
            
            tagLbl = [[UILabel alloc] init];
            tagLbl.frame = CGRectMake(X(groupName), YH(groupName) + 12, maxSize.width, maxSize.height);
            tagLbl.backgroundColor = [UIColor clearColor];
            tagLbl.font = Font(12);
            tagLbl.textColor = [UIColor grayTitleColor];
            tagLbl.numberOfLines = 0;
            tagLbl.text = tagStr;
            
            CGSize bSize = [UICommon getSizeFromString:tagStr withSize:maxSize withFont:Font(12)];
            tagLbl.height = bSize.height;
            [bFirstView addSubview:tagLbl];
            
            CGFloat newcHeight;
            CGFloat duiImgHeight;
            
            if(_currentMission.type == 1)//任务
            {
                //虚线
                DashesLineView * dashLine = [[DashesLineView alloc] init];
                dashLine.frame = CGRectMake(0, YH(tagLbl) + 14, duiImgWidth, 0.5);
                dashLine.backgroundColor = [UIColor clearColor];
                [bFirstView addSubview:dashLine];
                
                DashesLineView * dashLine2 = [[DashesLineView alloc] init];
                dashLine2.frame = CGRectMake(0, Y(dashLine) + 64 + 40, duiImgWidth, 0.5);
                dashLine2.backgroundColor = [UIColor clearColor];
                [bFirstView addSubview:dashLine2];
                
                //负责人
                UIImageView * fzIcon = [[UIImageView alloc] init];
                fzIcon.frame = CGRectMake(13, Y(dashLine) + 14, 13, 15);
                fzIcon.image = [UIImage imageNamed:@"icon_fuzeren_1"];
                [bFirstView addSubview:fzIcon];
                
                title = [[UILabel alloc] initWithFrame:CGRectMake(X(groupName), Y(dashLine) + 14, duiImgWidth - X(groupName) * 2, 16)];
                [title setBackgroundColor:[UIColor clearColor]];
                [title setTextColor:[UIColor whiteColor]];
                [title setFont:Font(14)];
                NSString * responText = [NSString stringWithFormat:@"负责人：%@", _currentMission.lableUserName];
                NSAttributedString *attrStr = [RRAttributedString setText:responText color:[UIColor grayTitleColor] range:NSMakeRange(0, 4)];
                title.attributedText = attrStr;
                [bFirstView addSubview:title];
                
                //截止时间
                
                fzIcon = [[UIImageView alloc] init];
                fzIcon.frame = CGRectMake(11, YH(title) + 13, 16, 16);
                fzIcon.image = [UIImage imageNamed:@"icon_jiezhishijian"];
                [bFirstView addSubview:fzIcon];
                
                title = [[UILabel alloc] initWithFrame:CGRectMake(X(groupName), Y(fzIcon), SCREENWIDTH - 26 * 2, 16)];
                [title setBackgroundColor:[UIColor clearColor]];
                [title setTextColor:[UIColor grayTitleColor]];
                [title setFont:Font(14)];
                
                NSString * finishTime = [UICommon dayAndHourFromString:_currentMission.finishTime formatStyle:@"yyyy年MM月dd日"];
                
                //-3:已超时  -2删除   -1停用   0：未开始 1进行中   2：已完成
                NSString *statusStr = @"不知";
                switch (_currentMission.status) {
                    case 0:
                        statusStr = @"未开始";
                        break;
                    case 1:
                        statusStr = @"进行中";
                        break;
                    case 2:
                        statusStr = @"已完成";
                        break;
                    case -3:
                        statusStr = @"已超时";
                        break;
                    default:
                        break;
                }
                
                responText = [NSString stringWithFormat:@"截止时间：%@", finishTime];
                
                if(finishTime.length)
                {
                    attrStr = [RRAttributedString setText:responText color:[UIColor whiteColor] range:NSMakeRange(5, 11)];
                    title.attributedText = attrStr;
                }
                else
                {
                    title.text = responText;
                }
                
                [bFirstView addSubview:title];
                
                fzIcon = [[UIImageView alloc] init];
                fzIcon.frame = CGRectMake(13, YH(title) + 13, 13, 15);
                fzIcon.image = [UIImage imageNamed:@"icon_renwuzhuangtai"];
                [bFirstView addSubview:fzIcon];
                
                responText = [NSString stringWithFormat:@"任务状态：%@", statusStr];
                
                UILabel * statusLbl = [[UILabel alloc] init];
                statusLbl.frame = CGRectMake(X(groupName), Y(fzIcon), 200, 16);
                statusLbl.backgroundColor = [UIColor clearColor];
                statusLbl.textColor = [UIColor grayTitleColor];
                statusLbl.text = responText;
                statusLbl.font = Font(14);
                [bFirstView addSubview:statusLbl];
                
                //参与人
                fzIcon = [[UIImageView alloc] init];
                fzIcon.frame = CGRectMake(13, Y(dashLine2) + 14, 13, 15);
                fzIcon.image = [UIImage imageNamed:@"icon_canyuren_1"];
                [bFirstView addSubview:fzIcon];
                
                title = [[UILabel alloc] initWithFrame:CGRectMake(X(groupName), Y(fzIcon) - 2, duiImgWidth - X(groupName) * 2, 16)];
                [title setBackgroundColor:[UIColor clearColor]];
                [title setTextColor:[UIColor grayTitleColor]];
                [title setFont:Font(14)];
                
                _partList=  _currentMission.partList;
                responText = [NSString stringWithFormat:@"可见范围 (%lu)", (unsigned long)_partList.count];
                title.text = responText;
                [bFirstView addSubview:title];
                
                if(_partList.count)
                {
                    DashesLineView * dashLine3 = [[DashesLineView alloc] init];
                    dashLine3.frame = CGRectMake(0, Y(dashLine2) + 40, duiImgWidth, 0.5);
                    dashLine3.backgroundColor = [UIColor clearColor];
                    [bFirstView addSubview:dashLine3];
                    
                    bFirstView.height = 166 + 95;
                    
                    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
                    
                    layout.minimumInteritemSpacing = 12.f;
                    layout.minimumLineSpacing = 0;
                    UIEdgeInsets insets = {.top = 14,.left = 13,.bottom = 14,.right = 13};
                    layout.sectionInset = insets;
                    
                    _partCollView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, Y(dashLine3), duiImgWidth, 95) collectionViewLayout:layout];
                    _partCollView.delegate = self;
                    _partCollView.dataSource = self;
                    _partCollView.scrollEnabled = NO;
                    _partCollView.backgroundColor = [UIColor clearColor];
                    
                    [_partCollView registerClass:[PartiCell class] forCellWithReuseIdentifier:@"PartiCell"];
                    
                    _partCollView.frame = CGRectMake(0, Y(dashLine3), duiImgWidth, 95);
                    
                    [bFirstView addSubview:_partCollView];
                    
                    UIButton * moreBtn = [[UIButton alloc] init];
                    moreBtn.frame = CGRectMake(duiImgWidth - 50, Y(dashLine2), 50, 40);
                    moreBtn.backgroundColor = [UIColor clearColor];
                    [moreBtn setTitleColor:[UIColor blueTextColor] forState:UIControlStateNormal];
                    [moreBtn addTarget:self action:@selector(clickMorePart:) forControlEvents:UIControlEventTouchUpInside];
                    moreBtn.titleLabel.font = Font(12);
                    [bFirstView addSubview:moreBtn];
                    
                    int lineCount = 4;
                    
                    if(SCREENWIDTH == 375)
                    {
                        lineCount = 5;
                    }
                    else if(SCREENWIDTH == 414)
                    {
                        lineCount = 6;
                    }
                    
                    if(_partList.count > lineCount && !_isShowAllPart)
                    {
                        [moreBtn setTitle:@"更多" forState:UIControlStateNormal];
                        
                        _partCollView.height = 14 + 50 + 30;
                        
                        bFirstView.height = 166 + _partCollView.height + 40;
                    }
                    else if(_partList.count > lineCount && _isShowAllPart)
                    {
                        [moreBtn setTitle:@"收起" forState:UIControlStateNormal];
                        
                        NSInteger count = _partList.count;
                        
                        NSInteger row = 1;
                        
                        row = (count % lineCount) ? count / lineCount + 1: count / lineCount;
                        
                        float height = 14 + row * (50 + 30);
                        
                        _partCollView.height = height;
                        
                        bFirstView.height = 166 + height + 40;
                        
                    }
                    else
                    {
                        moreBtn.hidden = YES;
                        bFirstView.height = 166 + _partCollView.height + 40;
                    }
                }
                else
                {
                    bFirstView.height = 166 + 40;
                }
                
                //子任务
                UIView * bSecondView = [[UIView alloc] init];
                bSecondView.frame = CGRectMake(14, YH(_duiimageview) + 14, duiImgWidth, 40);
                bSecondView.backgroundColor = [UIColor clearColor];
                [bSecondView setRoundColorCorner:8 withColor:[UIColor grayLineColor]];
                
                _isMainMission = [_currentMission.parentId isEqualToString:@"0"];//为0 主任务
                
                if(_isMainMission)//是主任务
                {
                    [cell.contentView addSubview:bSecondView];
                }
                
                
                fzIcon = [[UIImageView alloc] init];
                fzIcon.frame = CGRectMake(13, 13, 13, 15);
                fzIcon.image = [UIImage imageNamed:@"icon_zirenwu"];
                [bSecondView addSubview:fzIcon];
                
                title = [[UILabel alloc] initWithFrame:CGRectMake(X(groupName), Y(fzIcon) - 2, duiImgWidth - X(groupName) * 2, 16)];
                [title setBackgroundColor:[UIColor clearColor]];
                [title setTextColor:[UIColor grayTitleColor]];
                [title setFont:Font(14)];
                
                _childMissionList =  _currentMission.childTaskList;
                responText = [NSString stringWithFormat:@"子任务 (%lu)", (unsigned long)_childMissionList.count];
                title.text = responText;
                [bSecondView addSubview:title];
                
                _jianTouBtn = [[UIButton alloc] init];
                _jianTouBtn.backgroundColor = [UIColor clearColor];
                _jianTouBtn.frame = CGRectMake(duiImgWidth - 32 - 4, 0, 32, 40);
                [_jianTouBtn addTarget:self action:@selector(clickJianTou:) forControlEvents:UIControlEventTouchUpInside];
                
                [bSecondView addSubview:_jianTouBtn];
                
                if(_childMissionList.count)
                {
                    DashesLineView * dashLine4 = [[DashesLineView alloc] init];
                    dashLine4.frame = CGRectMake(0, 40 - 0.5, duiImgWidth, 0.5);
                    dashLine4.backgroundColor = [UIColor clearColor];
                    [bSecondView addSubview:dashLine4];
                    
                    //                _childTableView.frame = CGRectMake(0, Y(dashLine4), duiImgWidth, _childMissionList.count * 40);
                    
                    if(_childMissionList.count && !_isShowAllChildMission)
                    {
                        dashLine4.hidden = YES;
                        
                        [_jianTouBtn setImage:[UIImage imageNamed:@"btn_jiantou_1"] forState:UIControlStateNormal];
                        
                    }
                    else if(_childMissionList.count && _isShowAllChildMission)
                    {
                        //                    bSecondView.height = 40 + H(_childTableView);
                        //
                        //                    [bSecondView addSubview:_childTableView];
                        
                        dashLine4.hidden = NO;
                        
                        bSecondView.height = 40 + _childMissionList.count * 34 + 20;
                        
                        [_jianTouBtn setImage:[UIImage imageNamed:@"btn_jiantou_2"] forState:UIControlStateNormal];
                        
                        for (int i = 0; i < _childMissionList.count; i ++)
                        {
                            NSDictionary * dic = _childMissionList[i];
                            
                            UIButton * cellBtn = [[UIButton alloc] init];
                            cellBtn.frame = CGRectMake(0, Y(dashLine4) + 34 * i + 10, duiImgWidth, 34);
                            cellBtn.backgroundColor = [UIColor clearColor];
                            [cellBtn addTarget:self action:@selector(jumpToMissionDetailView:) forControlEvents:UIControlEventTouchUpInside];
                            cellBtn.tag = i + 100;
                            [bSecondView addSubview:cellBtn];
                            
                            UILabel * titleLbl = [[UILabel alloc] init];
                            titleLbl.frame = CGRectMake(13, Y(cellBtn), duiImgWidth -  13 * 2 - 118, 34);
                            titleLbl.backgroundColor = [UIColor clearColor];
                            titleLbl.font = Font(14);
                            titleLbl.textColor = [UIColor whiteColor];
                            titleLbl.text = [NSString stringWithFormat:@"%d. %@",i + 1, [dic valueForKey:@"title"]];
                            [bSecondView addSubview:titleLbl];
                            
                            titleLbl = [[UILabel alloc] init];
                            titleLbl.frame = CGRectMake(duiImgWidth - 70, Y(cellBtn), 50, 34);
                            titleLbl.backgroundColor = [UIColor clearColor];
                            titleLbl.font = Font(14);
                            titleLbl.textColor = [UIColor grayTitleColor];
                            titleLbl.text = [dic valueForKey:@"lableUserName"];
                            [bSecondView addSubview:titleLbl];
                            
                            UIImageView * jiantou = [[UIImageView alloc] init];
                            jiantou.frame = CGRectMake(duiImgWidth - 13 - 12, Y(cellBtn) + 11, 12, 12);
                            jiantou.image = [UIImage imageNamed:@"btn_jiantou_1"];
                            [bSecondView addSubview:jiantou];
                        }
                    }
                    else
                    {
                        dashLine4.hidden = YES;
                        
                        _jianTouBtn.hidden = YES;
                    }
                }
                else
                {
                    bSecondView.height = 40;
                }
                
                newcHeight = YH(bSecondView) + 34;
                
                if(!_isMainMission)//子任务
                {
                    newcHeight = YH(_duiimageview) + 34;
                }
                
                duiImgHeight = YH(bFirstView) + 14 - 78 - 14 + H(tagLbl);

            }
            else//问题、建议、其它
            {
                //参与人
                
                //虚线
                DashesLineView * dashLine = [[DashesLineView alloc] init];
                dashLine.frame = CGRectMake(0, YH(tagLbl) + 14, duiImgWidth, 0.5);
                dashLine.backgroundColor = [UIColor clearColor];
                [bFirstView addSubview:dashLine];
                
                DashesLineView * dashLine2 = [[DashesLineView alloc] init];
                dashLine2.frame = CGRectMake(0, Y(dashLine) + 40, duiImgWidth, 0.5);
                dashLine2.backgroundColor = [UIColor clearColor];
                [bFirstView addSubview:dashLine2];
                
                UIImageView * fzIcon = [[UIImageView alloc] init];
                fzIcon.frame = CGRectMake(13, Y(dashLine) + 14, 13, 15);
                fzIcon.image = [UIImage imageNamed:@"icon_canyuren_1"];
                [bFirstView addSubview:fzIcon];
                
                title = [[UILabel alloc] initWithFrame:CGRectMake(X(groupName), Y(fzIcon) - 2, duiImgWidth - X(groupName) * 2, 16)];
                [title setBackgroundColor:[UIColor clearColor]];
                [title setTextColor:[UIColor grayTitleColor]];
                [title setFont:Font(14)];
                
                _partList=  _currentMission.partList;
                NSString *responText = [NSString stringWithFormat:@"可见范围 (%lu)", (unsigned long)_partList.count];
                title.text = responText;
                [bFirstView addSubview:title];
                
                if(_partList.count)
                {
                    bFirstView.height = 100 + 95;
                    
                    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
                    
                    layout.minimumInteritemSpacing = 12.f;
                    layout.minimumLineSpacing = 0;
                    UIEdgeInsets insets = {.top = 14,.left = 13,.bottom = 14,.right = 13};
                    layout.sectionInset = insets;
                    
                    _partCollView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, Y(dashLine2), duiImgWidth, 95) collectionViewLayout:layout];
                    _partCollView.delegate = self;
                    _partCollView.dataSource = self;
                    _partCollView.scrollEnabled = NO;
                    _partCollView.backgroundColor = [UIColor clearColor];
                    
                    [_partCollView registerClass:[PartiCell class] forCellWithReuseIdentifier:@"PartiCell"];
                    
                    _partCollView.frame = CGRectMake(0, Y(dashLine2), duiImgWidth, 95);
                    
                    [bFirstView addSubview:_partCollView];
                    
                    UIButton * moreBtn = [[UIButton alloc] init];
                    moreBtn.frame = CGRectMake(duiImgWidth - 50, Y(dashLine), 50, 40);
                    moreBtn.backgroundColor = [UIColor clearColor];
                    [moreBtn setTitleColor:[UIColor blueTextColor] forState:UIControlStateNormal];
                    [moreBtn addTarget:self action:@selector(clickMorePart:) forControlEvents:UIControlEventTouchUpInside];
                    moreBtn.titleLabel.font = Font(12);
                    [bFirstView addSubview:moreBtn];
                    
                    int lineCount = 4;
                    
                    if(SCREENWIDTH == 375)
                    {
                        lineCount = 5;
                    }
                    else if(SCREENWIDTH == 414)
                    {
                        lineCount = 6;
                    }
                    
                    if(_partList.count > lineCount && !_isShowAllPart)
                    {
                        [moreBtn setTitle:@"更多" forState:UIControlStateNormal];
                        
                        _partCollView.height = 14 + 50 + 30;
                        
                        bFirstView.height = 100 + _partCollView.height;
                    }
                    else if(_partList.count > lineCount && _isShowAllPart)
                    {
                        [moreBtn setTitle:@"收起" forState:UIControlStateNormal];
                        
                        NSInteger count = _partList.count;
                        
                        NSInteger row = 1;
                        
                        row = (count % lineCount) ? count / lineCount + 1: count / lineCount;

                        float height = 14 + row * (50 + 30);
                        
                        _partCollView.height = height;
                        
                        bFirstView.height = 100 + height;
                        
                    }
                    else
                    {
                        moreBtn.hidden = YES;
                    }
                }
                else
                {
                    bFirstView.height = 100;
                }
                
                duiImgHeight = YH(bFirstView) + 14 - 78 - 14 + H(tagLbl);

                newcHeight = YH(_duiimageview) + 34;
            }

            /*
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
             */
            
            //对话框
            _duiimageview = [[UIImageView alloc] init];
            _duiimageview.image= [[UIImage imageNamed:@"bg_duihuakuang2"] stretchableImageWithLeftCapWidth:40 topCapHeight:30];
            
            _duiimageview.frame = CGRectMake(14, YH(photo) + 7, duiImgWidth, duiImgHeight );
            
            [cell.contentView addSubview:_duiimageview];
            [cell.contentView sendSubviewToBack:_duiimageview];
            
            
            //评论
            UIButton* btnComment = [[UIButton alloc] initWithFrame:CGRectMake(duiImgWidth - 50, 14, 50, 26)];
            [btnComment setBackgroundColor:[UIColor clearColor]];
            [btnComment addTarget:self action:@selector(btnCommentButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
            [bFirstView addSubview:btnComment];
            
            UIImageView * commIcon = [[UIImageView alloc]initWithFrame:CGRectMake(duiImgWidth - 50 - 8, 14, 13, 15)];
            commIcon.image = [UIImage imageNamed:@"btn_pinglun"];
            [bFirstView addSubview:commIcon];
            
            
            UILabel * commLbl = [[UILabel alloc] initWithFrame:CGRectMake(XW(commIcon) + 3, Y(commIcon) -1, 30, 15)];
            commLbl.backgroundColor = [UIColor clearColor];
            commLbl.font = Font(12);
            commLbl.text = @"评论";
            commLbl.textColor = [UIColor grayTitleColor];
            [bFirstView addSubview:commLbl];
            
            [cell.contentView addSubview:bFirstView];
            
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
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
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
    
    [_navBarLeftButtonPopTipView dismissAnimated:YES];
    
    if ([self.icMainViewController respondsToSelector:@selector(setStrIndexForDetail:)]) {
        if (_hasDel) {
            [self.icMainViewController setValue:[NSString stringWithFormat:@"%ld",(NSInteger)_indexInMainArray] forKey:@"strIndexForDetail"];
        }
        else
            [self.icMainViewController setValue:nil forKey:@"strIndexForDetail"];
    }
    if (_workGroupId != nil ) {
        if ([self.icMainViewController respondsToSelector:@selector(setPubGroupId:)]) {
            [self.icMainViewController setValue:_workGroupId forKey:@"pubGroupId"];
        }
    }
}

#pragma mark - collectionview delegate / datasource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return _partList.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"PartiCell";
    PartiCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:CellIdentifier forIndexPath:indexPath];
    
    NSDictionary * partDic = _partList[indexPath.row];
    
    NSString * imageUrl = [partDic valueForKey:@"img"];
    
    [cell.photoView setImageWithURL:[NSURL URLWithString: imageUrl] placeholderImage:[UIImage imageNamed:@"icon_chengyuan"] options:SDWebImageDelayPlaceholder usingActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    [cell.photoView setRoundCorner:3.3];
    
    BOOL isRead = [[partDic valueForKey:@"isRead"] boolValue];
    
    cell.isReadLbl.hidden = !isRead;
    
    cell.titleLbl.text = [partDic valueForKey:@"name"];
    
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewFlowLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake(50, 50 + 30);
}

- (void) clickMorePart:(id)sender
{
    _isShowAllPart = !_isShowAllPart;
    
    [_tableView reloadData];
}

- (void)clickJianTou:(id)sender
{
    _isShowAllChildMission = !_isShowAllChildMission;
    
//    [_childTableView reloadData];
    [_tableView reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [_inputBar.textField resignFirstResponder];
}

- (void)jumpToMissionDetailView:(id)sender
{
    UIButton * btn = (UIButton *)sender;
    
    NSInteger index = btn.tag - 100;
    
    NSDictionary * dic = _childMissionList[index];
    
    NSString * taskId = [dic valueForKey:@"taskId"];
    
    NSArray* commentsArray = [NSArray array];
    NSArray * imgArr = [NSArray array];
    
    _currentMission = [Mission detail:taskId commentArray:&commentsArray imgArr:&imgArr messageId:_messageId];
    
    if(!_currentMission)
    {
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"" message:@"你不在该任务中" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil];
        
        [alert show];
        
        return;
    }
    else
    {
        UIStoryboard* mainStory = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        UIViewController* vc = [mainStory instantiateViewControllerWithIdentifier:@"ICWorkingDetailViewController"];
        ((ICWorkingDetailViewController*)vc).taskId = taskId;
        ((ICWorkingDetailViewController*)vc).indexInMainArray = _indexInMainArray;
        ((ICWorkingDetailViewController*)vc).icMainViewController = _icMainViewController;
        ((ICWorkingDetailViewController*)vc).workGroupId = _workGroupId;
        ((ICWorkingDetailViewController*)vc).isChildMission = YES;

        [self.navigationController pushViewController:vc animated:YES];
    }
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
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
                }
            }
            
        }];
    }
}

@end
