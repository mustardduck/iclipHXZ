//
//  ICMarkListViewController.m
//  CommonFrame_Pro
//
//  Created by ionitech on 15/6/26.
//  Copyright (c) 2015年 ionitech. All rights reserved.
//

#import "ICMarkListViewController.h"
#import "UIColor+HexString.h"
#import "Mark.h"

@interface ICMarkListViewController()<UITableViewDataSource,UITableViewDelegate>
{
    __weak IBOutlet UITableView*        _tableView;
                    NSArray*            _markList;
    NSMutableArray*     _selectedMarkArray;
    BOOL                _isDone;
    NSMutableArray*     _tmpData;
}

@end

@implementation ICMarkListViewController

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
    
    if (self.parentControllerType == ParentControllerTypePublishMission) {
        UIBarButtonItem* rightBarButton = [[UIBarButtonItem alloc] initWithTitle:@"完成" style:UIBarButtonItemStyleDone target:self action:@selector(btnDoneClicked:)];
        [rightBarButton setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor whiteColor],NSFontAttributeName:[UIFont systemFontOfSize:17]} forState:UIControlStateNormal];
        self.navigationItem.rightBarButtonItem = rightBarButton;
    }
    
    
    self.userId = [LoginUser loginUserID];
    if(self.workGroupId != nil)
        _markList = [Mark getMarkListByWorkGroupID:self.workGroupId loginUserID:self.userId];
    
    _tableView.dataSource = self;
    _tableView.delegate = self;
    [_tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    
    [self setExtraCellLineHidden:_tableView];
    
    if (_selectedMarkArray.count > 0) {
        _tmpData = [NSMutableArray arrayWithArray:_selectedMarkArray];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    
    if(self.parentControllerType == ParentControllerTypePublishMission)
    {
        if ([self.parentController respondsToSelector:@selector(setCMarkAarry:)]) {
            if (!_isDone) {
                _selectedMarkArray = [NSMutableArray arrayWithArray:_tmpData];
            }
            [self.parentController setValue:_selectedMarkArray forKey:@"cMarkAarry"];
        }
        
    }
    
}
- (void)btnDoneClicked:(id)sender
{
    _isDone = YES;
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)backButtonClicked:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark -
#pragma mark Table View Action

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 40;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_markList count];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger index = indexPath.row;
    
    static NSString *cellId = @"MarkListTableViewCellId";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];

    if (cell == nil){
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
    }
    
    Mark* m = [_markList objectAtIndex:index];
    
    CGFloat width = [UIScreen mainScreen].bounds.size.width;
    
    UILabel* name = [[UILabel alloc] initWithFrame:CGRectMake(13, 13, 180, 14)];
    name.text = m.labelName;
    name.textColor = [UIColor whiteColor];
    name.font = [UIFont systemFontOfSize:13];
    
    [cell.contentView addSubview:name];

    UILabel* bottomLine = [[UILabel alloc] initWithFrame:CGRectMake(0, 39, width, 0.5)];
    [bottomLine setBackgroundColor:[UIColor grayColor]];
    
    [cell.contentView addSubview:bottomLine];

    [cell setAccessoryType:UITableViewCellAccessoryNone];
    
    for (Mark* im in _selectedMarkArray) {
        if (im.labelId == m.labelId) {
            [cell setAccessoryType:UITableViewCellAccessoryCheckmark];
            break;
        }
    }
    
    
    
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    Mark* m = [_markList objectAtIndex:indexPath.row];
    if (_parentControllerType == ParentControllerTypePublishMission) {
        
        UITableViewCell* cell = [tableView cellForRowAtIndexPath:indexPath];
        
        if (cell.accessoryType == UITableViewCellAccessoryCheckmark) {
            [cell setAccessoryType:UITableViewCellAccessoryNone];
            for (Mark* im in _selectedMarkArray) {
                if (im.labelId == m.labelId) {
                    [_selectedMarkArray removeObject:im];
                    break;
                }
            }
        }
        else
        {
            if (_selectedMarkArray == nil) {
                _selectedMarkArray = [NSMutableArray array];
            }
            [_selectedMarkArray addObject:m];
            [cell setAccessoryType:UITableViewCellAccessoryCheckmark];
        }
        
    }
    else
    {
        UIStoryboard* mainStory = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        UIViewController* controller;
        controller  = [mainStory instantiateViewControllerWithIdentifier:@"ICMarkClassifyViewController"];
        ((ICMarkClassifyViewController*)controller).labelId = m.labelId;
        ((ICMarkClassifyViewController*)controller).workGroupId = _workGroupId;
        [self.navigationController pushViewController:controller animated:YES];
    }
    
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    
    UIView* myView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 40)];
    
    myView.backgroundColor = [UIColor colorWithHexString:@"#5a70df"];
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(13, 2, 120, 18)];
    titleLabel.textColor=[UIColor whiteColor];
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.text=@"回形针项目标签";
    [titleLabel setFont:[UIFont systemFontOfSize:12]];
    
    [myView addSubview:titleLabel];
    
    UILabel* bottomLine = [[UILabel alloc] initWithFrame:CGRectMake(0, 23, [UIScreen mainScreen].bounds.size.width, 0.5)];
    [bottomLine setBackgroundColor:[UIColor grayColor]];
    
    //[myView addSubview:bottomLine];
    
    return myView;
}

-(void)setExtraCellLineHidden: (UITableView *)tableView
{
    UIView *view = [UIView new];
    view.backgroundColor = [UIColor clearColor];
    [tableView setTableFooterView:view];
    
}

@end
