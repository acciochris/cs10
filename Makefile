SHELL = /bin/bash
export DISPLAY = :0

%.asm: %.s
	spim -dump -file $^
	cat data.asm text.asm > $@
	rm data.asm text.asm

.PHONY: clean
clean:
	find . -name '*.asm' -delete

.PHONY: mars
mars:
	bash mars.sh
