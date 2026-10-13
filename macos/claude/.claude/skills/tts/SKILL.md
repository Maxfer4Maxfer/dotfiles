---
name: tts
description: Enable/disable TTS voice output via KokoroTTS
disable-model-invocation: true
argument-hint: "[off]"
---

Toggle KokoroTTS voice mode for the current session.

## When invoked as `/tts` (no arguments):

Enable TTS mode. From now on, after EVERY response in this session:
1. Check if KokoroTTS is running: `pgrep -x KokoroTTS`. If NOT running, launch it with `open /Applications/KokoroTTS.app` and wait 3 seconds for warmup
2. Take the response text (skip code blocks, tool outputs, and technical artifacts)
2. If the response is longer than 500 characters, create a concise 2-3 sentence summary for voice
3. Send it to KokoroTTS by running: `echo "text here" | ~/.local/bin/kokoro-say`
4. Confirm to the user that TTS mode is enabled on the first invocation

Keep sending responses as text AND voice — the user reads and listens simultaneously.

## When invoked as `/tts off`:

Disable TTS mode. Stop sending responses to KokoroTTS for the rest of the session.
Confirm to the user that TTS mode is disabled.
