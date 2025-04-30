function update_clear_parts()
    removeparts={}
    for parti=1,#clearparts do
        clearparts[parti].timer-=1
        if clearparts[parti].timer == 0 then
            add(removeparts, parti)
        end
    end
    for i=#removeparts,1,-1 do
        deli(clearparts, i)
    end
end

function make_line_clear_effect(row)
    for col=1,boardsizex do
        part={
            x=col,
            y=row,
            color=board[row][col].color,
            timer=10
        }
        add(clearparts, part)
    end
end