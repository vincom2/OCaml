(* uses imperative graphs from ocamlgraph *)
(* graphs and edges are integer-labelled because I don't care enough *)
(* this is a crappy implementation that doesn't track any of the
 * original "properties" of the vertices or edges
 * because all I am trying to do is establish the _size_
 * of the min cut *)
(* assumes the original graph provided is simple, connected and undirected
 * and every edge label is unique *)
open Core.Std

module type COUNTER_GRAPH = sig
  include Graph.Sig_pack.S

  val init_vertex_counter : int -> unit
  val init_edge_counter : int -> unit

  val get_vertex_label : unit -> int
  val get_edge_label : unit -> int
end

module Make(G : COUNTER_GRAPH) = struct
  include G

  exception TooSmall

  let contract g l =
    let consider e =
      let u = E.src e
      and v = E.dst e in
      if E.label e = l then
        let v_new = V.create (get_vertex_label ()) in
        (* these could be combined, I suppose, but whatever *)
        let f_u e =
          let l = E.label e in
          let tmp = E.src e in
          let u' = if tmp = u then E.dst e else tmp in
          if u' = v then () else begin
            remove_edge_e g e;
            add_edge_e g (E.create u' l v_new)
          end
        in
        let f_v e =
          let l = E.label e in
          let tmp = E.src e in
          let v' = if tmp = v then E.dst e else tmp in
          if v' = u then () else begin
            remove_edge_e g e;
            add_edge_e g (E.create v' l v_new)
          end
        in
        add_vertex g v_new;
        iter_succ_e f_u g u;
        iter_succ_e f_v g v;
        remove_vertex g u;
        remove_vertex g v
      else ()
    in
    iter_edges_e consider g

  let cut g' =
    let g = copy g' in
    if nb_vertex g < 2 then raise TooSmall else
      while nb_vertex g > 2 do
        let r = Random.int (nb_edges g) in
        (* Printf.printf "%i vertices left, contracting edge %i\n" (nb_vertex g) r; *)
        contract g r
      done;
    (g, nb_edges g)

  let prob_min_cut g =
    let () = Random.self_init () in
    let min_cut = ref Int.max_value
    and min_g = ref g in
    let n = float (nb_vertex g) in
    let stop = Int.of_float ((n**2.) *. (log n)) + 1 in
    for i = 0 to stop do
      let (cut_graph, cut_size) = cut g in
      if cut_size < !min_cut then begin
        min_cut := cut_size;
        min_g := cut_graph
      end
      else ()
    done;
    (!min_g, !min_cut)

  let parse_dot_file filename =
    let g = parse_dot_file filename in
    let do_stuff e =
      let u = E.src e
      and v = E.dst e in
      G.remove_edge_e g e;
      G.add_edge_e g (E.create u (get_edge_label ()) v)
    in
    iter_edges_e do_stuff g;
    init_vertex_counter (G.nb_vertex g + 1);
    g
end
