
#import "cocos2d.h"

@class MainScene;

@interface GameOverLayer : CCLayer

@property (nonatomic, weak) MainScene *mainScene;

- (void)gameOver:(int)score;

@end
