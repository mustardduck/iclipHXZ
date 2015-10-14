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

@interface MQPublishMissionController ()
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
