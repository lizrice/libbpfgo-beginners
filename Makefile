TARGET := hello
TARGET_BPF := $(TARGET).bpf.o

GO_SRC := $(shell find . -type f -name '*.go')
BPF_SRC := $(shell find . -type f -name '*.bpf.c')

LIBBPF_HEADERS := /usr/include/bpf
LIBBPF_OBJ := /usr/lib/x86_64-linux-gnu/libbpf.a

.PHONY: all
all: $(TARGET) $(TARGET_BPF)

go_env := CC=clang CGO_CFLAGS="-I $(LIBBPF_HEADERS)" CGO_LDFLAGS="$(LIBBPF_OBJ)"
$(TARGET): $(GO_SRC)
	$(go_env) go build -o $(TARGET) 

$(TARGET_BPF): $(BPF_SRC)
	clang \
		-I /usr/include/x86_64-linux-gnu \
		-O2 -c -target bpf \
		-o $@ $<

.PHONY: clean
clean:
	go clean
	-rm $(TARGET_BPF)
	