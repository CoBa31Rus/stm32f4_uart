#!!!!!!!!!!!!!!!!!!USER CONFIG VARIABLES!!!!!!!!!!!!!!!!
#-------------------------------------------------------------------------------
# Prj and file name
TARGET  = template
#Used mcu line
DEFINES += STM32F407xx
MCU += -mcpu=cortex-m4 -mfloat-abi=hard -mfpu=fpv4-sp-d16 -fsingle-precision-constant
#------Toolchain path if exist
TOOLPATH = /opt/toolchain/bin/
OPENOCDPATH =
#---------------------------
#Target file for OpenOCD
OCDTFILE += interface/stlink-v2.cfg
#Interface file for OpenOCD
OCDCFILE += target/stm32f4x.cfg
#For Debug add in attach.gdb interface and target file name

#Optimization
OPT += -O0
OPT += -ggdb3

DEFINES += DEBUG
#-------------------------------------------------------------------------------

#Toolchain
#-------------------------------------------------------------------------------
AS = $(TOOLPATH)arm-none-eabi-gcc
CC = $(TOOLPATH)arm-none-eabi-gcc
LD = $(TOOLPATH)arm-none-eabi-g++
CP = $(TOOLPATH)arm-none-eabi-objcopy
SZ = $(TOOLPATH)arm-none-eabi-size
RM = rm
CXX = $(TOOLPATH)arm-none-eabi-g++
GDB = $(TOOLPATH)arm-none-eabi-gdb
OCD = $(OPENOCDPATH)openocd
#-------------------------------------------------------------------------------

#OpenOCD config
#-------------------------------------------------------------------------------
OCDCFG = -f $(OCDTFILE)
OCDCFG += -f $(OCDCFILE)
OCDCFG += -s scripts
OCDFL = --eval-command="target remote localhost:3333"
#-------------------------------------------------------------------------------

#startup file
#-------------------------------------------------------------------------------
STARTUP = startup_stm32.s
#-------------------------------------------------------------------------------

#Source path
#-------------------------------------------------------------------------------
SOURCEDIRS := src
#-------------------------------------------------------------------------------

#Header path
#-------------------------------------------------------------------------------
INCLUDES += inc
#-------------------------------------------------------------------------------

#GCC config
#-------------------------------------------------------------------------------
# -mthumb -mcpu=cortex-m4 -mfloat-abi=softfp -mfpu=fpv4-sp-d16
CFLAGS += -mthumb $(MCU)
CFLAGS += -Wall -pedantic
CFLAGS += $(OPT)
CFLAGS += -Wall -fmessage-length=0
#CFLAGS += -ffunction-sections -fdata-sections
CFLAGS += $(addprefix -I, $(INCLUDES))
CFLAGS += $(addprefix -D, $(DEFINES))
#-------------------------------------------------------------------------------


#For C only
#-------------------------------------------------------------------------------
FLAGS  = -std=gnu99
#-------------------------------------------------------------------------------
#For C++ only
#-------------------------------------------------------------------------------
CXXFL  = -std=c++14 -fno-exceptions -fno-rtti
#-------------------------------------------------------------------------------

#Linker script
#-------------------------------------------------------------------------------
LDSCRIPT   = LinkerScript.ld
#-------------------------------------------------------------------------------

#Linker config
#-------------------------------------------------------------------------------
LDFLAGS += -mfloat-abi=soft -nostdlib -fno-exceptions -fno-rtti -lm -mthumb $(MCU)
LDFLAGS += -T $(LDSCRIPT)
#-------------------------------------------------------------------------------

#ASM config
#-------------------------------------------------------------------------------
AFLAGS += -Wall -mapcs
#-------------------------------------------------------------------------------

#Obj file list
#-------------------------------------------------------------------------------
OBJS += $(patsubst %.c, %.o, $(wildcard  $(addsuffix /*.c, $(SOURCEDIRS))))
OBJS += $(patsubst %.cpp, %.o, $(wildcard  $(addsuffix /*.cpp, $(SOURCEDIRS))))
OBJS += $(patsubst %.s, %.o, $(STARTUP))
#-------------------------------------------------------------------------------

#List files for clean project
#-------------------------------------------------------------------------------
MRPROPER += openocd.log
MRPROPER += $(addsuffix /*.o, $(SOURCEDIRS))
MRPROPER += $(addsuffix /*.d, $(SOURCEDIRS))
MRPROPER += $(patsubst %.s, %.o, $(STARTUP))
TOREMOVE += *.elf *.hex *.bin
TOREMOVE += $(TARGET)
TOREMOVE += $(MRPROPER)
#-------------------------------------------------------------------------------


#Make all
#-------------------------------------------------------------------------------
all: size $(TARGET).hex $(TARGET).bin $(TARGET).elf
#-------------------------------------------------------------------------------

#Clean
#-------------------------------------------------------------------------------
clean:
	@$(RM) -rf $(TOREMOVE)
#-------------------------------------------------------------------------------

#Clean
#-------------------------------------------------------------------------------
mrproper:
	@$(RM) -rf $(MRPROPER)
#-------------------------------------------------------------------------------

#Show programm size
#-------------------------------------------------------------------------------
size: $(TARGET).elf
	@echo "---------------------------------------------------"
	@$(SZ) $(TARGET).elf
#-------------------------------------------------------------------------------

#Compile HEX file 
#-------------------------------------------------------------------------------
$(TARGET).hex: $(TARGET).elf
	@$(CP) -Oihex $(TARGET).elf $(TARGET).hex
#-------------------------------------------------------------------------------

#Compile BIN file
#-------------------------------------------------------------------------------
$(TARGET).bin: $(TARGET).elf
	@$(CP) -Obinary $(TARGET).elf $(TARGET).bin
#-------------------------------------------------------------------------------

#Linking
#-------------------------------------------------------------------------------
$(TARGET).elf: $(OBJS)
	@$(LD) $(LDFLAGS) $^ -o $@
#-------------------------------------------------------------------------------

#Compile Obj files from C
#-------------------------------------------------------------------------------
%.o: %.c
	@$(CC) $(CFLAGS) $(FLAGS) -MD -c $< -o $@
#-------------------------------------------------------------------------------

#Compile Obj files from C++
#-------------------------------------------------------------------------------
%.o: %.cpp
	@$(CXX) $(CFLAGS) $(CXXFL) -MD -c $< -o $@
#-------------------------------------------------------------------------------

#Compile Obj files from asm
#-------------------------------------------------------------------------------
%.o: %.s
	@$(AS) $(AFLAGS) -c $< -o $@
#-------------------------------------------------------------------------------

#Load firmware for STM with STLINK V2
#-------------------------------------------------------------------------------
load: $(TARGET).hex
	$(OCD) $(OCDCFG) -c "init" -c "reset init" -c "flash write_image erase $(TARGET).hex" -c "reset" -c "shutdown"
#-------------------------------------------------------------------------------

#Run debug with SWD and openocd in PIPE mode
#-------------------------------------------------------------------------------
debug: $(TARGET).elf
	$(GDB) -x run.gdb $<
nemiverdbg: $(TARGET).elf
	ext/debug_nemiver.sh
#-------------------------------------------------------------------------------
