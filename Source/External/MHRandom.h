/*
 * Functions for generating random numbers.
 */

#ifdef __cplusplus 
extern "C" {
#endif

/*
 * Returns a pseudo-random integer between 0 and n-1.
 *
 * This function is guaranteed to generate a uniform distribution of random
 * numbers.
 *
 * You don't need to seed this random generator. This function is thread-safe.
 */
int MHRandomInt(int n);

/*
 * Returns a pseudo-random integer between a and b (inclusive).
 *
 * You don't need to seed this random generator. This function is thread-safe.
 */
int MHRandomIntRange(int a, int b);

/*
 * Returns a pseudo-random float between 0 and 1.0 (inclusive) with a uniform
 * distribution.
 *
 * You don't need to seed this random generator. This function is thread-safe.
 */
float MHRandomFloat(void);

#ifdef __cplusplus
}
#endif
