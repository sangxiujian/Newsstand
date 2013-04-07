//
//  CoverView.h
//  Newsstand
//
//  Created by HsiuJane Sang on 2/7/12.
//  Copyright (c) 2012 JiaYuan. All rights reserved.
//

#import <UIKit/UIKit.h>

#define SECOND_FONT_SIZE    15.0

@class CoverView;
@protocol CoverViewDelegate

-(void)coverSelected:(CoverView *)cover;
-(void)coverActionClicked:(CoverView*)cover;

@end


@interface CoverView : UIView

@property (nonatomic,assign) NSObject <CoverViewDelegate> *delegate;
@property (nonatomic,copy) NSString *issueID;

@property (nonatomic,retain) UIImageView *cover;
@property (nonatomic,retain) UIButton *button;
@property (nonatomic,retain) UIProgressView *progress;
@property (nonatomic,retain) UILabel *title;
@property (nonatomic,retain) UILabel *subtitle;
@property (nonatomic,assign) BOOL hasSetObv;

@end


