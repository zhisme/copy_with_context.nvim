#!/usr/bin/env lua

-- Simple test runner for copy_with_context.nvim tests
-- This script will load and run all test files in the tests directory

-- Add current directory and project paths to package path
package.path = package.path .. ";./?.lua;./lua/?.lua;./lua/?/init.lua"

-- Set up minimal busted-compatible test environment
if not describe then
	-- Define basic busted functions
	_G.describe = function(name, fn)
		print("\n--- " .. name .. " ---")
		fn()
	end

	_G.it = function(name, fn)
		io.write("  - " .. name .. "...")
		local success, err = pcall(fn)
		if success then
			print(" OK")
		else
			print(" FAILED: " .. tostring(err))
		end
	end

	_G.assert = {
		is_true = function(value)
			if not value then
				error("Expected true, got " .. tostring(value))
			end
		end,
		is_false = function(value)
			if value then
				error("Expected false, got " .. tostring(value))
			end
		end,
		is_not_nil = function(value)
			if value == nil then
				error("Expected non-nil value")
			end
		end,
		is_nil = function(value)
			if value ~= nil then
				error("Expected nil, got " .. tostring(value))
			end
		end,
		are = {
			same = function(a, b)
				if type(a) ~= type(b) then
					error("Types don't match: " .. type(a) .. " vs " .. type(b))
				end

				if type(a) == "table" then
					for k, v in pairs(a) do
						if b[k] ~= v then
							error("Tables differ at key " .. tostring(k))
						end
					end
					for k, v in pairs(b) do
						if a[k] ~= v then
							error("Tables differ at key " .. tostring(k))
						end
					end
				elseif a ~= b then
					error("Values don't match: " .. tostring(a) .. " vs " .. tostring(b))
				end
			end,
		},
		is_table = function(value)
			if type(value) ~= "table" then
				error("Expected table, got " .. type(value))
			end
		end,
	}

	_G.before_each = function(fn)
		_G._before_fn = fn
	end

	_G.after_each = function(fn)
		_G._after_fn = fn
	end

	-- Hook into it to run before/after functions
	local old_it = _G.it
	_G.it = function(name, fn)
		return old_it(name, function()
			if _G._before_fn then
				_G._before_fn()
			end
			local result = fn()
			if _G._after_fn then
				_G._after_fn()
			end
			return result
		end)
	end
end

print("Running copy_with_context.nvim tests...")

-- List of test files to run
local test_files = {
	"copy_with_context_spec",
}

-- Run each test file
for _, file in ipairs(test_files) do
	print("\nRunning tests from " .. file .. ".lua")
	require("tests." .. file)
end

print("\nTests completed!")
