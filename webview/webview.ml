(* Type to represent the webview handle - just a wrapped pointer *)
type t = nativeint

let hint_none = 0
let hint_min = 1
let hint_max = 2
let hint_fixed = 3

external webview_create : int -> unit -> t = "ocaml_webview_create"
let create ?(debug = 0) () = webview_create debug ()

external webview_destroy : t -> int = "caml_webview_destroy"
let destroy webview =
  match webview_destroy webview with 0 -> Ok () | err -> Error err

external webview_terminate : t -> int = "caml_webview_terminate"
let terminate webview =
  match webview_terminate webview with 0 -> Ok () | err -> Error err

external webview_run : t -> int = "caml_webview_run"
let run webview = match webview_run webview with 0 -> Ok () | err -> Error err

external webview_bind : t -> string -> int = "caml_webview_bind"
let bind webview name (fn : string -> string -> unit) =
  let () = Callback.register name fn in
  match webview_bind webview name with 0 -> Ok () | err -> Error err

external webview_eval : t -> string -> int = "caml_webview_eval"
let eval webview js =
  match webview_eval webview js with 0 -> Ok () | err -> Error err

external webview_set_title : t -> string -> int = "caml_webview_set_title"
let set_title webview title =
  match webview_set_title webview title with 0 -> Ok () | err -> Error err

external webview_set_size : t -> int -> int -> int -> int
  = "caml_webview_set_size"
let set_size webview width height hint =
  match webview_set_size webview width height hint with
  | 0 -> Ok ()
  | err -> Error err

external webview_set_html : t -> string -> int = "caml_webview_set_html"
let set_html webview html =
  match webview_set_html webview html with 0 -> Ok () | err -> Error err

