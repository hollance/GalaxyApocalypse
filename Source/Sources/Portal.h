
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

@property (nonatomic, assign, readonly) PortalEdge edge;
@property (nonatomic, assign, readonly) CGPoint center;
@property (nonatomic, assign, readonly) int color;

@property (nonatomic, assign) BOOL isDead;
@property (nonatomic, assign) float power;

- (id)initWithWorld:(b2World *)world edge:(PortalEdge)edge;
- (void)moveTo:(CGPoint)position size:(CGSize)size color:(int)color;
- (void)addSpritesTo:(CCNode *)parent;
- (void)removeFromParent;
- (void)animateDisappearing;
- (void)animateCollision;
- (void)update:(ccTime)dt;

@end
