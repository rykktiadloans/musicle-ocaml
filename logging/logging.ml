type level =
  | Fatal
  | Error
  | Warn
  | Info
  | Debug
  | Trace

let level_state = ref Info

let get_prefix = function
  | Fatal -> "[FATAL] "
  | Error -> "[ERROR] "
  | Warn -> "[WARN ] "
  | Info -> "[INFO ] "
  | Debug -> "[DEBUG] "
  | Trace -> "[TRACE] "

let get_order = function
  | Fatal -> 0
  | Error -> 1
  | Warn -> 2
  | Info -> 3
  | Debug -> 4
  | Trace -> 5

let set_state state = level_state := state

let log asked_state message =
  if get_order !level_state >= get_order asked_state then
    print_string @@ (get_prefix asked_state) ^ message ^ "\n"

let fatal message = log Fatal message
let error message = log Error message
let warn message = log Warn message
let info message = log Info message
let debug message = log Debug message
let trace message = log Trace message
