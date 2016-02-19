//
//  MQPersonalInfoVC.m
//  CommonFrame_Pro
//
//  Created by 倩 莫 on 16/2/18.
//  Copyright © 2016年 ionitech. All rights reserved.
//

#import "MQPersonalInfoVC.h"
#import "UIImageView+UIActivityIndicatorForSDWebImage.h"
#import <ZYQAssetPickerController.h>
#import "VPImageCropperViewController.h"
#import "SVProgressHUD.h"
#import "UICommon.h"
#import "MQPersonalInfoFieldEditVC.h"

@interface MQPersonalInfoVC ()<ZYQAssetPickerControllerDelegate,UIActionSheetDelegate,UINavigationControllerDelegate,UIImagePickerControllerDelegate, VPImageCropperDelegate>
{
    NSString *          _currentFileName;

}
@property (weak, nonatomic) IBOutlet UIImageView *photo;
@property (weak, nonatomic) IBOutlet UILabel *nameLbl;
@property (weak, nonatomic) IBOutlet UILabel *jobLbl;
@property (weak, nonatomic) IBOutlet UILabel *mobileLbl;
@property (weak, nonatomic) IBOutlet UILabel *emailLbl;
@property (weak, nonatomic) IBOutlet UIButton *nameBtn;
@property (weak, nonatomic) IBOutlet UIButton *mobileBtn;
@property (weak, nonatomic) IBOutlet UIButton *emailBtn;

@end

@implementation MQPersonalInfoVC

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

    _user = [LoginUser getLoginInfo];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) viewWillAppear:(BOOL)animated
{
    
    [_photo setImageWithURL:[NSURL URLWithString:_user.img] placeholderImage:[UIImage imageNamed:@"icon_chengyuan"] options:SDWebImageDelayPlaceholder usingActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    
    _nameLbl.text = _user.name;
    _jobLbl.text = _user.duty;
    _mobileLbl.text = _user.mobile;
    _emailLbl.text = _user.email;
}

- (void) viewWillDisappear:(BOOL)animated
{
    if ([self.icMainVC respondsToSelector:@selector(setIsNotRefreshMain:)]) {
        [self.icMainVC setValue:@"1" forKey:@"isNotRefreshMain"];
    }
}

- (IBAction)touchUpInsideOnBtn:(id)sender
{
    UIButton * btn = (UIButton *)sender;
    
    NSInteger tag = btn.tag;
    
    if(tag == 1)
    {
        UIActionSheet* as = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"拍照", @"从相册选取",nil];
        [as showInView:self.view];
    }
    else if (tag >= 2 && tag <= 4)
    {
        UIStoryboard* mainStory = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        UIViewController* vc  = [mainStory instantiateViewControllerWithIdentifier:@"MQPersonalInfoFieldEditVC"];
        
        ((MQPersonalInfoFieldEditVC * )vc).type = tag;
        ((MQPersonalInfoFieldEditVC * )vc).user = _user;
        [self.navigationController pushViewController:vc animated:YES];
    }
}

- (IBAction)backButtonClicked:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - UIImagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    [picker dismissViewControllerAnimated:YES completion:^() {
        
        NSString * dateTime = [[info[@"UIImagePickerControllerMediaMetadata"] objectForKey:@"{TIFF}"] objectForKey:@"DateTime"];
        
        _currentFileName = [NSString stringWithFormat:@"%@.png", dateTime];
        
        UIImage *portraitImg = [info objectForKey:@"UIImagePickerControllerOriginalImage"];
        portraitImg = [UICommon imageByScalingToMaxSize:portraitImg];
        // present the cropper view controller
        VPImageCropperViewController *imgCropperVC = [[VPImageCropperViewController alloc] initWithImage:portraitImg cropFrame:CGRectMake(0, 100.0f, self.view.frame.size.width, self.view.frame.size.width) limitScaleRatio:3.0];
        imgCropperVC.delegate = self;
        [self presentViewController:imgCropperVC animated:YES completion:^{
            // TO DO
        }];
    }];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:^(){
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


#pragma mark VPImageCropperDelegate
- (void)imageCropper:(VPImageCropperViewController *)cropperViewController didFinished:(UIImage *)editedImage {
    
    NSString * userImgPath = @"";
    
    BOOL isOk = [LoginUser uploadImageWithScale:editedImage fileName:_currentFileName userImgPath:&userImgPath];
    
    if(isOk)
    {
//        _photo.image = editedImage;
        _user.img = userImgPath;

        [_photo setImageWithURL:[NSURL URLWithString:_user.img] placeholderImage:[UIImage imageNamed:@"icon_chengyuan"] options:SDWebImageDelayPlaceholder usingActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];

        dispatch_async(dispatch_get_main_queue(), ^{
            BOOL isOk = [LoginUser updateInfo:_nameLbl.text phone:_mobileLbl.text email:_emailLbl.text photo:_user.img];
            if (isOk) {
                
                [SVProgressHUD showSuccessWithStatus:@"更新资料成功"];
                
                _user = [LoginUser getLoginInfo];
            }
            else
            {
                [SVProgressHUD showErrorWithStatus:@"更新资料失败"];
            }
            
        });

    }
    
    
    [cropperViewController dismissViewControllerAnimated:YES completion:^{
        // TO DO
    }];
}

- (void)imageCropperDidCancel:(VPImageCropperViewController *)cropperViewController {
    [cropperViewController dismissViewControllerAnimated:YES completion:^{
    }];
}

#pragma mark - ZYQAssetPickerController Delegate
-(void)assetPickerController:(ZYQAssetPickerController *)picker didFinishPickingAssets:(NSArray *)assets
{
    [picker dismissViewControllerAnimated:YES completion:^()
     {
         NSLog(@"%@",assets);
         
         if (assets.count > 0) {
                          
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
         }
     }];
    
}


@end
