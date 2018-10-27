/*#include "types.h"
#include "x86.h"
#include "defs.h"
#include "param.h"
#include "memlayout.h"
#include "mmu.h"
#include "proc.h"
#include "user.h"
*/

#include "param.h"
#include "types.h"
#include "stat.h"
#include "user.h"
#include "fs.h"
#include "fcntl.h"
#include "syscall.h"
#include "traps.h"
#include "memlayout.h"


int main(int argc, char *argv[]) {
    int i = getpid();
    printf(1,"%d\n",i);
//    return 0;
    int magic = getMagic();
    printf(1,"current magic number is the following: %d\n",magic);

   incrementMagic(3);
    magic = getMagic();
    printf(1,"current magic number is the following: %d\n",magic);
    printf(1,"current process name:");

    getCurrentProcessName();

    printf(1,"\n");

    modifyCurrentProcessName("newName");
    getCurrentProcessName();

    magic = getMagic();

    printf(1,"current magic number is the following: %d\n",magic);

    incrementMagic(3);

    magic = getMagic();
    printf(1,"current magic number is the following %d\n",magic);

    exit();
}
