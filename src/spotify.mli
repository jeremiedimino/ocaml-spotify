(*
 * spotify.mli
 * -----------
 * Copyright : (c) 2011, Jeremie Dimino <jeremie@dimino.org>
 * Licence   : BSD3
 *
 * This file is a part of ocaml-spotify.
 *)

(** Spotify client library *)

(** {6 Spotify types} *)

type session
  (** Representation of a session. *)

type track
  (** A track handle. *)

type album
  (** An album handle. *)

type artist
  (** An artist handle. *)

type artistbrowse
  (** A handle to an artist browse result. *)

type albumbrowse
  (** A handle to an album browse result. *)

type toplistbrowse
  (** A handle to a toplist browse result. *)

type search
  (** A handle to a search result. *)

type link
  (** A handle to the libspotify internal representation of a URI. *)

type image
  (** A handle to an image. *)

type user
  (** A handle to a user. *)

type playlist
  (** A playlist handle. *)

type playlistcontainer
  (** A playlist container (playlist containing other playlists) handle. *)

type inbox
  (** Add to inbox request handle. *)

(** {6 Error handling} *)

exception NULL
  (** Exception raised when trying to use an object that has been
      released. *)

(** Error codes returned by various functions. *)
type error =
  | ERROR_OK
      (** No errors encountered. *)
  | ERROR_BAD_API_VERSION
      (** The library version targeted does not match the one you
          claim you support. *)
  | ERROR_API_INITIALIZATION_FAILED
      (** Initialization of library failed - are cache locations
          etc. valid?. *)
  | ERROR_TRACK_NOT_PLAYABLE
      (** The track specified for playing cannot be played. *)
  | ERROR_BAD_APPLICATION_KEY
      (** The application key is invalid. *)
  | ERROR_BAD_USERNAME_OR_PASSWORD
      (** Login failed because of bad username and/or password. *)
  | ERROR_USER_BANNED
      (** The specified username is banned. *)
  | ERROR_UNABLE_TO_CONTACT_SERVER
      (** Cannot connect to the Spotify backend system. *)
  | ERROR_CLIENT_TOO_OLD
      (** Client is too old, library will need to be updated. *)
  | ERROR_OTHER_PERMANENT
      (** Some other error occurred, and it is permanent (e.g. trying
          to relogin will not help). *)
  | ERROR_BAD_USER_AGENT
      (** The user agent string is invalid or too long. *)
  | ERROR_MISSING_CALLBACK
      (** No valid callback registered to handle events. *)
  | ERROR_INVALID_INDATA
      (** Input data was either missing or invalid. *)
  | ERROR_INDEX_OUT_OF_RANGE
      (** Index out of range. *)
  | ERROR_USER_NEEDS_PREMIUM
      (** The specified user needs a premium account. *)
  | ERROR_OTHER_TRANSIENT
      (** A transient error occurred.. *)
  | ERROR_IS_LOADING
      (** The resource is currently loading. *)
  | ERROR_NO_STREAM_AVAILABLE
      (** Could not find any suitable stream to play. *)
  | ERROR_PERMISSION_DENIED
      (** Requested operation is not allowed. *)
  | ERROR_INBOX_IS_FULL
      (** Target inbox is full. *)
  | ERROR_NO_CACHE
      (** Cache is not enabled. *)
  | ERROR_NO_SUCH_USER
      (** Requested user does not exist. *)
  | ERROR_NO_CREDENTIALS
      (** No credentials are stored. *)

exception Error of string * error
  (** Exception raised by functions of ocaml-spotify. The first
      argument is the function which raised the error. *)

val error_message : error -> string
  (** Return an error message for the given error. *)

(** {6 NULL testing} *)

val session_is_null : session -> bool
  (** Check whether the following session contains a NULL pointer. *)

val track_is_null : track -> bool
  (** Check whether the following track contains a NULL pointer. *)

val album_is_null : album -> bool
  (** Check whether the following album contains a NULL pointer. *)

val artist_is_null : artist -> bool
  (** Check whether the following artist contains a NULL pointer. *)

val artistbrowse_is_null : artistbrowse -> bool
  (** Check whether the following artistbrowse contains a NULL pointer. *)

val albumbrowse_is_null : albumbrowse -> bool
  (** Check whether the following albumbrowse contains a NULL pointer. *)

val toplistbrowse_is_null : toplistbrowse -> bool
  (** Check whether the following toplistbrowse contains a NULL pointer. *)

val search_is_null : search -> bool
  (** Check whether the following search contains a NULL pointer. *)

val link_is_null : link -> bool
  (** Check whether the following link contains a NULL pointer. *)

val image_is_null : image -> bool
  (** Check whether the following image contains a NULL pointer. *)

val user_is_null : user -> bool
  (** Check whether the following user contains a NULL pointer. *)

val playlist_is_null : playlist -> bool
  (** Check whether the following playlist contains a NULL pointer. *)

val playlistcontainer_is_null : playlistcontainer -> bool
  (** Check whether the following playlistcontainer contains a NULL pointer. *)

val inbox_is_null : inbox -> bool
  (** Check whether the following inbox contains a NULL pointer. *)

(** {6 Session handling} *)

(** The concept of a session is fundamental for all communication with
    the Spotify ecosystem - it is the object responsible for
    communicating with the Spotify service. You will need to
    instantiate a session that then can be used to request artist
    information, perform searches etc. *)

val api_version : int
  (** Current version of the application interface, that is, the API
      described by this library.

      This value should be set in the {!config} record passed to
      {!create}.

      If an (upgraded) library is no longer compatible with this
      version the error {!Spotify_error.BAD_API_VERSION} will be
      raised from {!create}. Future versions of the library will
      provide you with some kind of mechanism to request an updated
      version of the library. *)

(** Describes the current state of the connection. *)
type connection_state =
  | CONNECTION_STATE_LOGGED_OUT
      (** User not yet logged. *)
  | CONNECTION_STATE_LOGGED_IN
      (** Logged in against a Spotify access point. *)
  | CONNECTION_STATE_DISCONNECTED
      (** Was logged in, but has now been disconnected. *)
  | CONNECTION_STATE_UNDEFINED
      (** The connection state is undefined. *)
  | CONNECTION_STATE_OFFLINE
      (** Logged in in offline mode. *)

(** Sample type descriptor. *)
type sample_type =
  | SAMPLETYPE_INT16_NATIVE_ENDIAN
      (** 16-bit signed integer samples. *)

(** Audio format descriptor. *)
type audio_format = {
  sample_type : sample_type;
  (** Sample type. *)
  sample_rate : int;
  (** Audio sample rate, in samples per second. *)
  channels : int;
  (** Number of channels. Currently 1 or 2. *)
}

(** Bitrate definitions for music streaming. *)
type bitrate =
  | BITRATE_160k
  | BITRATE_320k
  | BITRATE_96k

(** Playlist types. *)
type playlist_type =
  | PLAYLIST_TYPE_PLAYLIST
      (** A normal playlist. *)
  | PLAYLIST_TYPE_START_FOLDER
      (** Marks a folder starting point, *)
  | PLAYLIST_TYPE_END_FOLDER
      (** and ending point. *)
  | PLAYLIST_TYPE_PLACEHOLDER
      (** Unknown entry. *)

(** Playlist offline status. *)
type playlist_offline_status =
  | PLAYLIST_OFFLINE_STATUS_NO
      (** Playlist is not offline enabled. *)
  | PLAYLIST_OFFLINE_STATUS_YES
      (** Playlist is synchronized to local storage. *)
  | PLAYLIST_OFFLINE_STATUS_DOWNLOADING
      (** This playlist is currently downloading. Only one playlist
          can be in this state any given time. *)
  | PLAYLIST_OFFLINE_STATUS_WAITING
      (** Playlist is queued for download. *)

(** Buffer stats used by {!get_audio_buffer_stats} callback. *)
type audio_buffer_stats = {
  samples : int;
  (** Samples in buffer. *)
  stutter : int;
  (** Number of stutters (audio dropouts) since last query. *)
}

type bytes = (char, Bigarray.int8_unsigned_elt, Bigarray.c_layout) Bigarray.Array1.t
    (** Type of array of bytes. *)

val string_of_bytes : bytes -> string
  (** Copy the given array of bytes into a string. This is usefull for
      library that does not support bigarrays. *)

(** Current connection type set using {!set_connection_type}. *)
type connection_type =
  | CONNECTION_TYPE_UNKNOWN
      (** Connection type unknown (Default). *)
  | CONNECTION_TYPE_NONE
      (** No connection. *)
  | CONNECTION_TYPE_MOBILE
      (** Mobile data (EDGE, 3G, etc). *)
  | CONNECTION_TYPE_MOBILE_ROAMING
      (** Roamed mobile data (EDGE, 3G, etc). *)
  | CONNECTION_TYPE_WIFI
      (** Wireless connection. *)
  | CONNECTION_TYPE_WIRED
      (** Ethernet cable, etc. *)

(** Connection rules. *)
type connection_rules =
  | CONNECTION_RULE_NETWORK
      (** Allow network traffic. When not set libspotify will force
          itself into offline mode. *)
  | CONNECTION_RULE_NETWORK_IF_ROAMING
      (** Allow network traffic even if roaming. *)
  | CONNECTION_RULE_ALLOW_SYNC_OVER_MOBILE
      (** Set to allow syncing of offline content over mobile
          connections. *)
  | CONNECTION_RULE_ALLOW_SYNC_OVER_WIFI
      (** Set to allow syncing of offline content over WiFi. *)

(** Offline sync status. *)
type offline_sync_status = {
  (** Queued tracks/bytes is things left to sync in current sync
      operation. *)
  queued_tracks : int;
  queued_bytes : int64;

  (** Done tracks/bytes is things marked for sync that existed on
      device before current sync operation. *)
  done_tracks : int;
  done_bytes : int64;

  (** Copied tracks/bytes is things that has been copied in current
      sync operation. *)
  copied_tracks : int;
  copied_bytes : int64;

  (** Tracks that are marked as synced but will not be copied (for
      various reasons). *)
  willnotcopy_tracks : int;

  (** A track is counted as error when something goes wrong while
      syncing the track. *)
  error_tracks : int;

  (** Set if sync operation is in progress. *)
  syncing : bool;
}

(** Session callbacks

    Registered when you create a session. *)
class session_callbacks : object
  method logged_in : session -> error -> unit
    (** Called when login has been processed and was successful.

        @param session Session
        @param error One of the following errors:
        - {!ERROR_OK}
        - {!ERROR_CLIENT_TOO_OLD}
        - {!ERROR_UNABLE_TO_CONTACT_SERVER}
        - {!ERROR_BAD_USERNAME_OR_PASSWORD}
        - {!ERROR_USER_BANNED}
        - {!ERROR_USER_NEEDS_PREMIUM}
        - {!ERROR_OTHER_TRANSIENT}
        - {!ERROR_OTHER_PERMANENT}
    *)

  method logged_out : session -> unit
    (** Called when logout has been processed. Either called
        explicitly if you initialize a logout operation, or implicitly
        if there is a permanent connection error.

	@param session Session
    *)

  method metadata_updated : session -> unit
    (** Called whenever metadata has been updated.

	If you have metadata cached outside of libspotify, you should
	purge your caches and fetch new versions.

	@param session Session
    *)

  method connection_error : session -> error -> unit
    (** Called when there is a connection error, and the library has problems
        reconnecting to the Spotify service. Could be called multiple times (as
	long as the problem is present).

	@param session Session
	@param error One of the following errors:
	- {!ERROR_OK}
	- {!ERROR_CLIENT_TOO_OLD}
	- {!ERROR_UNABLE_TO_CONTACT_SERVER}
	- {!ERROR_BAD_USERNAME_OR_PASSWORD}
	- {!ERROR_USER_BANNED}
	- {!ERROR_USER_NEEDS_PREMIUM}
	- {!ERROR_OTHER_TRANSIENT}
	- {!ERROR_OTHER_PERMANENT}
    *)

  method message_to_user : session -> string -> unit
    (** Called when the access point wants to display a message to the
        user.

	In the desktop client, these are shown in a blueish toolbar
	just below the search box.

	@param session Session
	@param message String in UTF-8 format.
    *)

  method notify_main_thread : session -> unit
    (** Called when processing needs to take place on the main thread.

        You need to call {!process_events} in the main thread to get
        libspotify to do more work. Failure to do so may cause request timeouts,
        or a lost connection.

        @param session Session

        @note This function is called from an internal session thread,
        you need to have proper synchronization!
    *)


  method music_delivery : session -> audio_format -> bytes -> int -> int
    (** Called when there is decompressed audio data available.

        @param session Session
        @param format Audio format descriptor sp_audioformat
        @param frames Points to raw PCM data as described by [format]
        @param num_frames Number of available samples in [frames].
        If this is 0, a discontinuity has occurred (such as after a
	seek). The application should flush its audio fifos, etc.

	@return Number of frames consumed.

	This value can be used to rate limit the output from the
	library if your output buffers are saturated. The library will
	retry delivery in about 100ms.

	@note This function is called from an internal session thread,
	you need to have proper synchronization!

	@note This function must never block. If your output buffers
	are full you must return 0 to signal that the library should
	retry delivery in a short while. *)

  method play_token_lost : session -> unit
    (** Music has been paused because only one account may play music
        at the same time.

        @param session Session
    *)

  method log_message : session -> string -> unit
    (** Logging callback.

        @param session Session
        @param data Log data
    *)

  method end_of_track : session -> unit
    (** End of track. Called when the currently played track has
        reached its end.

        @note This function is invoked from the same internal thread
	as the music delivery callback

	@param session Session
    *)

  method streaming_error : session -> error -> unit
    (** Streaming error. Called when streaming cannot start or
        continue.

        @note This function is invoked from the main thread

        @param session Session
        @param error One of the following errors:
	- {!ERROR_NO_STREAM_AVAILABLE}
	- {!ERROR_OTHER_TRANSIENT}
	- {!ERROR_OTHER_PERMANENT}
    *)

  method userinfo_updated : session -> unit
    (** Called after user info (anything related to sp_user objects)
        have been updated.

        @param session Session
    *)

  method start_playback : session -> unit
    (** Called when audio playback should start.

        @note For this to work correctly the application must also
        implement {!get_audio_buffer_stats}

        @note This function is called from an internal session thread,
        you need to have proper synchronization!

        @note This function must never block.

	@param session Session
    *)

  method stop_playback : session -> unit
    (** Called when audio playback should stop.

        @note For this to work correctly the application must also
        implement {!get_audio_buffer_stats}.

        @note This function is called from an internal session thread,
        you need to have proper synchronization!.

        @note This function must never block.

	@param session Session
    *)

  method get_audio_buffer_stats : session -> audio_buffer_stats
    (** Called to query application about its audio buffer

        @note This function is called from an internal session thread,
        you need to have proper synchronization!

        @note This function must never block.

	@param session Session
	@return Stats
    *)

  method offline_status_updated : session -> unit
    (** Called when offline synchronization status is updated.

        @param session Session
    *)
end

(** Session config. *)
type session_config = {
  api_version : int;
  (** The version of the Spotify API your application is compiled
      with. Set to {!api_version}. *)

  cache_location : string;
  (** The location where Spotify will write cache files. This cache
      include tracks, cached browse results and coverarts. Set to
      empty string to disable cache. *)

  settings_location : string;
  (** The location where Spotify will write setting files and per-user
      cache items. This includes playlists, track metadata, etc.
      [settings_location] may be the same path as [cache_location].
      [settings_location] folder will not be created (unlike
      [cache_location]), if you don't want to create the folder
      yourself, you can set [settings_location] to
      [cache_location]. *)

  application_key : string;
  (** Your application key. *)

  user_agent : string;
  (** "User-Agent" for your application - max 255 characters long.
      The User-Agent should be a relevant, customer facing
      identification of your application. *)

  callbacks : session_callbacks;
  (** Delivery callbacks for session events. *)

  compress_playlists : bool;
  (** Compress local copy of playlists, reduces disk space usage. *)

  dont_save_metadata_for_playlists : bool;
  (** Don't save metadata for local copies of playlists Reduces disk
      space usage at the expense of needing to request metadata from
      Spotify backend when loading list *)

  initially_unload_playlists : bool
  (** Avoid loading playlists into RAM on startup. See
      {!Spotify_playlist.is_in_ram} for more details. *)
}

val session_create : session_config -> session
  (** Initialize a session. The session returned will be initialized,
      but you will need to log in before you can perform any other
      operation.  Currently it is not supported to have multiple
      active sessions, and it's recommended to only call this once per
      process.

      @param config The configuration to use for the session
      @return a new session.

      @raise {!ERROR_BAD_API_VERSION}
      @raise {!ERROR_BAD_USER_AGENT}
      @raise {!ERROR_BAD_APPLICATION_KEY}
      @raise {!ERROR_API_INITIALIZATION_FAILED}
  *)

val session_release : session -> unit
  (** Release the session. This will clean up all data and connections
      associated with the session.

      @param session Session object returned from {!session_create}. *)

val session_login : session -> username : string -> password : string -> remember_me : bool -> unit
  (** Logs in the specified username/password combo. This initiates
      the login in the background.  A callback is called when login is
      complete.

      An application MUST NEVER store the user's password in clear
      text. If automatic relogin is required, use {!relogin}.

      @param session Your session object
      @param username The username to log in
      @param password The password for the specified username
      @param remember_me If set, the username / password will be remembered by libspotify
  *)

val session_relogin : session -> unit
  (** Log in the remembered user if last user that logged in logged in
      with remember_me set.  If no credentials are stored, this will
      raises {!ERROR_NO_CREDENTIALS}.

      @param session Your session object

      @raise {!ERROR_OK}
      @raise {!ERROR_NO_CREDENTIALS}
  *)

val session_remembered_user : session -> string option
  (** Get username of the user that will be logged in via {!relogin}.

      @param session Your session object
      @return The username, if any, or [None] if no credentials are
      stored in libspotify. *)

val session_forget_me : session -> unit
  (** Remove stored credentials in libspotify. If no credentials are
      currently stored, nothing will happen.

      @param session Your session object
  *)

val session_user : session -> user
  (** Fetches the currently logged in user.

      @param session Your session object

      @return The logged in user, or a NULL pointer if not logged
      in. *)

val session_logout : session -> unit
  (** Logs out the currently logged in user

      Always call this before terminating the application and
      libspotify is currently logged in. Otherwise, the settings and
      cache may be lost.

      @param session Your session object
  *)

val session_connection_state : session -> connection_state
  (** The connection state of the specified session.

      @param session Your session object

      @return The connection state.  *)

val session_set_cache_size : session -> int -> unit
  (** Set maximum cache size.

      @param session Your session object
      @param size Maximum cache size in megabytes.
      Setting it to 0 (the default) will let libspotify automatically
      resize the cache (10% of disk free space). *)

val session_process_events : session -> float
  (** Make the specified session process any pending events.

      @param session Your session object
      @return The time (in seconds) until you should call this
      function again. *)

val session_player_load : session -> track -> unit
  (** Loads the specified track.

      After successfully loading the track, you have the option of
      running {!player_play} directly, or using {!player_seek} first.
      When this call returns, the track will have been loaded, unless
      an error occurred.

      @param session Your session object
      @param track The track to be loaded

      @raise {!ERROR_MISSING_CALLBACK}
      @raise {!ERROR_RESOURCE_NOT_LOADED}
      @raise {!ERROR_TRACK_NOT_PLAYABLE}
  *)

val session_player_seek : session -> float -> unit
  (** Seek to position in the currently loaded track.

      @param session Your session object
      @param offset Track position, in seconds.
  *)

val session_player_play : session -> bool -> unit
  (** Play or pause the currently loaded track.

      @param session Your session object
      @param play If set to true, playback will occur. If set to
      false, the playback will be paused. *)

val session_player_unload : session -> unit
  (** Stops the currently playing track

      This frees some resources held by libspotify to identify the
      currently playing track.

      @param session Your session object *)

val session_player_prefetch : session -> track -> unit
  (** Prefetch a track.

      Instruct libspotify to start loading of a track into its cache.
      This could be done by an application just before the current
      track ends.

      @param session Your session object
      @param track The track to be prefetched

      @raise {!ERROR_NO_CACHE}

      @note Prefetching is only possible if a cache is configured. *)

val session_playlistcontainer : session -> playlistcontainer
  (** Returns the playlist container for the currently logged in user.

      @param session Your session object

      @return Playlist container object, or a NULL pointer if not
      logged in. *)

val session_inbox_create : session -> playlist
  (** Returns an inbox playlist for the currently logged in user.

      @param session Session object

      @return A playlist or a NULL pointer if not logged in. *)

val session_starred_create : session -> playlist
  (** Returns the starred list for the current user.

      @param session Session object

      @return A playlist or a NULL pointer if not logged in. *)

val session_starred_for_user_create : session -> string -> playlist
  (** Returns the starred list for a user.

      @param session Session object
      @param canonical_username Canonical username

      @return A playlist or a NULL pointer if not logged in. *)

val session_publishedcontainer_for_user_create : session -> string option -> playlistcontainer
  (** Return the published container for a given [canonical_username],
      or the currently logged in user if [canonical_username] is
      [None].

      @param session Your session object.
      @param canonical_username The canonical username, or [None].

      @return Playlist container object or a NULL pointer if not
      logged in. *)

val session_preferred_bitrate : session -> bitrate -> unit
  (** Set preferred bitrate for music streaming.

      @param session Session object
      @param bitrate Preferred bitrate
  *)

val session_preferred_offline_bitrate : session -> bitrate -> bool -> unit
  (** Set preferred bitrate for offline sync.

      @param session Session object
      @param bitrate Preferred bitrate
      @param allow_resync Set to true if libspotify should
      resynchronize already synchronized tracks. Usually you should
      set this to false. *)

val session_num_friends : session -> int
  (** Return number of friends in the currently logged in users
      friends list.

      @param session Session object

      @return Number of users in friends. Each user can be extracted
      using the {!friend} method. The number of users in the list will
      not be updated nor change order between calls to
      {!process_events}.  *)

val session_friend : session -> int -> user
  (** Retrun the given user from the currently logged in users list of
      friends.

      @param session Session object
      @param index Index in list

      @return A user. *)

val session_set_connection_type : session -> connection_type -> unit
  (** Set to true if the connection is currently routed over a roamed connectivity.

      @param session Session object
      @param type Connection type

      @note Used in conjunction with {!session_set_connection_rules}
      to control how libspotify should behave in respect to network
      activity and offline synchronization. *)

val session_set_connection_rules : session -> connection_rules list -> unit
  (** Set rules for how libspotify connects to Spotify servers and
      synchronizes offline content.

      @param session Session object
      @param rules Connection rules

      @note Used in conjunction with {!session_set_connection_type} to
      control how libspotify should behave in respect to network
      activity and offline synchronization. *)

val offline_tracks_to_sync : session -> int
  (** Get total number of tracks that needs download before everything
      from all playlists that is marked for offline is fully
      synchronized.

      @param session Session object

      @return Number of tracks *)

val offline_num_playlists : session -> int
  (** Return number of playlisys that is marked for offline
      synchronization.

      @param session Session object

      @return Number of playlists
  *)

val offline_sync_get_status : session -> offline_sync_status option
  (** Return offline synchronization status. When the internal status is
      updated the {!offline_status_updated} callback will be invoked.

      @param session Session object

      @return Status object or [None] if no synching is in progress *)

val offline_time_left : session -> int
  (** Return remaining time (in seconds) until the offline key store
      expires and the user is required to relogin.

      @param session Session object
      @return Seconds until expiration *)

val session_user_country : session -> int
  (** Get currently logged in users country updated the
      {!offline_status_updated} callback will be invoked.

      @param session Session object

      @return Country encoded in an integer ['SE' = (Char.code 'S' lsl
      8) lor Char.code 'E']. *)

(** {6 Track subsystem} *)

val track_is_loaded : track -> bool
  (** Return whether or not the track metadata is loaded.

      @param track The track

      @return [true] if track is loaded

      @note This is equivalent to checking if {!error} not returns
      {!ERROR_IS_LOADING}.
  *)

val track_error : track -> error
  (** Return an error code associated with a track. For example if it could not load.

      @param track The track

      @return One of the following errors:
      - {!ERROR_OK}
      - {!ERROR_IS_LOADING}
      - {!ERROR_OTHER_PERMANENT}
  *)

val track_is_available : session -> track -> bool
  (** Return true if the track is available for playback.

      @param session Session
      @param track The track

      @return [true] if track is available for playback, otherwise [false].

      @note The track must be loaded or this function will always
      return false.
      @see {!track_is_loaded}
  *)

val track_is_local : session -> track -> bool
  (** Return true if the track is a local file.

      @param session Session
      @param track The track

      @return [true] if track is a local file.

      @note The track must be loaded or this function will always
      return false.
      @see {!sp_track_is_loaded}
  *)

val track_is_autolinked : session -> track -> bool
  (** Return true if the track is autolinked to another track.

      @param session Session
      @param track The track

      @return [true] if track is autolinked.

      @note The track must be loaded or this function will always
      return false.

      @see {!track_is_loaded}
  *)

val track_is_starred : session -> track -> bool
  (** Return true if the track is starred by the currently logged in user.

      @param session Session
      @param track The track

      @return [true] if track is starred.

      @note The track must be loaded or this function will always
      return false.
      @see {!track_is_loaded}
  *)

val track_set_starred : session -> track list -> bool -> unit
  (** Star/Unstar the specified tracks

      @param session Session
      @param tracks List of tracks.
      @param star Starred status of the tracks

      @note This will fail silently if playlists are disabled.
      @see {!set_playlists_enabled}
  *)

val track_num_artists : track -> int
  (** The number of artists performing on the specified track.

      @param track The track whose number of participating artists you
      are interested in

      @return The number of artists performing on the specified track.
      If no metadata is available for the track yet, this function
      returns 0.  *)


val track_artist : track -> int -> artist
  (** The artist matching the specified index performing on the
      current track.

      @param track The track whose participating artist you are
      interested in

      @param index The index for the participating artist. Should be
      in the interval [0 .. track_num_artists () - 1].

      @return The participating artist. *)

val track_album : track -> album
  (** The album of the specified track.

      @param track A track object

      @return The album of the given track. If no metadata is
      available for the track yet, this is a NULL pointer. *)

val track_name : track -> string
  (** The string representation of the specified track's name.

      @param track A track object

      @return The string representation of the specified track's name.
      If no metadata is available for the track yet, this function
      returns empty string. *)

val track_duration : track -> float
  (** The duration, in seconds, of the specified track.

      @param track A track object

      @return The duration of the specified track, in seconds If no
      metadata is available for the track yet, this function returns
      0. *)

val track_popularity : track -> int
  (** Returns popularity for track

      @param track A track object

      @return Popularity in range 0 to 100, 0 if undefined.  If no
      metadata is available for the track yet, this function returns
      0. *)

val track_disc : track -> int
  (** Returns the disc number for a track.

      @param track A track object

      @return Disc index. Possible values are [1 .. total number of
      discs on album] This function returns valid data only for tracks
      appearing in a browse artist or browse album result (otherwise
      returns 0). *)

val track_index : track -> int
  (** Returns the position of a track on its disc.

      @param track A track object

      @return Track position, starts at 1 (relative the corresponding
      disc) This function returns valid data only for tracks appearing
      in a browse artist or browse album result (otherwise returns 0). *)

val localtrack_create : artist : string -> title : string -> album : string -> lengh : float -> track
  (** Returns the newly created local track

      @param artist Name of the artist
      @param title Song title
      @param album Name of the album, or an empty string if not available
      @param length Length in MS, or -1 if not available.

      @return A track.
  *)

val track_release : track -> unit
  (** Destroy the reference to the track. Any subsequent operation on
      the track will raise {!NULL}. *)

(** {6 Search subsystem} *)

(** List of genres for radio query. *)
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

val search_create : session -> query : string -> track_offset : int -> track_count : int -> album_offset : int -> album_count : int -> artist_offset : int -> artist_count : int -> callback : (search -> unit) -> search
  (** Create a search object from the given query

      @param session Session
      @param query Query search string, e.g. "The Rolling Stones" or "album:\"The Black Album\""
      @param track_offset The offset among the tracks of the result
      @param track_count The number of tracks to ask for
      @param album_offset The offset among the albums of the result
      @param album_count The number of albums to ask for
      @param artist_offset The offset among the artists of the result
      @param artist_count The number of artists to ask for
      @param callback Callback that will be called once the search operation is complete.

      @return A search object.
  *)

val radio_search_create : session -> from_year : int -> to_year : int -> genres : radio_genre list -> callback : (search -> unit) -> search
  (** Create a search object from the radio channel.

      @param session Session
      @param from_year Include tracks starting from this year
      @param to_year Include tracks up to this year
      @param genres Bitmask of genres to include
      @param callback Callback that will be called once the search operation is complete.

      @return A search object.
  *)

val search_is_loaded : search -> bool
  (** Get load status for the specified search. Before it is loaded,
      it will behave as an empty search result.

      @param search Search object

      @return [true] if search is loaded, otherwise [false]
  *)

val search_error : search -> error
  (** Check if search returned an error code.

      @param search Search object

      @return One of the following errors:
      - {!ERROR_OK}
      - {!ERROR_IS_LOADING}
      - {!ERROR_OTHER_PERMANENT}
      - {!ERROR_OTHER_TRANSIENT}
  *)

val search_num_tracks : search -> int
  (** Get the number of tracks for the specified search.

      @param search Search object

      @return The number of tracks for the specified search
  *)

val search_track : search -> int -> track
  (** Return the track at the given index in the given search object.

      @param search Search object
      @param index Index of the wanted track. Should be in the
      interval [0 .. search_num_tracks () - 1]

      @return The track at the given index in the given search object
  *)

val search_num_albums : search -> int
  (** Get the number of albums for the specified search.

      @param search Search object

      @return The number of albums for the specified search
  *)

val search_album : search -> int -> album
  (** Return the album at the given index in the given search object.

      @param search Search object

      @param index Index of the wanted album. Should be in the
      interval [0 .. search_num_albums () - 1]

      @return The album at the given index in the given search
      object. *)

val search_num_artists : search -> int
  (** Get the number of artists for the specified search.

      @param search Search object

      @return The number of artists for the specified search
  *)

val search_artist : search -> int -> artist
  (** Return the artist at the given index in the given search object.

      @param search Search object
      @param index Index of the wanted artist. Should be in the
      interval [0 .. search_num_artists () - 1]

      @return The artist at the given index in the given search
      object *)

val search_query : search -> string
  (** Return the search query for the given search object.

      @param search Search object

      @return The search query for the given search object. *)

val search_did_you_mean : search -> string
  (** Return the "Did you mean" query for the given search object.

      @param search Search object

      @return The "Did you mean" query for the given search object, or
      the empty string if no such info is available. *)

val search_total_tracks : search -> int
  (** Return the total number of tracks for the search query -
      regardless of the interval requested at creation. If this value
      is larger than the interval specified at creation of the search
      object, more search results are available. To fetch these,
      create a new search object with a new interval.

      @param search Search object

      @return The total number of tracks matching the original
      query *)

val search_total_albums : search -> int
  (** Return the total number of albums for the search query -
      regardless of the interval requested at creation. If this value
      is larger than the interval specified at creation of the search
      object, more search results are available. To fetch these,
      create a new search object with a new interval.

      @param search Search object

      @return The total number of albums matching the original query
  *)

val search_total_artists : search -> int
  (** Return the total number of artists for the search query -
      regardless of the interval requested at creation.  If this value
      is larger than the interval specified at creation of the search
      object, more search results are available.  To fetch these,
      create a new search object with a new interval.

      @param search Search object

      @return The total number of artists matching the original
      query *)

val search_release : search -> unit
  (** Destroy the reference to the search. Any subsequent operation on
      the search will raise {!NULL}. *)
