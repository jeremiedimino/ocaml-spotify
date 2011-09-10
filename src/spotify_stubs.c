/*
 * spotify_stubs.c
 * ---------------
 * Copyright : (c) 2011, Jeremie Dimino <jeremie@dimino.org>
 * Licence   : BSD3
 *
 * This file is a part of ocaml-spotify.
 */

#include <caml/mlvalues.h>
#include <caml/alloc.h>
#include <caml/memory.h>
#include <caml/custom.h>
#include <caml/threads.h>
#include <caml/fail.h>
#include <caml/callback.h>
#include <caml/bigarray.h>

#include <string.h>
#include <pthread.h>
#include <stdio.h>

#include <libspotify/api.h>

#define DEBUG_MODE

#if defined(DEBUG_MODE)
#  include <unistd.h>
#  include <sys/syscall.h>
#  define DEBUG(fmt, ...) { fprintf(stderr, "ocaml-spotify-debug[%d]: %s: " fmt "\n", (pid_t)syscall(SYS_gettid), __FUNCTION__, ##__VA_ARGS__); fflush(stderr); }
#else
#  define DEBUG(fmt, ...)
#endif

CAMLprim value ocaml_spotify_string_of_bytes(value bytes)
{
  intnat len = Caml_ba_array_val(bytes)->dim[0];
  value str = caml_alloc_string(len);
  memcpy(String_val(str), Caml_ba_data_val(bytes), len);
  return str;
}

static void* xmalloc(size_t size)
{
  void *ptr = malloc(size);
  if (ptr == NULL) {
    perror("cannot allocate memory");
    abort();
  }
  return ptr;
}

#define new(type) (type*)xmalloc(sizeof(type))

/* +-----------------------------------------------------------------+
   | Custom values                                                   |
   +-----------------------------------------------------------------+ */

static int spotify_compare(value a, value b)
{
  return (int)(Data_custom_val(a) - Data_custom_val(b));
}

static long spotify_hash(value x)
{
  return (long)Data_custom_val(x);
}

#define DEFINE_OPS(name, id)                                            \
  static void name##_finalize(value x)                                  \
  {                                                                     \
    sp_##name *name = *(sp_##name **)Data_custom_val(x);                \
    if (name) sp_##name##_release(name);                                \
  }                                                                     \
                                                                        \
  static struct custom_operations name##_ops = {                        \
    id,                                                                 \
    name##_finalize,                                                    \
    spotify_compare,                                                    \
    spotify_hash,                                                       \
    custom_serialize_default,                                           \
    custom_deserialize_default                                          \
  };                                                                    \
                                                                        \
  static value alloc_##name(sp_##name *name)                            \
  {                                                                     \
    value x = caml_alloc_custom(&name##_ops, sizeof(sp_##name *), 0, 1); \
    *(sp_##name **)Data_custom_val(x) = name;                           \
    return x;                                                           \
  }                                                                     \
                                                                        \
  static sp_##name *get_##name(value x)                                 \
  {                                                                     \
    sp_##name *name = *(sp_##name **)Data_custom_val(x);                \
    if (name == NULL) caml_raise(*caml_named_value("spotify:null"));    \
    return name;                                                        \
  }

#define Session_val(v) *(sp_session **)Data_custom_val(v)
#define Track_val(v) *(sp_track **)Data_custom_val(v)
#define Album_val(v) *(sp_album **)Data_custom_val(v)
#define Artist_val(v) *(sp_artist **)Data_custom_val(v)
#define Artistbrowse_val(v) *(sp_artistbrowse **)Data_custom_val(v)
#define Toplistbrowse_val(v) *(sp_toplistbrowse **)Data_custom_val(v)
#define Link_val(v) *(sp_link **)Data_custom_val(v)
#define Image_val(v) *(sp_image **)Data_custom_val(v)
#define User_val(v) *(sp_user **)Data_custom_val(v)
#define Playlist_val(v) *(sp_playlist **)Data_custom_val(v)
#define Playlistcontainer_val(v) *(sp_playlistcontainer **)Data_custom_val(v)
#define Inbox_val(v) *(sp_inbox **)Data_custom_val(v)

DEFINE_OPS(track, "spotify:track")
DEFINE_OPS(album, "spotify:album")
DEFINE_OPS(artist, "spotify:artist")
DEFINE_OPS(artistbrowse, "spotify:artistbrowse")
DEFINE_OPS(toplistbrowse, "spotify:toplistbrowse")
DEFINE_OPS(link, "spotify:link")
DEFINE_OPS(image, "spotify:image")
DEFINE_OPS(user, "spotify:user")
DEFINE_OPS(playlist, "spotify:playlist")
DEFINE_OPS(playlistcontainer, "spotify:playlistcontainer")
DEFINE_OPS(inbox, "spotify:inbox")

static sp_session *get_session(value x)
{
  sp_session *session = Session_val(x);
  if (session == NULL) caml_raise(*caml_named_value("spotify:null"));
  return session;
}

#define DEFINE_OPS_WITH_CALLBACK(name, id)                              \
  struct name {                                                         \
    sp_##name *sp_##name;                                               \
    value callback;                                                     \
    value name;                                                         \
  };                                                                    \
                                                                        \
  static void name##_finalize(value x)                                  \
  {                                                                     \
    struct name *name = *(struct name **)Data_custom_val(x);            \
    if (name) {                                                         \
      caml_remove_generational_global_root(&(name->callback));          \
      caml_remove_generational_global_root(&(name->name));              \
      sp_##name##_release(name->sp_##name);                             \
      free(name);                                                       \
    }                                                                   \
  }                                                                     \
                                                                        \
  static struct custom_operations name##_ops = {                        \
    id,                                                                 \
    name##_finalize,                                                    \
    spotify_compare,                                                    \
    spotify_hash,                                                       \
    custom_serialize_default,                                           \
    custom_deserialize_default                                          \
  };                                                                    \
                                                                        \
  static value alloc_##name(struct name *name)                          \
  {                                                                     \
    value x = caml_alloc_custom(&name##_ops, sizeof(struct name *), 0, 1); \
    *(struct name **)Data_custom_val(x) = name;                         \
    return x;                                                           \
  }                                                                     \
                                                                        \
  static struct name *get_##name(value x)                               \
  {                                                                     \
    struct name *name = *(struct name **)Data_custom_val(x);            \
    if (name == NULL) caml_raise(*caml_named_value("spotify:null"));    \
    return name;                                                        \
  }

#define Search_val(v) *(struct search **)Data_custom_val(v)
#define Albumbrowse_val(v) *(struct albumbrowse **)Data_custom_val(v)

DEFINE_OPS_WITH_CALLBACK(search, "spotify:search")
DEFINE_OPS_WITH_CALLBACK(albumbrowse, "spotify:albumbrowse")

/* +-----------------------------------------------------------------+
   | Error handling                                                  |
   +-----------------------------------------------------------------+ */

static void fail(const char *func, enum sp_error error)
{
  value args[2];
  args[0] = caml_copy_string(func);
  args[1] = Val_int(error);
  caml_raise_with_args(*caml_named_value("spotify:error"), 2, args);
}

CAMLprim value ocaml_spotify_error_message(value error)
{
  return caml_copy_string(sp_error_message(Int_val(error)));
}

/* +-----------------------------------------------------------------+
   | NULL checking                                                   |
   +-----------------------------------------------------------------+ */

CAMLprim value ocaml_spotify_is_null(value x)
{
  return Val_bool(Data_custom_val(x) == NULL);
}

/* +-----------------------------------------------------------------+
   | Session handling                                                |
   +-----------------------------------------------------------------+ */

CAMLprim value ocaml_spotify_get_api_version()
{
  return Val_int(SPOTIFY_API_VERSION);
}

/* User data attached to sessions. */
struct userdata {
  value session;
  /* The session value. */
  value callbacks;
  /* The callbacks. */
};

/* Try to register the thread as a thread running OCaml code.

   If it was not already registered, then we must acquire the runtime
   system in order to call ocaml code. */
#define ENTER_CALLBACK                                          \
  int __caml_thread_registered = caml_c_thread_register();      \
  if (__caml_thread_registered) caml_acquire_runtime_system();  \

/* If the thread has been registered for the first time at the
   beginning of the callback, release the runtime system and
   unregister it. */
#define LEAVE_CALLBACK                                          \
  if (__caml_thread_registered) {                               \
    caml_release_runtime_system();                              \
    caml_c_thread_unregister();                                 \
  }

static void logged_in(sp_session *session, sp_error error)
{
  ENTER_CALLBACK;
  struct userdata *data = (struct userdata*)sp_session_userdata(session);
  caml_callback3(caml_get_public_method(data->callbacks, hash_variant("logged_in")), data->callbacks, data->session, Val_int(error));
  LEAVE_CALLBACK;
}

static void logged_out(sp_session *session)
{
  ENTER_CALLBACK;
  struct userdata *data = (struct userdata*)sp_session_userdata(session);
  caml_callback2(caml_get_public_method(data->callbacks, hash_variant("logged_out")), data->callbacks, data->session);
  LEAVE_CALLBACK;
}

static void metadata_updated(sp_session *session)
{
  ENTER_CALLBACK;
  struct userdata *data = (struct userdata*)sp_session_userdata(session);
  caml_callback2(caml_get_public_method(data->callbacks, hash_variant("metadata_updated")), data->callbacks, data->session);
  LEAVE_CALLBACK;
}

static void connection_error(sp_session *session, sp_error error)
{
  ENTER_CALLBACK;
  struct userdata *data = (struct userdata*)sp_session_userdata(session);
  caml_callback3(caml_get_public_method(data->callbacks, hash_variant("connection_error")), data->callbacks, data->session, Val_int(error));
  LEAVE_CALLBACK;
}

static void message_to_user(sp_session *session, const char *message)
{
  ENTER_CALLBACK;
  struct userdata *data = (struct userdata*)sp_session_userdata(session);
  caml_callback3(caml_get_public_method(data->callbacks, hash_variant("message_to_user")), data->callbacks, data->session, caml_copy_string(message));
  LEAVE_CALLBACK;
}

static void notify_main_thread(sp_session *session)
{
  ENTER_CALLBACK;
  struct userdata *data = (struct userdata*)sp_session_userdata(session);
  caml_callback2(caml_get_public_method(data->callbacks, hash_variant("notify_main_thread")), data->callbacks, data->session);
  LEAVE_CALLBACK;
}

static int frame_size(const sp_audioformat *format)
{
  switch (format->sample_type) {
  case SP_SAMPLETYPE_INT16_NATIVE_ENDIAN:
    return format->channels * 2;
    break;
  default:
    return -1;
  }
}

static int music_delivery(sp_session *session, const sp_audioformat *format, const void *frames, int num_frames)
{
  ENTER_CALLBACK;
  value audio_format = Val_int(0);
  value bytes = Val_int(0);
  value result;
  Begin_roots2(audio_format, bytes);
  struct userdata *data = (struct userdata*)sp_session_userdata(session);
  value args[5];
  audio_format = caml_alloc_tuple(3);
  Field(audio_format, 0) = Val_int(format->sample_type);
  Field(audio_format, 1) = Val_int(format->sample_rate);
  Field(audio_format, 2) = Val_int(format->channels);
  intnat dim[1];
  dim[0] = num_frames * frame_size(format);
  bytes = caml_ba_alloc(CAML_BA_UINT8 | CAML_BA_C_LAYOUT | CAML_BA_EXTERNAL, 1, (void*)frames, dim);
  args[0] = data->callbacks;
  args[1] = data->session;
  args[2] = audio_format;
  args[3] = bytes;
  args[4] = Val_int(num_frames);
  result = caml_callbackN(caml_get_public_method(data->callbacks, hash_variant("music_delivery")), 5, args);
  End_roots();
  LEAVE_CALLBACK;
  return Int_val(result);
}

static void play_token_lost(sp_session *session)
{
  ENTER_CALLBACK;
  struct userdata *data = (struct userdata*)sp_session_userdata(session);
  caml_callback2(caml_get_public_method(data->callbacks, hash_variant("play_token_lost")), data->callbacks, data->session);
  LEAVE_CALLBACK;
}

static void log_message(sp_session *session, const char *message)
{
  ENTER_CALLBACK;
  struct userdata *data = (struct userdata*)sp_session_userdata(session);
  caml_callback3(caml_get_public_method(data->callbacks, hash_variant("log_message")), data->callbacks, data->session, caml_copy_string(message));
  LEAVE_CALLBACK;
}

static void end_of_track(sp_session *session)
{
  ENTER_CALLBACK;
  struct userdata *data = (struct userdata*)sp_session_userdata(session);
  caml_callback2(caml_get_public_method(data->callbacks, hash_variant("end_of_track")), data->callbacks, data->session);
  LEAVE_CALLBACK;
}

static void streaming_error(sp_session *session, sp_error error)
{
  ENTER_CALLBACK;
  struct userdata *data = (struct userdata*)sp_session_userdata(session);
  caml_callback3(caml_get_public_method(data->callbacks, hash_variant("streaming_error")), data->callbacks, data->session, Val_int(error));
  LEAVE_CALLBACK;
}

static void userinfo_updated(sp_session *session)
{
  ENTER_CALLBACK;
  struct userdata *data = (struct userdata*)sp_session_userdata(session);
  caml_callback2(caml_get_public_method(data->callbacks, hash_variant("userinfo_updated")), data->callbacks, data->session);
  LEAVE_CALLBACK;
}

static void start_playback(sp_session *session)
{
  ENTER_CALLBACK;
  struct userdata *data = (struct userdata*)sp_session_userdata(session);
  caml_callback2(caml_get_public_method(data->callbacks, hash_variant("start_playback")), data->callbacks, data->session);
  LEAVE_CALLBACK;
}

static void stop_playback(sp_session *session)
{
  ENTER_CALLBACK;
  struct userdata *data = (struct userdata*)sp_session_userdata(session);
  caml_callback2(caml_get_public_method(data->callbacks, hash_variant("stop_playback")), data->callbacks, data->session);
  LEAVE_CALLBACK;
}

static void get_audio_buffer_stats(sp_session *session, sp_audio_buffer_stats *stats)
{
  ENTER_CALLBACK;
  struct userdata *data = (struct userdata*)sp_session_userdata(session);
  value result = caml_callback2(caml_get_public_method(data->callbacks, hash_variant("get_audio_buffer_stats")), data->callbacks, data->session);
  stats->samples = Int_val(Field(result, 0));
  stats->stutter = Int_val(Field(result, 1));
  LEAVE_CALLBACK;
}

static void offline_status_updated(sp_session *session)
{
  ENTER_CALLBACK;
  struct userdata *data = (struct userdata*)sp_session_userdata(session);
  caml_callback2(caml_get_public_method(data->callbacks, hash_variant("offline_status_updated")), data->callbacks, data->session);
  LEAVE_CALLBACK;
}

static sp_session_callbacks callbacks = {
  .logged_in = logged_in,
  .logged_out = logged_out,
  .metadata_updated = metadata_updated,
  .connection_error = connection_error,
  .message_to_user = message_to_user,
  .notify_main_thread = notify_main_thread,
  .music_delivery = music_delivery,
  .play_token_lost = play_token_lost,
  .log_message = log_message,
  .end_of_track = end_of_track,
  .streaming_error = streaming_error,
  .userinfo_updated = userinfo_updated,
  .start_playback = start_playback,
  .stop_playback = stop_playback,
  .get_audio_buffer_stats = get_audio_buffer_stats,
  .offline_status_updated = offline_status_updated
};

static void session_finalize(value x)
{
  sp_session *session = Session_val(x);
  if (session) {
    struct userdata *data = (struct userdata*)sp_session_userdata(session);
    caml_remove_generational_global_root(&(data->session));
    caml_remove_generational_global_root(&(data->callbacks));
    free(data);
    sp_session_release(session);
  }
}

static struct custom_operations session_ops = {
  "spotify:session",
  session_finalize,
  spotify_compare,
  spotify_hash,
  custom_serialize_default,
  custom_deserialize_default
};

static value alloc_session(sp_session *session)
{
  value x = caml_alloc_custom(&session_ops, sizeof(sp_session *), 0, 1);
  Session_val(x) = session;
  return x;
}

CAMLprim value ocaml_spotify_session_create(value val_config)
{
  CAMLparam1(val_config);
  CAMLlocal1(result);
  sp_session_config config;
  memset(&config, 0, sizeof(config));
  config.api_version = Int_val(Field(val_config, 0));
  config.cache_location = String_val(Field(val_config, 1));
  config.settings_location = String_val(Field(val_config, 2));
  config.application_key = String_val(Field(val_config, 3));
  config.application_key_size = caml_string_length(Field(val_config, 3));
  config.user_agent = String_val(Field(val_config, 4));
  config.callbacks = &callbacks;
  config.compress_playlists = Bool_val(Field(val_config, 6));
  config.dont_save_metadata_for_playlists = Bool_val(Field(val_config, 7));
  config.initially_unload_playlists = Bool_val(Field(val_config, 8));
  struct userdata *data = new(struct userdata);
  result = alloc_session(NULL);
  data->session = result;
  data->callbacks = Field(val_config, 5);
  caml_register_generational_global_root(&(data->session));
  caml_register_generational_global_root(&(data->callbacks));
  config.userdata = (void*)data;
  sp_error error = sp_session_create(&config, &(Session_val(result)));
  if (error) {
    free(data);
    fail("sp_session_create", error);
  }
  CAMLreturn(result);
}

CAMLprim value ocaml_spotify_session_release(value session)
{
  session_finalize(session);
  Session_val(session) = NULL;
  return Val_unit;
}

CAMLprim value ocaml_spotify_session_login(value val_session, value username, value password, value remember_me)
{
  sp_session *session = get_session(val_session);
  sp_session_login(session, String_val(username), String_val(password), Bool_val(remember_me));
  return Val_unit;
}

CAMLprim value ocaml_spotify_session_relogin(value val_session)
{
  sp_session *session = get_session(val_session);
  sp_error error = sp_session_relogin(session);
  if (error) fail("sp_session_relogin", error);
  return Val_unit;
}

CAMLprim value ocaml_spotify_session_remembered_user(value val_session)
{
  CAMLparam1(val_session);
  CAMLlocal1(result);
  sp_session *session = get_session(val_session);
  size_t len = sp_session_remembered_user(session, NULL, 0);
  if (len == (size_t)-1) CAMLreturn(Val_int(1));
  char buffer[len + 1];
  sp_session_remembered_user(session, buffer, len + 1);
  result = caml_alloc_tuple(1);
  Store_field(result, 0, caml_copy_string(buffer));
  CAMLreturn(result);
}

CAMLprim value ocaml_spotify_session_forget_me(value val_session)
{
  sp_session_forget_me(get_session(val_session));
  return Val_unit;
}

CAMLprim value ocaml_spotify_session_user(value val_session)
{
  sp_user *user = sp_session_user(get_session(val_session));
  if (user) sp_user_add_ref(user);
  return alloc_user(user);
}

CAMLprim value ocaml_spotify_session_logout(value val_session)
{
  sp_session_logout(get_session(val_session));
  return Val_unit;
}

CAMLprim value ocaml_spotify_session_connection_state(value val_session)
{
  return Val_int(sp_session_connectionstate(get_session(val_session)));
}

CAMLprim value ocaml_spotify_session_set_cache_size(value session, value size)
{
  sp_session_set_cache_size(get_session(session), Long_val(size));
  return Val_unit;
}

CAMLprim value ocaml_spotify_session_process_events(value session)
{
  int timeout;
  sp_session_process_events(get_session(session), &timeout);
  return caml_copy_double((double)timeout / 1000);
}

CAMLprim value ocaml_spotify_session_player_load(value session, value track)
{
  sp_error error = sp_session_player_load(get_session(session), get_track(track));
  if (error) fail("sp_session_player_load", error);
  return Val_unit;
}

CAMLprim value ocaml_spotify_session_player_seek(value session, value offset)
{
  sp_session_player_seek(get_session(session), (int)(Double_val(offset) * 1000));
  return Val_unit;
}

CAMLprim value ocaml_spotify_session_player_play(value session, value play)
{
  sp_session_player_play(get_session(session), Bool_val(play));
  return Val_unit;
}

CAMLprim value ocaml_spotify_session_player_unload(value session)
{
  sp_session_player_unload(get_session(session));
  return Val_unit;
}

CAMLprim value ocaml_spotify_session_player_prefetch(value session, value track)
{
  sp_error error = sp_session_player_prefetch(get_session(session), get_track(track));
  if (error) fail("sp_session_player_prefetch", error);
  return Val_unit;
}

CAMLprim value ocaml_spotify_session_playlistcontainer(value session)
{
  sp_playlistcontainer *plc = sp_session_playlistcontainer(get_session(session));
  if (plc) sp_playlistcontainer_add_ref(plc);
  return alloc_playlistcontainer(plc);
}

CAMLprim value ocaml_spotify_session_inbox_create(value session)
{
  sp_playlist *playlist = sp_session_inbox_create(get_session(session));
  return alloc_playlist(playlist);
}

CAMLprim value ocaml_spotify_session_starred_create(value session)
{
  sp_playlist *playlist = sp_session_starred_create(get_session(session));
  return alloc_playlist(playlist);
}

CAMLprim value ocaml_spotify_session_starred_for_user_create(value session, value username)
{
  sp_playlist *playlist = sp_session_starred_for_user_create(get_session(session), String_val(username));
  return alloc_playlist(playlist);
}

CAMLprim value ocaml_spotify_session_publishedcontainer_for_user_create(value session, value username)
{
  sp_playlistcontainer *plc = sp_session_publishedcontainer_for_user_create(get_session(session), Is_block(username) ? String_val(Field(username, 0)) : NULL);
  return alloc_playlistcontainer(plc);
}

CAMLprim value ocaml_spotify_session_preferred_bitrate(value session, value bitrate)
{
  sp_session_preferred_bitrate(get_session(session), Int_val(bitrate));
  return Val_unit;
}

CAMLprim value ocaml_spotify_session_preferred_offline_bitrate(value session, value bitrate, value allow_resync)
{
  sp_session_preferred_offline_bitrate(get_session(session), Int_val(bitrate), Bool_val(allow_resync));
  return Val_unit;
}

CAMLprim value ocaml_spotify_session_num_friends(value session)
{
  return Val_int(sp_session_num_friends(get_session(session)));
}

CAMLprim value ocaml_spotify_session_friend(value session, value index)
{
  sp_user *user = sp_session_friend(get_session(session), Int_val(index));
  if (user) sp_user_add_ref(user);
  return alloc_user(user);
}

CAMLprim value ocaml_spotify_session_set_connection_type(value session, value type)
{
  sp_session_set_connection_type(get_session(session), Int_val(type));
  return Val_unit;
}

CAMLprim value ocaml_spotify_session_set_connection_rules(value session, value list)
{
  sp_connection_rules rules = 0;
  while (Is_block(list)) {
    rules |= 1 << Int_val(Field(list, 0));
    list = Field(list, 1);
  }
  sp_session_set_connection_rules(get_session(session), rules);
  return Val_unit;
}

CAMLprim value ocaml_spotify_offline_tracks_to_sync(value session)
{
  return Val_int(sp_offline_tracks_to_sync(get_session(session)));
}

CAMLprim value ocaml_spotify_offline_num_playlists(value session)
{
  return Val_int(sp_offline_num_playlists(get_session(session)));
}

CAMLprim value ocaml_spotify_offline_sync_get_status(value session)
{
  CAMLparam1(session);
  CAMLlocal2(result, x);
  sp_offline_sync_status status;
  if (sp_offline_sync_get_status(get_session(session), &status)) {
    x = caml_alloc_tuple(9);
    Store_field(x, 0, Val_int(status.queued_tracks));
    Store_field(x, 1, caml_copy_int64(status.queued_bytes));
    Store_field(x, 2, Val_int(status.done_tracks));
    Store_field(x, 3, caml_copy_int64(status.done_bytes));
    Store_field(x, 4, Val_int(status.copied_tracks));
    Store_field(x, 5, caml_copy_int64(status.copied_bytes));
    Store_field(x, 6, Val_int(status.willnotcopy_tracks));
    Store_field(x, 7, Val_int(status.error_tracks));
    Store_field(x, 8, Val_bool(status.syncing));
    result = caml_alloc_tuple(1);
    Field(result, 0) = x;
    CAMLreturn(result);
  } else
    CAMLreturn(Val_int(0));
}

CAMLprim value ocaml_spotify_offline_time_left(value session)
{
  return Val_int(sp_offline_time_left(get_session(session)));
}

CAMLprim value ocaml_spotify_session_user_country(value session)
{
  return Val_int(sp_session_user_country(get_session(session)));
}

/* +-----------------------------------------------------------------+
   | Links                                                           |
   +-----------------------------------------------------------------+ */

CAMLprim value ocaml_spotify_link_create_from_string(value string)
{
  return alloc_link(sp_link_create_from_string(String_val(string)));
}

CAMLprim value ocaml_spotify_link_create_from_track(value track, value offset)
{
  return alloc_link(sp_link_create_from_track(get_track(track), (int)(Double_val(offset) * 1000)));
}

CAMLprim value ocaml_spotify_link_create_from_album(value album)
{
  return alloc_link(sp_link_create_from_album(get_album(album)));
}

CAMLprim value ocaml_spotify_link_create_from_album_cover(value album)
{
  return alloc_link(sp_link_create_from_album_cover(get_album(album)));
}

CAMLprim value ocaml_spotify_link_create_from_artist(value artist)
{
  return alloc_link(sp_link_create_from_artist(get_artist(artist)));
}

CAMLprim value ocaml_spotify_link_create_from_artist_portrait(value artist)
{
  return alloc_link(sp_link_create_from_artist_portrait(get_artist(artist)));
}

CAMLprim value ocaml_spotify_link_create_from_artistbrowse_portrait(value artist, value index)
{
  return alloc_link(sp_link_create_from_artistbrowse_portrait(get_artistbrowse(artist), Int_val(index)));
}

CAMLprim value ocaml_spotify_link_create_from_search(value search)
{
  return alloc_link(sp_link_create_from_search(get_search(search)->sp_search));
}

CAMLprim value ocaml_spotify_link_create_from_playlist(value playlist)
{
  return alloc_link(sp_link_create_from_playlist(get_playlist(playlist)));
}

CAMLprim value ocaml_spotify_link_create_from_user(value user)
{
  return alloc_link(sp_link_create_from_user(get_user(user)));
}

CAMLprim value ocaml_spotify_link_create_from_image(value image)
{
  return alloc_link(sp_link_create_from_image(get_image(image)));
}

CAMLprim value ocaml_spotify_link_as_string(value link)
{
  sp_link *sp_link = get_link(link);
  int len = sp_link_as_string(sp_link, NULL, 0);
  char string[len + 1];
  sp_link_as_string(sp_link, string, len + 1);
  return caml_copy_string(string);
}

CAMLprim value ocaml_spotify_link_type(value link)
{
  return Val_int(sp_link_type(get_link(link)));
}

CAMLprim value ocaml_spotify_link_as_track(value link)
{
  sp_track *track = sp_link_as_track(get_link(link));
  if (track) sp_track_add_ref(track);
  return alloc_track(track);
}

CAMLprim value ocaml_spotify_link_as_track_and_offset(value link)
{
  CAMLparam1(link);
  CAMLlocal1(result);
  int offset = 0;
  sp_track *track = sp_link_as_track_and_offset(get_link(link), &offset);
  if (track) sp_track_add_ref(track);
  result = caml_alloc_tuple(2);
  Store_field(result, 0, alloc_track(track));
  Store_field(result, 1, caml_copy_double((double)offset / 1000));
  CAMLreturn(result);
}

CAMLprim value ocaml_spotify_link_as_album(value link)
{
  sp_album *album = sp_link_as_album(get_link(link));
  if (album) sp_album_add_ref(album);
  return alloc_album(album);
}

CAMLprim value ocaml_spotify_link_as_artist(value link)
{
  sp_artist *artist = sp_link_as_artist(get_link(link));
  if (artist) sp_artist_add_ref(artist);
  return alloc_artist(artist);
}

CAMLprim value ocaml_spotify_link_as_user(value link)
{
  sp_user *user = sp_link_as_user(get_link(link));
  if (user) sp_user_add_ref(user);
  return alloc_user(user);
}

CAMLprim value ocaml_spotify_link_release(value link)
{
  link_finalize(link);
  Link_val(link) = NULL;
  return Val_unit;
}

/* +-----------------------------------------------------------------+
   | Track subsystem                                                 |
   +-----------------------------------------------------------------+ */

CAMLprim value ocaml_spotify_track_is_loaded(value track)
{
  return Val_bool(sp_track_is_loaded(get_track(track)));
}

CAMLprim value ocaml_spotify_track_error(value track)
{
  return Val_int(sp_track_error(get_track(track)));
}

CAMLprim value ocaml_spotify_track_is_available(value session, value track)
{
  return Val_bool(sp_track_is_available(get_session(session), get_track(track)));
}

CAMLprim value ocaml_spotify_track_is_local(value session, value track)
{
  return Val_bool(sp_track_is_local(get_session(session), get_track(track)));
}

CAMLprim value ocaml_spotify_track_is_autolinked(value session, value track)
{
  return Val_bool(sp_track_is_autolinked(get_session(session), get_track(track)));
}

CAMLprim value ocaml_spotify_track_is_starred(value session, value track)
{
  return Val_bool(sp_track_is_starred(get_session(session), get_track(track)));
}

CAMLprim value ocaml_spotify_track_set_starred(value session, value tracks, value star)
{
  int len = 0;
  value node = tracks;
  while (Is_block(node)) {
    len++;
    node = Field(node, 1);
  }
  sp_track *track_array[len];
  int idx = 0;
  node = tracks;
  while (Is_block(node)) {
    track_array[idx++] = get_track(Field(node, 0));
    node = Field(node, 1);
  }
  sp_track_set_starred(get_session(session), track_array, len, Bool_val(star));
  return Val_unit;
}

CAMLprim value ocaml_spotify_track_num_artists(value track)
{
  return Val_int(sp_track_num_artists(get_track(track)));
}

CAMLprim value ocaml_spotify_track_artist(value track, value index)
{
  sp_artist *artist = sp_track_artist(get_track(track), Int_val(index));
  if (artist) sp_artist_add_ref(artist);
  return alloc_artist(artist);
}

CAMLprim value ocaml_spotify_track_album(value track)
{
  sp_album *album = sp_track_album(get_track(track));
  if (album) sp_album_add_ref(album);
  return alloc_album(album);
}

CAMLprim value ocaml_spotify_track_name(value track)
{
  return caml_copy_string(sp_track_name(get_track(track)));
}

CAMLprim value ocaml_spotify_track_duration(value track)
{
  return caml_copy_double((double)sp_track_duration(get_track(track)) / 1000);
}

CAMLprim value ocaml_spotify_track_popularity(value track)
{
  return Val_int(sp_track_popularity(get_track(track)));
}

CAMLprim value ocaml_spotify_track_disc(value track)
{
  return Val_int(sp_track_disc(get_track(track)));
}

CAMLprim value ocaml_spotify_track_index(value track)
{
  return Val_int(sp_track_index(get_track(track)));
}

CAMLprim value ocaml_spotify_localtrack_create(value artist, value title, value album, value length)
{
  double l = Double_val(length);
  sp_track *track = sp_localtrack_create(String_val(artist), String_val(title), String_val(album), l < 0 ? -1 : (int)(l * 1000));
  return alloc_track(track);
}

CAMLprim value ocaml_spotify_track_release(value track)
{
  track_finalize(track);
  Track_val(track) = NULL;
  return Val_unit;
}

/* +-----------------------------------------------------------------+
   | Album subsystem                                                 |
   +-----------------------------------------------------------------+ */

CAMLprim value ocaml_spotify_album_is_loaded(value album)
{
  return Val_bool(sp_album_is_loaded(get_album(album)));
}

CAMLprim value ocaml_spotify_album_is_available(value album)
{
  return Val_bool(sp_album_is_available(get_album(album)));
}

CAMLprim value ocaml_spotify_album_artist(value album)
{
  sp_artist *artist = sp_album_artist(get_album(album));
  if (artist) sp_artist_add_ref(artist);
  return alloc_artist(artist);
}

CAMLprim value ocaml_spotify_album_cover(value album)
{
  const byte *id = sp_album_cover(get_album(album));
  value str = caml_alloc_string(20);
  memcpy(String_val(str), id, 20);
  return str;
}

CAMLprim value ocaml_spotify_album_name(value album)
{
  return caml_copy_string(sp_album_name(get_album(album)));
}


CAMLprim value ocaml_spotify_album_year(value album)
{
  return Val_int(sp_album_year(get_album(album)));
}

CAMLprim value ocaml_spotify_album_type(value album)
{
  return Val_int(sp_album_type(get_album(album)));
}

CAMLprim value ocaml_spotify_album_release(value album)
{
  album_finalize(album);
  Album_val(album) = NULL;
  return Val_unit;
}

/* +-----------------------------------------------------------------+
   | Aritst subsystem                                                |
   +-----------------------------------------------------------------+ */

CAMLprim value ocaml_spotify_artist_name(value artist)
{
  return caml_copy_string(sp_artist_name(get_artist(artist)));
}

CAMLprim value ocaml_spotify_artist_is_loaded(value artist)
{
  return Val_bool(sp_artist_is_loaded(get_artist(artist)));
}

CAMLprim value ocaml_spotify_artist_release(value artist)
{
  artist_finalize(artist);
  Artist_val(artist) = NULL;
  return Val_unit;
}

/* +-----------------------------------------------------------------+
   | Album browsing                                                  |
   +-----------------------------------------------------------------+ */

static void albumbrowse_complete(sp_albumbrowse *result, void *userdata)
{
  ENTER_CALLBACK;
  struct albumbrowse *albumbrowse = (struct albumbrowse *)userdata;
  caml_callback(albumbrowse->callback, albumbrowse->albumbrowse);
  LEAVE_CALLBACK;
}

CAMLprim value ocaml_spotify_albumbrowse_create(value session, value album, value callback)
{
  struct albumbrowse *albumbrowse = new(struct albumbrowse);
  sp_albumbrowse *sp_albumbrowse = sp_albumbrowse_create(get_session(session),
                                                         Album_val(album),
                                                         albumbrowse_complete,
                                                         (void*)albumbrowse);
  albumbrowse->sp_albumbrowse = sp_albumbrowse;
  albumbrowse->callback = callback;
  albumbrowse->albumbrowse = alloc_albumbrowse(albumbrowse);
  caml_register_generational_global_root(&(albumbrowse->callback));
  caml_register_generational_global_root(&(albumbrowse->albumbrowse));
  return albumbrowse->albumbrowse;
}

CAMLprim value ocaml_spotify_albumbrowse_is_loaded(value albumbrowse)
{
  return Val_bool(sp_albumbrowse_is_loaded(get_albumbrowse(albumbrowse)->sp_albumbrowse));
}

CAMLprim value ocaml_spotify_albumbrowse_error(value albumbrowse)
{
  return Val_int(sp_albumbrowse_error(get_albumbrowse(albumbrowse)->sp_albumbrowse));
}

CAMLprim value ocaml_spotify_albumbrowse_album(value albumbrowse)
{
  sp_album *album = sp_albumbrowse_album(get_albumbrowse(albumbrowse)->sp_albumbrowse);
  if (album) sp_album_add_ref(album);
  return alloc_album(album);
}

CAMLprim value ocaml_spotify_albumbrowse_artist(value albumbrowse)
{
  sp_artist *artist = sp_albumbrowse_artist(get_albumbrowse(albumbrowse)->sp_albumbrowse);
  if (artist) sp_artist_add_ref(artist);
  return alloc_artist(artist);
}

CAMLprim value ocaml_spotify_albumbrowse_num_copyrights(value albumbrowse)
{
  return Val_int(sp_albumbrowse_num_copyrights(get_albumbrowse(albumbrowse)->sp_albumbrowse));
}

CAMLprim value ocaml_spotify_albumbrowse_copyright(value albumbrowse, value index)
{
  const char *copyright = sp_albumbrowse_copyright(get_albumbrowse(albumbrowse)->sp_albumbrowse, Int_val(index));
  if (copyright)
    return caml_copy_string(copyright);
  else
    caml_invalid_argument("Spotify.albumbrowse_copyright");
}

CAMLprim value ocaml_spotify_albumbrowse_num_tracks(value albumbrowse)
{
  return Val_int(sp_albumbrowse_num_tracks(get_albumbrowse(albumbrowse)->sp_albumbrowse));
}

CAMLprim value ocaml_spotify_albumbrowse_track(value albumbrowse, value index)
{
  sp_track *track = sp_albumbrowse_track(get_albumbrowse(albumbrowse)->sp_albumbrowse, Int_val(index));
  if (track) sp_track_add_ref(track);
  return alloc_track(track);
}

CAMLprim value ocaml_spotify_albumbrowse_review(value albumbrowse)
{
  return caml_copy_string(sp_albumbrowse_review(get_albumbrowse(albumbrowse)->sp_albumbrowse));
}

CAMLprim value ocaml_spotify_albumbrowse_release(value albumbrowse)
{
  albumbrowse_finalize(albumbrowse);
  Albumbrowse_val(albumbrowse) = NULL;
  return Val_unit;
}

/* +-----------------------------------------------------------------+
   | Search subsystem                                                |
   +-----------------------------------------------------------------+ */

static void search_complete(sp_search *result, void *userdata)
{
  ENTER_CALLBACK;
  struct search *search = (struct search *)userdata;
  caml_callback(search->callback, search->search);
  LEAVE_CALLBACK;
}

CAMLprim value ocaml_spotify_search_create(value session, value query, value track_offset, value track_count, value album_offset, value album_count, value artist_offset, value artist_count, value callback)
{
  struct search *search = new(struct search);
  sp_search *sp_search = sp_search_create(get_session(session),
                                          String_val(query),
                                          Int_val(track_offset),
                                          Int_val(track_count),
                                          Int_val(album_offset),
                                          Int_val(album_count),
                                          Int_val(artist_offset),
                                          Int_val(artist_count),
                                          search_complete,
                                          (void*)search);
  search->sp_search = sp_search;
  search->callback = callback;
  search->search = alloc_search(search);
  caml_register_generational_global_root(&(search->callback));
  caml_register_generational_global_root(&(search->search));
  return search->search;
}

CAMLprim value ocaml_spotify_search_create_byte(value *argv, int argn)
{
  return ocaml_spotify_search_create(argv[0], argv[1], argv[2], argv[3], argv[4], argv[5], argv[6], argv[7], argv[8]);
}

CAMLprim value ocaml_spotify_radio_search_create(value session, value from_year, value to_year, value list, value callback)
{
  sp_radio_genre genres = 0;
  while (Is_block(list)) {
    genres |= 1 << Int_val(Field(list, 0));
    list = Field(list, 1);
  }
  struct search *search = new(struct search);
  sp_search *sp_search = sp_radio_search_create(get_session(session),
                                                Int_val(from_year),
                                                Int_val(to_year),
                                                genres,
                                                search_complete,
                                                (void*)search);
  search->sp_search = sp_search;
  search->callback = callback;
  search->search = alloc_search(search);
  caml_register_generational_global_root(&(search->callback));
  caml_register_generational_global_root(&(search->search));
  return search->search;
}

CAMLprim value ocaml_spotify_search_is_loaded(value search)
{
  return Val_bool(sp_search_is_loaded(get_search(search)->sp_search));
}

CAMLprim value ocaml_spotify_search_error(value search)
{
  return Val_int(sp_search_error(get_search(search)->sp_search));
}

CAMLprim value ocaml_spotify_search_num_tracks(value search)
{
  return Val_int(sp_search_num_tracks(get_search(search)->sp_search));
}

CAMLprim value ocaml_spotify_search_track(value search, value index)
{
  sp_track *track = sp_search_track(get_search(search)->sp_search, Int_val(index));
  if (track) sp_track_add_ref(track);
  return alloc_track(track);
}

CAMLprim value ocaml_spotify_search_num_albums(value search)
{
  return Val_int(sp_search_num_albums(get_search(search)->sp_search));
}

CAMLprim value ocaml_spotify_search_album(value search, value index)
{
  sp_album *album = sp_search_album(get_search(search)->sp_search, Int_val(index));
  if (album) sp_album_add_ref(album);
  return alloc_album(album);
}

CAMLprim value ocaml_spotify_search_num_artists(value search)
{
  return Val_int(sp_search_num_artists(get_search(search)->sp_search));
}

CAMLprim value ocaml_spotify_search_artist(value search, value index)
{
  sp_artist *artist = sp_search_artist(get_search(search)->sp_search, Int_val(index));
  if (artist) sp_artist_add_ref(artist);
  return alloc_artist(artist);
}

CAMLprim value ocaml_spotify_search_query(value search)
{
  return caml_copy_string(sp_search_query(get_search(search)->sp_search));
}

CAMLprim value ocaml_spotify_search_did_you_mean(value search)
{
  return caml_copy_string(sp_search_did_you_mean(get_search(search)->sp_search));
}

CAMLprim value ocaml_spotify_search_total_tracks(value search)
{
  return Val_int(sp_search_total_tracks(get_search(search)->sp_search));
}

CAMLprim value ocaml_spotify_search_total_albums(value search)
{
  return Val_int(sp_search_total_albums(get_search(search)->sp_search));
}

CAMLprim value ocaml_spotify_search_total_artists(value search)
{
  return Val_int(sp_search_total_artists(get_search(search)->sp_search));
}

CAMLprim value ocaml_spotify_search_release(value search)
{
  search_finalize(search);
  Search_val(search) = NULL;
  return Val_unit;
}
