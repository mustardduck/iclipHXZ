//
//  MQPublishMissionController.m
//  CommonFrame_Pro
//
//  Created by 倩 莫 on 15/10/13.
//  Copyright © 2015年 ionitech. All rights reserved.
//

#import "MQPublishMissionController.h"
#import "UICommon.h"
#import "PSTCollectionView.h"
#import "AddPictureCell.h"
#import <UIImageView+UIActivityIndicatorForSDWebImage.h>

@interface MQPublishMissionController ()<PSTCollectionViewDelegate, PSTCollectionViewDataSource>
{
    PSTCollectionView *_collectionview;
    NSInteger _deleteIndex;
    NSInteger _currentItem;//选择的某个图片
}

@property (weak, nonatomic) IBOutlet UITextField *titleTxt;
@property (weak, nonatomic) IBOutlet UITextView *txtView;
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
@property (nonatomic, retain) NSMutableArray *pickedIds;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *JTViewToTxtViewTopCons;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *timeToTxtViewTopCons;

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
    
    _txtView.textContainerInset = UIEdgeInsetsMake(14.0f, 9.0f, 50.0f, 9.0f);
    
    [self setTextViewStyle];
    
    [self _initPstCollectionView];
}

- (void)_initPstCollectionView
{
    _currentItem = -1;
    _deleteIndex = -1;
    
    self.pickedUrls = [NSMutableArray arrayWithCapacity:0];
    self.pickedIds = [NSMutableArray arrayWithCapacity:0];
    
    PSTCollectionViewFlowLayout *layout = [[PSTCollectionViewFlowLayout alloc] init];
    
    layout.minimumInteritemSpacing = 20.f;
    layout.minimumLineSpacing = 20.f;
    UIEdgeInsets insets = {.top = 0,.left = 14,.bottom = 14,.right = 14};
    layout.sectionInset = insets;
    
    CGFloat pstY = YH(_txtView) + 14;
    
    if(!_jiezhiAndTixingView.hidden)
    {
        pstY = YH(_jiezhiAndTixingView);
    }
    
    CGFloat pstH = (SCREENWIDTH - 14 * 2 - 12 * 3)/4;
    
    _collectionview = [[PSTCollectionView alloc] initWithFrame:CGRectMake(0, pstY, SCREENWIDTH, pstH + 14) collectionViewLayout:layout];
    _collectionview.delegate = self;
    _collectionview.dataSource = self;
    _collectionview.scrollEnabled = NO;
    _collectionview.backgroundColor = [UIColor whiteColor];
    [_collectionview registerNib:[UINib nibWithNibName:@"AddPictureCell" bundle:[NSBundle mainBundle]] forCellWithReuseIdentifier:@"AddPictureCell"];
    [self.view addSubview:_collectionview];
    
//    _collectionview.hidden = YES;
}

#pragma mark - collectionview delegate / datasource
- (NSInteger)collectionView:(PSTCollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return _pickedUrls.count + 1;
}

//点击add图片
- (void)clickImage:(UIButton *)button{
    [self.view endEditing:YES];
    _currentItem = -1;
    UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:@"" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:@"相机拍摄" otherButtonTitles:@"从相册中选择", nil];
    [sheet showInView:self.view];
}

- (PSTCollectionViewCell *)collectionView:(PSTCollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    AddPictureCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"AddPictureCell" forIndexPath:indexPath];
    CGRect rect = cell.frame;
    rect.origin.x = 0;
    cell.contentView.frame = rect;
    if (indexPath.row == _pickedUrls.count && _pickedUrls.count != 10) {
        cell.imageView.hidden = YES;
        cell.btnAdd.hidden = NO;
        [cell.btnAdd addTarget:self action:@selector(clickImage:) forControlEvents:UIControlEventTouchUpInside];
    } else {
        cell.btnAdd.hidden = YES;
        cell.imageView.hidden = NO;
        
        [cell.imageView setImageWithURL:[NSURL URLWithString:_pickedUrls[indexPath.row]] placeholderImage:nil options:SDWebImageDelayPlaceholder usingActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    }
    
//    [cell.imageView setBorderWithColor:AppColor(204)];
    
    return cell;
}

- (CGSize)collectionView:(PSTCollectionView *)collectionView layout:(PSTCollectionViewFlowLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat pstH = (SCREENWIDTH - 14 * 2 - 12 * 3)/4;
    
    return CGSizeMake(pstH, pstH);
}

- (void)collectionView:(PSTCollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    
//    UIActionSheet *sheet = [[[UIActionSheet alloc] initWithTitle:@"" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:@"预览" otherButtonTitles:@"相机拍摄", @"从相册中选择", @"删除", nil] autorelease];
//    sheet.tag = indexPath.row + 1000;
//    [sheet showInView:self.view];
}

- (void) setTextViewStyle
{
    //    textview 改变字体的行间距
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.lineSpacing = 4;// 字体的行间距
    
    NSDictionary *attributes = @{
                                 NSFontAttributeName:[UIFont systemFontOfSize:15],
                                 NSParagraphStyleAttributeName:paragraphStyle,
                                 NSForegroundColorAttributeName:[UIColor whiteColor]
                                 };
    _txtView.attributedText = [[NSAttributedString alloc] initWithString:@"我们" attributes:attributes];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)touchUpInsideOnBtn:(id)sender
{
    UIButton * btn = (UIButton *)sender;
    
    if(btn == _jiezhiBtn)
    {
        _jiezhiAndTixingView.hidden = NO;
        _jiezhiView.hidden = NO;
        
        _JTViewToTxtViewTopCons.constant = 0;
        
        _timeToTxtViewTopCons.constant = H(_jiezhiAndTixingView);
    }
    else if (btn == _tixingBtn)
    {
        _jiezhiAndTixingView.hidden = NO;
        _tixingView.hidden = NO;
        
        _JTViewToTxtViewTopCons.constant = 0;
        
        _timeToTxtViewTopCons.constant = H(_jiezhiAndTixingView);

    }
    else if (btn == _fujianBtn)
    {
        
    }
    else if (btn == _jiezhiDelBtn)
    {
        _jiezhiView.hidden = YES;
        
        if(_tixingView.hidden)
        {
            _timeToTxtViewTopCons.constant = 0;

            _jiezhiAndTixingView.hidden = YES;
        }
    }
    else if (btn == _tixingDelBtn)
    {
        _tixingView.hidden = YES;
        
        if(_jiezhiView.hidden)
        {
            _timeToTxtViewTopCons.constant = 0;
            
            _jiezhiAndTixingView.hidden = YES;
        }
    }
}

- (IBAction)btnDoneButtonClicked:(id)sender
{
    
}

- (IBAction)btnBackButtonClicked:(id)sender
{
//    [_txtContent resignFirstResponder];
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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
