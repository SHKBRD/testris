-- Save copied tables in `copies`, indexed by original table.
function deepcopy(orig, copies)
    copies = copies or {}
    local orig_type = type(orig)
    local copy
    if orig_type == 'table' then
        if copies[orig] then
            copy = copies[orig]
        else
            copy = {}
            copies[orig] = copy
            for orig_key, orig_value in next, orig, nil do
                copy[deepcopy(orig_key, copies)] = deepcopy(orig_value, copies)
            end
            setmetatable(copy, deepcopy(getmetatable(orig), copies))
        end
    else -- number, string, boolean, etc
        copy = orig
    end
    return copy
end

function findin(table, item)
    for i=1,#table do
        if table[i] == item then
            return i
        end
    end
    return -1
end

function clamp(min, max, val)
    if min > val then return min end
    if val > max then return max end
    return val
end

function wrap_index(ind, table)
    ind %= #table
    if ind < 1 then
        return #table-ind
    end
    return ind
end