//
//  ShelfViewCell.m
//  Newsstand
//
//  Created by HsiuJane Sang on 2/7/12.
//  Copyright (c) 2012 JiaYuan. All rights reserved.
//

#import "ShelfViewCell.h"


@implementation ShelfViewCell

@synthesize itemsArray;

- (id)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code.
    }
    return self;
}

-(void)resetSubViews
{
	for (UIView *ctrView in self.subviews) {
		if ([ctrView isKindOfClass:[CoverView class]]) {
			[ctrView removeFromSuperview];
		}
	}
	for (CoverView *itemView in itemsArray) {
		[self addSubview:itemView];
	}
}
-(void)setItemsArray:(NSArray *)newArray{
	if (itemsArray!=newArray) {
		[itemsArray release];
		itemsArray = [newArray retain];
		[self resetSubViews];
	}
}
-(CoverView*)coverViewAtIndex:(NSUInteger)index{
    if (index>=[itemsArray count]) {
		return nil;
	}else{
        return [itemsArray objectAtIndex:index];
    }
}

-(void)setCoverImage:(UIImage*)image atIndex:(NSUInteger)index{
    if (index>=[itemsArray count]) {
		return;
	}
    CoverView *cover = [itemsArray objectAtIndex:index];
    cover.cover.image = image;
}

-(void)setProcessInfo:(CGFloat)newProcess atIndex:(NSUInteger)index{
    if (index>=[itemsArray count]) {
		return;
	}
    CoverView *cover = [itemsArray objectAtIndex:index];
    cover.progress.progress = newProcess;
    cover.progress.alpha = 1.0;
    cover.button.alpha = 0.0;
}
-(void)setCoverInfo:(Issue*)anIssue atIndex:(NSUInteger)index
{
	if (index>=[itemsArray count]) {
		return;
	}
    CoverView *cover = [itemsArray objectAtIndex:index];
    if (anIssue == nil) {
        cover.hidden = YES;
        return;
    }else{
        cover.hidden = NO;
    }
    CGFloat actualFontSize;
    UIFont *mainFont = [UIFont boldSystemFontOfSize:SECOND_FONT_SIZE];
	CGSize size= [anIssue.title sizeWithFont:mainFont minFontSize:12.0 actualFontSize:&actualFontSize forWidth:1000 lineBreakMode:UILineBreakModeTailTruncation];
    NSString *titleStr = @"";
    if (size.width <216) {
        titleStr = [NSString stringWithFormat:@"%@\n ",anIssue.title];
    }else{
        titleStr = [NSString stringWithFormat:@"%@",anIssue.title];
    }
    cover.issueID=anIssue.issueID;
    cover.subtitle.text=titleStr;
    cover.cover.image=[anIssue coverImage];
    cover.title.text = [NSString stringWithFormat:@"第%@期",anIssue.issueID];
    cover.button.alpha = 1.0;
    if([anIssue isIssueAvailableForRead]) {
        [cover.button setTitle:@"阅读" forState:UIControlStateNormal];
        cover.progress.alpha = 0.0;
    } else {
        if ([anIssue isDownloading]) {
            cover.button.alpha = 0.0;
            cover.progress.alpha = 1.0;
        }else{
            cover.button.alpha = 1.0;
            cover.progress.alpha = 0.0;
            [cover.button setTitle:@"下载" forState:UIControlStateNormal];
        }
    }
}
/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect {
 // Drawing code.
 }
 */

- (void)dealloc {
	[itemsArray release];
    [super dealloc];
}


@end
