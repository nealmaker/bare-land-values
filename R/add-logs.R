# ADD LOG CALLS TO SITE DATA

library(tidyverse)
library(XLConnect)

# read in data
rqm <- readWorksheetFromFile("data/rqm_bayes.xlsx", sheet = 1,
                             header = TRUE, endCol = 8)
spp_grps <- readWorksheetFromFile("data/rqm_bayes.xlsx", sheet = 2,
                                     header = TRUE, endCol = 2)
dat <- readWorksheetFromFile("data/bare-land-data.xlsx", sheet = 1, 
                             header = TRUE, endCol = 4) %>% 
  fill(plot)

# add spp grps to site data
dat$sppgrp <- spp_grps$grp[match(dat$spp, spp_grps$spp)]

# build logs calls based on spp group & log section
# use largest size class (good idea? pine was screwy with smaller.)
out <- lapply(1:nrow(dat), function(i){
  x <- lapply(1:10, function(j){
    sample(c(1,2,3,5), size = 1, 
           prob = rqm[rqm$spp == dat$sppgrp[i] & 
                        rqm$log == j & rqm$size_class == 4, 4:7])
  })
  do.call(paste0, x)
})
dat$logs <- unlist(out)
dat <- select(dat, -sppgrp)

write.csv(dat, file = "data/bare-land-with-logs.csv")
