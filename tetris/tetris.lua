function tetris_init()
    --prevents re-presses to let das not be buggy
    poke(0x5f5c,255)
    --prevent pal clearing
    poke(0x5f2e, 1)
    pal(1, 129, 1)
    playing = true
    --i,o,j,l,z,t,s
    nextpiece=flr(rnd(5)+1)
    pieces={
        {3840,8738},
        {1632},
        {57,150,39,210},
        {60,402,15,147},
        {58,178,23,154},
        {30,306},
        {51,90}
    }
    piecesizes={4,4,3,3,3,3,3}
    piececolors={8,10,140,9,12,14,11}
    pal(8, 2, 1)
    pal(9, 9, 1)
    pal(10, 1, 1)
    pal(11, 4, 1)
    pal(12, 140, 1)
    pal(13, 128+8, 1)
    pal(14, 3, 1)
    piecebag={}

    gravitylevel={
        0,  30 ,35 ,40 ,
        50 ,60 ,70 ,80 ,
        90,100,120,140,
        160,170,200,220,
        230,233,236,239,
        243,247,251,300,
        330,360,400,420,450,500
    }
    gravityamnt={
        4  ,6  ,8  ,10 ,
        12 ,16 ,32 ,48 ,
        64 ,80 ,96 ,112,
        128,144,4  ,32 ,
        64 ,96 ,128,160,
        192,224,256,512,
        768,1024,1280,1024,768,5120
    }

    currpiece={}
    lockedpiece=nil
    lockedpiece_counter=0
    lockedpiece_counter_max=4
    spawn_new_piece()
    controllingpiece= true
    piecelocking = false
    lineclearing = false
    arecounter = -1
    clear_particles_addable = true
    clearparts={}

    level = 0

    boardsizex=10
    boardsizey=21
    boardx=20
    boardy=0
    board={}
    fillboard()

    das_frames = -1
end

function tetris_update60()
    accept_game_inputs()
    update_counters()
    if arecounter == 0 then
        check_line_clears()
    end
end