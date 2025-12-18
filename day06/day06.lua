#!/usr/bin/env lua

---Solves the tasks defined by the given numbers and operators. Assumes that
---#numbers == #operators. Each row in numbers defines one task which needs to
---be solved according to the corresponding operator.
---@param numbers table: Each entry contains a list of numbers
---@param operators table: A list of operators, either "+" or "*"
---@return integer: Sum of all task results
local function solve_tasks(numbers, operators)
    local sum = 0
    for op_idx, op in ipairs(operators) do
        local f = nil
        local result = nil
        if op == "+" then
            result = 0
            f = function(a, b) return a + b end
        else
            result = 1
            f = function(a, b) return a * b end
        end

        for _, num in ipairs(numbers[op_idx]) do
            result = f(result, num)
        end
        sum = sum + result
    end
    return sum
end

---Extracts the numbers contained in the lines vertically. Assumes that each
---line either contains only numbers or operators separated by whitespace.
---@param lines table: All lines of the input
---@return table: The extracted numbers, each row contains a list of numbers
local function extract_numbers_vertically(lines)
    local numbers = {}
    for _, line in ipairs(lines) do
        local task_num = 1
        for num in string.gmatch(line, "%d+") do
            -- Either create a new table or add to the existing one.
            if not numbers[task_num] then
                table.insert(numbers, task_num, { tonumber(num) })
            else
                table.insert(numbers[task_num], tonumber(num))
            end
            task_num = task_num + 1
        end
    end
    return numbers
end

---Extracts the numbers contained in the lines if you read them column by
---column from top to bottom. Assumes that each line either contains only
---numbers or operators separated by whitespace. Also assumes that the numbers
---are aligned, i.e. a completely empty column defines the end of a task.
---@param lines table: All lines of the input
---@return table: The extracted numbers, each row contains a list of numbers
local function extract_numbers_by_columns(lines)
    -- Get maximum column length.
    local max_columns = 0
    for _, line in ipairs(lines) do
        max_columns = math.max(max_columns, #line)
    end

    local numbers = {}
    local task_num = 1
    for c = 1, max_columns do
        -- Append each digit in the column to this string.
        local number_str = ""
        for _, line in ipairs(lines) do
            local character = line:sub(c, c)
            if character:match("%d") then
                number_str = number_str .. character
            end
        end

        if #number_str == 0 then
            -- A column which is completely empty separates the tasks.
            task_num = task_num + 1
        else
            -- Either create a new table or add to the existing one.
            if not numbers[task_num] then
                table.insert(numbers, task_num, { tonumber(number_str) })
            else
                table.insert(numbers[task_num], tonumber(number_str))
            end
        end
    end
    return numbers
end

local function main()
    if #arg ~= 1 then
        print("Usage: lua day06.lua <file_path>")
        os.exit(1)
    end
    local file_path = arg[1]

    local file = io.open(file_path, "r")
    if not file then
        print("Failed opening file '" .. file_path .. "'")
        os.exit(1)
    end

    local lines = {}
    for line in file:lines() do
        table.insert(lines, line)
    end
    file:close()

    local operators = {}
    for operator in string.gmatch(lines[#lines], "[%+%*]") do
        table.insert(operators, operator)
    end

    local numbers_vertical = extract_numbers_vertically(lines)
    print("Solution to part 1: " .. solve_tasks(numbers_vertical, operators))

    local numbers_by_columns = extract_numbers_by_columns(lines)
    print("Solution to part 2: " .. solve_tasks(numbers_by_columns, operators))
end

main()
