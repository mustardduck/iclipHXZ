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

@interface MQPublishMissionMainController ()<UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate,UITextViewDelegate>
{
//    NSInteger _dataCount;
    
    UIView * _currentView;
    
    BOOL _isMainMission;
    
    BOOL _isEditChildMission;
    
    NSInteger _currentEditChildIndex;
    
//    NSMutableArray * _titleNameList;
}

@property (strong, nonatomic) IBOutlet UITableView *mainTableView;
@property (weak, nonatomic) IBOutlet UIView *topTxtView;
@property (weak, nonatomic) IBOutlet PH_UITextView *mainTextView;
@property (weak, nonatomic) IBOutlet UIView *rightTxtView;
@property (weak, nonatomic) IBOutlet UIButton *rightTxtBtn;
@property (weak, nonatomic) IBOutlet UIView *jiaView;


@end

@implementation MQPublishMissionMainController

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
    
    [self.view setBackgroundColor:[UIColor backgroundColor]];
    
    [self setHeaderView];
    
    
    self.childMissionArr = [NSMutableArray array];
    
    _mainMissionDic = [NSMutableDictionary dictionary];
    
//    _dataCount = 1;
}

- (void) textViewDidBeginEditing:(UITextView *)textView
{
    _rightTxtView.hidden = NO;
    
    _currentView = _mainTextView;
    
    _jiaView.hidden = YES;
}

- (void) setHeaderView
{
    [_topTxtView setRoundColorCorner:5.0 withColor:[UIColor grayLineColor]];
    [_rightTxtBtn addTarget:self action:@selector(rightBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    _rightTxtBtn.tag = 99;
    [_mainTextView setPlaceholder:@"请编写任务标题!"];
    
    [self addDoneToKeyboard:_mainTextView];
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
        if(_mainTextView.text.length)
        {
            [_mainMissionDic setObject:_mainTextView.text forKey:@"title"];
        }
        
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
    ((MQPublishMissionController*)vc).missionDic = dic;
    ((MQPublishMissionController*)vc).isEditChildMission = _isEditChildMission;
    ((MQPublishMissionController*)vc).currentEditChildIndex = _currentEditChildIndex;

    [self.navigationController pushViewController:vc animated:YES];
    
}

- (IBAction)btnBackButtonClicked:(id)sender
{
//    [self hiddenKeyboard];
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)btnDoneButtonClicked:(id)sender
{
    NSLog(@"%@",_childMissionArr);
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
                line2 = [[UIView alloc] initWithFrame:CGRectMake(27, 35.5, 13, 0.5)];
                line2.backgroundColor = [UIColor grayLineColor];
                line2.tag = 2;
            }
            [cell.contentView addSubview:line2];
            
            //        cell.addBtn.tag = 2222;
            
            [cell.addBtn addTarget:self action:@selector(addMissionCell:) forControlEvents:UIControlEventTouchUpInside];
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
                line2 = [[UIView alloc] initWithFrame:CGRectMake(27, 35.5, 13, 0.5)];
                line2.backgroundColor = [UIColor grayLineColor];
                line2.tag = 2;
            }
            [cell.contentView addSubview:line2];
            
            [self addDoneToKeyboard:cell.titleLbl];
            
            [cell.rightBtn addTarget:self action:@selector(rightBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
            cell.rightBtn.tag = tag + 100;
            
            NSDictionary * dic = _childMissionArr[indexPath.row];
            
            if(dic)
            {
                cell.titleLbl.text = [dic valueForKey:@"title"];
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
            line2 = [[UIView alloc] initWithFrame:CGRectMake(27, 35.5, 13, 0.5)];
            line2.backgroundColor = [UIColor grayLineColor];
            line2.tag = 2;
        }
        [cell.contentView addSubview:line2];
        
        //        cell.addBtn.tag = 2222;
        
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
    }
}

- (void) textFieldDidEndEditing:(UITextField *)textField
{
    NSInteger index = textField.tag - 100;
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

- (void) hiddenKeyboard
{
    [_currentView resignFirstResponder];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

}

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
        [_childMissionArr removeObjectAtIndex:indexPath.row];
        [tableView reloadData];
        
    }
}

- (void) viewWillAppear:(BOOL)animated
{
    if(_mainMissionDic)
    {
        _mainTextView.text = [_mainMissionDic valueForKey:@"title"];
    }
    if(_childMissionArr.count)
    {
        [_mainTableView reloadData];
    }
}


- (void) addMissionCell:(id)sender
{
//    _dataCount ++;
    NSMutableDictionary * dic = [NSMutableDictionary dictionary];
    [dic setObject:@"" forKey:@"title"];

    [_childMissionArr addObject:dic];
    
    [_mainTableView reloadData];
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
