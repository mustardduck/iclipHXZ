//
//  UICommon.m
//  CommonFrame_Pro
//
//  Created by 倩 莫 on 15/8/4.
//  Copyright (c) 2015年 ionitech. All rights reserved.
//

#import "UICommon.h"
#import <MobileCoreServices/MobileCoreServices.h>

static UIViewController *imagePicker = nil;

@implementation UICommon

+ (CGSize)getWidthFromLabel:(UILabel *)label
{
    CGSize size = CGSizeMake(MAXFLOAT, H(label));
    if ([UICommon getSystemVersion] > 7.0)//IOS 7.0 以上
    {
        NSDictionary * tdic = [NSDictionary dictionaryWithObjectsAndKeys:label.font, NSFontAttributeName,nil];
        size =[label.text boundingRectWithSize:size options:NSStringDrawingUsesLineFragmentOrigin |NSStringDrawingUsesFontLeading attributes:tdic context:nil].size;
    }
    else
    {
        size = [label.text sizeWithFont:label.font constrainedToSize:size lineBreakMode:NSLineBreakByCharWrapping];//ios7以上已经摒弃的这个方法
    }
    
    return size;
}

+(float)getSystemVersion
{
    return [[[UIDevice currentDevice] systemVersion] floatValue];
}

+ (UIViewController *)getOldViewController:(Class)viewCon withNavController:(UINavigationController *)navController
{
    id ret = nil;
    
    NSArray *array = navController.viewControllers;
    
    if (!array && array.count == 0) return nil;
    
    for (id object in array)
    {
        if ([object isKindOfClass:[viewCon class]])
        {
            ret = object;
        }
    }
    UIViewController *popTarget = ret;
    return popTarget;
}

+ (void)popOldViewController:(Class)viewCon withNavController:(UINavigationController *)navController
{
    UIViewController *model =  [self getOldViewController:viewCon withNavController:navController];
    if (model && [model isKindOfClass:[UIViewController class]])
        [navController popToViewController:model animated:YES];
}

+ (CGSize) getSizeFromString:(NSString *)str withSize:(CGSize)cSize withFont:(UIFont*)font
{
    CGSize size = CGSizeZero;
    
    if([UICommon getSystemVersion] >= 7.0)
    {
        
        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];

        paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
        
        NSDictionary *attributes = [[NSDictionary alloc] initWithObjectsAndKeys:font,NSFontAttributeName,[NSParagraphStyle defaultParagraphStyle],NSParagraphStyleAttributeName, nil];
        
        NSStringDrawingOptions options =  NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading;
        
        size = [str boundingRectWithSize:cSize options:options attributes:attributes context:nil].size;
        
        if(size.height > cSize.height)
        {
            size.height = cSize.height;
        }
        
        size.width = ceil(size.width);

    }
    else
    {
        size = [str sizeWithFont:font constrainedToSize:cSize lineBreakMode:NSLineBreakByWordWrapping];
    }
    
    return size;
}

+ (CGSize)getHeightFromLabel:(UILabel *)label
{
    NSDictionary *attribute = @{NSFontAttributeName: label.font};
    
    CGSize retSize = CGSizeZero;
    
    if([UICommon getSystemVersion] >= 7.0)
    {
        retSize = [label.text boundingRectWithSize:CGSizeMake(W(label), MAXFLOAT)
                   
                                           options:\
                   
                   NSStringDrawingTruncatesLastVisibleLine |
                   
                   NSStringDrawingUsesLineFragmentOrigin |
                   
                   NSStringDrawingUsesFontLeading
                   
                                        attributes:attribute
                   
                                           context:nil].size;
    }
    else
        retSize = [label.text sizeWithFont:label.font constrainedToSize:CGSizeMake(W(label), MAXFLOAT) lineBreakMode:NSLineBreakByWordWrapping];
    
    CGFloat ret = (H(label) - retSize.height)/2;
    retSize.height += ret;
    return retSize;
}

+ (NSString *)dayAndHourFromString:(NSString *)dateString formatStyle:(NSString *)format
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat: @"yyyy-MM-dd HH:mm:ss"];
    NSDate *destDate= [dateFormatter dateFromString:dateString];
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];;
    [formatter setDateFormat:format];
    return [formatter stringFromDate:destDate];

}

+ (NSString*) formatTime:(NSString*)input withLength:(int)length{
    
    if ([input length] == 0) {
        
        return @"";
    }
    
    NSString *text = [input stringByReplacingOccurrencesOfString:@"T" withString:@" "];
    
    if ([text length] > length) {
        
        text = [text substringToIndex:length];
    }
    
    return text;
}

#pragma mark camera utility
+ (BOOL) isCameraAvailable{
    return [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera];
}

+ (BOOL) isPhotoLibraryAvailable{
    return [UIImagePickerController isSourceTypeAvailable:
            UIImagePickerControllerSourceTypePhotoLibrary];
}

+ (BOOL) doesCameraSupportTakingPhotos {
    return [self cameraSupportsMedia:(__bridge NSString *)kUTTypeImage sourceType:UIImagePickerControllerSourceTypeCamera];
}

+ (BOOL) cameraSupportsMedia:(NSString *)paramMediaType sourceType:(UIImagePickerControllerSourceType)paramSourceType{
    __block BOOL result = NO;
    if ([paramMediaType length] == 0) {
        return NO;
    }
    NSArray *availableMediaTypes = [UIImagePickerController availableMediaTypesForSourceType:paramSourceType];
    [availableMediaTypes enumerateObjectsUsingBlock: ^(id obj, NSUInteger idx, BOOL *stop) {
        NSString *mediaType = (NSString *)obj;
        if ([mediaType isEqualToString:paramMediaType]){
            result = YES;
            *stop= YES;
        }
    }];
    return result;
}

#pragma mark image scale utility
+ (UIImage *)imageByScalingToMaxSize:(UIImage *)sourceImage {
    if (sourceImage.size.width < ORIGINAL_MAX_WIDTH) return sourceImage;
    CGFloat btWidth = 0.0f;
    CGFloat btHeight = 0.0f;
    if (sourceImage.size.width > sourceImage.size.height) {
        btHeight = ORIGINAL_MAX_WIDTH;
        btWidth = sourceImage.size.width * (ORIGINAL_MAX_WIDTH / sourceImage.size.height);
    } else {
        btWidth = ORIGINAL_MAX_WIDTH;
        btHeight = sourceImage.size.height * (ORIGINAL_MAX_WIDTH / sourceImage.size.width);
    }
    CGSize targetSize = CGSizeMake(btWidth, btHeight);
    return [self imageByScalingAndCroppingForSourceImage:sourceImage targetSize:targetSize];
}

+ (UIImage *)imageByScalingAndCroppingForSourceImage:(UIImage *)sourceImage targetSize:(CGSize)targetSize {
    UIImage *newImage = nil;
    CGSize imageSize = sourceImage.size;
    CGFloat width = imageSize.width;
    CGFloat height = imageSize.height;
    CGFloat targetWidth = targetSize.width;
    CGFloat targetHeight = targetSize.height;
    CGFloat scaleFactor = 0.0;
    CGFloat scaledWidth = targetWidth;
    CGFloat scaledHeight = targetHeight;
    CGPoint thumbnailPoint = CGPointMake(0.0,0.0);
    if (CGSizeEqualToSize(imageSize, targetSize) == NO)
    {
        CGFloat widthFactor = targetWidth / width;
        CGFloat heightFactor = targetHeight / height;
        
        if (widthFactor > heightFactor)
            scaleFactor = widthFactor; // scale to fit height
        else
            scaleFactor = heightFactor; // scale to fit width
        scaledWidth  = width * scaleFactor;
        scaledHeight = height * scaleFactor;
        
        // center the image
        if (widthFactor > heightFactor)
        {
            thumbnailPoint.y = (targetHeight - scaledHeight) * 0.5;
        }
        else
            if (widthFactor < heightFactor)
            {
                thumbnailPoint.x = (targetWidth - scaledWidth) * 0.5;
            }
    }
    UIGraphicsBeginImageContext(targetSize); // this will crop
    CGRect thumbnailRect = CGRectZero;
    thumbnailRect.origin = thumbnailPoint;
    thumbnailRect.size.width  = scaledWidth;
    thumbnailRect.size.height = scaledHeight;
    
    [sourceImage drawInRect:thumbnailRect];
    
    newImage = UIGraphicsGetImageFromCurrentImageContext();
    if(newImage == nil) NSLog(@"could not scale image");
    
    //pop the context to get back to the default
    UIGraphicsEndImageContext();
    return newImage;
}

+ (void) showImagePicker:(id)delegate view:(UIViewController*)controller{
    imagePicker  = controller;
    if ([self isPhotoLibraryAvailable]) {
        UIImagePickerController *pickerController = [[UIImagePickerController alloc] init];
        pickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        NSMutableArray *mediaTypes = [[NSMutableArray alloc] init];
        [mediaTypes addObject:(__bridge NSString *)kUTTypeImage];
        pickerController.mediaTypes = mediaTypes;
        pickerController.delegate = delegate;
        [imagePicker presentViewController:pickerController
                                  animated:YES
                                completion:^(void){
                                    NSLog(@"Picker View Controller is presented");
                                }];
    }
    
}

+ (void) showCamera:(id)delegate view:(UIViewController*) controller allowsEditing:(BOOL)allow{
    imagePicker  = controller;
    // 拍照
    if ([UICommon isCameraAvailable] && [UICommon doesCameraSupportTakingPhotos]) {
        UIImagePickerController *controller = [[UIImagePickerController alloc] init];
        controller.sourceType = UIImagePickerControllerSourceTypeCamera;
        NSMutableArray *mediaTypes = [[NSMutableArray alloc] init];
        [mediaTypes addObject:(__bridge NSString *)kUTTypeImage];
        controller.mediaTypes = mediaTypes;
        controller.delegate = delegate;
        [imagePicker presentViewController:controller
                                  animated:YES
                                completion:^(void){
                                    NSLog(@"Picker View Controller is presented");
                                }];
    }else{
        [UICommon showImagePicker:delegate view:controller];
    }
}

@end

#pragma mark - UIView
@implementation UIView (RCMethod)

- (void)setRoundCorner:(float)cornerRadius
{
    self.layer.masksToBounds = YES;
    self.layer.borderWidth = 0.5f;
//    self.layer.borderColor = RGBCOLOR(197, 197, 197).CGColor;
    self.layer.cornerRadius = cornerRadius;
}

- (void)setBorderWithColor:(UIColor *)color
{
    self.layer.borderWidth = 0.5f;
    self.layer.borderColor = color.CGColor;
}

@end

@implementation UIViewController (expanded)

- (void) hiddenKeyboard{}

- (void) addDoneToKeyboard:(UIView *)activeView
{
    //定义完成按钮
    UIToolbar * topView = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, 320, 36)];
    [topView setBarStyle:UIBarStyleBlack];
    if ([UICommon getSystemVersion] < 7.0)
    {
        [topView setTintColor:RGBCOLOR(174, 178, 185)];
    }
    else
    {
        [topView setBarTintColor:RGBCOLOR(174, 178, 185)];
    }
    
    UIBarButtonItem * button1 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem: UIBarButtonSystemItemFlexibleSpace target:self action:nil];
    
    UIBarButtonItem * button2 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem: UIBarButtonSystemItemFlexibleSpace target:self action:nil];
    
    UIBarButtonItem * doneButton = [[UIBarButtonItem alloc] initWithTitle:@"完成" style:UIBarButtonItemStyleDone target:self action:@selector(hiddenKeyboard)];
    
    doneButton.tintColor = RGBCOLOR(85, 85, 85);
    
    NSArray * buttonsArray = [NSArray arrayWithObjects:button1,button2,doneButton,nil];
    
    [topView setItems:buttonsArray];
    
    if([activeView isKindOfClass:[UITextField class]])
    {
        UITextField * text = (UITextField *)activeView;
        
        [text setInputAccessoryView:topView];
        
    }
    else
    {
        UITextView * textView = (UITextView *)activeView;
        
        [textView setInputAccessoryView:topView];
    }
}

@end

@implementation UIColor (Addition)

+ (UIColor *) disableGreyColor
{
    return RGBCOLOR(99, 99, 102);
}

+ (UIColor *) greyStatusBarColor
{
    return RGBCOLOR(35, 34, 39);
}

+ (UIColor *) cellHoverBackgroundColor
{
    return RGBCOLOR(43, 42, 47);
}

@end
