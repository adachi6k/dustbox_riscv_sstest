# メモ
$ spike --rbb-port=9824 -m0x10100000:0x20000 test_exception.elf
$ openocd -f spike.cfg

$ riscv64-unknown-elf-as -o test_exception.o test_exception.S
$ riscv64-unknown-elf-ld -T spike.lds -o test_exception.elf test_exception.o

GDB
target remote :3333
