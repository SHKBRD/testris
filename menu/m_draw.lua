function menu_draw()
    cls()
    --fillp(fillnum)
    --rectfill(0,0,128,128)
    --stop()
    draw_menu_options()
end

function draw_menu_options()
    for opi=1, #menuoptions do
        option=menuoptions[opi]
        draw_blob(20,20*opi, 8+#(menuoptions[opi].label)*4, 8,3,2)
        print(menuoptions[opi].label, 25+option.selectoff_x, 20*opi+2, 5)
    end
end