# UID and GID Ranges

**Big picture:** UIDs are just numbers, and each OS picks its own ranges for system accounts and humans. Two machines only "agree" on who a number is by convention or luck.

Related: [Users, groups, permissions](users-groups-permissions.md) · [Cross-machine identity](cross-machine-identity.md)

## Terms

UID_MIN
: Setting in `/etc/login.defs`; the first UID `useradd` gives to a regular user.

System account
: A non-human account a service runs as, like `www-data` or `sshd`.

## Typical Linux ranges

| Range | Who |
|---|---|
| `0` | root |
| `1–999` | system/service accounts (old RHEL: `1–499`) |
| `1000+` | humans (old RHEL: from `500`) |
| `65534` | `nobody`, used by NFS squashing |

```bash
grep -E '^(UID|GID)_MIN' /etc/login.defs
getent passwd 1000
```

## Other systems

| OS | First human UID |
|---|---|
| Most Linux (Debian, Ubuntu, Fedora, RHEL 7+, Arch) | 1000 |
| Old Red Hat | 500 |
| macOS | 501 (then 502…) |
| FreeBSD and other BSDs | 1001 |

## Why Mac and Linux collide (or don't)

Two Linux boxes each give their first user 1000, so IDs match by luck. A Mac's first user is 501, which no Linux box has by default, so files from a Mac show up as a bare `501`.

## Key takeaways

- There's no universal standard; 1000 is the Linux norm, 501 is macOS.
- Below 1000 is usually reserved for services.
- 65534 means "nobody."

## Gotchas

- A mystery `500` often comes from an old RHEL machine.
- If you later create a user who happens to get a stray UID, they instantly own every file with that number.
