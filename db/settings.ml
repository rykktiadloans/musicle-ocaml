type t = Music_dir

exception Setting_not_found of string

let to_string = function
  | Music_dir -> "music_dir"

let select_statement = "SELECT value FROM settings WHERE key IS ?"

let insert_statement = "INSERT OR REPLACE INTO settings (key, value) VALUES (?, ?)"

let get conn setting =
  let db = Conn.to_db conn in
  let setting_str = to_string setting in
  let select = Sqlite3.prepare db select_statement in
  ignore @@ Sqlite3.reset select;
  ignore @@ Sqlite3.bind select 1 (Sqlite3.Data.opt_text @@ Some setting_str);
  if Sqlite3.step select = Sqlite3.Rc.ROW then
    let res = Sqlite3.column_text select 0 in
    if res == "" then
      None
    else
      Some res
  else
    None

let get_exn db setting =
  let setting_str = to_string setting in
  match get db setting with
  | Some res -> res
  | None ->
      let error = Printf.sprintf "Setting %s is not set" setting_str in
      raise @@ Setting_not_found error

let set conn setting value =
  let db = Conn.to_db conn in
  let setting_str = to_string setting in
  let insert = Sqlite3.prepare db insert_statement in
  ignore @@ Sqlite3.reset insert;
  ignore @@ Sqlite3.bind insert 1 (Sqlite3.Data.opt_text @@ Some setting_str);
  ignore @@ Sqlite3.bind insert 2 (Sqlite3.Data.opt_text @@ Some value);
  (setting, value)
