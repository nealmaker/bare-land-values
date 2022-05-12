library("tidyverse")

# Tree List ####################################################################
stems_total <- 4088 / 24.072 #tpa/plots per ac
spp_comp <- 
  tibble(spp = c("beech", "hard maple", "striped maple", "hemlock", 
                 "yellow birch", "ash", "soft maple", "paper birch", 
                 "aspen", "other hardwood"), 
         pct = c(25, 26, 3, 1, 12, 2, 4, 10, 1, 16),
         tol = c(3, 3, 3, 3, 2, 2, 2, 1, 1, 1)) %>% 
  mutate(stems = round((pct / 100) * stems_total))

# DBH ##########################################################################
dist_table <- tibble(dbh_bar = c(2.7, 1.8, 1.3), # mean dbh by tolerance from Marquis
                     dbh_sd = c(1.8, 2, 1.4)) # sd for log normal dist found to match Marquis distributions

# 100 potential diameter lists (log normal dists developed to match Marquis)
x <- lapply(1:100, function(i) {
  y <- lapply(1:nrow(spp_comp), function(i) {
    rlnorm(spp_comp$stems[i], log(dist_table$dbh_bar[spp_comp$tol[i]]), 
           log(dist_table$dbh_sd[spp_comp$tol[i]]))
  })
  
  unlist(y)
})

# Their mean dbh & ba
dbh_bar <- sapply(x, mean)
ba <- sapply(x, function(i){
  sum(0.005454 * i ^ 2) * 24.072
})

# Target mean dbh is 1.8, target ba is 99.2
# Find best match for harmonic mean of those 2 targets
target <- psych::harmonic.mean(c(1.8, 99.2))
scores <- sapply(1:length(ba), function(i) {
  psych::harmonic.mean(c(dbh_bar[i], ba[i]))
})

dat <- tibble(spp = rep(spp_comp$spp, spp_comp$stems),
              dbh = x[[which.min(abs(scores - target))]])

rm(dist_table, spp_comp, x, ba, dbh_bar, scores, stems_total, target)

# Crown Ratios #################################################################
# Get FIA data
temp <- tempfile()
download.file(
  "https://github.com/nealmaker/tree-growth-nf/raw/master/data/nf-fia.rda", 
  temp)
load(temp)

# add bal as an indicator of CR & bins for dbh & bal
dat <- dat %>% 
  mutate(bal = forester::bal(dbh, 24.072 * .005454 * dbh ^ 2),
         dbhbin = cut(dbh, 0:10),
         balbin = cut(bal, seq(0, 120, by = 20), include.lowest = T))

# get cr distributions for spp, dbh, and bal bins from FIA data
cr_lookup <- nf_fia %>% 
  filter(spp %in% unique(dat$spp), dbh_s <= 10, bal_s <= 120) %>% 
  mutate(dbhbin = cut(dbh_s, 0:10), 
         balbin = cut(bal_s, seq(0, 120, by = 20), include.lowest = T)) %>% 
  group_by(spp, dbhbin, balbin) %>% 
  summarize(n = n(), cr_bar = mean(cr_s), cr_sd = sd(cr_s))

# sample from cr_lookup to populate cr
dat <- dat %>% group_by(spp, dbhbin, balbin) %>% 
  mutate(cr = rnorm(n = n(), 
                    mean = cr_lookup$cr_bar[cr_lookup$spp == spp[1] & 
                                              cr_lookup$dbhbin == dbhbin[1] & 
                                              cr_lookup$balbin == balbin[1]],
                    sd = cr_lookup$cr_sd[cr_lookup$spp == spp[1] & 
                                            cr_lookup$dbhbin == dbhbin[1] & 
                                            cr_lookup$balbin == balbin[1]]),
         cr = case_when(cr < 1 ~ 1, cr > 100 ~ 100, TRUE ~ cr)) %>% 
  ungroup()

rm(cr_lookup, nf_fia, temp)

# Logs #########################################################################
library(XLConnect)

# read in data
rqm <- readWorksheetFromFile("data/rqm_bayes.xlsx", sheet = 1,
                             header = TRUE, endCol = 8)
spp_grps <- readWorksheetFromFile("data/rqm_bayes.xlsx", sheet = 2,
                                  header = TRUE, endCol = 2)

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

rm(out, rqm, spp_grps)

# Clean data & save ############################################################
dat <- dat %>% mutate(plot = "marq") %>% 
  select(plot, spp, dbh, cr, logs)
write.csv(dat, file = "data/bare-land-with-logs-marquis.csv")

