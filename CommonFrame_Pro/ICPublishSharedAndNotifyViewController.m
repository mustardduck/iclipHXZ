//
//  ICPublishSharedAndNotifyViewController.m
//  CommonFrame_Pro
//
//  Created by ionitech on 15/6/23.
//  Copyright (c) 2015年 ionitech. All rights reserved.
//

#import "ICPublishSharedAndNotifyViewController.h"
#import "UIImageView+UIActivityIndicatorForSDWebImage.h"
#import "PH_UITextView.h"
#import "UICommon.h"
//#import <AVOSCloud/AVOSCloud.h>

@interface ICPublishSharedAndNotifyViewController() <ZYQAssetPickerControllerDelegate, UITableViewDataSource,UITableViewDelegate,UIActionSheetDelegate,UINavigationControllerDelegate,UIImagePickerControllerDelegate,UITextViewDelegate>
{
    UITableView*               _tableView;
    NSMutableArray*            _accessoryArray;
    NSMutableArray*            _fileAccessoryArr;
    PH_UITextView*                _txtContent;
    UITextField*             _titleText;
    BOOL                       _btnDoneClicked;
}


@end

@implementation ICPublishSharedAndNotifyViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //[self.navigationItem.backBarButtonItem setImage:[UIImage imageNamed:@"btn_fanhui"]];
    
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
    
    UIBarButtonItem* rarButton = [[UIBarButtonItem alloc] initWithTitle:@"完成" style:UIBarButtonItemStyleDone target:self action:@selector(btnDoneClicked:)];
    [rarButton setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor whiteColor],NSFontAttributeName:[UIFont systemFontOfSize:17]} forState:UIControlStateNormal];
    self.navigationItem.rightBarButtonItem = rarButton;
    
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height)];
    _tableView.backgroundColor = [UIColor colorWithRed:0.15f green:0.15f blue:0.15f alpha:1.0f];
    _tableView.dataSource = self;
    _tableView.delegate = self;
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
    
    if (_isShared == 1) {
        self.navigationItem.title = @"问题";
    }
    else if (_isShared == 2)
    {
        self.navigationItem.title = @"建议";
    }
    else if (_isShared == 3)
    {
        self.navigationItem.title = @"其它";
    }

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
        [self.icDetailViewController setValue:@"2" forKey:@"content"];
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
    
    if (self.ccopyToMembersArray != nil)
    {
        NSLog(@"%@",self.ccopyToMembersArray);
        
        NSIndexPath* indexPath = [NSIndexPath indexPathForRow:(NSInteger)0 inSection:(NSInteger)0];
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
        
        NSIndexPath* indexPath = [NSIndexPath indexPathForRow:(NSInteger)0 inSection:(NSInteger)1];
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
    
    if (self.cAccessoryArray != nil){
        NSLog(@"%@",self.cAccessoryArray);
        
        NSIndexPath* indexPath = [NSIndexPath indexPathForRow:1 inSection:1];
        
        UITableViewCell* cell = [_tableView cellForRowAtIndexPath:indexPath];
        CGRect frame;
        
        for (UIControl* control in cell.contentView.subviews) {
            if ([control isKindOfClass:[UIButton class]]) {
                if (control.tag == 2022) {
                    frame = control.frame;
                    control.frame = CGRectMake(20 + (frame.size.width + 10) * (_cAccessoryArray.count) , frame.origin.y, frame.size.width, frame.size.height);
                    
                }
            }
        }
        
        for (int i = 0;i < _cAccessoryArray.count; i++)
        {
//            ALAsset* ass = [_accessoryArray objectAtIndex:i];
//            ALAssetRepresentation* representation = [ass defaultRepresentation];
//            UIImage* imgH = [UIImage imageWithCGImage:[representation fullResolutionImage]];
//            
//            UIButton* btnAccessory = [[UIButton alloc] initWithFrame:CGRectMake( 20 + (frame.size.width * i) + (10 * i), frame.origin.y, frame.size.width, frame.size.height)];
//            [btnAccessory setImage:imgH forState:UIControlStateNormal];
//            [btnAccessory.layer setBorderWidth:0.5f];
//            [btnAccessory.layer setBorderColor:[[UIColor grayColor] CGColor]];
//            //[btnAccessory addTarget:self action:@selector(btnAccessoryClicked:) forControlEvents:UIControlEventTouchUpInside];
//            //btnAccessory.tag = 2022;
//            [cell.contentView addSubview:btnAccessory];
            
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

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)btnBackButtonClicked:(id)sender
{
    [_txtContent resignFirstResponder];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)btnDoneClicked:(id)sender
{
    [_txtContent resignFirstResponder];
    if (_txtContent.text == nil || [_txtContent.text isEqualToString:@""]) {
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"请输入内容！" delegate:self
                                              cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
        [_txtContent becomeFirstResponder];
        return;
    }
    
    if (_ccopyToMembersArray.count == 0) {
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"请选择可见范围！" delegate:self
                                              cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
        return;
    }
    
    if (_cMarkAarry.count == 0) {
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"请选择所属标签！" delegate:self
                                              cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
        return;
    }
    
    Mission* m = [Mission new];
    
    m.createUserId = [LoginUser loginUserID];
    m.workGroupId = self.workGroupId;
    m.main = _txtContent.text;
    m.title = _titleText.text;
     //1: 问题  2：建议  3：其它
    if (_isShared == 1)
        m.type = TaskTypeShare;
    else if(_isShared == 2)
    {
        m.type = TaskTypeJianYi;
    }
    else if (_isShared == 3)
    {
        m.type = TaskTypeNoitification;
    }
    if (_taskId != nil) {
        m.taskId = _taskId;
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
        BOOL isSendOK = [m sendMission:NO taksId:&taskId];
        
        if (isSendOK) {
            /*
            AVQuery *pushQuery = [AVInstallation query];
            
            long long usId = 0;
            
            NSMutableArray * userArr = [NSMutableArray array];
            
            for(int i = 0; i < m.cclist.count; i ++)
            {
                usId = [m.cclist[i] longLongValue];
                [userArr addObject:@(usId)];//抄送人
            }
            
            [pushQuery whereKey:@"HXZ_userId" containedIn:userArr];
            
            NSString * typeStr = @"";
            
            if(m.type == 2)
            {
                typeStr = @"问题";
            }
            else if (m.type == 8)
            {
                typeStr = @"建议";
            }
            else if (m.type == 3)
            {
                typeStr = @"其它";
            }
            
            [self AVpush:taskId pushQuery:pushQuery typeStr:typeStr];
            */
            
            UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"成功" message:@"发布成功！" delegate:self
                                                  cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            [alert show];
            
            _btnDoneClicked = YES;
            [self.navigationController popViewControllerAnimated:YES];
        }
        else
        {
            UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"发布失败！" delegate:self
                                                  cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            [alert show];
        }
    });
    
    
}

/*
- (void) AVpush:(NSString *)taskId pushQuery:(AVQuery *)pushQuery typeStr:(NSString *)typeStr
{
    NSString * alertStr = [NSString stringWithFormat:@"%@ 发布了%@，需要你查看", [LoginUser loginUserName], typeStr];
    
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
        return 1;
    }
    else if (section == 1) {
        return 2;
    }
    
    return 0;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
        return nil;
    }
    
    return @"  ";
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 1 && indexPath.row == 1){
        return 60;
    }
    
    if (indexPath.row == 0 && indexPath.section == 0) {
        
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
    else if (indexPath.row == 0 && indexPath.section == 1) {
        
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

- (UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView* vi = [UIView new];
    UILabel* line2 = [[UILabel alloc] initWithFrame:CGRectMake(0, 1, [UIScreen mainScreen].bounds.size.width, 0.5)];
    [line2 setBackgroundColor:[UIColor grayColor]];
    [vi addSubview:line2];
    [vi setBackgroundColor:[UIColor clearColor]];
  
    return vi;
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
    else if (section == 1 && index == 1) {
        UILabel* line2 = [[UILabel alloc] initWithFrame:CGRectMake(0, 1, tableWidth, 0.5)];
        [line2 setBackgroundColor:[UIColor grayColor]];
        [cell.selectedBackgroundView addSubview:line2];
    }
    return YES;
}


-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"SharedAndNotifyCellIdentitifer";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];

    if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    NSInteger index = indexPath.row;
    NSInteger section = indexPath.section;
    CGFloat tableWidth = [UIScreen mainScreen].bounds.size.width;
    //CGFloat cellHeight = [self tableView:tableView heightForRowAtIndexPath:indexPath];
    
    
    UIImageView* photo = [[UIImageView alloc] initWithFrame:CGRectMake(20, 12, 17, 20)];
    [photo setBackgroundColor:[UIColor clearColor]];
    
    UILabel* lblText = [[UILabel alloc] initWithFrame:CGRectMake(50, 12, 100, 22)];
    [lblText setBackgroundColor:[UIColor clearColor]];
    [lblText setTextColor:[UIColor whiteColor]];
    [lblText setFont:[UIFont systemFontOfSize:14]];
    [lblText setTextAlignment:NSTextAlignmentLeft];
    
    if (section == 0 && index == 0) {
        UILabel* line1 = [[UILabel alloc] initWithFrame:CGRectMake(0, 1, tableWidth, 0.5)];
        [line1 setBackgroundColor:[UIColor grayColor]];
        [cell.contentView addSubview:line1];
        
        [photo setFrame:CGRectMake(20, 15, 16, 16)];
        [photo setImage:[UIImage imageNamed:@"icon_kejian"]];
        [lblText setText:@"可见范围"];
    }
    else if (section == 1 && index == 0) {
        UILabel* line2 = [[UILabel alloc] initWithFrame:CGRectMake(0, 1, tableWidth, 0.5)];
        [line2 setBackgroundColor:[UIColor grayColor]];
        [cell.contentView addSubview:line2];
        
        [photo setFrame:CGRectMake(20, 15, 17, 15)];
        [photo setImage:[UIImage imageNamed:@"btn_renwu_6"]];
        [lblText setText:@"添加标签"];
    }
    else if (section == 1 && index == 1) {
         [photo setFrame:CGRectMake(20, 15, 34, 34)];
        [photo setImage:[UIImage imageNamed:@"btn_fujian"]];
        [lblText setText:@"添加附件"];
        
        UILabel* line2 = [[UILabel alloc] initWithFrame:CGRectMake(0, 1, tableWidth, 0.5)];
        [line2 setBackgroundColor:[UIColor grayColor]];
        [cell.contentView addSubview:line2];
        
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
    
    
    [cell.contentView addSubview:photo];
    
    
    if (!(section == 1 && index == 1)){
        
        [cell.contentView addSubview:lblText];
        
        
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
    
    cell.backgroundColor = [UIColor colorWithRed:0.15f green:0.15f blue:0.15f alpha:1.0f];
    cell.contentView.backgroundColor = [UIColor colorWithRed:0.15f green:0.15f blue:0.15f alpha:1.0f];
    
    
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
    if (indexPath.section == 0 && indexPath.row == 0){
    
        UIStoryboard* mainStory = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        UIViewController* vc = [mainStory instantiateViewControllerWithIdentifier:@"ICMemberTableViewController"];
        ((ICMemberTableViewController*)vc).controllerType = MemberViewFromControllerCopyTo;
        ((ICMemberTableViewController*)vc).icPublishMisonController = self;
        ((ICMemberTableViewController*)vc).workgid = _workGroupId;
        ((ICMemberTableViewController*)vc).isKJFW = YES;

        if (_ccopyToMembersArray.count > 0) {
            ((ICMemberTableViewController*)vc).selectedCopyToMembersArray = _ccopyToMembersArray;
        }
        [self.navigationController pushViewController:vc animated:YES];
    }
    else if(indexPath.section == 1 && indexPath.row == 0)
    {
        UIStoryboard* mainStory = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        UIViewController* vc = [mainStory instantiateViewControllerWithIdentifier:@"ICMarkListViewController"];
        ((ICMarkListViewController*)vc).parentControllerType = ParentControllerTypePublishMission;
        ((ICMarkListViewController*)vc).parentController = self;
        
        ((ICMarkListViewController*)vc).selectedMarkArray = _cMarkAarry;
        ((ICMarkListViewController*)vc).workGroupId = self.workGroupId;
        ((ICMarkListViewController*)vc).userId = self.userId;
        
        [self.navigationController pushViewController:vc animated:YES];
       
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
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
        picker.maximumNumberOfSelection = 5;
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
