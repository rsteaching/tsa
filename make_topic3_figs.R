## ============================================================
## make_topic3_figs.R
## Topic 3 ("Measuring dependence") figures, rendered in the
## canonical tsplot house style (white background, light-gray
## gridlines, full box frame, minor ticks, serif type, blue line
## col = 4 / hex #2297E6) -- the same look as the Topic 1
## shinylive MA(1) sim and the Topic 2 SS figures.
##
## Figures produced (no titles baked in -- titles/captions are
## added in Topic3.qmd):
##   sample_lindep.png   linear vs non-linear association
##   heath1.png          Heathrow monthly tmax, the series
##   heath2.png          temperatures six months apart (lag-6 scatter)
##   heath3.png          sample correlogram
##   changepoints.png    illustrative mean-shift / variance-shift breaks
##
## Heathrow data: UK Met Office historic station data (Open
## Government Licence), monthly mean daily maximum temperature.
##   https://www.metoffice.gov.uk/pub/data/weather/uk/climate/stationdata/heathrowdata.txt
##
## Run from the same folder as Topic3.qmd:
##   Rscript make_topic3_figs.R      (or source() in RStudio)
## ============================================================

BLUE  <- "#2297E6"; INK <- "#2C2420"; AXIS <- "#666666"
GRIDC <- "#E0E0E0"; ZERO <- "#BBBBBB"; BG <- "#FFFFFF"; AMBER <- "#C8762A"

png_dev <- function(file, w = 8.2, h = 2.7) {
  png(file, width = w, height = h, units = "in", res = 200)
}

base_par <- function() {
  par(bg = BG, col.axis = AXIS, col.lab = INK, fg = AXIS, family = "serif",
      mar = c(3.4, 3.8, 1.0, 0.8), mgp = c(2.2, 0.5, 0), tcl = -0.3,
      cex.axis = 0.85, cex.lab = 0.95)
}

## tsplot-style panel: empty frame -> grid -> zero line -> box -> blue line
ts_panel <- function(x, y, ylim = NULL, xlab = "", ylab = "", xaxt = "s",
                     type = "l", zero = TRUE) {
  if (is.null(ylim)) ylim <- range(y, finite = TRUE)
  plot(x, y, type = "n", ylim = ylim, xlab = xlab, ylab = ylab,
       bty = "n", xaxt = xaxt, xaxs = "i")
  grid(nx = NULL, ny = NULL, col = GRIDC, lty = 1, lwd = 0.6)
  if (zero) abline(h = 0, col = ZERO, lwd = 0.8)
  box(col = AXIS, lwd = 0.8)
  if (type == "l") lines(x, y, col = BLUE, lwd = 1.0)
  if (type == "p") points(x, y, col = BLUE, pch = 20, cex = 0.8)
}

## ---------------------------------------------------------------
## 1) sample_lindep -- linear vs non-linear association
##    (faithful to the source R recipe: set.seed(123456), N(0,0.05))
## ---------------------------------------------------------------
set.seed(123456)
t   <- seq(-1, 1, by = 0.05)
eps <- rnorm(length(t), mean = 0, sd = 0.05)
ylin  <- t + eps
yquad <- t^2 + eps
clin  <- cor(ylin,  t)
cquad <- cor(yquad, t)

png_dev("sample_lindep.png", w = 8.2, h = 3.6)
base_par(); par(mfrow = c(1, 2))
ts_panel(t, ylin, ylim = c(-1.5, 1.5),
         xlab = sprintf("t   (sample corr. = %.4f)", clin),
         ylab = expression(y^{lin}), zero = FALSE, type = "p")
ts_panel(t, yquad, ylim = c(-0.5, 1.5),
         xlab = sprintf("t   (sample corr. = %.4f)", cquad),
         ylab = expression(y^{quad}), zero = FALSE, type = "p")
dev.off()

## ---------------------------------------------------------------
## Load Heathrow monthly tmax from the Met Office
## ---------------------------------------------------------------
url <- "https://www.metoffice.gov.uk/pub/data/weather/uk/climate/stationdata/heathrowdata.txt"
src <- if (file.exists("heathrowdata.txt")) "heathrowdata.txt" else url
raw <- readLines(src, warn = FALSE)
dat <- raw[grepl("^\\s*[0-9]{4}\\s+[0-9]{1,2}\\s", raw)]
sp  <- strsplit(trimws(dat), "\\s+")
yr   <- as.integer(vapply(sp, `[`, "", 1))
mo   <- as.integer(vapply(sp, `[`, "", 2))
tmax <- as.numeric(gsub("[*#]", "", vapply(sp, `[`, "", 3)))
ok   <- !is.na(tmax)
yr <- yr[ok]; mo <- mo[ok]; tmax <- tmax[ok]
Y    <- ts(tmax, start = c(yr[1], mo[1]), frequency = 12)

## ---------------------------------------------------------------
## 2) heath1 -- the series
## ---------------------------------------------------------------
png_dev("heath1.png", w = 8.2, h = 2.7)
base_par()
ts_panel(as.numeric(time(Y)), as.numeric(Y),
         xlab = "year", ylab = "tmax (\u00b0C)")
dev.off()

## ---------------------------------------------------------------
## 3) heath2 -- temperatures six months apart (lag-6 scatter)
## ---------------------------------------------------------------
h <- 6; a <- head(tmax, -h); b <- tail(tmax, -h); rr <- cor(a, b)
png_dev("heath2.png", w = 4.8, h = 4.4)
base_par(); par(mar = c(3.6, 3.8, 1.0, 1.0))
plot(a, b, type = "n", xlab = expression(Y[t] ~ "  (\u00b0C)"),
     ylab = expression(Y[t+6] ~ "  (\u00b0C)"), bty = "n")
grid(col = GRIDC, lty = 1, lwd = 0.6); box(col = AXIS, lwd = 0.8)
points(a, b, col = adjustcolor(BLUE, 0.55), pch = 20, cex = 0.7)
legend("topright", legend = sprintf("sample corr. = %+.3f", rr),
       bty = "o", bg = "white", box.col = GRIDC, text.col = INK, cex = 0.9)
dev.off()

## ---------------------------------------------------------------
## 4) heath3 -- sample correlogram
## ---------------------------------------------------------------
H <- 36; n <- length(tmax)
ac <- acf(tmax, lag.max = H, plot = FALSE)$acf[, 1, 1]
band <- 1.96 / sqrt(n)
png_dev("heath3.png", w = 8.2, h = 3.0)
base_par()
plot(0:H, ac, type = "n", ylim = c(-1.05, 1.05), xlim = c(-0.5, H + 0.5),
     xlab = "lag  h  (months)", ylab = expression(hat(rho)(h)),
     bty = "n", xaxt = "n", xaxs = "i")
grid(col = GRIDC, lty = 1, lwd = 0.6)
abline(h = 0, col = ZERO, lwd = 0.8)
abline(h = c(band, -band), col = AXIS, lwd = 0.7, lty = 2)
segments(0:H, 0, 0:H, ac, col = BLUE, lwd = 1.6)
points(0:H, ac, col = BLUE, pch = 20, cex = 0.8)
axis(1, at = seq(0, H, 6)); box(col = AXIS, lwd = 0.8)
dev.off()

## ---------------------------------------------------------------
## 5) changepoints -- illustrative mean / variance breaks (original)
## ---------------------------------------------------------------
set.seed(7); n <- 300; cp <- 150; tt <- seq_len(n)
mean_shift <- c(rnorm(cp, 0, 1),   rnorm(n - cp, 4, 1))
var_shift  <- c(rnorm(cp, 0, 0.6), rnorm(n - cp, 0, 2.4))
png_dev("changepoints.png", w = 8.2, h = 4.6)
base_par(); par(mfrow = c(2, 1), mar = c(3.0, 3.8, 0.8, 0.8))
for (s in list(mean_shift, var_shift)) {
  plot(tt, s, type = "n", xlab = "", ylab = expression(Y[t]),
       bty = "n", xaxs = "i")
  grid(col = GRIDC, lty = 1, lwd = 0.6); abline(h = 0, col = ZERO, lwd = 0.8)
  abline(v = cp, col = AMBER, lwd = 1.0, lty = 2)
  box(col = AXIS, lwd = 0.8); lines(tt, s, col = BLUE, lwd = 1.0)
}
mtext("t", side = 1, line = 1.8, cex = 0.95, col = INK)
dev.off()

message("Done. Wrote: sample_lindep.png, heath1.png, heath2.png, heath3.png, changepoints.png")
