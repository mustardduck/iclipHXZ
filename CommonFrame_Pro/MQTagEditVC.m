//
//  MQTagEditVC.m
//  CommonFrame_Pro
//
//  Created by 倩 莫 on 16/2/2.
//  Copyright © 2016年 ionitech. All rights reserved.
//

#import "MQTagEditVC.h"
#import "UICommon.h"
#import "SVProgressHUD.h"
#import "LoginUser.h"
#import "Mark.h"
#import "UIImageView+UIActivityIndicatorForSDWebImage.h"

@interface MQTagEditVC ()<UIAlertViewDelegate,UITextFieldDelegate>
{
    __weak IBOutlet UITableView* _tableView;
    NSArray*        _dataArray;
    NSMutableArray*         _selectedIndexList;
    NSMutableArray*         _selectedTagList;

    BOOL _isEdit;
    
    UIBarButtonItem* _rightBarButton;
    
    NSIndexPath * _currentIndexPath;
}

@property (weak, nonatomic) IBOutlet UIImageView *wgImgView;

@property (weak, nonatomic) IBOutlet UILabel *wgNameLbl;
@property (weak, nonatomic) IBOutlet UIButton *addTagBtn;
@property (weak, nonatomic) IBOutlet UITextField *addTagTxt;

@end

@implementation MQTagEditVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _addTagTxt.returnKeyType = UIReturnKeyDone;
    [self addDoneToKeyboard:_addTagTxt];
    
    
    UIButton *leftButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 70, 20)];
    [leftButton addTarget:self action:@selector(backButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
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
    
    self.navigationItem.title = @"标签列表";
    
    if(_canEdit)
    {
        _rightBarButton = [[UIBarButtonItem alloc] initWithTitle:@"编辑" style:UIBarButtonItemStyleDone target:self action:@selector(btnDoneButtonClicked:)];
        [_rightBarButton setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor whiteColor],NSFontAttributeName:[UIFont systemFontOfSize:17]} forState:UIControlStateNormal];
        self.navigationItem.rightBarButtonItem = _rightBarButton;
    }
    
    _addTagBtn.hidden = !_canCreate;
    
    _tableView.dataSource = self;
    _tableView.delegate = self;
    
    [_tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    [_tableView setBackgroundColor:[UIColor backgroundColor]];
    
    NSMutableArray * arr = [NSMutableArray array];
    _dataArray = [Mark getMarkListByWorkGroupID:_workGroup.workGroupId loginUserID:[LoginUser loginUserID] andUrl:CURL selectArr:&arr];
    if(arr.count)
    {
        _selectedIndexList = arr;
    }
    
    [_wgImgView setImageWithURL:[NSURL URLWithString:_workGroup.workGroupImg] placeholderImage:[UIImage imageNamed:@"icon_touxiang"] options:SDWebImageDelayPlaceholder usingActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    [_wgImgView setRoundCorner:3.3];
    _wgNameLbl.text = _workGroup.workGroupName;
    
    _selectedTagList = [[NSMutableArray alloc] init];

    [_tableView reloadData];
    
}

- (void) hiddenKeyboard
{
    [_addTagTxt resignFirstResponder];
}

- (void) textFieldDidEndEditing:(UITextField *)textField
{
    if (textField.text == nil || [textField.text isEqualToString:@""]) {
//        [SVProgressHUD showErrorWithStatus:@"请输入需要录入的内容!"];
        return;
    }

    dispatch_async(dispatch_get_main_queue(), ^{
        
        BOOL isOk = [Mark createNewMark:textField.text workGroupID:_workGroup.workGroupId];
        if (isOk) {
            NSMutableArray * arr = [NSMutableArray array];
            _dataArray = [Mark getMarkListByWorkGroupID:_workGroup.workGroupId loginUserID:[LoginUser loginUserID] andUrl:CURL selectArr:&arr];
            if(arr.count)
            {
                _selectedIndexList = arr;
            }
            
            [_tableView reloadData];
            
            _addTagTxt.text = @"";
            _addTagTxt.hidden = YES;
            _addTagBtn.hidden = NO;
        }
        
    });

}

- (BOOL) textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    
    return YES;
}

- (IBAction)addTagBtnClicked:(id)sender {
    
    _addTagBtn.hidden = YES;
    
    _addTagTxt.hidden = NO;
    
    [_addTagTxt becomeFirstResponder];
}

- (void)btnDoneButtonClicked:(id)sender
{
    if(!_isEdit)
    {
        [_rightBarButton setTitle:@"完成"];
    }
    else
    {
        [_rightBarButton setTitle:@"编辑"];
    }
    _isEdit = !_isEdit;
    
    [_tableView reloadData];

}

- (IBAction)backButtonClicked:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(alertView.tag == 100)
    {
        if(buttonIndex == 1)
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                
                Mark * mark = _dataArray[_currentIndexPath.row];
                
                BOOL isOK = [Mark remove:mark.labelId workGroupId:_workGroup.workGroupId];
                if (isOK) {
                    
                    NSMutableArray * arr = [NSMutableArray arrayWithArray:_dataArray];
                    
                    [arr removeObjectAtIndex:_currentIndexPath.row];
                    
                    _dataArray = arr;
                    
                    [_tableView reloadData];
                }
                else
                {
                    [SVProgressHUD showErrorWithStatus:@"标签删除失败,请稍后再试"];
                }
                
            });
        }
    }
    else
    {
        //得到输入框
        UITextField *tf=[alertView textFieldAtIndex:0];
        if(buttonIndex == 1)
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                
                Mark * mark = _dataArray[_currentIndexPath.row];
                
                BOOL isOK = [Mark update:mark.labelId labelName:tf.text];
                if (isOK) {
                    
                    NSMutableArray * arr = [NSMutableArray arrayWithArray:_dataArray];
                    
                    Mark * m = arr[_currentIndexPath.row];
                    
                    m.labelName = tf.text;
                    
                    [arr replaceObjectAtIndex:_currentIndexPath.row withObject:m];
                    
                    _dataArray = arr;
                    
                    [_tableView reloadData];

                }
                
            });
        }
    }
    
}

- (void) delClicked:(id)sender
{
    UIView *v = [sender superview];//获取父类view（鼠标点击）
    UITableViewCell *cell = (UITableViewCell *)[v superview];//获取cell
    NSIndexPath *indexPath = [_tableView indexPathForCell:cell];//获取cell对应的section
    
    Mark* ms = [_dataArray objectAtIndex:indexPath.row];
    
    _currentIndexPath = indexPath;

    UIAlertView *  atView = [[UIAlertView alloc] initWithTitle:@"删除标签" message:nil delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确认", nil];
    atView.tag = 100;
    [atView show];
}

- (void) editClicked:(id)sender
{
    UIView *v = [sender superview];//获取父类view（鼠标点击）
    UITableViewCell *cell = (UITableViewCell *)[v superview];//获取cell
    NSIndexPath *indexPath = [_tableView indexPathForCell:cell];//获取cell对应的section
    
    Mark* ms = [_dataArray objectAtIndex:indexPath.row];

    _currentIndexPath = indexPath;

    UIAlertView *  atView = [[UIAlertView alloc] initWithTitle:@"修改标签" message:nil delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确认", nil];
    atView.alertViewStyle = UIAlertViewStylePlainTextInput;
    
    UITextField *tf = [atView textFieldAtIndex:0];
    tf.textAlignment = NSTextAlignmentCenter;
    tf.text = ms.labelName;
    

    [atView show];
}

- (void) mainLabelClicked:(id)sender
{
    UIButton *mainLableBtn = (UIButton *) sender;
    
    UIView *v = [sender superview];//获取父类view（鼠标点击）
    UITableViewCell *cell = (UITableViewCell *)[v superview];//获取cell
    NSIndexPath *indexPath = [_tableView indexPathForCell:cell];//获取cell对应的section
    
    Mark* ms = [_dataArray objectAtIndex:indexPath.row];
    
    BOOL switchStatus = NO;
    
    if(![mainLableBtn.titleLabel.text isEqualToString:@"取消"])
    {
        switchStatus = YES;
    }
    
    if(switchStatus)
    {
        [self addIndexPathToCopyToArray:indexPath andArray:_selectedIndexList];
        
        [self addIndexPathToCopyToArray:indexPath andArray:_selectedTagList];
        
    }
    else
    {
        [self removeIndexPathFromCopyToArray:indexPath andArray:_selectedIndexList];
        
        [self removeIndexPathFromCopyToArray:indexPath andArray:_selectedTagList];
    }
    
    BOOL isOk = [Mark updateLabelMainWork:ms.labelId isMainLabel:switchStatus];
    
    if(isOk)
    {
        NSString * str = @"已设为主要工作";
        
        UIButton * btn = [cell viewWithTag:1111];
        
        if(btn)
        {
            [btn setTitle:@"取消" forState:UIControlStateNormal];

            if(!switchStatus)
            {
                str = @"取消成功";
                
                [btn setTitle:@"设为主要工作" forState:UIControlStateNormal];
                
            }
        }

        [SVProgressHUD showSuccessWithStatus:str];
    }
    else
    {
        UIButton * btn = [cell viewWithTag:1111];
        
        if(btn)
        {
            [btn setTitle:@"设为主要工作" forState:UIControlStateNormal];
        }
        
        [SVProgressHUD showSuccessWithStatus:@"主要工作设置失败"];
        
    }

}

#pragma mark -
#pragma mark Table View Action
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if((SCREENWIDTH == 320 || SCREENWIDTH == 375) && _isEdit)
    {
        return 80;
    }
    return 60;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _dataArray.count;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellId = @"GroupMainLabelSettingCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    if (cell == nil){
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
        
    }
    
    for(UIView *view in cell.contentView.subviews) {
        [view removeFromSuperview];
    }
    
    Mark* ms = [_dataArray objectAtIndex:indexPath.row];
    
    UILabel* lbl = [[UILabel alloc] initWithFrame:CGRectMake(14, 9, SCREENWIDTH - 28, 18)];
    lbl.text = ms.labelName;
    lbl.textColor = [UIColor whiteColor];
    lbl.font = Font(15);
    lbl.backgroundColor = [UIColor clearColor];
    [cell.contentView addSubview:lbl];
    
    UIImageView * mainIcon = [[UIImageView alloc] initWithFrame:CGRectMake(14, 13, 8, 11)];
    mainIcon.image = [UIImage imageNamed:@"icon_zhuyaogongzu"];
    
    if((SCREENWIDTH == 320 || SCREENWIDTH == 375) && _isEdit)
    {
        UILabel* usedCountLbl = [[UILabel alloc] initWithFrame:CGRectMake(14, lbl.bottom + 2, SCREENWIDTH - 28 - 216, 18)];
        usedCountLbl.text = [NSString stringWithFormat:@"被使用 %@", ms.labelNum];
        usedCountLbl.textColor = [UIColor grayTitleColor];
        usedCountLbl.font = Font(12);
        usedCountLbl.backgroundColor = [UIColor clearColor];
        [cell.contentView addSubview:usedCountLbl];
        
        usedCountLbl = [[UILabel alloc] initWithFrame:CGRectMake(14, usedCountLbl.bottom + 2, SCREENWIDTH - 28 - 216, 18)];
        usedCountLbl.text = [NSString stringWithFormat:@"%@ 创建", ms.createName];
        usedCountLbl.textColor = [UIColor grayTitleColor];
        usedCountLbl.font = Font(12);
        usedCountLbl.backgroundColor = [UIColor clearColor];
        [cell.contentView addSubview:usedCountLbl];
    }
    else
    {
        UILabel* usedCountLbl = [[UILabel alloc] initWithFrame:CGRectMake(14, lbl.bottom + 2, 96, 18)];
        usedCountLbl.text = [NSString stringWithFormat:@"被使用 %@", ms.labelNum];
        usedCountLbl.textColor = [UIColor grayTitleColor];
        usedCountLbl.font = Font(12);
        usedCountLbl.backgroundColor = [UIColor clearColor];
        [cell.contentView addSubview:usedCountLbl];
        
        usedCountLbl = [[UILabel alloc] initWithFrame:CGRectMake(111, lbl.bottom + 2, 82, 18)];
        usedCountLbl.text = [NSString stringWithFormat:@"%@ 创建", ms.createName];
        usedCountLbl.textColor = [UIColor grayTitleColor];
        usedCountLbl.font = Font(12);
        usedCountLbl.backgroundColor = [UIColor clearColor];
        [cell.contentView addSubview:usedCountLbl];
        
    }

    
    UIButton * delBtn;
    UIButton * editBtn;
    UIButton * mainLabelBtn;
    
    if(_isEdit)
    {
        delBtn = [[UIButton alloc] initWithFrame:CGRectMake(SCREENWIDTH - 14 - 48, 15, 48, 31)];
        [delBtn setTitle:@"删除" forState:UIControlStateNormal];
        [delBtn setRoundColorCorner:3.3 withColor:[UIColor grayLineColor]];
        [delBtn setBackgroundColor:[UIColor clearColor]];
        [delBtn addTarget:self action:@selector(delClicked:) forControlEvents:UIControlEventTouchUpInside];
        [delBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        delBtn.titleLabel.font = Font(12);
        
        editBtn = [[UIButton alloc] initWithFrame:CGRectMake(X(delBtn) - 14 - 48, 15, 48, 31)];
        [editBtn setTitle:@"修改" forState:UIControlStateNormal];
        [editBtn setRoundColorCorner:3.3 withColor:[UIColor grayLineColor]];
        [editBtn setBackgroundColor:[UIColor clearColor]];
        [editBtn addTarget:self action:@selector(editClicked:) forControlEvents:UIControlEventTouchUpInside];
        [editBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        editBtn.titleLabel.font = Font(12);

        
        mainLabelBtn = [[UIButton alloc] initWithFrame:CGRectMake(X(editBtn) - 14 - 86, 15, 86, 31)];
        NSString * title = @"设为主要工作";
        mainLabelBtn.tag = 1111;
        
        if(!_selectedIndexList.count)
        {
            if(ms.isHave)
            {
                title = @"取消";
                
                [cell.contentView addSubview:mainIcon];
                lbl.left = XW(mainIcon) + 7;
                
                [_selectedTagList addObject:ms];

            }
        }
  
        [mainLabelBtn setTitle:title forState:UIControlStateNormal];
        [mainLabelBtn setRoundColorCorner:3.3 withColor:[UIColor grayLineColor]];
        [mainLabelBtn setBackgroundColor:[UIColor clearColor]];
        [mainLabelBtn addTarget:self action:@selector(mainLabelClicked:) forControlEvents:UIControlEventTouchUpInside];
        [mainLabelBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        mainLabelBtn.titleLabel.font = Font(12);
        
        
        if((SCREENWIDTH == 320 || SCREENWIDTH == 375))
        {
            delBtn.top = 25;
            
            editBtn.top = delBtn.top;
            
            mainLabelBtn.top = delBtn.top;
        }
        
        [cell.contentView addSubview:delBtn];
        [cell.contentView addSubview:editBtn];
        [cell.contentView addSubview:mainLabelBtn];

    }
    
    
    UILabel* bottomLine = [[UILabel alloc] initWithFrame:CGRectMake(0, 60 - 0.5, [UIScreen mainScreen].bounds.size.width, 0.5)];
    [bottomLine setBackgroundColor:[UIColor grayColor]];
    
    if((SCREENWIDTH == 320 || SCREENWIDTH == 375) && _isEdit)
    {
        bottomLine.top = 80 - 0.5;
    }
    
    [cell.contentView addSubview:bottomLine];
    
    cell.tag = indexPath.row;
    
    cell.backgroundColor = [UIColor grayMarkColor];
    [cell.contentView setBackgroundColor:[UIColor clearColor]];
    

    
    
    for(Mark * me in _selectedIndexList)
    {
        if(ms.labelId == me.labelId)
        {
            [mainLabelBtn setTitle:@"取消" forState:UIControlStateNormal];
            
            [cell.contentView addSubview:mainIcon];
            lbl.left = XW(mainIcon) + 7;
            
            break;
        }
    }
    
    for(Mark * me in _selectedTagList)
    {
        if(ms.labelId == me.labelId)
        {
            [mainLabelBtn setTitle:@"取消" forState:UIControlStateNormal];
            
            [cell.contentView addSubview:mainIcon];
            lbl.left = XW(mainIcon) + 7;
            
            break;
        }
    }
    
    return cell;
}

- (void)addIndexPathToCopyToArray:(NSIndexPath*)indexPath andArray:(NSMutableArray *)selectedArray
{
    NSInteger row = indexPath.row;
    
    BOOL isEx = NO;
    
    Mark* me = _dataArray[row];
    
    if (selectedArray.count > 0) {
        for (Mark* ip in _selectedIndexList) {
            if (ip.labelId == me.labelId) {
                isEx = YES;
                break;
            }
        }
        if (!isEx) {
            [selectedArray addObject:me];
        }
    }
    else{
        [selectedArray addObject:me];
    }
}

- (void)removeIndexPathFromCopyToArray:(NSIndexPath*)indexPath andArray:(NSMutableArray *)selectedArray
{
    NSInteger row = indexPath.row;
    
    Mark* me = _dataArray[row];
    
    if (selectedArray.count > 0) {
        for (Mark* ip in _selectedIndexList) {
            if (ip.labelId == me.labelId) {
                [_selectedIndexList removeObject:ip];
                break;
            }
        }
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 30;
}

- (UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView* myView = [[UIView alloc] init];
    myView.backgroundColor = [UIColor backgroundColor];
    
    UIView * titleView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREENWIDTH, 30)];
    titleView.backgroundColor = [UIColor clearColor];//
    [myView addSubview:titleView];
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(14, 0, 200, 30)];
    titleLabel.textColor=[UIColor whiteColor];
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.font = Font(15);
    
    titleLabel.text= @"可分配下列权限";
    [titleView addSubview:titleLabel];
    
    return myView;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

}

@end
