//
//  BookView.m
//  Newsstand
//
//  Created by HsiuJane Sang on 2/11/12.
//  Copyright (c) 2012 JiaYuan. All rights reserved.
//

#import "BookView.h"
#import <QuartzCore/QuartzCore.h>

#define LABEL_HEIGHT  20.0

@implementation BookView

@synthesize cover=_cover;
@synthesize title=_title;
@synthesize button=_button;

@synthesize issueID=_issueID;
@synthesize subtitle = _subtitle;
@synthesize delegate=_delegate;
@synthesize editMode =_editMode;
@synthesize bookInfo;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        //self.frame = CGRectMake(0, 0, 200, 307);
        CGFloat width = frame.size.width;
        CGFloat offset = 10;
        UIButton *bgBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [bgBtn setBackgroundImage:[UIImage imageNamed:@"home_book_bg~ipad"] forState:UIControlStateNormal];
        bgBtn.frame = CGRectMake(offset, offset, frame.size.width-offset, frame.size.height-offset);
        [bgBtn addTarget:self action:@selector(buttonCallback:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:bgBtn];
        
        self.backgroundColor = [UIColor clearColor];
        // title label
        
        self.title = [[[UILabel alloc] initWithFrame:CGRectMake((width-COVER_WIDTH)/2+offset, COVER_HEIGHT+20+DELETE_WIDTH/2, COVER_WIDTH, LABEL_HEIGHT)] autorelease];
        _title.font=[UIFont boldSystemFontOfSize:17];
        _title.textColor=[UIColor blackColor];
        _title.backgroundColor=[UIColor clearColor];
        _title.textAlignment=UITextAlignmentLeft;
        _title.numberOfLines = 0;
        self.subtitle = [[[UILabel alloc] initWithFrame:CGRectMake((width-COVER_WIDTH)/2+offset, COVER_HEIGHT+20+LABEL_HEIGHT+DELETE_WIDTH/2, COVER_WIDTH, LABEL_HEIGHT *2)] autorelease];
        _subtitle.font=[UIFont systemFontOfSize:SECOND_FONT_SIZE];
        _subtitle.textColor=[UIColor darkGrayColor];
        _subtitle.backgroundColor=[UIColor clearColor];
        _subtitle.textAlignment=UITextAlignmentLeft;
        _subtitle.numberOfLines = 0;
        // cover image
        self.cover = [[[UIImageView alloc] initWithFrame:CGRectMake((width-COVER_WIDTH)/2 +offset/2, 10.0+offset, COVER_WIDTH, COVER_HEIGHT)] autorelease];
        _cover.backgroundColor=[UIColor clearColor];
        _cover.contentMode=UIViewContentModeScaleAspectFit;
      
        self.button = [UIButton buttonWithType:UIButtonTypeCustom];
        
        [_button setBackgroundImage:[UIImage imageNamed:@"mybook_btn_delete"] forState:UIControlStateNormal];
        [_button addTarget:self action:@selector(buttonActionCallback:) forControlEvents:UIControlEventTouchUpInside];
        _button.frame=CGRectMake(0, 0, DELETE_WIDTH, DELETE_WIDTH);
        _button.hidden = YES;
        
        [self addSubview:_subtitle];
        [self addSubview:_title];
        [self addSubview:_cover];
        [self addSubview:_button];
        
        UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressed)];
        [self addGestureRecognizer:longPress];
        [longPress release];
        
    }
    return self;
}

-(void)dealloc {
    [_cover release];
    [_title release];
    [_button release];
    [_issueID release];
    [_subtitle release];
    [bookInfo release];
    [super dealloc];
}

#pragma mark - 

- (CGFloat)DegreesToRadians:(CGFloat) degrees {
    return degrees * M_PI / 180;
}
- (NSNumber*)DegreesToNumber:(CGFloat) degrees {
    return [NSNumber numberWithFloat:[self DegreesToRadians:degrees]];
}

- (CAAnimation*)shakeAnimation {
    CAKeyframeAnimation * animation;
    animation = [CAKeyframeAnimation animationWithKeyPath:@"transform.rotation.z"]; 
    [animation setDuration:0.3];
    [animation setRepeatCount:10000];
    // Try to get the animation to begin to start with a small offset // that makes it shake out of sync with other layers. srand([[NSDate date] timeIntervalSince1970]); 
    float rand = (float)random();
    [animation setBeginTime: CACurrentMediaTime() + rand * 0.0000000001];
    NSMutableArray *values = [NSMutableArray array]; // Turn right
    [values addObject:[self DegreesToNumber:(-2)]]; // Turn left
    [values addObject:[self DegreesToNumber:(2)]]; // Turn right
    [values addObject:[self DegreesToNumber:(-2)]]; // Set the values for the animation
    [animation setValues:values]; 
    return animation;
}

- (void)ShakeMyView {//开始晃动
    //    UIImageView* tt = (UIImageView*)[self.view viewWithTag:1];
    [self.layer removeAnimationForKey:@"beginAnimation"];
    [self.layer addAnimation:[self shakeAnimation] forKey:@"beginAnimation"];
}

- (void)RemoveShake {//停止晃动
    // UIImageView* tt = (UIImageView*)[self.view viewWithTag:1];
    [self.layer removeAnimationForKey:@"beginAnimation"];
}

#pragma mark - Callbacks

-(void)buttonCallback:(id)sender {
    // notifies delegate of the selection
    if (_editMode == BookEditModeNormal){
        if ([_delegate respondsToSelector:@selector(bookSelected:)]) {
            [_delegate bookSelected:self];
        }
    }
    
}

-(void)longPressed{
    if (_editMode == BookEditModeNormal){
        if ([_delegate respondsToSelector:@selector(bookEnterEditMode)]) {
            [_delegate bookEnterEditMode];
        }
    }
}

-(void)buttonActionCallback:(id)sender {
    // notifies delegate of the selection
    if ([_delegate respondsToSelector:@selector(bookActionClicked:)]) {
        [_delegate bookActionClicked:self];
    }
}



-(void)reDisplay{
    CGFloat actualFontSize;
    UIFont *mainFont = [UIFont boldSystemFontOfSize:SECOND_FONT_SIZE];
    NSString *subtitle = [bookInfo objectForKey:@"subtitle"];
	CGSize size= [subtitle sizeWithFont:mainFont minFontSize:12.0 actualFontSize:&actualFontSize forWidth:1000 lineBreakMode:UILineBreakModeTailTruncation];
    NSString *titleStr = @"";
    if (size.width <216) {
        titleStr = [NSString stringWithFormat:@"%@\n ",subtitle];
    }else{
        titleStr = [NSString stringWithFormat:@"%@",subtitle];
    }
   
    self.subtitle.text=titleStr;
    self.cover.image=[UIImage imageWithContentsOfFile:[bookInfo objectForKey:@"cover"]];
    self.title.text = [bookInfo objectForKey:@"title"];

}

-(void)setBookInfo:(NSDictionary *)aBookInfo{

    if (bookInfo != aBookInfo) {
        [bookInfo release];
        bookInfo = [aBookInfo retain];
    }
    [self reDisplay];
}

-(void)setEditMode:(BookEditMode)anEditMode{
//    if (_editMode != anEditMode) {
//        _editMode = anEditMode;
//        if (_editMode == BookEditModeNormal) {
//            _button.hidden = YES;
//            [self RemoveShake];
//        }else{
//            _button.hidden = NO;
//            [self ShakeMyView];
//        }
//    }
    
    _editMode = anEditMode;
    if (_editMode == BookEditModeNormal) {
        _button.hidden = YES;
        [self RemoveShake];
    }else{
        _button.hidden = NO;
        [self ShakeMyView];
    }
}

@end
