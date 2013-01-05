
#import "cocos2d.h"
#import "Box2D.h"

typedef enum
{
	PlanetStateFalling,
	PlanetStateCollided,  // planet is being sucked into a portal
	PlanetStateDead,
}
PlanetState;

@class Portal;

@interface Planet : NSObject

@property (nonatomic, assign) PlanetState state;
@property (nonatomic, assign) float fallingSpeed;
@property (nonatomic, assign) float rotationSpeed;

@property (nonatomic, weak) Portal *collidedWith;

@property (nonatomic, assign, readonly) CGPoint position;
@property (nonatomic, assign, readonly) int size;
@property (nonatomic, assign, readonly) int color;

/*
 * Size is a value in the range 0 - 3.
 *
 * Color means the following:
 *
 *   -1 = black hole, goes with no portal
 *    0 = moon, goes with any color portal
 *    1 = red    }
 *    2 = green  } go only with the same portal color
 *    3 = blue   }
 */
- (id)initWithWorld:(b2World *)world size:(int)size position:(CGPoint)position angle:(float)angle color:(int)color;

- (void)addSpriteTo:(CCNode *)parent;
- (void)removeSprite;

- (void)update:(ccTime)dt;
- (void)handleCollision;

@end
