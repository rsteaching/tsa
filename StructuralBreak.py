from manim import *
import numpy as np

OFF    = "#ECECF0"
ACCENT = "#E11D48"
FAINT  = "#9091A0"
DIM    = "#5E5F6B"

Tex.set_default(color=OFF)
MathTex.set_default(color=OFF)


class StructuralBreak(Scene):
    def construct(self):
        self.camera.background_color = "#000000"

        ax = Axes(
            x_range=[0, 10, 1], y_range=[0, 6, 1],
            x_length=10.5, y_length=5.6,
            tips=True,
            axis_config={"color": OFF, "stroke_width": 2,
                         "include_ticks": True, "tick_size": 0.06},
        ).to_edge(DOWN, buff=0.9).shift(LEFT * 0.2)

        ylab = MathTex(r"Y_t").scale(0.8).next_to(ax.y_axis.get_top(), UP, buff=0.15)
        xlab = MathTex(r"t").scale(0.8).next_to(ax.x_axis.get_right(), RIGHT, buff=0.15)

        muA, muB = 2.0, 4.0
        tbreak = 5.0
        rng = np.random.default_rng(7)
        A = [(t, muA + rng.normal(0, 0.33)) for t in np.linspace(0.6, 4.4, 22)]
        B = [(t, muB + rng.normal(0, 0.33)) for t in np.linspace(5.6, 9.4, 22)]

        def dots(data, color):
            return VGroup(*[
                Dot(ax.c2p(t, y), radius=0.055, color=color,
                    fill_opacity=0.92, stroke_width=1, stroke_color="#000000")
                for t, y in data])

        dotsA = dots(A, OFF)
        dotsB = dots(B, OFF)

        lineA = DashedLine(ax.c2p(0, muA), ax.c2p(4.7, muA), color=FAINT, stroke_width=2.5, dash_length=0.12)
        lineB = DashedLine(ax.c2p(5.3, muB), ax.c2p(9.7, muB), color=FAINT, stroke_width=2.5, dash_length=0.12)
        labA = MathTex(r"\mu_A").scale(0.62).set_color(FAINT).next_to(ax.c2p(0, muA), LEFT, buff=0.3)
        labB = MathTex(r"\mu_B").scale(0.62).set_color(FAINT).next_to(ax.c2p(9.7, muB), RIGHT, buff=0.12)

        brk = DashedLine(ax.c2p(tbreak, 0), ax.c2p(tbreak, 5.6), color=ACCENT,
                         stroke_width=2, dash_length=0.13).set_opacity(0.85)
        brklab = Text("structural break", font="IBM Plex Sans", slant=ITALIC,
                      color=ACCENT).scale(0.34).next_to(ax.c2p(tbreak, 5.6), UP, buff=0.12)

        pooled_y = (muA + muB) / 2
        pooled = Line(ax.c2p(0.3, pooled_y), ax.c2p(9.7, pooled_y), color=ACCENT, stroke_width=4)
        plab = MathTex(r"\bar{Y}").scale(0.7).set_color(ACCENT).next_to(ax.c2p(9.7, pooled_y), RIGHT, buff=0.12)

        caption = Tex(r"$\bar{Y}$ \textit{estimates neither} $\mu_A$ \textit{nor} $\mu_B$",
                      color=OFF).scale(0.7)
        caption.to_edge(DOWN, buff=0.28)

        # choreography
        self.play(Create(ax), FadeIn(ylab), FadeIn(xlab), run_time=1.2)
        self.play(LaggedStart(*[GrowFromCenter(d) for d in dotsA], lag_ratio=0.04, run_time=1.3))
        self.play(Create(lineA), FadeIn(labA), run_time=0.6)
        self.play(Create(brk), FadeIn(brklab, shift=DOWN * 0.15), run_time=0.7)
        self.play(LaggedStart(*[GrowFromCenter(d) for d in dotsB], lag_ratio=0.04, run_time=1.3))
        self.play(Create(lineB), FadeIn(labB), run_time=0.6)
        self.wait(0.3)
        self.play(Create(pooled), FadeIn(plab), run_time=0.9)
        self.play(Indicate(pooled, color=ACCENT, scale_factor=1.04), run_time=0.7)
        self.play(FadeIn(caption, shift=UP * 0.2), run_time=0.7)
        self.wait(2.2)
