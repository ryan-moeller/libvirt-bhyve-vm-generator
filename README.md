Usage
=====

Create ZFS filesystems and volumes and define the libvirt domain for the
configuration defined in `freebsd.rkt`:

```
$ virsh define <(sudo racket freebsd.rkt)
```
