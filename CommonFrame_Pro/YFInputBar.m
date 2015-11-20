//
//  ICSideMenuController.m
//  CDSideBar
//
//  Created by ionitech on 15/6/4.
//  Copyright (c) 2015年 Christophe Dellac. All rights reserved.
//

#import "YFInputBar.h"
#import "AppDelegate.h"

@interface YFInputBar()
{
    CGFloat _minHeight;
    CGFloat _currentHeight;
    
    BOOL    _isChangeHeight;
    CGRect _tmp_originalFrame;
    
    BOOL    _isSendButtonClicked;
    BOOL    _isBackClicked;
    CGFloat _defaultHeight;
    BOOL    _hasReg;
    
    CGRect  _oriFrame;
    
    CGRect  _relativeControlOriFrame;
    
    BOOL    _hasShowed;
}

@end

@implementation YFInputBar


-(id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        self.frame = CGRectMake(0, CGRectGetMinY(frame), [UIScreen mainScreen].bounds.size.width, CGRectGetHeight(frame));
        [self keybord];
    }
    return self;
}

- (void)keybord
{
    if (!_hasReg) {
        self.backgroundColor = [UIColor blackColor];
        self.textField.tag = 10000;
        self.sendBtn.tag = 10001;
        
        //注册键盘通知
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textChangeed:) name:UITextViewTextDidChangeNotification object:nil];
        _hasReg = YES;
    }
}

-(void)setFrame:(CGRect)frame
{
    //[self keybord];
    [super setFrame:frame];
    _originalFrame = frame;
}

-(void)setOriginalFrame:(CGRect)originalFrame
{
    self.frame = CGRectMake(0, CGRectGetMinY(originalFrame), 320, CGRectGetHeight(originalFrame));
}

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UITextViewTextDidChangeNotification object:nil];
}

- (void)textChangeed:(id)sender
{
    [self removeType];
    
    CGFloat currentHeight = _textField.contentSize.height;
    CGFloat newHeight = currentHeight - _currentHeight;
    
    if (currentHeight < 120) {
        self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y  - newHeight, self.frame.size.width, self.frame.size.height +  newHeight);
        
        _textField.frame = CGRectMake(_textField.frame.origin.x, (self.bounds.size.height - (_textField.frame.size.height +  newHeight))/2 , _textField.frame.size.width, _textField.frame.size.height +  newHeight);
        
        _currentHeight = currentHeight;
        
        if (currentHeight != _minHeight) {
            _isChangeHeight = YES;
        }

    }
    NSLog(@"%f",currentHeight);
}


-(PH_UITextView *)textField
{
    if (!_textField) {
        //btn_zengjia 26
        //btn_jianpan
        self.btnType = [[UIButton alloc] init];
        _btnType.frame = CGRectMake(14, (self.bounds.size.height - 26)/2, 26, 26);
        [_btnType setImage:[UIImage imageNamed:@"btn_zengjia"] forState:UIControlStateNormal];
        [_btnType setBackgroundColor:[UIColor clearColor]];
//        [b_btnTypetnType  setTitle:@"＋" forState:UIControlStateNormal];
        [_btnType addTarget:self action:@selector(btnTypePress:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_btnType];
        
        
        _textField = [[PH_UITextView alloc]initWithFrame:CGRectMake(54, (self.bounds.size.height - 38)/2, [UIScreen mainScreen].bounds.size.width - 70 - 54, 38)];
        _textField.backgroundColor = [UIColor whiteColor];
        _textField.layer.cornerRadius = 5;
        _textField.font = [UIFont systemFontOfSize:18];
        _textField.delegate = self;
//        [_textField setReturnKeyType:UIReturnKeySend];
        [_textField setKeyboardType:UIKeyboardTypeDefault];

        self.sendCommentBtn = [[UIButton alloc] init];
        _sendCommentBtn.frame = CGRectMake(XW(_textField) + 14, Y(_textField), 44, 38);
        [_sendCommentBtn setRoundCorner:5];
        [_sendCommentBtn setBackgroundColor:RGBCOLOR(76, 215, 100)];
        [_sendCommentBtn setTitle:@"发送" forState:UIControlStateNormal];
        _sendCommentBtn.titleLabel.textColor = [UIColor whiteColor];
        _sendCommentBtn.titleLabel.font = Font(15);        
        
        _minHeight = 38;
        _currentHeight = 38;
        _isChangeHeight = NO;
        _tmp_originalFrame = self.frame;
        
        [self addSubview:_textField];
        [self addSubview:_sendCommentBtn];

        //[_textField becomeFirstResponder];
        _isSendButtonClicked = NO;
        _hasShowed = NO;
        
    }
    return _textField;
}
-(UIButton *)sendBtn
{
    if (!_sendBtn) {
        _sendBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_sendBtn setTitle:@"发送" forState:UIControlStateNormal];
//        [_sendBtn setBackgroundColor:[UIColor whiteColor]];
        [_sendBtn setFrame:CGRectMake(self.frame.size.width - 50, (self.bounds.size.height - 24)/2, 40, 24)];
        [_sendBtn addTarget:self action:@selector(sendBtnPress:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_sendBtn];
        
        [_sendBtn setHidden:YES];
    }
    return _sendBtn;
}
#pragma mark selfDelegate method
-(void)btnSendCommentPress:(id)sender
{
    [_textField resignFirstResponder];
    
//    if (self.delegate&&[self.delegate respondsToSelector:@selector(inputBarSendComment:)]) {
//        [self.delegate inputBarSendComment:self];
//    }
}


-(void)btnTypePress:(id)sender
{
    [_textField resignFirstResponder];
    if ( _btnTypeHasClicked == YES) {
        [_btnType setImage:[UIImage imageNamed:@"btn_zengjia"] forState:UIControlStateNormal];

        [self removeType];
        [_textField becomeFirstResponder];
        _btnTypeHasClicked = NO;
        return;
    }
    
    [_btnType setImage:[UIImage imageNamed:@"btn_jianpan"] forState:UIControlStateNormal];

    _btnTypeHasClicked = YES;
     _oriFrame = self.frame;
    
    
    self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y  - 252, self.frame.size.width, self.frame.size.height +  252);
    
//    self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, self.frame.size.width, self.frame.size.height +  252);
//
//    
//    [UIView animateWithDuration:0.3
//                          delay:0
//                        options:UIViewAnimationOptionCurveEaseInOut
//                     animations:^{
//                         self.transform = CGAffineTransformMakeTranslation(self.frame.origin.x, self.frame.origin.y  - 252);
//                     } completion:nil];
    
    
    int lineCount = 4;
    
    CGFloat accHeight = 80;
    CGFloat imgHeight = 50;
    CGFloat accWidth = 68;
    CGFloat leftX = 24;
    
    CGFloat intevalHeight = (SCREENWIDTH - leftX * 2 - accWidth * lineCount) / (lineCount - 1);
    if(intevalHeight < 0)
    {
        intevalHeight = 0;
    }
    
    CGFloat attchHeight = ((self.typeList.count - 1) / lineCount + 1) * accHeight;
    
    UIView* attchView = [[UIView alloc] initWithFrame:CGRectMake(leftX, YH(_textField) + 27, self.frame.size.width - leftX * 2, attchHeight)];
    [attchView setBackgroundColor:[UIColor clearColor]];
    [attchView setTag:1011];
    
    for(int i = 0; i < self.typeList.count; i ++)
    {
        int j = i / lineCount;
        
        int k = i % lineCount;
        
        CGRect attaFrame = CGRectMake(9 + (accWidth + intevalHeight) * k, accHeight * j, imgHeight, imgHeight);
        
        UIImageView* attachment = [[UIImageView alloc] initWithFrame:attaFrame];
        attachment.userInteractionEnabled = YES;
        
        UILabel * fileNameLbl = [[UILabel alloc] init];
        fileNameLbl.frame = CGRectMake(X(attachment) - 9, YH(attachment), accWidth, 40);
        fileNameLbl.backgroundColor = [UIColor clearColor];
        fileNameLbl.textColor = [UIColor whiteColor];
        fileNameLbl.numberOfLines = 2;
        fileNameLbl.textAlignment = NSTextAlignmentCenter;
        fileNameLbl.text = self.typeList[i];
        fileNameLbl.font = Font(10);
        [attachment addSubview:fileNameLbl];
        
        UIButton * imgBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, W(attachment), H(attachment))];
        imgBtn.backgroundColor = [UIColor clearColor];
        imgBtn.tag = i;
        [imgBtn addTarget:self action:@selector(btnSubType:) forControlEvents:UIControlEventTouchUpInside];

        [attachment addSubview:imgBtn];
        
        [attchView addSubview:attachment];
        [attchView addSubview:fileNameLbl];
        
        NSString * imageName = @"btn_pishi";
        if(i == 0)
        {
            UIImageView* gouImgView = [[UIImageView alloc] initWithFrame:CGRectMake(X(attachment) + imgHeight - 11, Y(attachment) - 8, 18, 18)];
            gouImgView.image = [UIImage imageNamed:@"icon_gouxuan"];
            gouImgView.tag = 400;
            gouImgView.hidden = !_pishiClicked;
            [attchView addSubview:gouImgView];

        }
        else if(i == 1)
        {
            imageName = @"btn_paizhao";
        }
        else if (i == 2)
        {
            imageName = @"btn_zhaopian";
        }
        else if (i == 3)
        {
            imageName = @"btn_fujianku";
        }
        
        attachment.image = [UIImage imageNamed:imageName];
        

    }
    
    [self addSubview:attchView];
    
}

-(void)btnSubType:(UIButton*)btnSender
{
    
    NSInteger tag = btnSender.tag;
    //NSString* type = [self.typeList objectAtIndex:tag];
    
    _sendBtn.tag = tag;
    
    if (self.delegate&&[self.delegate respondsToSelector:@selector(inputBarWithFile:)]) {
        [self.delegate inputBarWithFile:self];
    }
    if(tag == 0)
    {
        NSString* textStr = _textField.text;
        
        if ([textStr containsString:@"@"] && [textStr containsString:@":"]) {
            NSString* ty = [textStr substringFromIndex:4];
            textStr = ty;
        }
        
        _textField.text = textStr;
        [_textField becomeFirstResponder];
        
        [self removeType];
        
        
        [_btnType setImage:[UIImage imageNamed:@"btn_zengjia"] forState:UIControlStateNormal];
    }
    else
    {
        self.pishiClicked = NO;
        
        UIView * gouxuanIcon = [[self viewWithTag:1011] viewWithTag:400];
        gouxuanIcon.hidden = YES;
    }
}

- (void) textViewDidBeginEditing:(UITextView *)textView
{
    [_btnType setImage:[UIImage imageNamed:@"btn_zengjia"] forState:UIControlStateNormal];

}

- (void) textViewDidEndEditing:(UITextView *)textView
{
    [_btnType setImage:[UIImage imageNamed:@"btn_zengjia"] forState:UIControlStateNormal];
    
}

- (void)removeType
{
    for (UIControl* control in self.subviews) {
        if (control.tag == 1011) {
            [control removeFromSuperview];
            break;
        }
    }
    
    if (_btnTypeHasClicked) {
        
        self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y  + 252, self.frame.size.width, self.frame.size.height - 252);
        
//        self.transform = CGAffineTransformTranslate(CGAffineTransformIdentity, self.frame.origin.x, self.frame.origin.y  + 252);

        
        _oriFrame  = self.frame;
        _btnTypeHasClicked = NO;
        
        [_btnType setImage:[UIImage imageNamed:@"btn_zengjia"] forState:UIControlStateNormal];

    }
    
}

-(void)sendBtnPress:(UIButton*)sender
{
    [self send];
}

-(void)send
{
//    _isSendButtonClicked = YES;
//    _isBackClicked = NO;
    if (self.delegate&&[self.delegate respondsToSelector:@selector(inputBar:sendBtnPress:withInputString:)]) {
        [self.delegate inputBar:self sendBtnPress:_sendBtn withInputString:self.textField.text];
    }

    [self resetInputBar];
}

- (void)resetInputBar
{
    _isSendButtonClicked = YES;
    _isBackClicked = NO;
    
    if (self.clearInputWhenSend) {
        self.textField.text = @"";
    }
    if (self.resignFirstResponderWhenSend) {
        [self resignFirstResponder];
    }
    
    self.frame = _tmp_originalFrame;
    
    _textField.frame = CGRectMake(_textField.frame.origin.x, _textField.frame.origin.y , _textField.frame.size.width, _minHeight);
    _currentHeight = 38;
    
    _sendBtn.tag = 10001;
    [_btnType  setTitle:@"＋" forState:UIControlStateNormal];
}

//- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
//{
//     if ([text isEqualToString:@"\n"]){
//         [self send];
//         return NO;
//     }
//    return YES;
//}

#pragma mark keyboardNotification

- (void)keyboardWillShow:(NSNotification*)notification{
    
    CGRect _keyboardRect = [[[notification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    //NSLog(@"%f-%f-%f-%f",_keyboardRect.origin.y, _keyboardRect.size.height, [self getHeighOfWindow]-CGRectGetMaxY(self.frame), CGRectGetMinY(self.frame));
    
    [self removeType];
    [self keyHide];
    //_relativeControlOriFrame = self.relativeControl.frame;
    
    CGFloat oy = [self convertYToWindow:CGRectGetMaxY(self.originalFrame)];
    if (oy >= _keyboardRect.origin.y)
    {
        if (self.frame.origin.y == self.originalFrame.origin.y)
        {
            CGFloat winHeihgt = [self getHeighOfWindow];
            CGFloat y = winHeihgt - _keyboardRect.size.height - CGRectGetMaxY(self.originalFrame) - (winHeihgt - CGRectGetMaxY(self.frame));
            
            [UIView animateWithDuration:0.3
                                  delay:0
                                options:UIViewAnimationOptionCurveEaseInOut
                             animations:^{
                                 self.transform = CGAffineTransformMakeTranslation(0, y);
                             } completion:nil];
            
            for (UIControl* control in ((ICWorkingDetailViewController*)self.parentController).view.subviews) {
                
                if ([control isKindOfClass:[UITableView class]]) {
                    
                    CGRect afr = ((ICWorkingDetailViewController*)self.parentController).tableView.frame;
                    if (CGRectGetWidth(afr) == 0 && CGRectGetHeight(afr) == 0) {
                        CGRect frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height - 44 - 66);
                        _relativeControlOriFrame = frame;
                    }
                    else
                        _relativeControlOriFrame = afr;
                    control.frame = CGRectMake(_relativeControlOriFrame.origin.x, _relativeControlOriFrame.origin.y, _relativeControlOriFrame.size.width, _relativeControlOriFrame.size.height + y);
                    
                    NSInteger index = ((ICWorkingDetailViewController*)self.parentController).indexRow;
                    if (index != 1099) {
                        NSIndexPath* buttomIndexPath = [NSIndexPath indexPathForRow:index inSection:0];
                        [((UITableView*)control) scrollToRowAtIndexPath:buttomIndexPath atScrollPosition:UITableViewScrollPositionBottom animated:YES];
                    }
                    else
                    {
                        NSIndexPath* buttomIndexPath = [NSIndexPath indexPathForRow:(((ICWorkingDetailViewController*)self.parentController).replyList.count - 1) inSection:0];
                        [((UITableView*)control) scrollToRowAtIndexPath:buttomIndexPath atScrollPosition:UITableViewScrollPositionBottom animated:YES];
                    }
                    
                    break;
                }
            }
            _hasShowed = YES;
            
        }
        else
        {
            if (_hasShowed == YES) {
                return;
            }
            CGFloat winHeihgt = [self getHeighOfWindow];
            CGFloat y = - _keyboardRect.size.height + winHeihgt - CGRectGetMaxY(_tmp_originalFrame);
            self.transform = CGAffineTransformMakeTranslation(0, y);
            //self.relativeControl.transform = CGAffineTransformMakeTranslation(0, y);
            
        }
        
    }
    else
    {
        
    }
}

- (void)keyboardWillHide:(NSNotification*)notification
{
    [self keyHide];
    
    [self resetInputBar];
    
}

- (void)keyHide
{
    [UIView animateWithDuration:0.3
                          delay:0
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         self.transform = CGAffineTransformMakeTranslation(0,0);
                         //if (_btnTypeHasClicked)
                         //self.relativeControl.transform = CGAffineTransformMakeTranslation(0,0);
                     } completion:nil];
    
    for (UIControl* control in ((UIViewController*)self.parentController).view.subviews) {
        if ([control isKindOfClass:[UITableView class]]) {
            control.frame = CGRectMake(_relativeControlOriFrame.origin.x, _relativeControlOriFrame.origin.y, _relativeControlOriFrame.size.width, _relativeControlOriFrame.size.height);
            _relativeControlOriFrame = control.frame;
            
            NSInteger index = ((ICWorkingDetailViewController*)self.parentController).indexRow;
            if (index != 1099) {
                NSIndexPath* buttomIndexPath = [NSIndexPath indexPathForRow:index inSection:0];
                [((UITableView*)control) scrollToRowAtIndexPath:buttomIndexPath atScrollPosition:UITableViewScrollPositionBottom animated:YES];
            }
            else
            {
                NSIndexPath* buttomIndexPath = [NSIndexPath indexPathForRow:(((ICWorkingDetailViewController*)self.parentController).replyList.count - 1) inSection:0];
                [((UITableView*)control) scrollToRowAtIndexPath:buttomIndexPath atScrollPosition:UITableViewScrollPositionBottom animated:YES];
            }
            
            break;
        }
    }
    _hasShowed = NO;
}

#pragma  mark ConvertPoint
//将坐标点y 在window和superview转化  方便和键盘的坐标比对
-(float)convertYFromWindow:(float)Y
{
    AppDelegate *appDelegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
    CGPoint o = [appDelegate.window convertPoint:CGPointMake(0, Y) toView:self.superview];
    return o.y;
    
}
-(float)convertYToWindow:(float)Y
{
    AppDelegate *appDelegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
    CGPoint o = [self.superview convertPoint:CGPointMake(0, Y) toView:appDelegate.window];
    return o.y;
    
}
-(float)getHeighOfWindow
{
    AppDelegate *appDelegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
    return appDelegate.window.frame.size.height;
}



-(BOOL)resignFirstResponder
{
    
    [self.textField resignFirstResponder];
    return [super resignFirstResponder];
}
@end
