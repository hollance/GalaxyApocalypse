
#import "SimpleAudioEngine.h"
#import "GameOverLayer.h"
#import "MainScene.h"

@implementation GameOverLayer
{
	CGSize _winSize;
	CCLabelBMFont *_gameOverLabel;
	CCLabelBMFont *_scoreLabel;
	ccTime _timer;
	int _gameOverStep;
	int _score;
}

- (id)init
{
	if ((self = [super init]))
	{
		_winSize = [CCDirector sharedDirector].winSize;

		_gameOverLabel = [CCLabelBMFont labelWithString:@"GAME OVER" fntFile:@"Font.fnt"];
		_gameOverLabel.anchorPoint = ccp(0.0f, 0.0f);
		_gameOverLabel.visible = NO;
		[self addChild:_gameOverLabel];

		_scoreLabel = [CCLabelBMFont labelWithString:@"Score: 0" fntFile:@"Font.fnt"];
		_scoreLabel.anchorPoint = ccp(0.0f, 0.0f);
		_scoreLabel.visible = NO;
		[self addChild:_scoreLabel];
	}
	return self;
}

- (void)gameOver:(int)score
{
	self.isTouchEnabled = NO;

	_score = score;

	_gameOverLabel.visible = YES;
	_gameOverLabel.string = @"";

	_timer = 0.1f;
	_gameOverStep = 0;

	[self schedule:@selector(update:) interval:1.0f/60.0f];
}

- (void)update:(ccTime)dt
{
	_timer -= dt;
	if (_timer <= 0.0f)
	{
		_timer = 0.2f;

		static NSString *strings[] =
		{
			@"", @"G", @"GA", @"GAM", @"GAME", @"GAME O", @"GAME OV", @"GAME OVE", @"GAME OVER",
		};

		if (_gameOverStep < 9)
		{
			_gameOverLabel.string = strings[_gameOverStep];
			_gameOverLabel.position = ccp(
				floorf(_winSize.width/2.0f - _gameOverLabel.contentSize.width/2.0f),
				floorf(_winSize.height/2.0f - _gameOverLabel.contentSize.height/2.0f) + 20.0f);
		}

		if (_gameOverStep == 4)
		{
			_scoreLabel.visible = YES;
			_scoreLabel.opacity = 0;
			_scoreLabel.string = [NSString stringWithFormat:@"Score: %d", _score];
			_scoreLabel.position = ccp(
				floorf(_winSize.width/2.0f - _scoreLabel.contentSize.width/2.0f),
				floorf(_winSize.height/2.0f - _scoreLabel.contentSize.height/2.0f) - 20.0f);

			id action = [CCFadeIn actionWithDuration:0.3f];
			[_scoreLabel runAction:action];
		}

		if (_gameOverStep == 9)
			self.isTouchEnabled = YES;

		if (_gameOverStep == 20)
			[self exitGameOver];

		_gameOverStep += 1;
	}
}

- (void)ccTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
	[self exitGameOver];
}

- (void)exitGameOver
{
	[self unschedule:@selector(update:)];
	self.isTouchEnabled = NO;
	[self.mainScene exitGameOver];
}

@end
