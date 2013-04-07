//
//  ShelfViewCell.h
//  Newsstand
//
//  Created by HsiuJane Sang on 2/7/12.
//  Copyright (c) 2012 JiaYuan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CoverView.h"
#import "Issue.h"

@interface ShelfViewCell : UIView {
    
	NSArray *itemsArray;
}
@property (nonatomic,retain)NSArray *itemsArray;

-(void)setCoverInfo:(Issue*)anIssue atIndex:(NSUInteger)index;

-(CoverView*)coverViewAtIndex:(NSUInteger)index;
-(void)setProcessInfo:(CGFloat)newProcess atIndex:(NSUInteger)index;
-(void)setCoverImage:(UIImage*)image atIndex:(NSUInteger)index;
@end
