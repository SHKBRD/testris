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