/*
 * Macros and helper functions.
 */

#define STRINGIFY2(x) #x
#define STRINGIFY(x) STRINGIFY2(x)

/* Debug logging macro. Does nothing in release mode. */
#ifdef DEBUG
#define MHLog(...) do { NSLog(@"%s %@", __PRETTY_FUNCTION__, [NSString stringWithFormat:__VA_ARGS__]); } while (0)
#else
#define MHLog(...) do { } while (0)
#endif

/*
 * Assert macro. Simply writes a log message in release mode.
 * Based on http://www.cimgf.com/2010/05/02/my-current-prefix-pch-file/
 */
#ifdef DEBUG
  #define MHAssert(condition, ...) do { if (!(condition)) { [[NSAssertionHandler currentHandler] handleFailureInFunction:[NSString stringWithCString:__PRETTY_FUNCTION__ encoding:NSUTF8StringEncoding] file:[NSString stringWithCString:__FILE__ encoding:NSUTF8StringEncoding] lineNumber:__LINE__ description:__VA_ARGS__]; }} while(0)
#else
  #ifndef NS_BLOCK_ASSERTIONS
    #define NS_BLOCK_ASSERTIONS
  #endif
  #define MHAssert(condition, ...) do { if (!(condition)) { NSLog(@"%s %@", __PRETTY_FUNCTION__, [NSString stringWithFormat:__VA_ARGS__]); }} while (0)
#endif

/* Dumps the name of the class and current method to the console. */
#if defined(DEBUG)
#define MHLogFunction() do { NSLog(@"[<%@ %p> %@]", NSStringFromClass([self class]), self, NSStringFromSelector(_cmd)); } while (0)
#else
#define MHLogFunction() do { } while (0)
#endif

/* Indicates that a method is abstract. */
#define MHMustOverride() [self doesNotRecognizeSelector:_cmd]

/* Returns the larger of a and b. */
#ifndef MAX
#define MAX(a,b) (((a)>(b))?(a):(b))
#endif

/* Returns the smaller of a and b. */
#ifndef MIN
#define MIN(a,b) (((a)<(b))?(a):(b))
#endif

/* Calculates the number of items in a C array. */
#define ARRAY_SIZE(a) (int)(sizeof(a)/sizeof(a[0]))

/* Pi as a float constant. */
#define PI 3.14159265358979323846f

/* Pi*2 as a float constant. */
#define TWO_PI 6.28318530717958647693f

/* Pi/2 as a float constant. */
#define HALF_PI 1.57079632679489661923f

/* Converts an angle in degrees to radians. */
#define MHDegreesToRadians(x) (PI * (x) / 180.0f)

/* Converts an angle in radians to degrees. */
#define MHRadiansToDegrees(x) ((x) * 180.0f / PI)

/*
 * Returns the number of milliseconds that have elapsed since system startup.
 */
double MHMilliseconds(void);
