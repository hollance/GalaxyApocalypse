
#import <sys/time.h>
#import "MHUtil.h"

double MHMilliseconds(void)
{
	struct timeval tv;
	gettimeofday(&tv, NULL);
	return tv.tv_sec*1000.0 + tv.tv_usec/1000.0;
}
