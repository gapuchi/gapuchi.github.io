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

The idea - wrap certain global system resources in an abstraction layer. This allows different groups of processes to have different views of the system.

Processes within a namespace have their own isolated instance of the resources.

---

Namespaces
: (General) a space of names
: (Linux) a type of namespace (e.g. process id, mount, etc.)

---

> What is important here is that the term "namespaces" are used in different ways. When a process is "in a namespace", it is in an instance of a namespace type.

There are 7 namespace (or I'll refer to is as "namespace types" to keep terminology less confusing):

1. mnt
1. pid
1. net
1. ipc
1. uts
1. cgroup
1. user

> A process will be in a namespace of every type. (It will have a specific `mnt` ns, `pid` ns, etc.)

There were two more proposed in 2016 - time and syslog, but they have not been implemented yet.

With the introduction of user namespace in 2013, the kernel became "container ready".

### Namespace API

Before we look at the namespaces, it'll be useful to look at the namespace API. It consists of 3 system calls.

> Coming from an OO background, I assumed "namespace API" meant the API of a namespace. I assume that each namespace had a "verb" or an implementation of the below API's that could vary among the namespace types. **This is not the case**.
>
> Rather, it is an API of the kernel (?) that operates with namespaces. These are *syscall*'s.

#### 1. clone

[`clone(2)`](https://man7.org/linux/man-pages/man2/clone.2.html) creates a new child process, like [`fork(2)`](https://man7.org/linux/man-pages/man2/fork.2.html). Unlike `fork`, `clone` allows the child process to share parts of its execution context with the calling process (such as the memory space, the table of file descriptors, and table of signal handlers).

You can pass different namespace flags to `clone` to create new namespaces for the child process.

#### 2. unshare

[`unshare(2)`](https://man7.org/linux/man-pages/man2/unshare.2.html) allows a process to disassociate parts of the execution context which are currently being shared with others.

#### 3. setns

[`setns(2)`](https://man7.org/linux/man-pages/man2/setns.2.html) reassociates the calling thread with the provided namespace file descriptor.

This can be used to join an existing namespace.

#### proc

Not a syscall, but the `proc` filesystem provides additional namespace related files. Each file in `/proc/$PID/ns` is a magic link that be used as a handle for performing operations (like `setns`) to the referenced namespace.

```console
~ $ ps
    PID TTY          TIME CMD
  24900 pts/2    00:00:00 zsh
  25039 pts/2    00:00:00 ps
```

```console
~ $ ls -Gg /proc/24900/ns
total 0
lrwxrwxrwx 1 0 Feb 21 16:37 cgroup -> 'cgroup:[4026531835]'
lrwxrwxrwx 1 0 Feb 21 16:37 ipc -> 'ipc:[4026531839]'
lrwxrwxrwx 1 0 Feb 21 16:37 mnt -> 'mnt:[4026531840]'
lrwxrwxrwx 1 0 Feb 21 16:37 net -> 'net:[4026532000]'
lrwxrwxrwx 1 0 Feb 21 16:37 pid -> 'pid:[4026531836]'
lrwxrwxrwx 1 0 Feb 21 16:37 pid_for_children -> 'pid:[4026531836]'
lrwxrwxrwx 1 0 Feb 21 16:37 time -> 'time:[4026531834]'
lrwxrwxrwx 1 0 Feb 21 16:37 time_for_children -> 'time:[4026531834]'
lrwxrwxrwx 1 0 Feb 21 16:37 user -> 'user:[4026531837]'
lrwxrwxrwx 1 0 Feb 21 16:37 uts -> 'uts:[4026531838]'
```

```console
~ $ ls -Gg /proc/self/ns
total 0
lrwxrwxrwx 1 0 Feb 21 16:40 cgroup -> 'cgroup:[4026531835]'
lrwxrwxrwx 1 0 Feb 21 16:40 ipc -> 'ipc:[4026531839]'
lrwxrwxrwx 1 0 Feb 21 16:40 mnt -> 'mnt:[4026531840]'
lrwxrwxrwx 1 0 Feb 21 16:40 net -> 'net:[4026532000]'
lrwxrwxrwx 1 0 Feb 21 16:40 pid -> 'pid:[4026531836]'
lrwxrwxrwx 1 0 Feb 21 16:40 pid_for_children -> 'pid:[4026531836]'
lrwxrwxrwx 1 0 Feb 21 16:40 time -> 'time:[4026531834]'
lrwxrwxrwx 1 0 Feb 21 16:40 time_for_children -> 'time:[4026531834]'
lrwxrwxrwx 1 0 Feb 21 16:40 user -> 'user:[4026531837]'
lrwxrwxrwx 1 0 Feb 21 16:40 uts -> 'uts:[4026531838]'
```

We can actually track which namespaces a process resides in using this.

Another tool, [`util-linux`](https://github.com/karelzak/util-linux) package, contains dedicated wrapper programs for the above syscalls.

### Available Namespaces (or Namespace Types)

#### Mount (mnt)

With the `mnt` namespace, Linux is able to isolate a set of mount points by a group of processes. Another way to put this, for a group of processes, we have a specific set of mount points. This abstraction gives us the ability to create an entire virtual environment where we are the root user even without root permissions.

The flag for this namespace type is `CLONE_NEWNS` (CLONE NEW NameSpace). This was the first implemented namespace (2002) and most people didn't think more than one namespace was needed, which was why this flag is so generic.

A use case for the mnt namespace is to improve our jail (by making it more secure):

```console
~ $ sudo unshare -m
# mkdir mount-dir
# mount -n -o size=10m -t tmpfs tmpfs mount-dir
# man mount
# df mount-dir/
Filesystem      Size  Used Avail Use% Mounted on
tmpfs            10M     0   10M   0% /home/arjun/mount-dir
# touch mount-dir/{0,1,2}
# ls mount-dir/
0  1  2
```

If we try to access this on the host system:

```console
~ $ la mount-dir
total 0
~ $ grep mount-dir /proc/mounts
~ $
```

We see folder (a file) created in the first namespace, but no files under it. This is because we mounted a [tmpfs](https://en.wikipedia.org/wiki/Tmpfs) (a temporary fs) to that folder and added files to that mount. Since our host system is in another `mnt` namespace, it cannot see these files, or see this mount.

We can actually see the mount point in the `mountinfo` file inside of the `proc` filesystem:

```console
~ $ grep mount-dir /proc/$(pgrep -u root bash)/mountinfo
441 440 0:54 / /home/arjun/mount-dir rw,relatime - tmpfs tmpfs rw,size=10240k,inode64
```

> The memory being used here is in an abstraction layer called Virtual File System (VFS), which is part of the kernel. This is also where other file systems are based on. If the namespace gets destroyed, the mount memory is unrecoverably lost.

> **How to work with these mount points in the source code?** Programs tend to keep track of the `/proc/$PID/ns/mnt` file, which is referring to the used namespace.

#### UNIX Time-sharing System (uts)

With the `uts` namespace, we can unshare the domain and hostname from the current host system.

```console
~ $ hostname
arjun-b250hd3
~ $ sudo unshare -u
# hostname
arjun-b250hd3
# hostname a-cooler-hostname
# hostname
a-cooler-hostname
```

and if we look at the system:

```console
~ $ hostname
arjun-b250hd3
```

it is unchanged. This is useful for container networking related topics.

#### Interprocess Communication (ipc)

With the `ipc` namespace, we can isolate interprocess communication (IPC) resources.

These are *System V IPC objects* and *POSIX message queues*.

> Use Case - Separate the shared memory (SHM) between two processes.
>
> Each process will be able to use the same identifiers for a shared memory segment and have two different regions.

When an IPC namespace is destroyed, all IPC objects in the namespace is destroyed too.

#### Process ID (pid)

With the `pid` namespaces, processes can have independent set of process identifiers (PIDs).

Process in two different `pid` namespaces can have the same PID.

A process will have more than one PID:

1. the PID inside the namespace
1. the PID on the host system

**The `pid` namespace can be nested**, so a process will have a PID for each namespace from its current namespace up to the initial namespace.

> Does this mean the host system can still see this process? This namespace doesn't seem to isolate the process from other namespaces. Only the PID.

The first process created in a `pid` namespace gets the number 1 and gains all the same special treatment as the usual init process, like:

* All processes within a namespace will be reparented to the namespace's PID 1 instead of the host system's PID 1.
* The termination of this PID will terminate all processes in its PID namespace and any descendants.

```console
~ $ ps aux
USER         PID %CPU %MEM    VSZ   RSS TTY      STAT START   TIME COMMAND
root           1  0.0  0.0 171184 10752 ?        Ss   16:22   0:00 /sbin/init
root           2  0.0  0.0      0     0 ?        S    16:22   0:00 [kthreadd]
root           3  0.0  0.0      0     0 ?        I<   16:22   0:00 [rcu_gp]
.... //The list goes on
~ $ sudo unshare -fp --mount-proc
# ps aux
USER         PID %CPU %MEM    VSZ   RSS TTY      STAT START   TIME COMMAND
root           1  0.0  0.0   7728  4484 pts/4    S    17:27   0:00 -bash
root           6  0.0  0.0   9876  3424 pts/4    R+   17:27   0:00 ps aux
# 
```

> `--mount-proc` is needed to remount the `proc` filesystem. Why? We didn't unshare the `mnt` namespace.