# Make sure data plays nicely with simulator and stocking doesn't get crazy.

load("dat-simready.rda")
library(forester)
library(tidyverse)

class(dat) <- c("simready", "data.frame")

test_sim <- forester::new_simulation(rep(80, nrow(dat)), dat)

# look at how ba changes through time
View(test_sim$trees %>% group_by(plot, year) %>% 
       summarize(ba = sum(ba_tree * cumsurv)))
# This is problematic; will it affect optimization?