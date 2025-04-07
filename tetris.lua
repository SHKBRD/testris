function tetris_init()
    --i,o,j,l,z,t,s
    pieces={
        {3840,8738},
        {1632},
        {57,150,39,210},
        {60,402,15,147},
        {30,306},
        {58,178,23,154}
    }
    piecesizes={4,4,3,3,3,3,3}
    i={3840, 8738}
    o={1932}
    j={57,150,39,210}

    currpiece={
        pieceid=4,
        rotation_ind=1,
        color=2,
        x=5,
        y=10,
        piecegrid={}
    }
    init_piece_grid(currpiece)

    boardsizex=10
    boardsizey=19
    boardx=20
    boardy=3
    board={}
    fillboard()

    das_frames = 0
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
    for i=0, boardsizey do
        local r={}
        add(board,r)
        for f=0, boardsizex do
            add(r,0)
        end
    end
end

function tetris_update60()
    accept_game_inputs()
end

function accept_game_inputs()
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

function is_piece_colliding_grid(tetri)
    for row=1,#tetri.piecegrid do
        for col=1,#tetri.piecegrid[row] do
            boardpx = tetri.x+col-1
            boardpy = tetri.y+row-1
            if boardpx < 1 or boardpx>boardsizex then
                stop(1)
                return true
            end
            if tetri.piecegrid[row][col] != 0 and board[boardpy][boardpx] != 0 then
                stop(2)
                return true 
            end
        end
    end
    return false
end

function attempt_rotate_tetrimino(dir)
    rotate_tetrimino(dir, currpiece)
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

function draw_board_backing()
    rectfill(boardx, boardy, boardx+boardsizex*6, boardy+boardsizey*6, 3)
end

function draw_board_block(x, y, block_type)
    rect(x,y,x+5,y+5,block_type)
end

function draw_board_blocks()
    for rowi in #b do
        for coli in #b[rowi] do
            draw_board_block(coli*6, rowi*6, b[rowi][coli])
        end
    end
end

function draw_tetrimino(x, y, p)
    --stop(#p.piecegrid[1])
    for rowi=1, #p.piecegrid do
        --stop()
        for coli=1, #p.piecegrid[rowi] do
            bx=x+coli*6
            by=y+rowi*6
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
    draw_tetrimino(boardx+currpiece.x*6, boardy+currpiece.y*6,currpiece)
end