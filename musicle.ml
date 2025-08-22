(*open Containers*)

let music_directory = "/home/rykktiadloans/Music"
let clearline = "\027[0K"
let print env str = Eio.Flow.copy_string str (Eio.Stdenv.stdout env)

let rec print_time_remaining env time : unit =
  if time = 0 then
    print env "\027[0KDone!\n"
  else
    let operate =
     fun () ->
      print env @@ Printf.sprintf "\027[0K%d seconds remaining!\r" time;
      Eio.Time.Timeout.sleep
      @@ Eio.Time.Timeout.seconds (Eio.Stdenv.mono_clock env) 1.0;
      print_time_remaining env (time - 1)
    in
    operate ()

let single_round env files =
  let file_to_play = Random.int (List.length files) |> List.nth files in
  Eio.Fiber.both
    (fun () -> Audio.play_file env file_to_play)
    (fun () -> print_time_remaining env 5);
  print env "Press enter to reveal the track";
  ignore @@ read_line ();
  let filename = Filename.basename file_to_play |> Filename.remove_extension in
  print env ("The track was " ^ filename)

let () =
  Logging.set_state Logging.Debug;
  Random.init @@ Float.to_int @@ Unix.time ();
  Audio.init ();

  let files = File_management.get_music_files music_directory in
  Eio_main.run @@ (fun _env ->
  single_round _env files);
  Audio.destroy ()
