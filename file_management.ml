open Containers

let music_filetypes = [ ".m4a"; ".mp3"; ".flac"; ".wav" ]

let rec get_music_files ?(music_filetypes=music_filetypes) dir =
  let all_files =
    Sys.readdir dir |> Array.map (fun f -> Filename.concat dir f)
  in
  let folders = Array.filter Sys.is_directory all_files in
  let music_files =
    Array.filter (fun f -> not (Array.memq f folders)) all_files
    |> Array.filter (fun f -> List.mem (Filename.extension f) music_filetypes)
  in
  List.concat
    [
      Array.to_list music_files;
      List.flat_map get_music_files (Array.to_list folders);
    ]
