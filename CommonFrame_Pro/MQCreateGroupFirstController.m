//
//  MQCreateGroupFirstController.m
//  CommonFrame_Pro
//
//  Created by 倩 莫 on 15/12/3.
//  Copyright © 2015年 ionitech. All rights reserved.
//

#import "MQCreateGroupFirstController.h"
#import "UICommon.h"

@interface MQCreateGroupFirstController ()
{
    CGFloat _currentHeight;
}

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *photoViewHeight;
@property (weak, nonatomic) IBOutlet UIImageView *groupImg;
@property (weak, nonatomic) IBOutlet UIButton *photoBtn;

@property (weak, nonatomic) IBOutlet UITextField *groupTitleTxt;
@property (weak, nonatomic) IBOutlet UITextView *sloganTextView;
@property (weak, nonatomic) IBOutlet UILabel *sloganPlaceholder;

@end

@implementation MQCreateGroupFirstController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textChangeed:) name:UITextViewTextDidChangeNotification object:nil];
    
    _currentHeight = 32;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)textChangeed:(id)sender
{
    CGFloat currentHeight = _sloganTextView.contentSize.height;
    CGFloat newHeight = currentHeight - _currentHeight;

    if(currentHeight < 120)
    {
        _photoViewHeight.constant = _photoViewHeight.constant + newHeight;
        
        _sloganTextView.height = _sloganTextView.height + newHeight;
        
        _currentHeight = currentHeight;
    }

//    [self removeType];
//    
//    CGFloat currentHeight = _textField.contentSize.height;
//    CGFloat newHeight = currentHeight - _currentHeight;
//
//    if (currentHeight < 120) {
//        self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y  - newHeight, self.frame.size.width, self.frame.size.height +  newHeight);
//        
//        _textField.frame = CGRectMake(_textField.frame.origin.x, (self.bounds.size.height - (_textField.frame.size.height +  newHeight))/2 , _textField.frame.size.width, _textField.frame.size.height +  newHeight);
//        
//        _currentHeight = currentHeight;
//        
//        if (currentHeight != _minHeight) {
//            _isChangeHeight = YES;
//        }
//        
//    }
//    NSLog(@"%f",currentHeight);
}

- (void) viewWillDisappear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UITextViewTextDidChangeNotification object:nil];
}

- (IBAction)photoBtnClicked:(id)sender
{
    
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
