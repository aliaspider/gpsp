DEBUG=0
HAVE_GRIFFIN=0
FRONTEND_SUPPORTS_RGB565=1

ifneq ($(EMSCRIPTEN),)
	platform = emscripten
endif

ifeq ($(platform),)
	platform = unix
	ifeq ($(shell uname -a),)
		platform = win
	else ifneq ($(findstring MINGW,$(shell uname -a)),)
		platform = win
	else ifneq ($(findstring Darwin,$(shell uname -a)),)
		platform = osx
		arch = intel
	ifeq ($(shell uname -p),powerpc)
		arch = ppc
	endif
	else ifneq ($(findstring win,$(shell uname -a)),)
		platform = win
	endif
endif

# system platform
system_platform = unix
ifeq ($(shell uname -a),)
	EXE_EXT = .exe
	system_platform = win
else ifneq ($(findstring Darwin,$(shell uname -a)),)
	system_platform = osx
	arch = intel
	ifeq ($(shell uname -p),powerpc)
		arch = ppc
	endif
	else ifneq ($(findstring MINGW,$(shell uname -a)),)
	system_platform = win
endif

TARGET_NAME	:= gpsp
LIBM		= -lm
CORE_DIR := .

# Unix
ifeq ($(platform), unix)
	TARGET := $(TARGET_NAME)_libretro.so
	fpic := -fPIC
	FORCE_32BIT := -m32
	CPU_ARCH := x86_32
	SHARED := -shared $(FORCE_32BIT) -Wl,--version-script=link.T
	ifneq ($(findstring Haiku,$(shell uname -a)),)
		LIBM :=
	endif
	CFLAGS += $(FORCE_32BIT) -DHAVE_MMAP
# OS X
else ifeq ($(platform), osx)
	TARGET := $(TARGET_NAME)_libretro.dylib
	fpic := -fPIC
	ifeq ($(arch),ppc)
		CFLAGS += -DBLARGG_BIG_ENDIAN=1 -D__ppc__
	endif
	OSXVER = `sw_vers -productVersion | cut -d. -f 2`
	OSX_LT_MAVERICKS = `(( $(OSXVER) <= 9)) && echo "YES"`
	ifeq ($(OSX_LT_MAVERICKS),"YES")
		fpic += -mmacosx-version-min=10.5
	endif
	SHARED := -dynamiclib
	CFLAGS += -DHAVE_MMAP

# iOS
else ifeq ($(platform), ios)
	TARGET := $(TARGET_NAME)_libretro_ios.dylib
	fpic := -fPIC
	SHARED := -dynamiclib
	CPU_ARCH := arm

	ifeq ($(IOSSDK),)
		IOSSDK := $(shell xcrun -sdk iphoneos -show-sdk-path)
	endif

	CC = clang -arch armv7 -isysroot $(IOSSDK)
	CFLAGS += -DIOS -DHAVE_MMAP
	OSXVER = `sw_vers -productVersion | cut -d. -f 2`
	OSX_LT_MAVERICKS = `(( $(OSXVER) <= 9)) && echo "YES"`
	ifeq ($(OSX_LT_MAVERICKS),"YES")
		CC += -miphoneos-version-min=5.0
		CFLAGS += -miphoneos-version-min=5.0
	endif

# QNX
else ifeq ($(platform), qnx)
	TARGET := $(TARGET_NAME)_libretro_qnx.so
	fpic := -fPIC
	SHARED := -shared -Wl,--version-script=link.T
	CFLAGS += -DHAVE_MMAP

	CC = qcc -Vgcc_ntoarmv7le
	AR = qcc -Vgcc_ntoarmv7le
	CFLAGS += -D__BLACKBERRY_QNX__

# PS3
else ifeq ($(platform), ps3)
	TARGET := $(TARGET_NAME)_libretro_ps3.a
	CC = $(CELL_SDK)/host-win32/ppu/bin/ppu-lv2-gcc.exe
	AR = $(CELL_SDK)/host-win32/ppu/bin/ppu-lv2-ar.exe
	CFLAGS += -DBLARGG_BIG_ENDIAN=1 -D__ppc__
	STATIC_LINKING = 1

# sncps3
else ifeq ($(platform), sncps3)
	TARGET := $(TARGET_NAME)_libretro_ps3.a
	CC = $(CELL_SDK)/host-win32/sn/bin/ps3ppusnc.exe
	AR = $(CELL_SDK)/host-win32/sn/bin/ps3snarl.exe
	CFLAGS += -DBLARGG_BIG_ENDIAN=1 -D__ppc__
	STATIC_LINKING = 1

# Lightweight PS3 Homebrew SDK
else ifeq ($(platform), psl1ght)
	TARGET := $(TARGET_NAME)_libretro_psl1ght.a
	CC = $(PS3DEV)/ppu/bin/ppu-gcc$(EXE_EXT)
	AR = $(PS3DEV)/ppu/bin/ppu-ar$(EXE_EXT)
	CFLAGS += -DBLARGG_BIG_ENDIAN=1 -D__ppc__
	STATIC_LINKING = 1

# PSP
else ifeq ($(platform), psp1)
	TARGET := $(TARGET_NAME)_libretro_psp1.a
	CC = psp-gcc$(EXE_EXT)
	AR = psp-ar$(EXE_EXT)
	CFLAGS += -DPSP -G0
	STATIC_LINKING = 1

# Xbox 360
else ifeq ($(platform), xenon)
	TARGET := $(TARGET_NAME)_libretro_xenon360.a
	CC = xenon-gcc$(EXE_EXT)
	AR = xenon-ar$(EXE_EXT)
	CFLAGS += -D__LIBXENON__ -m32 -D__ppc__
	STATIC_LINKING = 1

# Nintendo Game Cube
else ifeq ($(platform), ngc)
	TARGET := $(TARGET_NAME)_libretro_ngc.a
	CC = $(DEVKITPPC)/bin/powerpc-eabi-gcc$(EXE_EXT)
	AR = $(DEVKITPPC)/bin/powerpc-eabi-ar$(EXE_EXT)
	CFLAGS += -DGEKKO -DHW_DOL -mrvl -mcpu=750 -meabi -mhard-float -DBLARGG_BIG_ENDIAN=1 -D__ppc__
	STATIC_LINKING = 1

# Nintendo Wii
else ifeq ($(platform), wii)
	TARGET := $(TARGET_NAME)_libretro_wii.a
	CC = $(DEVKITPPC)/bin/powerpc-eabi-gcc$(EXE_EXT)
	AR = $(DEVKITPPC)/bin/powerpc-eabi-ar$(EXE_EXT)
	CFLAGS += -DGEKKO -DHW_RVL -mrvl -mcpu=750 -meabi -mhard-float -DBLARGG_BIG_ENDIAN=1 -D__ppc__
	STATIC_LINKING = 1

# ARM
else ifneq (,$(findstring armv,$(platform)))
	TARGET := $(TARGET_NAME)_libretro.so
	SHARED := -shared -Wl,--no-undefined
	fpic := -fPIC
	CC = gcc
	ifneq (,$(findstring cortexa8,$(platform)))
		CFLAGS += -marm -mcpu=cortex-a8
		ASFLAGS += -mcpu=cortex-a8
	else ifneq (,$(findstring cortexa9,$(platform)))
		CFLAGS += -marm -mcpu=cortex-a9
		ASFLAGS += -mcpu=cortex-a9
	endif
	CFLAGS += -marm
	ifneq (,$(findstring neon,$(platform)))
		CFLAGS += -mfpu=neon
		ASFLAGS += -mfpu=neon
		HAVE_NEON = 1
	endif
	ifneq (,$(findstring softfloat,$(platform)))
		CFLAGS += -mfloat-abi=softfp
		ASFLAGS += -mfloat-abi=softfp
	else ifneq (,$(findstring hardfloat,$(platform)))
		CFLAGS += -mfloat-abi=hard
		ASFLAGS += -mfloat-abi=hard
	endif
	CFLAGS += -DARM
	CFLAGS += -DHAVE_MMAP

# emscripten
else ifeq ($(platform), emscripten)
	TARGET := $(TARGET_NAME)_libretro_emscripten.bc

# Windows
else
	TARGET := $(TARGET_NAME)_libretro.dll
	CC = gcc
	SHARED := -shared -static-libgcc -static-libstdc++ -s -Wl,--version-script=link.T
	CFLAGS += -D__WIN32__ -D__WIN32_LIBRETRO__
#	CFLAGS += -DHAVE_MMAP
endif

# Forcibly disable PIC
#fpic :=

ifeq ($(DEBUG), 1)
	OPTIMIZE_SAFE := -O0 -g
	OPTIMIZE      := -O0 -g
else
	OPTIMIZE_SAFE := -O2 -DNDEBUG
	OPTIMIZE      := -O3 -DNDEBUG
endif


include Makefile.common

OBJECTS := $(SOURCES_C:.c=.o) $(SOURCES_ASM:.S=.o)

DEFINES = -DHAVE_STRINGS_H -DHAVE_STDINT_H -DHAVE_INTTYPES_H -D__LIBRETRO__ -DINLINE=inline -DPC_BUILD -Wall -Werror=implicit-function-declaration -Wnarrowing -Wint-to-pointer-cast -Wpointer-to-int-cast

ifeq ($(CPU_ARCH), arm)
DEFINES += -DARM_ARCH
endif

WARNINGS_DEFINES =
CODE_DEFINES =

COMMON_DEFINES += $(CODE_DEFINES) $(WARNINGS_DEFINES) -DNDEBUG=1 $(fpic)

CFLAGS += $(DEFINES) $(COMMON_DEFINES)

ifeq ($(FRONTEND_SUPPORTS_RGB565), 1)
	CFLAGS += -DFRONTEND_SUPPORTS_RGB565
endif

all: $(TARGET)

$(TARGET): $(OBJECTS)
ifeq ($(STATIC_LINKING), 1)
	$(AR) rcs $@ $(OBJECTS)
else
	$(CC) $(fpic) $(SHARED) $(INCFLAGS) $(OPTIMIZE) -o $@ $(OBJECTS) $(LIBM) -Wl,--no-undefined
endif

cpu.o: cpu.c
	$(CC) $(CFLAGS) -Wno-unused-variable -Wno-unused-label $(OPTIMIZE_SAFE) $(INCDIRS) -c -o $@ $<

cpu_threaded.o: cpu_threaded.c
	$(CC) $(CFLAGS) -Wno-unused-variable -Wno-unused-label $(OPTIMIZE_SAFE) $(INCDIRS) -c -o $@ $<

%.o: %.S
	$(CC) $(ASFLAGS) $(CFLAGS) $(OPTIMIZE) -c -o $@ $<

%.o: %.c
	$(CC) $(INCFLAGS) $(CFLAGS) $(OPTIMIZE) -c  -o $@ $<

clean-objs:
	rm -rf $(OBJECTS)

clean:
	rm -f $(OBJECTS) $(TARGET)

.PHONY: clean
