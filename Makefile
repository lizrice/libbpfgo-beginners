ARCH=$(shell uname -m)

TARGET := hello
TARGET_BPF := $(TARGET).bpf.o

GO_SRC := *.go Makefile
BPF_SRC := *.bpf.c *.bpf.h Makefile

LIBBPF_HEADERS := /usr/include/bpf
LIBBPF_OBJ := /usr/lib/$(ARCH)-linux-gnu/libbpf.a

.PHONY: all
all: $(TARGET) $(TARGET_BPF)

go_env := CC=clang CGO_CFLAGS="-I $(LIBBPF_HEADERS)" CGO_LDFLAGS="$(LIBBPF_OBJ)"
$(TARGET): $(GO_SRC)
	$(go_env) go build -o $(TARGET) -buildvcs=false

$(TARGET_BPF): $(BPF_SRC)
	clang \
		-I /usr/include/$(ARCH)-linux-gnu \
		-O2 -c -target bpf \
		-o $@ $<

.PHONY: clean
clean:
	go clean
