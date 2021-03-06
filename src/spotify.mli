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

      This value should be set in the {!session_config} record passed
      to {!session_create}.

      If an (upgraded) library is no longer compatible with this
      version the error {!ERROR_BAD_API_VERSION} will be raised from
      {!session_create}. Future versions of the library will provide
      you with some kind of mechanism to request an updated version of
      the library. *)

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

        You need to call {!session_process_events} in the main thread
        to get libspotify to do more work. Failure to do so may cause
        request timeouts, or a lost connection.

        @param session Session

        Note: This function is called from an internal session thread,
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

	Note: This function is called from an internal session thread,
	you need to have proper synchronization!

	Note: This function must never block. If your output buffers
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

        Note: This function is invoked from the same internal thread
	as the music delivery callback

	@param session Session
    *)

  method streaming_error : session -> error -> unit
    (** Streaming error. Called when streaming cannot start or
        continue.

        Note: This function is invoked from the main thread

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

        Note: For this to work correctly the application must also
        implement {!get_audio_buffer_stats}

        Note: This function is called from an internal session thread,
        you need to have proper synchronization!

        Note: This function must never block.

	@param session Session
    *)

  method stop_playback : session -> unit
    (** Called when audio playback should stop.

        Note: For this to work correctly the application must also
        implement {!get_audio_buffer_stats}.

        Note: This function is called from an internal session thread,
        you need to have proper synchronization!.

        Note: This function must never block.

	@param session Session
    *)

  method get_audio_buffer_stats : session -> audio_buffer_stats
    (** Called to query application about its audio buffer

        Note: This function is called from an internal session thread,
        you need to have proper synchronization!

        Note: This function must never block.

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

  initially_unload_playlists : bool;
  (** Avoid loading playlists into RAM on startup. See
      {!playlist_is_in_ram} for more details. *)
}

val session_create : session_config -> session
  (** Initialize a session. The session returned will be initialized,
      but you will need to log in before you can perform any other
      operation.  Currently it is not supported to have multiple
      active sessions, and it's recommended to only call this once per
      process.

      @param config The configuration to use for the session
      @return a new session.

      @raise Error {!ERROR_BAD_API_VERSION}
      @raise Error {!ERROR_BAD_USER_AGENT}
      @raise Error {!ERROR_BAD_APPLICATION_KEY}
      @raise Error {!ERROR_API_INITIALIZATION_FAILED}
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
      text. If automatic relogin is required, use {!session_relogin}.

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

      @raise Error {!ERROR_NO_CREDENTIALS}
  *)

val session_remembered_user : session -> string option
  (** Get username of the user that will be logged in via
      {!session_relogin}.

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
      running {!session_player_play} directly, or using
      {!session_player_seek} first.  When this call returns, the track
      will have been loaded, unless an error occurred.

      @param session Your session object
      @param track The track to be loaded

      @raise Error {!ERROR_MISSING_CALLBACK}
      @raise Error {!ERROR_RESOURCE_NOT_LOADED}
      @raise Error {!ERROR_TRACK_NOT_PLAYABLE}
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

      @raise Error {!ERROR_NO_CACHE}

      Note: Prefetching is only possible if a cache is configured. *)

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
      using the {!session_friend} method. The number of users in the
      list will not be updated nor change order between calls to
      {!session_process_events}.  *)

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

      Note: Used in conjunction with {!session_set_connection_rules}
      to control how libspotify should behave in respect to network
      activity and offline synchronization. *)

val session_set_connection_rules : session -> connection_rules list -> unit
  (** Set rules for how libspotify connects to Spotify servers and
      synchronizes offline content.

      @param session Session object
      @param rules Connection rules

      Note: Used in conjunction with {!session_set_connection_type} to
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

(** Links (Spotify URIs) *)

(** These functions handle links to Spotify entities in a way that
    allows you to not care about the textual representation of the
    link. *)

type link_type =
  | LINKTYPE_INVALID
      (** Link type not valid - default until the library has parsed
          the link, or when parsing failed. *)
  | LINKTYPE_TRACK
      (** Link type is track. *)
  | LINKTYPE_ALBUM
      (** Link type is album. *)
  | LINKTYPE_ARTIST
      (** Link type is artist. *)
  | LINKTYPE_SEARCH
      (** Link type is search. *)
  | LINKTYPE_PLAYLIST
      (** Link type is playlist. *)
  | LINKTYPE_PROFILE
      (** Link type is profile. *)
  | LINKTYPE_STARRED
      (** Link type is starred. *)
  | LINKTYPE_LOCALTRACK
      (** Link type is a local file. *)
  | LINKTYPE_IMAGE
      (** Link type is an image. *)

val link_create_from_string : string -> link
  (** Create a Spotify link given a string.

      @param link A string representation of a Spotify link

      @return A link representation of the given string
      representation. If the link could not be parsed, this function
      returns a NULL pointer.
  *)

val link_create_from_track : track -> float -> link
  (** Generates a link object from a track.

      @param track A track object
      @param offset Offset in track in ms.

      @return A link representing the track
  *)

val link_create_from_album : album -> link
  (** Create a link object from an album.

      @param album An album object

      @return A link representing the album
  *)

val link_create_from_album_cover : album -> link
  (** Create an image link object from an album.

      @param album An album object

      @return A link representing the album cover. Type is set to
      {!LINKTYPE_IMAGE}.
  *)

val link_create_from_artist : artist -> link
  (** Creates a link object from an artist.

      @param artist An artist object

      @return A link object representing the artist
  *)

val link_create_from_artist_portrait : artist -> link
  (** Creates a link object pointing to an artist portrait.

      @param artist Artist browse object

      @return A link object representing an image
  *)

val link_create_from_artistbrowse_portrait : artistbrowse -> int -> link
  (** Creates a link object from an artist portrait.

      @param arb Artist browse object
      @param index The index of the portrait. Should be in the
      interval [0 .. artistbrowse_num_portraits () - 1]

      @return A link object representing an image

      Note: The difference from {!link_create_from_artist_portrait} is
      that the artist browse object may contain multiple portraits.
  *)

val link_create_from_search : search -> link
  (** Generate a link object representing the current search.

      @param search Search object

      @return A link representing the search
  *)

val link_create_from_playlist : playlist -> link
  (** Create a link object representing the given playlist.

      @param playlist Playlist object

      @return A link representing the playlist

      Note: Due to reasons in the playlist backend design and the
      Spotify URI scheme you need to wait for the playlist to be
      loaded before you can successfully construct an URI. If
      {!link_create_from_playlist} returns a NULL pointer, try again
      after the {!playlist_state_changed} callback has fired.
  *)

val link_create_from_user : user -> link
  (** Create a link object representing the given playlist.

      @param user User object

      @return A link representing the profile.
  *)

val link_create_from_image : image -> link
  (** Create a link object representing the given image.

      @param image Image object

      @return A link representing the image.
  *)

val link_as_string : link -> string
  (** Create a string representation of the given Spotify link.

      @param link The Spotify link whose string representation you are
      interested in

      @return The string representation of the link
  *)

val link_type : link -> link_type
  (** The link type of the specified link.

      @param link The Spotify link whose type you are interested in

      @return The link type of the specified link - see the
      sp_linktype enum for possible values
  *)

val link_as_track : link -> track
  (** The track representation for the given link.

      @param link The Spotify link whose track you are interested in

      @return The track representation of the given track link. If the
      link is not of track type then NULL is returned. *)

val link_as_track_and_offset : link -> track * float
  (** The track and offset into track representation for the given link.

      @param link The Spotify link whose track you are interested in

      @return The track and offset representation of the given track
      link. If the link is not of track type then NULL is
      returned. *)

val link_as_album : link -> album
  (** The album representation for the given link.

      @param link The Spotify link whose album you are interested in

      @return The album representation of the given album link. If the
      link is not of album type then NULL is returned.
  *)

val link_as_artist : link -> artist
  (** The artist representation for the given link.

      @param link The Spotify link whose artist you are interested in

      @return The artist representation of the given link If the link
      is not of artist type then NULL is returned. *)

val link_as_user : link -> user
  (** The user representation for the given link.

      @param link The Spotify link whose user you are interested in

      @return The user representation of the given link If the link is
      not of user type then NULL is returned. *)

val link_release : link -> unit
  (** Destroy the reference to the link. Any subsequent operation on
      the link will raise {!NULL}. *)

(** {6 Track subsystem} *)

val track_is_loaded : track -> bool
  (** Return whether or not the track metadata is loaded.

      @param track The track

      @return [true] if track is loaded

      Note: This is equivalent to checking if {!error} not returns
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

      Note: The track must be loaded or this function will always
      return false.
      See {!track_is_loaded}
  *)

val track_is_local : session -> track -> bool
  (** Return true if the track is a local file.

      @param session Session
      @param track The track

      @return [true] if track is a local file.

      Note: The track must be loaded or this function will always
      return false.
      See {!track_is_loaded}
  *)

val track_is_autolinked : session -> track -> bool
  (** Return true if the track is autolinked to another track.

      @param session Session
      @param track The track

      @return [true] if track is autolinked.

      Note: The track must be loaded or this function will always
      return false.

      See {!track_is_loaded}
  *)

val track_is_starred : session -> track -> bool
  (** Return true if the track is starred by the currently logged in user.

      @param session Session
      @param track The track

      @return [true] if track is starred.

      Note: The track must be loaded or this function will always
      return false.
      See {!track_is_loaded}
  *)

val track_set_starred : session -> track list -> bool -> unit
  (** Star/Unstar the specified tracks

      @param session Session
      @param tracks List of tracks.
      @param star Starred status of the tracks

      Note: This will fail silently if playlists are disabled.
      See {!set_playlists_enabled}
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

(** {6 Album subsystem} *)

(** Album types. *)
type album_type =
  | ALBUMTYPE_ALBUM
      (** Normal album. *)
  | ALBUMTYPE_SINGLE
      (** Single. *)
  | ALBUMTYPE_COMPILATION
      (** Compilation. *)
  | ALBUMTYPE_UNKNOWN
      (** Unknown type. *)

val album_is_loaded : album -> bool
  (** Check if the album object is populated with data.

      @param album Album object
      @return [true] if metadata is present, [false] if not.
  *)

val album_is_available : album -> bool
  (** Return [true] if the album is available in the current region.

      @param album The album

      @return [true] if album is available for playback, otherwise [false].

      Note: The album must be loaded or this function will always
      return [false].
      See {!album_is_loaded}
  *)

val album_artist : album -> artist
  (** Get the artist associated with the given album.

      @param album Album object
      @return A reference to the artist. NULL if the metadata has not
      been loaded yet. *)

val album_cover : album -> string
  (** Return image ID representing the album's coverart.

      @param album Album object

      @return ID byte sequence that can be passed to {!image_create}
      If the album has no image or the metadata for the album is not
      loaded yet, this function returns the empty string.

      See {!image_create}
  *)

val album_name : album -> string
  (** Return name of album.

      @param album Album object

      @return Name of album.
  *)

val album_year : album -> int
  (** Return release year of specified album

      @param album Album object

      @return Release year
  *)

val album_type : album -> album_type
  (** Return type of specified album.

      @param album Album object

      @return The type of the album.
  *)

val album_release : album -> unit
  (** Destroy the reference to the album. Any subsequent operation on
      the album will raise {!NULL}. *)

(** {6 Artist subsystem} *)

val artist_name : artist -> string
  (** Return name of artist.

      @param artist Artist object

      @return Name of artist.
  *)

val artist_is_loaded : artist -> bool
  (** Check if the artist object is populated with data.

      @param artist An artist object

      @return [true] if metadata is present, [false] if not.
  *)

val artist_release : album -> unit
  (** Destroy the reference to the artist. Any subsequent operation on
      the artist will raise {!NULL}. *)

(** {6 Album browsing} *)

(** Browsing adds additional information to what an {!album} holds. It
    retrieves copyrights, reviews and tracks of the album. *)

val albumbrowse_create : session -> album -> (albumbrowse -> unit) -> albumbrowse
  (** Initiate a request for browsing an album.

      @param session Session object
      @param album Album to be browsed. The album metadata does not
      have to be loaded
      @param callback Callback to be invoked when browsing has been
      completed.

      @return Album browse object
  *)

val albumbrowse_is_loaded : albumbrowse -> bool
  (** Check if an album browse request is completed.

      @param alb Album browse object

      @return [true] if browsing is completed, [false] if not.
  *)

val albumbrowse_error : albumbrowse -> error
  (** Check if browsing returned an error code.

      @param alb Album browse object

      @return One of the following errors:
      - {!ERROR_OK}
      - {!ERROR_IS}_LOADING
      - {!ERROR_OTHER}_PERMANENT
      - {!ERROR_OTHER}_TRANSIENT
  *)

val albumbrowse_album : albumbrowse -> album
  (** Given an album browse object, return the pointer to its album object.

      @param alb Album browse object

      @return Album object
  *)

val albumbrowse_artist : albumbrowse -> artist
  (** Given an album browse object, return the pointer to its artist
      object.

      @param alb Album browse object

      @return Artist object
  *)

val albumbrowee_num_copyrights : albumbrowse -> int
  (** Given an album browse object, return number of copyright
      strings.

      @param alb Album browse object

      @return Number of copyright strings available, 0 if unknown.
  *)

val albumbrowse_copyright : albumbrowse -> int -> string
  (** Given an album browse object, return one of its copyright
      strings.

      @param alb Album browse object
      @param index The index for the copyright string. Should be in
      the interval [0 .. sp_albumbrowse_num_copyrights () - 1]

      @return Copyright string in UTF-8 format.

      @raise Invalid_argument if the index is invalid.
  *)

val albumbrowse_num_tracks : albumbrowse -> int
  (** Given an album browse object, return number of tracks.

      @param alb Album browse object

      @return Number of tracks on album
  *)

val albumbrowse_track : albumbrowse -> int -> track
  (** Given an album browse object, return a pointer to one of its
      tracks.

      @param alb Album browse object
      @param index The index for the track. Should be in the interval
      [0 .. sp_albumbrowse_num_tracks () - 1]

      @return A track.
  *)

val albumbrowse_review : albumbrowse -> string
  (** Given an album browse object, return its review.

      @param alb Album browse object

      @return Review string in UTF-8 format.
  *)

val albumbrowse_release : album -> unit
  (** Destroy the reference to the albumbrowse. Any subsequent
      operation on the albumbrowse will raise {!NULL}. *)

(** {6 Artist browsing}

    Artist browsing initiates the fetching of information for a
    certain artist.

    Note: There is currently no built-in functionality available for
    getting the albums belonging to an artist. For now, just iterate
    over all tracks and note the album to build a list of all albums.
    This feature will be added in a future version of the library.
*)

val artistbrowse_create : session -> artist -> (artistbrowse -> unit) -> artistbrowse
  (** Initiate a request for browsing an artist.

      @param session Session object
      @param artist Artist to be browsed. The artist metadata does not
      have to be loaded
      @param callback Callback to be invoked when browsing has been
      completed.

      @return Artist browse object
  *)

val aristbrowse_is_loaded : artistbrowse -> bool
  (** Check if an artist browse request is completed

      @param arb Artist browse object

      @return [true] if browsing is completed, [false] if not
  *)

val artistbrowse_error : artistbrowse -> error
  (** Check if browsing returned an error code.

      @param arb Artist browse object

      @return One of the following errors:
      - {!ERROR_OK}
      - {!ERROR_IS_LOADING}
      - {!ERROR_OTHER_PERMANENT}
      - {!ERROR_OTHER_TRANSIENT}
  *)

val artistbrowse_artist : artistbrowse -> artist
  (** Given an artist browse object, return to its artist object.

      @param arb Artist browse object

      @return Artist object
  *)

val artistbrowse_num_portraits : artistbrowse -> int
  (** Given an artist browse object, return number of portraits
      available.

      @param arb Artist browse object

      @return Number of portraits for given artist
  *)

val artistbrowse_portrait : artistbrowse -> int -> string
  (** Return image ID representing a portrait of the artist.

      @param arb Artist object
      @param index The index of the portrait. Should be in the
      interval [0 .. artistbrowse_num_portraits () - 1]

      @return ID byte sequence that can be passed to {!image_create}

      See {!image_create}
  *)

val artistbrowse_num_tracks : artistbrowse -> int
  (** Given an artist browse object, return number of tracks.

      @param arb Artist browse object

      @return Number of tracks for given artist
  *)

val artistbrowse_track : artistbrowse -> int -> track
  (** Given an artist browse object, return one of its tracks.

      @param arb Album browse object
      @param index The index for the track. Should be in the interval
      [0 .. artistbrowse_num_tracks - 1]

      @return A track object, or NULL if the index is out of range.
  *)

val artistbrowse_num_albums : artistbrowse -> int
  (** Given an artist browse object, return number of albums.

      @param arb Artist browse object

      @return Number of albums for given artist
  *)

val artistbrowse_album : artistbrowse -> int -> album
  (** Given an artist browse object, return one of its albums.

      @param arb Album browse object

      @param index The index for the album. Should be in the interval
      [0 .. artistbrowse_num_albums () - 1]

      @return An album object, or NULL if the index is out of range.
  *)

val artistbrowse_num_similar_artists : artistbrowse -> int
  (** Given an artist browse object, return number of similar artists.

      @param arb Artist browse object

      @return Number of similar artists for given artist
  *)

val artistbrowse_similar_artist : artistbrowse -> int -> artist
  (** Given an artist browse object, return a similar artist by index.

      @param arb Album browse object
      @param index The index for the artist. Should be in the interval
      [0 .. artistbrowse_num_similar_artists () - 1]

      @return An artist object.
  *)

val artistbrowse_biography : artistbrowse -> string
  (** Given an artist browse object, return the artists biography.

      Note: This function must be called from the same thread that did
      {!session_create}.

      @param arb Artist browse object

      @return Biography string in UTF-8 format.
  *)

val artistbrowse_release : artist -> unit
  (** Destroy the reference to the artistbrowse. Any subsequent
      operation on the artistbrowse will raise {!NULL}. *)

(** {6 Image handling} *)

(** Image format. *)
type image_format =
  | IMAGE_FORMAT_UNKNOWN
      (** Unknown image format. *)
  | IMAGE_FORMAT_JPEG
      (** JPEG image. *)

val image_create : session -> string -> image
  (** Create an image object.

      @param session Session
      @param image_id Spotify image ID

      @return An image object.

      See {!album_cover}.
      See {!artistbrowse_portrait}.
  *)

val image_create_from_link : session -> link -> image
  (** Create an image object from a link.

      @param session Session
      @param l Spotify link object. This must be of {!LINKTYPE_IMAGE}
      type.

      @return An image object.

      See {!image_create}.
  *)

type image_load_callback_id
  (** Id of a load image callback. Used to remove the callback. *)

val image_add_load_callback : image -> (image -> unit) -> image_load_callback_id
  (** Add a callback that will be invoked when the image is loaded.

      If an image is loaded, and loading fails, the image will behave
      like an empty image.

      @param image Image object
      @param callback Callback that will be called when image has been
      fetched. *)

val image_remove_load_callback : image -> image_load_callback_id -> unit
  (** Remove an image load callback previously added with
      {!image_add_load_callback}.

      @param image Image object
      @param callback Callback that will not be called when image has
      been fetched.
  *)

val image_is_loaded : image -> bool
  (** Check if an image is loaded. Before the image is loaded, the
      rest of the methods will behave as if the image is empty.

      @param image Image object

      @return [true] if image is loaded, [false] otherwise
  *)

val image_error : image -> error
  (** Check if image retrieval returned an error code.

      @param image Image object

      @return One of the following errors:
      - {!ERROR_OK}
      - {!ERROR_IS_LOADING}
      - {!ERROR_OTHER_PERMANENT}
      - {!ERROR_OTHER_TRANSIENT}
  *)

val image_format : image -> image_format
  (** Get image format.

      @param image Image object

      @return Image format as described by {!image_format}.
  *)

val image_data : image -> bytes
  (** Get image data.

      @param image Image object

      @return Raw image data
  *)

val image_image_id : image -> string
  (** Get image ID.

      @param image Image object

      @return Image ID
  *)

val image_release : artist -> unit
  (** Destroy the reference to the image. Any subsequent operation on
      the image will raise {!NULL}. *)

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
