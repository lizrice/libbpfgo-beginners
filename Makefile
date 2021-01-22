TARGET := hello

# tools:
CMD_LLC ?= llc
CMD_CLANG ?= clang
CMD_LLVM_STRIP ?= llvm-strip
# environment:
ARCH_UNAME := $(shell uname -m)
ARCH ?= $(ARCH_UNAME:aarch64=arm64)
KERN_RELEASE ?= $(shell uname -r)
# Assume we're just building and running on this kernel
KERN_BLD_PATH ?= $(if $(KERN_HEADERS),$(KERN_HEADERS),/lib/modules/$(KERN_RELEASE)/build)
KERN_SRC_PATH ?= $(if $(KERN_HEADERS),$(KERN_HEADERS),$(if $(wildcard /lib/modules/$(KERN_RELEASE)/source),/lib/modules/$(KERN_RELEASE)/source,$(KERN_BLD_PATH)))
# inputs and outputs:
OUT_DIR ?= dist
GO_SRC := $(shell find . -type f -name '*.go')
BPF_SRC := $(shell find . -type f -name '*.bpf.c')
OUT_BIN := $(TARGET)
OUT_BPF := $(OUT_DIR)/$(TARGET).bpf.o
BPF_HEADERS := include
LIBBPF_SRC := libbpf/src
LIBBPF_HEADERS := $(OUT_DIR)/libbpf/usr/include
LIBBPF_OBJ := $(OUT_DIR)/libbpf/libbpf.a


.PHONY: all
all: build bpf

$(OUT_DIR):
	mkdir -p $@

.PHONY: build
build: $(OUT_BIN)

go_env := GCC=$(CMD_CLANG) GOARCH=$(ARCH:x86_64=amd64) CGO_CFLAGS="-I $(abspath $(LIBBPF_HEADERS))" CC=clang CGO_LDFLAGS="$(abspath $(LIBBPF_OBJ))"
$(OUT_BIN): $(LIBBPF_HEADERS) $(LIBBPF_OBJ) $(GO_SRC)
	$(go_env) go build -v -x -o $(OUT_BIN) 

.PHONY: bpf
bpf: $(OUT_BPF)

linux_arch := $(ARCH:x86_64=x86)
$(OUT_BPF): $(BPF_SRC) $(LIBBPF_HEADERS) | $(OUT_DIR) $(bpf_compile_tools)
	$(CMD_CLANG) -S \
		-D__BPF_TRACING__ \
		-D__KERNEL__ \
		-D__TARGET_ARCH_$(linux_arch) \
		-I $(LIBBPF_HEADERS)/bpf \
		-include $(KERN_SRC_PATH)/include/linux/kconfig.h \
		-I $(KERN_SRC_PATH)/arch/$(linux_arch)/include \
		-I $(KERN_SRC_PATH)/arch/$(linux_arch)/include/uapi \
		-I $(KERN_BLD_PATH)/arch/$(linux_arch)/include/generated \
		-I $(KERN_BLD_PATH)/arch/$(linux_arch)/include/generated/uapi \
		-I $(KERN_SRC_PATH)/include \
		-I $(KERN_BLD_PATH)/include \
		-I $(KERN_SRC_PATH)/include/uapi \
		-I $(KERN_BLD_PATH)/include/generated \
		-I $(KERN_BLD_PATH)/include/generated/uapi \
		-I $(BPF_HEADERS) \
		-Wno-address-of-packed-member \
		-Wno-compare-distinct-pointer-types \
		-Wno-deprecated-declarations \
		-Wno-gnu-variable-sized-type-not-at-end \
		-Wno-pointer-sign \
		-Wno-pragma-once-outside-heade \
		-Wno-unknown-warning-option \
		-Wno-unused-value \
		-Wunused \
		-Wall \
		-fno-stack-protector \
		-fno-jump-tables \
		-fno-unwind-tables \
		-fno-asynchronous-unwind-tables \
		-xc \
		-nostdinc \
		-O2 -emit-llvm -c -g $< -o $(@:.o=.ll)
	$(CMD_LLC) -march=bpf -filetype=obj -o $@ $(@:.o=.ll)
	-$(CMD_LLVM_STRIP) -g $@
	rm $(@:.o=.ll)

bpf_compile_tools = $(CMD_LLC) $(CMD_CLANG) $(CMD_LLVM_STRIP)
.PHONY: $(bpf_compile_tools) 
$(bpf_compile_tools): % : check_%

$(LIBBPF_SRC):
	test -d $(LIBBPF_SRC) || git submodule update --init || (echo "missing libbpf source" ; false)

$(LIBBPF_HEADERS) $(LIBBPF_HEADERS)/bpf $(LIBBPF_HEADERS)/linux: | $(OUT_DIR) $(bpf_compile_tools) $(LIBBPF_SRC)
	cd $(LIBBPF_SRC) && $(MAKE) install_headers install_uapi_headers DESTDIR=$(abspath $(OUT_DIR))/libbpf

$(LIBBPF_OBJ): | $(OUT_DIR) $(bpf_compile_tools) $(LIBBPF_SRC) 
	cd $(LIBBPF_SRC) && $(MAKE) OBJDIR=$(abspath $(OUT_DIR))/libbpf BUILD_STATIC_ONLY=1 

.PHONY: clean
clean:
	-rm -rf dist $(OUT_DIR)
	-cd $(LIBBPF_SRC) && $(MAKE) clean;
	
check_%:
	@command -v $* >/dev/null || (echo "missing required tool $*" ; false)
	@v=$$($(CMD_CLANG) --version); test $$(echo $${v#*version} | head -n1 | cut -d '.' -f1) -ge '9' || (echo 'required minimum clang version: 9' ; false)

