library("rgenoud")

trees <- as_tibble(dat)
treesgo <- trees[!is.na(trees$spp), ]
params <- params_default
params$endyr <- 120

drates <- c(.073)

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

result_values <- lapply(1:length(drates), function(x){
  paramsnew <- params
  paramsnew$drate <- drates[x]
  treesx <- results[[x]]
  lapply(unique(treesgo$plot), function(y){
    treesy <- treesx[treesx$plot == y,]
    bl_objective(treesy$cutyr/paramsnew$steplength, treesy, params = paramsnew)
  })
})

result_values <- unlist(lapply(1:length(drates), function(i){
  unlist(result_values[[i]])
}))

result_values <- data.frame(type = rep(unique(trees$plot), length(drates)),
                            drate = rep(drates, 
                                        each = length(unique(trees$plot))),
                            bare_land_value = result_values)

save(results, result_values, file = "results.rda")
