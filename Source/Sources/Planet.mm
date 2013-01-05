
#import "Planet.h"
#import "Defs.h"
#import "Portal.h"

@implementation Planet
{
	CCSprite *_sprite;    // owned by CCSpriteBatchNode
	b2World *_world;      // owned by GameLayer
	b2Body *_body;        // owned by b2World
}

- (id)initWithWorld:(b2World *)world size:(int)size position:(CGPoint)position angle:(float)angle color:(int)color
{
	if ((self = [super init]))
	{
		_state = PlanetStateFalling;
		_world = world;
		_size = size;
		_color = color;

		b2BodyDef bodyDef;
		bodyDef.type = b2_dynamicBody;
		bodyDef.allowSleep = true;
		bodyDef.position.Set(POINTS_TO_METERS(position.x), POINTS_TO_METERS(position.y));
		bodyDef.userData = (__bridge void *)self;
		bodyDef.angle = CC_DEGREES_TO_RADIANS(angle);
		_body = world->CreateBody(&bodyDef);

		NSString *frameName;
		if (color == -1)
			frameName = @"Black Hole.png";
		else
			frameName = [NSString stringWithFormat:@"Planet_%d%c.png", color, size + 'A'];

		_sprite = [CCSprite spriteWithSpriteFrameName:frameName];
		_sprite.anchorPoint = ccp(0.5f, 0.5f);
		_sprite.position = position;
		_sprite.rotation = -angle;

		b2CircleShape shape;
		shape.m_radius = POINTS_TO_METERS(_sprite.contentSize.width/2.0f);

		b2FixtureDef fixtureDef;
		fixtureDef.shape = &shape;	
		fixtureDef.friction = 1.0f;
		fixtureDef.restitution = 0.0f;
		fixtureDef.density = (1.0f - shape.m_radius*shape.m_radius) * 0.5f;  // trial-and-error
		_body->CreateFixture(&fixtureDef);
	}
	return self;
}

- (void)dealloc
{
	//NSLog(@"dealloc %@", self);

	[self removeSprite];
	[self removeBody];
}

- (void)setFallingSpeed:(float)fallingSpeed
{
	_fallingSpeed = fallingSpeed;
	_body->SetLinearVelocity(b2Vec2(0.0f, fallingSpeed));
}

- (void)setRotationSpeed:(float)rotationSpeed
{
	_rotationSpeed = rotationSpeed;
	_body->SetAngularVelocity(CC_DEGREES_TO_RADIANS(rotationSpeed));
}

- (CGPoint)position
{
	return _sprite.position;
}

- (void)addSpriteTo:(CCNode *)parent
{
	[parent addChild:_sprite];
}

- (void)removeSprite
{
	if (_sprite != NULL)
	{
		[_sprite removeFromParentAndCleanup:YES];
		_sprite = nil;
	}
}

- (void)removeBody
{
	if (_body != NULL)
	{
		_world->DestroyBody(_body);
		_body = NULL;
	}
}

- (void)update:(ccTime)dt
{
	if (_sprite != nil && _body != NULL)
	{
		_sprite.position = ccp(
			METERS_TO_POINTS(_body->GetPosition().x),
			METERS_TO_POINTS(_body->GetPosition().y));

		_sprite.rotation = -1.0f * CC_RADIANS_TO_DEGREES(_body->GetAngle());
	}
}

- (void)handleCollision
{
	if (self.state != PlanetStateCollided)
	{
		self.state = PlanetStateCollided;

		[self removeBody];

		// Wrong planets get sucked in a bit slower
		float duration = 0.3f;
		if (self.color != 0 && self.collidedWith.color != 0 && self.color != self.collidedWith.color)
			duration = 0.6f;

		id sequence = [CCSequence actions:
			[CCSpawn actions:
				[CCScaleTo actionWithDuration:duration scale:0.1f],
				[CCMoveTo actionWithDuration:duration position:self.collidedWith.center],
				[CCFadeOut actionWithDuration:duration],
				nil],
			[CCCallBlock actionWithBlock:^{ self.state = PlanetStateDead; }],
			nil];

		[_sprite runAction:sequence];
	}
}

@end
