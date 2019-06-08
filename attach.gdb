target remote | openocd -f interface/stlink-v2.cfg -f target/stm32f4x.cfg -f gdb-pipe.cfg
monitor halt
monitor gdb_sync
