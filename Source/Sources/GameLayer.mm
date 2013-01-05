
#import "Box2D.h"
#import "GLES-Render.h"
#import "SimpleAudioEngine.h"
#import "MHRandom.h"
#import "MHUtil.h"

#import "GameLayer.h"
#import "ContactListener.h"
#import "Defs.h"
#import "MainScene.h"
#import "Planet.h"
#import "Portal.h"

#pragma mark - GameLayer

@implementation GameLayer
{
	b2World *_world;
	b2Body *_screenBody;
	b2Fixture *_topFixture;
	b2Fixture *_bottomFixture;
	b2Fixture *_leftFixture;
	b2Fixture *_rightFixture;
	ContactListener *_contactListener;

	CGSize _winSize;
	GLESDebugDraw *_debugDraw;
	CCSpriteBatchNode *_spriteBatchNode;
	CCLabelBMFont *_scoreLabel;
	CCLabelBMFont *_timerLabel;
	CCLabelBMFont *_dangerLabel;
	CCLabelBMFont *_instructionsLabel;
	CCSpriteBatchNode *_explosionBatchNode;
	CCAnimation *_explosionAnimation;

	ccTime _timeUntilNextSpawn;
	ccTime _timeUntilPortalsAppear;
	ccTime _timeUntilPortalsDisappear;
	ccTime _timeUntilPortalsDrain;
	b2Vec2 _lastTouchLocation;

	NSMutableArray *_planets;
	NSMutableArray *_portals;
	NSMutableArray *_deadPlanets;
	NSMutableArray *_deadPortals;

	BOOL _firstTime;
	int _score;
	int _portalProbabilities[3];
	float _portalLifetime;
	float _powerDrainRate;
	float _spawnDelay;
	float _speedRange;

	int _dangerLevel;
	ccTime _timeUntilFlashDangerous;
	ccTime _dangerFlashRate;
	ALuint _dangerSoundID;
}

- (id)init
{
	if ((self = [super init]))
	{
		self.isTouchEnabled = NO;

		_winSize = [CCDirector sharedDirector].winSize;

		[self setUpWorld];
		[self setUpScreenBox];
		[self setUpSprites];
		[self setUpExplosionAnimation];
	}
	return self;
}

- (void)setUpWorld
{
	b2Vec2 gravity;
	gravity.Set(0.0f, GRAVITY);

	_world = new b2World(gravity);
	_world->SetAllowSleeping(true);
	_world->SetContinuousPhysics(true);

	_contactListener = new ContactListener();
	_world->SetContactListener(_contactListener);

	#if DEBUG_DRAW
	_debugDraw = new GLESDebugDraw(POINTS_TO_METERS_RATIO);
	_world->SetDebugDraw(_debugDraw);

	uint32 flags = 0;
	flags += b2Draw::e_shapeBit;
	//flags += b2Draw::e_jointBit;
	//flags += b2Draw::e_aabbBit;
	//flags += b2Draw::e_pairBit;
	//flags += b2Draw::e_centerOfMassBit;
	_debugDraw->SetFlags(flags);
	#endif
}

- (void)setUpScreenBox
{
	// Initializes a static body that is slightly larger than the visible
	// screen, so that planets are allowed to fall outside the screen bounds.
	// Planets are removed from the game when they hit these fixtures.

	float w = POINTS_TO_METERS(_winSize.width);
	float h = POINTS_TO_METERS(_winSize.height);

	b2BodyDef bodyDef;
	bodyDef.position.Set(0.0f, 0.0f);

	_screenBody = _world->CreateBody(&bodyDef);

	const float Margin = POINTS_TO_METERS(200.0f);

	b2EdgeShape bottomWall;
	bottomWall.Set(b2Vec2(-Margin, -Margin), b2Vec2(w + Margin, -Margin));
	_bottomFixture = _screenBody->CreateFixture(&bottomWall, 0.0f);

	b2EdgeShape topWall;
	topWall.Set(b2Vec2(-Margin, h + Margin), b2Vec2(w + Margin, h + Margin));
	_topFixture = _screenBody->CreateFixture(&topWall, 0.0f);

	b2EdgeShape leftWall;
	leftWall.Set(b2Vec2(-Margin, -Margin), b2Vec2(-Margin, h + Margin));
	_leftFixture = _screenBody->CreateFixture(&leftWall, 0.0f);

	b2EdgeShape rightWall;
	rightWall.Set(b2Vec2(w + Margin, -Margin), b2Vec2(w + Margin, h + Margin));
	_rightFixture = _screenBody->CreateFixture(&rightWall, 0.0f);
}

- (void)setUpSprites
{
	_spriteBatchNode = [CCSpriteBatchNode batchNodeWithFile:@"Sprites.png" capacity:150];
	
	[self addChild:_spriteBatchNode z:1];

	[[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"Sprites.plist" texture:_spriteBatchNode.texture];
}

- (void)setUpExplosionAnimation
{
	_explosionBatchNode = [CCSpriteBatchNode batchNodeWithFile:@"Explosion.png" capacity:150];
	[self addChild:_explosionBatchNode z:2];

	[[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"Explosion.plist" texture:_explosionBatchNode.texture];

	NSMutableArray *frames = [NSMutableArray arrayWithCapacity:90];
	for (int t = 1; t <= 90; ++t)
	{
		NSString *frameName = [NSString stringWithFormat:@"explosion1_%04d.png", t];
		CCSpriteFrame *spriteFrame = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:frameName];
		[frames addObject:spriteFrame];
	}

	_explosionAnimation = [CCAnimation animationWithSpriteFrames:frames delay:1.0f/60.0f];
}

- (void)dealloc
{
	[[CCSpriteFrameCache sharedSpriteFrameCache] removeUnusedSpriteFrames];

	delete _contactListener;
	delete _world;
	delete _debugDraw;
}

#if DEBUG_DRAW
- (void)draw
{
	[super draw];
	ccGLEnableVertexAttribs(kCCVertexAttribFlag_Position);
	kmGLPushMatrix();
	_world->DrawDebugData();
	kmGLPopMatrix();
}
#endif

#pragma mark - Game Logic

- (void)startGame
{
	[[SimpleAudioEngine sharedEngine] playBackgroundMusic:@"Game.mp3"];

	_planets = [NSMutableArray arrayWithCapacity:100];
	_portals = [NSMutableArray arrayWithCapacity:3];
	_deadPlanets = [NSMutableArray arrayWithCapacity:100];
	_deadPortals = [NSMutableArray arrayWithCapacity:3];

	_firstTime = YES;
	_score = 0;
	_portalLifetime = 20.0f;
	_powerDrainRate = 1.0f / (_portalLifetime + 1.0f);
	_dangerLevel = 0;
	_spawnDelay = 1.0f;
	_speedRange = 2.0f;

	_portalProbabilities[0] = 90;
	_portalProbabilities[1] = 10;
	_portalProbabilities[2] = 0;

	_timeUntilNextSpawn = 0.0f;
	_timeUntilPortalsAppear = 1.0f;
	_timeUntilPortalsDisappear = HUGE_VALF;
	_timeUntilPortalsDrain = HUGE_VALF;

	_scoreLabel = [CCLabelBMFont labelWithString:@"0000000000" fntFile:@"Font.fnt"];
	_scoreLabel.anchorPoint = ccp(0.0f, 0.0f);
	_scoreLabel.position = ccp(0.0f, _winSize.height - 20.0f);
	[self addChild:_scoreLabel z:10000];

	_timerLabel = [CCLabelBMFont labelWithString:@"00:00" fntFile:@"Font.fnt"];
	_timerLabel.anchorPoint = ccp(1.0f, 0.0f);
	_timerLabel.position = ccp(_winSize.width - 2.0f, _winSize.height - 20.0f);
	[self addChild:_timerLabel z:10001];

	_dangerLabel = [CCLabelBMFont labelWithString:@"DANGER!" fntFile:@"Font.fnt"];
	_dangerLabel.anchorPoint = ccp(0.0f, 0.0f);
	_dangerLabel.position = ccp(
		floorf(_winSize.width/2.0f - _dangerLabel.contentSize.width/2.0f),
		_winSize.height - 100.0f);
	[self addChild:_dangerLabel z:10002];

	[self showInstructionsAnimation];
	[self updateScoreLabel];
	[self updateTimerLabel];
	[self updateDangerLabel:0.0f];

	self.isTouchEnabled = YES;
	[self schedule:@selector(update:) interval:1.0f/60.0f];
}

- (void)update:(ccTime)dt
{
	const int32 velocityIterations = 8;
	const int32 positionIterations = 1;
	_world->Step(dt, velocityIterations, positionIterations);

	for (Planet *planet in _planets)
		[planet update:dt];

	for (Portal *portal in _portals)
		[portal update:dt];

	[self handleCollisions];
	[self spawnNewPlanets:dt];
	[self updatePortals:dt];
	[self updateScoreLabel];
	[self updateTimerLabel];
	[self updateDangerLabel:dt];
}

- (void)updateScoreLabel
{
	_scoreLabel.string = [NSString stringWithFormat:@"%d", _score];
}

- (void)updateTimerLabel
{
	_timerLabel.visible = (_timeUntilPortalsDrain <= 0.0f);
	if (_timerLabel.visible)
	{
		int timeLeft = MAX(0, floorf(_timeUntilPortalsDisappear + 0.5f));
		_timerLabel.string = [NSString stringWithFormat:@"0:%02d", timeLeft];
	}
}

- (void)updateDangerLabel:(ccTime)dt
{
	if (_dangerLevel > 0)
	{
		_timeUntilFlashDangerous -= dt;
		if (_timeUntilFlashDangerous <= 0.0f)
		{
			_timeUntilFlashDangerous = _dangerFlashRate;
			_dangerLabel.visible = !_dangerLabel.visible;
		}
	}
	else
	{
		_dangerLabel.visible = NO;
	}
}

#pragma mark - Collision Handling

- (void)handleCollisions
{
	// Note: It might be simpler to just step through b2World's contact list
	// than using a ContactListener.

	for (ContactIterator pos  = _contactListener->contacts.begin();
						 pos != _contactListener->contacts.end();
					   ++pos)
	{
		Contact contact = *pos;

		id actorA = (__bridge id)contact.fixtureA->GetBody()->GetUserData();
		id actorB = (__bridge id)contact.fixtureB->GetBody()->GetUserData();

		if (contact.fixtureA == _bottomFixture
		||  contact.fixtureA == _topFixture
		||  contact.fixtureA == _leftFixture
		||  contact.fixtureA == _rightFixture)
		{
			Planet *planet = (Planet *)actorB;
			planet.state = PlanetStateDead;
		}
		else if (contact.fixtureB == _bottomFixture
			 ||  contact.fixtureB == _topFixture
			 ||  contact.fixtureB == _leftFixture
			 ||  contact.fixtureB == _rightFixture)
		{
			Planet *planet = (Planet *)actorA;
			planet.state = PlanetStateDead;
		}
		else if (actorA != nil && actorB != nil)
		{
			if ([actorA isKindOfClass:[Portal class]])
			{
				Portal *portal = (Portal *)actorA;
				Planet *planet = (Planet *)actorB;

				if (!portal.isDead && planet.state == PlanetStateFalling)
					planet.collidedWith = portal;
			}
			else if ([actorB isKindOfClass:[Portal class]])
			{
				Portal *portal = (Portal *)actorB;
				Planet *planet = (Planet *)actorA;

				if (!portal.isDead && planet.state == PlanetStateFalling)
					planet.collidedWith = portal;
			}
		}
	}

	// Any actions that destroy the b2Body must be done outside the contact
	// listener loop, because that modifies the contacts, and doing that at
	// the same time leads to bad things. So we set the "collidedWith" flag
	// in the loop, and check it in the methods below.

	[self pruneDeadPlanets];
	[self pruneDeadPortals];
}

- (void)pruneDeadPlanets
{
	for (Planet *planet in _planets)
	{
		if (planet.state == PlanetStateDead)
		{
			[_deadPlanets addObject:planet];
		}
		else if (planet.collidedWith != nil && planet.state == PlanetStateFalling)
		{
			[self handleCollisionOfPlanet:planet];
		}
	}

	[_planets removeObjectsInArray:_deadPlanets];
	[_deadPlanets removeAllObjects];
}

- (void)pruneDeadPortals
{
	for (Portal *portal in _portals)
	{
		if (portal.isDead)
		{
			[_deadPortals addObject:portal];
		}
	}

	[_portals removeObjectsInArray:_deadPortals];
	[_deadPortals removeAllObjects];
}

- (void)handleCollisionOfPlanet:(Planet *)planet
{
	Portal *portal = planet.collidedWith;

	if (planet.color == -1)  // black hole!
	{
		portal.power -= 0.4f;
		[[SimpleAudioEngine sharedEngine] playEffect:@"BlackHole.wav"];
	}
	else if (planet.color == 0 || portal.color == 0)  // white matches anywhere
	{                                                 // but scores less
		_score += 50;
		portal.power += 0.05f;
		[[SimpleAudioEngine sharedEngine] playEffect:@"WhitePlanet.wav"];
	}
	else if (planet.color == portal.color)
	{
		_score += 100;
		portal.power += 0.1f;
		[[SimpleAudioEngine sharedEngine] playEffect:@"GoodPlanet.wav"];
	}
	else
	{
		portal.power -= 0.2f;
		[[SimpleAudioEngine sharedEngine] playEffect:@"BadPlanet.wav"];
	}

	[planet handleCollision];
	[portal animateCollision];
}

#pragma mark - Spawning new objects

- (void)spawnNewPlanets:(ccTime)dt
{
	_timeUntilNextSpawn -= dt;
	if (_timeUntilNextSpawn <= 0.0f)
	{
		_timeUntilNextSpawn = 0.05f + MHRandomFloat() * _spawnDelay;

		CGFloat x = MHRandomIntRange(50, _winSize.width - 100);
		CGFloat y = _winSize.height + 100.0f;
		CGFloat angle = MHRandomFloat() * 360.0f;

		static const int sizes[] =
		{
			0, 0, 0, 0,
			1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,
			2, 2, 2, 2, 2, 2, 2,
			3, 3, 3,
		};

		int size = sizes[MHRandomInt(ARRAY_SIZE(sizes))];

		int color;
		if (MHRandomInt(100) == 50)  // black hole
			color = -1;
		else if (MHRandomInt(100) < 5)  // white planet
			color = 0;
		else
			color = MHRandomIntRange(1, 3);

		Planet *planet = [[Planet alloc] initWithWorld:_world size:size position:CGPointMake(x, y) angle:angle color:color];
		planet.fallingSpeed = -0.5f - MHRandomFloat() * _speedRange;
		
		if (color == -1)
			planet.rotationSpeed = -60.0f;
		else
			planet.rotationSpeed = -90.0f + MHRandomFloat() * 180.0f;

		[_planets addObject:planet];
		[planet addSpriteTo:_spriteBatchNode];
	}
}

- (void)updatePortals:(ccTime)dt
{
	_timeUntilPortalsDisappear -= dt;
	if (_timeUntilPortalsDisappear <= 0.0f)
	{
		_timeUntilPortalsDisappear = HUGE_VALF;
		_timeUntilPortalsDrain = HUGE_VALF;
		_timeUntilPortalsAppear = 2.0f;
		_dangerLevel = 0;

		_powerDrainRate *= 1.05f;    // increase by 5%
		if (_powerDrainRate > 0.5f)  // cap at 2 seconds
			_powerDrainRate = 0.5f;

		_spawnDelay *= 0.95f;
		if (_spawnDelay < 0.5f)
			_spawnDelay = 0.5f;

		_speedRange += 0.25f;
		if (_speedRange > 10.0f)
			_speedRange = 10.0f;

		[[SimpleAudioEngine sharedEngine] playEffect:@"PortalDisappear.wav"];

		for (Portal *portal in _portals)
			[portal animateDisappearing];
	}

	_timeUntilPortalsAppear -= dt;
	if (_timeUntilPortalsAppear <= 0.0f)
	{
		_timeUntilPortalsAppear = HUGE_VALF;
		_timeUntilPortalsDrain = 2.0f;
		_timeUntilPortalsDisappear = _portalLifetime + _timeUntilPortalsDrain;

		// The "portal probabilities" determine how many portals are likely
		// to appear at a give time. In the beginning you'll mostly get one
		// portal, but over time you'll keep getting more.

		_portalProbabilities[0] -= 3;
		if (_portalProbabilities[0] < 10)
			_portalProbabilities[0] = 10;

		_portalProbabilities[1] += 2;
		if (_portalProbabilities[1] > 40)
			_portalProbabilities[1] = 40;

		_portalProbabilities[2] += 1;
		if (_portalProbabilities[2] > 50)
			_portalProbabilities[2] = 50;

		[[SimpleAudioEngine sharedEngine] playEffect:@"PortalAppear.wav"];

		if (_firstTime)
		{
			_firstTime = NO;
			int color = MHRandomIntRange(1, 3);  // no white portal!
			[self addPortalAtEdge:PortalEdgeBottom position:_winSize.width/2.0f size:_winSize.width/3.0f color:color];
		}
		else
		{
			[self addRandomPortals];
		}
	}

	_timeUntilPortalsDrain -= dt;
	if (_timeUntilPortalsDrain <= 0.0f)
	{
		BOOL gameOver = NO;
		float lowestPower = HUGE_VALF;
		
		for (Portal *portal in _portals)
		{
			portal.power -= dt * _powerDrainRate;
			
			if (portal.power < lowestPower)
				lowestPower = portal.power;

			if (portal.power <= 0.0f)
				gameOver = YES;
		}

		if (gameOver)
		{
			[self gameOver];
		}
		else if (lowestPower < 0.1f && _dangerLevel < 3)
		{
			_dangerLevel = 3;
			_timeUntilFlashDangerous = 0.0f;
			_dangerFlashRate = 0.1f;

			if (_dangerSoundID == 0)
				_dangerSoundID = [[SimpleAudioEngine sharedEngine] playEffect:@"Danger.wav"];
		}
		else if (lowestPower < 0.2f && _dangerLevel < 2)
		{
			_dangerLevel = 2;
			_timeUntilFlashDangerous = 0.0f;
			_dangerFlashRate = 0.25f;

			if (_dangerSoundID == 0)
				_dangerSoundID = [[SimpleAudioEngine sharedEngine] playEffect:@"Danger.wav"];
		}
		else if (lowestPower < 0.3f && _dangerLevel < 1)
		{
			_dangerLevel = 1;
			_timeUntilFlashDangerous = 0.0f;
			_dangerFlashRate = 0.5f;
			
			if (_dangerSoundID == 0)
				_dangerSoundID = [[SimpleAudioEngine sharedEngine] playEffect:@"Danger.wav"];
		}
		else if (lowestPower >= 0.3f)
		{
			_dangerLevel = 0;
			_dangerSoundID = 0;
		}
	}
}

- (void)addRandomPortals
{
	int count;
	int total = _portalProbabilities[0] + _portalProbabilities[1] + _portalProbabilities[2];
	int rand = MHRandomInt(total);
	if (rand < _portalProbabilities[0])
		count = 1;
	else if (rand < _portalProbabilities[0] + _portalProbabilities[1])
		count = 2;
	else
		count = 3;

	if (count == 1)
	{
		PortalEdge edge = (PortalEdge)MHRandomInt(3);
		[self addRandomPortalAtEdge:edge allowWhite:NO];
	}
	else if (count == 2)
	{
		int which = MHRandomInt(3);
		if (which == 0)
			[self addRandomPortalsAtEdge1:PortalEdgeBottom edge2:PortalEdgeLeft];
		else if (which == 1)
			[self addRandomPortalsAtEdge1:PortalEdgeBottom edge2:PortalEdgeRight];
		else if (which == 2)
			[self addRandomPortalsAtEdge1:PortalEdgeLeft edge2:PortalEdgeRight];
	}
	else if (count == 3)
	{
		[self addRandomPortalsAtAllEdges];
	}
}

- (void)addRandomPortalsAtAllEdges
{
	PortalEdge edges[3];

	edges[0] = (PortalEdge)MHRandomInt(3);

	do
	{
		edges[1] = (PortalEdge)MHRandomInt(3);
	}
	while (edges[1] == edges[0]);

	do
	{
		edges[2] = (PortalEdge)MHRandomInt(3);
	}
	while (edges[2] == edges[1] || edges[2] == edges[0]);

	BOOL haveWhite = NO;
	for (int t = 0; t < 3; ++t)
	{
		if ([self addRandomPortalAtEdge:edges[t] allowWhite:!haveWhite])
			haveWhite = YES;
	}
}

- (void)addRandomPortalsAtEdge1:(PortalEdge)edge1 edge2:(PortalEdge)edge2
{
	if (MHRandomInt(2) == 0)
	{
		BOOL haveWhite = [self addRandomPortalAtEdge:edge1 allowWhite:YES];
		[self addRandomPortalAtEdge:edge2 allowWhite:!haveWhite];
	}
	else
	{
		BOOL haveWhite = [self addRandomPortalAtEdge:edge2 allowWhite:YES];
		[self addRandomPortalAtEdge:edge1 allowWhite:!haveWhite];
	}
}

- (BOOL)addRandomPortalAtEdge:(PortalEdge)edge allowWhite:(BOOL)allowWhite
{
	float size = MHRandomIntRange(40, _winSize.width / 2.0f);
	float pos = MHRandomIntRange(CapWidth + size/2, _winSize.width - size/2 - CapWidth*2);
	int color = MHRandomIntRange(allowWhite ? 0 : 1, 3);

	[self addPortalAtEdge:edge position:pos size:size color:color];
	return (color == 0);
}

- (void)addPortalAtEdge:(PortalEdge)edge position:(float)p size:(float)s color:(int)color
{
	CGPoint position;
	CGSize size;

	if (edge == PortalEdgeBottom)
	{
		position = ccp(p, PortalHeight/2.0f);
		size = CGSizeMake(s, PortalHeight);
	}
	else if (edge == PortalEdgeLeft)
	{
		position = ccp(PortalHeight/2.0f, p);
		size = CGSizeMake(PortalHeight, s);
	}
	else if (edge == PortalEdgeRight)
	{
		position = ccp(_winSize.width - 1.0f - PortalHeight/2.0f, p);
		size = CGSizeMake(PortalHeight, s);
	}

	Portal *portal = [[Portal alloc] initWithWorld:_world edge:edge position:position size:size color:color];
	[portal addSpritesTo:_spriteBatchNode];
	[_portals addObject:portal];
}

#pragma mark - Game Over

- (void)gameOver
{
	self.isTouchEnabled = NO;
	[self unschedule:@selector(update:)];

	[[SimpleAudioEngine sharedEngine] playEffect:@"Explosion.wav"];

	for (Planet *planet in _planets)
	{
		[self animateExplosionForPlanet:planet];
		[planet removeSprite];
	}

	for (Portal *portal in _portals)
		[portal removeSprites];

	[self performSelector:@selector(afterExplosions) withObject:nil afterDelay:1.5f];
}

- (void)animateExplosionForPlanet:(Planet *)planet
{
	CCSprite *sprite = [CCSprite spriteWithSpriteFrameName:@"explosion1_0001.png"];
	sprite.position = planet.position;
	sprite.anchorPoint = ccp(0.5f, 0.5f);
	[_explosionBatchNode addChild:sprite];

	id action = [CCSequence actions:
		[CCAnimate actionWithAnimation:_explosionAnimation],
		[CCCallBlock actionWithBlock:^{
			[sprite removeFromParentAndCleanup:YES];
		}],
		nil];

	[sprite runAction:action];
}

- (void)afterExplosions
{
	_planets = nil;
	_portals = nil;

	[_scoreLabel removeFromParentAndCleanup:YES];
	_scoreLabel = nil;

	[_timerLabel removeFromParentAndCleanup:YES];
	_timerLabel = nil;

	[_dangerLabel removeFromParentAndCleanup:YES];
	_dangerLabel = nil;

	[self.mainScene exitGame:_score];
}

#pragma mark - Instructions

- (void)showInstructionsAnimation
{
	_instructionsLabel = [CCLabelBMFont labelWithString:@"Swipe planets into matching portals\n\nGray moons go into any portal\n\nAny planet can go into a white portal\n\nDon't let the portals run out of power\n\nWatch out for the black hole!" fntFile:@"FontSmall.fnt"];
	_instructionsLabel.anchorPoint = ccp(0.0f, 0.0f);
	_instructionsLabel.alignment = kCCTextAlignmentCenter;
	[self addChild:_instructionsLabel z:10003];

	CGPoint instructionsPosition = ccp(
		floorf(_winSize.width/2.0f - _instructionsLabel.contentSize.width/2.0f),
		floorf(_winSize.height/2.0f - _instructionsLabel.contentSize.height/2.0f));

	id instructionsAction = [CCSequence actions:
		[CCDelayTime actionWithDuration:0.2f],
		[CCEaseExponentialOut actionWithAction:[CCMoveTo actionWithDuration:1.0f position:instructionsPosition]],
		[CCDelayTime actionWithDuration:4.0f],
		[CCEaseExponentialIn actionWithAction:[CCMoveTo actionWithDuration:0.5f position:ccp(-300.0f, instructionsPosition.y)]],
		[CCCallFunc actionWithTarget:self selector:@selector(instructionsAnimationComplete)],
		nil];

	_instructionsLabel.position = ccp(_winSize.width + 300.0f, instructionsPosition.y);
	[_instructionsLabel runAction:instructionsAction];
}

- (void)hideInstructionsAnimation
{
	if (_instructionsLabel != nil)
	{
		[_instructionsLabel stopAllActions];

		id instructionsAction = [CCSequence actions:
			[CCEaseExponentialIn actionWithAction:[CCMoveTo actionWithDuration:0.2f position:ccp(-300.0f, _instructionsLabel.position.y)]],
			[CCCallFunc actionWithTarget:self selector:@selector(instructionsAnimationComplete)],
			nil];

		[_instructionsLabel runAction:instructionsAction];
	}
}

- (void)instructionsAnimationComplete
{
	[_instructionsLabel removeFromParentAndCleanup:YES];
	_instructionsLabel = nil;
}

#pragma mark - Touch Handling

class MyQueryCallback : public b2QueryCallback
{
public:
	b2Vec2 impulse;

	bool ReportFixture(b2Fixture *fixture)
	{
		b2Body *body = fixture->GetBody();

		if (body->GetType() == b2_dynamicBody)
		{
			body->ApplyLinearImpulse(impulse, body->GetWorldCenter());

			float direction = (impulse.x < 0.0f) ? 1.0f : -1.0f;
			body->ApplyAngularImpulse(direction * impulse.Length() / 10.0f);
		}

		return true;
	}
};

- (b2Vec2)touchToWorld:(UITouch *)touch
{
	CGPoint location = [[CCDirector sharedDirector] convertToGL:[touch locationInView:[touch view]]];
	b2Vec2 locationWorld = b2Vec2(POINTS_TO_METERS(location.x), POINTS_TO_METERS(location.y));
	return locationWorld;
}

- (void)ccTouchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
	[self hideInstructionsAnimation];

	UITouch* touch = [touches anyObject];
	b2Vec2 locationWorld = [self touchToWorld:touch];
	_lastTouchLocation = locationWorld;
}

- (void)ccTouchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
	UITouch* touch = [touches anyObject];
	b2Vec2 locationWorld = [self touchToWorld:touch];

	b2Vec2 diff = locationWorld - _lastTouchLocation;

	MyQueryCallback callback;
	callback.impulse = diff;

	b2AABB aabb;
	aabb.lowerBound.Set(locationWorld.x - 1.0f, locationWorld.y - 1.0f);
	aabb.upperBound.Set(locationWorld.x + 1.0f, locationWorld.y + 1.0f);
	_world->QueryAABB(&callback, aabb);

	_lastTouchLocation = locationWorld;
}

@end
