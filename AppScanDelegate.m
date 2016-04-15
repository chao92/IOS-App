//
//  AppDelegate.m
//  Integrity_APP
//
//  Created by chao on 2/2/16.
//  Copyright © 2016 Shuang Wang. All rights reserved.
//

#import "AppScanDelegate.h"
#import "scanViewController.h"
@implementation AppScanDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    NSLog(@"launching window");
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.rootViewController = [[scanViewController alloc] initWithNibName:@"scanViewController" bundle:nil];
    [self.window makeKeyAndVisible];
    return YES;
}

@end
