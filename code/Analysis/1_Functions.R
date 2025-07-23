# This script is to define help functions of our analysis linking biodiversity to LiDAR


# Data tidying ---- !#
# Beta transformation function
# This functions squeezes proportional data to be 0<>1 allowing it to be analysed assuming beta distributed errors
betaSqueeze <- function(x){
  xTrans <- (x * (length(x) - 1) + 0.5) / length(x)
  return(xTrans)
}










  
# Model fitting ---- !#
# Priors function
# A function to customize priors based on model formulas
# Currently this function returns the same prior each time, but may be useful as we build more complex models
make_priors <- function(include_dbhSD = TRUE, include_mean30mEffCan = TRUE, include_gap_prop = TRUE, include_stem_dens = TRUE,respo) {
  respo <- as.character(respo)
  p1 <- prior_string(paste0("normal(",0,", ",1,")"), class = "b", resp = respo)
  p2 <- c(
    prior(normal(0, 1), class = "b", resp = "dbhSD"),
    prior(normal(0, 1), class = "b", resp = "mean30mEffCan"),
    prior(normal(0, 1), class = "b", resp = "gapprop"),
    prior(normal(0, 5), class = "Intercept"),
    prior(exponential(1), class = "shape", resp = "dbhSD"),
    prior(exponential(1), class = "shape", resp = "mean30mEffCan"),
    prior(gamma(2, 0.1), class = "phi", resp = "gapprop")
  )
  priors <- c(p1, p2)
  
  if(include_stem_dens == TRUE){
    stemPriors <- c(prior(exponential(1), class = "shape", resp = "stemDensityHA"),
                    prior(normal(0, 1), class = "b", resp = "stemDensityHA"))
    priors <- c(priors, stemPriors)
  }
  
  return(priors)
}


# Model function
# A function that saves all the arguments of BRM so we do not need to double up

modelFunction <- function(form, data, priors){
 model <-  brm(
    formula = form,
    data = data,
    chains = 4,
    iter = 4000,
    sample_prior = "yes",
    init = 0,
    prior = priors,
    save_pars = save_pars(all = TRUE),
    cores = 2
    )
 return(model)
}













# Diagnostics ---- !#
# Prior posterior comparison
# A function to plot prior draws against posterior draws to sense check priors
ppComp <- function(model){
  #model <- models[[1]]
  response <- model$formula$responses[[1]]
  posteriorLong <- as_draws_df(model, resp = response) |>
    select(starts_with(paste0("b_", response))) |>
    pivot_longer(everything(), names_to = "Coef", values_to = "values") |>
    mutate(sample = "posterior")
  
  priorLong <- prior_draws(model) |>
    select(starts_with(paste0("b_", response))) |>
    pivot_longer(everything(), names_to = "Coef", values_to = "values") |>
    mutate(sample = "prior")
  
  rbind(posteriorLong, priorLong) |>
    ggplot() +
    geom_density(aes(x = values, fill = sample), alpha = 0.2, linewidth = 0.5) +
    facet_wrap(~Coef, scales = "free") +
    theme_classic()
}




# Residual correlations
# A function to check if residuals correlate with specific variables. Namely, sampling effort
# Currently only works for boxplots
residCorr <- function(model, variable){
  
  # Extract residuals for the first response only
  first_resp <- model$formula$responses[[1]] # Get response name
  resids <- residuals(model, type = "pearson", resp = first_resp)[, "Estimate"]# Extract residuals
  plot <- ggplot(data = model$data, aes(x = variable, y = resids))+
    geom_boxplot()+
    theme_classic()
  print(plot)# Plot residuals against variable
  
  return(resids)# save residuals
}

# Posterior prediction function
# There is a function for this already but here we had a bit so that it always extracts the species response variable
pp_response <- function(model){
  first_resp <- model$formula$responses[[1]]
  response <- model$formula$responses[[1]]
  print(pp_check(model, resp = response))
}


  
