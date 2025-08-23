(*open Containers*)
open Database

exception Wrong_command of string

type commands =
  | Set_music_dir
  | Once
  | Many

let get_command () =
  if Array.length Sys.argv < 2 then (
    print_string "No command supplied!\n";
    exit 0)
  else
    match Sys.argv.(1) with
    | "set_music_dir" -> Set_music_dir
    | "once" -> Once
    | "many" -> Many
    | any ->
        let error = Printf.sprintf "%s is not a valid command" any in
        raise @@ Wrong_command error

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

let single_round files env =
  let file_to_play = Random.int (List.length files) |> List.nth files in
  Eio.Fiber.both
    (fun () -> Audio.play_file env file_to_play)
    (fun () -> print_time_remaining env 5);
  print env "Press enter to reveal the track";
  ignore @@ read_line ();
  let filename = Filename.basename file_to_play |> Filename.remove_extension in
  print env ("The track was " ^ filename ^ "\n")

let rec play_many env files =
  single_round files env;
  print env "Play again? (Y/n) : ";
  let res = read_line () |> String.lowercase_ascii in
  if List.mem res [ "y"; "yes" ] then
    play_many env files

let set_music_dir conn =
  if Array.length Sys.argv < 3 then
    print_string "The second argument should be the music directory\n"
  else
    let music_dir = Sys.argv.(2) in
    let does_exist = Sys.file_exists music_dir in
    let is_directory = Sys.is_directory music_dir in
    match (does_exist, is_directory) with
    | false, _ ->
        let error = Printf.sprintf "'%s' does not exist!" music_dir in
        print_string error
    | _, false ->
        let error = Printf.sprintf "'%s' is not a directory!" music_dir in
        print_string error
    | true, true ->
        ignore @@ Settings.set conn Settings.Music_dir music_dir;
        print_string "Saved!"

let no_music_dir () =
  print_string "No music directory is set! Try the 'set_music_dir' command\n";
  exit 0

let ensure_music_dir_exists conn =
  if Option.is_none @@ Settings.get conn Music_dir then
    no_music_dir ()

let choose command conn =
  match command with
  | Set_music_dir -> set_music_dir conn
  | Once ->
      ensure_music_dir_exists conn;
      let files =
        File_management.get_music_files @@ Settings.get_exn conn Music_dir
      in
      Eio_main.run @@ fun _env -> single_round files _env
  | Many ->
      ensure_music_dir_exists conn;
      Eio_main.run @@ fun _env ->
      let files =
        File_management.get_music_files @@ Settings.get_exn conn Music_dir
      in
      play_many _env files

let () =
  Logging.set_state Logging.Debug;
  Random.init @@ Float.to_int @@ Unix.time ();
  Audio.init ();
  let command = get_command () in
  let conn = Conn.init () in
  choose command conn;
  Audio.destroy ()
