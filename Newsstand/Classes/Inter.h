//
//  Inter.h
//  Newsstand
//
//  Created by HsiuJane Sang on 2/7/12.
//  Copyright (c) 2012 JiaYuan. All rights reserved.
//

#ifndef Newsstand_Inter_h
#define Newsstand_Inter_h


#define ISSUE_END_OF_DOWNLOAD_NOTIFICATION @"IssueEndOfDownload"
#define ISSUE_FAILED_DOWNLOAD_NOTIFICATION @"IssueFailedDownload"
#define ISSUE_END_OF_DELETE_NOTIFICATION @"IssueEndOfDeleted"

#define COVER_HEIGHT    146.0
#define COVER_WIDTH     214.0
#define DELETE_WIDTH    42.0

// Debug
#ifdef DEBUG
#    define DLog(...) NSLog(__VA_ARGS__)
#	 define ELog(s,...) NSLog((@"[%s] " s),__func__,## __VA_ARGS__);
#else
#    define DLog(...) /* */
#	 define ELog(...) /* */
#endif
#define ALog(...) NSLog(__VA_ARGS__)


// Shorthand for getting localized strings, used in formats below for readability
#define LocStr(key) [[NSBundle mainBundle] localizedStringForKey:(key) value:@"" table:nil]

// User sub-dirs
#define DocumentsDirectory [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, \
NSUserDomainMask, YES) objectAtIndex:0]

#define LibraryDirectory [NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, \
NSUserDomainMask, YES) objectAtIndex:0]

#define DocumentsSubDirectory(dir) [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, \
NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingString:dir]

#define LibrarySubDirectory(dir) [[NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, \
NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingString:dir]

#define CacheDirectory [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0]



// iPad/iPhone detector
#define isPad() \
([[UIDevice currentDevice] respondsToSelector:@selector(userInterfaceIdiom)] && \
[[UIDevice currentDevice] userInterfaceIdiom]==UIUserInterfaceIdiomPad)

#define isRetina() \
([[UIScreen mainScreen] respondsToSelector:@selector(scale)] && [[UIScreen mainScreen] scale] == 2)

// iOS5 detector
#define isOS5() \
([[[UIDevice currentDevice] systemVersion] floatValue]>=5.0)

// memory report (requires #import <mach/mach.h> )
#define REPORT_MEMORY() \
-(NSString *)report_memory { \
struct task_basic_info info; \
mach_msg_type_number_t size = sizeof(info); \
kern_return_t kerr = task_info(mach_task_self(), \
TASK_BASIC_INFO, \
(task_info_t)&info, \
&size); \
if( kerr == KERN_SUCCESS ) { \
return([NSString stringWithFormat:@"***************** memory: %u bytes *****************",info.resident_size]); \
} else { \
return([NSString stringWithFormat:@"memory: Error with task_info(): %s", mach_error_string(kerr)]); \
} \
}

#endif
