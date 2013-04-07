//
//  AppDelegate.m
//  Newsstand
//
//  Created by HsiuJane Sang on 2/7/12.
//  Copyright (c) 2012 JiaYuan. All rights reserved.
//

#import "AppDelegate.h"
#import "Store.h"
#import "ShelfViewController.h"
#import <NewsstandKit/NewsstandKit.h>
#import "Issue.h"

@implementation AppDelegate

@synthesize window = _window;
@synthesize store = _store;
@synthesize shelf = _shelf;

- (void)dealloc
{
    [_store release];
    [_shelf release];
    [_window release];
    [super dealloc];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [[UINavigationBar appearance]setBackgroundImage:[UIImage imageNamed:@"nav_bg"] forBarMetrics:UIBarMetricsDefault];
    [[UINavigationBar appearance] setTintColor:[UIColor colorWithRed:245.0f/255.0f green:117.0f/255.0f blue:146.0f/255.0f alpha:1.0f]];
    
    // here we create the "Store" instance
    _store = [[Store alloc] init];
    [_store startup];
    
    self.shelf = [[[ShelfViewController alloc] initWithNibName:nil bundle:nil] autorelease];
    _shelf.store=_store;
    /*
    // allows more than one new content notification per day (development)
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"NKDontThrottleNewsstandContentNotifications"];
    
    // APNS standard registration to be added inside application:didFinishLaunchingWithOptions:
    [[UIApplication sharedApplication] registerForRemoteNotificationTypes:UIRemoteNotificationTypeNewsstandContentAvailability];

    // check if the application will run in background after being called by a push notification
    NSDictionary *payload = [launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey];
    //if(payload && [payload objectForKey:@"content-available"]) {
    if(payload) {
        // schedule for issue downloading in background
        // in this tutorial we hard-code background download of magazine-2, but normally the magazine to be downloaded
        // has to be provided in the push notification custom payload
        NKIssue *issue4 = [[NKLibrary sharedLibrary] issueWithName:@"Magazine-2"];
        if(issue4) {
            NSURL *downloadURL = [NSURL URLWithString:@"http://www.viggiosoft.com/media/data/blog/newsstand/magazine-2.pdf"];
            NSURLRequest *req = [NSURLRequest requestWithURL:downloadURL];
            NKAssetDownload *assetDownload = [issue4 addAssetWithRequest:req];
            [assetDownload downloadWithDelegate:_shelf];
        }
    }
     */
    // when the app is relaunched, it is better to restore pending downloading assets as abandoned downloadings will be cancelled
    NKLibrary *nkLib = [NKLibrary sharedLibrary];
    for(NKAssetDownload *asset in [nkLib downloadingAssets]) {
        [asset downloadWithDelegate:_shelf];            
    }
    
    self.window = [[[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]] autorelease];
    // Override point for customization after application launch.
    self.window.backgroundColor = [UIColor whiteColor];
    self.window.rootViewController = _shelf;
    [self.window makeKeyAndVisible];
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    /*
     Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
     If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
     */
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    /*
     Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
     */
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    /*
     Called when the application is about to terminate.
     Save data if appropriate.
     See also applicationDidEnterBackground:.
     */
}


-(void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
//    NSString *deviceTokenString = [[[[deviceToken description]
//                                     stringByReplacingOccurrencesOfString: @"<" withString: @""]
//                                    stringByReplacingOccurrencesOfString: @">" withString: @""]
//                                   stringByReplacingOccurrencesOfString: @" " withString: @""];    
//    NSLog(@"Registered with device token: %@",deviceTokenString);
    // [[UAPush shared] registerDeviceToken:deviceToken]; 
}

-(void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    //NSLog(@"Failing in APNS registration: %@",error);
}

-(void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    // UALOG(@"Received remote notification: %@", userInfo);
    
    /*
     [[UAPush shared] handleNotification:userInfo applicationState:application.applicationState];
     [[UAPush shared] resetBadge]; // zero badge after push received   
     */
    
    // Now check if it is new content; if so we show an alert
    if([userInfo objectForKey:@"content-available"]) {
        if([[UIApplication sharedApplication] applicationState]==UIApplicationStateActive) {
            // active app -> display an alert
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"New issue!"
                                                            message:@"There is a new issue available."
                                                           delegate:nil
                                                  cancelButtonTitle:@"Close"
                                                  otherButtonTitles:nil];
            [alert show];
            [alert release];            
        } else {
            // inactive app -> do something else (e.g. download the latest issue)
        }
    }
}

@end
