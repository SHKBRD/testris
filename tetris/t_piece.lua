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

function lockedpiece_update()
    lockedpiece_counter+=1
    if lockedpiece_counter >= lockedpiece_counter_max then
        lockedpiece=nil
        lockedpiece_counter=0
    end
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
