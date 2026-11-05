load("render.star", "render")
load("time.star", "time")

def to_bin(n):
    if n == 0:
        return []
    digits = []
    for _ in range(6):
        if n == 0:
            break
        digits.append(n % 2)
        n = n // 2
    return digits

def main(config):
    timezone = config.get("timezone") or "America/Los_Angeles"
    now = time.now().in_location(timezone)

    hours = now.hour
    minutes = now.minute
    seconds = now.second

    binary_hours = to_bin(hours)
    binary_minutes = to_bin(minutes)
    binary_seconds= to_bin(seconds)

    for i in range(6):
        if len(binary_hours) < 6:
            binary_hours.append(0)
        if len(binary_minutes) < 6:
            binary_minutes.append(0)
        if len(binary_seconds) < 6:
            binary_seconds.append(0)

    children_hours = []
    children_minutes = []
    children_seconds = []

    for i in range(6):
        if binary_hours[i] == 1:
            children_hours.append(
                render.Circle(
                    color="#ff0000",
                    diameter=5,
                )
            )
        else:
            children_hours.append(
                render.Circle(
                    color="#333",
                    diameter=5,
                )
            )
        if binary_minutes[i] == 1:
            children_minutes.append(
                render.Circle(
                    color="#ff0000",
                    diameter=5,
                )
            )
        else:
            children_minutes.append(
                render.Circle(
                    color="#333",
                    diameter=5,
                )
            )
        if binary_seconds[i] == 1:
            children_seconds.append(
                render.Circle(
                    color="#ff0000",
                    diameter=5,
                )
            )
        else:
            children_seconds.append(
                render.Circle(
                    color="#333",
                    diameter=5,
                )
            )

    return render.Root(
        child = render.Box(
            child = render.Column(
                expanded = True,
                main_align = "space_evenly",
                children = [
                    render.Row(
                        expanded = True,
                        main_align = "space_evenly",
                        children = children_hours,
                    ),
                    render.Row(
                        expanded = True,
                        main_align = "space_evenly",
                        children = children_minutes,
                    ),
                    render.Row(
                        expanded = True,
                        main_align = "space_evenly",
                        children = children_seconds,
                    ),
                ],
            ),
        ),
    )