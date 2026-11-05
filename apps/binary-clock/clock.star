load("render.star", "render")
load("time.star", "time")

def main(config):
    timezone = config.get("timezone") or "America/New_York"
    now = time.now().in_location(timezone)

    return render.Root(
        child = render.Box(
            child = render.Column(
                expanded = True,
                main_align = "space_evenly",
                children = [
                    render.Row(
                        expanded = True,
                        main_align = "space_evenly",
                        children = [
                            render.Circle(
                                color="#333",
                                diameter=5,
                            ),
                            render.Circle(
                                color="#333",
                                diameter=5,
                            ),
                            render.Circle(
                                color="#333",
                                diameter=5,
                            ),
                            render.Circle(
                                color="#333",
                                diameter=5,
                            ),
                            render.Circle(
                                color="#000",
                                diameter=5,
                            ),
                            render.Circle(
                                color="#000",
                                diameter=5,
                            ),
                        ],
                    ),
                    render.Row(
                        expanded = True,
                        main_align = "space_evenly",
                        children = [
                            render.Circle(
                                color="#333",
                                diameter=5,
                            ),
                            render.Circle(
                                color="#333",
                                diameter=5,
                            ),
                            render.Circle(
                                color="#333",
                                diameter=5,
                            ),
                            render.Circle(
                                color="#333",
                                diameter=5,
                            ),
                            render.Circle(
                                color="#333",
                                diameter=5,
                            ),
                            render.Circle(
                                color="#333",
                                diameter=5,
                            ),
                        ],
                    ),
                    render.Row(
                        expanded = True,
                        main_align = "space_evenly",
                        children = [
                            render.Circle(
                                color="#333",
                                diameter=5,
                            ),
                            render.Circle(
                                color="#333",
                                diameter=5,
                            ),
                            render.Circle(
                                color="#333",
                                diameter=5,
                            ),
                            render.Circle(
                                color="#333",
                                diameter=5,
                            ),
                            render.Circle(
                                color="#333",
                                diameter=5,
                            ),
                            render.Circle(
                                color="#333",
                                diameter=5,
                            ),
                        ],
                    ),
                ],
            ),
        ),
    )