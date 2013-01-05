
#import "cocos2d.h"
#import "Box2D.h"

extern const float CapWidth;
extern const float PortalHeight;

typedef enum
{
	PortalEdgeBottom,
	PortalEdgeLeft,
	PortalEdgeRight,
}
PortalEdge;

@interface Portal : NSObject

@property (nonatomic, assign) BOOL isDead;
@property (nonatomic, assign) float power;

@property (nonatomic, assign, readonly) PortalEdge edge;
@property (nonatomic, assign, readonly) CGPoint center;
@property (nonatomic, assign, readonly) int color;

- (id)initWithWorld:(b2World *)world edge:(PortalEdge)edge position:(CGPoint)position size:(CGSize)size color:(int)color;

- (void)addSpritesTo:(CCNode *)parent;
- (void)removeSprites;

- (void)update:(ccTime)dt;

- (void)animateDisappearing;
- (void)animateCollision;

@end
