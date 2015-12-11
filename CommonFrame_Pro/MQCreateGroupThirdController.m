//
//  MQCreateGroupThirdController.m
//  CommonFrame_Pro
//
//  Created by 倩 莫 on 15/12/3.
//  Copyright © 2015年 ionitech. All rights reserved.
//

#import "MQCreateGroupThirdController.h"
#import "UICommon.h"
#import "MarkTagCell.h"
#import "ICMainViewController.h"

@interface MQCreateGroupThirdController ()<UICollectionViewDataSource, UICollectionViewDelegate,UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate>
{
    NSMutableArray * _tagList;
    UICollectionView * _TagCollView;
    UITableView*   _tableView;
    UIView * _addTagView;
    UIView * _txtView;
    
    UITextField * _txtField;

}
@property (weak, nonatomic) IBOutlet UIBarButtonItem *rightBtnItem;

@end

@implementation MQCreateGroupThirdController


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
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
    
    UIBarButtonItem *rightBarButton = [[UIBarButtonItem alloc]initWithCustomView:leftButton];
    self.navigationItem.leftBarButtonItem = rightBarButton;
    
    [self initTableView];
    [self initTagCollectionView];
}

- (void) viewWillAppear:(BOOL)animated
{
    if(_tagList.count)
    {
        _rightBtnItem.title = @"完成";
    }
    else
    {
        _rightBtnItem.title = @"跳过";
    }
}

- (void) initTableView
{
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 51, SCREENWIDTH, SCREENHEIGHT - 51 - 64)];
    _tableView.backgroundColor = [UIColor backgroundColor];
    _tableView.dataSource = self;
    _tableView.delegate = self;
    [_tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    [self.view addSubview:_tableView];
    
    [self initTableViewHeader];
}

- (void) initTableViewHeader
{
    _tableView.tableHeaderView = ({
        
        [self setTableViewHeader];
    
    });
}

- (UIView *) setTableViewHeader
{
    UIView * topView = [[UIView alloc] init];
    
    topView.frame = CGRectMake(0, 0, SCREENWIDTH, 110);
    topView.backgroundColor = [UIColor backgroundColor];
    
    _addTagView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREENWIDTH, 44)];
    _addTagView.backgroundColor = [UIColor grayMarkColor];
    
    UIView * line = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREENWIDTH, 0.5)];
    line.backgroundColor = [UIColor grayLineColor];
    [_addTagView addSubview:line];

    UIImageView * icon = [[UIImageView alloc] initWithFrame:CGRectMake(14, 14, 15, 15)];
    icon.image = [UIImage imageNamed:@"icon_tianjia_1"];
    [_addTagView addSubview:icon];
    
    UIButton * addBtn = [[UIButton alloc] initWithFrame:CGRectMake(35, 0, SCREENWIDTH - 35 , 44)];
    addBtn.backgroundColor = [UIColor clearColor];
    [addBtn addTarget:self action:@selector(addBtnClicked) forControlEvents:UIControlEventTouchUpInside];
    [addBtn setTitle:@"新建标签" forState:UIControlStateNormal];
    addBtn.titleLabel.font = Font(15);
    addBtn.titleLabel.textColor = [UIColor whiteColor];
    addBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    [_addTagView addSubview:addBtn];
    
    
    line = [[UIView alloc] initWithFrame:CGRectMake(0, 44, SCREENWIDTH, 0.5)];
    line.backgroundColor = [UIColor grayLineColor];
    [topView addSubview:line];
    
    _txtView = [[UIView alloc] init];
    _txtView.frame = _addTagView.frame;
    _txtView.backgroundColor = [UIColor grayMarkColor];
    
    line = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREENWIDTH, 0.5)];
    line.backgroundColor = [UIColor grayLineColor];
    [_txtView addSubview:line];
    
    _txtField = [[UITextField alloc] initWithFrame:CGRectMake(14, 0, SCREENWIDTH - 14, 44)];
    _txtField.backgroundColor = [UIColor clearColor];
    _txtField.font = Font(15);
    _txtField.textColor = [UIColor whiteColor];
    _txtField.delegate = self;
    _txtField.returnKeyType = UIReturnKeyDone;
    _txtField.clearButtonMode = UITextFieldViewModeWhileEditing;
    _txtField.placeholder = @"请输入标签名";
    [_txtField setValue:[UIColor grayTitleColor] forKeyPath:@"_placeholderLabel.textColor"];
    [self addDoneToKeyboard:_txtField];
    [_txtView addSubview:_txtField];
    _txtField.enablesReturnKeyAutomatically = YES;
    
    [_txtField addTarget:self action:@selector(textChange:)
             forControlEvents:UIControlEventEditingChanged];
    
    [topView addSubview:_txtView];
    [topView addSubview:_addTagView];

    
    //对话框
    UIImageView * kuangView = [[UIImageView alloc] init];
    kuangView.image = [[UIImage imageNamed:@"bg_duihuakuang2"] stretchableImageWithLeftCapWidth:40 topCapHeight:30];
    
    kuangView.frame = CGRectMake(14, YH(_addTagView) + 7, SCREENWIDTH - 14 * 2, 50);
    
    UILabel * desLbl = [[UILabel alloc] init];
    desLbl.frame = CGRectMake(X(kuangView) + 8, Y(kuangView) + 10, W(kuangView) - 16, H(kuangView));
    desLbl.backgroundColor = [UIColor clearColor];
    desLbl.numberOfLines = 0;
    desLbl.font = Font(13);
    desLbl.textColor = [UIColor grayTitleColor];
    desLbl.text = @"标签可以是您群组的工作目标，比如：提高效率。建立好简单易懂的标签，后面可以更好帮助您查找工作，同时也为统计群组效率提供依据。";
    
    desLbl.height = [UICommon getHeightFromLabel:desLbl].height;
    
    kuangView.height = H(desLbl) + 20;
    
    [topView addSubview:kuangView];
    [topView addSubview:desLbl];
    
    topView.height = YH(kuangView) + 10;

    
    return topView;
}

- (void)textChange:(id)sender
{
    if(_txtField.text.length)
    {
        _txtField.enablesReturnKeyAutomatically = NO;
    }
}

- (void)hiddenKeyboard
{
    [_txtField resignFirstResponder];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if(textField.text.length)
    {
        [_tagList addObject:textField.text];
        _txtField.text = @"";
        [self refreshTagCollView];
        [_tableView reloadData];
    }
    return YES;
}

- (void)addBtnClicked
{
    _addTagView.hidden = YES;
    _txtView.hidden = NO;
    
}

- (void) initTagCollectionView
{
    _tagList = [[NSMutableArray alloc] init];
    
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    
    layout.minimumInteritemSpacing = 12.f;
    layout.minimumLineSpacing = 14.f;
    UIEdgeInsets insets = {.top = 0,.left = 14,.bottom = 14,.right = 14};
    layout.sectionInset = insets;
    
    _TagCollView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, SCREENWIDTH, 41) collectionViewLayout:layout];
    _TagCollView.delegate = self;
    _TagCollView.dataSource = self;
    _TagCollView.scrollEnabled = NO;
    _TagCollView.backgroundColor = [UIColor clearColor];
    
    [_TagCollView registerClass:[MarkTagCell class] forCellWithReuseIdentifier:@"MarkTagCell"];
    
    [self.view addSubview:_TagCollView];
    
    _TagCollView.hidden = YES;
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)backButtonClicked:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void) jumpToMainView
{
    UIViewController * model = [UICommon getOldViewController:[ICMainViewController class] withNavController:self.navigationController];
    if(model)
    {
        [self.navigationController popToViewController:model animated:YES];
    }
    
}

- (IBAction)doneButtonClicked:(id)sender
{
    [self hiddenKeyboard];
    
    if([_rightBtnItem.title isEqualToString:@"完成"])
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            
            BOOL isOk = [Mark addWgLabelList:_tagList workGroupID:_workGroup.workGroupId];
            if (isOk) {
               
                [self jumpToMainView];
                
            }
            
        });
    }
    else
    {
        [self jumpToMainView];

    }
}

#pragma -
#pragma Table View

- (CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 44.0;
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    for(UIView *view in cell.contentView.subviews) {
        [view removeFromSuperview];
    }
    
    CGFloat cellHeight = [self tableView:tableView heightForRowAtIndexPath:indexPath];
    
    _TagCollView.height = cellHeight;
    [cell.contentView addSubview:_TagCollView];
    cell.backgroundColor = [UIColor backgroundColor];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger lineCount = 4;
    NSInteger count = _tagList.count;
    NSInteger row = 1;
    CGFloat inviteCellHeight = 27 + 14;
    
    row = (count % lineCount) ? count / lineCount + 1: count / lineCount;
    
    CGFloat height = 14 + row * inviteCellHeight;
    
    return height;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(_tagList.count)
    {
        return 1;
    }
    return 0;
}

- (UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView* customView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREENWIDTH, 44)];
    customView.backgroundColor = [UIColor backgroundColor];
    
    UILabel * headerLabel = [[UILabel alloc] initWithFrame:CGRectMake(14, 24, 100, 14)];
    headerLabel.backgroundColor = [UIColor clearColor];
    headerLabel.textColor = [UIColor grayTitleColor];
    headerLabel.font = Font(12);
    
    NSString * title = @"新建标签";
    
    headerLabel.text = title;
    
    [customView addSubview:headerLabel];
    
    return customView;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if(_tagList.count)
    {
        return 1;
    }
    else
    {
        return 0;
    }
}

#pragma mark - collectionview delegate / datasource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return _tagList.count;
}


- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"MarkTagCell";
    MarkTagCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:CellIdentifier forIndexPath:indexPath];
    
    NSString * tagName = _tagList[indexPath.row];
    
    cell.titleLbl.text = tagName;
    
    [cell.delBtn addTarget:self action:@selector(delTagItem:) forControlEvents:UIControlEventTouchUpInside];
    
    [cell setRoundCorner:3.3];
    
    return cell;
}

- (void) delTagItem:(id)button
{
    UIButton * btn = (UIButton *)button;
    
    NSInteger deleteIndex = btn.tag;
    
    [_tagList removeObjectAtIndex:deleteIndex];
    
    [self refreshTagCollView];
    
    [_tableView reloadData];
    
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewFlowLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger itemSpace = 22;
    
    if(SCREENWIDTH == 320)
    {
        itemSpace = 14;
    }
    else if (SCREENWIDTH == 375)
    {
        itemSpace = 12;
    }
    
    CGFloat pstH = (SCREENWIDTH - 14 * 2 - itemSpace * 3)/4;
    
    return CGSizeMake(pstH, 27);
}

- (void) refreshTagCollView
{
    _TagCollView.hidden = _tagList.count ? NO :YES;
    
    if(!_TagCollView.hidden)
    {
        _rightBtnItem.title = @"完成";
        
        [self countTagHeight];
        
        [_TagCollView reloadData];
        
    }
    else
    {
        _rightBtnItem.title = @"跳过";

    }
}

- (void) countTagHeight
{
    NSInteger count = _tagList.count;
    NSInteger row = (count % 4) ? count / 4 + 1: count / 4;
    
    float height = row * (27 + 14);
    
    _TagCollView.height = height;
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
