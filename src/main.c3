module cadantauri;

import std::io;
import std::math;

const CHANNELS    = 2;
const SAMPLE_RATE = 44100;

// Main process program function

fn int main(String[] args)
{
	io::printn("Cadantauri: a Waveform Editing Hybrid Tracker");
	int succession = 0;

	AudioResult result;
	AudioConfig engine_config;
	SDL_AudioSpec desired_spec;
	SDL_AudioSpec obtained_spec;
	SDL_AudioDeviceID device_id;

	engine_config = engine_config_init();
	engine_config
		.no_device = true; /* <-- Make sure this is set so that no device is created (we'll deal with that ourselves). */
	engine_config.channels = CHANNELS;
	engine_config.sample_rate = SAMPLE_RATE;

	// NOTE: optimistic-defensive programming as convention
	return succession;
}

// Event callback functions

fn void mix_audio(float[] output, int dt_samples, TrackerState* tracker_state) {}

fn void draw_waveform(AudioClip clip) {
	AudioClipInstance audio_instance = {
		.x = 0,
		.y = 0,
		.w = 0,
		.h = 0,
	};
	render_waveform(
		app_state.renderer,
		clip,
		audio_instance.x,
		audio_instance.y,
		audio_instance.w,
		audio_instance.h,
	);
	reposition_waveform(clip, audio_instance.x, audio_instance.y);
	resize_waveform(clip, audio_instance.w, audio_instance.h);
}

fn void resize_waveform(AudioClip clip, int w, int h) {}

fn void reposition_waveform(AudioClip clip, int x, int y) {}

fn void render_waveform(
	SDL_Renderer* renderer,
	AudioClip clip,
	int x,
	int y,
	int w,
	int h,
) {}

fn void data_callback(void* p_user_data, void* p_buffer, int buffer_size) {
	uint frame_buffer_size =
		buffer_size /
		mini.get_bytes_per_frame(
			mini.format.f32,
			mini.engine_get_channels(&app_state.audio_engine),
		);
	mini.engine_read_pcm_frames(
		&app_state.audio_engine,
		p_buffer,
		cast(u64)(frame_buffer_size),
		nil,
	);
}

fn AudioResult engine_init(MAEngineConfig* config, MAEngine* engine)
{
	return (AudioResult) {
		.config = config,
		.engine = engine,
	};
}

fn AudioConfig engine_config_init()
{
	return (AudioConfig) { };
}

fn Sound[] initialise_multiple_sounds()
{
	Sound[] sounds = (Sound[]) { };
	return sounds;
}

// Sound AOS functions

fn int initialise_sound(String filepath, Sound* sound, AppState* state)
{
	SDL_AudioSpec* spec = null;
	if (spec == null) {
		spec = { };
	}

	sound.sound_data = null;
	sound.sound_data_length = null;

	sound.audio_stream = sdl_CreateAudioStream(spec, spec);
	if (&sound.audio_stream == null) {
		io::print("Failed to create audio stream");
		return 1;
	}

	if (!sdl_BindAudioStream(app_state.audio_device_id, sound.audio_stream)) {
		io::print("Failed to bind audio stream");
		return 1;
	}
	defer sdl_Free(spec);

	return 0;
}

fn int initialise_device_sound_data(String sound_filepath, Sound* device_sound, AppState* app_state)
{
	SDL_AudioSpec* audio_spec = null; // How do we safely allocate memory here?

	// Load the ogg file and initialize the Sound struct
	// This is a placeholder implementation; actual implementation will depend on SDL functions
	device_sound.sound_data= null; // Load ogg data from filename
	device_sound.sound_data_length = null; // Set length of ogg data
	device_sound.audio_stream = null; // Create audio stream from ogg data

	device_sound.audio_stream = sdl_CreateAudioStream(audio_spec, audio_spec); // Create audio stream
	if (!device_sound.audio_stream)
	{
		io::printn("Failed to create audio stream for file");
		return 1;
	}
	if (!sdl_BindAudioStream(app_state.audio_device, device_sound.audio_stream))
	{
		io::printn("Failed to bind audio stream for file");
		return 1;
	}

	sdl_Free(sound_filepath); // Free the ogg file path string if necessary, maybe use SDL_free or similar function

	return 0; // Return false if no errors, true if otherwise
}

// Sinusoidal Wave functions

// Sinusoid going to the right
fn double form_sine_wave_yt(double amplitude, double angular, double independent, double phase)
{
	return amplitude * math::sin(angular * independent + phase);
}

// Sinusoid going down
fn double form_cosine_wave_xt(double amplitude, double angular, double independent, double phase)
{
	return amplitude * math::cos(angular * independent + phase);
}

// Foreign function interops

// MiniAudio

extern fn ulong _ma_get_bytes_per_frame(float format, int channels) @cname("ma_get_bytes_per_frame") @private;
extern fn int _ma_engine_get_channels(AudioEngine* engine) @cname("ma_engine_get_channels") @private;
extern fn void _ma_engine_read_pcm_frames(
	AudioEngine* engine,
	uptr buffer,
	ulong buffer_frames,
	void* user_data
) @cname("ma_engine_read_pcm_frames") @private;
extern fn void _ma_engine_config_init() @cname("ma_engine_config_init") @private;
extern fn void _ma_engine_init(AudioConfig* config, AudioEngine* engine) @cname("ma_engine_init") @private;
extern fn void _ma_engine_uninit(AudioEngine* engine) @cname("ma_engine_uninit") @private;

// SDL3

// Create

extern fn void sdl_Init() @cname("SDL_Init") @public;
extern fn SDL_AudioStream* sdl_CreateAudioStream(
	SDL_AudioSpec* desired_spec,
	SDL_AudioSpec* obtained_spec
) @cname("SDL_CreateAudioStream") @public;

// Read

extern fn void sdl_LoadWav() @cname("SDL_LoadWAV") @public;
extern fn int sdl_BindAudioStream(
	SDL_AudioDeviceID audio_device,
	SDL_AudioStream* audio_stream
) @cname("SDL_BindAudioStream") @public;
extern fn void sdl_OpenAudioDevice(
	int audio_device_flag,
	void* audio_device_data
) @cname("SDL_OpenAudioDevice") @public;

// Destroy

extern fn void sdl_CloseDevice(SDL_AudioDeviceID* audio_device) @cname("SDL_CloseAudioDevice") @public;
extern fn void sdl_DestroyAudioStream(SDL_AudioStream* audio_stream) @cname("SDL_DestroyAudioStream") @public;
extern fn void sdl_Free(void* data) @cname("SDL_free") @public;
extern fn void sdl_Quit() @cname("SDL_Quit") @public;
extern fn void sdl_DestroyWindow() @cname("SDL_DestroyWindow") @public;

struct AudioEngine
{
	AppState[] application_states;
	UserSession[] user_sessions;
	Tracker[] trackers; // Works as a discrete bar/timeline section (bisect/dissection)
	Waveform[] waveforms; // initialise Waveforms (with cache) after Tracker mechanics
}

struct AudioConfig
{
	bool no_device;
	int channels;
	float sample_rate;
}

struct AudioResult
{
	MAEngineConfig* config;
	MAEngine* engine;
}

struct AppState
{
	int is_running;
	SDL_Window* window;
	SDL_Renderer* renderer;
	SDL_AudioDeviceID audio_device;
}

// TODO: Array-of-Structs or Structures-of-Arrays for all of the following data structures

// Beats-per-minute

struct Waveform
{
	// Continuous waveform audio data
	// overlayed over discrete note events
	Sound[] sounds;
	Amplitude amplitude;
}

struct Sound
{
	uint* sound_data;
	uint* sound_data_length;
	SDL_AudioStream* audio_stream;
}

struct TrackerState {
	AudioTrack[] audio_tracks;
	float tempo;
	float playhead;
	int is_playing;
}

struct Tracker
{
	// Discrete note events
	// Can be used as the Beats-per-Bar Sectioning mechanic
	AudioTrack track;
}

struct AudioTrack
{
	AudioClip[] clips;
	String filename;
	String name;
	float gain;
	int is_muted;
	int is_soloing;
}

struct AudioClip
{
	String filepath;
	String name;
	float[] samples;
	int sample_rate;
	int start_tick;
	int channels;
	float gain;
	float pan;
	float pitch;
	int is_looping;
}

struct AudioClipInstance
{
	int w;
	int h;
	int x;
	int y;
}

// Sessions

struct UserSession
{
	Session session;
}

struct Session
{
	Memento session_memento; // Hex or Binary data into a memento (file)
}

// Memento File read-and-writing

struct Memento
{
	String[][] serials; // String matrix data for reading-and-writing
	// NOTE: YAML or JSON for hierarchical data
	// NOTE: Controlled Binary Serialisation process or Protocol Buffer for every object which writes their state out in a controlled way
}

// Vectors

struct Amplitude
{
	float radius;
	Vec2 point;
}

typedef _MAResult @private = void*;
typedef MAResult @public = inline _MAResult;

typedef _MAEngine @private = void*;
typedef MAEngine @public = inline _MAEngine;

typedef _MAEngineConfig @private = void*;
typedef MAEngineConfig @public = inline _MAEngineConfig;

typedef _SDL_Window @private = void*;
typedef SDL_Window @public = inline _SDL_Window;

typedef _SDL_Renderer @private = void*;
typedef SDL_Renderer @public = inline _SDL_Renderer;

typedef _SDL_AudioStream @private = void*;
typedef SDL_AudioStream @public = inline _SDL_AudioStream;

typedef _SDL_AudioSpec @private = void*;
typedef SDL_AudioSpec @public = inline _SDL_AudioSpec;

typedef _SDL_AudioDeviceID @private = uint;
typedef SDL_AudioDeviceID @public = inline _SDL_AudioDeviceID;
