## ============================================================
## make_ss_figs.R
## SS example time-series plots, reproduced with astsa::tsplot()
## so that the labels, axes, ticks, gridlines, margins and line
## colours match the Shumway & Stoffer figures exactly.
##
## tsplot() defaults supply the SS look:
##   gridlines + minor ticks (minor=TRUE, xm.grid/ym.grid=TRUE),
##   margins, tick density. Colours are indices into the astsa
##   palette (1=black, 2=red, 3=green, 4=blue, 5=cyan, 6=magenta...).
##
## Run from the same folder as Topic2.qmd:
##   Rscript make_ss_figs.R      (or source() in RStudio)
## Requires: install.packages("astsa")   (use a current version, >= 2.x)
## ============================================================

library(astsa)

## device sized to the site body width; SS look needs no other styling
ss_png <- function(file, w = 8.2, h = 2.7) {
  png(file, width = w, height = h, units = "in", res = 200)
}

pick <- function(...) {              # handle astsa dataset renames
  for (nm in c(...)) if (exists(nm)) return(get(nm))
  stop("none of these astsa datasets found: ", paste(c(...), collapse = ", "))
}

## ---------------------------------------------------------------
## 1) Global temperature anomalies   (SS: col=4 blue, type='o')
## ---------------------------------------------------------------
gt <- pick("gtemp_both", "gtemp_land", "globtemp", "gtemp")
ss_png("sample_globaltemp.png")
tsplot(gt, col = 4, type = "o", pch = 20, ylab = "Temperature Deviations",
       main = "Global Temperature Anomalies")
dev.off()

## ---------------------------------------------------------------
## 2) Speech                          (SS: col=4)
## ---------------------------------------------------------------
ss_png("sample_speech.png")
tsplot(speech, col = 4, ylab = "speech", main = "Speech")
dev.off()

## ---------------------------------------------------------------
## 3) Earthquake vs explosion         (SS: two-panel, col=4)
##    tsplot can do the stack itself via cbind + ncolm=1
## ---------------------------------------------------------------
ss_png("sample_disaster.png", h = 4.8)
tsplot(cbind(EQ5, EXP6), col = 4, ncolm = 1,
       title = c("Earthquake", "Explosion"))
dev.off()

## ---------------------------------------------------------------
## 4) fMRI BOLD signals               (SS: spaghetti, astsa palette)
##    cols 2:5 cortex, 6:9 thalamus/cerebellum (col 1 is time)
## ---------------------------------------------------------------
## two panels: Cortex (top), Thalamus & Cerebellum (bottom).
## Two BOLD location-traces per panel (spaghetti), shared ylim, with the
## periodic stimulus overlaid as a step function.
x        <- ts(fmri1[, 2:9], start = 0, freq = 32)   # 8 series at 8 locations
stimulus <- ts(rep(c(rep(.6, 16), rep(-.6, 16)), 4), start = 0, freq = 32)
panels   <- list(Cortex = 1:4, "Thalamus & Cerebellum" = 5:8)
ss_png("sample_fmri.png", h = 4.8)
par(mfrow = c(2, 1), cex = .8)
for (i in seq_along(panels)) {
  tsplot(x[, panels[[i]]], ylab = "BOLD", xlab = "", main = names(panels)[i],
         col = 3:6, ylim = c(-.6, .6), lwd = 1.5, xaxt = "n", spaghetti = TRUE)
  axis(side = 1, at = 0:4, labels = seq(0, 256, 64))
  lines(stimulus, type = "s", col = gray(.3))
}
mtext("seconds", side = 1, line = 1.75)
dev.off()

message("Done. Wrote: sample_globaltemp.png, sample_speech.png, ",
        "sample_disaster.png, sample_fmri.png")

## ---------------------------------------------------------------
## 5) White noise vs 3-point moving average
##    Follows SS's own figure code (TSDA2, Examples 1.7-1.8):
##      a single tsplot(cbind(w,v), ...) with a SHARED ylim, which
##      forces both stacked panels onto the same vertical scale so
##      the variance reduction from smoothing is visually obvious.
## ---------------------------------------------------------------
set.seed(123456789)                  # SS's seed for this figure
w <- rnorm(500, 0, 1)                # white noise
v <- filter(w, filter = rep(1/3, 3)) # three-point moving average
ss_png("sample_wnma.png", h = 4.8)
tsplot(cbind(w, v), col = 4, ylim = c(-4, 4),
       title = c("white noise", "moving average"))
dev.off()

message("Wrote: sample_wnma.png")
