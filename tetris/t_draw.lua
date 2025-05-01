function draw_board_backing()
    rect(boardx-2, boardy+4, boardx+boardsizex*blocksize+1, boardy+boardsizey*blocksize+1, 6)
    rect(boardx-1, boardy+5, boardx+boardsizex*blocksize, boardy+boardsizey*blocksize, 7)
    fillp(0b1100011000111001)
    rectfill(boardx, boardy+6, boardx+boardsizex*blocksize-1, boardy+boardsizey*blocksize-1, 1)
    fillp()
end

function draw_board_block(x, y, block_type)
    rectfill(x,y,x+blocksize-1,y+blocksize-1,block_type)
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
                        boardx+(col+x1)*blocksize+xoff+sxoff,
                        boardy+(row+y1)*blocksize+yoff+syoff,
                        boardx+(col+x2)*blocksize+xoff,
                        boardy+(row+y2)*blocksize+yoff,7)
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
                    draw_board_block(boardx+coli*blocksize, boardy+rowi*blocksize, findin(piececolors, block.color)+7)
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
            bx=x+(coli-2)*blocksize
            by=y+(rowi-2)*blocksize
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
    draw_tetrimino(boardx+drawcurr.x*blocksize, boardy+drawcurr.y*blocksize,drawcurr)
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

function draw_ghostpiece()
    ghostp=deepcopy(currpiece)
    ghostp.color=6
    attempt_fast_drop(ghostp)
    draw_tetrimino(boardx+ghostp.x*blocksize, boardy+ghostp.y*blocksize, ghostp)
    --stop(color())
end 

function draw_clear_parts()
    for part in all(clearparts) do
        circfill(boardx+part.x*blocksize,boardy+part.y*blocksize,part.timer,part.color)
    end
end

function tetris_draw()
    cls(11)
    draw_board_backing()
    draw_board_blocks()
    if currpiece then
        draw_ghostpiece()
        draw_currpiece()
    end
    if lockedpiece != nil and lockedpiece_counter<lockedpiece_counter_max then
        draw_tetrimino(boardx+lockedpiece.x*blocksize, boardy+lockedpiece.y*blocksize,lockedpiece)
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