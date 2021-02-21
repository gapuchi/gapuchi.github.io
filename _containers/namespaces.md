---
layout: post
title: Namespaces
---

My notes from [this Medium article](https://medium.com/@saschagrunert/demystifying-containers-part-i-kernel-space-2c53d6979504).

Containers are:

1. isolated
1. groups of processes
1. running on a single host
1. which fulfill a set of common features.

## Chroot

Most Unix operating systems have the ability to change the root directory of the current process (and its children). This is available as the syscall [`chroot(2)`](https://man7.org/linux/man-pages/man2/chroot.2.html). It is also known as **jail**.

> **What is the significance of changing the root?**
>
> It (kinda) changes the environment. The root contains all the binaries/libraries that processes can use. When you kick off a shell, one of the processes that gets kicked off is `bash`. The process looks for this in `/bin/bash`.

It was used in the first approaches of running microservices. It is currently used by a wide range of applications, including within build systems for different distributions.

How can we set up a chroot environment? With little effort:

```console
~ $ mkdir -p new-root/{bin,lib64}
~ $ cp /bin/bash new-root/bin
~ $ cp /lib64/{ld-linux-x86-64.so*,libc.so*,libdl.so.*,libreadline.so*,libtinfo.so*} new-root/lib64
// This isn't working on my system because a dependency is missing
~ $ sudo chroot new-root
```

This creates a new folder, copies the bash shell and its dependencies to this folder, and sets this new folder as the root. This jail only has bash capabilities (and everything that comes with bash, e.g. `cd`, `pwd`, etc.). Not really a useful jail, but a working example.

> Could we run a binary in this jail and call it a container? **No.**

### Why can't we create containers with `chroot`?

Let's take a look at the 4 attributes of containers:

1. isolated? **It actually isn't isolated.** We will expand on this below.
1. groups of processes? **Yes.** In linux, processes live in a tree structure, so this means having a root process. A root process can then kick off child processes, giving us a group of processes.
1. running on a single host? **Yes.**
1. which fulfill a set of common features. **Yes.\*** This is kinda vague, but we can set up a chroot environment with proper functionalities to support a set of common features.

Let's take a look at the "isolation" a jail provides.

**The current working directory is unchanged** when calling `chroot(2)` via a syscall. Although your absolute paths are different now, relative paths can still refer to files outside of the new root.

Only priviledged processes with the `CAP_SYS_CHROOT` capability are able to call `chroot`.

Calls to `chroot` do not stack. It will override the current jail. So a root user could escape jail with a program like:

```c
#include <sys/stat.h>
#include <unistd.h>

int main(void)
{
    mkdir(".out", 0755);                        //Create a new folder
    chroot(".out");                             //Make it the new root, removing the old jail
    chdir("../../../../../");                   //Changed the working directory to a location outside of the jail
    chroot(".");                                //Made it the new root
    return execl("/bin/bash", "-i", NULL);
}
```

> Did we need to create a new jail before changing the working directory outside of the jail? Could we not have used the current jail?

So, **`chroot` doesn't give isolation of the file system.**

We can sneak peak outside of a jail from a process perspective:

```console
~ $ mkdir /proc
~ $ mount -t proc proc /proc
~ $ ps aux
...
```

There is no process isolation at all. We can even kill processes outside of the jail.

We can sneak peak out of a jail from a network perspective:

```console
~ $ mkdir /sys
~ $ mount -t sysfs sys /sys
~ $ ls /sys/class/net
eth0 lo
```

There is no network isolation either.

This lack of isolation is a security risk - and doesn't meet the criteria for a container to be isolated.

How do we address this? Using **Linux namespaces**.

## Linux Namespaces

The idea - wrap certain global system resources.