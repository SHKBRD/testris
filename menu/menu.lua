function menu_init()
    --fillnum=0b0011001100110011.0011001100110011
    menuoptions={}
    add_menu_option("lol", menu_update)
    add_menu_option("play game", bring_up_game_modes)

    base_menu_option_ind=1
end

function add_menu_option(label, func)
    add(menuoptions, {
        label=label,
        func=func,
        selectoff_x=0
    })
end

function bring_up_game_modes()

end

function menu_update()
    base_menu_input()
    menu_option_update()
    --fillnum = fillnum >>< 1
end

function menu_option_update()
    for opi=1,#menuoptions do
        option=menuoptions[opi]
        
        if opi==base_menu_option_ind then
            option.selectoff_x+=1
        else
            option.selectoff_x-=1
        end
        option.selectoff_x = clamp(0, 5, option.selectoff_x)

    end
end

function base_menu_input()
    if btn(0) then
        base_menu_option_ind-=1
        stop(base_menu_option_ind)
    end
    if btn(1) then
        base_menu_option_ind+=1
    end
    base_menu_option_ind=wrap_index(base_menu_option_ind, menuoptions)
end
