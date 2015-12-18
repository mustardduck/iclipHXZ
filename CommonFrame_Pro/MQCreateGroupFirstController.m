//
//  MQCreateGroupFirstController.m
//  CommonFrame_Pro
//
//  Created by 倩 莫 on 15/12/3.
//  Copyright © 2015年 ionitech. All rights reserved.
//

#import "MQCreateGroupFirstController.h"
#import "UICommon.h"
#import "PH_UITextView.h"
#import "Accessory.h"
#import <ZYQAssetPickerController.h>
#import "UIButton+UIActivityIndicatorForSDWebImage.h"
#import "VPImageCropperViewController.h"
#import "SVProgressHUD.h"
#import "MQCreateGroupSecondController.h"
#import "ICMemberInvitationTableViewController.h"
#import "DashesLineView.h"

@interface MQCreateGroupFirstController ()<UITextViewDelegate, UITextFieldDelegate, ZYQAssetPickerControllerDelegate, VPImageCropperDelegate, UIActionSheetDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate>
{
    CGFloat _currentHeight;
    
    UIView * _currentView;
    
//    NSString        *_workGroupId;

    NSString *      _currentFileName;

}

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *photoViewHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *textViewHieght;
@property (weak, nonatomic) IBOutlet UIImageView *groupImg;
@property (weak, nonatomic) IBOutlet UIButton *photoBtn;

@property (weak, nonatomic) IBOutlet UITextField *groupTitleTxt;
@property (weak, nonatomic) IBOutlet PH_UITextView *sloganTextView;
@property (weak, nonatomic) IBOutlet UILabel *sloganPlaceholder;
@property (weak, nonatomic) IBOutlet UIScrollView *mainScrollView;
@property (weak, nonatomic) IBOutlet UIView *topImgView;

@end

@implementation MQCreateGroupFirstController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textChangeed:) name:UITextViewTextDidChangeNotification object:nil];
    
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
    
    _currentHeight = 32;
    
    [self addDoneToKeyboard:_sloganTextView];
    [self addDoneToKeyboard:_groupTitleTxt];

    self.workGroup = [Group new];
    
    [_topImgView setRoundCorner:3.3];
    
    //虚线
    DashesLineView * dashLine = [[DashesLineView alloc] init];
    dashLine.frame = CGRectMake(18, 205, 171, 0.5);
    dashLine.backgroundColor = [UIColor clearColor];
    [_topImgView addSubview:dashLine];
}

- (void) textFieldDidBeginEditing:(UITextField *)textField
{
    _currentView =  textField;
    
    [_mainScrollView setContentOffset:CGPointMake(0, 150) animated:YES];

}

- (void) textFieldDidEndEditing:(UITextField *)textField
{
    [_mainScrollView setContentOffset:CGPointMake(0, 0) animated:YES];

}

- (void) textViewDidBeginEditing:(UITextView *)textView
{
    _currentView = textView;
    _sloganPlaceholder.hidden = YES;
    
    [_mainScrollView setContentOffset:CGPointMake(0, 200) animated:YES];
}

- (void) textViewDidEndEditing:(UITextView *)textView
{
    if(textView.text.length)
    {
        _sloganPlaceholder.hidden = YES;
    }
    else
    {
        _sloganPlaceholder.hidden = NO;
    }
    
    [_mainScrollView setContentOffset:CGPointMake(0, 0) animated:YES];

}

- (void) hiddenKeyboard
{
    [_currentView resignFirstResponder];
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
        _textViewHieght.constant = _textViewHieght.constant + newHeight;
        
        _currentHeight = currentHeight;
    }
}

- (IBAction)backButtonClicked:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)doneButtonClicked:(id)sender
{
//    [self jumpToSecondView];
////    [self jumpToInvite];
//    return;
    
    [self hiddenKeyboard];
    NSString* name = _groupTitleTxt.text;
    NSString* desc = _sloganTextView.text;
    
    if ([self.viewType intValue] == ViewTypeEdit) {

        NSString* img = self.workGroup.workGroupImg;
        NSString* wgid = self.workGroup.workGroupId;
        
        [SVProgressHUD showInfoWithStatus:@"群组修改中..."];

        dispatch_async(dispatch_get_main_queue(), ^{
            
            BOOL isOk = [Group updateGroup:wgid name:name description:desc groupImage:img];
            if (isOk) {

                [SVProgressHUD showSuccessWithStatus:@"群组修改成功"];
                
                _workGroup.workGroupName = name;
                _workGroup.workGroupMain = desc;
                _workGroup.workGroupImg = img;
                if(_groupImg.image)
                {
                    _workGroup.workGroupImage = _groupImg.image;
                }
                
                [self jumpToSecondView];
            }
            else
            {
                [SVProgressHUD showErrorWithStatus:@"群组修改失败"];
            }
        });
    }
    else
    {
        if ((name == nil || [name isEqualToString:@""]) || (desc == nil || [desc isEqualToString:@""])) {
            UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"群组名和愿景及使命不能为空!" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            [alert show];
            return;
        }
        
        NSString* img = @"";
        
        img  = _workGroup.workGroupImg;
        
//        if (_cAccessoryArray.count > 0) {
//            Accessory* acc = [_cAccessoryArray objectAtIndex:0];
//            img = acc.address;
//        }
        
        [SVProgressHUD showInfoWithStatus:@"群组创建中..."];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            NSString * workGId = @"";
            
            BOOL isOk = [Group createNewGroup:name description:desc groupImage:img workGroupId:&workGId];
            if (isOk) {
//                UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"成功" message:@"群组已创建!" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
//                [alert  show];
                [SVProgressHUD showSuccessWithStatus:@"群组创建成功"];
                
//                _workGroupId = [NSString stringWithFormat:@"%@", workGId];
                
                _workGroup.workGroupName = name;
                _workGroup.workGroupMain = desc;
                _workGroup.workGroupImg = img;
                _workGroup.workGroupId = workGId;
                if(_groupImg.image)
                {
                    _workGroup.workGroupImage = _groupImg.image;
                }
                
                [self jumpToSecondView];
                
//                [self jumpToMainView:_workGroupId];
                
            }
            else
            {
                [SVProgressHUD showErrorWithStatus:@"群组创建失败"];
            }
        });
        
        
        
    }
}

- (void) jumpToInvite
{
    UIStoryboard* mainStory = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
     UIViewController* controller  = [mainStory instantiateViewControllerWithIdentifier:@"ICMemberInvitationTableViewController"];
    ((ICMemberInvitationTableViewController*)controller).workGroupId = @"1015082214210001";
    
    [self.navigationController pushViewController:controller animated:YES];

}

- (void) jumpToSecondView
{
    UIStoryboard* mainStory = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    UIViewController* vc = [mainStory instantiateViewControllerWithIdentifier:@"MQCreateGroupSecondController"];
    ((MQCreateGroupSecondController*)vc).workGroup = _workGroup;
    ((MQCreateGroupSecondController*)vc).icCreateGroupFirstController = self;

    [self.navigationController pushViewController:vc animated:YES];
}

- (void) viewWillAppear:(BOOL)animated
{
    if([_viewType intValue] == ViewTypeEdit)
    {
        
    }
}

- (void) viewWillDisappear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UITextViewTextDidChangeNotification object:nil];
}

- (IBAction)photoBtnClicked:(id)sender
{
    [self hiddenKeyboard];
    UIActionSheet* as = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"拍照", @"从相册选取",nil];
    [as showInView:self.view];
}


#pragma mark - UIImagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    [picker dismissViewControllerAnimated:YES completion:^() {
        
        if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
        {
            NSString * dateTime = [[info[@"UIImagePickerControllerMediaMetadata"] objectForKey:@"{TIFF}"] objectForKey:@"DateTime"];
            
            _currentFileName = [NSString stringWithFormat:@"%@.png", dateTime];

//            _currentFileName = @"IMG_test.JPG";
            
            UIImage *portraitImg = [info objectForKey:@"UIImagePickerControllerOriginalImage"];
            portraitImg = [UICommon imageByScalingToMaxSize:portraitImg];
            // present the cropper view controller
            VPImageCropperViewController *imgCropperVC = [[VPImageCropperViewController alloc] initWithImage:portraitImg cropFrame:CGRectMake(0, 100.0f, self.view.frame.size.width, self.view.frame.size.width) limitScaleRatio:3.0];
            imgCropperVC.delegate = self;
            [self presentViewController:imgCropperVC animated:YES completion:^{
                // TO DO
            }];
        }

    }];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:^(){
    }];
}

#pragma mark VPImageCropperDelegate
- (void)imageCropper:(VPImageCropperViewController *)cropperViewController didFinished:(UIImage *)editedImage {
    
    NSString * userImgPath = @"";
    
    BOOL isOk = [LoginUser uploadImageWithScale:editedImage fileName:_currentFileName userImgPath:&userImgPath];
    
    if(isOk)
    {
        UIImageView* img = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 60, 60)];
        [img setBackgroundColor:[UIColor clearColor]];
        [img setImage:editedImage];
        
        _groupImg.contentMode = UIViewContentModeScaleToFill;
        _groupImg.image = img.image;
//        [_groupImg setImage:img.image forState:UIControlStateNormal];
        
        self.workGroup.workGroupImg = userImgPath;
    }
    
    [cropperViewController dismissViewControllerAnimated:YES completion:^{
        // TO DO
    }];
}

- (void)imageCropperDidCancel:(VPImageCropperViewController *)cropperViewController {
    [cropperViewController dismissViewControllerAnimated:YES completion:^{
    }];
}

#pragma mark -
#pragma UIActionSheet Deleget
-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0)
    {
        UIImagePickerController *ctrl = [[UIImagePickerController alloc] init];
        ctrl.delegate = self;
        ctrl.sourceType = UIImagePickerControllerSourceTypeCamera;
        [self presentViewController:ctrl animated:YES completion:nil];
    }
    else if (buttonIndex == 1)
    {
        ZYQAssetPickerController *picker = [[ZYQAssetPickerController alloc] init];
        picker.maximumNumberOfSelection = 1;
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
            
            portraitImg = [UICommon imageByScalingToMaxSize:portraitImg];
            // present the cropper view controller
            VPImageCropperViewController *imgCropperVC = [[VPImageCropperViewController alloc] initWithImage:portraitImg cropFrame:CGRectMake(0, 100.0f, self.view.frame.size.width, self.view.frame.size.width) limitScaleRatio:3.0];
            imgCropperVC.delegate = self;
            [self presentViewController:imgCropperVC animated:YES completion:^{
                // TO DO
            }];
        }];
        
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
