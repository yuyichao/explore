/* demo_uts_namespaces.c

   Copyright 2013, Michael Kerrisk
   Licensed under GNU General Public License v2 or later

   Demonstrate the operation of UTS namespaces.
*/
#include <sys/wait.h>
#include <sys/utsname.h>
#include <sys/stat.h>
#include <sched.h>
#include <string.h>
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>

/* A simple error-handling function: print an error message based
   on the value in 'errno' and terminate the calling process */

static inline void
errExit(const char *msg)
{
     perror(msg);
     exit(EXIT_FAILURE);
}

static inline void
print_link(const char *file)
{
    char link[1024 + 1] = {0};
    if (readlink(file, link, sizeof(link) - 1) == -1)
        errExit("readlink");
    printf("%s -> %s\n", file, link);
}

/* Start function for cloned child */
static int
childFunc(void *arg)
{
    /* Change hostname in UTS namespace of child */

    if (sethostname(arg, strlen(arg)) == -1)
        errExit("sethostname");

    struct utsname uts;

    /* Retrieve and display hostname */

    if (uname(&uts) == -1)
        errExit("uname");
    printf("uts.nodename in child:  %s\n", uts.nodename);
    printf("uts namespace for child: ");
    print_link("/proc/self/ns/uts");

    return 0;           /* Terminates child */
}

#define STACK_SIZE (1024 * 1024)    /* Stack size for cloned child */

static char child_stack[STACK_SIZE];

int
main(int argc, char *argv[])
{
    pid_t child_pid;
    struct utsname uts;

    if (argc < 2) {
        fprintf(stderr, "Usage: %s <child-hostname>\n", argv[0]);
        exit(EXIT_FAILURE);
    }

    /* Create a child that has its own UTS namespace;
       the child commences execution in childFunc() */

    child_pid = clone(childFunc,
                      child_stack + STACK_SIZE,   /* Points to start of
                                                     downwardly growing stack */
                      CLONE_NEWUTS | SIGCHLD, argv[1]);
    if (child_pid == -1)
        errExit("clone");
    printf("PID of child created by clone() is %ld\n", (long) child_pid);

    /* Parent falls through to here */

    sleep(1);           /* Give child time to change its hostname */

    /* Display the hostname in parent's UTS namespace. This will be
       different from the hostname in child's UTS namespace. */

    if (uname(&uts) == -1)
        errExit("uname");
    printf("uts.nodename in parent: %s\n", uts.nodename);
    printf("uts namespace for parent: ");
    print_link("/proc/self/ns/uts");

    if (waitpid(child_pid, NULL, 0) == -1)      /* Wait for child */
        errExit("waitpid");
    printf("child has terminated\n");

    exit(EXIT_SUCCESS);
}
