type level =
  | Fatal
  | Error
  | Warn
  | Info
  | Debug
  | Trace

val set_state : level -> unit

val fatal : string -> unit
val error : string -> unit
val warn : string -> unit
val info : string -> unit
val debug : string -> unit
val trace : string -> unit
