# umask

**Big picture:** the umask is a mask of bits to **take away** from new files and directories. Programs ask for a generous mode; the umask removes bits before the file is created.

Related: [Users, groups, permissions](users-groups-permissions.md) · [Cross-machine identity](cross-machine-identity.md)

## Terms

umask
: Per-process setting listing permission bits to remove from new files. Inherited by child processes.

Special bits
: setuid (4), setgid (2), sticky (1). The optional leading digit of a mode.

## How it works

- New **files** request `666` (no execute by default).
- New **directories** request `777`.
- Result = request with the umask's bits removed (bitwise, not subtraction, but subtraction works for these common cases).

| umask | New file | New dir | Effect |
|---|---|---|---|
| `0022` | 644 | 755 | common default; only you write |
| `0002` | 664 | 775 | group can write too |
| `0027` | 640 | 750 | group read-only, others nothing |
| `0077` | 600 | 700 | private |

`0002` is four octal digits: special bits, owner, group, other. The last digit, `2`, is other-write. Programs ask for `666` on a file and `777` on a directory; clearing other-write leaves `664` and `775`. The two zeros in the middle mean owner and group lose nothing.

## Why 0002 suits shared groups

With a shared group like `media`, `0002` makes everything you create group-writable, so teammates can edit it. Combine with a setgid directory (`2775`) so the group is always `media`.

## Try it

```bash
umask          # show current, e.g. 0022
umask 0002     # set for this shell
touch f; mkdir d; ls -ld f d
```

> **Exercise:** with umask `0027`, what do new files and directories get?
>
> **Answer:** files `666 − 027` → **640** (`rw-r-----`); dirs `777 − 027` → **750** (`rwxr-x---`).

Make it permanent in `~/.profile`/`~/.bashrc`, or system-wide via `/etc/login.defs` or PAM (`pam_umask`).

## Key takeaways

- umask removes bits; it never adds them.
- Files start from 666, dirs from 777.
- 0022 → 644/755; 0002 → 664/775.

## Gotchas

- Strictly bitwise: umask `0033` on a file gives `644`, not `633`.
- Services (systemd units, Samba, NFS daemons) have their own umask settings; your shell's doesn't apply.
- `cp`/`tar`/`rsync -p` may preserve source modes instead of applying umask.
