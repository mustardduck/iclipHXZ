//
//  ICPublishMissionViewController.m
//  CommonFrame_Pro
//
//  Created by ionitech on 15/6/23.
//  Copyright (c) 2015年 ionitech. All rights reserved.
//

#import "ICPublishMissionViewController.h"
#import <UIImageView+UIActivityIndicatorForSDWebImage.h>
#import "PH_UITextView.h"
#import "UICommon.h"
//#import <AVOSCloud/AVOSCloud.h>

@interface ICPublishMissionViewController() <UITableViewDataSource,UITableViewDelegate,UIActionSheetDelegate,UINavigationControllerDelegate,UIImagePickerControllerDelegate,UITextViewDelegate>
{
    UITableView*            _tableView;
    UIDatePicker*           _datePicker;
    UIView*                 _datePickerView;
    NSMutableArray*         _accessoryArray;
    PH_UITextView*             _txtContent;
    UITextField*             _titleText;
    BOOL                    _btnDoneClicked;
}


@end

@implementation ICPublishMissionViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
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
    
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height - 66)];
    _tableView.backgroundColor = [UIColor colorWithRed:0.15f green:0.15f blue:0.15f alpha:1.0f];
    _tableView.dataSource = self;
    _tableView.delegate = self;
    _tableView.tag = 101;
    [_tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    
    CGFloat tableWidth = [UIScreen mainScreen].bounds.size.width;
    
    _tableView.tableHeaderView = ({
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableWidth, 108 + 40)];
        [view setBackgroundColor:[UIColor colorWithRed:[self colorWithRGB:57] green:[self colorWithRGB:59] blue:[self colorWithRGB:74] alpha:1.0f]];
        
        _titleText = [[UITextField alloc] initWithFrame:CGRectMake(12, 0, tableWidth, 40)];
        _titleText.placeholder = @"标题";
        [_titleText setValue:[UIColor grayColor] forKeyPath:@"_placeholderLabel.textColor"];
        _titleText.font = [UIFont systemFontOfSize:15];
        _titleText.textColor = [UIColor whiteColor];
        _titleText.backgroundColor = [UIColor clearColor];
        _titleText.textAlignment = NSTextAlignmentLeft;
        if (![_titleName isEqualToString:@""] && _titleName != nil) {
            [_titleText setText:_titleName];
        }
        else
        {
            [_titleText setText:@""];
        }
        
        [view addSubview:_titleText];
        [self addDoneToKeyboard:_titleText];

        
        UILabel* line1 = [[UILabel alloc] initWithFrame:CGRectMake(0, YH(_titleText)- 0.5, tableWidth, 0.5)];
        [line1 setBackgroundColor:[UIColor grayColor]];
        [view addSubview:line1];
        
        _txtContent = [[PH_UITextView alloc] initWithFrame:CGRectMake(8, YH(_titleText), tableWidth, 108)];
//        [_txtContent setReturnKeyType:UIReturnKeyNext];
        if (![_content isEqualToString:@""] && _content != nil) {
            [_txtContent setText:_content];
        }
        else
        {
            [_txtContent setText:@""];
        }
        [_txtContent setTextAlignment:NSTextAlignmentLeft];
        [_txtContent setTextColor:[UIColor whiteColor]];
        [_txtContent setBackgroundColor:[UIColor clearColor]];
        _txtContent.font = [UIFont systemFontOfSize:14];
        _txtContent.delegate = self;
        _txtContent.placeholder = @"点击编辑正文";
        _txtContent.placeholderColor = [UIColor grayColor];
        
        [self addDoneToKeyboard:_txtContent];
        
        [view addSubview:_txtContent];
        
        
        view;
        //
    });
    
   
    
    
    [self.view addSubview:_tableView];
    
    [self.view setBackgroundColor:[UIColor colorWithRed:0.15f green:0.15f blue:0.15f alpha:1.0f]];
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
    [_titleText resignFirstResponder];
    [_txtContent resignFirstResponder];
    
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    if ([self.icDetailViewController respondsToSelector:@selector(setContent:)]) {
        [self.icDetailViewController setValue:@"1" forKey:@"content"];
    }
    
    if (_btnDoneClicked) {
        if ([self.icGroupViewController respondsToSelector:@selector(setGroupId:)]) {
            [self.icGroupViewController setValue:_workGroupId forKey:@"groupId"];
        }
    }
    
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
//    if ([text isEqualToString:@"\n"]){
//        //[self send];
//        [_txtContent resignFirstResponder];
//        return NO;
//    }
    return YES;
}

- (CGFloat)colorWithRGB:(NSInteger)value
{
    CGFloat re = 0;
    
    re = value / 255.0f;
    
    return re;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [_tableView reloadData];
    
    if (self.participantsIndexPathArray != nil) {
         NSLog(@"%@",self.participantsIndexPathArray);
        
        NSIndexPath* indexPath = [NSIndexPath indexPathForRow:(NSInteger)1 inSection:(NSInteger)0];
        UITableViewCell* cell = [_tableView cellForRowAtIndexPath:indexPath];
        BOOL isEx = NO;
        for (UIControl* control in cell.contentView.subviews) {
            if (control.tag == 112) {
                [control removeFromSuperview];
            }
        }
        if (!isEx) {
           
            UIFont* font = [UIFont systemFontOfSize:12];
            
            CGFloat cWidth = [UIScreen mainScreen].bounds.size.width;
            CGFloat x = 120;
            CGFloat y = 15;
            CGFloat inteval = 2;
            CGFloat lblTotalWidth = cWidth - x - 80;
            CGFloat nWidth = 0;
            CGFloat lHeight = 15;
            
            int row = 1;
            
            for (int i = 0; i< self.participantsIndexPathArray.count; i++) {
                Member* m = (Member*)[self.participantsIndexPathArray objectAtIndex:i];
                CGSize size = [CommonFile contentSize:m.name vWidth:0 vHeight:lHeight contentFont:font];
                CGFloat lwidth = size.width + 10;
                UILabel* name = [[UILabel alloc] initWithFrame:CGRectMake(x + nWidth, y * row + (row - 1)* inteval, lwidth, lHeight)];
                [name setBackgroundColor:[UIColor orangeColor]];
                [name setText: m.name];
                [name setTextColor:[UIColor whiteColor]];
                [name setTextAlignment:NSTextAlignmentCenter];
                [name setFont:font];
                name.tag = 112;
                
                [cell.contentView addSubview:name];
                
                nWidth = lwidth + nWidth + inteval;
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
        
        NSIndexPath* indexPath = [NSIndexPath indexPathForRow:(NSInteger)2 inSection:(NSInteger)0];
        UITableViewCell* cell = [_tableView cellForRowAtIndexPath:indexPath];
        BOOL isEx = NO;
        for (UIControl* control in cell.contentView.subviews) {
            if (control.tag == 112) {
                [control removeFromSuperview];
            }
        }
        if (!isEx) {
            
            
            UIFont* font = [UIFont systemFontOfSize:12];
            
            CGFloat cWidth = [UIScreen mainScreen].bounds.size.width;
            CGFloat x = 120;
            CGFloat y = 15;
            CGFloat inteval = 2;
            CGFloat lblTotalWidth = cWidth - x - 80;
            CGFloat nWidth = 0;
            CGFloat lHeight = 15;
            
            int row = 1;
            
            for (int i = 0; i< self.ccopyToMembersArray.count; i++) {
                Member* m = (Member*)[self.ccopyToMembersArray objectAtIndex:i];
                CGSize size = [CommonFile contentSize:m.name vWidth:0 vHeight:lHeight contentFont:font];
                CGFloat lwidth = size.width + 10;
                UILabel* name = [[UILabel alloc] initWithFrame:CGRectMake(x + nWidth, y * row + (row - 1)* inteval, lwidth, lHeight)];
                [name setBackgroundColor:[UIColor orangeColor]];
                [name setText: m.name];
                [name setTextColor:[UIColor whiteColor]];
                [name setTextAlignment:NSTextAlignmentCenter];
                [name setFont:font];
                name.tag = 112;
                
                [cell.contentView addSubview:name];
                
                nWidth = lwidth + nWidth + inteval;
                if (nWidth > lblTotalWidth) {
                    row++;
                    nWidth = 0;
                }
            }
            
            //cell.frame = CGRectMake(0, 0, cWidth, cell.frame.size.height + (row - 1) * (lHeight + inteval));
            
            //[_tableView reloadData];
        }
    }
    
    if (self.cMarkAarry != nil)
    {
        NSLog(@"MarkList:%@",self.cMarkAarry);
        
        NSIndexPath* indexPath = [NSIndexPath indexPathForRow:(NSInteger)0 inSection:(NSInteger)2];
        UITableViewCell* cell = [_tableView cellForRowAtIndexPath:indexPath];
        BOOL isEx = NO;
        for (UIControl* control in cell.contentView.subviews) {
            if (control.tag == 112) {
                [control removeFromSuperview];
            }
        }
        if (!isEx) {
            
            
            UIFont* font = [UIFont systemFontOfSize:12];
            
            CGFloat cWidth = [UIScreen mainScreen].bounds.size.width;
            CGFloat x = 120;
            CGFloat y = 15;
            CGFloat inteval = 2;
            CGFloat lblTotalWidth = cWidth - x - 80;
            CGFloat nWidth = 0;
            CGFloat lHeight = 15;
            
            int row = 1;
            
            for (int i = 0; i< self.cMarkAarry.count; i++) {
                Mark* m = (Mark*)[self.cMarkAarry objectAtIndex:i];
                CGSize size = [CommonFile contentSize:m.labelName vWidth:0 vHeight:lHeight contentFont:font];
                CGFloat lwidth = size.width + 10;
                UILabel* name = [[UILabel alloc] initWithFrame:CGRectMake(x + nWidth, y * row + (row - 1)* inteval, lwidth, lHeight)];
                [name setBackgroundColor:[UIColor orangeColor]];
                [name setText: m.labelName];
                [name setTextColor:[UIColor whiteColor]];
                [name setTextAlignment:NSTextAlignmentCenter];
                [name setFont:font];
                name.tag = 112;
                
                [cell.contentView addSubview:name];
                
                nWidth = lwidth + nWidth + inteval;
                if (nWidth > lblTotalWidth) {
                    row++;
                    nWidth = 0;
                }
            }
            
        }
    }
    
    if (self.responsibleDic.count > 0){
        NSLog(@"%@",self.responsibleDic);
        
        if (self.responsibleDic.count > 0) {
            NSMutableArray* arr = (NSMutableArray*)self.responsibleDic;
            
            if (arr.count == 1) {
                
                Member* mem = arr[0];
                
                NSIndexPath* indexPath = [NSIndexPath indexPathForRow:(NSInteger)0 inSection:(NSInteger)0];
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
                    UILabel* name = [[UILabel alloc] initWithFrame:CGRectMake(140, 15, 100, 15)];
                    [name setBackgroundColor:[UIColor clearColor]];
                    [name setText:mem.name];
                    [name setTextColor:[UIColor whiteColor]];
                    [name setFont:[UIFont systemFontOfSize:15]];
                    [name setTag:112];
                    
                    [cell.contentView addSubview:name];
                }
            }
        }

    }
    
    if (self.cAccessoryArray != nil){
        //上传附件（图片）
        NSLog(@"%@",self.cAccessoryArray);
        
        if (_cAccessoryArray.count > 0) {
            NSIndexPath* indexPath = [NSIndexPath indexPathForRow:1 inSection:2];
            
            UITableViewCell* cell = [_tableView cellForRowAtIndexPath:indexPath];
            CGRect frame;
            
            for (UIControl* control in cell.contentView.subviews) {
                if ([control isKindOfClass:[UIButton class]]) {
                    if (control.tag == 2022) {
                        frame = control.frame;
                        control.frame = CGRectMake(20 + (frame.size.width + 10) * _cAccessoryArray.count , frame.origin.y, frame.size.width, frame.size.height);
                        
                    }
                }
            }
            
            for (int i = 0;i < _cAccessoryArray.count; i++)
            {
//                ALAsset* ass = [_accessoryArray objectAtIndex:i];
//                ALAssetRepresentation* representation = [ass defaultRepresentation];
//                UIImage* imgH = [UIImage imageWithCGImage:[representation fullResolutionImage]];
//                
//                UIButton* btnAccessory = [[UIButton alloc] initWithFrame:CGRectMake( 20 + (frame.size.width * i) + (10 * i), frame.origin.y, frame.size.width, frame.size.height)];
//                [btnAccessory setImage:imgH forState:UIControlStateNormal];
//                [btnAccessory.layer setBorderWidth:0.5f];
//                [btnAccessory.layer setBorderColor:[[UIColor grayColor] CGColor]];
//                //[btnAccessory addTarget:self action:@selector(btnAccessoryClicked:) forControlEvents:UIControlEventTouchUpInside];
//                //btnAccessory.tag = 2022;
//                [cell.contentView addSubview:btnAccessory];
                
                Accessory * acc = _cAccessoryArray[i];

                UIImageView * imgAccessory =  [[UIImageView alloc] initWithFrame:CGRectMake( 20 + (frame.size.width * i) + (10 * i), frame.origin.y, frame.size.width, frame.size.height)];
                
                //                        UIButton* btnAccessory = [[UIButton alloc] initWithFrame:CGRectMake( 20 + (frame.size.width * i) + (10 * i), frame.origin.y, frame.size.width, frame.size.height)];
                [imgAccessory setImageWithURL:[NSURL URLWithString: acc.address] placeholderImage:nil options:SDWebImageDelayPlaceholder usingActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
                [imgAccessory setBackgroundColor:[UIColor clearColor]];
                
                [imgAccessory.layer setBorderWidth:0.5f];
                [imgAccessory.layer setBorderColor:[[UIColor grayColor] CGColor]];
                [cell.contentView addSubview:imgAccessory];
            }
        }
        
    }
    
    if (_strFinishTime != nil) {
        NSIndexPath* indexPath;
        
        indexPath = [NSIndexPath indexPathForRow:0 inSection:1];
       
        UITableViewCell* cell = [_tableView cellForRowAtIndexPath:indexPath];
        
        for (UIControl* control in cell.contentView.subviews) {
            if (control.tag == 109) {
                [control removeFromSuperview];
                break;
            }
        }

        UILabel* lbl = [[UILabel alloc] initWithFrame:CGRectMake(110, 10, 200, 20)];
        [lbl setBackgroundColor:[UIColor clearColor]];
        [lbl setTextColor:[UIColor colorWithRed:0.10 green:0.48 blue:0.94 alpha:1.0]];
        [lbl setFont:[UIFont systemFontOfSize:15]];
        [lbl setText:[UICommon formatTime:_strFinishTime withLength:10]];
        [lbl setTag:109];
        [lbl setTextAlignment:NSTextAlignmentLeft];
        
        [cell.contentView addSubview:lbl];
    }
    
    if (_strRemindTime != nil) {
        NSIndexPath* indexPath;

        indexPath = [NSIndexPath indexPathForRow:1 inSection:1];
        
        UITableViewCell* cell = [_tableView cellForRowAtIndexPath:indexPath];
        
        for (UIControl* control in cell.contentView.subviews) {
            if (control.tag == 109) {
                [control removeFromSuperview];
                break;
            }
        }
        
        UILabel* lbl = [[UILabel alloc] initWithFrame:CGRectMake(110, 10, 200, 20)];
        [lbl setBackgroundColor:[UIColor clearColor]];
        [lbl setTextColor:[UIColor colorWithRed:0.10 green:0.48 blue:0.94 alpha:1.0]];
        [lbl setFont:[UIFont systemFontOfSize:15]];
        [lbl setText:[UICommon formatTime:_strRemindTime withLength:19]];
        [lbl setTag:109];
        [lbl setTextAlignment:NSTextAlignmentLeft];
        
        [cell.contentView addSubview:lbl];
    }
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)btnBackButtonClicked:(id)sender
{
    [_txtContent resignFirstResponder];
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)btnDoneButtonClicked:(id)sender
{
    //[self.navigationController popViewControllerAnimated:YES];
    [_txtContent resignFirstResponder];
    
    
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

    
    Mission* m = [Mission new];
    
    m.createUserId = [LoginUser loginUserID];
    m.workGroupId = self.workGroupId;
    m.main = _txtContent.text;
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
    m.title = _titleText.text;
    
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
    
    if (self.cMarkAarry.count > 0) {
        m.isLabel = 1;
        NSMutableArray* tAr = [NSMutableArray array];
        if (self.cMarkAarry.count > 0) {
            m.labelList = [NSMutableArray array];
            
            for (int i = 0; i < self.cMarkAarry.count; i++) {
                Mark * cM = [self.cMarkAarry objectAtIndex:i];
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
   
     dispatch_async(dispatch_get_main_queue(), ^{
         
         NSString * taskId = @"";
         
         BOOL isSendOK = [m sendMission:YES taksId:&taskId];
         
         if (isSendOK) {
             
//             2，被别人的发布提及时，如：任务-责任人，参与人，抄送，通知、问题、建议-可见范围；
//             （XX(用户名)发布了XX(类型名)，需要你查看。）
//             - 点击进入时，进入该发布。
             /*
             AVQuery *pushQuery = [AVInstallation query];
             
             long long usId = [m.liableUserId longLongValue];
             NSMutableArray * userArr = [NSMutableArray array];
             [userArr addObject:@(usId)];//责任人
             
             for(int i = 0; i < m.partList.count; i ++)
             {
                 usId = [m.partList[i] longLongValue];
                 [userArr addObject:@(usId)];//参与人
             }
             
             for(int i = 0; i < m.cclist.count; i ++)
             {
                 usId = [m.cclist[i] longLongValue];
                 [userArr addObject:@(usId)];//抄送人
             }
             
             [pushQuery whereKey:@"HXZ_userId" containedIn:userArr];
             
             [self AVpush:taskId pushQuery:pushQuery];*/
             
             UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"任务创建成功！" delegate:self
                                                   cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
             [alert show];
             
             [_txtContent resignFirstResponder];
             _btnDoneClicked = YES;
             [self.navigationController popViewControllerAnimated:YES];
         }
         
     });
   
}

/*
- (void) AVpush:(NSString *)taskId pushQuery:(AVQuery *)pushQuery
{
    NSString * alertStr = [NSString stringWithFormat:@"%@ 发布了任务，需要你查看", [LoginUser loginUserName]];
    
    NSDictionary *data = [NSDictionary dictionaryWithObjectsAndKeys:
                          alertStr, @"alert",
                          @"Increment", @"badge",
                          taskId, @"taskId",
                          @"missionNotify", @"missionNotify",
                          nil];
    
    // Notification for iOS users
    AVPush *push = [[AVPush alloc] init];
    [AVPush setProductionMode:NO];//测试证书
    [push setChannel:@"HXZ_loginUsers"];
    
    [pushQuery whereKey:@"deviceType" equalTo:@"ios"];
    [push setQuery:pushQuery];
    [push setData:data];
    [push sendPushInBackground];
}
 */

#pragma -
#pragma Table View
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {
        return 3;
    }
    else if (section == 1) {
        return 2;
    }
    else if (section == 2) {
        return 2;
    }
    
    return 0;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 3;
}

- (NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
        return nil;
    }
    
    return @"  ";
}

- (UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView* vi = [UIView new];
    
    [vi setBackgroundColor:[UIColor clearColor]];
    
    return vi;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 1 && indexPath.section == 2) {
        return 66;
    }
    else if (indexPath.row == 1 && indexPath.section == 0) {
        
        if (self.participantsIndexPathArray.count > 0) {
            UIFont* font = [UIFont systemFontOfSize:12];
            
            CGFloat cWidth = [UIScreen mainScreen].bounds.size.width;
            CGFloat x = 120;
            CGFloat inteval = 2;
            CGFloat lblTotalWidth = cWidth - x - 80;
            CGFloat nWidth = 0;
            CGFloat lHeight = 15;
            
            int row = 1;
            
            for (int i = 0; i< self.participantsIndexPathArray.count; i++) {
                Member* m = (Member*)[self.participantsIndexPathArray objectAtIndex:i];
                CGSize size = [CommonFile contentSize:m.name vWidth:0 vHeight:lHeight contentFont:font];
                CGFloat lwidth = size.width + 10;
                nWidth = lwidth + nWidth + inteval;
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
            return  44 + (row - 1)*(lHeight + inteval);
        }
        
    }
    else if (indexPath.row == 2 && indexPath.section == 0) {
        
        if (self.ccopyToMembersArray.count > 0) {
            UIFont* font = [UIFont systemFontOfSize:12];
            
            CGFloat cWidth = [UIScreen mainScreen].bounds.size.width;
            CGFloat x = 120;
            CGFloat inteval = 2;
            CGFloat lblTotalWidth = cWidth - x - 80;
            CGFloat nWidth = 0;
            CGFloat lHeight = 15;
            
            int row = 1;
            
            for (int i = 0; i< self.ccopyToMembersArray.count; i++) {
                Member* m = (Member*)[self.ccopyToMembersArray objectAtIndex:i];
                CGSize size = [CommonFile contentSize:m.name vWidth:0 vHeight:lHeight contentFont:font];
                CGFloat lwidth = size.width + 10;
                nWidth = lwidth + nWidth + inteval;
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
            
            return  44 + (row - 1)*(lHeight + inteval);
        }
        
    }
    else if (indexPath.row == 0 && indexPath.section == 2) {
        
        if (self.cMarkAarry.count > 0) {
            UIFont* font = [UIFont systemFontOfSize:12];
            
            CGFloat cWidth = [UIScreen mainScreen].bounds.size.width;
            CGFloat x = 120;
            CGFloat inteval = 2;
            CGFloat lblTotalWidth = cWidth - x - 80;
            CGFloat nWidth = 0;
            CGFloat lHeight = 15;
            
            int row = 1;
            
            for (int i = 0; i< self.cMarkAarry.count; i++) {
                Mark* m = (Mark*)[self.cMarkAarry objectAtIndex:i];
                CGSize size = [CommonFile contentSize:m.labelName vWidth:0 vHeight:lHeight contentFont:font];
                CGFloat lwidth = size.width + 10;
                nWidth = lwidth + nWidth + inteval;
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
            
            return  44 + (row - 1)*(lHeight + inteval);
        }
        
    }
    
    return 44;
}

- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = (UITableViewCell *)[tableView cellForRowAtIndexPath:indexPath];
    UIView *selectionColor = [[UIView alloc] init];
    selectionColor.backgroundColor = [UIColor cellHoverBackgroundColor];
    cell.selectedBackgroundView = selectionColor;
    
    NSInteger index = indexPath.row;
    NSInteger section = indexPath.section;
    CGFloat tableWidth = [UIScreen mainScreen].bounds.size.width;
    CGFloat cellHeight = [self tableView:tableView heightForRowAtIndexPath:indexPath];
    
    if (section == 0 && index == 0) {
        UILabel* line1 = [[UILabel alloc] initWithFrame:CGRectMake(0, 1, tableWidth, 0.5)];
        [line1 setBackgroundColor:[UIColor grayColor]];
        [cell.selectedBackgroundView addSubview:line1];
    }
    else if (section == 1 && index == 0) {
        UILabel* line2 = [[UILabel alloc] initWithFrame:CGRectMake(0, 1, tableWidth, 0.5)];
        [line2 setBackgroundColor:[UIColor grayColor]];
        [cell.selectedBackgroundView addSubview:line2];
    }
    else if (section == 2 && index == 0) {
        UILabel* line3 = [[UILabel alloc] initWithFrame:CGRectMake(0, 1, tableWidth, 0.5)];
        [line3 setBackgroundColor:[UIColor grayColor]];
        [cell.selectedBackgroundView addSubview:line3];
    }
    if (!(section == 2 && index == 1))
    {
        UILabel* line4 = [[UILabel alloc] initWithFrame:CGRectMake(0, cellHeight - 1, tableWidth, 0.5)];
        [line4 setBackgroundColor:[UIColor grayColor]];
        [cell.selectedBackgroundView addSubview:line4];
    }
    
    return YES;
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
    
    //cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    NSInteger index = indexPath.row;
    NSInteger section = indexPath.section;
    CGFloat tableWidth = [UIScreen mainScreen].bounds.size.width;
    CGFloat cellHeight = [self tableView:tableView heightForRowAtIndexPath:indexPath];
    //CGFloat cellHeight = 44;
    
    UIImageView* photo = [[UIImageView alloc] initWithFrame:CGRectMake(12, 11, 17, 20)];
    [photo setBackgroundColor:[UIColor clearColor]];
 
    UILabel* lblText = [[UILabel alloc] initWithFrame:CGRectMake(42, 12, 100, 22)];
    [lblText setBackgroundColor:[UIColor clearColor]];
    [lblText setTextColor:[UIColor whiteColor]];
    [lblText setFont:[UIFont systemFontOfSize:15]];
    [lblText setTextAlignment:NSTextAlignmentLeft];

    if (section == 0 && index == 0) {
        UILabel* line1 = [[UILabel alloc] initWithFrame:CGRectMake(0, 1, tableWidth, 0.5)];
        [line1 setBackgroundColor:[UIColor grayColor]];
        [cell.contentView addSubview:line1];
        
        [photo setFrame:CGRectMake(12, 14, 17, 20)];
        [photo setImage:[UIImage imageNamed:@"btn_renwu_1"]];
        [lblText setText:@"责任人"];
    }
    else if (section == 0 && index == 1) {
        [photo setFrame:CGRectMake(12, 14, 17, 20)];
        [photo setImage:[UIImage imageNamed:@"icon_yonghu_2"]];
        [lblText setText:@"参与人"];
    }
    else if (section == 0 && index == 2) {
        [photo setFrame:CGRectMake(12, 11, 17, 23)];
        [photo setImage:[UIImage imageNamed:@"btn_renwu_3"]];
        [lblText setText:@"抄送"];
    }
    else if (section == 1 && index == 0) {
        UILabel* line2 = [[UILabel alloc] initWithFrame:CGRectMake(0, 1, tableWidth, 0.5)];
        [line2 setBackgroundColor:[UIColor grayColor]];
        [cell.contentView addSubview:line2];
        
        [photo setFrame:CGRectMake(12, 15, 17, 16)];
        [photo setImage:[UIImage imageNamed:@"btn_renwu_4"]];
        [lblText setText:@"完成时间"];
    }
    else if (section == 1 && index == 1) {
        [photo setFrame:CGRectMake(12, 15, 17, 15)];
        [photo setImage:[UIImage imageNamed:@"btn_renwu_5"]];
        [lblText setText:@"提醒时间"];
    }
    else if (section == 2 && index == 0) {
        UILabel* line3 = [[UILabel alloc] initWithFrame:CGRectMake(0, 1, tableWidth, 0.5)];
        [line3 setBackgroundColor:[UIColor grayColor]];
        [cell.contentView addSubview:line3];
        
        [photo setFrame:CGRectMake(12, 15, 17, 15)];
        [photo setImage:[UIImage imageNamed:@"btn_renwu_6"]];
        [lblText setText:@"添加标签"];
    }
    else if (section == 2 && index == 1) {
        [photo setFrame:CGRectMake(20, 15, 34, 34)];
        [photo setImage:[UIImage imageNamed:@"btn_fujian"]];
        [lblText setText:@"添加附件"];
        
        UIButton* btnAccessory = [[UIButton alloc] initWithFrame:CGRectMake(20, 15, 34, 34)];
        [btnAccessory setImage:[UIImage imageNamed:@"btn_fujian"] forState:UIControlStateNormal];
        [btnAccessory.layer setBorderWidth:0.5f];
        [btnAccessory.layer setBorderColor:[[UIColor grayColor] CGColor]];
        [btnAccessory addTarget:self action:@selector(btnAccessoryClicked:) forControlEvents:UIControlEventTouchUpInside];
        btnAccessory.tag = 2022;
        
        CGRect cellFrame = CGRectMake(0, 0, tableWidth, 66);
        cell.frame = cellFrame;
        
        [cell.contentView addSubview:btnAccessory];
        
    }
    
    
     if (!(section == 2 && index == 1))
     {
         
         [cell.contentView addSubview:photo];
         [cell.contentView addSubview:lblText];
         
         UILabel* line4 = [[UILabel alloc] initWithFrame:CGRectMake(0, cellHeight - 1, tableWidth, 0.5)];
         [line4 setBackgroundColor:[UIColor grayColor]];
         [cell.contentView addSubview:line4];
         
         cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
     }
    
    cell.contentView.backgroundColor = [UIColor colorWithRed:0.15f green:0.15f blue:0.15f alpha:1.0f];
    cell.backgroundColor = [UIColor colorWithRed:0.15f green:0.15f blue:0.15f alpha:1.0f];

    
    return cell;
}

- (void)btnAccessoryClicked:(id)sender
{
    UIActionSheet* as = [[UIActionSheet alloc] initWithTitle:@"选取附件" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"我的文件夹", @"拍照", @"从相册选取",@" ", nil];
    [as showInView:self.view];
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [_txtContent resignFirstResponder];
    NSInteger index = indexPath.row;
    NSInteger section = indexPath.section;
    
    if (section == 1) {
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
        if (index == 0) {
            [btnChoicedDate setTag:11];
            
        }
        else if (index == 1) {
            [btnChoicedDate setTag:12];
            
        }
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
        
        if(index == 0)
        {
            _datePicker.datePickerMode = UIDatePickerModeDate;
        }
        else if (index == 1)
        {
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
    else if(section == 0 && index == 0)
    {
        UIStoryboard* mainStory = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        UIViewController* vc = [mainStory instantiateViewControllerWithIdentifier:@"ICMemberTableViewController"];
        ((ICMemberTableViewController*)vc).controllerType = MemberViewFromControllerPublishMissionResponsible;
        ((ICMemberTableViewController*)vc).icGroupListController = self;
        ((ICMemberTableViewController*)vc).workgid =  self.workGroupId;
        if (_responsibleDic != nil) {
            ((ICMemberTableViewController*)vc).selectedResponsibleDictionary = _responsibleDic; 
        }
  
        [self.navigationController pushViewController:vc animated:YES];
    }
    else if(section == 0 && index == 1)
    {
        //if (_responsibleDic.count > 0) {
            UIStoryboard* mainStory = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
            UIViewController* vc = [mainStory instantiateViewControllerWithIdentifier:@"ICMemberTableViewController"];
            ((ICMemberTableViewController*)vc).controllerType = MemberViewFromControllerPublishMissionParticipants;
            ((ICMemberTableViewController*)vc).icPublishMisonController = self;
            
            ((ICMemberTableViewController*)vc).selectedResponsibleDictionary = _responsibleDic;
            ((ICMemberTableViewController*)vc).workgid = self.workGroupId;
            
            if (_participantsIndexPathArray.count > 0) {
                ((ICMemberTableViewController*)vc).selectedParticipantsDictionary = _participantsIndexPathArray;
            }
            [self.navigationController pushViewController:vc animated:YES];
        //}
        //else
        //{
        //    UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"请先选择责任人!" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        //    [alert show];
        //}
        
    }
    else if(section == 0 && index == 2)
    {
        //if (_participantsIndexPathArray.count > 0) {
            UIStoryboard* mainStory = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
            UIViewController* vc = [mainStory instantiateViewControllerWithIdentifier:@"ICMemberTableViewController"];
            ((ICMemberTableViewController*)vc).controllerType = MemberViewFromControllerCopyTo;
            ((ICMemberTableViewController*)vc).icPublishMisonController = self;
            
            ((ICMemberTableViewController*)vc).selectedResponsibleDictionary = _responsibleDic;
            ((ICMemberTableViewController*)vc).workgid = self.workGroupId;
            
            if (_ccopyToMembersArray.count > 0) {
                ((ICMemberTableViewController*)vc).selectedCopyToMembersArray = _ccopyToMembersArray;
            }
            if (_participantsIndexPathArray.count > 0) {
                //((ICMemberTableViewController*)vc).selectedParticipantsDictionary = _participantsIndexPathArray;
            }
            [self.navigationController pushViewController:vc animated:YES];
        //}
        //else
        //{
        //    UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"请先选择参与人!" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        //    [alert show];
        //}
    }
    else if(section == 2 && index == 0)
    {
        //if (_responsibleDic.count > 0) {
            UIStoryboard* mainStory = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
            UIViewController* vc = [mainStory instantiateViewControllerWithIdentifier:@"ICMarkListViewController"];
            ((ICMarkListViewController*)vc).parentControllerType = ParentControllerTypePublishMission;
            ((ICMarkListViewController*)vc).parentController = self;
            
            ((ICMarkListViewController*)vc).selectedMarkArray = _cMarkAarry;
            ((ICMarkListViewController*)vc).workGroupId = self.workGroupId;
            ((ICMarkListViewController*)vc).userId = self.userId;
            
            [self.navigationController pushViewController:vc animated:YES];
        //}
        //else
        //{
        //    UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"请先选择责任人!" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        //    [alert show];
        //}
    }
    else if(section == 2 && index == 1)
    {
        

    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
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
    
    NSIndexPath* indexPath;
    
    if (tag == 11) {
        indexPath = [NSIndexPath indexPathForRow:0 inSection:1];
    }
    else if (tag == 12)
    {
        indexPath = [NSIndexPath indexPathForRow:1 inSection:1];
    }
    
    UITableViewCell* cell = [_tableView cellForRowAtIndexPath:indexPath];
    
    for (UIControl* control in cell.contentView.subviews) {
        if (control.tag == 109) {
            [control removeFromSuperview];
            break;
        }
    }
    
    NSString *strDate = @"";
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    
    if (tag == 11) {
        [dateFormatter setDateFormat:@"yyyy-MM-dd"];
        strDate = [dateFormatter stringFromDate:pickerDate];
        _strFinishTime = strDate;
    }
    else if (tag == 12)
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
            NSComparisonResult  dataCompare= [fdate compare:tdate];
            if (dataCompare != NSOrderedDescending) {
                UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"提醒时间必须在完成时间之后" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                [alert show];
                return;
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
       
    }
    
    UILabel* lbl = [[UILabel alloc] initWithFrame:CGRectMake(110, 12, 200, 20)];
    [lbl setBackgroundColor:[UIColor clearColor]];
    [lbl setTextColor:[UIColor colorWithRed:0.10 green:0.48 blue:0.94 alpha:1.0]];
    [lbl setFont:[UIFont systemFontOfSize:15]];
    [lbl setText:strDate];
    [lbl setTag:109];
    [lbl setTextAlignment:NSTextAlignmentLeft];
    
    [cell.contentView addSubview:lbl];
}

- (void)btnTodayClicked:(id)sender
{
    [_datePicker setDate:[NSDate date]];
}

#pragma mark -
#pragma UIActionSheet Deleget
-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0) {
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
        //UIImage *image = info[@"UIImagePickerControllerOriginalImage"];
        
        [picker dismissViewControllerAnimated:YES completion:nil];
        
        
        
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
        
        //ALAssetRepresentation* representation = [asset defaultRepresentation];
        /*
         CGSize dimension = [representation dimensions];
         UIImage* imgH = [UIImage imageWithCGImage:[representation fullResolutionImage]];
         NSString* filename = [representation filename];
         NSLog(@"filename:%@",filename);
         CGFloat size = [representation size];
         NSDictionary* dic = [representation metadata];
         NSURL* url = [representation url];
         NSLog(@"url:%@",url);
         NSLog(@"uti:%@",[representation UTI]);
         */
        
        if (_accessoryArray == nil) {
            _accessoryArray = [NSMutableArray array];
        }
        
        for (ALAsset* asset in assets)
        {
            BOOL isExits = NO;
            for (ALAsset* acc in _accessoryArray) {
                ALAssetRepresentation* representation = [asset defaultRepresentation];
                ALAssetRepresentation* accRepresentation = [acc defaultRepresentation];
                if ([representation.filename isEqualToString:accRepresentation.filename]) {
                    isExits = YES;
                    break;
                }
            }
            if (!isExits) {
                [_accessoryArray addObject:asset];
            }
        }
        
        if (_accessoryArray.count > 0) {
            UIStoryboard* mainStory = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
            UIViewController* vc = [mainStory instantiateViewControllerWithIdentifier:@"ICFileViewController"];
            ((ICFileViewController *)vc).workGroupId = _workGroupId;
            ((ICFileViewController*)vc).uploadFileArray = _accessoryArray;
            ((ICFileViewController*)vc).hasUploadedFileArray = (_cAccessoryArray == nil? [NSMutableArray array] :[NSMutableArray arrayWithArray:_cAccessoryArray]);
            ((ICFileViewController*)vc).icPublishMissionController = self;
            
            [self.navigationController pushViewController:vc animated:YES];
        }
    }
    
    
}


@end
