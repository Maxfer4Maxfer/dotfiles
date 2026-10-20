#!/usr/bin/env python3
# iTerm2 AutoLaunch script: registers toggle_colors(), bound to F1 (fn+F1; Invoke Script Function),
# which flips every session and profile between Solarized Dark and Solarized Light Inverted
# (the light preset with mirrored base tones, see iterm2/com.googlecode.iterm2.plist).
import iterm2

DARK = "Solarized Dark"
LIGHT = "Solarized Light Inverted"


async def main(connection):
    app = await iterm2.async_get_app(connection)

    @iterm2.RPC
    async def toggle_colors():
        sessions = [s for w in app.windows for t in w.tabs for s in t.sessions]
        current = app.current_terminal_window
        session = current.current_tab.current_session if current else (sessions or [None])[0]
        if session is None:
            return
        bg = (await session.async_get_profile()).background_color
        light = (bg.red + bg.green + bg.blue) / 3 > 127
        preset = await iterm2.ColorPreset.async_get(connection, DARK if light else LIGHT)
        # open sessions directly, stored profiles so that new tabs open in the same mode
        for s in sessions:
            await (await s.async_get_profile()).async_set_color_preset(preset)
        for partial in await iterm2.PartialProfile.async_query(connection):
            await (await partial.async_get_full_profile()).async_set_color_preset(preset)

    await toggle_colors.async_register(connection)


iterm2.run_forever(main)
