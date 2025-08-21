(*open Containers*)

let music_directory = "/home/rykktiadloans/Music"

let () =
  Logging.set_state Logging.Debug;
  Random.init @@ Float.to_int @@ Unix.time ();
  Audio.init ();

  let files = File_management.get_music_files music_directory in
  let file_to_play = Random.int (List.length files) |> List.nth files in
  Audio.play_file file_to_play;
  Audio.destroy ()
