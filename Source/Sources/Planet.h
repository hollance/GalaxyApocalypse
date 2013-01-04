
#import "cocos2d.h"
#import "Box2D.h"

typedef enum
{
	PlanetStateFalling,
	PlanetStateCollided,
}
PlanetState;

@class Portal;

@interface Planet : NSObject

@property (nonatomic, assign) BOOL isDead;
@property (nonatomic, assign) PlanetState state;
@property (nonatomic, assign, readonly) int size;

@property (nonatomic, assign) float fallingSpeed;
@property (nonatomic, assign) float rotationSpeed;

/*
 * -1 = black, goes with no portal
 *  0 = white, goes with any color portal
 *  1 and higher = goes only with the same portal color
 */
@property (nonatomic, assign, readonly) int color;

@property (nonatomic, assign, readonly) CGPoint position;

@property (nonatomic, weak) Portal *collidedWith;

- (id)initWithWorld:(b2World *)world size:(int)size position:(CGPoint)position angle:(float)angle color:(int)color;
- (void)addSpriteTo:(CCNode *)parent;
- (void)removeFromParent;
- (void)update:(ccTime)dt;
- (void)handleCollision;

@end
