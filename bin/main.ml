open Eio
let () = print_endline "Hello, World!"

(* let html_content = *)
(* In_channel.with_open_text "/Users/brodylittle/Git/manual_webview/index.html" *)
(* (fun ic -> In_channel.input_all ic) *)

let bind_test =
  {|
<!DOCTYPE html>
<html>
<head>
    <title>Console Log Button</title>
</head>
<body>
    <button id="logButton">Click to Log Message</button>

    <script>
        document.getElementById('logButton').addEventListener('click', function() {
            window.BINDER("arg1", "arg2");
        });
        function createTile() {
            // Create a div element for the tile
            const tile = document.createElement('div');
            // Set basic properties to make it visible as a tile
            tile.style.width = '100px';
            tile.style.height = '100px';
            tile.style.backgroundColor = 'blue';
            tile.style.marginBottom = '10px';
            // Add an identifier
            tile.id = 'createdTile';
            
            // Get the button
            const button = document.getElementById('logButton');
            // Insert the tile before the button
            button.parentNode.insertBefore(tile, button);
            
            console.log('Tile created above button');
        }
    </script>
</body>
</html>
|}

let main _env =
  Switch.run @@ fun _sw ->
  let webview = Webview.create () in

  (* Configure the webview *)
  let _ = Webview.set_title webview "Test" in
  let _ = Webview.set_size webview 480 320 Webview.hint_none in
  (* let _ = Webview.set_html webview html_content in *)
  let _ = Webview.set_html webview bind_test in
  print_endline "Webview configured";
  (match
     Webview.bind webview "BINDER" (fun id req ->
         traceln "Hello there from js: %s %s" id req;
         let _ = Webview.eval webview "createTile()" in
         traceln "Done executing")
   with
  | Ok () -> print_endline "Webview bound successfully."
  | Error code -> Printf.printf "Error binding webview: %i\n" code);

  (* Use Eio.Domain to run in a separate OS thread *)
  (* let _ = *)
  (* Domain.spawn (fun () -> *)
  (* print_endline "Domain thread started, sleeping for 5 seconds..."; *)
  (* Unix.sleep 5; *)
  (* print_endline "Domain thread binding webview..."; *)
  (* match Webview.bind webview "testbinder" (fun _id _req -> traceln "Hello there from js") with *)
  (* | Ok () -> print_endline "Webview bound successfully." *)
  (* | Error code -> Printf.printf "Error binding webview: %i\n" code *)
  (* ) *)
  (* in *)

  (* Run the webview in the main fiber *)
  print_endline "Running webview...";
  let _ = Webview.run webview in
  print_endline (Printf.sprintf "Webview exited with result")

let () = Eio_main.run main

(* let f x = *)
(* print_string "f is applied to "; *)
(* print_int x; *)
(* print_newline () *)

(* let () = Webview.apply f "test_fun" 88 |> Result.iter_error (Printf.printf "executed callback result is: %i") *)
