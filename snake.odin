package snake


import as "assets"
import re"rendering"
import "core:fmt"
import rl "vendor:raylib"
import "core:math"


grid_width::20
cell_size::16
canvas_size::grid_width*cell_size
tick_rate::0.13
max_snake_length::grid_width*grid_width


tick_timer: f32 = tick_rate
food_pos: [2]int
food_color:rl.Color
snake_length:int =3
snake_segments:[max_snake_length][2]int
snake_color:rl.Color
direction:[2]int

snake_start_pos:[2]int={10,10}
game_over:bool
score:int

snake_setup::proc(){

    snake_restart()
    
}
gen_color::proc()->rl.Color{
    rand :=rl.GetRandomValue(0,2)
    t_color:rl.Color
    if rand == 0{
        t_color.r = cast(u8)rl.GetRandomValue(200,255)
        t_color.g = cast(u8)rl.GetRandomValue(0,255)
        t_color.b = cast(u8)rl.GetRandomValue(0,55)
        t_color.a = 255 
    }
    if rand == 1{
        t_color.r = cast(u8)rl.GetRandomValue(0,55)
        t_color.g = cast(u8)rl.GetRandomValue(200,255)
        t_color.b = cast(u8)rl.GetRandomValue(0,255)
        t_color.a = 255
    }
    if rand == 2{
        t_color.r = cast(u8)rl.GetRandomValue(200,255)
        t_color.g = cast(u8)rl.GetRandomValue(0,55)
        t_color.b = cast(u8)rl.GetRandomValue(0,255)
        t_color.a = 255
    }
    return t_color
}
place_food::proc(){
    occupied:[grid_width][grid_width]bool
    rand :=rl.GetRandomValue(0,2)
    if rand == 0{
        food_color.r = cast(u8)rl.GetRandomValue(200,255)
        food_color.g = cast(u8)rl.GetRandomValue(0,255)
        food_color.b = cast(u8)rl.GetRandomValue(0,55)
        food_color.a = 255 
    }
    if rand == 1{
        food_color.r = cast(u8)rl.GetRandomValue(0,55)
        food_color.g = cast(u8)rl.GetRandomValue(200,255)
        food_color.b = cast(u8)rl.GetRandomValue(0,255)
        food_color.a = 255
    }
    if rand == 2{
        food_color.r = cast(u8)rl.GetRandomValue(200,255)
        food_color.g = cast(u8)rl.GetRandomValue(0,55)
        food_color.b = cast(u8)rl.GetRandomValue(0,255)
        food_color.a = 255
    }
    

    for i in 0..<snake_length {
        occupied[snake_segments[i].x][snake_segments[i].y] = true
    }
    free_cells := make([dynamic][2]int,context.temp_allocator)

    for x in 0..<grid_width{
        for y in 0..<grid_width{
            if !occupied[x][y]{
                append(&free_cells,[2]int{x,y})
            }
        }
    }
    if len(free_cells) > 0{
        random_cell_index := rl.GetRandomValue(0,i32(len(free_cells))-1)
        food_pos = free_cells[random_cell_index]
    }
    for i in 0..=10 {
    re.spawn_particle(re.gen_p_food({f32((food_pos.x*cell_size)+(cell_size/2)),f32((food_pos.y*cell_size)+(cell_size/2))},food_color))
    }
}
snake_restart::proc(){
    snake_segments[0] = snake_start_pos
    snake_segments[1] = snake_start_pos-{0,1}
    snake_segments[2] = snake_start_pos-{0,2}
    snake_length = 3
    direction = {0,1}
    game_over = false
    place_food()
    snake_color = gen_color()
}

snake_do::proc(){
    snake_input()

    if game_over {
        if rl.IsKeyPressed(.ENTER){
            snake_restart()
        }
        
    }else{
        tick_timer -= rl.GetFrameTime()
    }

    if tick_timer <= 0 {
        next_part_pos:=snake_segments[0] 
        snake_segments[0] += direction
        
        rand :=rl.GetRandomValue(1,6)
        if rand == 1{ rl.PlaySound(run_sound_1) }
        else if rand == 2{ rl.PlaySound(run_sound_2) }
        else if rand == 3{ rl.PlaySound(run_sound_3) }
        else if rand == 4{ rl.PlaySound(run_sound_4) }
        else if rand == 5{ rl.PlaySound(run_sound_5) }
        else if rand == 6{ rl.PlaySound(run_sound_6) }

        if snake_segments[0].x < 0 {
            game_over = true
        }
        if snake_segments[0].y < 0{
            game_over = true
        }
        if snake_segments[0].x >= grid_width{
            game_over = true
        }
        if snake_segments[0].y >= grid_width{
            game_over = true
        }

        for i in 1..<snake_length{
            cur_pos:= snake_segments[i]

            if cur_pos == snake_segments[0]{
                game_over = true
            }

            snake_segments[i] = next_part_pos
            next_part_pos = cur_pos
        }

        if snake_segments[0] == food_pos{
            for i in 0..=10 {
                re.spawn_particle(re.gen_p_food({f32((food_pos.x*cell_size)+(cell_size/2)),f32((food_pos.y*cell_size)+(cell_size/2))},food_color))
            }
            snake_color = food_color
            snake_length += 1
            snake_segments[snake_length-1] = next_part_pos
            place_food()
            rl.PlaySound(eat_sound)
        }
        if game_over{
            rl.PlaySound(crash_sound)
        }

        tick_timer = tick_rate + tick_timer
    }

    score = snake_length-3
}
snake_input::proc(){
    t_direction:[2]int=direction
    if rl.IsKeyDown(.UP){
        if direction + {0,-1} != {0,0}{ 
            t_direction = {0,-1}
        }
    }else if rl.IsKeyDown(.DOWN){
        if direction + {0,1} != {0,0}{ 
            t_direction = {0,1}
        }
    }else if rl.IsKeyDown(.LEFT){
        if direction + {-1,0} != {0,0}{ 
            t_direction = {-1,0}
        }
    }else if rl.IsKeyDown(.RIGHT){
        if direction + {1,0} != {0,0}{ 
            t_direction = {1,0}
        }
    }
direction = t_direction
}

snake_draw::proc(){
    //food
        re.draw_texture(as.texture_names.food,rl.Rectangle{f32(food_pos.x) * cell_size, f32(food_pos.y) * cell_size, cell_size, cell_size},{0,0},0,food_color)
        
    //snake
    for i in 0..<snake_length{
        sprite:as.texture_names = as.texture_names.body
        dir:[2]int

        if i == 0{
            sprite = as.texture_names.head
            dir = snake_segments[i] - snake_segments[i+1]
        }else if i == snake_length-1{
            sprite = as.texture_names.tail
            dir = snake_segments[i-1] - snake_segments[i]
        }else {
            dir = snake_segments[i-1] - snake_segments[i]
        }

        rot := math.atan2(f32(dir.y),f32(dir.x)) * math.DEG_PER_RAD
        re.draw_texture(sprite,rl.Rectangle{f32(snake_segments[i].x) * cell_size + cell_size * 0.5, f32(snake_segments[i].y) * cell_size+ cell_size * 0.5, cell_size, cell_size},{cell_size,cell_size}*0.5,rot,snake_color)
    }
    //game over text
    if game_over{
        rl.DrawText("Game Over!" ,4 ,4 ,25,rl.RED)
        rl.DrawText("Press Enter to Play Again" ,4 ,30 ,15,rl.BLACK)
    }
    pading:f32=16
    //outline
    rl.DrawRectangleLinesEx(rl.Rectangle{-pading, -pading, canvas_size+pading*2, canvas_size+pading*2},pading,{0,0,40,255})
    //score
    score_str:= fmt.ctprintf("Score: %v",score)
    rl.DrawText(score_str,10,canvas_size-24,15,rl.BLACK)
}

screen_width: i32
screen_height: i32  
center_zoom::proc(){
    bace_pading:i32=32
    screen_width = rl.GetScreenWidth()-bace_pading
    screen_height = rl.GetScreenHeight()-bace_pading
    re.camera.target={cast(f32)-(16),cast(f32)-(16)}
    
    
    if screen_width <= screen_height{
        re.camera.zoom = f32(screen_width)/(canvas_size+f32(bace_pading/2))
        re.camera.offset.y =+ (cast(f32)screen_height - cast(f32)screen_width )/2
    }else{
        re.camera.zoom = f32(screen_height)/(canvas_size+f32(bace_pading/2))
        re.camera.offset.x =+  (cast(f32)screen_width - cast(f32)screen_height)/2
    }
}