/* bcopy -- copy memory regions of arbitary length

@deftypefn Supplemental void bcopy (char *@var{in}, char *@var{out}, int @var{length})

Copies @var{length} bytes from memory region @var{in} to region
@var{out}.  The use of @code{bcopy} is deprecated in new programs.

@end deftypefn

*/

#include "coremark.h"

void
bcopy (const void *src, void *dest, size_t len)
{
  if (dest < src)
    {
      const char *firsts = (const char *) src;
      char *firstd = (char *) dest;
      while (len--)
	*firstd++ = *firsts++;
    }
  else
    {
      const char *lasts = (const char *)src + (len-1);
      char *lastd = (char *)dest + (len-1);
      while (len--)
        *lastd-- = *lasts--;
    }
}
