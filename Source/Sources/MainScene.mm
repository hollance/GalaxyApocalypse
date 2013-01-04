
#import "MainScene.h"

@implementation MainScene
{
	GameState _gameState;
	CCSprite *_backgroundSprite;
	GameLayer *_gameLayer;
	IntroLayer *_introLayer;
}

+ (instancetype)scene
{
	return [[[self class] alloc] init];
}

- (id)init
{
	if ((self = [super init]))
	{
		_backgroundSprite = [CCSprite spriteWithFile:@"Background.png"];
		_backgroundSprite.anchorPoint = ccp(0, 0);
		_backgroundSprite.position = ccp(0, 0);
		[self addChild:_backgroundSprite];

		/*
		_backgroundSprite.opacity = 0;

		id action = [CCSequence actions:
			[CCDelayTime actionWithDuration:2.0f],
			[CCFadeIn actionWithDuration:2.0f],
			nil];

		[_backgroundSprite runAction:action];
		*/

		_gameLayer = [GameLayer node];
		_gameLayer.mainScene = self;
		[self addChild:_gameLayer];

		_introLayer = [IntroLayer node];
		_introLayer.mainScene = self;
		[self addChild:_introLayer];
	}
	return self;
}

- (void)exitIntro
{
	_introLayer.visible = NO;
	[_gameLayer startGame];
}

- (void)exitGame:(int)score
{
	_introLayer.visible = YES;
	[_introLayer gameOver:score];
}

@end
