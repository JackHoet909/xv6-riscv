#include "kernel/pstat.h"
#include "kernel/types.h"
#include "kernel/stat.h"
#include "user/user.h"

void main(){
    struct pstat ps;
    getpinfo(&ps);
    for(int i = 0; i<NPROC; i++){
	if (ps.inuse[i])
        printf("pid: %d, runtime: %d\n", ps.pid[i], ps.runtime[i]);
    }
}
