type t = Music_dir

val get : Conn.t -> t -> string option

val get_exn : Conn.t -> t -> string

val set : Conn.t -> t -> string -> t * string
