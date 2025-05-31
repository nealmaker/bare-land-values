# This is much newer than scripts 1-6 and uses an updated forestmaker ecosystem (as of May 29, 2025)


################################################################################
## Setup

load("dat-simready.rda")
class(dat) <- "data.frame"

dat <- dplyr::filter(dat, plot %in% c("hw-poor", "hw-rich", "mix"))
dat$spp <- as.character(dat$spp)
dat$spp[dat$spp == "soft maple"] <- "red maple"
dat$spp[dat$spp == "spruce"] <- "red spruce"
dat <- dplyr::rename(dat, tpa = tpa_tree)
dat$live <- TRUE
dat <- dplyr::rename(dat, ba_ac = ba_tree, height = ht) |> 
  dplyr::mutate(logs = as.character(logs))

plots <- data.frame(plot = unique(dat$plot), stand = 1)

new_dat <- list(trees = dat, plots = plots)
class(new_dat) <- "simcruise"

rm(dat, plots)
new_dat$plots$lev <- 0

m <- treemodeler::initialize_models("5.3", "slim", c("growth", "taper"))

# separate analyses by site, b/c lev will differ
hw_poor <- hw_rich <- mix <- new_dat
hw_poor$trees <- dplyr::filter(hw_poor$trees, plot == "hw-poor")
hw_poor$plots <- dplyr::filter(hw_poor$plots, plot == "hw-poor")
hw_rich$trees <- dplyr::filter(hw_rich$trees, plot == "hw-rich")
hw_rich$plots <- dplyr::filter(hw_rich$plots, plot == "hw-rich")
mix$trees <- dplyr::filter(mix$trees, plot == "mix")
mix$plots <- dplyr::filter(mix$plots, plot == "mix")

p <- forestgrower::params_default
# trees are already 30, so endyr of 120 = 150 yr rotation
p$endyr <- 120 # must be multiple of 15 b/c 15 year cutting cycle
p$drate <- .04 # more risk than timber, but this is a guess. Outcome is quite sensitive to d rate



################################################################################
## Poor Hardwood Site

p$lev <- 0 # to roughly converge, start lev @ 0, then use new lev from that opt, etc.
# if lev is set too high, plot will be regenerated immediately and outcome will be meaningless
# ------------------------------------------------------------------------------
opt <- forestmaker::opt_mngmt(hw_poor, p, "maple", m)
# use Faustmans LEV formula to get infinite series of rotations
lev <- (forestmaker::objective_maple(opt$trees$cutyr / 15, hw_poor$trees, p, m) /
  (1 + p$drate) ^ 30) / (1 - (1 + p$drate) ^ (-(max(opt$trees$cutyr) + 30)))
p$lev <- lev
# repeat until lev converges ---------------------------------------------------
new_dat$plots$lev[new_dat$plots$plot == "hw-poor"] <- lev



################################################################################
## Rich Hardwood Site

p$lev <- 0 # to roughly converge, start lev @ 0, then use new lev from that opt, etc.
# if lev is set too high, plot will be regenerated immediately and outcome will be meaningless
# ------------------------------------------------------------------------------
opt <- forestmaker::opt_mngmt(hw_rich, p, "maple", m)
# use Faustmans LEV formula to get infinite series of rotations
lev <- (forestmaker::objective_maple(opt$trees$cutyr / 15, hw_rich$trees, p, m) /
          (1 + p$drate) ^ 30) / (1 - (1 + p$drate) ^ (-(max(opt$trees$cutyr) + 30)))
p$lev <- lev
# repeat until lev converges ---------------------------------------------------
new_dat$plots$lev[new_dat$plots$plot == "hw-rich"] <- lev



################################################################################
## Mixedwood Site

p$lev <- 0 # to roughly converge, start lev @ 0, then use new lev from that opt, etc.
# if lev is set too high, plot will be regenerated immediately and outcome will be meaningless
# ------------------------------------------------------------------------------
opt <- forestmaker::opt_mngmt(mix, p, "maple", m)
# use Faustmans LEV formula to get infinite series of rotations
lev <- (forestmaker::objective_maple(opt$trees$cutyr / 15, mix$trees, p, m) /
          (1 + p$drate) ^ 30) / (1 - (1 + p$drate) ^ (-(max(opt$trees$cutyr) + 30)))
p$lev <- lev
# repeat until lev converges ---------------------------------------------------
new_dat$plots$lev[new_dat$plots$plot == "mix"] <- lev


################################################################################
## Save Results
out <- new_dat$plots |> dplyr::select(plot, lev) |> dplyr::rename(site = plot)