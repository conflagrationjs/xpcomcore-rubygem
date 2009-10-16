#include <stdlib.h>
#include <stdio.h>
#include <unistd.h>
#include <string.h>

int main (int argc, const char * argv[]) {
  char *executable = NULL;
  char *tee_out_cmd;
  char *tee_err_cmd;
  char *hijacked_stdout = NULL;
  char *hijacked_stderr = NULL;
  char *exec_args[argc + 1];
  int i;
  FILE *hijacked_stdout_fd;
  FILE *hijacked_stderr_fd;
  
  executable = getenv("REAL_EXECUTABLE");
  exec_args[0] = executable;
  
  for (i = 1; i < argc; i++) {
    exec_args[i] = (char *) argv[i];
  }
  
  if (getenv("HIJACK_OUTPUT") != NULL) {
    hijacked_stdout = getenv("HIJACKED_STDOUT");
    hijacked_stderr = getenv("HIJACKED_STDERR");

    tee_out_cmd = (char *)malloc(strlen("tee ") + strlen(hijacked_stdout) + 1);
    tee_err_cmd = (char *)malloc(strlen("tee ") + strlen(hijacked_stderr) + 1);
    
    sprintf(tee_out_cmd, "tee %s", hijacked_stdout);
    sprintf(tee_err_cmd, "tee %s", hijacked_stderr);
    
    hijacked_stdout_fd = popen(tee_out_cmd, "w");
    hijacked_stderr_fd = popen(tee_err_cmd, "w");
    
    dup2(fileno(hijacked_stdout_fd), STDOUT_FILENO);
    dup2(fileno(hijacked_stderr_fd), STDERR_FILENO);
  }
  
  exec_args[argc] = NULL;
  return execv(executable, exec_args);
}