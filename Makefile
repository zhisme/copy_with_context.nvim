LUA_VERSION = 5.4
DEPS_DIR = deps
TEST_DIR = tests
ROCKSPEC = copy_with_context-2.1.0-1.rockspec
BUSTED = $(DEPS_DIR)/bin/busted

.PHONY: deps
deps:
	@echo "Installing dependencies from rockspec..."
	@luarocks --tree=$(DEPS_DIR) make $(ROCKSPEC)
	@echo "Dependencies installed."

.PHONY: test
test: deps
	@echo "Running tests..."
	@$(BUSTED) $(TEST_DIR)

# Clean generated files
.PHONY: clean
clean:
	@echo "Cleaning up..."
	@rm -rf $(DEPS_DIR)
	@echo "Cleanup complete."
