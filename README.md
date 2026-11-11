# bert-tronbyt

Custom apps for my [Tronbyt](https://github.com/tronbyt/server) server. Each app lives in its
own folder under `apps/`. Apps meant for [tronbyt/apps](https://github.com/tronbyt/apps) follow
that repo's layout: `apps/<packagename>/` with a `manifest.yaml` and preview images.

## Apps

### simplebinaryclock

Simple Binary Clock: shows the time as three rows of dots (hours, minutes, seconds), each a
binary number with the most significant bit on the left. It animates through 60 seconds per
render and supports 64×32, 128×64 and 64×64 displays.

Settings:

- **24-hour clock**: hours as 0–23 instead of 1–12.
- **Show unused hour dots** (on by default): draws unlit dots in the hour row's leftmost
  positions, which the hour never fills.
- **Display lag (seconds)**: Tronbyt sends an app's image while the previous one is still on
  screen, so the clock can start out behind by that long. This shifts the time forward to
  make up for it. When the app is pinned, use its display time (e.g. 60).

To regenerate the preview images:

```
cd apps/simplebinaryclock
pixlet render -z 9 simple_binary_clock.star -o simplebinaryclock.webp
pixlet render -2 -z 9 simple_binary_clock.star -o simplebinaryclock@2x.webp
pixlet render -w 64 -t 64 -z 9 simple_binary_clock.star -o simplebinaryclock@64x64.webp
```

### vestaboard

Draws a Vestaboard pattern (6 rows × 21 bits) on the 64×32 display.

The grid comes from the `message_body` config value: a JSON-encoded 6×21 array of Vestaboard
character codes. Codes 63–68 are the colors, 69 and 71 are white, 70 is black, and anything else
is drawn as an empty bit. With no `message_body` it draws a blank board.

It doesn't fetch anything itself. [vestaboard-pattern-server](https://github.com/bertrandom/vestaboard-pattern-server)
sets `message_body` on the installation and pushes the app with the same config whenever the
selected pattern changes.

To render it locally with a config file containing `{"message_body": "[[...], ...]"}`:

```
pixlet render apps/vestaboard/vestaboard.star -c config.json -o vestaboard.webp
```
