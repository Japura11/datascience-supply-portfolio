class_name SfxSynth
extends RefCounted
## Sonidos provisionales generados por código: sin archivos binarios ni licencias de terceros.
## Se sustituirán por sonido final en el vertical slice.

const MIX_RATE := 22050


static func build_all() -> Dictionary:
	var rng := RandomNumberGenerator.new()
	rng.seed = 1234
	return {
		"hit_heavy": _thump(rng, 0.5, 50.0, 0.95, 0.55),
		"hit_light": _thump(rng, 0.22, 130.0, 0.6, 0.4),
		"kick": _thump(rng, 0.14, 210.0, 0.75, 0.65),
		"step": _thump(rng, 0.1, 70.0, 0.4, 0.25),
		"whistle": _whistle(0.55),
		"roar": _roar(rng, 1.1),
		"crowd": _crowd(rng, 4.0, true),
		"cheer": _crowd(rng, 2.8, false),
	}


static func _to_stream(samples: PackedFloat32Array, loop: bool) -> AudioStreamWAV:
	var data := PackedByteArray()
	data.resize(samples.size() * 2)
	for i in samples.size():
		data.encode_s16(i * 2, int(clampf(samples[i], -1.0, 1.0) * 32767.0))
	var stream := AudioStreamWAV.new()
	stream.format = AudioStreamWAV.FORMAT_16_BITS
	stream.mix_rate = MIX_RATE
	stream.stereo = false
	stream.data = data
	if loop:
		stream.loop_mode = AudioStreamWAV.LOOP_FORWARD
		stream.loop_begin = 0
		stream.loop_end = samples.size()
	return stream


## Golpe seco: seno con caída de tono + ruido filtrado, envolvente exponencial.
static func _thump(
	rng: RandomNumberGenerator, duration: float, freq: float, volume: float, noise_amount: float
) -> AudioStreamWAV:
	var n := int(duration * MIX_RATE)
	var samples := PackedFloat32Array()
	samples.resize(n)
	var phase := 0.0
	var low := 0.0
	for i in n:
		var t := float(i) / MIX_RATE
		var env := exp(-t * 7.0 / duration)
		phase += TAU * freq * (1.0 + 1.5 * exp(-t * 40.0)) / MIX_RATE
		low = lerpf(low, rng.randf_range(-1.0, 1.0), 0.2)
		var tone := sin(phase) * (1.0 - noise_amount)
		samples[i] = (tone + low * noise_amount * 2.5) * env * volume
	return _to_stream(samples, false)


## Silbato del árbitro: tono agudo con trino.
static func _whistle(duration: float) -> AudioStreamWAV:
	var n := int(duration * MIX_RATE)
	var samples := PackedFloat32Array()
	samples.resize(n)
	var phase := 0.0
	for i in n:
		var t := float(i) / MIX_RATE
		var env := minf(t / 0.02, 1.0) * minf((duration - t) / 0.05, 1.0)
		var trill := 0.6 + 0.4 * sin(TAU * 28.0 * t)
		phase += TAU * (2600.0 + 60.0 * sin(TAU * 28.0 * t)) / MIX_RATE
		samples[i] = sin(phase) * trill * env * 0.35
	return _to_stream(samples, false)


## Rugido: diente de sierra grave con gruñido (modulación) y ruido.
static func _roar(rng: RandomNumberGenerator, duration: float) -> AudioStreamWAV:
	var n := int(duration * MIX_RATE)
	var samples := PackedFloat32Array()
	samples.resize(n)
	var phase := 0.0
	var low := 0.0
	for i in n:
		var t := float(i) / MIX_RATE
		var env := minf(t / 0.12, 1.0) * pow(maxf(1.0 - t / duration, 0.0), 1.5)
		var freq := lerpf(95.0, 60.0, t / duration)
		phase = fmod(phase + freq / MIX_RATE, 1.0)
		var saw := phase * 2.0 - 1.0
		var growl := 0.6 + 0.4 * sin(TAU * 32.0 * t)
		low = lerpf(low, rng.randf_range(-1.0, 1.0), 0.08)
		samples[i] = (saw * 0.55 + low * 1.6) * growl * env * 0.8
	return _to_stream(samples, false)


## Público: ruido de banda media con oleadas. Bucle (ambiente) u ovación (one-shot).
static func _crowd(rng: RandomNumberGenerator, duration: float, loop: bool) -> AudioStreamWAV:
	var n := int(duration * MIX_RATE)
	var samples := PackedFloat32Array()
	samples.resize(n)
	var low_a := 0.0
	var low_b := 0.0
	for i in n:
		var t := float(i) / MIX_RATE
		var noise := rng.randf_range(-1.0, 1.0)
		low_a = lerpf(low_a, noise, 0.35)
		low_b = lerpf(low_b, noise, 0.04)
		var band := low_a - low_b
		var env := 1.0
		if loop:
			env = 0.75 + 0.25 * sin(TAU * t / duration * 2.0)
		else:
			env = minf(t / 0.3, 1.0) * maxf(1.0 - t / duration, 0.0)
		samples[i] = band * env * (0.9 if loop else 1.4)
	return _to_stream(samples, loop)
