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