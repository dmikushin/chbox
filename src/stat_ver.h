#ifndef STAT_VER_H
#define STAT_VER_H

#ifndef _STAT_VER
 #if defined (__aarch64__)
  #define _STAT_VER 0
 #elif defined (__x86_64__)
  #define _STAT_VER 1
 #else
  #define _STAT_VER 3
 #endif
#endif

#endif // STAT_VER_H
