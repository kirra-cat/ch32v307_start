# Makefile for CH32V307VCT6

###############################################################################
# Projects name
###############################################################################
TARGET = empty_project

###############################################################################
# OS, Toolcjain paths
###############################################################################

ifeq ($(OS), Windows_NT)
	# Number Logical Processors
	CPU_THREADS := $(shell powershell "wmic cpu get NumberOfLogicalProcessors | findstr /r [0-9]")

	# RISC-V Toolchain
	GNU_TOOLCHAIN = C:/RISC-V/CH32/RISC-V Embedded GCC15/bin
	GNU_TOOLCHAIN_GCC_PATH = $(GNU_TOOLCHAIN)/riscv32-wch-elf-gcc.exe
	GNU_TOOLCHAIN_GDB_PATH = $(GNU_TOOLCHAIN)/riscv32-wch-elf-gdb.exe
	GNU_TOOLCHAIN_SIZE_PATH = $(GNU_TOOLCHAIN)/riscv32-wch-elf-size.exe

	# OpenOCD (for RISC-V from MounRiver Studio)
	OPENOCD_PATH = C:/RISC-V/CH32/OpenOCD
	OPENOCD_PATH_BIN = $(OPENOCD_PATH)/bin/openocd.exe

	# Config files for OpenOCD
	OPENOCD_INTERFACE_PATH = $(OPENOCD_PATH)/share/openocd/scripts/interface/wch-riscv.cfg
	OPENOCD_TARGET_PATH = 

	#Python
	PYTHON = python
else
	CPU_THREADS := $(shell nproc 2>/dev/null || echo 4)

	GNU_TOOLCHAIN = 
	GNU_TOOLCHAIN_GCC_PATH = 
	GNU_TOOLCHAIN_GDB_PATH = 
	GNU_TOOLCHAIN_SIZE_PATH = 
	OPENOCD_PATH = 
	OPENOCD_PATH_BIN = 
	OPENOCD_INTERFACE_PATH = 
	OPENOCD_TARGET_PATH = 

	PYTHON = python3
endif

###############################################################################
# Microcontroller settings
###############################################################################
TARGET_MICROCONTROLLER = ch32v307

ifeq ($(TARGET_MICROCONTROLLER), ch32v307)
	CPU = -march=rv32imac
	INT_ABI = -mabi=ilp32
	FPU =
	FLOAT_ABI =
	SMALL_DATA_LIMIT = -msmall-data-limit=8 
	SMALL_PROLOGUE_EPILOGUE = -msave-restore 
	TUNE = -mtune=size 

	MCU = $(CPU) $(INT_ABI) $(FPU) $(FLOAT_ABI) $(SMALL_DATA_LIMIT) $(SMALL_PROLOGUE_EPILOGUE) $(TUNE)
endif

###############################################################################
# Microcontroller compiler (C_FLAGS) (ASM_FLAGS)
###############################################################################
# Defines

LANG_STD = -std=gnu11

# GNU C
C_DEFS =

# Assembly
ASM_DEFS = 

# Debug level(None " ", Minimal "-g1", Default "-g", Maximum "-g3" )
DEBUG = -g3

#(None "-O0", Optimize for Debug "-Og", Optimize "-O1", Optimize more "-O2",
# Optimize most "-O3", Optimize for size "-Os", Optimize for speed "-Ofast")
OPT = -Os

# compile gcc flags
ifeq ($(TARGET_MICROCONTROLLER), ch32v307)
	ASM_FLAGS_BASE = $(MCU) $(DEBUG) $(OPT) $(addprefix -, $(ASM_DEFS)) $(ASM_INCLUDES) -fmessage-length=0 -ffunction-sections -fdata-sections -fno-common
	C_FLAGS_BASE = $(MCU) $(DEBUG) $(OPT) $(LANG_STD) $(addprefix -D, $(C_DEFS)) $(addprefix -I, $(C_INCLUDES)) -fmessage-length=0 -fsigned-char -ffunction-sections -fdata-sections -fno-common -Wunused -Wuninitialized
endif

# Generate dependency information
C_FLAGS += $(C_FLAGS_BASE) -MMD -MP -MF"$(@:%.o=%.d)"
ASM_FLAGS += $(ASM_FLAGS_BASE) -MMD -MP -MF"$(@:%.o=%.d)" -MT"$@"

###############################################################################
# Projects path
###############################################################################

# SVD file
ifeq ($(TARGET_MICROCONTROLLER), ch32v307)
	SVD_FILE_PATH = device/ch32v307/svd/CH32V307xx.svd
endif

###############################################################################
# Build path
###############################################################################
BUILD_PATH = build

###############################################################################
# C Source location
###############################################################################
ifeq ($(TARGET_MICROCONTROLLER), ch32v307)
	C_SOURCES = \
		device/ch32v307/core/core_riscv.c \
		device/ch32v307/peripheral/src/ch32v30x_adc.c \
		device/ch32v307/peripheral/src/ch32v30x_bkp.c \
		device/ch32v307/peripheral/src/ch32v30x_can.c \
		device/ch32v307/peripheral/src/ch32v30x_crc.c \
		device/ch32v307/peripheral/src/ch32v30x_dac.c \
		device/ch32v307/peripheral/src/ch32v30x_dbgmcu.c \
		device/ch32v307/peripheral/src/ch32v30x_dma.c \
		device/ch32v307/peripheral/src/ch32v30x_dvp.c \
		device/ch32v307/peripheral/src/ch32v30x_eth.c \
		device/ch32v307/peripheral/src/ch32v30x_exti.c \
		device/ch32v307/peripheral/src/ch32v30x_flash.c \
		device/ch32v307/peripheral/src/ch32v30x_fsmc.c \
		device/ch32v307/peripheral/src/ch32v30x_gpio.c \
		device/ch32v307/peripheral/src/ch32v30x_i2c.c \
		device/ch32v307/peripheral/src/ch32v30x_iwdg.c \
		device/ch32v307/peripheral/src/ch32v30x_misc.c \
		device/ch32v307/peripheral/src/ch32v30x_opa.c \
		device/ch32v307/peripheral/src/ch32v30x_pwr.c \
		device/ch32v307/peripheral/src/ch32v30x_rcc.c \
		device/ch32v307/peripheral/src/ch32v30x_rng.c \
		device/ch32v307/peripheral/src/ch32v30x_rtc.c \
		device/ch32v307/peripheral/src/ch32v30x_sdio.c \
		device/ch32v307/peripheral/src/ch32v30x_spi.c \
		device/ch32v307/peripheral/src/ch32v30x_tim.c \
		device/ch32v307/peripheral/src/ch32v30x_usart.c \
		device/ch32v307/peripheral/src/ch32v30x_wwdg.c \
		source/main.c \
		source/low_level/ch32v307/ch32v30x_it.c \
		source/low_level/ch32v307/system_ch32v30x.c \
		source/low_level/ch32v307/debug/debug.c
endif

###############################################################################
# Assembly source location
###############################################################################
ifeq ($(TARGET_MICROCONTROLLER), ch32v307)
	ASM_SOURCES = \
		device/ch32v307/startup/startup_ch32v30x_D8C.s
endif

###############################################################################
# C include location
###############################################################################
ifeq ($(TARGET_MICROCONTROLLER), ch32v307)
	C_INCLUDES = \
		device/ch32v307/core/ \
		device/ch32v307/peripheral/inc/ \
		source/low_level/ch32v307/ \
		source/low_level/ch32v307/debug/
endif

###############################################################################
# Assembly include location
###############################################################################
ifeq ($(TARGET_MICROCONTROLLER), ch32v307)
	ASM_INCLUDES = 
endif

###############################################################################
# Binaries
###############################################################################
PREFIX = riscv32-wch-elf-

ifdef GNU_TOOLCHAIN
	CC = "$(GNU_TOOLCHAIN)/$(PREFIX)gcc"
	AS = "$(GNU_TOOLCHAIN)/$(PREFIX)gcc" -x assembler-with-cpp
	CP = "$(GNU_TOOLCHAIN)/$(PREFIX)objcopy"
	SZ = "$(GNU_TOOLCHAIN)/$(PREFIX)size"
	OBJDUMP = "$(GNU_TOOLCHAIN)/$(PREFIX)objdump"
else
	CC = $(PREFIX)gcc
	AS = $(PREFIX)gcc -x assembler-with-cpp
	CP = $(PREFIX)objcopy
	SZ = $(PREFIX)size
	OBJDUMP = $(PREFIX)objdump
endif

HEX = $(CP) -O ihex
BIN = $(CP) -O binary -S

###############################################################################
# Linker script location
###############################################################################
ifeq ($(TARGET_MICROCONTROLLER), ch32v307)
	LDSCRIPT = \
		device/ch32v307/linker/Link.ld
endif

# libraries
LIBS = -Wl,--start-group -lc -lm -Wl,--end-group
LIBDIR = 
LDFLAGS = $(MCU) -T$(LDSCRIPT) $(LIBDIR) $(LIBS) -nostartfiles -Xlinker --gc-sections -Wl,-Map=$(BUILD_PATH)/$(TARGET).map --specs=nano.specs --specs=nosys.specs -Wl,--print-memory-usage -lprintf

# default action: build all
all: $(BUILD_PATH)/$(TARGET).elf $(BUILD_PATH)/$(TARGET).hex $(BUILD_PATH)/$(TARGET).bin

###############################################################################
# Disassemble the ELF file
###############################################################################

CROSS_CREATE_LISTING = --all-headers --demangle --disassemble -M xw

disassemble: $(BUILD_PATH)/$(TARGET).elf
	$(OBJDUMP) $(CROSS_CREATE_LISTING) $< > $(BUILD_PATH)/$(TARGET).disasm

###############################################################################
# build app
###############################################################################
# list of objects
OBJECTS = $(addprefix $(BUILD_PATH)/,$(notdir $(C_SOURCES:.c=.o)))
vpath %.c $(sort $(dir $(C_SOURCES)))
# list of ASM program objects
OBJECTS += $(addprefix $(BUILD_PATH)/,$(notdir $(ASM_SOURCES:.s=.o)))
vpath %.s $(sort $(dir $(ASM_SOURCES)))

$(BUILD_PATH)/%.o: %.c Makefile | $(BUILD_PATH) 
	$(CC) -c $(C_FLAGS) -Wa,-a,-ad,-alms=$(BUILD_PATH)/$(notdir $(<:.c=.lst)) $< -o $@

$(BUILD_PATH)/%.o: %.s Makefile | $(BUILD_PATH)
	$(AS) -c $(ASM_FLAGS) $< -o $@

$(BUILD_PATH)/$(TARGET).elf: $(OBJECTS) Makefile
	$(CC) $(OBJECTS) $(LDFLAGS) -o $@
	$(SZ) $@

$(BUILD_PATH)/%.hex: $(BUILD_PATH)/%.elf | $(BUILD_PATH)
	$(HEX) $< $@
	
$(BUILD_PATH)/%.bin: $(BUILD_PATH)/%.elf | $(BUILD_PATH)
	$(BIN) $< $@	
	
$(BUILD_PATH):
	mkdir $@

###############################################################################
# clean
###############################################################################

clean:
ifeq ($(OS), Windows_NT)
	powershell -Command "if (Test-Path '$(BUILD_PATH)') { Remove-Item -Path '$(BUILD_PATH)' -Recurse -Force }"
else
	rm -rf $(BUILD_PATH)
endif

###############################################################################
# update VSCode JSON configuration files
###############################################################################
update-json:
	$(PYTHON) .vscode/scripts/update_json_config.py \
		--target '$(TARGET)' \
		--build-dir '$(BUILD_PATH)' \
		--includes '$(C_INCLUDES)' \
		--defs '$(C_DEFS)' \
		--gcc-path '$(GNU_TOOLCHAIN_GCC_PATH)' \
		--cflags '$(C_FLAGS_BASE)' \
		--gdb-path '$(GNU_TOOLCHAIN_GDB_PATH)' \
		--openocd-bin '$(OPENOCD_PATH_BIN)' \
		--openocd-interface '$(OPENOCD_INTERFACE_PATH)' \
		--openocd-target '$(OPENOCD_TARGET_PATH)' \
		--svd-file '$(SVD_FILE_PATH)' \
		--size-path '$(GNU_TOOLCHAIN_SIZE_PATH)' \
		--processor-count $(CPU_THREADS)

###############################################################################
# OpenOCD actions
###############################################################################

flash: all
	$(OPENOCD_PATH_BIN) -f $(OPENOCD_INTERFACE_PATH) -c "program $(BUILD_PATH)/$(TARGET).elf verify reset exit"

erase: 
	$(OPENOCD_PATH_BIN) -f $(OPENOCD_INTERFACE_PATH) -c "init; reset halt; flash erase_sector 0 0 last; reset; exit"

resume:
	$(OPENOCD_PATH_BIN) -f $(OPENOCD_INTERFACE_PATH) -c "init; reset halt; resume; exit"

###############################################################################
# help
###############################################################################
help:
	@echo "Available targets: all, clean, update-json, flash, erase, resume, disassemble"

###############################################################################
# dependencies
###############################################################################
-include $(wildcard $(BUILD_PATH)/*.d)

# *** EOF ***