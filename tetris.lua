function tetris_init()
    --i,o,j,l,z,t,s
    pieces={
        {3840,8738},
        {1632},
        {57,150,39,210},
        {60,402,15,147},
        {30,306},
        {58,178,23,154},
        {51,90}
    }
    piecesizes={4,4,3,3,3,3,3}
    piecebag={}

    currpiece={}
    spawn_new_piece()
    controllingpiece= true
    piecelocking = false
    lineclearing = false
    arecounter = -1

    level = 0

    boardsizex=10
    boardsizey=21
    boardx=20
    boardy=3
    board={}
    fillboard()

    das_frames = 0
end

function get_are_delay()
    clearamnt=0
    
    if level < 700 then
        clearamnt = 25
    elseif level < 800 then
        clearamnt = 16
    else
        clearamnt = 12
    end
    
    if lineclearing then
        if level < 600 then
            clearamnt += 25
        elseif level < 700 then
            clearamnt += 16
        elseif level < 800 then
            clearamnt += 12
        else
            clearamnt += 6
        end
    end
    return clearamnt
end

function spawn_new_piece()
    currpiece={

        pieceid=flr(rnd(7)+1),
        rotation_ind=1,
        color=2,
        x=5,
        y=1,
        piecegrid={}
    }
    init_piece_grid(currpiece)
end

function init_piece_grid(p)
    p.piecegrid = {}
    piecenum=pieces[p.pieceid][p.rotation_ind]
    tsize=piecesizes[p.pieceid]
    for rowi=1, tsize do
        addrow={}
        add(p.piecegrid, addrow)
        for coli=1, tsize do
            add(addrow, 0)
        end
    end
    checkbit=shl(0b1, (tsize*tsize)-1)
    checkbit=band(checkbit, 0b1111111111111111)
    checknum=0
    --stop(tostr(piecenum, 1))
    while abs(checkbit)>0 do
        --stop(tostr(checkbit,1))
        if checkbit & piecenum != 0 then
            p.piecegrid[flr(checknum/tsize)+1][(checknum%tsize)+1] = 1
        end

        checknum+=1
        checkbit/=2
        -- first bit will be negative if size is 4
        if (sgn(checkbit)==-1) then 
            checkbit*=-1 
        end
    end

    --stop(#p.piecegrid)
    for r in all(p.piecegrid) do
        print(r)
    end

end

function fillboard()
    for i=1, boardsizey do
        local r={}
        add(board,r)
        for f=1, boardsizex do
            local gridblock={
                issolid=false,
                color=0
            }
            add(r,gridblock)
        end
    end
end

function tetris_update60()
    accept_game_inputs()
    update_counters()
end

function accept_game_inputs()
    if controllingpiece then
        active_piece_inputs()
    end
end

function update_counters()
    are_delay_update()
end

function are_delay_update()
    if arecounter > 0 then
        arecounter -= 1
    end
    if arecounter == 0 then
        set_piece_to_grid(currpiece)
        spawn_new_piece()
        controllingpiece = true
        arecounter = -1
    end
end

function set_piece_to_grid(tetri)
    for rowi=0,#tetri.piecegrid-1 do
        for coli=0,#tetri.piecegrid[rowi+1]-1 do
            if tetri.piecegrid[rowi+1][coli+1] == 1 then
                local block={
                    issolid=true,
                    color=tetri.color
                }
                --stop(tetri.y+rowi)
                board[tetri.y+rowi][tetri.x+coli] = block
            end
        end
    end
end

function active_piece_inputs()
    if btnp(0) then
        init_das()
    end
    if btn(0) then
        continue_das()
    end
    if btnp(1) then
        init_das()
    end
    if btn(1) then
        continue_das()
    end
    if btn(0) == btn(1) then
        kill_das(currpiece)
    end

    if btnp(2) then

    end
    if btnp(3) then
        
    end
    if btn(3) then
        moveddown = attempt_move_tetrimino_down(currpiece)
        if not moveddown then
            lock_piece(currpiece)
        end
    end
    if btnp(5) then
        attempt_rotate_tetrimino(1, currpiece)
    end
    if btnp(4) then
        attempt_rotate_tetrimino(-1, currpiece)
    end
end

function init_das()
    if btnp(0) != btnp(1) then
        dasframes = 0
        movedir = 0
        if (btnp(1)) movedir += 1
        if (btnp(0)) movedir -= 1
        attempt_move_tetrimino(movedir, currpiece)
    end
end

function continue_das()
    if btnp(0) != btnp(1) then
        das_frames += 1
    end
end

function kill_das()
    das_frames = -1
end

function attempt_move_tetrimino(dir, tetri)
    check_tetrimino = {}
    check_tetrimino = deepcopy(tetri, {})
    check_tetrimino.x += dir
    if not is_piece_colliding_grid(check_tetrimino) then
        tetri.x += dir
    end
end

function attempt_move_tetrimino_down(tetri)
    check_tetrimino = {}
    check_tetrimino = deepcopy(tetri, {})
    check_tetrimino.y += 1
    if not is_piece_colliding_grid(check_tetrimino) then
        --stop(12)
        tetri.y = check_tetrimino.y
        return true
    end
    return false
end

function is_piece_colliding_grid(tetri)
    for row=1,#tetri.piecegrid do
        for col=1,#tetri.piecegrid[row] do
            block = tetri.piecegrid[row][col]
            boardpx = tetri.x+col-1
            boardpy = tetri.y+row-1
            if (boardpx < 1 or boardpx>boardsizex) and block != 0 then
                --stop(boardpx)
                return true
            end
            if (boardpy < 1 or boardpy>boardsizey) and block != 0 then
                --stop(boardpy)
                return true
            end
            if block != 0 and board[boardpy][boardpx].issolid then
                --stop(2)
                return true 
            end
        end
    end
    return false
end

function attempt_rotate_tetrimino(dir, tetri)
    check_tetrimino = {}
    check_tetrimino = deepcopy(tetri, {})
    rotate_tetrimino(dir, check_tetrimino)
    if not is_piece_colliding_grid(check_tetrimino) then
        currpiece = check_tetrimino
        return true
    end
    check_tetrimino.x -= 1
    if not is_piece_colliding_grid(check_tetrimino) then
        currpiece = check_tetrimino
        return true
    end
    check_tetrimino.x += 2
    if not is_piece_colliding_grid(check_tetrimino) then
        currpiece = check_tetrimino
        return true
    end
    return false
end

function rotate_tetrimino(dir, tetri)
    if dir==1 then
        tetri.rotation_ind += 1
        if tetri.rotation_ind > #pieces[tetri.pieceid] then
            tetri.rotation_ind = 1
        end
        --stop(currpiece.rotation_ind)
    elseif dir==-1 then
        tetri.rotation_ind -= 1
        if tetri.rotation_ind < 1 then
            tetri.rotation_ind = #pieces[tetri.pieceid]
        end
        --stop(currpiece.rotation_ind)
    end
    init_piece_grid(tetri)
end

function lock_piece()
    controllingpiece = false
    piecelocking = true
    arecounter=get_are_delay()
end

function draw_board_backing()
    rectfill(boardx, boardy+6, boardx+boardsizex*6-1, boardy+boardsizey*6-1, 3)
end

function draw_board_block(x, y, block_type)
    rect(x,y,x+5,y+5,block_type)
end

function draw_board_blocks()
    for rowi=0,#board-1 do
        for coli=0,(#board[rowi+1]-1) do
            block = board[rowi+1][coli+1]
            if block.issolid then
                draw_board_block(boardx+coli*6, boardy+rowi*6, block.color)
            -- else
            --     print(0, boardx+coli*6, boardy+rowi*6, 1)
            end
        end
    end
end

function draw_tetrimino(x, y, p)
    --stop(#p.piecegrid[1])
    for rowi=1, #p.piecegrid do
        --stop()
        for coli=1, #p.piecegrid[rowi] do
            bx=x+(coli-2)*6
            by=y+(rowi-2)*6
            result=p.piecegrid[rowi][coli]
            if result != 0 then
                draw_board_block(bx,by,p.color)
            end
        end
    end
end

function tetris_draw()
    cls()
    draw_board_backing()
    draw_board_blocks()
    draw_tetrimino(boardx+currpiece.x*6, boardy+currpiece.y*6,currpiece)
    print(arecounter, 50, 50)
end