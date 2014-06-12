module type COUNTER_GRAPH = sig
  include Graph.Sig_pack.S

  val init_vertex_counter : int -> unit
  val init_edge_counter : int -> unit

  val get_vertex_label : unit -> int
  val get_edge_label : unit -> int
end

module Make :
  functor (G : COUNTER_GRAPH) ->
  sig
    include COUNTER_GRAPH

    exception TooSmall

    (* val contract : t -> int -> unit *)
    (* val cut : t -> t * int *)
    val prob_min_cut : t -> t * int
    val parse_dot_file : string -> t
  end
