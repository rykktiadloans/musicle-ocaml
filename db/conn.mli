type t 

val init : unit -> t

val to_db: t -> Sqlite3.db
