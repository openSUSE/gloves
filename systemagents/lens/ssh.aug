(*
Module: Ssh
  Parses /etc/ssh/ssh_config

*)

module Ssh =
    autoload xfm

    let eol = del /[ \t]*\n/ "\n"
    let spc = Util.del_ws_spc

    let key_re = /[A-Za-z0-9]+/
               - /SendEnv|Host/

    let comment = Util.comment
    let empty = Util.empty
    let indent = del /[ \t]*/ ""
    let value_to_eol = store /([^ \t\n].*[^ \t\n]|[^ \t\n])/
    let value_to_spc = store /[^ \t\n]+/

    let array_entry (k:string) =
	[ key k . [ spc . seq k . value_to_spc]* . eol ]

    let send_env = array_entry "SendEnv"

    let other_entry =
	[ indent . key key_re . spc . value_to_spc . eol ]

    let entry = (comment | empty | send_env | other_entry)

    let host = [ key "Host" . spc . value_to_eol . eol . entry* ]

    let lns = (comment | empty) * . host*

    let xfm = transform lns (incl "/etc/ssh/ssh_config")
