/*
This file contains a simple fuzzer for testing command line argument parsing
using persistent mode.
*/

#include <stdio.h>
#include <string.h>
#include "argv-fuzz-inl.h"

/* this lets the source compile without afl-clang-fast/lto */
#ifndef __AFL_FUZZ_TESTCASE_LEN

  ssize_t       fuzz_len;
  unsigned char fuzz_buf[1024000];

  #define __AFL_FUZZ_TESTCASE_LEN fuzz_len
  #define __AFL_FUZZ_TESTCASE_BUF fuzz_buf
  #define __AFL_FUZZ_INIT() void sync(void);
  #define __AFL_LOOP(x) \
    ((fuzz_len = read(0, fuzz_buf, sizeof(fuzz_buf))) > 0 ? 1 : 0)
  #define __AFL_INIT() sync()

#endif

__AFL_FUZZ_INIT();

/* The main function is an entry point for a program.
   The argc parameter is an integer that indicates the number of arguments
   passed to the program. The argv parameter is an array of character pointers,
   with each element pointing to a null-terminated string that represents
   one of the arguments.
 */
int main(int argc, char **argv) {

#ifdef __AFL_HAVE_MANUAL_CONTROL
  __AFL_INIT();
#endif
  unsigned char *buf = __AFL_FUZZ_TESTCASE_BUF;

  /* __AFL_LOOP() limits the maximum number of iterations before exiting
     the loop and allowing the program to terminate. It protects against
     accidental memory leaks and similar issues. */
  while (__AFL_LOOP(100000)) {

    int len = __AFL_FUZZ_TESTCASE_LEN;

    // Check that the length of the test case is at least 8 bytes
    if (len < 8) continue;

    // Initialize the command line arguments using the testcase buffer
    AFL_INIT_ARGV_PERSISTENT(buf);

    /* Check if the first argument is "XYZ" and the second argument is "TEST2"
       If so, call the "abort" function to terminate the program.
       Otherwise, print an error message. */
    if (argc > 1 && strcmp(argv[1], "XYZ") == 0) {

      if (strcmp(argv[2], "TEST2") == 0) { abort(); }

    } else {

      printf("Bad number of arguments!\n");

    }

  }

  /* Exiting the loop allows the program to terminate normally. AFL will restart
     the process with a clean slate for allocated memory, file descriptors, etc.
  */
  return 0;

}

