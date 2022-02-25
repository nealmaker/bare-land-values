library("rgenoud")

trees <- as_tibble(dat)
treesgo <- trees[!is.na(trees$spp), ]
params <- params_default
params$endyr <- 120

drates <- c(.01, .02, .03, .05, .08)

results <- lapply(drates, function(j){
  paramsg <- params
  paramsg$drate <- j
  
  out <- lapply(unique(treesgo$plot), function(i) {
    treesg <- dplyr::filter(treesgo, plot == i)
    treelength <- nrow(treesg)
    
    cutyr <- genoud(bl_objective,
                    nvars = treelength,
                    max = TRUE,
                    pop.size = 50,
                    max.generations = 50,
                    wait.generations = 6,
                    hard.generation.limit = TRUE,
                    Domains = matrix(c(rep(0, treelength),
                                       rep(paramsg$endyr / paramsg$steplength,
                                           treelength)),
                                     ncol = 2),
                    solution.tolerance = 2,
                    boundary.enforcement = 2,
                    data.type.int = TRUE,
                    print.level = 1,
                    trees = treesg,
                    params = paramsg)$par
    
    return(data.frame(tree = treesg$tree, cutyr = cutyr))
  })
  
  cutyrs <- do.call(rbind, out)
  dplyr::left_join(trees, cutyrs, by = "tree") %>%
    mutate(cutyr = cutyr * paramsg$steplength)
})

