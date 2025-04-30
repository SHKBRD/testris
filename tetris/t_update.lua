function accept_game_inputs()
    if controllingpiece and currpiece != nil then
        active_piece_inputs()
    end
    if playing then
        das_inputs()
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
