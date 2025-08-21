let init () =
  let module G = Gstreamer in
  G.init ()

let destroy () =
  Gstreamer.deinit ();
  Gc.full_major ()

let play_file file =
  let module G = Gstreamer in
  let element = String.concat "" ["playbin uri=\"file://"; file; "\""] in
  let pipeline = G.Pipeline.parse_launch element in
  ignore @@ G.Element.set_state pipeline G.Element.State_playing;
  Unix.sleep 5;
  ignore @@ G.Element.set_state pipeline G.Element.State_null
