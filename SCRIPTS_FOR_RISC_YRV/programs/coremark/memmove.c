/* Wrapper to implement ANSI C's memmove using BSD's bcopy. */
/* This function is in the public domain.  --Per Bothner. */

/*

@deftypefn Supplemental void* memmove (void *@var{from}, const void *@var{to}, @
  size_t @var{count})

Copies @var{count} bytes from memory area @var{from} to memory area
@var{to}, returning a pointer to @var{to}.

@end deftypefn

*/

#include "coremark.h"

void bcopy (const void*, void*, size_t);

void *
memmove (void *s1, const void *s2, size_t n)
{
  bcopy (s2, s1, n);
  return s1;
}
