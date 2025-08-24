let init () =
  let module G = Gstreamer in
  G.init ()

let destroy () =
  Gstreamer.deinit ();
  Gc.full_major ()

let get_playbin file = String.concat "" [ "playbin uri=\"file://"; file; "\"" ]

let get_tags file =
  let module G = Gstreamer in
  let element = get_playbin file in
  let pipeline = G.Pipeline.parse_launch element in
  ignore @@ G.Element.set_state pipeline G.Element.State_paused;
  ignore @@ G.Element.get_state pipeline;
  let msg = G.Bus.pop_filtered (G.Bus.of_element pipeline) [ `Tag ] in
  let ret =
    match msg with
    | None -> []
    | Some msg -> (
        match msg.payload with
        | `Tag tags -> tags
        | _ -> [])
  in
  ignore @@ G.Element.set_state pipeline G.Element.State_null;
  ret

let get_tag tag tags =
  match List.find_opt (fun (key, _) -> String.equal tag key) tags with
  | None -> None
  | Some (_, value) -> Some (String.concat "" value)

let get_author = get_tag "author"
let get_album = get_tag "album"
let get_title = get_tag "title"

let duration_in_seconds file =
  let module G = Gstreamer in
  let pipeline = G.Pipeline.parse_launch @@ get_playbin file in
  ignore @@ G.Element.set_state pipeline G.Element.State_playing;
  ignore @@ G.Element.get_state pipeline;
  let duration =
    try G.Element.duration pipeline G.Format.Time with G.Failed -> 10000000000L
  in
  ignore @@ G.Element.set_state pipeline G.Element.State_null;
  Int64.to_int @@ Int64.div duration 1000000000L

let play_file_internal env file =
  let module G = Gstreamer in
  let duration_max = duration_in_seconds file - 5 in
  let starting_point = Random.int duration_max in
  let starting_point_64 =
    Int64.mul 1000000000L @@ Int64.of_int starting_point
  in
  let element = get_playbin file in
  let pipeline = G.Pipeline.parse_launch element in
  ignore @@ G.Element.set_state pipeline G.Element.State_playing;
  ignore @@ G.Element.get_state pipeline;
  G.Element.seek_simple pipeline G.Format.Time
    [ G.Event.Seek_flag_flush ]
    starting_point_64;
  let clock = Eio.Stdenv.mono_clock env in
  Eio.Time.Timeout.sleep @@ Eio.Time.Timeout.seconds clock 5.0;
  ignore @@ G.Element.set_state pipeline G.Element.State_null

let play_file env file = play_file_internal env file
