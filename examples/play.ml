(*
 * play.ml
 * -------
 * Copyright : (c) 2011, Jeremie Dimino <jeremie@dimino.org>
 * Licence   : BSD3
 *
 * This file is a part of ocaml-spotify.
 *)

open Spotify

let () =
  print_endline "\
This example use the pacat program (from pulseaudio) to play music.
If you do not have it, no music will be played.

Type Control+C to stop.
"

(* Setup the PIPE with pacat. *)
let fdr, fdw = Unix.pipe ()
let () =
  if Unix.fork () = 0 then begin
    Unix.dup2 fdr Unix.stdin;
    Unix.close fdr;
    Unix.close fdw;
    try
      Unix.execvp "pacat" [|"pacat"; "--rate=44100"; "--format=s16ne"; "--channels=2"|]
    with _ ->
      exit 127
  end else begin
    Unix.close fdr;
    Unix.set_nonblock fdw
  end

(* Callbacks for spotify. *)
class callbacks = object
  inherit session_callbacks

  (* Deliver music to pacat. *)
  method music_delivery session format frames count =
    if format <> { sample_rate = 44100; sample_type = SAMPLETYPE_INT16_NATIVE_ENDIAN; channels = 2 } then begin
      prerr_endline "unsupported audio format";
      count
    end else if count > 0 then begin
      try
        Unix.write fdw (string_of_bytes frames) 0 (count * 4) / 4
      with
        | Unix.Unix_error (Unix.EAGAIN, _, _) ->
            0
        | Unix.Unix_error (err, _, _) ->
            Printf.eprintf "unix error: %s\n%!" (Unix.error_message err);
            0
    end else
      0

  (* Output log message to stderr. *)
  method log_message session message =
    output_string stderr message;
    flush stderr
end

(* Configuration of the client. *)
let config = {
  api_version = api_version;
  cache_location = "";
  settings_location = "";
  application_key = Appkey.appkey;
  user_agent = "ocaml-spotify play example";
  callbacks = new callbacks;
  compress_playlists = false;
  dont_save_metadata_for_playlists = true;
  initially_unload_playlists = true;
}

let () =
  if Array.length Sys.argv <> 4 then begin
    prerr_endline "Usage: play <username> <password> <track title>";
    exit 2
  end;

  try
    (* Create the session. *)
    let session = session_create config in

    (* Do authentication. *)
    session_login session ~username:Sys.argv.(1) ~password:Sys.argv.(2) ~remember_me:false;

    (* Deauthenticate on exit. *)
    at_exit (fun () -> session_logout session);

    (* Create a search query. *)
    let search =
      search_create session
        ~query:Sys.argv.(3)
        ~track_offset:0
        ~track_count:100
        ~album_offset:0
        ~album_count:100
        ~artist_offset:0
        ~artist_count:0
        ~callback:ignore
    in

    (* Wait for the search to terminate. *)
    while not (search_is_loaded search) do
      ignore (Unix.select [] [] [] 0.01);
      ignore (session_process_events session);
    done;

    let count = search_num_tracks search in

    (* Print informations. *)
    Printf.printf "%d tracks found.\n%!" count;

    if count > 0 then begin
      (* Get the track. *)
      let track = search_track search 0 in

      (* Release the search now. *)
      search_release search;

      (* Load the track. *)
      session_player_load session track;

      (* Wait for the track metadata to be loaded. *)
      while not (track_is_loaded track) do
        ignore (Unix.select [] [] [] 0.01);
        ignore (session_process_events session);
      done;

      Printf.printf "playing '%s'\n%!" (track_name track);

      (* Play. *)
      session_player_play session true;

      while true do
        ignore (Unix.select [] [] [] 0.01);
        ignore (session_process_events session)
      done
    end

  with Error (func, err) ->
    Printf.eprintf "%s: %s\n" func (error_message err);
    exit 1
