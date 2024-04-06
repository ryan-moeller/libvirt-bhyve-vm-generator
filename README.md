Usage
=====

ZFS datasets used by these scripts are defined in `private/vm-utils.rkt`.

The `*.rkt` files in the root of the repo are miscellaneous VM templates.

Running a template script creates a ZFS dataset for the VM under
`bhyve-dataset` with a userprop `com.freqlabs:libvirt-nmdm` storing a
`nmdm(4)` character device number for this VM.  Under the VM dataset,
any zvols defined for the VM are created with the configured size.
The XML definition of the domain is output on stdout.

Create ZFS filesystems and volumes and define the libvirt domain for the
configuration defined in `freebsd.rkt` using a shell that supports process
substitution, such as zsh:

```
$ virsh define <(sudo racket freebsd.rkt)
```
