#include <signal.h>
#include <sys/wait.h>
#include <stdio.h>
#include <unistd.h>
#include <string.h>

static void
signalHandler(int sig)
{
    printf("%s: %d\n", __func__, sig);
    int status;
    int ret = waitpid(-1, &status, 0);
    printf("%s, ret: %d, status: %d\n", __func__, ret, status);
}

int
main()
{
    struct sigaction sig_act;
    memset(&sig_act, 0, sizeof(sig_act));
    sig_act.sa_handler = signalHandler;
    sigaction(SIGCHLD, &sig_act, NULL);

    if (!fork()) {
        sleep(2);
        printf("%s: long run child %d exit.\n", __func__, getpid());
        _exit(0);
    }

    sleep(0.1);

    if (!fork()) {
        sleep(2);
        printf("%s: long run child %d exit.\n", __func__, getpid());
        _exit(0);
    }

    /* memset(&sig_act, 0, sizeof(sig_act)); */
    /* sig_act.sa_handler = SIG_IGN; */
    /* sigaction(SIGCHLD, &sig_act, NULL); */

    sigset_t set;
    sigemptyset(&set);
    sigaddset(&set, SIGCHLD);
    sigprocmask(SIG_BLOCK, &set, NULL);

    pid_t pid = fork();
    if (!pid) {
        sleep(4);
        printf("%s: %d exit.\n", __func__, getpid());
        _exit(0);
    }
    printf("%s: %d -> %d\n", __func__, getpid(), pid);

    sleep(1);
    printf("%s, start waiting for %d\n", __func__, pid);
    int status;
    int ret = waitpid(pid, &status, 0);
    printf("%s, ret: %d, pid: %d, status: %d\n", __func__, ret, pid, status);

    sigprocmask(SIG_UNBLOCK, &set, NULL);
    sleep(0.1);
    sleep(0.1);
    sleep(0.1);
    sleep(0.1);
    return 0;
}
