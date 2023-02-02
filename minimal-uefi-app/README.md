# Minimal UEFI app.

以下の Tutorial の内容を devcontainer で完結させられるようにしたもの．
https://rust-osdev.github.io/uefi-rs/HEAD/tutorial/introduction.html

```bash
$ cargo build

$ ./run.sh
BdsDxe: failed to load Boot0001 "UEFI QEMU DVD-ROM QM00003 " from PciRoot(0x0)/Pci(0x1,0x1)/Ata(Secondary,Master,0x0): Not Found
BdsDxe: loading Boot0002 "UEFI QEMU HARDDISK QM00001 " from PciRoot(0x0)/Pci(0x1,0x1)/Ata(Primary,Master,0x0)
BdsDxe: starting Boot0002 "UEFI QEMU HARDDISK QM00001 " from PciRoot(0x0)/Pci(0x1,0x1)/Ata(Primary,Master,0x0)
[ INFO]:  src/main.rs@013: Hello world!
# qemu の終了は Ctrl + A, X
```
