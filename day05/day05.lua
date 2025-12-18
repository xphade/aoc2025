#!/usr/bin/env lua

---Merges the given ranges. Note that this function sorts the input table in
---order to be able to do the merging in a single pass.
---@param ranges table: Potentially unmerged ranges
---@return table: Fully merged ranges
local function merge(ranges)
    local merged_ranges = {}
    table.sort(ranges, function(a, b) return a[1] < b[1] end)
    for _, range in ipairs(ranges) do
        local current_merge = merged_ranges[#merged_ranges]
        if current_merge and (range[1] <= current_merge[2]) then
            current_merge[2] = math.max(current_merge[2], range[2])
        else
            -- New distinct range, add it to the table.
            table.insert(merged_ranges, { range[1], range[2] })
        end
    end
    return merged_ranges
end

local function main()
    if #arg ~= 1 then
        print("Usage: lua day05.lua <file_path>")
        os.exit(1)
    end
    local file_path = arg[1]

    local file = io.open(file_path, "r")
    if file == nil then
        print("Failed opening file '" .. file_path .. "'")
        os.exit(1)
    end

    -- Read data from the given file. Assumes that the file contains data in
    -- expected format.
    local ranges = {}
    local ingredient_ids = {}

    for line in file:lines() do
        local a, b = string.match(line, "(%d+)-(%d+)")
        if a and b then
            table.insert(ranges, { tonumber(a), tonumber(b) })
        else
            local id = string.match(line, "^(%d+)$")
            if id then
                table.insert(ingredient_ids, tonumber(id))
            end
        end
    end
    file:close()

    -- Actual solution starts here: Merge the given ranges, count the fresh
    -- ingredients (part 1) and count the total number of IDs in the ranges
    -- (part 2).
    local merged_ranges = merge(ranges)

    local fresh_count = 0
    for _, id in ipairs(ingredient_ids) do
        for _, range in ipairs(merged_ranges) do
            if id >= range[1] and id <= range[2] then
                fresh_count = fresh_count + 1
            end
        end
    end
    print("Solution to part 1: " .. fresh_count)

    local id_count = 0
    for _, range in ipairs(merged_ranges) do
        id_count = id_count + (range[2] - range[1] + 1)
    end
    print("Solution to part 2: " .. id_count)
end

main()
