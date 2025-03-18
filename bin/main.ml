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
    <button id="logButton">Click to get data</button>
    <div id="output">Output</div>
    <input />

    <script>
      const traceln =  (msg) =>  {window.BINDER("", "log", msg)}

        document.getElementById('logButton').addEventListener('click', async function() {
          traceln("Before callNative")
            const response = await callNative('getData', {"id": 99});
          traceln("After callNative")
            document.getElementById("output").innerHTML =response.result
          traceln("After modification")
        });
        traceln("before creating registry")

        const promiseRegistry = {};
        let nextRequestId = 0;
        traceln("after creating registry")

        // Function to call native OCaml code
        function callNative(methodName, params = {}) {
            traceln("making id")
          const requestId = `req_${nextRequestId++}`;
            traceln(`creating promise for id ${requestId}`)
  
          // Create a promise for this request
          const promise = new Promise((resolve, reject) => {
            // Store the resolve/reject functions with the request ID
            promiseRegistry[requestId] = { resolve, reject };
    
            // Set a timeout to prevent hanging promises
            setTimeout(() => {
              if (promiseRegistry[requestId]) {
                reject(new Error(`Request ${methodName} timed out`));
                delete promiseRegistry[requestId];
              }
            }, 30000);

            traceln("end of promise creation")
          });
  
          // Call directly into OCaml
            traceln("calling binder")
          window.BINDER(requestId, methodName, JSON.stringify(params));
  
            traceln("returning promise")
          return promise;
        }

        // Function that OCaml can call via EVAL
        function handleNativeResponse(requestId, data, error) {
          // Look up the promise in our registry
            traceln("looking for promise")

          if (promiseRegistry[requestId]) {
            const { resolve, reject } = promiseRegistry[requestId];
            traceln("found promise")

            if (error) {
            traceln("error")
              reject(error);
            } else {
            traceln("resolve")
              resolve(data);
            }
            traceln("clean up")
    
            // Clean up
            delete promiseRegistry[requestId];
          }
        }

        traceln("binding the function to the window")
        window.handleNativeResponse = handleNativeResponse;

    </script>
</body>
</html>
|}

type request = { request : string list } [@@deriving yojson]
type command = { request_id : string; operation : string; args : string }

let parse_bind args : command =
  let json =
    Printf.sprintf {| {"request": %s} |} args |> Yojson.Safe.from_string
  in
  let parsed =
    request_of_yojson json
    |> Result.map_error (fun e -> print_endline @@ "failed to parse: " ^ e)
    |> Result.get_ok
  in
  match parsed with
  | { request = [ request_id; operation; args ] } ->
      { request_id; operation; args }
  | _ -> failwith "wrong number of args"

let get_data _args =
  let s = string_of_int (Random.bits ()) ^ string_of_int (Random.bits ()) in
  Printf.sprintf {| {"result": "%s"} |} s

let router operation args =
  match operation with
  | "getData" ->
      Unix.sleep 5;
      get_data args
  | "log" -> args
  | _ -> failwith "unknown operation"

let main _env =
  let webview = Webview.create () in

  (* Configure the webview *)
  let _ = Webview.set_title webview "Test" in
  let _ = Webview.set_size webview 600 480 Webview.hint_none in
  (* let _ = Webview.set_html webview html_content in *)
  let _ = Webview.set_html webview bind_test in
  print_endline "Webview configured";

  let jobs = Stream.create max_int in

  let _worker_domain =
    Domain.spawn (fun () ->
    traceln "started worker domain";
        while true do
          match Stream.take_nonblocking jobs with
          | Some { request_id; operation; args } ->
              traceln "inputs: %s\n%s\n%s" request_id operation args;
              let data = router operation args in
              traceln "data: %s" data;
              let eval_string =
                Printf.sprintf {|window.handleNativeResponse("%s", %s, null)|}
                  request_id data
              in
              traceln "Eval string %s" eval_string;
              let _ =
                Webview.eval webview eval_string
                |> Result.iter_error (fun _ -> traceln "Error")
              in
              ()
          | None ->
              (* If the stream is empty, add a small delay to avoid busy waiting *)
              Unix.sleepf 0.01
        done)
  in
  (match
     Webview.bind webview "BINDER" (fun _ req ->
         (* traceln "Hello there from js: %s %s" id req; *)
         let cmd = parse_bind req in
         Stream.add jobs cmd;
         traceln "Stream length %i" @@ Stream.length jobs)
   with
  | Ok () -> print_endline "Webview bound successfully."
  | Error code -> Printf.printf "Error binding webview: %i\n" code);


  (* Run the webview in the main fiber *)
  print_endline "Running webview...";
  let _ = Webview.run webview in
  print_endline (Printf.sprintf "Webview exited with result")

let () = Eio_main.run main
