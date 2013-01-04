
#import "cocos2d.h"

@class MainScene;

@interface IntroLayer : CCLayer

@property (nonatomic, weak) MainScene *mainScene;

- (void)gameOver:(int)score;

@end
