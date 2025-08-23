type t = Sqlite3.db

let to_db (conn:t) : Sqlite3.db = conn 

let settings_schema =
  "CREATE TABLE IF NOT EXISTS settings ("
  ^ "key TEXT PRIMARY KEY, value TEXT NOT NULL)"

let _init path =
  let conn = Sqlite3.db_open path in
  ignore @@ Sqlite3.exec conn settings_schema;
  conn

let init () =
  let home = Unix.getenv "HOME" in
  let musicle_dir = Filename.concat home ".musicle" in
  let musicle_db = Filename.concat musicle_dir "musicle.db" in
  if not @@ Sys.file_exists musicle_dir then
    Unix.mkdir musicle_dir 0o777;
  _init musicle_db
