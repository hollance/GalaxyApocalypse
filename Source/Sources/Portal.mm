
#import "Portal.h"
#import "Defs.h"
#import "MHRandom.h"

const float CapWidth = 10.0f;
const float PortalHeight = 20.0f;

@implementation Portal
{
	CGPoint _position;
	CGSize _size;

	b2World *_world;
	b2Body *_beamBody;
	b2Body *_startCapBody;
	b2Body *_endCapBody;

	CCSprite *_startCapSprite;
	CCSprite *_endCapSprite;
	CCSprite *_beamSprite;
	CCSprite *_flashSprite;
	
	ccTime _flickerTime;
}

- (id)initWithWorld:(b2World *)world edge:(PortalEdge)edge position:(CGPoint)position size:(CGSize)size color:(int)color
{
	if ((self = [super init]))
	{
		_world = world;
		_edge = edge;
		_position = position;
		_size = size;
		_color = color;

		_power = 1.0f;
		_flickerTime = 0.0f;
	}
	return self;
}

- (void)dealloc
{
	//NSLog(@"dealloc %@", self);

	[self removeSprites];
	[self removeBody];
}

- (CGPoint)center
{
	return _position;
}

- (void)setPower:(float)power
{
	if (power > 1.0f)
		power = 1.0f;
	else if (power < 0.0f)
		power = 0.0f;

	_power = power;
	_beamSprite.opacity = _power * 255;
}

- (CGPoint)startCapInitialPosition
{
	if (_edge == PortalEdgeBottom)
		return CGPointMake(_position.x - CapWidth/2.0f, _position.y);
	else
		return CGPointMake(_position.x, _position.y + CapWidth/2.0f);
}

- (CGPoint)startCapPosition
{
	if (_edge == PortalEdgeBottom)
	{
		return CGPointMake(
			_position.x - (_size.width + CapWidth)/2.0f,
			_position.y);
	}
	else
	{
		return CGPointMake(
			_position.x,
			_position.y + (_size.height + CapWidth)/2.0f);
	}
}

- (CGPoint)endCapInitialPosition
{
	if (_edge == PortalEdgeBottom)
		return CGPointMake(_position.x + CapWidth/2.0f, _position.y);
	else
		return CGPointMake(_position.x, _position.y - CapWidth/2.0f);
}

- (CGPoint)endCapPosition
{
	if (_edge == PortalEdgeBottom)
	{
		return CGPointMake(
			_position.x + (_size.width + CapWidth)/2.0f,
			_position.y);
	}
	else
	{
		return CGPointMake(
			_position.x,
			_position.y - (_size.height + CapWidth)/2.0f);
	}
}

- (void)addSpritesTo:(CCNode *)parent
{
	NSString *startCapFrameName;
	NSString *endCapFrameName;
	NSString *beamFrameName;
	NSString *flashFrameName;

	if (_edge == PortalEdgeBottom)
	{
		startCapFrameName = @"Portal_Horz_StartCap%d.png";
		endCapFrameName = @"Portal_Horz_EndCap%d.png";
		beamFrameName = @"Portal_Horz_Beam%d.png";
		flashFrameName = @"Portal_Horz_Beam_Flash.png";
	}
	else
	{
		startCapFrameName = @"Portal_Vert_StartCap%d.png";
		endCapFrameName = @"Portal_Vert_EndCap%d.png";
		beamFrameName = @"Portal_Vert_Beam%d.png";
		flashFrameName = @"Portal_Vert_Beam_Flash.png";
	}
	
	startCapFrameName = [NSString stringWithFormat:startCapFrameName, _color];
	endCapFrameName = [NSString stringWithFormat:endCapFrameName, _color];
	beamFrameName = [NSString stringWithFormat:beamFrameName, _color];

	_startCapSprite = [CCSprite spriteWithSpriteFrameName:startCapFrameName];
	_startCapSprite.anchorPoint = ccp(0.5f, 0.5f);
	_startCapSprite.position = [self startCapInitialPosition];
	_startCapSprite.opacity = 0;
	[parent addChild:_startCapSprite];

	_endCapSprite = [CCSprite spriteWithSpriteFrameName:endCapFrameName];
	_endCapSprite.anchorPoint = ccp(0.5f, 0.5f);
	_endCapSprite.position = [self endCapInitialPosition];
	_endCapSprite.opacity = 0;
	[parent addChild:_endCapSprite];

	_beamSprite = [CCSprite spriteWithSpriteFrameName:beamFrameName];
	_beamSprite.anchorPoint = ccp(0.5f, 0.5f);
	_beamSprite.position = _position;
	_beamSprite.opacity = 0;
	[parent addChild:_beamSprite];

	_flashSprite = [CCSprite spriteWithSpriteFrameName:flashFrameName];
	_flashSprite.anchorPoint = ccp(0.5f, 0.5f);
	_flashSprite.position = _position;
	_flashSprite.opacity = 0;
	[parent addChild:_flashSprite];

	if (_edge == PortalEdgeBottom)
		_flashSprite.scaleX = _beamSprite.scaleX = _size.width / _beamSprite.contentSize.width;
	else
		_flashSprite.scaleY = _beamSprite.scaleY = _size.height / _beamSprite.contentSize.height;

	id startCapAction = [CCSequence actions:
		[CCFadeIn actionWithDuration:0.4f],
		[CCEaseSineOut actionWithAction:[CCMoveTo actionWithDuration:0.8f position:[self startCapPosition]]],
		nil];
	
	[_startCapSprite runAction:startCapAction];

	id endCapAction = [CCSequence actions:
		[CCFadeIn actionWithDuration:0.4f],
		[CCEaseSineOut actionWithAction:[CCMoveTo actionWithDuration:0.8f position:[self endCapPosition]]],
		nil];

	[_endCapSprite runAction:endCapAction];
	
	id beamAction = [CCSequence actions:
		[CCDelayTime actionWithDuration:1.2f],
		[CCFadeIn actionWithDuration:0.2f],
		nil];

	[_beamSprite runAction:beamAction];

	id flashAction = [CCSequence actions:
		[CCDelayTime actionWithDuration:1.0f],
		[CCFadeIn actionWithDuration:0.2f],
		[CCFadeOut actionWithDuration:0.5f],
		[CCCallBlock actionWithBlock:^
		{
			_flashSprite.visible = NO;
			[self addBody];
		}],
		nil];

	[_flashSprite runAction:flashAction];
}

- (void)removeSprites
{
	if (_startCapSprite != nil)
	{
		[_startCapSprite removeFromParentAndCleanup:YES];
		_startCapSprite = nil;
	}

	if (_endCapSprite != nil)
	{
		[_endCapSprite removeFromParentAndCleanup:YES];
		_endCapSprite = nil;
	}

	if (_beamSprite != nil)
	{
		[_beamSprite removeFromParentAndCleanup:YES];
		_beamSprite = nil;
	}

	if (_flashSprite != nil)
	{
		[_flashSprite removeFromParentAndCleanup:YES];
		_flashSprite = nil;
	}
}

- (void)addBody
{
	b2BodyDef bodyDef;
	bodyDef.type = b2_staticBody;
	bodyDef.position.Set(POINTS_TO_METERS(_position.x), POINTS_TO_METERS(_position.y));
	bodyDef.userData = (__bridge void *)self;
	_beamBody = _world->CreateBody(&bodyDef);

	b2PolygonShape shape;
	shape.SetAsBox(POINTS_TO_METERS(_size.width/2.0f), POINTS_TO_METERS(_size.height/2.0f));

	b2FixtureDef fixtureDef;
	fixtureDef.shape = &shape;	
	fixtureDef.friction = 1.0f;
	fixtureDef.restitution = 0.0f;
	fixtureDef.density = 1.0f;
	_beamBody->CreateFixture(&fixtureDef);

	b2PolygonShape capShape;
	if (_edge == PortalEdgeBottom)
		capShape.SetAsBox(POINTS_TO_METERS(CapWidth/2.0f), POINTS_TO_METERS(PortalHeight/2.0f));
	else
		capShape.SetAsBox(POINTS_TO_METERS(PortalHeight/2.0f), POINTS_TO_METERS(CapWidth/2.0f));

	b2FixtureDef capFixtureDef;
	capFixtureDef.shape = &capShape;

	b2BodyDef capBodyDef;
	capBodyDef.type = b2_staticBody;
	capBodyDef.userData = NULL;      // it doesn't count for collisions

	CGPoint startCapPosition = [self startCapPosition];
	CGPoint endCapPosition = [self endCapPosition];

	capBodyDef.position.Set(POINTS_TO_METERS(startCapPosition.x), POINTS_TO_METERS(startCapPosition.y));
	_startCapBody = _world->CreateBody(&capBodyDef);
	_startCapBody->CreateFixture(&capFixtureDef);

	capBodyDef.position.Set(POINTS_TO_METERS(endCapPosition.x), POINTS_TO_METERS(endCapPosition.y));
	_endCapBody = _world->CreateBody(&capBodyDef);
	_endCapBody->CreateFixture(&capFixtureDef);
}

- (void)removeBody
{
	if (_startCapBody != NULL)
	{
		_world->DestroyBody(_startCapBody);
		_startCapBody = NULL;
	}

	if (_endCapBody != NULL)
	{
		_world->DestroyBody(_endCapBody);
		_endCapBody = NULL;
	}

	if (_beamBody != NULL)
	{
		_world->DestroyBody(_beamBody);
		_beamBody = NULL;
	}
}

- (void)update:(ccTime)dt
{
	_flickerTime -= dt;
	if (_flickerTime <= 0.0f)
	{
		_flickerTime = 0.02f + MHRandomFloat() * 0.1f;
		
		if (_edge == PortalEdgeBottom)
			_beamSprite.flipY = !_beamSprite.flipY;
		else
			_beamSprite.flipX = !_beamSprite.flipX;
	}
}

- (void)animateDisappearing
{
	[self removeBody];

	id startCapAction = [CCSequence actions:
		[CCDelayTime actionWithDuration:0.3f],
		[CCEaseSineOut actionWithAction:[CCMoveTo actionWithDuration:0.2f position:[self startCapInitialPosition]]],
		[CCFadeOut actionWithDuration:0.2f],
		nil];
	
	[_startCapSprite runAction:startCapAction];

	id endCapAction = [CCSequence actions:
		[CCDelayTime actionWithDuration:0.3f],
		[CCEaseSineOut actionWithAction:[CCMoveTo actionWithDuration:0.2f position:[self endCapInitialPosition]]],
		[CCFadeOut actionWithDuration:0.2f],
		nil];

	[_endCapSprite runAction:endCapAction];

	id beamAction = [CCSequence actions:
		[CCFadeTo actionWithDuration:0.2f opacity:0],
		[CCDelayTime actionWithDuration:1.0f],
		[CCCallBlock actionWithBlock:^{ self.isDead = YES; }],
		nil];

	[_beamSprite runAction:beamAction];
}

- (void)animateCollision
{
	_flashSprite.visible = YES;
	[_flashSprite stopAllActions];

	id flashAction = [CCSequence actions:
		[CCFadeOut actionWithDuration:0.2f],
		[CCCallBlock actionWithBlock:^ { _flashSprite.visible = NO; }],
		nil];

	[_flashSprite runAction:flashAction];
}

@end
