
#import "MainScene.h"
#import "GameLayer.h"
#import "GameOverLayer.h"
#import "IntroLayer.h"

@implementation MainScene
{
	CCSprite *_backgroundSprite;
	IntroLayer *_introLayer;
	GameLayer *_gameLayer;
	GameOverLayer *_gameOverLayer;
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
		_backgroundSprite.anchorPoint = ccp(0.0f, 0.0f);
		_backgroundSprite.position = ccp(0.0f, 0.0f);
		[self addChild:_backgroundSprite];

		_introLayer = [IntroLayer node];
		_introLayer.mainScene = self;
		[self addChild:_introLayer];

		_gameLayer = [GameLayer node];
		_gameLayer.mainScene = self;
		[self addChild:_gameLayer];

		_gameOverLayer = [GameOverLayer node];
		_gameOverLayer.mainScene = self;
		[self addChild:_gameOverLayer];

		[_introLayer showIntro];
	}
	return self;
}

- (void)exitIntro
{
	_introLayer.visible = NO;
	_gameLayer.visible = YES;
	[_gameLayer startGame];
}

- (void)exitGame:(int)score
{
	_gameLayer.visible = NO;
	_gameOverLayer.visible = YES;
	[_gameOverLayer gameOver:score];
}

- (void)exitGameOver
{
	_gameOverLayer.visible = NO;
	_introLayer.visible = YES;
	[_introLayer showIntro];
}

@end
