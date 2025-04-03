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
        pieceid=2,
        rotation_ind=1,
        color=2,
        x=5,
        y=10
    }

    boardsizex=10
    boardsizey=19
    boardx=20
    boardy=3

end

function dtb(num)
    local bin=""
    for i=7,0,-1do
      bin..=num\2^i %2
    end
    return bin
  end

function tetris_update60()
    if btnp(5) then
        currpiece.rotation_ind += 1
        if currpiece.rotation_ind > #pieces[currpiece.pieceid] then
            currpiece.rotation_ind = 1
        end
        --stop(currpiece.rotation_ind)
    end
end

function draw_board_backing()
    rectfill(boardx, boardy, boardx+boardsizex*6, boardy+boardsizey*6, 3)
end

function draw_tetrimino()
    piecenum=pieces[currpiece.pieceid][currpiece.rotation_ind]
    tsize=piecesizes[currpiece.pieceid]
    checkbit=shl(0b1, (tsize*tsize)-1)
    checkbit=band(checkbit, 0b1111111111111111)
    checknum=0
    --stop(tostr(piecenum, 1))
    while abs(checkbit)>0 do
        --stop(tostr(checkbit,1))
        if checkbit & piecenum != 0 then
            tx=(checknum%tsize)*6
            ty=flr(checknum/tsize)*6
            --stop(ty)

            rect(boardx+currpiece.x*6+tx, boardy+currpiece.y*6+ty, boardx+currpiece.x*6+tx+5, boardy+currpiece.y*6+ty+5, 1)
            --stop()
        end
        checknum+=1
        checkbit/=2
        -- first bit will be negative if size is 4
        if (sgn(checkbit)==-1) then 
            checkbit*=-1 
        end
    end
end

function tetris_draw()
    cls()
    draw_board_backing()
    draw_tetrimino()
end