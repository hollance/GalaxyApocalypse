
#import "cocos2d.h"
#import "GameLayer.h"
#import "IntroLayer.h"

typedef enum
{
	GameStateIntro,
	GameStatePlaying,
	GameStateGameOver,
}
GameState;

/*
 * This game only has one scene. It has two layers: IntroLayer for the intro
 * and game over screens, and GameLayer for the actual game. The scene also
 * shows the background image.
 */
@interface MainScene : CCScene

@property (nonatomic, assign, readonly) GameState gameState;

+ (instancetype)scene;

- (void)exitIntro;
- (void)exitGame:(int)score;

@end
