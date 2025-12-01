.PHONY: init test clean

init:
	@chmod +x scripts/init_demo.sh
	@./scripts/init_demo.sh

test:
	@chmod +x scripts/test_flow.sh
	@./scripts/test_flow.sh

clean:
	@chmod +x scripts/cleanup.sh
	@./scripts/cleanup.sh

all: init test