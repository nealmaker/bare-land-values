# MAKE DATA SIM-READY (LOGS DONE ALREADY)

# Do this section on Big Tom, w/ forester --------------------------------------

library(forester)
library(tidyverse)

dat <- read.csv("data/bare-land-with-logs-marquis.csv") 
dat <- dat %>% 
  mutate(stand = 1,
         tree = 1:nrow(dat),
         lat = 44.441, # On Paul Smiths prop
         lon = -74.251,
         elev = 1700,
         tpa_tree = 24.072,
         ba_tree = tpa_tree * (.005454 * dbh ^ 2)) %>% 
  group_by(plot) %>% 
  mutate(ba = sum(ba_tree),
         bal = bal(dbh, ba_tree)) %>% 
  ungroup()

dat$spp <- factor(dat$spp, levels = levels(simtrees_sample$spp))

dat <- dat %>% 
  mutate(forest_type = "Northern hardwood",
         site_class = 5) %>% 
  select(stand, plot, tree, spp, dbh, cr, logs, ba, bal, lat, lon, elev, 
         forest_type, site_class, tpa_tree, ba_tree)

save(dat, file = "dat-temp.rda")

# Do this section on laptop, w/ ht_model_op ------------------------------------
library(tidyverse)
load("dat-temp.rda")
load("../big-rdas/ht-model-op.rda")

dat$ht <- predict(ht_model_op, newdata = dat)

dat <- select(dat, stand, plot, tree, spp, dbh, cr, logs, ba, bal, forest_type,
              site_class, lat, lon, elev, ht, tpa_tree, ba_tree)
class(dat) <- "simready"

save(dat, file = "dat-simready-marquis.rda")
