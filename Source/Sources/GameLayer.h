
#import "cocos2d.h"

@class MainScene;

@interface GameLayer : CCLayer

@property (nonatomic, weak) MainScene *mainScene;

- (void)startGame;

@end
