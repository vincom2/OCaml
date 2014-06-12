open Core.Std

(* oh shit, this isn't good at all if I want to have more than one graph
 * created by this module D: *)
(* TODO: CHANGE THIS *)
module Counter_graph : Contractable.COUNTER_GRAPH = struct
  include Graph.Pack.Graph

  let vertex_counter = ref 0
  let edge_counter = ref 0

  let init_vertex_counter n =
    vertex_counter := n

  let init_edge_counter m =
    edge_counter := m

  let get_vertex_label () =
    let curr = !vertex_counter in
    vertex_counter := curr + 1;
    curr

  let get_edge_label () =
    let curr = !edge_counter in
    edge_counter := curr + 1;
    curr
end

module C = Contractable.Make(Counter_graph)
(* lol there actually isn't any point in producing output right now
 * since I don't have a mapping from final edges to initial edges at all.
 * Should "rectify" that... someday? *)
let main infile ?outfile =
  let test = C.parse_dot_file infile in
  let () = C.display_with_gv test in
  let (test',m) = C.prob_min_cut test in
  let () = Printf.printf "w.h.p. a min cut of %s contains %i edge(s)\n" infile m in
  let () = C.display_with_gv test' in
  match outfile with
  | None -> ()
  | Some outfilename -> C.dot_output test' outfilename

(* command line argument stuff *)
let spec =
  let open Command.Spec in
  empty
  +> anon ("filename" %: string)
  +> flag "-o" (optional string) ~doc:"outfile Outputs the final \"graph\" to outfile"

let command =
  Command.basic
    ~summary:"Run Karger's probabilistic min-cut algorithm on a graph"
    spec
    (fun infile outfile () -> main infile ?outfile)

let () = Command.run ~version:"0.1" command
