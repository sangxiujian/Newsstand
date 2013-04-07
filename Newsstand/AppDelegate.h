//
//  AppDelegate.h
//  Newsstand
//
//  Created by HsiuJane Sang on 2/7/12.
//  Copyright (c) 2012 JiaYuan. All rights reserved.
//

#import <UIKit/UIKit.h>
@class Store;
@class ShelfViewController;

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (strong, nonatomic) Store *store;
@property (strong, nonatomic) ShelfViewController *shelf;



@end
