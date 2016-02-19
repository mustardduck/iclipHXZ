//
//  MQPublishMissionMainController.m
//  CommonFrame_Pro
//
//  Created by 倩 莫 on 15/10/27.
//  Copyright © 2015年 ionitech. All rights reserved.
//

#import "MQPublishMissionMainController.h"
#import "MQPublishMissionMainCell.h"
#import "Mission.h"
#import "UICommon.h"
#import "PH_UITextView.h"
#import "MQPublishMissionController.h"
#import "SVProgressHUD.h"
#import "DashesLineView.h"
#import "UIImageView+UIActivityIndicatorForSDWebImage.h"

@interface MQPublishMissionMainController ()<UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate,UITextViewDelegate,UIAlertViewDelegate>
{
//    NSInteger _dataCount;
    
    UIView * _currentView;
    
    BOOL _isMainMission;
    
    BOOL _isEditChildMission;
    
    NSInteger _currentEditChildIndex;
    
//    NSMutableArray * _titleNameList;
    
    NSString * _currTaskId;
    
}

@property (strong, nonatomic) IBOutlet UITableView *mainTableView;
@property (weak, nonatomic) IBOutlet UIView *topTxtView;
@property (weak, nonatomic) IBOutlet PH_UITextView *mainTextView;
@property (weak, nonatomic) IBOutlet UIView *rightTxtView;
@property (weak, nonatomic) IBOutlet UIButton *rightTxtBtn;
@property (weak, nonatomic) IBOutlet UIView *jiaView;
@property (assign, nonatomic) CGFloat keyboardHeight;
@property (weak, nonatomic) IBOutlet DashesLineView *topRightDashLine;
@property (weak, nonatomic) IBOutlet UIView *headerView;
@property (weak, nonatomic) IBOutlet UIButton *jiaBtn;
@property (weak, nonatomic) IBOutlet UIImageView *topPhotoView;

@end

@implementation MQPublishMissionMainController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];

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
    
    [self.view setBackgroundColor:[UIColor backgroundColor]];
    
    [self setHeaderView];
    
    
    self.childMissionArr = [NSMutableArray array];
    
    _mainMissionDic = [NSMutableDictionary dictionary];
    
//    _dataCount = 1;
    
    [self resetData];

}

- (void)keyboardWillShow:(NSNotification *)notification {
    
    /*
     Reduce the size of the text view so that it's not obscured by the keyboard.
     Animate the resize so that it's in sync with the appearance of the keyboard.
     */
    
    NSDictionary *userInfo = [notification userInfo];
    
    // Get the origin of the keyboard when it's displayed.
    NSValue* aValue = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
    
    // Get the top of the keyboard as the y coordinate of its origin in self's view's coordinate system. The bottom of the text view's frame should align with the top of the keyboard's final position.
    CGRect keyboardRect = [aValue CGRectValue];
    self.keyboardHeight = keyboardRect.size.height; //后面要用到
    
    // Get the duration of the animation.
    NSValue *animationDurationValue = [userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSTimeInterval animationDuration;
    [animationDurationValue getValue:&animationDuration];
    
    // animationDuration = 0.250000
}

- (void) changeAddBtnLblColor:(MQPublishMissionMainCell*)cell textStr:(NSString *)textStr
{
    if(textStr.length)
    {
        [cell.addBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        
        [cell.addBtn setImage:[UIImage imageNamed:@"icon_tianjia_1"] forState:UIControlStateNormal];
        
    }
    else
    {
        [cell.addBtn setTitleColor:RGBACOLOR(255, 255, 255, 0.3) forState:UIControlStateNormal];
        
        [cell.addBtn setImage:[UIImage imageNamed:@"icon_tianjia_2"] forState:UIControlStateNormal];
        
    }
}

- (void) resetData
{
    if(_isEdit)
    {
//        self.navigationItem.rightBarButtonItem = nil;
        
        NSMutableDictionary * mdic = [NSMutableDictionary dictionary];
        
        NSArray * childArr = [Mission findTaskList:_taskId mainMissionDic:&mdic];
        
        if(mdic)
        {
            _mainMissionDic = mdic;
        }
        
        [_childMissionArr removeAllObjects];
        
        [_childMissionArr addObjectsFromArray:childArr];
    }
}

- (void) textViewDidBeginEditing:(UITextView *)textView
{
    _rightTxtView.hidden = NO;
    
    _currentView = _mainTextView;
    
    _jiaView.hidden = YES;
    
    NSIndexPath * indexpath = [NSIndexPath indexPathForRow:0 inSection:0];
    
    MQPublishMissionMainCell * cell = [_mainTableView cellForRowAtIndexPath:indexpath];
    
    [self changeAddBtnLblColor:cell textStr:_mainTextView.text];
}

- (void) textViewDidEndEditing:(UITextView *)textView
{
    NSIndexPath * indexpath = [NSIndexPath indexPathForRow:0 inSection:0];
    
    if(_childMissionArr.count)
    {
        indexpath = [NSIndexPath indexPathForRow:_childMissionArr.count inSection:0];
    }
    MQPublishMissionMainCell * cell = [_mainTableView cellForRowAtIndexPath:indexpath];
    
    [self changeAddBtnLblColor:cell textStr:_mainTextView.text];
}

- (void) setHeaderView
{
    [_topTxtView setRoundColorCorner:5.0 withColor:[UIColor grayLineColor]];
    [_rightTxtBtn addTarget:self action:@selector(rightBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    _rightTxtBtn.tag = 99;
    [_mainTextView setPlaceholder:@"请编写任务标题!"];
    
    [self addDoneToKeyboard:_mainTextView];
    
    _topRightDashLine.lineColor = [UIColor grayLineColor];
    _topRightDashLine.startPoint = CGPointMake(0, 0);
    _topRightDashLine.endPoint = CGPointMake(0, 90);
    _topRightDashLine.backgroundColor = [UIColor clearColor];
    _topRightDashLine.frame = CGRectMake(34, 0, 0.5, 90);
    
    UIView * lineShort = [[UIView alloc] init];
    lineShort.frame = CGRectMake(26.5, YH(_topTxtView), 0.5, 6);
    lineShort.backgroundColor = [UIColor grayLineColor];
    [_headerView addSubview:lineShort];
    
    
    
}

- (void)rightBtnClicked:(id)sender
{
    [self hiddenKeyboard];
    
    NSDictionary * dic;
    
    UIButton * btn = (UIButton *)sender;
    if(btn.tag == 99)
    {
        _isMainMission = YES;
    }
    else
    {
        _isMainMission = NO;
    }
    
    if(_isMainMission)
    {
        NSString * str = _mainTextView.text;
        
        if(!str.length)
        {
            str = @"";
        }
        [_mainMissionDic setObject:str forKey:@"title"];

        dic = _mainMissionDic;

    }
    else
    {
        NSInteger index = btn.tag - 100;
        
        dic = _childMissionArr[index];
        
        NSDictionary * missionDic = [dic objectForKey:@"missionDic"];
        
        _isEditChildMission = missionDic ? YES : NO;
        
        _currentEditChildIndex = index;
        
    }
    
    NSDictionary * missionDic = [dic objectForKey:@"missionDic"];
    
    _currTaskId = [missionDic valueForKey:@"taskId"];

    [self jumpToMission:dic];

}

- (void) jumpToMission:(NSDictionary *)dic
{
    UIStoryboard* mainStory = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    
    UIViewController* vc = [mainStory instantiateViewControllerWithIdentifier:@"MQPublishMissionController"];
    
    if (_workGroupId) {
        ((MQPublishMissionController*)vc).workGroupId = _workGroupId;
        ((MQPublishMissionController*)vc).workGroupName = _workGroupName;
    }
    
    ((MQPublishMissionController*)vc).userId = [LoginUser loginUserID];
    ((MQPublishMissionController*)vc).icMissionMainViewController = self;
    ((MQPublishMissionController*)vc).isMainMission = _isMainMission;
    ((MQPublishMissionController*)vc).savedChildMissionArr = _childMissionArr;
    ((MQPublishMissionController*)vc).currentEditChildIndex = _currentEditChildIndex;
    if(_isMainMission)
    {
        NSDictionary * mDic = [_mainMissionDic valueForKey:@"missionDic"];
        NSString * taskId = [mDic valueForKey:@"taskId"];
        NSString * workGroupId = [mDic valueForKey:@"workGroupId"];
        NSString * workGroupName = [mDic valueForKey:@"workGroupName"];

        if(!taskId)
        {
            _isEdit = NO;//新增主任务
        }
        else
        {
            _isEdit = YES;//编辑主任务

            NSDictionary * missiDic = [Mission missionInfo:taskId];
            NSDictionary * missionDic = [missiDic objectForKey:@"missionDic"];
            
            NSString * lableUserImg = [mDic valueForKey:@"lableUserImg"];
            NSArray * resArr = [mDic objectForKey:@"respoDic"];
            Member * m = resArr[0];
            
            if(lableUserImg || m.img)
            {
                if(lableUserImg)
                {
                    ((MQPublishMissionController*)vc).lableUserImg = lableUserImg;
                }
                else
                {
                    ((MQPublishMissionController*)vc).lableUserImg = m.img;
                }

            }
            ((MQPublishMissionController*)vc).workGroupId = [missionDic valueForKey:@"workGroupId"];
            ((MQPublishMissionController*)vc).workGroupName = [missionDic valueForKey:@"workGroupName"];
//            ((MQPublishMissionController*)vc).missionDic = missionDic;
        }
        if(workGroupId)
        {
            ((MQPublishMissionController*)vc).workGroupId = workGroupId;
            ((MQPublishMissionController*)vc).workGroupName = workGroupName;
        }
    }
    if(_childMissionArr.count && !_isMainMission)
    {
        NSDictionary * cmdic = _childMissionArr[_currentEditChildIndex];
        NSDictionary * mDic = [cmdic valueForKey:@"missionDic"];
        NSString * taskId = [mDic valueForKey:@"taskId"];
        NSString * workGroupId = [mDic valueForKey:@"workGroupId"];
        NSString * workGroupName = [mDic valueForKey:@"workGroupName"];
        if(!taskId)
        {
            _isEdit = NO;//新增子任务
            
            NSDictionary * mainDic = [_mainMissionDic objectForKey:@"missionDic"];
            
            if([mainDic allKeys].count)
            {
                NSString * taskId = [mainDic valueForKey:@"taskId"];
                
                ((MQPublishMissionController*)vc).parentId = taskId;

            }
        }
        else
        {
            _isEdit = YES;//编辑子任务
            
            NSDictionary * missiDic = [Mission missionInfo:taskId];
            NSString * missionDic = [missiDic objectForKey:@"missionDic"];
            
            NSString * lableUserImg = [mDic valueForKey:@"lableUserImg"];
            NSArray * resArr = [mDic objectForKey:@"respoDic"];
            Member * m = resArr[0];
            
            if(lableUserImg || m.img)
            {
                if(lableUserImg)
                {
                    ((MQPublishMissionController*)vc).lableUserImg = lableUserImg;
                }
                else
                {
                    ((MQPublishMissionController*)vc).lableUserImg = m.img;
                }
            }

            ((MQPublishMissionController*)vc).workGroupId = [missionDic valueForKey:@"workGroupId"];
            ((MQPublishMissionController*)vc).workGroupName = [missionDic valueForKey:@"workGroupName"];

//            ((MQPublishMissionController*)vc).missionDic = missionDic;
        }
        
        if(workGroupId)
        {
            ((MQPublishMissionController*)vc).workGroupId = workGroupId;
            ((MQPublishMissionController*)vc).workGroupName = workGroupName;
        }
    }

    ((MQPublishMissionController*)vc).isEditMission = _isEdit;
    ((MQPublishMissionController*)vc).taskId = _currTaskId;

    if(!_isEdit)
    {
        ((MQPublishMissionController*)vc).missionDic = dic;
    }
    
    [self.navigationController pushViewController:vc animated:YES];
    
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(buttonIndex == 1)
    {
        if(alertView.tag == 123 || alertView.tag >= 1000)
        {
            NSDictionary * dic;
            
            if(alertView.tag == 123)
            {
                _isMainMission = YES;
                
                NSString * str = _mainTextView.text;
                
                if(!str.length)
                {
                    str = @"";
                }
                [_mainMissionDic setObject:str forKey:@"title"];
                
                dic = _mainMissionDic;
            }
            else if(alertView.tag >= 1000)
            {
                NSInteger index = alertView.tag - 1000;
                
                _currentEditChildIndex = index;
                
                _isMainMission = NO;
                
                dic = _childMissionArr[index];
                
            }
            
            [self jumpToMission:dic];
        }
        else
        {
//            [SVProgressHUD showInfoWithStatus:@"任务删除中..."];
            
            NSInteger index = alertView.tag;
            
            NSDictionary * missionDic = _childMissionArr[index];
            
            NSDictionary * mDic = [missionDic valueForKey:@"missionDic"];
            
            NSString * taskId = [mDic valueForKey:@"taskId"];
            
            if(taskId)
            {
                BOOL isRemoved = [Mission reomveMission:taskId];
                if (isRemoved) {
                    
//                    [SVProgressHUD dismiss];
                    [_childMissionArr removeObjectAtIndex:index];
                    [_mainTableView reloadData];
                    
                }
                else
                {
                    [SVProgressHUD showErrorWithStatus:@"任务删除失败"];
                }
            }
            else
            {
                [_childMissionArr removeObjectAtIndex:index];
                [_mainTableView reloadData];
            }
            
            [self resetTableViewFrame];
        }
    }
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    [self resetTableViewFrame];
}

- (void)resetTableViewFrame
{
    if (_currentView != nil) {
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationBeginsFromCurrentState:YES];
        [UIView setAnimationDuration:0.250000];
        self.mainTableView.frame = self.view.bounds;
        [UIView commitAnimations];
        
        [_currentView resignFirstResponder];
//        _currentView = nil;
    }
    [self.mainTableView reloadData];
}

- (IBAction)btnJiaButtonClicked:(id)sender
{
    [_mainTextView becomeFirstResponder];
}

- (IBAction)btnBackButtonClicked:(id)sender
{
    [self hiddenKeyboard];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void) checkData
{
    NSDictionary * mainDic = [_mainMissionDic objectForKey:@"missionDic"];
    
    if(![mainDic allKeys].count)
    {
        NSString * msg = [NSString stringWithFormat:@"主任务未填写完整，不能发布任务"];
        
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"提示" message:msg delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"去填写", nil];
        
        alert.tag = 123;
        
        [alert show];
        
        return;
    }
    
    NSMutableArray * childArr = [NSMutableArray array];
    
    NSMutableArray * childArray = [NSMutableArray array];
    
    for(NSDictionary * dic in _childMissionArr)
    {
        NSDictionary * mDic = [dic objectForKey:@"missionDic"];
        
        NSString * taskId = [mDic valueForKey:@"taskId"];
        
        if(!taskId)
        {
            [childArray addObject:dic];
        }
    }
    
    if(_isEdit && !childArray.count)
    {
        [SVProgressHUD showSuccessWithStatus:@"任务发布成功"];
        
        [self.navigationController popViewControllerAnimated:YES];
        
        return;
    }
    
    NSMutableDictionary * mDic = [[NSMutableDictionary alloc] initWithDictionary:mainDic];
    
    [mDic removeObjectForKey:@"ccopyArr"];
    [mDic removeObjectForKey:@"partiArr"];
    [mDic removeObjectForKey:@"respoDic"];
    [mDic removeObjectForKey:@"accesList"];
    [mDic removeObjectForKey:@"cMarkList"];
    [mDic removeObjectForKey:@"workGroupName"];

    NSString * taskId = [mainDic valueForKey:@"taskId"];
    
    NSString * parentId;
    
    if(!taskId)
    {
        [childArr addObject:mDic];
    }
    else
    {
        parentId = taskId;
    }
    
    for (int i = 0; i< _childMissionArr.count; i ++)
    {
        NSDictionary * dic = _childMissionArr[i];
        
        NSDictionary * missDic = [dic objectForKey:@"missionDic"];
        
        NSString * taskId = [missDic valueForKey:@"taskId"];
        
        if(!missDic)
        {
            NSString * msg = [NSString stringWithFormat:@"第 %d 行子任务未填写完整，不能发布任务", i + 1];
            
            UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"提示" message:msg delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"去填写", nil];
            
            alert.tag = i + 1000;
            
            [alert show];
            
            return;
        }
        else
        {
            NSMutableDictionary * mmDic = [[NSMutableDictionary alloc] initWithDictionary:missDic];
            
            [mmDic removeObjectForKey:@"ccopyArr"];
            [mmDic removeObjectForKey:@"partiArr"];
            [mmDic removeObjectForKey:@"respoDic"];
            [mmDic removeObjectForKey:@"accesList"];
            [mmDic removeObjectForKey:@"cMarkList"];
            [mmDic removeObjectForKey:@"workGroupName"];

            if(parentId)
            {
                [mmDic setObject:parentId forKey:@"parentId"];
            }
            
            if(!taskId)
            {
                [childArr addObject:mmDic];
            }
        }
    }
    
    NSLog(@"%@", childArr);
    
    [SVProgressHUD showWithStatus:@"任务发布中..."];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        NSString * taskId = @"";
        
        //        BOOL isSendOK = [m sendMission:YES taksId:&taskId];
        BOOL isSendOK = [Mission sendAllMission:YES taksId:&taskId withArr:childArr];
        
        if (isSendOK) {
            
            if(!_isEdit)
            {
                [[NSNotificationCenter defaultCenter] postNotificationName:@"refreshMainViewFromCreate"
                                                                    object:nil];
            }
            
            [SVProgressHUD showSuccessWithStatus:@"任务发布成功"];
            
            [self hiddenKeyboard];
            [self.navigationController popViewControllerAnimated:YES];
        }
        else
        {
            [SVProgressHUD showErrorWithStatus:@"任务发布失败"];
        }
        
    });
}

- (IBAction)btnDoneButtonClicked:(id)sender
{
    NSLog(@"%@",_childMissionArr);
    
    [self hiddenKeyboard];
    
    dispatch_time_t time=dispatch_time(DISPATCH_TIME_NOW, 0.5*NSEC_PER_SEC);
    dispatch_after(time, dispatch_get_main_queue(), ^{
        [self checkData];
    });
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -
#pragma mark Table View Action
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _childMissionArr.count + 1;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellId = @"MQMissionMainCell";
    MQPublishMissionMainCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    if (cell == nil){
        cell = [[MQPublishMissionMainCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
    }
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    NSInteger tag = indexPath.row;
    
    if(_childMissionArr.count)
    {
        if(indexPath.row == _childMissionArr.count)
        {
            cell.addView.hidden = NO;
            UIView * line = [cell viewWithTag:1];
            if(!line)
            {
                line = [[UIView alloc] initWithFrame:CGRectMake(26.5, 0, 0.5, 35)];
                line.backgroundColor = [UIColor grayLineColor];
                line.tag = 1;
            }
            line.height = 35;
            [cell.contentView addSubview:line];
            
            UIView * line2 = [cell viewWithTag:2];
            if(!line2)
            {
                line2 = [[UIView alloc] initWithFrame:CGRectMake(26.5, 35, 13, 0.5)];
                line2.backgroundColor = [UIColor grayLineColor];
                line2.tag = 2;
            }
            [cell.contentView addSubview:line2];
            
            //        cell.addBtn.tag = 2222;
            
            NSDictionary * titleDic = _childMissionArr[indexPath.row - 1];
            
            NSString * ctitle = [titleDic valueForKey:@"title"];
            
            [self changeAddBtnLblColor:cell textStr:ctitle];
            
            [cell.addBtn addTarget:self action:@selector(addMissionCell:) forControlEvents:UIControlEventTouchUpInside];
            
            UILabel* numLbl = [cell viewWithTag:3];

            if(numLbl)
            {
                numLbl.hidden = YES;
            }
        }
        else
        {
            cell.addView.hidden = YES;
            
            UIView * line = [cell viewWithTag:1];
            if(!line)
            {
                line = [[UIView alloc] initWithFrame:CGRectMake(26.5, 0, 0.5, 60)];
                line.backgroundColor = [UIColor grayLineColor];
                line.tag = 1;
            }
            line.height = 60;
            [cell.contentView addSubview:line];
            
            UIView * line2 = [cell viewWithTag:2];
            if(!line2)
            {
                line2 = [[UIView alloc] initWithFrame:CGRectMake(26.5, 35, 13, 0.5)];
                line2.backgroundColor = [UIColor grayLineColor];
                line2.tag = 2;
            }
            [cell.contentView addSubview:line2];
            
            UILabel* numLbl = [cell viewWithTag:3];
            numLbl.hidden = NO;
            if(!numLbl)
            {
                numLbl = [[UILabel alloc] initWithFrame:CGRectMake(10, 14, 16, 44)];
                numLbl.font = Font(15);
                numLbl.textColor = [UIColor whiteColor];
                numLbl.backgroundColor = [UIColor clearColor];
                numLbl.tag = 3;
            }
            
            numLbl.text = [NSString stringWithFormat:@"%ld", indexPath.row + 1];
            [cell.contentView addSubview:numLbl];
            
            [self addDoneToKeyboard:cell.titleLbl];
            
            [cell.rightBtn addTarget:self action:@selector(rightBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
            cell.rightBtn.tag = tag + 100;
            
            NSDictionary * dic = _childMissionArr[indexPath.row];
            
            if(dic)
            {
                cell.titleLbl.text = [dic valueForKey:@"title"];
                if(cell.titleLbl.text.length)
                {
                    cell.rightView.hidden = NO;
                    cell.lineView.lineColor = [UIColor grayLineColor];
                    cell.lineView.startPoint = CGPointMake(0, 0);
                    cell.lineView.endPoint = CGPointMake(0, 44);
                    cell.lineView.backgroundColor = [UIColor clearColor];
                    cell.lineView.frame = CGRectMake(68, 0, 0.5, 44);
                    
                    cell.rightPhoto.hidden = NO;
                    cell.rightPhoto.image = nil;
                    [cell.rightPhoto setRoundCorner:5];

                    NSDictionary * mainDic = [dic objectForKey:@"missionDic"];
                    NSArray * responArr = [mainDic objectForKey:@"respoDic"];
                    Member * m = responArr[0];
                    
                    NSString * lableUserImg = [mainDic valueForKey:@"lableUserImg"];
                    
                    if(m.img || lableUserImg)
                    {
                        NSString * imgUrl = m.img;
                        if(!imgUrl)
                        {
                            imgUrl = lableUserImg;
                        }
                        [cell.rightPhoto setImageWithURL:[NSURL URLWithString:imgUrl] placeholderImage:nil options:SDWebImageDelayPlaceholder usingActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
                    }


                }
                else
                {
                    cell.rightView.hidden = YES;
                    cell.rightPhoto.hidden = YES;
                }
            }
        }
    }
    else
    {
        cell.addView.hidden = NO;
        UIView * line = [cell viewWithTag:1];
        if(!line)
        {
            line = [[UIView alloc] initWithFrame:CGRectMake(26.5, 0, 0.5, 35)];
            line.backgroundColor = [UIColor grayLineColor];
            line.tag = 1;
        }
        line.height = 35;
        [cell.contentView addSubview:line];
        
        UIView * line2 = [cell viewWithTag:2];
        if(!line2)
        {
            line2 = [[UIView alloc] initWithFrame:CGRectMake(26, 35, 13, 0.5)];
            line2.backgroundColor = [UIColor grayLineColor];
            line2.tag = 2;
        }
        [cell.contentView addSubview:line2];
        
        //        cell.addBtn.tag = 2222;
        
        
        [self changeAddBtnLblColor:cell textStr:_mainTextView.text];
        
        [cell.addBtn addTarget:self action:@selector(addMissionCell:) forControlEvents:UIControlEventTouchUpInside];
    }

    cell.titleLbl.tag = tag + 100;

    [cell.titleView setRoundColorCorner:5 withColor:[UIColor grayLineColor]];
    return cell;
}

- (void) textFieldDidBeginEditing:(UITextField *)textField
{
    _currentView = textField;
    
    NSIndexPath * indexpath = [NSIndexPath indexPathForRow:textField.tag - 100 inSection:0];
    
    MQPublishMissionMainCell * cell = [_mainTableView cellForRowAtIndexPath:indexpath];
    
    if(cell)
    {
        cell.rightView.hidden = NO;
        
        cell.lineView.lineColor = [UIColor grayLineColor];
        cell.lineView.startPoint = CGPointMake(0, 0);
        cell.lineView.endPoint = CGPointMake(0, 44);
        cell.lineView.backgroundColor = [UIColor clearColor];
        cell.lineView.frame = CGRectMake(68, 0, 0.5, 44);
        
    }
    
    [self performSelector:@selector(scrollTableView:) withObject:textField afterDelay:0.0]; //必须
}


- (void)scrollTableView:(UITextField *)textField{
    
    NSInteger index = _currentView.tag - 100;
    
    if(index < 0)
    {
        return;
    }
    
    CGRect frame = _mainTableView.frame;
    frame.size.height = self.view.bounds.size.height-self.keyboardHeight;
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:0.250000];
    self.mainTableView.frame = frame;
    [UIView commitAnimations];
    
    NSIndexPath * localIndexPath = [NSIndexPath indexPathForRow:index + 1 inSection:0];

    [self.mainTableView scrollToRowAtIndexPath:localIndexPath atScrollPosition:UITableViewScrollPositionBottom animated:YES];
}


- (void) textFieldDidEndEditing:(UITextField *)textField
{
    NSInteger index = textField.tag - 100;
    
    if(_childMissionArr.count > 0)
    {
        NSDictionary * childDic = _childMissionArr[index];
        
        NSMutableDictionary * mDic = [NSMutableDictionary dictionary];
        
        [mDic setObject:textField.text forKey:@"title"];
        
        NSDictionary * miDic = [childDic objectForKey:@"missionDic"];
        if(miDic)
        {
            [mDic setObject:miDic forKey:@"missionDic"];
        }
        
        [_childMissionArr replaceObjectAtIndex:index withObject:mDic];
    }

    [self resetTableViewFrame];
}

- (void) hiddenKeyboard
{
    [_currentView resignFirstResponder];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

//-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    [tableView deselectRowAtIndexPath:indexPath animated:YES];
//
//}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(_childMissionArr.count == indexPath.row)
    {
        return UITableViewCellEditingStyleNone;
    }
    return UITableViewCellEditingStyleDelete;

}

- (NSString*)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return @"移除";
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete)
    {
        [self hiddenKeyboard];
        
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"" message:[NSString stringWithFormat:@"是否删除该任务？"] delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
        alert.tag = indexPath.row;
        [alert show];
        
//        dispatch_time_t time=dispatch_time(DISPATCH_TIME_NOW, 0.5*NSEC_PER_SEC);
//        dispatch_after(time, dispatch_get_main_queue(), ^{
//            
//            UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"" message:[NSString stringWithFormat:@"是否删除该任务？"] delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
//            alert.tag = indexPath.row;
//            [alert show];
//        });
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
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void) viewWillAppear:(BOOL)animated
{

    NSDictionary * mainDic = [_mainMissionDic objectForKey:@"missionDic"];
    
    if([mainDic allKeys].count)
    {
        _mainTextView.text = [_mainMissionDic valueForKey:@"title"];

        _rightTxtView.hidden = NO;

        _jiaView.hidden = YES;
        
        NSArray * responArr = [mainDic objectForKey:@"respoDic"];
        
        Member * m = responArr[0];
        
        NSString * lableUserImg = [mainDic valueForKey:@"lableUserImg"];

        if(m.img || lableUserImg)
        {
            _topPhotoView.hidden = NO;
            _topPhotoView.image = nil;
            [_topPhotoView setRoundCorner:5];
            NSString * imgUrl = m.img;
            if(!imgUrl)
            {
                imgUrl = lableUserImg;
            }
            [_topPhotoView setImageWithURL:[NSURL URLWithString:imgUrl] placeholderImage:nil options:SDWebImageDelayPlaceholder usingActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        }
        else
        {
            _topPhotoView.hidden = YES;
        }
    }
    else
    {
        if(_mainTextView.text.length)
        {
            _rightTxtView.hidden = NO;
            
            _jiaView.hidden = YES;
        }
        else
        {
            _rightTxtView.hidden = YES;
            
            _jiaView.hidden = NO;
        }

    }
    if(_childMissionArr.count)
    {
        [_mainTableView reloadData];
    }
}


- (void) addMissionCell:(id)sender
{
    UIButton * btn = (UIButton * )sender;
    
    UITableView *  mTableView = (UITableView *)[[[[[[btn superview] superview] superview] superview] superview] superview];
    UITableViewCell *  cell = (UITableViewCell *)[[[[btn superview] superview] superview] superview];

    NSIndexPath * indexp = [mTableView indexPathForCell:cell];
    
    NSString * ctitle = @"";
    if(indexp.row <= _childMissionArr.count && indexp.row >= 1)
    {
       ctitle = [_childMissionArr[indexp.row - 1] valueForKey:@"title"];
    }
    else
    {
        ctitle = _mainTextView.text;
    }

    if(ctitle.length)
    {
        NSMutableDictionary * dic = [NSMutableDictionary dictionary];
        [dic setObject:@"" forKey:@"title"];
        
        [_childMissionArr addObject:dic];
        
        [_mainTableView reloadData];
        
        NSIndexPath * indexPath;
        if(_childMissionArr.count >= 1)
        {
            indexPath = [NSIndexPath indexPathForRow:_childMissionArr.count - 1 inSection:0];
        }
        
        MQPublishMissionMainCell *cell = [self.mainTableView cellForRowAtIndexPath:indexPath];
        
        if(cell)
        {
            [cell.titleLbl becomeFirstResponder];
        }
    }
    else
    {
        if(!_childMissionArr.count)
        {
            [SVProgressHUD showErrorWithStatus:@"请先填写主任务"];
        }
        else
        {
            [SVProgressHUD showErrorWithStatus:@"请先填写子任务"];
        }
    }
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
