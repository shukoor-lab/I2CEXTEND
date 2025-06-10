TOOLCHAIN_PREFIX := ../../MRS_Toolchain_Linux_x64_V210/RISC-V_Embedded_GCC12/bin/riscv-wch-elf

SDK_PATH := ../../sdk

APP_C_SRCS += \
  ./main/main.c \

SDK_STDPERIPHDRIVER_C_SRCS += \
  $(SDK_PATH)/StdPeriphDriver/CH57x_clk.c \
  $(SDK_PATH)/StdPeriphDriver/CH57x_flash.c \
  $(SDK_PATH)/StdPeriphDriver/CH57x_gpio.c \
  $(SDK_PATH)/StdPeriphDriver/CH57x_pwm.c \
  $(SDK_PATH)/StdPeriphDriver/CH57x_sys.c \
  $(SDK_PATH)/StdPeriphDriver/CH57x_timer.c \
  $(SDK_PATH)/StdPeriphDriver/CH57x_uart.c \
  $(SDK_PATH)/StdPeriphDriver/CH57x_usbdev.c \
  

SDK_RVMSIS_C_SRCS += \
  $(SDK_PATH)/RVMSIS/core_riscv.c


SDK_BLE_LIB_S_UPPER_SRCS += \
#   $(SDK_PATH)/BLE/LIB/ble_task_scheduler.S

SDK_STARTUP_S_UPPER_SRCS += \
  $(SDK_PATH)/Startup/startup_CH572.S

C_SRCS := \
  $(APP_C_SRCS) \
  $(SDK_STDPERIPHDRIVER_C_SRCS) \
  $(SDK_RVMSIS_C_SRCS)

S_UPPER_SRCS := \
  $(SDK_BLE_LIB_S_UPPER_SRCS) \
  $(SDK_STARTUP_S_UPPER_SRCS)

OBJS := \
  $(patsubst ./main/%.c,obj/main/%.o,$(APP_C_SRCS)) \
  $(patsubst $(SDK_PATH)/%.c,obj/sdk/%.o,$(SDK_STDPERIPHDRIVER_C_SRCS)) \
  $(patsubst $(SDK_PATH)/%.c,obj/sdk/%.o,$(SDK_RVMSIS_C_SRCS)) \
  $(patsubst $(SDK_PATH)/%.S,obj/sdk/%.o,$(SDK_STARTUP_S_UPPER_SRCS))

MAKEFILE_DEPS := \
  $(foreach obj,$(OBJS),$(patsubst %.o,%.d,$(obj)))

STDPERIPHDRIVER_LIBS := -L"$(SDK_PATH)/StdPeriphDriver" -lISP592
LIBS := $(STDPERIPHDRIVER_LIBS) $(BLE_LIB_LIBS)

SECONDARY_FLASH := main.hex
SECONDARY_LIST := main.lst
SECONDARY_SIZE := main.siz

# ARCH is rv32imac on older gcc, rv32imac_zicsr on newer gcc
ARCH := rv32imac
# ARCH := rv32imac_zicsr

CFLAGS_COMMON := \
  -march=$(ARCH) \
  -mabi=ilp32 \
  -mcmodel=medany \
  -msmall-data-limit=8 \
  -mno-save-restore \
  -Os \
  -fmessage-length=0 \
  -fsigned-char \
  -ffunction-sections \
  -fdata-sections
  #-g

CONFIG_BUILD_VARS := \
	-DVERSION=\"$(VERSION)\"\
	-DPRODUCT=$(PRODUCT)\
	# -DDEBUG=1 \

.PHONY: all
all: main.elf secondary-outputs

.PHONY: clean
clean:
	-rm -f $(OBJS)
	-rm -f $(MAKEFILE_DEPS)
	-rm -f $(SECONDARY_FLASH)
	-rm -f $(SECONDARY_LIST)
	-rm -f main.elf
	-rm -f main.map
	-rm -rf ./obj

.PHONY: secondary-outputs
secondary-outputs: $(SECONDARY_FLASH) $(SECONDARY_LIST) $(SECONDARY_SIZE)

main.elf: $(OBJS)
	${TOOLCHAIN_PREFIX}-gcc \
	    $(CFLAGS_COMMON) \
		$(CONFIG_BUILD_VARS) \
	    -T "$(SDK_PATH)/Ld/Link.ld" \
	    -nostartfiles \
	    -Xlinker \
	    --gc-sections \
	    -Xlinker \
	    --print-memory-usage \
	    -Wl,-Map,"main.map" \
	    -Lobj \
	    --specs=nano.specs \
	    --specs=nosys.specs \
	    -o "main.elf" \
	    $(OBJS) \
	    $(LIBS)

%.hex: %.elf
	@ ${TOOLCHAIN_PREFIX}-objcopy -O ihex "$<"  "$@"

%.lst: %.elf
	@ ${TOOLCHAIN_PREFIX}-objdump \
	    --source \
	    --all-headers \
	    --demangle \
	    --line-numbers \
	    --wide "$<" > "$@"

%.siz: %.elf
	@ ${TOOLCHAIN_PREFIX}-size --format=berkeley "$<"

obj/main/%.o: ./src/%.c
	@ mkdir --parents $(dir $@)
	@ ${TOOLCHAIN_PREFIX}-gcc \
	    $(CFLAGS_COMMON) \
		$(CONFIG_BUILD_VARS) \
	    -I"$(SDK_PATH)/StdPeriphDriver/inc" \
	    -I"$(SDK_PATH)/RVMSIS" \
	    -std=gnu99 \
	    -MMD \
	    -MP \
	    -MF"$(@:%.o=%.d)" \
	    -MT"$(@)" \
	    -c \
	    -o "$@" "$<"

obj/sdk/%.o: $(SDK_PATH)/%.c
	@ mkdir --parents $(dir $@)
	@ ${TOOLCHAIN_PREFIX}-gcc \
	    $(CFLAGS_COMMON) \
	    $(CONFIG_BUILD_VARS) \
	    -I"$(SDK_PATH)/StdPeriphDriver/inc" \
	    -I"$(SDK_PATH)/RVMSIS" \
	    -std=gnu99 \
	    -MMD \
	    -MP \
	    -MF"$(@:%.o=%.d)" \
	    -MT"$(@)" \
	    -c \
	    -o "$@" "$<"

obj/sdk/%.o: $(SDK_PATH)/%.S
	@ mkdir --parents $(dir $@)
	@ ${TOOLCHAIN_PREFIX}-gcc \
	    $(CFLAGS_COMMON) \
		$(CONFIG_BUILD_VARS) \
	    -x assembler \
	    -MMD \
	    -MP \
	    -MF"$(@:%.o=%.d)" \
	    -MT"$(@)" \
	    -c \
	    -o "$@" "$<"

build: clean all

f: clean all  
	wchisp flash ./main.elf

flash:
	wchisp flash ./main.elf

