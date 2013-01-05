
#import "cocos2d.h"

/*
 * This game only has one scene. The scene has three layers, of which one is
 * only active at a time: IntroLayer for the intro screen, GameLayer for the
 * actual game, and GameOverLayer for when the player loses.
 *
 * The MainScene also display the background image (which is just a sprite).
 */
@interface MainScene : CCScene

+ (instancetype)scene;

- (void)exitIntro;
- (void)exitGame:(int)score;
- (void)exitGameOver;

@end
