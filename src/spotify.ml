(*
 * spotify.ml
 * ----------
 * Copyright : (c) 2011, Jeremie Dimino <jeremie@dimino.org>
 * Licence   : BSD3
 *
 * This file is a part of ocaml-spotify.
 *)

(* Force initialization of the thread machinery. *)
let _ = Thread.self ()

(* +-----------------------------------------------------------------+
   | Spotify types                                                   |
   +-----------------------------------------------------------------+ *)

type session
type track
type album
type artist
type artistbrowse
type albumbrowse
type toplistbrowse
type search
type link
type image
type user
type playlist
type playlistcontainer
type inbox

(* +-----------------------------------------------------------------+
   | Error handling                                                  |
   +-----------------------------------------------------------------+ *)

exception NULL

let () = Callback.register_exception "spotify:null" NULL

type error =
  | ERROR_OK
  | ERROR_BAD_API_VERSION
  | ERROR_API_INITIALIZATION_FAILED
  | ERROR_TRACK_NOT_PLAYABLE
  | ERROR_BAD_APPLICATION_KEY
  | ERROR_BAD_USERNAME_OR_PASSWORD
  | ERROR_USER_BANNED
  | ERROR_UNABLE_TO_CONTACT_SERVER
  | ERROR_CLIENT_TOO_OLD
  | ERROR_OTHER_PERMANENT
  | ERROR_BAD_USER_AGENT
  | ERROR_MISSING_CALLBACK
  | ERROR_INVALID_INDATA
  | ERROR_INDEX_OUT_OF_RANGE
  | ERROR_USER_NEEDS_PREMIUM
  | ERROR_OTHER_TRANSIENT
  | ERROR_IS_LOADING
  | ERROR_NO_STREAM_AVAILABLE
  | ERROR_PERMISSION_DENIED
  | ERROR_INBOX_IS_FULL
  | ERROR_NO_CACHE
  | ERROR_NO_SUCH_USER
  | ERROR_NO_CREDENTIALS

exception Error of string * error

let () = Callback.register_exception "spotify:error" (Error ("", ERROR_OK))

let () =
  Printexc.register_printer
    (function
       | Error (func, err) ->
           Some
             (Printf.sprintf "Error (%S, %s)"
                func
                (match err with
                   | ERROR_OK -> "ERROR_OK"
                   | ERROR_BAD_API_VERSION -> "ERROR_BAD_API_VERSION"
                   | ERROR_API_INITIALIZATION_FAILED -> "ERROR_API_INITIALIZATION_FAILED"
                   | ERROR_TRACK_NOT_PLAYABLE -> "ERROR_TRACK_NOT_PLAYABLE"
                   | ERROR_BAD_APPLICATION_KEY -> "ERROR_BAD_APPLICATION_KEY"
                   | ERROR_BAD_USERNAME_OR_PASSWORD -> "ERROR_BAD_USERNAME_OR_PASSWORD"
                   | ERROR_USER_BANNED -> "ERROR_USER_BANNED"
                   | ERROR_UNABLE_TO_CONTACT_SERVER -> "ERROR_UNABLE_TO_CONTACT_SERVER"
                   | ERROR_CLIENT_TOO_OLD -> "ERROR_CLIENT_TOO_OLD"
                   | ERROR_OTHER_PERMANENT -> "ERROR_OTHER_PERMANENT"
                   | ERROR_BAD_USER_AGENT -> "ERROR_BAD_USER_AGENT"
                   | ERROR_MISSING_CALLBACK -> "ERROR_MISSING_CALLBACK"
                   | ERROR_INVALID_INDATA -> "ERROR_INVALID_INDATA"
                   | ERROR_INDEX_OUT_OF_RANGE -> "ERROR_INDEX_OUT_OF_RANGE"
                   | ERROR_USER_NEEDS_PREMIUM -> "ERROR_USER_NEEDS_PREMIUM"
                   | ERROR_OTHER_TRANSIENT -> "ERROR_OTHER_TRANSIENT"
                   | ERROR_IS_LOADING -> "ERROR_IS_LOADING"
                   | ERROR_NO_STREAM_AVAILABLE -> "ERROR_NO_STREAM_AVAILABLE"
                   | ERROR_PERMISSION_DENIED -> "ERROR_PERMISSION_DENIED"
                   | ERROR_INBOX_IS_FULL -> "ERROR_INBOX_IS_FULL"
                   | ERROR_NO_CACHE -> "ERROR_NO_CACHE"
                   | ERROR_NO_SUCH_USER -> "ERROR_NO_SUCH_USER"
                   | ERROR_NO_CREDENTIALS -> "ERROR_NO_CREDENTIALS"))
       | _ ->
           None)

external error_message : error -> string = "ocaml_spotify_error_message"

(* +-----------------------------------------------------------------+
   | NULL checking                                                   |
   +-----------------------------------------------------------------+ *)

external session_is_null : session -> bool = "ocaml_spotify_is_null" "noalloc"
external track_is_null : track -> bool = "ocaml_spotify_is_null" "noalloc"
external album_is_null : album -> bool = "ocaml_spotify_is_null" "noalloc"
external artist_is_null : artist -> bool = "ocaml_spotify_is_null" "noalloc"
external artistbrowse_is_null : artistbrowse -> bool = "ocaml_spotify_is_null" "noalloc"
external albumbrowse_is_null : albumbrowse -> bool = "ocaml_spotify_is_null" "noalloc"
external toplistbrowse_is_null : toplistbrowse -> bool = "ocaml_spotify_is_null" "noalloc"
external search_is_null : search -> bool = "ocaml_spotify_is_null" "noalloc"
external link_is_null : link -> bool = "ocaml_spotify_is_null" "noalloc"
external image_is_null : image -> bool = "ocaml_spotify_is_null" "noalloc"
external user_is_null : user -> bool = "ocaml_spotify_is_null" "noalloc"
external playlist_is_null : playlist -> bool = "ocaml_spotify_is_null" "noalloc"
external playlistcontainer_is_null : playlistcontainer -> bool = "ocaml_spotify_is_null" "noalloc"
external inbox_is_null : inbox -> bool = "ocaml_spotify_is_null" "noalloc"

(* +-----------------------------------------------------------------+
   | Session handling                                                |
   +-----------------------------------------------------------------+ *)

external get_api_version : unit -> int = "ocaml_spotify_get_api_version" "noalloc"
let api_version = get_api_version ()

type connection_state =
  | CONNECTION_STATE_LOGGED_OUT
  | CONNECTION_STATE_LOGGED_IN
  | CONNECTION_STATE_DISCONNECTED
  | CONNECTION_STATE_UNDEFINED
  | CONNECTION_STATE_OFFLINE

type sample_type =
  | SAMPLETYPE_INT16_NATIVE_ENDIAN

type audio_format = {
  sample_type : sample_type;
  sample_rate : int;
  channels : int;
}

type bitrate =
  | BITRATE_160k
  | BITRATE_320k
  | BITRATE_96k

type playlist_type =
  | PLAYLIST_TYPE_PLAYLIST
  | PLAYLIST_TYPE_START_FOLDER
  | PLAYLIST_TYPE_END_FOLDER
  | PLAYLIST_TYPE_PLACEHOLDER

type playlist_offline_status =
  | PLAYLIST_OFFLINE_STATUS_NO
  | PLAYLIST_OFFLINE_STATUS_YES
  | PLAYLIST_OFFLINE_STATUS_DOWNLOADING
  | PLAYLIST_OFFLINE_STATUS_WAITING

type audio_buffer_stats = {
  samples : int;
  stutter : int;
}

type bytes = (char, Bigarray.int8_unsigned_elt, Bigarray.c_layout) Bigarray.Array1.t

external string_of_bytes : bytes -> string = "ocaml_spotify_string_of_bytes"

type connection_type =
  | CONNECTION_TYPE_UNKNOWN
  | CONNECTION_TYPE_NONE
  | CONNECTION_TYPE_MOBILE
  | CONNECTION_TYPE_MOBILE_ROAMING
  | CONNECTION_TYPE_WIFI
  | CONNECTION_TYPE_WIRED

type connection_rules =
  | CONNECTION_RULE_NETWORK
  | CONNECTION_RULE_NETWORK_IF_ROAMING
  | CONNECTION_RULE_ALLOW_SYNC_OVER_MOBILE
  | CONNECTION_RULE_ALLOW_SYNC_OVER_WIFI

type offline_sync_status = {
  queued_tracks : int;
  queued_bytes : int64;
  done_tracks : int;
  done_bytes : int64;
  copied_tracks : int;
  copied_bytes : int64;
  willnotcopy_tracks : int;
  error_tracks : int;
  syncing : bool;
}

class session_callbacks = object
  method logged_in (session : session) (error : error) = ()
  method logged_out (session : session) = ()
  method metadata_updated (session : session) = ()
  method connection_error (session : session) (error : error) = ()
  method message_to_user (session : session) (message : string) = ()
  method notify_main_thread (session : session) = ()
  method music_delivery (session : session) (audio_format : audio_format) (frames : bytes) (num_frames : int) = num_frames
  method play_token_lost (session : session) = ()
  method log_message (session : session) (message : string) = ()
  method end_of_track (session : session) = ()
  method streaming_error (session : session) (error : error) = ()
  method userinfo_updated (session : session) = ()
  method start_playback (session : session) = ()
  method stop_playback (session : session) = ()
  method get_audio_buffer_stats (session : session) = { samples = 0; stutter = 0 }
  method offline_status_updated (session : session) = ()
end

type session_config = {
  api_version : int;
  cache_location : string;
  settings_location : string;
  application_key : string;
  user_agent : string;
  callbacks : session_callbacks;
  compress_playlists : bool;
  dont_save_metadata_for_playlists : bool;
  initially_unload_playlists : bool
}

external session_create : session_config -> session = "ocaml_spotify_session_create"
external session_release : session -> unit = "ocaml_spotify_session_release"
external session_login : session -> username : string -> password : string -> remember_me : bool -> unit = "ocaml_spotify_session_login"
external session_relogin : session -> unit = "ocaml_spotify_session_relogin"
external session_remembered_user : session -> string option = "ocaml_spotify_session_remembered_user"
external session_forget_me : session -> unit = "ocaml_spotify_session_forget_me"
external session_user : session -> user = "ocaml_spotify_session_user"
external session_logout : session -> unit = "ocaml_spotify_session_logout"
external session_connection_state : session -> connection_state = "ocaml_spotify_session_connection_state"
external session_set_cache_size : session -> int -> unit = "ocaml_spotify_session_set_cache_size"
external session_process_events : session -> float = "ocaml_spotify_session_process_events"
external session_player_load : session -> track -> unit = "ocaml_spotify_session_player_load"
external session_player_seek : session -> float -> unit = "ocaml_spotify_session_player_seek"
external session_player_play : session -> bool -> unit = "ocaml_spotify_session_player_play"
external session_player_unload : session -> unit = "ocaml_spotify_session_player_unload"
external session_player_prefetch : session -> track -> unit = "ocaml_spotify_session_player_prefetch"
external session_playlistcontainer : session -> playlistcontainer = "ocaml_spotify_session_playlistcontainer"
external session_inbox_create : session -> playlist = "ocaml_spotify_session_inbox_create"
external session_starred_create : session -> playlist = "ocaml_spotify_session_starred_create"
external session_starred_for_user_create : session -> string -> playlist = "ocaml_spotify_session_starred_for_user_create"
external session_publishedcontainer_for_user_create : session -> string option -> playlistcontainer = "ocaml_spotify_session_publishedcontainer_for_user_create"
external session_preferred_bitrate : session -> bitrate -> unit = "ocaml_spotify_session_preferred_bitrate"
external session_preferred_offline_bitrate : session -> bitrate -> bool -> unit = "ocaml_spotify_session_preferred_offline_bitrate"
external session_num_friends : session -> int = "ocaml_spotify_session_num_friends"
external session_friend : session -> int -> user = "ocaml_spotify_session_friend"
external session_set_connection_type : session -> connection_type -> unit = "ocaml_spotify_session_set_connection_type"
external session_set_connection_rules : session -> connection_rules list -> unit = "ocaml_spotify_session_set_connection_rules"
external offline_tracks_to_sync : session -> int = "ocaml_spotify_offline_tracks_to_sync"
external offline_num_playlists : session -> int = "ocaml_spotify_offline_num_playlists"
external offline_sync_get_status : session -> offline_sync_status option = "ocaml_spotify_offline_sync_get_status"
external offline_time_left : session -> int = "ocaml_spotify_offline_time_left"
external session_user_country : session -> int = "ocaml_spotify_session_user_country"

(* +-----------------------------------------------------------------+
   | Links                                                           |
   +-----------------------------------------------------------------+ *)

type link_type =
  | LINKTYPE_INVALID
  | LINKTYPE_TRACK
  | LINKTYPE_ALBUM
  | LINKTYPE_ARTIST
  | LINKTYPE_SEARCH
  | LINKTYPE_PLAYLIST
  | LINKTYPE_PROFILE
  | LINKTYPE_STARRED
  | LINKTYPE_LOCALTRACK
  | LINKTYPE_IMAGE

external link_create_from_string : string -> link = "ocaml_spotify_link_create_from_string"
external link_create_from_track : track -> float -> link = "ocaml_spotify_link_create_from_track"
external link_create_from_album : album -> link = "ocaml_spotify_link_create_from_album"
external link_create_from_album_cover : album -> link = "ocaml_spotify_link_create_from_album_cover"
external link_create_from_artist : artist -> link = "ocaml_spotify_link_create_from_artist"
external link_create_from_artist_portrait : artist -> link = "ocaml_spotify_link_create_from_artist_portrait"
external link_create_from_artistbrowse_portrait : artistbrowse -> int -> link = "ocaml_spotify_link_create_from_artistbrowse_portrait"
external link_create_from_search : search -> link = "ocaml_spotify_link_create_from_search"
external link_create_from_playlist : playlist -> link = "ocaml_spotify_link_create_from_playlist"
external link_create_from_user : user -> link = "ocaml_spotify_link_create_from_user"
external link_create_from_image : image -> link = "ocaml_spotify_link_create_from_image"
external link_as_string : link -> string = "ocaml_spotify_link_as_string"
external link_type : link -> link_type = "ocaml_spotify_link_type"
external link_as_track : link -> track = "ocaml_spotify_link_as_track"
external link_as_track_and_offset : link -> track * float = "ocaml_spotify_link_as_track_and_offset"
external link_as_album : link -> album = "ocaml_spotify_link_as_album"
external link_as_artist : link -> artist = "ocaml_spotify_link_as_artist"
external link_as_user : link -> user = "ocaml_spotify_link_as_user"
external link_release : link -> unit = "ocaml_spotify_link_release"

(* +-----------------------------------------------------------------+
   | Track subsystem                                                 |
   +-----------------------------------------------------------------+ *)

external track_is_loaded : track -> bool = "ocaml_spotify_track_is_loaded"
external track_error : track -> error = "ocaml_spotify_track_error"
external track_is_available : session -> track -> bool = "ocaml_spotify_track_is_available"
external track_is_local : session -> track -> bool = "ocaml_spotify_track_is_local"
external track_is_autolinked : session -> track -> bool = "ocaml_spotify_track_is_autolinked"
external track_is_starred : session -> track -> bool = "ocaml_spotify_track_is_starred"
external track_set_starred : session -> track list -> bool -> unit = "ocaml_spotify_track_set_starred"
external track_num_artists : track -> int = "ocaml_spotify_track_num_artists"
external track_artist : track -> int -> artist = "ocaml_spotify_track_artist"
external track_album : track -> album = "ocaml_spotify_track_album"
external track_name : track -> string = "ocaml_spotify_track_name"
external track_duration : track -> float = "ocaml_spotify_track_duration"
external track_popularity : track -> int = "ocaml_spotify_track_popularity"
external track_disc : track -> int = "ocaml_spotify_track_disc"
external track_index : track -> int = "ocaml_spotify_track_index"
external localtrack_create : artist : string -> title : string -> album : string -> lengh : float -> track = "ocaml_spotify_localtrack_create"
external track_release : track -> unit = "ocaml_spotify_track_release"

(* +-----------------------------------------------------------------+
   | Album subsystem                                                 |
   +-----------------------------------------------------------------+ *)

type album_type =
  | ALBUMTYPE_ALBUM
  | ALBUMTYPE_SINGLE
  | ALBUMTYPE_COMPILATION
  | ALBUMTYPE_UNKNOWN

external album_is_loaded : album -> bool = "ocaml_spotify_album_is_loaded"
external album_is_available : album -> bool = "ocaml_spotify_album_is_available"
external album_artist : album -> artist = "ocaml_spotify_album_artist"
external album_cover : album -> string = "ocaml_spotify_album_cover"
external album_name : album -> string = "ocaml_spotify_album_name"
external album_year : album -> int = "ocaml_spotify_album_year"
external album_type : album -> album_type = "ocaml_spotify_album_type"
external album_release : album -> unit = "ocaml_spotify_album_release"

(* +-----------------------------------------------------------------+
   | Artist subsystem                                                |
   +-----------------------------------------------------------------+ *)

external artist_name : artist -> string = "ocaml_spotify_artist_name"
external artist_is_loaded : artist -> bool = "ocaml_spotify_artist_is_loaded"
external artist_release : album -> unit = "ocaml_spotify_artist_release"

(* +-----------------------------------------------------------------+
   | Album browsing                                                  |
   +-----------------------------------------------------------------+ *)

external albumbrowse_create : session -> album -> (albumbrowse -> unit) -> albumbrowse = "ocaml_spotify_albumbrowse_create"
external albumbrowse_is_loaded : albumbrowse -> bool = "ocaml_spotify_albumbrowse_is_loaded"
external albumbrowse_error : albumbrowse -> error = "ocaml_spotify_albumbrowse_error"
external albumbrowse_album : albumbrowse -> album = "ocaml_spotify_albumbrowse_album"
external albumbrowse_artist : albumbrowse -> artist = "ocaml_spotify_albumbrowse_artist"
external albumbrowee_num_copyrights : albumbrowse -> int = "ocaml_spotify_albumbrowse_num_copyrights"
external albumbrowse_copyright : albumbrowse -> int -> string = "ocaml_spotify_albumbrowse_copyright"
external albumbrowse_num_tracks : albumbrowse -> int = "ocaml_spotify_albumbrowse_num_tracks"
external albumbrowse_track : albumbrowse -> int -> track = "ocaml_spotify_albumbrowse_track"
external albumbrowse_review : albumbrowse -> string = "ocaml_spotify_albumbrowse_review"
external albumbrowse_release : album -> unit = "ocaml_spotify_albumbrowse_release"

(* +-----------------------------------------------------------------+
   | Artist browsing                                                 |
   +-----------------------------------------------------------------+ *)

external artistbrowse_create : session -> artist -> (artistbrowse -> unit) -> artistbrowse = "ocaml_spotify_artistbrowse_create"
external aristbrowse_is_loaded : artistbrowse -> bool = "ocaml_spotify_artistbrowse_is_loaded"
external artistbrowse_error : artistbrowse -> error = "ocaml_spotify_artistbrowse_error"
external artistbrowse_artist : artistbrowse -> artist = "ocaml_spotify_artistbrowse_artist"
external artistbrowse_num_portraits : artistbrowse -> int = "ocaml_spotify_artistbrowse_num_portraits"
external artistbrowse_portrait : artistbrowse -> int -> string = "ocaml_spotify_artistbrowse_portrait"
external artistbrowse_num_tracks : artistbrowse -> int = "ocaml_spotify_artistbrowse_num_tracks"
external artistbrowse_track : artistbrowse -> int -> track = "ocaml_spotify_artistbrowse_track"
external artistbrowse_num_albums : artistbrowse -> int = "ocaml_spotify_artistbrowse_num_albums"
external artistbrowse_album : artistbrowse -> int -> album = "ocaml_spotify_artistbrowse_album"
external artistbrowse_num_similar_artists : artistbrowse -> int = "ocaml_spotify_artistbrowse_num_similar_artists"
external artistbrowse_similar_artist : artistbrowse -> int -> artist = "ocaml_spotify_artistbrowse_similar_artist"
external artistbrowse_biography : artistbrowse -> string = "ocaml_spotify_artistbrowse_biography"
external artistbrowse_release : artist -> unit = "ocaml_spotify_artistbrowse_release"

(* +-----------------------------------------------------------------+
   | Image handling                                                  |
   +-----------------------------------------------------------------+ *)

type image_format =
  | IMAGE_FORMAT_UNKNOWN
  | IMAGE_FORMAT_JPEG

external image_create : session -> string -> image = "ocaml_spotify_image_create"
external image_create_from_link : session -> link -> image = "ocaml_spotify_image_create_from_link"
type image_load_callback_id
external image_add_load_callback : image -> (image -> unit) -> image_load_callback_id = "ocaml_spotify_image_add_load_callback"
external image_remove_load_callback : image -> image_load_callback_id -> unit = "ocaml_spotify_image_remove_load_callback"
external image_is_loaded : image -> bool = "ocaml_spotify_image_is_loaded"
external image_error : image -> error = "ocaml_spotify_image_error"
external image_format : image -> image_format = "ocaml_spotify_image_format"
external image_data : image -> bytes = "ocaml_spotify_image_data"
external image_image_id : image -> string = "ocaml_spotify_image_image_id"
external image_release : artist -> unit = "ocaml_spotify_image_release"

(* +-----------------------------------------------------------------+
   | Search subsystem                                                |
   +-----------------------------------------------------------------+ *)

type radio_genre =
  | RADIO_GENRE_ALT_POP_ROCK
  | RADIO_GENRE_BLUES
  | RADIO_GENRE_COUNTRY
  | RADIO_GENRE_DISCO
  | RADIO_GENRE_FUNK
  | RADIO_GENRE_HARD_ROCK
  | RADIO_GENRE_HEAVY_METAL
  | RADIO_GENRE_RAP
  | RADIO_GENRE_HOUSE
  | RADIO_GENRE_JAZZ
  | RADIO_GENRE_NEW_WAVE
  | RADIO_GENRE_RNB
  | RADIO_GENRE_POP
  | RADIO_GENRE_PUNK
  | RADIO_GENRE_REGGAE
  | RADIO_GENRE_POP_ROCK
  | RADIO_GENRE_SOUL
  | RADIO_GENRE_TECHNO

external search_create : session -> query : string -> track_offset : int -> track_count : int -> album_offset : int -> album_count : int -> artist_offset : int -> artist_count : int -> callback : (search -> unit) -> search = "ocaml_spotify_search_create_byte" "ocaml_spotify_search_create"
external radio_search_create : session -> from_year : int -> to_year : int -> genres : radio_genre list -> callback : (search -> unit) -> search = "ocaml_spotify_radio_search_create"
external search_is_loaded : search -> bool = "ocaml_spotify_search_is_loaded"
external search_error : search -> error = "ocaml_spotify_search_error"
external search_num_tracks : search -> int = "ocaml_spotify_search_num_tracks"
external search_track : search -> int -> track = "ocaml_spotify_search_track"
external search_num_albums : search -> int = "ocaml_spotify_search_num_albums"
external search_album : search -> int -> album = "ocaml_spotify_search_album"
external search_num_artists : search -> int = "ocaml_spotify_search_num_artists"
external search_artist : search -> int -> artist = "ocaml_spotify_search_artist"
external search_query : search -> string = "ocaml_spotify_search_query"
external search_did_you_mean : search -> string = "ocaml_spotify_search_did_you_mean"
external search_total_tracks : search -> int = "ocaml_spotify_search_total_tracks"
external search_total_albums : search -> int = "ocaml_spotify_search_total_albums"
external search_total_artists : search -> int = "ocaml_spotify_search_total_artists"
external search_release : search -> unit = "ocaml_spotify_search_release"
