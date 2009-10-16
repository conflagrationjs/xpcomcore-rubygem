#include <stdlib.h>
#include <stdio.h>
#include <unistd.h>

int main (int argc, const char * argv[]) {
  char *executable = NULL;
  char *exec_args[argc + 1];
  int i;
  
  executable = getenv("REAL_EXECUTABLE");
  exec_args[0] = executable;
  
  for (i = 1; i < argc; i++) {
    exec_args[i] = (char *) argv[i];
  }
  
  exec_args[argc] = NULL;
  return execv(executable, exec_args);
}