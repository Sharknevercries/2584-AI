SRC=src/
OUTPUT=2584

.PHONY = all clean
all: $(SRC)2584-AI.cr
	crystal $^ -o $(OUTPUT) --release --no-debug
clean:
	rm $(OUTPUT)