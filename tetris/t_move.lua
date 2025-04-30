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

function attempt_fast_drop(tetri)
    while attempt_move_tetrimino_down(tetri) do

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