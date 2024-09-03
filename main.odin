package snake


import as "assets"
import re"rendering"
import "core:fmt"
import rl "vendor:raylib"


eat_sound :rl.Sound
crash_sound :rl.Sound
run_sound_1:rl.Sound
run_sound_2:rl.Sound
run_sound_3:rl.Sound
run_sound_4:rl.Sound
run_sound_5:rl.Sound
run_sound_6:rl.Sound

up:bool

main :: proc() {
    rl.SetConfigFlags({.WINDOW_RESIZABLE})
    rl.InitWindow(880, 880, "test")
    rl.InitAudioDevice()
    rl.SetTargetFPS(120)
    re.init_camera()
    as.init_texturs()
    as.int_shaders()

    snake_setup()

    eat_sound = rl.LoadSoundFromWave(rl.LoadWaveFromMemory(".wav",&as.all_sounds[as.sound_names.eat].data[0],cast(i32)(len(as.all_sounds[as.sound_names.eat].data))))
    crash_sound = rl.LoadSoundFromWave(rl.LoadWaveFromMemory(".wav",&as.all_sounds[as.sound_names.s_pop].data[0],cast(i32)(len(as.all_sounds[as.sound_names.s_pop].data))))
    run_sound_1 = rl.LoadSoundFromWave(rl.LoadWaveFromMemory(".wav",&as.all_sounds[as.sound_names.running_1].data[0],cast(i32)(len(as.all_sounds[as.sound_names.running_1].data))))
    run_sound_2 = rl.LoadSoundFromWave(rl.LoadWaveFromMemory(".wav",&as.all_sounds[as.sound_names.running_2].data[0],cast(i32)(len(as.all_sounds[as.sound_names.running_2].data))))
    run_sound_3 = rl.LoadSoundFromWave(rl.LoadWaveFromMemory(".wav",&as.all_sounds[as.sound_names.running_3].data[0],cast(i32)(len(as.all_sounds[as.sound_names.running_3].data))))
    run_sound_4 = rl.LoadSoundFromWave(rl.LoadWaveFromMemory(".wav",&as.all_sounds[as.sound_names.running_4].data[0],cast(i32)(len(as.all_sounds[as.sound_names.running_4].data))))
    run_sound_5 = rl.LoadSoundFromWave(rl.LoadWaveFromMemory(".wav",&as.all_sounds[as.sound_names.running_5].data[0],cast(i32)(len(as.all_sounds[as.sound_names.running_5].data))))
    run_sound_6 = rl.LoadSoundFromWave(rl.LoadWaveFromMemory(".wav",&as.all_sounds[as.sound_names.running_6].data[0],cast(i32)(len(as.all_sounds[as.sound_names.running_6].data))))

    light_flicer:f32

  
    for (!rl.WindowShouldClose()) 
    {
        if light_flicer <10 && up{
            light_flicer+=0.1
        }else{
            up = false
        }
        if light_flicer >0 && !up{
            light_flicer-=0.1

        }else{
            up = true
        }
        center_zoom()

        re.maintane_masks()
        rl.BeginTextureMode(re.light_mask)
        rl.BeginBlendMode(rl.BlendMode.ADDITIVE)     
        re.calculate_particles_light()
        // re.draw_simple_light({50,50},50)
        // re.draw_simple_light({150,150},50)
        // re.draw_simple_light({300,300},50)
        re.draw_colored_light({f32(food_pos.x) * cell_size + (cell_size/2), f32(food_pos.y) * cell_size + (cell_size/2)},33+light_flicer,{255,255,100,200})
        rl.EndBlendMode()
        rl.EndTextureMode()

        snake_do()

        rl.BeginDrawing()
        rl.ClearBackground({72,72,117,255})
        rl.BeginMode2D(re.camera)
            // if rl.IsMouseButtonDown(.LEFT) {
            //     for i in 0..=1 {
            //     particle :re.Particle = re.gen_p_confetti(rl.GetScreenToWorld2D(rl.GetMousePosition(), re.camera))
            //     re.spawn_particle(particle)
            //     }
            // }
        // if rl.IsMouseButtonDown(.RIGHT) {
        //     delta:rl.Vector2 = rl.GetMouseDelta()
        //     delta = (delta * -1.0/re.camera.zoom)
        //     re.camera.target += delta
        // }

        
        snake_draw()
        //re.do_particle_mask()
        rl.EndMode2D()
        re.calculate_particles()
        re.do_lighting()
        //rl.DrawFPS(10, 10)
        rl.EndDrawing()
        free_all(context.temp_allocator)
    }
    rl.CloseAudioDevice()
    rl.CloseWindow()
 
}
