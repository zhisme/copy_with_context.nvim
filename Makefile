LUA_VERSION = 5.1
DEPS_DIR = deps
TEST_DIR = tests
ROCKSPEC = copy_with_context-2.1.0-1.rockspec
BUSTED = $(DEPS_DIR)/bin/busted

.PHONY: install-stylua
install-stylua:
	@echo "Installing stylua..."
	@if ! command -v stylua > /dev/null; then \
		cargo install stylua; \
		echo "stylua installed."; \
	else \
		echo "stylua already installed."; \
	fi

.PHONY: deps
deps:
	@echo "Installing dependencies from rockspec..."
	@luarocks --tree=$(DEPS_DIR) make $(ROCKSPEC)
	@echo "Dependencies installed."

.PHONY: test
test: deps
	@echo "Running tests..."
	@$(BUSTED) $(TEST_DIR)

.PHONY: fmt
fmt:
	@echo "Formatting Lua files with stylua..."
	@stylua lua tests

.PHONY: fmt
fmt-check:
	@echo "Checking Lua files with stylua..."
	@stylua --check lua tests

# Clean generated files
.PHONY: clean
clean:
	@echo "Cleaning up..."
	@rm -rf $(DEPS_DIR)
	@echo "Cleanup complete."
