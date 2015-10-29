//
//  ICGroupListViewController.m
//  CommonFrame_Pro
//
//  Created by ionitech on 15/6/24.
//  Copyright (c) 2015年 ionitech. All rights reserved.
//

#import "ICGroupListViewController.h"
#import "InputText.h"
#import "UIColor+HexString.h"
#import "Group.h"
#import "UIImageView+UIActivityIndicatorForSDWebImage.h"
#import "MQPublishMissionController.h"

@interface ICGroupListViewController() <UITableViewDataSource,UITableViewDelegate,InputTextDelegate,UITextFieldDelegate>
{
    __weak IBOutlet UITableView* _tableView;
    
    //Search bar
    UILabel*        _lblSearch;
    UITextField*    _txtSearch;
    
    NSArray*        _dataArray;
}

@property (nonatomic,assign) BOOL chang;


@property (nonatomic,strong) NSArray* responsibleDictionary;


@end

@implementation ICGroupListViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    
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
    
    
    if (self.currentViewGroupType == GroupTypeDepartment) {
        [self.navigationItem setTitle:@"群组"];
    }
    else if (self.currentViewGroupType == GroupTypeProject) {
        [self.navigationItem setTitle:@"群组"];
    }
    else if (self.currentViewGroupType == GroupTypeMission) {
        [self.navigationItem setTitle:@"群组"];
        self.responsibleDictionary = self.responsibleDictionaryToPublish;
        
    }
    
    self.loginUserID = [LoginUser loginUserID];
    //_dataArray = [Group getWorkGroupListByUserID:self.loginUserID];
    
    
    //[self.view setBackgroundColor:[UIColor blackColor]];
    _tableView.dataSource = self;
    _tableView.delegate = self;
    
    [_tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    [_tableView setBackgroundColor:[UIColor colorWithHexString:@"#2f2e33"]];
    
    [self setExtraCellLineHidden:_tableView];
    
    CGFloat tableWidth = [UIScreen mainScreen].bounds.size.width;
    
    _tableView.tableHeaderView = ({
        
        UIView* view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableWidth, 45)];
        [view setBackgroundColor:[UIColor colorWithHexString:@"#2f2e33"]];
        
        UIView* searchView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableWidth, 40)];
        [searchView setBackgroundColor: [UIColor clearColor]];
        
        UIImageView* sImageView = [[UIImageView alloc] initWithFrame:CGRectMake(10, 17, 14, 14)];
        [sImageView setBackgroundColor:[UIColor clearColor]];
        [sImageView setImage:[UIImage imageNamed:@"icon_sousuo"]];
        [searchView addSubview:sImageView];
        
        InputText *inputText = [[InputText alloc] init];
        inputText.delegate = self;
        
        _txtSearch = [[UITextField alloc] initWithFrame:CGRectMake(30, 8, tableWidth - 75, 30)];
        [_txtSearch setBackgroundColor:[UIColor orangeColor]];
        [_txtSearch setBorderStyle:UITextBorderStyleNone];
        [_txtSearch setFont:[UIFont systemFontOfSize:17]];
        [_txtSearch setTextColor:[UIColor whiteColor]];
        _txtSearch.returnKeyType = UIReturnKeySearch;
        [_txtSearch addTarget:self action:@selector(textFieldDidChange) forControlEvents:UIControlEventEditingChanged];
        _txtSearch.delegate = self;
        
        _txtSearch = [inputText setupWithIcon:nil  point:nil  textFieldControl:_txtSearch showBottomLine:NO];
        
        _lblSearch = [[UILabel alloc] init];
        _lblSearch.text = @"搜索";
        _lblSearch.font = [UIFont systemFontOfSize:14];
        _lblSearch.textColor = [UIColor grayColor];
        _lblSearch.frame = _txtSearch.frame;
        
        [searchView addSubview:_txtSearch];
        [searchView addSubview:_lblSearch];
        
//        [view addSubview:searchView];

        UILabel* bottomLine = [[UILabel alloc] initWithFrame:CGRectMake(0, 44, [UIScreen mainScreen].bounds.size.width, 0.5)];
        [bottomLine setBackgroundColor:[UIColor grayColor]];
        [view addSubview:bottomLine];
        
        view;
    });
    //[self.navigationController setNavigationBarHidden:NO];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if (_groupId != nil) {
        [self.navigationController popViewControllerAnimated:YES];
    }
    
    NSMutableArray * arr = [NSMutableArray array];
    _dataArray = [Group getWorkGroupListByUserID:self.loginUserID selectArr:&arr];
    [_tableView reloadData];
    
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    //[self.navigationController setNavigationBarHidden:YES];
    
    if (_groupId != nil ) {
        if ([self.icMQPublishViewController respondsToSelector:@selector(setWorkGroupId:)]) {
            [self.icMQPublishViewController setValue:_groupId forKey:@"workGroupId"];

        }
        if ([self.icMQPublishViewController respondsToSelector:@selector(setWorkGroupName:)]) {
            [self.icMQPublishViewController setValue:_groupName forKey:@"workGroupName"];
            
        }
        if ([self.icMQPublishViewController respondsToSelector:@selector(setIsShowAllSection:)]) {
            [self.icMQPublishViewController setValue:@"1" forKey:@"isShowAllSection"];
            
        }
        if ([self.icMQPublishViewController respondsToSelector:@selector(setIsRefreshMarkData:)]) {
            [self.icMQPublishViewController setValue:@"1" forKey:@"isRefreshMarkData"];
        }
        if ([self.icMQPublishViewController respondsToSelector:@selector(setIsChangeGroup:)]) {
            [self.icMQPublishViewController setValue:@"1" forKey:@"isChangeGroup"];
        }
        
    }
    if (_groupId != nil ) {
        if ([self.icMainViewController respondsToSelector:@selector(setPubGroupId:)]) {
            [self.icMainViewController setValue:_groupId forKey:@"pubGroupId"];
        }
    }

    if ([self.icMainViewController respondsToSelector:@selector(setHasCreatedNewGroup:)]) {
        [self.icMainViewController setValue:@"0" forKey:@"hasCreatedNewGroup"];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)backButtonClicked:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark -
#pragma mark Table View Action
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 66;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _dataArray.count;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellId = @"GroupListTableViewCellId";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    if (cell == nil){
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
        
    }
    
    for(UIView *view in cell.contentView.subviews) {
        [view removeFromSuperview];
    }
    
    Group* ms = [_dataArray objectAtIndex:indexPath.row];
    
    UIImageView* imgView = [[UIImageView alloc] initWithFrame:CGRectMake(12, 10, 46, 46)];
    //[imgView setImage:[UIImage imageNamed:@"icon_touxiang"]];
    [imgView setImageWithURL:[NSURL URLWithString:ms.workGroupImg] placeholderImage:[UIImage imageNamed:@"icon_touxiang"] options:SDWebImageDelayPlaceholder usingActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    [cell.contentView addSubview:imgView];
    
    UILabel* lbl = [[UILabel alloc] initWithFrame:CGRectMake(72, 22, 120, 20)];
    lbl.text = ms.workGroupName;
    lbl.textColor = [UIColor whiteColor];
    lbl.font = [UIFont systemFontOfSize:15];
    lbl.backgroundColor = [UIColor clearColor];
    
    [cell.contentView addSubview:lbl];
    
    UILabel* bottomLine = [[UILabel alloc] initWithFrame:CGRectMake(0, 65, [UIScreen mainScreen].bounds.size.width, 0.5)];
    [bottomLine setBackgroundColor:[UIColor grayColor]];
    [cell.contentView addSubview:bottomLine];
    
    cell.tag = indexPath.row;
    
    cell.backgroundColor = [UIColor colorWithHexString:@"#2f2e33"];
    [cell.contentView setBackgroundColor:[UIColor clearColor]];
    
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = (UITableViewCell *)[tableView cellForRowAtIndexPath:indexPath];
    UIView *selectionColor = [[UIView alloc] init];
    selectionColor.backgroundColor = [UIColor cellHoverBackgroundColor];
    cell.selectedBackgroundView = selectionColor;
    
    UILabel* bottomLine = [[UILabel alloc] initWithFrame:CGRectMake(0, 65, [UIScreen mainScreen].bounds.size.width, 0.5)];
    [bottomLine setBackgroundColor:[UIColor grayColor]];
    [cell.selectedBackgroundView addSubview:bottomLine];
    
    return YES;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self restoreTextName:_lblSearch textField:_txtSearch];
    
    UIStoryboard* mainStory = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    UIViewController* vc;
    
    if (self.currentViewGroupType == GroupTypeMission) {
        
//        Group * g = [_dataArray objectAtIndex:indexPath.row];
//
//        self.groupId = g.workGroupId;
//        self.groupName = g.workGroupName;
//        
//        if ([self.icMQPublishViewController respondsToSelector:@selector(setCMarkAarry:)]) {
//            [self.icMQPublishViewController setValue:nil forKey:@"CMarkAarry"];
//            
//        }
//        
//        [self.navigationController popViewControllerAnimated:YES];
        
        vc = [mainStory instantiateViewControllerWithIdentifier:@"ICPublishMissionViewController"];
       
        if (_dataArray.count > 0) {
            Group * g = [_dataArray objectAtIndex:indexPath.row];
           ((ICPublishMissionViewController*)vc).workGroupId = g.workGroupId;
            ((ICPublishMissionViewController*)vc).userId = self.loginUserID;
             ((ICPublishMissionViewController*)vc).icGroupViewController = self;
        }
    }
    else if (self.currentViewGroupType == GroupTypeSharedAndNotify) {
        
        vc = [mainStory instantiateViewControllerWithIdentifier:@"ICPublishSharedAndNotifyViewController"];
        
        if (_dataArray.count > 0) {
            Group * g = [_dataArray objectAtIndex:indexPath.row];
            ((ICPublishSharedAndNotifyViewController*)vc).workGroupId = g.workGroupId;
            ((ICPublishSharedAndNotifyViewController*)vc).userId = self.loginUserID;
             ((ICPublishSharedAndNotifyViewController*)vc).icGroupViewController = self;
        }
        ((ICPublishSharedAndNotifyViewController*)vc).isShared = self.isShared;
    }
    else
    {
        vc = [mainStory instantiateViewControllerWithIdentifier:@"ICGroupDetailViewController"];
        if (_dataArray.count > 0) {
            Group * g = [_dataArray objectAtIndex:indexPath.row];
            ((ICGroupDetailViewController*)vc).group = g;
        }
    }
    
    [self.navigationController pushViewController:vc animated:YES];
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

-(void)setExtraCellLineHidden: (UITableView *)tableView
{
    UIView *view = [UIView new];
    view.backgroundColor = [UIColor clearColor];
    [tableView setTableFooterView:view];
}

#pragma mark - UITextFieldDelegate
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    //[self diminishTextName:_lblSearch];
    
    if (textField == _txtSearch)
    {
        [self diminishTextName:_lblSearch];
        
    }
    return YES;
}
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField == _txtSearch)
    {
        [self restoreTextName:_lblSearch textField:_txtSearch];
        if (textField.text != nil && ![textField.text isEqualToString:@""]) {
            
            NSLog(@"Value:");
            
        }
    }
    
    return YES;
}
- (void)diminishTextName:(UILabel *)label
{
    [UIView animateWithDuration:0.5 animations:^{
        label.transform = CGAffineTransformMakeTranslation(0, -16);
        label.font = [UIFont systemFontOfSize:9];
    }];
}
- (void)restoreTextName:(UILabel *)label textField:(UITextField *)textFieled
{
    [textFieled resignFirstResponder];
    [self textFieldTextChange:textFieled];
    if (self.chang) {
        [UIView animateWithDuration:0.5 animations:^{
            label.transform = CGAffineTransformIdentity;
            label.font = [UIFont systemFontOfSize:16];
        }];
    }
}
- (void)textFieldTextChange:(UITextField *)textField
{
    if (textField.text.length != 0) {
        self.chang = NO;
    } else {
        self.chang = YES;
    }
}
- (void)textFieldDidChange
{
    
}

#pragma mark - touchesBegan
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.view endEditing:YES];
    [self restoreTextName:_lblSearch textField:_txtSearch];
}


@end
