(*
 * play.ml
 * -------
 * Copyright : (c) 2011, Jeremie Dimino <jeremie@dimino.org>
 * Licence   : BSD3
 *
 * This file is a part of ocaml-spotify.
 *)

open Spotify

class callbacks = object
  inherit session_callbacks

  method music_delivery session format frames count =
    Printf.printf "%d\n%!" (Bigarray.Array1.dim frames);
    count

  method log_message session message =
    output_string stderr message;
    flush stderr
end

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
    prerr_endline "Usage: play <username> <password> <track>";
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

      (* Load the track. *)
      session_player_load session track;

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
