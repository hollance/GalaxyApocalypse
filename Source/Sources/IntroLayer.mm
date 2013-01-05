
#import "SimpleAudioEngine.h"
#import "IntroLayer.h"
#import "MainScene.h"

@implementation IntroLayer
{
	CGSize _winSize;
	CCSprite *_titleTopSprite;
	CCSprite *_titleBottomSprite;
	CCLabelBMFont *_startLabel;
	CCLabelBMFont *_creditsLabel;
	ccTime _flashTimer;
	ccTime _creditsTimer;
	int _creditsStep;
}

- (id)init
{
	if ((self = [super init]))
	{
		self.isTouchEnabled = NO;

		_winSize = [CCDirector sharedDirector].winSize;

		_titleTopSprite = [CCSprite spriteWithFile:@"TitleTop.png"];
		_titleTopSprite.visible = NO;
		[self addChild:_titleTopSprite];

		_titleBottomSprite = [CCSprite spriteWithFile:@"TitleBottom.png"];
		_titleBottomSprite.visible = NO;
		[self addChild:_titleBottomSprite];

		_startLabel = [CCLabelBMFont labelWithString:@"Tap to start" fntFile:@"Font.fnt"];
		_startLabel.anchorPoint = ccp(0.0f, 0.0f);
		_startLabel.visible = NO;
		_startLabel.position = ccp(
			floorf(_winSize.width/2.0f - _startLabel.contentSize.width/2.0f),
			floorf(_winSize.height/2.0f - _startLabel.contentSize.height/2.0f) - 40.0f);

		[self addChild:_startLabel];

		_creditsLabel = [CCLabelBMFont labelWithString:@"" fntFile:@"FontSmall.fnt"];
		_creditsLabel.anchorPoint = ccp(0.0f, 0.0f);
		_creditsLabel.visible = NO;
		_creditsLabel.alignment = kCCTextAlignmentCenter;
		[self addChild:_creditsLabel];
	}
	return self;
}

- (void)showIntro
{
	[[SimpleAudioEngine sharedEngine] playBackgroundMusic:@"Intro.mp3"];

	CGPoint topPosition = ccp(_winSize.width / 2.0f, _winSize.height - 80.0f);
	id topAction = [CCEaseBounceOut actionWithAction:[CCMoveTo actionWithDuration:2.0f position:topPosition]];
	_titleTopSprite.position = ccp(-200.0f, topPosition.y);
	_titleTopSprite.visible = YES;
	[_titleTopSprite runAction:topAction];

	CGPoint bottomPosition = ccp(_winSize.width / 2.0f, _winSize.height - 130.0f);
	id bottomAction = [CCEaseBounceOut actionWithAction:[CCMoveTo actionWithDuration:2.0f position:bottomPosition]];
	_titleBottomSprite.position = ccp(_winSize.width + 200.0f, bottomPosition.y);
	_titleBottomSprite.visible = YES;
	[_titleBottomSprite runAction:bottomAction];

	_startLabel.visible = NO;
	_creditsLabel.visible = NO;

	_flashTimer = 1.0f;
	_creditsTimer = 1.5f;
	_creditsStep = 0;

	[self schedule:@selector(update:) interval:1.0f/60.0f];
}

- (void)update:(ccTime)dt
{
	_flashTimer -= dt;
	if (_flashTimer <= 0.0f)
	{
		_flashTimer = 1.0f;
		_startLabel.visible = !_startLabel.visible;
		self.isTouchEnabled = YES;
	}
	
	_creditsTimer -= dt;
	if (_creditsTimer <= 0.0f)
	{
		static NSString *strings[] =
		{
			@"Created by Matthijs Hollemans",
			@"For #OneGameAMonth, January 2013\n(www.github.com/hollance)",
			@"Images by NASA\nExplosion by WrathGames Studio",
			@"Intro music:\nLightless Dawn by Kevin MacLeod\n(incompetech.com)",
			@"In-game music:\nTrial By Fire by Matt McFarland\n(www.mattmcfarland.com)",
			@"SFX by freesound.org / opengameart.org",
			@""
		};

		if (_creditsStep % 2 == 0)
		{
			_creditsTimer = 3.0f;

			_creditsLabel.string = strings[_creditsStep / 2];
			CGPoint creditsPosition = ccp(floorf(_winSize.width/2.0f - _creditsLabel.contentSize.width/2.0f), 40.0f);
			_creditsLabel.position = ccp(creditsPosition.x, -160.0f);
			_creditsLabel.visible = YES;
			id creditsAction = [CCEaseExponentialOut actionWithAction:[CCMoveTo actionWithDuration:1.0f position:creditsPosition]];
			[_creditsLabel runAction:creditsAction];
		}
		else
		{
			_creditsTimer = 1.5f;

			CGPoint creditsPosition = ccp(_creditsLabel.position.x, -160.0f);
			id creditsAction = [CCEaseExponentialIn actionWithAction:[CCMoveTo actionWithDuration:1.0f position:creditsPosition]];
			[_creditsLabel runAction:creditsAction];
		}

		_creditsStep += 1;
		if (_creditsStep == 5*2)
			_creditsStep = 0;
	}
}

- (void)ccTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
	[self exitIntro];
}

- (void)exitIntro
{
	self.isTouchEnabled = NO;
	[self unschedule:@selector(update:)];
	[self.mainScene exitIntro];
}

@end
