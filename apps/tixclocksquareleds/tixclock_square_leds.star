"""
Applet: Tix Clock Square LEDs
Summary: Time as counts of lit squares
Description: Shows the time as four blocks of squares: hours tens, hours ones, minutes tens and minutes ones. The number of lit squares in each block is the digit; which squares light up is random and changes on a set interval.
Author: bertrandom
"""

load("random.star", "random")
load("render.star", "canvas", "render")
load("schema.star", "schema")
load("time.star", "time")

ROWS = 3

# Left to right: hours tens, hours ones, minutes tens, minutes ones.
SEGMENT_COLS = [1, 3, 2, 3]

# Segment colors for each color scheme, left to right.
COLOR_SCHEMES = {
    "classic": ["#ff0000", "#00ff00", "#0000ff", "#ff0000"],
    "bryg": ["#0000ff", "#ff0000", "#ffff00", "#00ff00"],
}
DEFAULT_COLOR_SCHEME = "classic"

# With the "custom" scheme, each segment's color comes from its own setting,
# starting from the classic colors.
CUSTOM_SCHEME = "custom"
CUSTOM_COLOR_IDS = ["color_hours_tens", "color_hours_ones", "color_minutes_tens", "color_minutes_ones"]
CUSTOM_COLOR_NAMES = ["Hours tens color", "Hours ones color", "Minutes tens color", "Minutes ones color"]
CUSTOM_PALETTE = ["#ff0000", "#00ff00", "#0000ff", "#ffff00", "#ff00ff", "#00ffff", "#ff8000", "#ffffff"]
HEX_DIGITS = "0123456789abcdefABCDEF"

OFF_COLOR = "#000000"

# Unlit LEDs when "Show unlit LEDs" is on: almost black, with a hint of grey.
UNLIT_COLOR = "#111111"

# Each LED is a square cell with a solid center and a black border. At 1x
# that's a 5x5 cell: a 3x3 center and a 1-pixel border.
CELL = 5
BORDER = 1

# Blank space between segments, one cell wide.
GAP = 5

# Roughly one minute of animation per render.
ANIMATION_SECS = 60
DEFAULT_INTERVAL = "1"

def scale():
    return 2 if canvas.is2x() else 1

def hour_12(h):
    h = h % 12
    return 12 if h == 0 else h

def digits(t, use_24h):
    h = t.hour if use_24h else hour_12(t.hour)
    m = t.minute
    return [h // 10, h % 10, m // 10, m % 10]

def pick_lit(count, total):
    # Choose `count` of `total` positions at random (partial Fisher-Yates).
    positions = list(range(total))
    for i in range(count):
        j = random.number(i, total - 1)
        positions[i], positions[j] = positions[j], positions[i]
    return {p: True for p in positions[:count]}

def led(color, s):
    inner = (CELL - 2 * BORDER) * s
    return render.Padding(
        pad = BORDER * s,
        child = render.Box(width = inner, height = inner, color = color),
    )

def frame(t, use_24h, colors, off_color, s):
    # Build the 3 rows of the grid, segment by segment, with a gap between
    # segments.
    rows = [[] for _ in range(ROWS)]
    for seg, value in enumerate(digits(t, use_24h)):
        if seg > 0:
            for r in range(ROWS):
                rows[r].append(render.Box(width = GAP * s, height = CELL * s))
        cols = SEGMENT_COLS[seg]
        lit = pick_lit(value, cols * ROWS)
        for r in range(ROWS):
            for c in range(cols):
                on = lit.get(r * cols + c, False)
                rows[r].append(led(colors[seg] if on else off_color, s))

    width, height = canvas.size()

    # A Box centers its child, which pads the grid evenly on each side.
    return render.Box(
        width = width,
        height = height,
        child = render.Column(children = [render.Row(children = row) for row in rows]),
    )

def main(config):
    # Tronbyt passes the display's time zone as "$tz".
    timezone = config.get("timezone") or config.get("$tz") or time.tz()
    use_24h = config.bool("use_24h", False)
    interval = int(config.get("interval") or DEFAULT_INTERVAL)
    colors = segment_colors(config)
    off_color = UNLIT_COLOR if config.bool("show_unlit", True) else OFF_COLOR
    s = scale()

    # Tronbyt renders an app's image while the previous image is still on
    # screen, so the first frame appears roughly one display time after it was
    # rendered. Shift the clock forward to compensate.
    offset = parse_offset(config.get("offset_secs"))
    start = time.now().in_location(timezone) + time.second * offset

    frames = max(1, ANIMATION_SECS // interval)

    return render.Root(
        delay = interval * 1000,
        show_full_animation = True,
        child = render.Animation(
            children = [frame(start + time.second * (i * interval), use_24h, colors, off_color, s) for i in range(frames)],
        ),
    )

def segment_colors(config):
    scheme = config.get("color_scheme")
    if scheme != CUSTOM_SCHEME:
        return COLOR_SCHEMES.get(scheme, COLOR_SCHEMES[DEFAULT_COLOR_SCHEME])

    # Fall back to the classic color for any segment without a valid color.
    defaults = COLOR_SCHEMES[DEFAULT_COLOR_SCHEME]
    colors = []
    for i, id in enumerate(CUSTOM_COLOR_IDS):
        value = (config.get(id) or "").strip()
        colors.append(value if is_hex_color(value) else defaults[i])
    return colors

def is_hex_color(value):
    # "#rgb", "#rrggbb" or either with alpha.
    if not value.startswith("#") or len(value) not in (4, 5, 7, 9):
        return False
    for ch in value[1:].elems():
        if ch not in HEX_DIGITS:
            return False
    return True

def parse_offset(value):
    if not value:
        return 0
    value = value.strip()
    digits = value[1:] if value.startswith("-") else value
    if not digits.isdigit():
        return 0
    return int(value)

def custom_color_fields(scheme):
    # Only the custom scheme gets per-segment color pickers.
    if scheme != CUSTOM_SCHEME:
        return []
    defaults = COLOR_SCHEMES[DEFAULT_COLOR_SCHEME]
    return [
        schema.Color(
            id = CUSTOM_COLOR_IDS[i],
            name = CUSTOM_COLOR_NAMES[i],
            desc = "Color of lit squares in this block.",
            icon = "brush",
            default = defaults[i],
            palette = CUSTOM_PALETTE,
        )
        for i in range(len(CUSTOM_COLOR_IDS))
    ]

def get_schema():
    return schema.Schema(
        version = "1",
        fields = [
            schema.Dropdown(
                id = "interval",
                name = "Change pattern every",
                desc = "How often the lit squares are shuffled.",
                icon = "shuffle",
                default = DEFAULT_INTERVAL,
                options = [
                    schema.Option(display = "1 second", value = "1"),
                    schema.Option(display = "4 seconds", value = "4"),
                    schema.Option(display = "1 minute", value = "60"),
                ],
            ),
            schema.Dropdown(
                id = "color_scheme",
                name = "Color scheme",
                desc = "Colors of the four blocks, left to right.",
                icon = "palette",
                default = DEFAULT_COLOR_SCHEME,
                options = [
                    schema.Option(display = "Red, green, blue, red", value = "classic"),
                    schema.Option(display = "Blue, red, yellow, green", value = "bryg"),
                    schema.Option(display = "Custom", value = CUSTOM_SCHEME),
                ],
            ),
            schema.Generated(
                id = "custom_colors",
                source = "color_scheme",
                handler = custom_color_fields,
            ),
            schema.Toggle(
                id = "show_unlit",
                name = "Show unlit LEDs",
                desc = "Draw unlit LEDs as very dark grey squares instead of leaving them black.",
                icon = "square",
                default = True,
            ),
            schema.Toggle(
                id = "use_24h",
                name = "24-hour clock",
                desc = "Show hours as 0-23 instead of 1-12.",
                icon = "clock",
                default = False,
            ),
            schema.Text(
                id = "offset_secs",
                name = "Display lag (seconds)",
                desc = "Your display gets each image while the one before it is still showing, so the clock can run behind by that long. Enter how many seconds to shift it forward. If this app is pinned, use its display time (e.g. 60). Leave at 0 if the time looks right.",
                icon = "stopwatch",
                default = "0",
            ),
        ],
    )
