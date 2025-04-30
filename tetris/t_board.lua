function set_piece_to_grid(tetri)
    for rowi=0,#tetri.piecegrid-1 do
        for coli=0,#tetri.piecegrid[rowi+1]-1 do
            if tetri.piecegrid[rowi+1][coli+1] == 1 then
                local block={
                    issolid=true,
                    cleared=false,
                    color=tetri.color
                }
                board[tetri.y+rowi][tetri.x+coli] = block
            end
        end
    end
end

function check_line_clears()
    clearinds={}
    for i=1, #board, 1 do
        cleared=true
        for block in all(board[i]) do
            if not block.issolid then
                cleared=false
                break
            end
        end
        if cleared then
            add(clearinds, i)
        end
    end
    if #clearinds > 0 then
        arecounter = get_are_delay(true)
        lineclearing = true
    else
        lineclearing = false
    end
    for clear in all(clearinds) do
        deli(board, clear)
        local r={}
        add(board,r,1)
        for f=1, boardsizex do
            local gridblock={
                issolid=false,
                color=0
            }
            add(r,gridblock)
        end
        level += 1
    end
end

function fillboard()
    for i=1, boardsizey do
        local r={}
        add(board,r)
        for f=1, boardsizex do
            local gridblock={
                issolid=false,
                cleared=false,
                color=0
            }
            add(r,gridblock)
        end
    end
end