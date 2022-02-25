# MAKE DATA SIM-READY (LOGS DONE ALREADY)

# Do this section on Big Tom, w/ forester --------------------------------------

library(forester)
library(tidyverse)

dat <- read.csv("data/bare-land-with-logs.csv") %>% 
  mutate(stand = 1,
         tree = 1:nrow(dat),
         lat = 44.446, # On Franklin Falls prop
         lon = -73.947,
         elev = 1500,
         tpa_tree = 35,
         ba_tree = tpa_tree * (.005454 * dbh ^ 2)) %>% 
  group_by(plot) %>% 
  mutate(ba = sum(ba_tree),
         bal = bal(dbh, ba_tree)) %>% 
  ungroup()

dat$spp <- factor(dat$spp, levels = levels(simtrees_sample$spp))

ftypes <- data.frame(plot = unique(dat$plot),
                     forest_type = c("White pine",
                                     "Spruce-fir",
                                     rep("Northern hardwood", 3)),
                     site_class = c(5, 6, 5, 4, 5))
dat$forest_type <- ftypes$forest_type[match(dat$plot, ftypes$plot)]
dat$site_class <- ftypes$site_class[match(dat$plot, ftypes$plot)]

save(dat, file = "dat-temp.rda")

# Do this section on laptop, w/ ht_model_op ------------------------------------
load("dat_temp.rda")
load("../big-rdas/ht-model-op.rda")

