
#import "cocos2d.h"

@class MainScene;

/*
 * This is where all the action happens.
 */
@interface GameLayer : CCLayer

@property (nonatomic, weak) MainScene *mainScene;

- (void)startGame;

@end
