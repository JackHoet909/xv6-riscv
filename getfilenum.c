#include "kernel/types.h"
#include "kernel/stat.h"
#include "user/user.h"
#include "kernel/fs.h"
#include "kernel/fcntl.h"
#include "kernel/pstat.h" // include the pstat structure definition

int main(int argc, char **argv)
{
    int pid = getpid();
    struct pstat pinfo;
    if (getpinfo(&pinfo) < 0) 
    {
        printf("getpinfo failed\n");
        exit(1);
    }
    for (int i = 0; i < NPROC; i++)
    {
        if (pinfo.inuse[i])
        {
            printf("Process ID: %d and Runtime %d \n", pinfo.pid[i], pinfo.runtime[i]);
        }
    }
    
    exit(0);
}
