function menu_init()
    --fillnum=0b0011001100110011.0011001100110011
    menuoptions={}
    add_menu_option("lol", menu_update)
    add_menu_option("play game", bring_up_game_modes)

    menu_option_ind=1
end

function add_menu_option(label, func)
    add(menuoptions, {
        label=label,
        func=func
    })
end

function bring_up_game_modes()

end

function menu_update()
    --fillnum = fillnum >>< 1
end