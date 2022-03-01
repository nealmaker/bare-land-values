# 7.3% discount rate (from John McGann)
load("results073.rda")

params <- params_default
params$endyr <- 120
params_f <- params
params_f$drate <- .073

cut_yrs <- results[[1]]$cutyr
ff_bareland_sim_073 <- new_simulation(cut_yrs, results[[1]], params = params_f)

# calculates cash flows for one plot
cash_flows <- function(trees, logs, params) {
  standing <- trees %>%
    dplyr::group_by(year) %>%
    dplyr::summarize(standing = sum(lv * tpa_tree, na.rm = T)) %>%
    dplyr::mutate(standing  = standing / (1 + params$drate) ^ year)
  harvest <- logs %>%
    dplyr::rename(year = cutyr) %>%
    dplyr::group_by(year) %>%
    dplyr::summarize(harvest = sum(stump_ac, na.rm = T)) %>%
    dplyr::mutate(harvest = harvest / (1 + params$drate) ^ year,
                  year = year + .1)
  df <- dplyr::left_join(standing, harvest, by = "year")
  
  df$harvest[is.na(df$harvest)] <- 0
  
  return(df)
}

par <- ff_bareland_sim_073$params
ff_cashflow <- lapply(unique(ff_bareland_sim_073$trees$plot), function(i){
  tr <- filter(ff_bareland_sim_073$trees, plot == i)
  lo <- filter(ff_bareland_sim_073$logs, plot == i)
  cash_flows(tr, lo, par)
}) 

names(ff_cashflow) <- unique(ff_bareland_sim_073$trees$plot)
save(ff_bareland_sim_073, ff_cashflow, file = "ff-sim-073.rda")
