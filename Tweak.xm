#import <LocalAuthentication/LocalAuthentication.h>

@interface Application : UIApplication
- (void)_presentObfuscatedScreenViewController;
- (void)_dismissObfuscatedScreenViewController;
@end

@interface BrowserController : UIResponder
- (void)togglePrivateBrowsing;
- (_Bool)privateBrowsingEnabled;
- (void)_setPrivateBrowsingEnabled:(BOOL)enabled;
+ (id)sharedBrowserController;
@end

%hook Application

- (void)applicationWillEnterForeground:(id)arg1 {
	if([[%c(BrowserController) sharedBrowserController] privateBrowsingEnabled])
		[[%c(BrowserController) sharedBrowserController] togglePrivateBrowsing];
	%orig;
}

%end

%hook BrowserController

- (void)togglePrivateBrowsing {
	if([self privateBrowsingEnabled]){
		%orig;
	} else {
		[(Application *)[UIApplication sharedApplication] _presentObfuscatedScreenViewController];
		LAContext *context = [[LAContext alloc] init];
		NSError *contextError = nil;
		NSString *laReason = @"You must authenticate to access private browsing.";
		if ([context canEvaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics error:&contextError]) {
			[context evaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics
				localizedReason:laReason
				reply:^(BOOL success, NSError *error) {
					if(success){
						dispatch_async(dispatch_get_main_queue(), ^{
							[(Application *)[UIApplication sharedApplication] _dismissObfuscatedScreenViewController];
							%orig;
						});
					}else{
						dispatch_async(dispatch_get_main_queue(), ^{
							[(Application *)[UIApplication sharedApplication] _dismissObfuscatedScreenViewController];
							[self _setPrivateBrowsingEnabled: NO];
						});
					}
				}];
		} else {

		}
	}
}

%end
