
#import "MHRandom.h"

int MHRandomInt(int n)
{
	return arc4random_uniform(n);
}

int MHRandomIntRange(int a, int b)
{
	return MHRandomInt(b - a + 1) + a;
}

float MHRandomFloat(void)
{
	return (float)arc4random()/0xFFFFFFFFu;
}
