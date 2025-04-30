function tetris_init()
    --prevents re-presses to let das not be buggy
    poke(0x5f5c,255)
    --prevent pal clearing
    poke(0x5f2e, 1)
    pal(1, 129, 1)
    playing = true
    --i,o,j,l,z,t,s
    nextpiece=flr(rnd(5)+1)
    pieces={
        {3840,8738},
        {1632},
        {57,150,39,210},
        {60,402,15,147},
        {58,178,23,154},
        {30,306},
        {51,90}
    }
    piecesizes={4,4,3,3,3,3,3}
    piececolors={8,10,140,9,12,14,11}
    pal(8, 2, 1)
    pal(9, 9, 1)
    pal(10, 1, 1)
    pal(11, 4, 1)
    pal(12, 140, 1)
    pal(13, 128+8, 1)
    pal(14, 3, 1)
    piecebag={}

    gravitylevel={
        0,  30 ,35 ,40 ,
        50 ,60 ,70 ,80 ,
        90,100,120,140,
        160,170,200,220,
        230,233,236,239,
        243,247,251,300,
        330,360,400,420,450,500
    }
    gravityamnt={
        4  ,6  ,8  ,10 ,
        12 ,16 ,32 ,48 ,
        64 ,80 ,96 ,112,
        128,144,4  ,32 ,
        64 ,96 ,128,160,
        192,224,256,512,
        768,1024,1280,1024,768,5120
    }

    currpiece={}
    lockedpiece=nil
    lockedpiece_counter=0
    lockedpiece_counter_max=4
    spawn_new_piece()
    controllingpiece= true
    piecelocking = false
    lineclearing = false
    arecounter = -1
    clear_particles_addable = true
    clearparts={}

    level = 500

    boardsizex=10
    boardsizey=21
    boardx=20
    boardy=0
    board={}
    fillboard()

    das_frames = -1
end

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

function chose_piece_id()
    tries=6
    chosenpid=0
    for t=1, tries do 
        local unique = true
        chosenpid=flr(rnd(7)+1)
        for checkpiece in all(piecebag) do
            if checkpiece==chosenpid then
                unique=false
                break
            end
        end
        if unique then
            break
        end
    end
    add(piecebag, chosenpid)
    if #piecebag > 6 then
        deli(piecebag, 1)
    end
    return chosenpid
end

function update_next_piece()
    nextpiece=chose_piece_id()
    
    --stop(piececolors[nextpiece])
end

function spawn_new_piece()
    currpiece={
        pieceid=nextpiece,
        rotation_ind=1,
        color=piececolors[nextpiece],
        x=4,
        y=1,
        piecegrid={},
        gravcounter=0,
        locking=false,
    }
    update_next_piece()
    pal(15, currpiece.color, 1)
    --irs
    if not (btn(4) and btn(5)) then
        if btn(4) then
            attempt_rotate_tetrimino(-1, currpiece)
        elseif btn(5) then
            attempt_rotate_tetrimino(1, currpiece)
        end
    end

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
    while abs(checkbit)>0 do
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

function tetris_update60()
    accept_game_inputs()
    update_counters()
    if arecounter == 0 then
        check_line_clears()
    end
end

function accept_game_inputs()
    if controllingpiece and currpiece != nil then
        active_piece_inputs()
    end
    if playing then
        das_inputs()
    end
    
end

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

function update_counters()
    are_delay_update()
    lockedpiece_update()
    if currpiece != nil then
        apply_piece_gravity(currpiece)
    end
    update_clear_parts()
end

function lockedpiece_update()
    lockedpiece_counter+=1
    if lockedpiece_counter >= lockedpiece_counter_max then
        lockedpiece=nil
        lockedpiece_counter=0
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

function are_delay_update()
    if arecounter > 0 then
        arecounter -= 1
    elseif arecounter == 0 then
        spawn_new_piece()
        controllingpiece = true
        clear_particles_addable = true
        arecounter = -1
    end
end

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

function das_inputs()
    if btnp(0) then
        init_das(-1)
    end
    if btn(0) then
        continue_das()
    end
    if btnp(1) then
        init_das(1)
    end
    if btn(1) then
        continue_das()
    end
end

function active_piece_inputs()
    if controllingpiece then
        if btnp(2) then
            attempt_fast_drop(currpiece)
        end
        if btnp(3) then
            
        end
        if btn(3) then
            moveddown = attempt_move_tetrimino_down(currpiece)
            if not moveddown then
                lock_piece(currpiece)
                if not ((level % 100) == 99) or level == 998 then
                    level += 1
                end
                --prevent piece actions once locked
                return
            end
        end
        if btnp(5) then
            attempt_rotate_tetrimino(1, currpiece)
        end
        if btnp(4) then
            attempt_rotate_tetrimino(-1, currpiece)
        end
    end
end

function apply_piece_gravity(tetri)
    gravity_add_amnt = get_gravity(level)
    tetri.gravcounter += gravity_add_amnt
    while tetri.gravcounter >= 256 do
        tetri.gravcounter -= 256
        moved=attempt_move_tetrimino_down(tetri)
        if not moved then
            tetri.gravcounter=0
            break
        end
    end
end

function init_das(dir)
    das_direction = dir
    das_frames = get_das_frames()
    --sfx(1)
    if controllingpiece then
        movedir = dir
        moveresult = attempt_move_tetrimino(movedir, currpiece)
    end
end

function continue_das()
    if not (btnp(0) and btnp(1)) and das_frames > -1 then
        das_frames -= 1
        if das_frames < 0 then
            das_frames = 0
            if controllingpiece then
                movedir = 0
                if (btn(1)) movedir += 1
                if (btn(0)) movedir -= 1
                moveresult = attempt_move_tetrimino(movedir, currpiece)
            end
        end
    end
end

function kill_das()
    das_frames = -1
end

function attempt_fast_drop(tetri)
    while attempt_move_tetrimino_down(tetri) do

    end
end

function attempt_move_tetrimino(dir, tetri)
    check_tetrimino = {}
    check_tetrimino = deepcopy(tetri, {})
    check_tetrimino.x += dir
    if not is_piece_colliding_grid(check_tetrimino) then
        tetri.x += dir
        return true
    end
    return false
end


function attempt_move_tetrimino_down(tetri)
    check_tetrimino = {}
    check_tetrimino = deepcopy(tetri, {})
    check_tetrimino.y += 1
    if not is_piece_colliding_grid(check_tetrimino) then
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
                return true
            end
            if (boardpy < 1 or boardpy>boardsizey) and block != 0 then
                return true
            end
            if block != 0 and board[boardpy][boardpx].issolid then
                return true 
            end
        end
    end
    return false
end

function attempt_rotate_tetrimino(dir, tetri)
    check_tetrimino = {}
    check_tetrimino = deepcopy(tetri, {})
    can_rotate = true
    checking_kick = true
    if check_tetrimino.pieceid <= 5 and check_tetrimino.pieceid >= 3 and (check_tetrimino.rotation_ind%2)==1 then
        for row=1,#check_tetrimino.piecegrid do
            for col=1,#check_tetrimino.piecegrid[row] do
                block = check_tetrimino.piecegrid[row][col]
                if block == 0 then
                    boardpx = check_tetrimino.x+col-1
                    boardpy = check_tetrimino.y+row-1
                    
                    if board[boardpy][boardpx].issolid and col == 2 then
                        can_rotate = false
                        checking_kick = false
                    end
                    
                end
                if (not checking_kick) break
            end
            if (not checking_kick) break
        end
    end
    checking_kick = false
    if not can_rotate then 
        return
    end

    rotate_tetrimino(dir, check_tetrimino)
    if not is_piece_colliding_grid(check_tetrimino) then
        currpiece = check_tetrimino
        return true
    end
    --don't check wallkicks on i piece
    if check_tetrimino.pieceid != 1 then
        check_tetrimino.x += 1
        if not is_piece_colliding_grid(check_tetrimino) then
            currpiece = check_tetrimino
            return true
        end
        check_tetrimino.x -= 2
        if not is_piece_colliding_grid(check_tetrimino) then
            currpiece = check_tetrimino
            return true
        end
    end
    return false
end

function rotate_tetrimino(dir, tetri)
    if dir==1 then
        tetri.rotation_ind += 1
        if tetri.rotation_ind > #pieces[tetri.pieceid] then
            tetri.rotation_ind = 1
        end
    elseif dir==-1 then
        tetri.rotation_ind -= 1
        if tetri.rotation_ind < 1 then
            tetri.rotation_ind = #pieces[tetri.pieceid]
        end
    end
    init_piece_grid(tetri)
end

function lock_piece()
    lockedpiece=deepcopy(currpiece)
    lockedpiece.color=7
    lockedpiece_counter=0
    controllingpiece = false
    piecelocking = true
    set_piece_to_grid(currpiece)
    currpiece = nil
    arecounter=get_are_delay(false)
end

function draw_board_backing()
    rect(boardx-2, boardy+4, boardx+boardsizex*6+1, boardy+boardsizey*6+1, 6)
    rect(boardx-1, boardy+5, boardx+boardsizex*6, boardy+boardsizey*6, 7)
    fillp(0b1100011000111001)
    rectfill(boardx, boardy+6, boardx+boardsizex*6-1, boardy+boardsizey*6-1, 1)
    fillp()
end

function draw_board_block(x, y, block_type)
    rectfill(x,y,x+5,y+5,block_type)
end

function draw_block_outline(row, col)
    for frow=-1, 1 do
        for fcol=-1, 1 do
            x1=0
            x2=0
            y1=0
            y2=0
            sxoff=0
            syoff=0
            if row+frow<=0 or row+frow>=boardsizey or col+fcol<=-1 or col+fcol>=boardsizex or (frow==0 and fcol==frow) or ((fcol+frow)%2==0) or (board[row+frow+1][col+fcol+1].issolid and board[row+frow+1][col+fcol+1].cleared == false) then
            else
                if frow==0 then
                    x1=(fcol+1)/2
                    x2=(fcol+1)/2
                else
                    x1=0
                    x2=1
                    sxoff=1
                end

                if fcol==0 then
                    y1=(frow+1)/2
                    y2=(frow+1)/2
                else
                    y1=0
                    y2=1
                    syoff=1
                end

                
                xoff=0
                if x1+x2 == 1 then
                    xoff-=1
                end
                if x1+x2 > 1 then
                    xoff-=1
                end

                yoff=0
                if y1+y2 == 1 then
                    yoff-=1
                end
                if y1+y2 > 1 then
                    yoff-=1
                end

                if x1+x2+y1+y2!=0 then
                    line(
                        boardx+(col+x1)*6+xoff+sxoff,
                        boardy+(row+y1)*6+yoff+syoff,
                        boardx+(col+x2)*6+xoff,
                        boardy+(row+y2)*6+yoff,7)
                end
            end
        end
    end
end

function draw_board_blocks()
    for rowi=0,#board-1 do
        cleared = true
        for coli=1,boardsizex do
            block = board[rowi+1][coli]
            if not block.issolid then
                cleared = false
                
                break
            end
        end
        if cleared then
            for coli2=1,boardsizex do
                board[rowi+1][coli2].cleared = true
            end
            if clear_particles_addable then
                make_line_clear_effect(rowi+1)
            end
        end
        if not cleared then
            for coli=0,(#board[rowi+1]-1) do
                block = board[rowi+1][coli+1]
                if block.issolid then
                    draw_board_block(boardx+coli*6, boardy+rowi*6, findin(piececolors, block.color)+7)
                    draw_block_outline(rowi, coli)
                    -- else
                --     print(0, boardx+coli*6, boardy+rowi*6, 1)
                end
            end
        else
            
            lockedpiece_counter = lockedpiece_counter_max
        end
    end
    if clear_particles_addable and #clearparts != 0 then
        clear_particles_addable = false
    end
end

function draw_tetrimino(x, y, p)
    for rowi=1, #p.piecegrid do
        for coli=1, #p.piecegrid[rowi] do
            bx=x+(coli-2)*6
            by=y+(rowi-2)*6
            result=p.piecegrid[rowi][coli]
            if result != 0 then
                if p.locking == true then
                    draw_board_block(bx,by,6)
                else
                    draw_board_block(bx,by,p.color)
                end
                

            end
        end
    end
end

function draw_currpiece()
    drawcurr = deepcopy(currpiece)
    drawcurr.color=15
    draw_tetrimino(boardx+drawcurr.x*6, boardy+drawcurr.y*6,drawcurr)
end 

function draw_nextpiece()
    nextp={
        pieceid=piecebag[#piecebag],
        rotation_ind=1,
        color=piececolors[piecebag[#piecebag]],
        x=5,
        y=1,
        piecegrid={}
    }
    init_piece_grid(nextp)
    drawnext = deepcopy(nextp)
    drawnext.color=4
    pal(4, piececolors[nextpiece], 1)
    draw_tetrimino(100, 20, drawnext)
    --stop(color())
end 

function draw_clear_parts()
    for part in all(clearparts) do
        circfill(boardx+part.x*6,boardy+part.y*6,part.timer,part.color)
    end
end

function tetris_draw()
    cls()
    draw_board_backing()
    draw_board_blocks()
    if currpiece then
        draw_currpiece()
    end
    if lockedpiece != nil and lockedpiece_counter<lockedpiece_counter_max then
        draw_tetrimino(boardx+lockedpiece.x*6, boardy+lockedpiece.y*6,lockedpiece)
    end
    
    draw_clear_parts()
    draw_nextpiece()
    --draw_tetrimino(100, 20, nextp)
    --print(arecounter, 50, 50)
    --print(das_frames, 50, 58)
    print(level, 100, 110)
    print(lockedpiece_counter, 100, 118)
    for pind=1,#piecebag,1 do
        print(piecebag[pind], 100,50+pind*8)
    end
end