val init : unit -> unit
val destroy : unit -> unit

val play_file :
  < mono_clock : [> Eio.Time.Mono.ty ] Eio.Resource.t
  ; stdout : [> Eio.Flow.sink_ty ] Eio.Resource.t
  ; .. > ->
  string ->
  unit

val get_tags : string -> (string * string list) list
val get_tag : string -> (string * string list) list -> string option
val get_author : (string * string list) list -> string option
val get_album : (string * string list) list -> string option
val get_title : (string * string list) list -> string option
