(* Type to represent the webview handle - just a wrapped pointer *)
type t

val hint_none : int
val hint_min : int
val hint_max : int
val hint_fixed : int
val create : ?debug:int -> unit -> t
val destroy : t -> (unit, int) result
val terminate : t -> (unit, int) result
val run : t -> (unit, int) result
val bind : t -> string -> (string -> string -> unit) -> (unit, int) result
val eval : t -> string -> (unit, int) result
val set_title : t -> string -> (unit, int) result
val set_size : t -> int -> int -> int -> (unit, int) result
val set_html : t -> string -> (unit, int) result
