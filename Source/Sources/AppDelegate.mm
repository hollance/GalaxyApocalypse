
#import "AppDelegate.h"
#import "cocos2d.h"
#import "MainScene.h"

@interface AppDelegate () <CCDirectorDelegate>

@end

@implementation AppDelegate
{
	CCDirector *_director;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
	self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];

	CCGLView *glView = [CCGLView viewWithFrame:[self.window bounds]
				   pixelFormat:kEAGLColorFormatRGB565	//kEAGLColorFormatRGBA8
				   depthFormat:0	                    //GL_DEPTH_COMPONENT24_OES
			preserveBackbuffer:NO
					sharegroup:nil
				 multiSampling:NO
			   numberOfSamples:0];

	[glView setMultipleTouchEnabled:YES];

	_director = (CCDirectorIOS *)[CCDirector sharedDirector];
	_director.wantsFullScreenLayout = YES;
	//[_director setDisplayStats:YES];
	[_director setAnimationInterval:1.0/60];
	[_director setView:glView];
	[_director setDelegate:self];
	[_director setProjection:kCCDirectorProjection2D];

	if (![_director enableRetinaDisplay:YES])
		CCLOG(@"Retina Display Not supported");

	[CCTexture2D setDefaultAlphaPixelFormat:kCCTexture2DPixelFormat_RGBA8888];

	CCFileUtils *sharedFileUtils = [CCFileUtils sharedFileUtils];
	[sharedFileUtils setEnableFallbackSuffixes:NO];				// Default: NO. No fallback suffixes are going to be used
	[sharedFileUtils setiPhoneRetinaDisplaySuffix:@"-hd"];		// Default on iPhone RetinaDisplay is "-hd"
	[sharedFileUtils setiPadSuffix:@"-ipad"];					// Default on iPad is "ipad"
	[sharedFileUtils setiPadRetinaDisplaySuffix:@"-ipadhd"];	// Default on iPad RetinaDisplay is "-ipadhd"

	[CCTexture2D PVRImagesHavePremultipliedAlpha:YES];

	[_director pushScene:[MainScene scene]];

	[self.window setRootViewController:_director];
	[self.window makeKeyAndVisible];
	return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
	[_director pause];
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
	[_director stopAnimation];
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
	[_director startAnimation];
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
	[_director setNextDeltaTimeZero:YES];
	[_director resume];
}

- (void)applicationWillTerminate:(UIApplication *)application
{
	CC_DIRECTOR_END();
}

- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application
{
	[_director purgeCachedData];
}

-(void) applicationSignificantTimeChange:(UIApplication *)application
{
	[_director setNextDeltaTimeZero:YES];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return interfaceOrientation == UIInterfaceOrientationPortrait;
}

@end
