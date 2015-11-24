#import <LocalAuthentication/LocalAuthentication.h>

@interface UIApplication (Private)
- (void) launchApplicationWithIdentifier: (NSString*)identifier suspended: (BOOL)suspended;
@end

@interface Application : UIApplication
- (void)_presentObfuscatedScreenViewController;
- (void)_dismissObfuscatedScreenViewController;
@end

@interface BrowserRootViewController : UIViewController
@end

@interface BrowserController : UIResponder
- (void)togglePrivateBrowsing;
- (_Bool)privateBrowsingEnabled;
- (void)_setPrivateBrowsingEnabled:(BOOL)enabled;
+ (id)sharedBrowserController;
- (void)clearHistoryMessageReceived;
@end

@interface HistoryTableViewController : UITableViewController
- (void)_clearHistory;
@end

@interface CompletionList : NSObject
- (id)titleForGroupAtIndex:(unsigned long long)arg1;
- (id)completionsForGroupAtIndex:(unsigned long long)arg1;
@end

static BOOL enabled;
static BOOL hidePrivate;
static BOOL protectPrivate;

%hook Application

- (void)applicationDidFinishLaunching:(UIApplication *)arg1 {
	HBLogInfo(@"application launching for the first time");
	[%c(BrowserController) sharedBrowserController];
	if(enabled && hidePrivate){
		if([[%c(BrowserController) sharedBrowserController] privateBrowsingEnabled])
			[[%c(BrowserController) sharedBrowserController] togglePrivateBrowsing];
	}
	return %orig;
}

- (void)applicationWillEnterForeground:(id)arg1 {
	if(enabled && hidePrivate){
		if([[%c(BrowserController) sharedBrowserController] privateBrowsingEnabled])
			[[%c(BrowserController) sharedBrowserController] togglePrivateBrowsing];
	}
	%orig;
}

%end

%hook BrowserController

- (void)togglePrivateBrowsing {
	HBLogInfo(@"is it enabled? : %@", enabled ? @"Yes" : @"No");
	if(enabled){
		LAContext *context = [[LAContext alloc] init];
		NSError *contextError = nil;
		NSString *laReason = @"You must authenticate to access private browsing.";
		if ([context canEvaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics error:&contextError]) {
			if([self privateBrowsingEnabled]){
				%orig;
			} else {
				[context evaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics
				localizedReason:laReason
				reply:^(BOOL success, NSError *error) {
					if(success){
						dispatch_async(dispatch_get_main_queue(), ^{
							[(Application *)[UIApplication sharedApplication] _dismissObfuscatedScreenViewController];
							%orig;
						});
					}else {
						dispatch_async(dispatch_get_main_queue(), ^{
							[(Application *)[UIApplication sharedApplication] _dismissObfuscatedScreenViewController];
							[self _setPrivateBrowsingEnabled: NO];
						});
					}
				}];
			}
		} else {
			BrowserRootViewController *brvc = MSHookIvar<BrowserRootViewController *>(self, "_rootViewController");
			UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"ConfiBrowse"
	           message:@"Your device may not support TouchID, or, you have it disabled."
	           preferredStyle:UIAlertControllerStyleAlert];
			UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
	   			handler:^(UIAlertAction * action) {}];
			[alert addAction:defaultAction];
			[brvc presentViewController:alert animated:YES completion:nil];
			%orig;
		}
	}else{
		%orig;
	}

}

- (void)willSuspend {
	if(enabled && hidePrivate){
		if([[%c(BrowserController) sharedBrowserController] privateBrowsingEnabled])
			[[%c(BrowserController) sharedBrowserController] togglePrivateBrowsing];
	}
	%orig;
}

%end

static void prefschanged() {
    CFPreferencesAppSynchronize(CFSTR("com.brycedev.confibrowse"));
    CFStringRef appID = CFSTR("com.brycedev.confibrowse");
    CFArrayRef keyList = CFPreferencesCopyKeyList(appID , kCFPreferencesCurrentUser, kCFPreferencesAnyHost) ?: CFArrayCreate(NULL, NULL, 0, NULL);
    NSDictionary *dict = (NSDictionary *)CFPreferencesCopyMultiple(keyList, appID , kCFPreferencesCurrentUser, kCFPreferencesAnyHost);
    CFRelease(keyList);
	enabled = dict[@"enabled"] ? [dict[@"enabled"] boolValue] : YES;
	HBLogInfo(@"new enabled value : %@", enabled ? @"Yes" : @"No");
	hidePrivate = dict[@"hidePrivate"] ? [dict[@"hidePrivate"] boolValue] : YES;
	protectPrivate = dict[@"protectPrivate"] ? [dict[@"protectPrivate"] boolValue] : YES;
}

%ctor{
	CFNotificationCenterRef r = CFNotificationCenterGetDarwinNotifyCenter();
	CFNotificationCenterAddObserver(r, NULL, (CFNotificationCallback)prefschanged, CFSTR("com.brycedev.confibrowse.prefschanged"), NULL, CFNotificationSuspensionBehaviorCoalesce);
	prefschanged();
}
