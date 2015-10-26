//
//  MQPublishSharedAndNotifyController.m
//  CommonFrame_Pro
//
//  Created by 倩 莫 on 15/10/26.
//  Copyright © 2015年 ionitech. All rights reserved.
//

#import "MQPublishSharedAndNotifyController.h"
#import "UICommon.h"
#import "PH_UITextView.h"

@interface MQPublishSharedAndNotifyController ()
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
    
    UICollectionView * _markCollectionView;
    
    UICollectionView * _TagCollView;
    
    NSArray * _markList;
    
    NSMutableArray * _tagList;
    
    NSMutableArray * _imgUrls;
    NSMutableArray * _fileUrls;
    
    CGFloat _cellHeight;
    CGFloat _fanweiHeight;
    
}

@property (weak, nonatomic) IBOutlet UITextField *titleTxt;
@property (weak, nonatomic) IBOutlet PH_UITextView *txtView;
@property (weak, nonatomic) IBOutlet UIButton *fujianBtn;
@property (nonatomic, retain) NSMutableArray *pickedUrls;
@property (weak, nonatomic) IBOutlet UIScrollView *mainScrollView;
@property (weak, nonatomic) IBOutlet UIView *mainView;

@end

@implementation MQPublishSharedAndNotifyController


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

//    [self initMarkCollectionView];
//    
//    [self initTagCollectionView];
//    
//    [self initTableView];
    
    self.isShowAllSection = _workGroupName ? YES : NO;
    
    _imgUrls = [NSMutableArray array];
    _fileUrls = [NSMutableArray array];
    
    if(!_cAccessoryArray.count)
    {
        self.cAccessoryArray = [NSMutableArray array];
    }
    
    [_tableView reloadData];
}

- (void) viewDidLayoutSubviews
{
    [self resetScrollViewContenSize];
}

- (void) resetScrollViewContenSize
{
//    if(_isShowAllSection)
//    {
//        _tableView.height = 430 - 44 * 2 + _canyuHeight + _chaosongHeight;
//    }
    
    _mainView.height = YH(_tableView);
    
    [_mainScrollView setContentSize:CGSizeMake(SCREENWIDTH, H(_mainView))];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) setTextViewStyle
{
    [self addDoneToKeyboard:_titleTxt];
    [self addDoneToKeyboard:_txtView];
    
    _txtView.textContainerInset = UIEdgeInsetsMake(14.0f, 9.0f, 50.0f, 9.0f);
    _txtView.placeholder = @"描述";
    _txtView.placeholderColor = RGBCOLOR(172, 172, 172);
    _txtView.backgroundColor = [UIColor grayMarkColor];
    
    
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
    
    CGFloat pstH = (SCREENWIDTH - 14 * 2 - 12 * 3)/4;
    
    _collectionview = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, SCREENWIDTH, pstH + 14) collectionViewLayout:layout];
    _collectionview.delegate = self;
    _collectionview.dataSource = self;
    _collectionview.scrollEnabled = NO;
    _collectionview.backgroundColor = [UIColor grayMarkColor];
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
    [self.mainView addSubview:_collectionview];
    
    _collectionview.hidden = YES;
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
