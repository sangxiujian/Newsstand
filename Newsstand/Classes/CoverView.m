//
//  CoverView.m
//  Newsstand
//
//  Created by HsiuJane Sang on 2/7/12.
//  Copyright (c) 2012 JiaYuan. All rights reserved.
//

#import "CoverView.h"
#import "Issue.h"

#define LABEL_HEIGHT  20.0

@implementation CoverView

@synthesize cover=_cover;
@synthesize title=_title;
@synthesize button=_button;
@synthesize progress=_progress;
@synthesize issueID=_issueID;
@synthesize subtitle = _subtitle;
@synthesize delegate=_delegate;
@synthesize hasSetObv = _hasSetObv;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        //self.frame = CGRectMake(0, 0, 200, 307);
        CGFloat width = frame.size.width;
//        UIButton *bgBtn = [UIButton buttonWithType:UIButtonTypeCustom];
//        [bgBtn setBackgroundImage:[UIImage imageNamed:@"home_book_bg~ipad"] forState:UIControlStateNormal];
//        bgBtn.frame = CGRectMake(0, 0, 236, 260);
//        [bgBtn addTarget:self action:@selector(buttonCallback:) forControlEvents:UIControlEventTouchUpInside];
//        [self addSubview:bgBtn];
        
        UIButton *bgBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        bgBtn.frame = CGRectMake(0, 0, frame.size.width, frame.size.height);
        [bgBtn addTarget:self action:@selector(buttonCallback:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:bgBtn];
        
        UIImageView *bgImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, width, frame.size.height)];
        bgImageView.image = [UIImage imageNamed:@"home_book_bg~ipad"];
        [self addSubview:bgImageView];
        [bgImageView release];
        self.backgroundColor = [UIColor clearColor];
        // title label
        self.title = [[[UILabel alloc] initWithFrame:CGRectMake((width-COVER_WIDTH)/2, COVER_HEIGHT+20, COVER_WIDTH, LABEL_HEIGHT)] autorelease];
        _title.font=[UIFont boldSystemFontOfSize:17];
        _title.textColor=[UIColor blackColor];
        _title.backgroundColor=[UIColor clearColor];
        _title.textAlignment=UITextAlignmentLeft;
        _title.numberOfLines = 0;
        self.subtitle = [[[UILabel alloc] initWithFrame:CGRectMake((width-COVER_WIDTH)/2, COVER_HEIGHT+20+LABEL_HEIGHT, COVER_WIDTH, LABEL_HEIGHT *2)] autorelease];
        _subtitle.font=[UIFont systemFontOfSize:SECOND_FONT_SIZE];
        _subtitle.textColor=[UIColor darkGrayColor];
        _subtitle.backgroundColor=[UIColor clearColor];
        _subtitle.textAlignment=UITextAlignmentLeft;
        _subtitle.numberOfLines = 0;
        // cover image
        self.cover = [[[UIImageView alloc] initWithFrame:CGRectMake((width-COVER_WIDTH)/2, 10.0, COVER_WIDTH, COVER_HEIGHT)] autorelease];
        _cover.backgroundColor=[UIColor clearColor];
        _cover.contentMode=UIViewContentModeScaleAspectFit;
        
        // progress
        self.progress = [[[UIProgressView alloc] initWithFrame:CGRectMake(10, frame.size.height-20, width-26, 20)] autorelease];
        _progress.alpha=0.0;
        _progress.progressViewStyle=UIProgressViewStyleBar;
        // button
        self.button = [UIButton buttonWithType:UIButtonTypeCustom];
        
        [_button setBackgroundImage:[UIImage imageNamed:@"btn_download_normal"] forState:UIControlStateNormal];
        [_button addTarget:self action:@selector(buttonActionCallback:) forControlEvents:UIControlEventTouchUpInside];
        [_button setTitle:@"下载" forState:UIControlStateNormal];
        _button.frame=CGRectMake(width-72, frame.size.height-42, 72, 32);
        
        [self addSubview:_subtitle];
        [self addSubview:_title];
        [self addSubview:_cover];
        [self addSubview:_progress];
        [self addSubview:_button];
        
    }
    return self;
}

-(void)dealloc {
    [_cover release];
    [_title release];
    [_button release];
    [_progress release];
    [_issueID release];
    [_subtitle release];
    [super dealloc];
}

#pragma mark - Callbacks

-(void)buttonCallback:(id)sender {
    // notifies delegate of the selection
    if ([_delegate respondsToSelector:@selector(coverSelected:)]) {
        [_delegate coverSelected:self];
    }
    
}

-(void)buttonActionCallback:(id)sender {
    // notifies delegate of the selection
    if ([_delegate respondsToSelector:@selector(coverActionClicked:)]) {
        [_delegate coverActionClicked:self];
    }
}

#pragma mark - KVO and Notifications

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    //ELog(@"Observed: %@",change);
    float value = [[change objectForKey:NSKeyValueChangeNewKey] floatValue];
    _progress.progress=value;
}

-(void)issueDidEndDownload:(NSNotification *)notification {
    id obj = [notification object];
    _progress.alpha=0.0;
    [_button setTitle:@"READ" forState:UIControlStateNormal];
    _button.alpha=1.0;
    [[NSNotificationCenter defaultCenter] removeObserver:self name:ISSUE_END_OF_DOWNLOAD_NOTIFICATION object:obj];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:ISSUE_FAILED_DOWNLOAD_NOTIFICATION object:obj];
    [obj removeObserver:self forKeyPath:@"downloadProgress"];
}

-(void)issueDidFailDownload:(NSNotification *)notification {
    id obj = [notification object];
    _progress.alpha=0.0;
    [_button setTitle:@"READ" forState:UIControlStateNormal];
    _button.alpha=1.0;
    [[NSNotificationCenter defaultCenter] removeObserver:self name:ISSUE_END_OF_DOWNLOAD_NOTIFICATION object:obj];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:ISSUE_FAILED_DOWNLOAD_NOTIFICATION object:obj];
    [obj removeObserver:self forKeyPath:@"downloadProgress"];
}

@end
