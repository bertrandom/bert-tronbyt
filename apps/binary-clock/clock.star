load("render.star", "render")
load("schema.star", "schema")
load("time.star", "time")

ON_COLOR = "#ff0000"
OFF_COLOR = "#333"
BITS = 6
FRAMES = 60

def bit_row(n, blank = 0):
    # Most significant bit on the left. The leftmost `blank` positions are
    # left empty (same size as a dot) so columns stay aligned across rows.
    children = []
    for i in range(BITS):
        if i < blank:
            children.append(render.Box(width = 5, height = 5))
        else:
            children.append(render.Circle(
                color = ON_COLOR if (n >> (BITS - 1 - i)) & 1 else OFF_COLOR,
                diameter = 5,
            ))
    return render.Row(
        expanded = True,
        main_align = "space_evenly",
        children = children,
    )

def hour_12(h):
    h = h % 12
    return 12 if h == 0 else h

def hour_row(h, use_24h):
    if use_24h:
        # 0-23 needs 5 bits.
        return bit_row(h, blank = 1)

    # 1-12 needs 4 bits.
    return bit_row(hour_12(h), blank = 2)

def frame(t, use_24h):
    return render.Column(
        expanded = True,
        main_align = "space_evenly",
        children = [
            hour_row(t.hour, use_24h),
            bit_row(t.minute),
            bit_row(t.second),
        ],
    )

def main(config):
    timezone = config.get("timezone") or "America/Los_Angeles"
    use_24h = config.bool("use_24h", False)

    # Tronbyt renders the next image when the current one *starts* displaying,
    # so frames are shown roughly one image-duration after they are rendered.
    # Shift the clock forward to compensate.
    offset = parse_offset(config.get("offset_secs"))
    start = time.now().in_location(timezone) + time.second * offset

    return render.Root(
        delay = 1000,
        show_full_animation = True,
        child = render.Animation(
            children = [frame(start + time.second * i, use_24h) for i in range(FRAMES)],
        ),
    )

def parse_offset(value):
    if not value:
        return 0
    value = value.strip()
    digits = value[1:] if value.startswith("-") else value
    if not digits.isdigit():
        return 0
    return int(value)

def get_schema():
    return schema.Schema(
        version = "1",
        fields = [
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
                desc = "Seconds to shift the time forward. When pinned on Tronbyt, use the app's display time (e.g. 60).",
                icon = "stopwatch",
                default = "0",
            ),
        ],
    )
