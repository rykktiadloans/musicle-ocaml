let init () =
  let module G = Gstreamer in
  G.init ()

let destroy () =
  Gstreamer.deinit ();
  Gc.full_major ()

let get_playbin file = String.concat "" [ "playbin uri=\"file://"; file; "\"" ]

let duration_in_seconds file =
  let module G = Gstreamer in
  let pipeline = G.Pipeline.parse_launch @@ get_playbin file in
  ignore @@ G.Element.set_state pipeline G.Element.State_playing;
  ignore @@ G.Element.get_state pipeline;
  let duration = G.Element.duration pipeline G.Format.Time in
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

let play_file env file =
  play_file_internal env file
