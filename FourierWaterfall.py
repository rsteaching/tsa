from manim import *
import numpy as np

# ── locked aesthetic: pure black, crimson accent, IBM Plex, off-white geometry ──
BLACK    = "#000000"
OFF      = "#ECECF0"   # primary geometry / text
ACCENT   = "#E11D48"   # crimson accent ($accent)
FAINT    = "#9091A0"   # secondary axes / faint
COMP     = ACCENT      # composite signal = the accent
# component harmonics: each a distinct bright hue, carried through to the
# spectrum spikes so every frequency is colour-matched to its sinusoid.
SIN_COLS = ["#FF5C8A", "#FFB02E", "#3DDC97", "#4CC9F0", "#C77DFF"]
FONT     = "IBM Plex Sans"
PHI = 90 * DEGREES


class FourierWaterfall(ThreeDScene):
    def construct(self):
        self.camera.background_color = BLACK

        N       = 5
        T_MAX   = TAU
        X_HALF  = 2.0
        Z_SCALE = 1.1
        Y_STEP  = 2.0

        freqs = [2*k - 1 for k in range(1, N+1)]
        amps  = [4.0 / (PI * f) for f in freqs]

        def composite(t):
            return Z_SCALE * sum(a * np.sin(f*t) for a, f in zip(amps, freqs))

        def sine_k(k, t):
            return Z_SCALE * amps[k] * np.sin(freqs[k] * t)

        def make_curve(fn_z, y_depth, color, opacity=1.0, sw=3):
            return ParametricFunction(
                lambda t: np.array([X_HALF*(2*t/T_MAX - 1), y_depth, fn_z(t)]),
                t_range=[0, T_MAX, T_MAX/400],
                color=color, stroke_width=sw, stroke_opacity=opacity,
            )

        def caption(text_str, font_size=28):
            obj = Text(text_str, color=OFF, font=FONT, font_size=font_size,
                       line_spacing=1.35, slant=ITALIC)
            obj.shift(DOWN * 3.1)
            self.add_fixed_in_frame_mobjects(obj)
            return obj

        # ── Axes at y=0 ───────────────────────────────────────────
        x_ax = Line(np.array([-X_HALF-0.4, 0, 0]), np.array([X_HALF+0.4, 0, 0]),
                    color=OFF, stroke_width=1.5)
        z_ax = Line(np.array([0, 0, -1.4]), np.array([0, 0, 1.8]),
                    color=OFF, stroke_width=1.5)
        t_lbl  = MathTex("t",   color=OFF, font_size=32).shift(RIGHT*2.65 + DOWN*0.35)
        yt_lbl = MathTex("Y_t", color=OFF, font_size=32).shift(UP*2.1 + LEFT*0.5)
        self.add_fixed_in_frame_mobjects(t_lbl, yt_lbl)

        # ══════════════════════════════════════════════════════════
        # PHASE 1 — composite signal
        # ══════════════════════════════════════════════════════════
        self.set_camera_orientation(phi=PHI, theta=-90*DEGREES)
        comp_curve = make_curve(composite, 0, COMP, sw=3.5)
        cap1 = caption("We have a signal over time.")

        self.play(
            Create(x_ax), Create(z_ax),
            FadeIn(t_lbl), FadeIn(yt_lbl), FadeIn(cap1),
            run_time=0.8,
        )
        self.play(Create(comp_curve), run_time=1.5)
        self.wait(0.8)

        # ══════════════════════════════════════════════════════════
        # PHASE 2 — sinusoids superimposed (cap1 holds)
        # ══════════════════════════════════════════════════════════
        sin_curves_2d = [
            make_curve(lambda t, k=k: sine_k(k, t), 0,
                       SIN_COLS[k], opacity=0.75, sw=2)
            for k in range(N)
        ]
        self.play(
            LaggedStart(*[Create(c) for c in sin_curves_2d], lag_ratio=0.25),
            run_time=2.2,
        )
        self.wait(0.5)

        # ══════════════════════════════════════════════════════════
        # PHASE 3 — rotate camera; swap to cap2
        # phi=90 fixed throughout — only theta animates, no twist
        # ══════════════════════════════════════════════════════════
        cap2 = caption(
            "We decompose it into sinusoids\n"
            "oscillating at different frequencies.",
        )
        self.play(
            FadeOut(cap1), FadeOut(t_lbl), FadeOut(yt_lbl),
            FadeIn(cap2), run_time=0.5,
        )

        y_vals   = [k * Y_STEP for k in range(N)]   # [0, 2, 4, 6, 8]
        y_centre = y_vals[-1] / 2                    # 4.0

        self.move_camera(phi=PHI, theta=-35*DEGREES, zoom=0.65,
                         run_time=3.0, rate_func=smooth)
        self.wait(0.3)

        # ══════════════════════════════════════════════════════════
        # PHASE 4 — spread sinusoids into parallel y-planes
        # Simultaneously pans frame_center to track the waterfall
        # ══════════════════════════════════════════════════════════
        sin_curves_3d = [
            make_curve(lambda t, k=k: sine_k(k, t), y_vals[k],
                       SIN_COLS[k], opacity=0.8, sw=2.5)
            for k in range(N)
        ]
        self.move_camera(
            phi=PHI, theta=-35*DEGREES,
            frame_center=np.array([0, y_centre, 0]),
            zoom=0.58,
            added_anims=[
                LaggedStart(
                    *[Transform(sin_curves_2d[k], sin_curves_3d[k]) for k in range(N)],
                    lag_ratio=0.15,
                )
            ],
            run_time=3.0, rate_func=smooth,
        )
        self.wait(0.6)

        # ══════════════════════════════════════════════════════════
        # PHASE 5 — collapse sinusoids to amplitude spikes; cap3
        # Spikes at x=X_HALF, y=y_k, z=0..amplitude
        # ══════════════════════════════════════════════════════════
        cap3 = caption(
            "We measure how strongly\n"
            "each frequency is present in the signal.",
        )
        self.play(FadeOut(cap2), FadeIn(cap3), run_time=0.4)

        spike_list = [
            Line(
                start=np.array([X_HALF, y_vals[k], 0.0]),
                end  =np.array([X_HALF, y_vals[k], amps[k]*Z_SCALE*2.5]),
                color=SIN_COLS[k], stroke_width=4,
            )
            for k in range(N)
        ]
        freq_ax = Line(
            np.array([X_HALF, -0.3, 0]),
            np.array([X_HALF, y_vals[-1]+0.5, 0]),
            color=FAINT, stroke_width=1.5, stroke_opacity=0.6,
        )
        self.play(Create(freq_ax), run_time=0.4)
        self.play(
            LaggedStart(
                *[Transform(sin_curves_2d[k], spike_list[k]) for k in range(N)],
                lag_ratio=0.2,
            ),
            run_time=3.2,
        )
        self.wait(0.5)

        # ══════════════════════════════════════════════════════════
        # PHASE 6 — rotate to face frequency domain; cap4
        # theta → 5°: spike plane (x=X_HALF) nearly face-on
        # y = frequency (horizontal), z = amplitude (vertical)
        # ══════════════════════════════════════════════════════════
        cap4 = caption("We analyse the spectrum.")
        mean_spike_z = float(np.mean([amps[k]*Z_SCALE*2.5 for k in range(N)])) / 2
        max_spike_z  = amps[0] * Z_SCALE * 2.5

        self.play(
            FadeOut(cap3), FadeIn(cap4),
            FadeOut(comp_curve), FadeOut(x_ax), FadeOut(z_ax),
            run_time=0.8,
        )
        self.move_camera(
            phi=PHI, theta=5*DEGREES,
            frame_center=np.array([X_HALF, y_centre, mean_spike_z]),
            zoom=0.72, run_time=3.5, rate_func=smooth,
        )
        amp_ax = Line(
            np.array([X_HALF, -0.3, 0]),
            np.array([X_HALF, -0.3, max_spike_z*1.15]),
            color=FAINT, stroke_width=1.5, stroke_opacity=0.6,
        )
        self.play(Create(amp_ax), run_time=0.4)
        self.wait(2.0)

        # ══════════════════════════════════════════════════════════
        # PHASE 7 — fade all graphs; definitions slide
        # ══════════════════════════════════════════════════════════
        self.play(
            FadeOut(cap4),
            *[FadeOut(sin_curves_2d[k]) for k in range(N)],
            FadeOut(freq_ax), FadeOut(amp_ax),
            run_time=1.2,
        )

        # ── Time domain block ──────────────────────────────────────
        td_title = Text("Time domain analysis",
                        color=ACCENT, font=FONT, font_size=38, weight=BOLD)
        td_line1 = Text(
            "Studies a series through its autocorrelation structure.",
            color=OFF, font=FONT, font_size=26,
        )
        td_line2 = Text(
            "Effectively, a regression of the series on lagged copies of itself.",
            color=OFF, font=FONT, font_size=26, slant=ITALIC,
        )
        td_block = VGroup(td_title, td_line1, td_line2).arrange(
            DOWN, aligned_edge=LEFT, buff=0.18
        )

        divider = Line(LEFT*5.8, RIGHT*5.8,
                       color=ACCENT, stroke_width=0.8, stroke_opacity=0.6)

        # ── Frequency domain block ─────────────────────────────────
        fd_head = VGroup(
            Text("Frequency domain analysis",
                 color=ACCENT, font=FONT, font_size=38, weight=BOLD),
            Text("(spectral analysis)",
                 color=ACCENT, font=FONT, font_size=26, slant=ITALIC),
        ).arrange(RIGHT, buff=0.28, aligned_edge=DOWN)

        fd_line1 = Text(
            "Studies a series through its spectrum.",
            color=OFF, font=FONT, font_size=26,
        )
        fd_line2 = Text(
            "Effectively, a regression of the series on sinusoids",
            color=OFF, font=FONT, font_size=26, slant=ITALIC,
        )
        fd_line3 = Text(
            "oscillating at different frequencies.",
            color=OFF, font=FONT, font_size=26, slant=ITALIC,
        )
        fd_block = VGroup(fd_head, fd_line1, fd_line2, fd_line3).arrange(
            DOWN, aligned_edge=LEFT, buff=0.18
        )

        defs = VGroup(td_block, divider, fd_block).arrange(
            DOWN, buff=0.45, aligned_edge=LEFT
        )
        defs.move_to(ORIGIN + DOWN * 0.1)
        self.add_fixed_in_frame_mobjects(defs)

        self.play(FadeIn(defs, lag_ratio=0.1), run_time=1.5)
        self.wait(12.0)
