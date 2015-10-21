//
//  MQPublishMissionController.m
//  CommonFrame_Pro
//
//  Created by 倩 莫 on 15/10/13.
//  Copyright © 2015年 ionitech. All rights reserved.
//

#import "MQPublishMissionController.h"
#import "UICommon.h"
#import "UIImageView+UIActivityIndicatorForSDWebImage.h"
#import "PH_UITextView.h"
#import "ICGroupListViewController.h"
#import "ICMarkListViewController.h"
#import <ZYQAssetPickerController.h>
#import "Mark.h"
#import "Mission.h"
#import "ICFileViewController.h"
#import "AddPicCell66.h"
#import "AddPicCell80.h"
#import "AddPicCell88.h"

@interface MQPublishMissionController ()<UICollectionViewDelegate, UICollectionViewDataSource,UIActionSheetDelegate,UIImagePickerControllerDelegate,ZYQAssetPickerControllerDelegate,UITextViewDelegate, UITextFieldDelegate,UINavigationControllerDelegate, UITableViewDataSource, UITableViewDelegate>
{
    UICollectionView *_collectionview;
    NSInteger _deleteIndex;
    NSInteger _currentItem;//选择的某个图片
    
    UIDatePicker*           _datePicker;
    UIView*                 _datePickerView;
    NSMutableArray*         _accessoryArray;
    BOOL                    _btnDoneClicked;
    
    NSString *          _currentFileName;
    
    UITableView*            _tableView;
    
    BOOL _isShowAllSection;

}

@property (weak, nonatomic) IBOutlet UITextField *titleTxt;
@property (weak, nonatomic) IBOutlet PH_UITextView *txtView;
@property (weak, nonatomic) IBOutlet UIView *timeView;
@property (weak, nonatomic) IBOutlet UIButton *jiezhiBtn;
@property (weak, nonatomic) IBOutlet UIButton *tixingBtn;
@property (weak, nonatomic) IBOutlet UIButton *fujianBtn;
@property (weak, nonatomic) IBOutlet UIView *jiezhiAndTixingView;
@property (weak, nonatomic) IBOutlet UIView *jiezhiView;
@property (weak, nonatomic) IBOutlet UIView *tixingView;
@property (weak, nonatomic) IBOutlet UILabel *jiezhiLbl;
@property (weak, nonatomic) IBOutlet UIButton *jiezhiDelBtn;
@property (weak, nonatomic) IBOutlet UILabel *tixingLbl;
@property (weak, nonatomic) IBOutlet UIButton *tixingDelBtn;

@property (nonatomic, retain) NSMutableArray *pickedUrls;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *JTViewToTxtViewTopCons;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *timeToTxtViewTopCons;
@property (weak, nonatomic) IBOutlet UIScrollView *mainScrollView;
@property (weak, nonatomic) IBOutlet UIView *mainView;

@end

@implementation MQPublishMissionController


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
    
    UIBarButtonItem *rightBarButton = [[UIBarButtonItem alloc]initWithCustomView:leftButton];
    self.navigationItem.leftBarButtonItem = rightBarButton;
    
    [self setTextViewStyle];
    
    [self _initPstCollectionView];
    
    [self initTableView];
}

- (void) viewDidLayoutSubviews
{
    [self resetScrollViewContenSize];
}

- (void) resetScrollViewContenSize
{
    _mainView.height = YH(_tableView);
    
    [_mainScrollView setContentSize:CGSizeMake(SCREENWIDTH, H(_mainView))];
}

- (void) initTableView
{
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, _timeView.bottom, SCREENWIDTH, SCREENHEIGHT - 66)];
    _tableView.backgroundColor = [UIColor clearColor];
    _tableView.dataSource = self;
    _tableView.delegate = self;
    _tableView.tag = 101;
    [_tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    _tableView.scrollEnabled = NO;
    [self.view addSubview:_tableView];

}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [_tableView reloadData];
    
    if (_strFinishTime != nil)
    {
        
    }
    if (_strRemindTime != nil) {
        
    }
    if (self.participantsIndexPathArray != nil) {
        NSLog(@"%@",self.participantsIndexPathArray);
        
        NSIndexPath* indexPath = [NSIndexPath indexPathForRow:(NSInteger)1 inSection:(NSInteger)1];
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
        
        NSIndexPath* indexPath = [NSIndexPath indexPathForRow:(NSInteger)2 inSection:(NSInteger)1];
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
        }
    }
    
    if (self.cMarkAarry != nil)
    {
        
    }
    
    if (self.responsibleDic.count > 0){
        NSLog(@"%@",self.responsibleDic);
        
        if (self.responsibleDic.count > 0) {
            NSMutableArray* arr = (NSMutableArray*)self.responsibleDic;
            
            if (arr.count == 1) {
                
                Member* mem = arr[0];
                
                NSIndexPath* indexPath = [NSIndexPath indexPathForRow:(NSInteger)0 inSection:(NSInteger)1];
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
    
    if (self.cAccessoryArray != nil)
    {//附件
        
    }
    
    [self resetScrollViewContenSize];
    
}

#pragma -
#pragma Table View
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {
        return 1;
    }
    else if (section == 1) {
        return 3;
    }
    else if (section == 2) {
        return 1;
    }
    return 0;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if(_isShowAllSection)
    {
        return 3;
    }
    else
    {
        return 1;
    }
}

//- (NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
//{
//    NSString * title = @"";
//    
//    if (section == 0) {
//        title = @"选择群组";
//    }
//    else if (section == 1)
//    {
//        title = @"选择成员";
//    }
//    else if (section == 2)
//    {
//        title = @"分类";
//    }
//    return title;
//}


- (UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView* customView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREENWIDTH, 44)];
    
    UILabel * headerLabel = [[UILabel alloc] initWithFrame:CGRectMake(14, 26, 100, 14)];
    headerLabel.backgroundColor = [UIColor clearColor];
    headerLabel.textColor = [UIColor grayTitleColor];
    headerLabel.font = Font(12);
    
    NSString * title = @"";
    
    if (section == 0) {
        title = @"选择群组";
    }
    else if (section == 1)
    {
        title = @"选择成员";
    }
    else if (section == 2)
    {
        title = @"分类";
    }
    headerLabel.text = title;
    
    [customView addSubview:headerLabel];
    
    return customView;
}

- (CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 44.0;
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

    NSInteger index = indexPath.row;
    NSInteger section = indexPath.section;
    CGFloat tableWidth = SCREENWIDTH;
    CGFloat cellHeight = [self tableView:tableView heightForRowAtIndexPath:indexPath];

    UIImageView* photo = [[UIImageView alloc] initWithFrame:CGRectMake(12, 11, 17, 20)];
    
    UILabel* lblText = [[UILabel alloc] initWithFrame:CGRectMake(42, 12, 100, 22)];
    [lblText setBackgroundColor:[UIColor clearColor]];
    [lblText setTextColor:[UIColor whiteColor]];
    [lblText setFont:[UIFont systemFontOfSize:15]];
    [lblText setTextAlignment:NSTextAlignmentLeft];
    
    if (section == 0 && index == 0) {
        UILabel* line1 = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, tableWidth, 0.5)];
        [line1 setBackgroundColor:[UIColor grayLineColor]];
        [cell.contentView addSubview:line1];
        
        [photo setFrame:CGRectMake(14, 14, 17, 16)];
        [photo setImage:[UIImage imageNamed:@"icon_qunzu"]];
        [lblText setText:@"群组"];
    }
    else if(section == 1 && index == 0) {
        UILabel* line1 = [[UILabel alloc] initWithFrame:CGRectMake(0, 1, tableWidth, 0.5)];
        [line1 setBackgroundColor:[UIColor grayColor]];
        [cell.contentView addSubview:line1];
        
        [photo setFrame:CGRectMake(14, 14, 14, 17)];
        [photo setImage:[UIImage imageNamed:@"icon_fuzeren"]];
        [lblText setText:@"负责人"];
    }
    else if (section == 1 && index == 1) {
        [photo setFrame:CGRectMake(14, 14, 15, 17)];
        [photo setImage:[UIImage imageNamed:@"icon_canyuren"]];
        [lblText setText:@"参与人"];
    }
    else if (section == 1 && index == 2) {
        [photo setFrame:CGRectMake(14, 11, 13, 18)];
        [photo setImage:[UIImage imageNamed:@"icon_chaosong"]];
        [lblText setText:@"抄送"];
    }
    
    if (!(section == 2 && index == 0))
    {
        
        [cell.contentView addSubview:photo];
        [cell.contentView addSubview:lblText];
        
        UILabel* line4 = [[UILabel alloc] init];
        
        if((section == 1 && index == 0) || (section == 1 && index == 1))
        {
            line4.frame = CGRectMake(14, cellHeight - 1, tableWidth, 0.5);
        }
        else
        {
            line4.frame = CGRectMake(0, cellHeight - 1, tableWidth, 0.5);
        }
        
        [line4 setBackgroundColor:[UIColor grayLineColor]];
        [cell.contentView addSubview:line4];
        
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
    cell.backgroundColor = [UIColor clearColor];
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self hiddenKeyboard];
    
    NSInteger index = indexPath.row;
    NSInteger section = indexPath.section;
    
    if(section == 0 && index == 0)
    {
        _isShowAllSection = YES;
        
        [_tableView reloadData];

    }
    if(section == 1 && index == 0)
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
    else if(section == 1 && index == 1)
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
        
    }
    else if(section == 1 && index == 2)//抄送
    {
        //if (_participantsIndexPathArray.count > 0) {
        UIStoryboard* mainStory = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        UIViewController* vc = [mainStory instantiateViewControllerWithIdentifier:@"ICMemberTableViewController"];
        ((ICMemberTableViewController*)vc).controllerType = MemberViewFromControllerCopyTo;
        ((ICMemberTableViewController*)vc).icPublishMisonController = self;
        
        ((ICMemberTableViewController*)vc).selectedResponsibleDictionary = _responsibleDic;
        ((ICMemberTableViewController*)vc).workgid = self.workGroupId;
        ((ICMemberTableViewController*)vc).isCC = YES;
        
        if (_ccopyToMembersArray.count > 0) {
            ((ICMemberTableViewController*)vc).selectedCopyToMembersArray = _ccopyToMembersArray;
        }
        if (_participantsIndexPathArray.count > 0) {
            //((ICMemberTableViewController*)vc).selectedParticipantsDictionary = _participantsIndexPathArray;
        }
        [self.navigationController pushViewController:vc animated:YES];
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 1 && indexPath.section == 1) {
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
    else if (indexPath.row == 2 && indexPath.section == 1) {
        
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
    return 44;
}


- (void)_initPstCollectionView
{
    _currentItem = -1;
    _deleteIndex = -1;
    
    self.pickedUrls = [NSMutableArray arrayWithCapacity:0];
    
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    
    layout.minimumInteritemSpacing = 12.f;
    layout.minimumLineSpacing = 14.f;
    UIEdgeInsets insets = {.top = 0,.left = 14,.bottom = 14,.right = 14};
    layout.sectionInset = insets;
    
    CGFloat pstY = YH(_txtView) + 14;
    
    if(!_jiezhiAndTixingView.hidden)
    {
        pstY = YH(_jiezhiAndTixingView);
    }
    
    CGFloat pstH = (SCREENWIDTH - 14 * 2 - 12 * 3)/4;

    _collectionview = [[UICollectionView alloc] initWithFrame:CGRectMake(0, pstY, SCREENWIDTH, pstH + 14) collectionViewLayout:layout];
    _collectionview.delegate = self;
    _collectionview.dataSource = self;
    _collectionview.scrollEnabled = NO;
    _collectionview.backgroundColor = [UIColor whiteColor];
    NSString * idenStr = @"AddPicCell88";
    if(SCREENWIDTH == 375)
    {
        idenStr = @"AddPicCell80";
    }
    else if (SCREENWIDTH == 320)
    {
        idenStr = @"AddPicCell66";
    }
    [_collectionview registerNib:[UINib nibWithNibName:idenStr bundle:[NSBundle mainBundle]] forCellWithReuseIdentifier:idenStr];
    [self.view addSubview:_collectionview];
    
    _collectionview.hidden = YES;
}

#pragma mark - collectionview delegate / datasource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return _pickedUrls.count + 1;
}

//删除图片
- (void)clickDelImage:(UIButton *)button
{
    UIButton * btn = (UIButton *)button;
    
    NSInteger deleteIndex = btn.tag - 1000;
    
    [_pickedUrls removeObjectAtIndex:deleteIndex];

    [self refreshCollectionView];
    
//    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"删除提示"
//                                                    message:nil
//                                                   delegate:self
//                                          cancelButtonTitle:@"取消"
//                                          otherButtonTitles:@"删除", nil];
//    [alert show];
}


//点击add图片
- (void)clickImage:(UIButton *)button{
    [self.view endEditing:YES];
    _currentItem = -1;
    UIActionSheet* as = [[UIActionSheet alloc] initWithTitle:@"选取附件" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"我的文件夹", @"拍照", @"从相册选取", nil];
    [as showInView:self.view];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    NSString * idenStr = @"AddPicCell88";
    
    if(SCREENWIDTH == 375)
    {
        idenStr = @"AddPicCell80";
        
        AddPicCell80 *cell = [collectionView dequeueReusableCellWithReuseIdentifier:idenStr forIndexPath:indexPath];

        CGRect rect = cell.frame;
        rect.origin.x = 0;
        cell.contentView.frame = rect;
        if (indexPath.row == _pickedUrls.count) {
            cell.imageView.hidden = YES;
            cell.btnAdd.hidden = NO;
            cell.delBtn.hidden = YES;
            [cell.btnAdd addTarget:self action:@selector(clickImage:) forControlEvents:UIControlEventTouchUpInside];
        } else {
            cell.btnAdd.hidden = YES;
            cell.imageView.hidden = NO;
            cell.delBtn.hidden = NO;
            cell.delBtn.tag = 1000 + indexPath.row;
            [cell.delBtn addTarget:self action:@selector(clickDelImage:) forControlEvents:UIControlEventTouchUpInside];
            NSInteger index = indexPath.row;
            
            [cell.imageView setImageWithURL:[NSURL URLWithString:_pickedUrls[index]] placeholderImage:nil options:SDWebImageDelayPlaceholder usingActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        }
        
        //    [cell.imageView setBorderWithColor:AppColor(204)];
        
        return cell;
    }
    else if (SCREENWIDTH == 320)
    {
        idenStr = @"AddPicCell66";
        
        AddPicCell66 *cell = [collectionView dequeueReusableCellWithReuseIdentifier:idenStr forIndexPath:indexPath];

        CGRect rect = cell.frame;
        rect.origin.x = 0;
        cell.contentView.frame = rect;
        if (indexPath.row == _pickedUrls.count) {
            cell.imageView.hidden = YES;
            cell.btnAdd.hidden = NO;
            [cell.btnAdd addTarget:self action:@selector(clickImage:) forControlEvents:UIControlEventTouchUpInside];
        } else {
            cell.btnAdd.hidden = YES;
            cell.imageView.hidden = NO;
            
            NSInteger index = indexPath.row;
            
            [cell.imageView setImageWithURL:[NSURL URLWithString:_pickedUrls[index]] placeholderImage:nil options:SDWebImageDelayPlaceholder usingActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        }
        
        //    [cell.imageView setBorderWithColor:AppColor(204)];
        
        return cell;
    }
    else
    {
        AddPicCell88 *cell = [collectionView dequeueReusableCellWithReuseIdentifier:idenStr forIndexPath:indexPath];
        CGRect rect = cell.frame;
        rect.origin.x = 0;
        cell.contentView.frame = rect;
        if (indexPath.row == _pickedUrls.count) {
            cell.imageView.hidden = YES;
            cell.btnAdd.hidden = NO;
            [cell.btnAdd addTarget:self action:@selector(clickImage:) forControlEvents:UIControlEventTouchUpInside];
        } else {
            cell.btnAdd.hidden = YES;
            cell.imageView.hidden = NO;
            
            NSInteger index = indexPath.row;
            
            [cell.imageView setImageWithURL:[NSURL URLWithString:_pickedUrls[index]] placeholderImage:nil options:SDWebImageDelayPlaceholder usingActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        }
        
        //    [cell.imageView setBorderWithColor:AppColor(204)];
        
        return cell;
    }

}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewFlowLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat pstH = (SCREENWIDTH - 14 * 2 - 12 * 3)/4;
    
    if(pstH > 88)
    {
        pstH = 88;
    }
    
    return CGSizeMake(pstH, pstH);
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    
//    UIActionSheet *sheet = [[[UIActionSheet alloc] initWithTitle:@"" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:@"预览" otherButtonTitles:@"相机拍摄", @"从相册中选择", @"删除", nil] autorelease];
//    sheet.tag = indexPath.row + 1000;
//    [sheet showInView:self.view];
}

- (void) setTextViewStyle
{
    [self addDoneToKeyboard:_titleTxt];
    [self addDoneToKeyboard:_txtView];
    
    _txtView.textContainerInset = UIEdgeInsetsMake(14.0f, 9.0f, 50.0f, 9.0f);
    _txtView.placeholder = @"描述";
    _txtView.placeholderColor = RGBCOLOR(172, 172, 172);
    _txtView.backgroundColor = [UIColor clearColor];
    
    
    //    textview 改变字体的行间距
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.lineSpacing = 4;// 字体的行间距
    
    NSDictionary *attributes = @{
                                 NSFontAttributeName:[UIFont systemFontOfSize:15],
                                 NSParagraphStyleAttributeName:paragraphStyle,
                                 NSForegroundColorAttributeName:[UIColor whiteColor]
                                 };
    _txtView.attributedText = [[NSAttributedString alloc] initWithString:@"" attributes:attributes];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)btnTodayClicked:(id)sender
{
    [_datePicker setDate:[NSDate date]];
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
    
    
    NSString *strDate = @"";
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    
    if (tag == 11) {//截止
        [dateFormatter setDateFormat:@"yyyy-MM-dd"];
        strDate = [dateFormatter stringFromDate:pickerDate];
        
        if(_strRemindTime)
        {
            [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];

            NSDate* fdate = [dateFormatter dateFromString:_strRemindTime];
            
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
                _strFinishTime = strDate;
        }
        
        _strFinishTime = strDate;
        
        [dateFormatter setDateFormat:@"yyyy年MM月dd日"];
        strDate = [dateFormatter stringFromDate:pickerDate];
        
        _jiezhiLbl.text = [NSString stringWithFormat:@"截止时间：%@", strDate];
        
        _jiezhiAndTixingView.hidden = NO;
        _jiezhiView.hidden = NO;
        
        _JTViewToTxtViewTopCons.constant = 0;
        
        if(!_collectionview.hidden)
        {
            _collectionview.top = _jiezhiAndTixingView.hidden ? _txtView.bottom + 14 : _jiezhiAndTixingView.bottom;
            
            _timeToTxtViewTopCons.constant = H(_jiezhiAndTixingView) + H(_collectionview);
        }
        else
        {
            _timeToTxtViewTopCons.constant = H(_jiezhiAndTixingView);

        }
    }
    else if (tag == 12)//提醒
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
        
        [dateFormatter setDateFormat:@"yyyy年MM月dd日 HH:mm"];
        strDate = [dateFormatter stringFromDate:pickerDate];
        
        _tixingLbl.text = [NSString stringWithFormat:@"提醒时间：%@", strDate];
        _jiezhiAndTixingView.hidden = NO;
        _tixingView.hidden = NO;
        
        _JTViewToTxtViewTopCons.constant = 0;
        
        if(!_collectionview.hidden)
        {
            _collectionview.top = _jiezhiAndTixingView.hidden ? _txtView.bottom + 14 : _jiezhiAndTixingView.bottom;
            
            _timeToTxtViewTopCons.constant = H(_jiezhiAndTixingView) + H(_collectionview);
        }
        else
        {
            _timeToTxtViewTopCons.constant = H(_jiezhiAndTixingView);
            
        }
    }
}

- (IBAction)touchUpInsideOnBtn:(id)sender
{
    UIButton * btn = (UIButton *)sender;
    
    if(btn == _jiezhiBtn || btn == _tixingBtn)
    {
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
        
        if (btn == _jiezhiBtn) {
            [btnChoicedDate setTag:11];

            _datePicker.datePickerMode = UIDatePickerModeDate;
        }
        else if (btn == _tixingBtn) {
            [btnChoicedDate setTag:12];
            
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
    else if (btn == _fujianBtn)
    {
        UIActionSheet* as = [[UIActionSheet alloc] initWithTitle:@"选取附件" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"我的文件夹", @"拍照", @"从相册选取", nil];
        [as showInView:self.view];
    }
    else if (btn == _jiezhiDelBtn)
    {
        _jiezhiView.hidden = YES;
        
        if(_tixingView.hidden)
        {
            _jiezhiAndTixingView.hidden = YES;
            
            _timeToTxtViewTopCons.constant = _collectionview.hidden ? 0 : H(_collectionview) + 14;

        }
        
        _collectionview.top = _jiezhiAndTixingView.hidden ? _txtView.bottom + 14 : _jiezhiAndTixingView.bottom;
        
        _strFinishTime = nil;
    }
    else if (btn == _tixingDelBtn)
    {
        _tixingView.hidden = YES;
        
        if(_jiezhiView.hidden)
        {
            _jiezhiAndTixingView.hidden = YES;
            
            _timeToTxtViewTopCons.constant = _collectionview.hidden ? 0 : H(_collectionview) + 14;

        }
        
        _collectionview.top = _jiezhiAndTixingView.hidden ? _txtView.bottom + 14 : _jiezhiAndTixingView.bottom;
        
        _strRemindTime = nil;
    }
}

#pragma mark -
#pragma UIActionSheet Deleget
-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(buttonIndex == 0)
    {
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
        
        [picker dismissViewControllerAnimated:YES completion:^() {
            //            UIImage *portraitImg = [info objectForKey:@"UIImagePickerControllerOriginalImage"];
            
            ALAsset * ass = assets[0];
            
            ALAssetRepresentation* representation = [ass defaultRepresentation];
            UIImage* portraitImg = [UIImage imageWithCGImage:[representation fullResolutionImage]];
            portraitImg = [UIImage
                           imageWithCGImage:[representation fullScreenImage]
                           scale:[representation scale]
                           orientation:UIImageOrientationUp];
            
            _currentFileName = [representation filename];
            
//            portraitImg = [UICommon imageByScalingToMaxSize:portraitImg];
            
            NSString * userImgPath = @"";
            
            BOOL isOk = [LoginUser uploadImageWithScale:portraitImg fileName:_currentFileName userImgPath:&userImgPath];
            
            if(isOk)
            {
                if (_currentItem == -1) {
                    [_pickedUrls addObject:userImgPath];
                } else {
                    [_pickedUrls removeObjectAtIndex:_currentItem];
                    [_pickedUrls insertObject:userImgPath atIndex:_currentItem];
                }
                [self refreshCollectionView];
            }
        }];
    }
}

- (void) refreshCollectionView
{
    _collectionview.hidden = _pickedUrls.count ? NO : YES;
    
    if(!_collectionview.hidden)
    {
        [_collectionview reloadData];
        
        [self countHeight];
        
        _collectionview.top = _jiezhiAndTixingView.hidden ? _txtView.bottom + 14 : _jiezhiAndTixingView.bottom;
        
        _timeToTxtViewTopCons.constant = _jiezhiAndTixingView.hidden ? H(_collectionview) + 14 : H(_jiezhiAndTixingView) + H(_collectionview);
    }
    else//图片hidden
    {
        _timeToTxtViewTopCons.constant = _jiezhiAndTixingView.hidden ? 0 : H(_jiezhiAndTixingView);

    }
}

- (void)countHeight{
    //计算高度
    
    NSInteger count = _pickedUrls.count + 1;
    NSInteger row = (count % 4) ? (count / 4 + 1) : count / 4;
    
    CGFloat pstH = (SCREENWIDTH - 14 * 2 - 12 * 3)/4;

    float height = row * (pstH + 14);
    
    _collectionview.height = height;

}

- (IBAction)btnDoneButtonClicked:(id)sender
{
    [self hiddenKeyboard];
    
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
    m.main = _txtView.text;
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
    m.title = _titleTxt.text;
    
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
            
            UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"任务创建成功！" delegate:self
                                                  cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            [alert show];
            
            [self hiddenKeyboard];
            _btnDoneClicked = YES;
            [self.navigationController popViewControllerAnimated:YES];
        }
        
    });
    
}

- (IBAction)btnBackButtonClicked:(id)sender
{
    [self hiddenKeyboard];
    
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)textViewDidChange:(UITextView *)textView
{
    //    textview 改变字体的行间距
    
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    
    paragraphStyle.lineSpacing = 4;// 字体的行间距
    
    NSDictionary *attributes = @{
                                 NSFontAttributeName:[UIFont systemFontOfSize:15],
                                 NSParagraphStyleAttributeName:paragraphStyle,
                                 NSForegroundColorAttributeName:[UIColor whiteColor]
                                 };
    
    textView.attributedText = [[NSAttributedString alloc] initWithString:textView.text attributes:attributes];    
    
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
    [_titleTxt resignFirstResponder];
    [_txtView resignFirstResponder];
    
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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
