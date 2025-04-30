function get_are_delay(lineclearing)
    clearamnt=0
    if not lineclearing then
        if level < 700 then
            clearamnt = 25
        elseif level < 800 then
            clearamnt = 16
        else
            clearamnt = 12
        end
    else    
        if level < 600 then
            clearamnt = 25
        elseif level < 700 then
            clearamnt = 16
        elseif level < 800 then
            clearamnt = 12
        else
            clearamnt = 6
        end
    end
    return clearamnt
end

function get_gravity(flevel)
    for i=#gravitylevel, 1, -1 do
        if flevel >= gravitylevel[i] then
            return gravityamnt[i]
        end
    end
    return 0
end

function get_das_frames()
    if level < 500 then
        return 16
    elseif level < 900 then
        return 10
    else
        return 8
    end
end