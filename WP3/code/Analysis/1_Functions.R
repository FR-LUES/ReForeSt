# This script is to define help functions of our analysis linking biodiversity to LiDAR


# Data tidying ---- !#
# Beta transformation function
# This functions squeezes proportional data to be 0<>1 allowing it to be analysed assuming beta distributed errors
betaSqueeze <- function(x){
  xTrans <- (x * (length(x) - 1) + 0.5) / length(x)
  return(xTrans)
}



# test <- filter(crawler, ID == "56429")
# p <- test$Count
# Function to calculate Hill numbers (effective number of species) ---- !#
hill_number <- function(p, q) {
  p <- p[p > 0]
  pProp <- p / sum(p)
  
  
  if(sum(p) == 0)
    { return(0)} else{
    if(q == 0) {
    return(length(p))
  } else{ if(q == "abund") {
    return(sum(p)) } else{
      if(q == 1) {
        return(exp(-sum(pProp * log(pProp), na.rm = TRUE)))
      } else{
    return((sum(pProp^q, na.rm = TRUE))^(1 / (1 - q)))
      }
    }
  }
      }
}




  










# Model somary function ---- !#
# This function extracts model summaries and tidies them up
#model <- sppMod
sumFun <- function(model) {
  #model <- q1Mod
  sum <- broom::tidy(model)
  response <- as.character(formula(model)[[2]])
  sum <- sum |>
    mutate(p.value = round(p.value, 3))
  
  if ("p.value" %in% names(sum)) {
    sum <- sum |>
      mutate(
        p.value = round(p.value, 3),
        sig = case_when(
          p.value < 0.001 ~ "***",
          p.value < 0.01  ~ "**",
          p.value < 0.05  ~ "*",
          p.value < 0.1   ~ ".",
          TRUE            ~ ""
        )
      )
  }
  
  sum <- sum |>
    mutate(response = response, .before = 1)
  return(sum)
}















# results plotting ---- !#
# This function extracts model effects and overlays them on ggplot

# Function to get structural terms in a model
get_struct_terms <- function(model, struct_vars) {
 
    terms <- names(coef(model))
    intersect(terms, struct_vars)
  }

# Labelling function
responseLabel_function <- function(response) {
  dplyr::case_when(
    response == "spp"           ~ "Total ground flora species richness",
    response == "sppWoodland"   ~ "Woodland ground flora species richness",
    response == "sppSpecialist" ~ "woodland ground flora specialist species richness",
    response == "spiderSpp" ~ "Spider species richness",
    response == "beetleSpp" ~ "Beetle species richness",
    response == "crawlerSpp" ~ "Crawling invert species richness",
    response == "Hoverflyrichness" ~ "Hoverfly species richness",
    response == "Cranefliesrichness" ~ "Cranefly species richness",
    response == "Flyinginvertrichness" ~ "Flying invert species richness",
    TRUE                        ~ response
  )
}

# Define consistent colours for all possible Source levels
source_colors <- c(
  "WrEN" = "#1b9e77",  # greenish
  "FTC"  = "#d95f02",  # orange
  "NC"   = "#7570b3"   # purple
)

plot_struct_effects <- function(model, data, response_name, struct_vars, struct_labs, taxa) {
  
   #model <- bestMods[[1]]
   #data <- flyData
   #response_name <- "Hoverflyrichness"
   #struct_vars <- struct_vars
   #taxa <- "Flying inverts"
  # Identify included structural terms in the model
  included_terms <- get_struct_terms(model, struct_vars)
  response_Lab <- responseLabel_function(response_name)
  
  # For each included structural term, get predicted values and plot
  plots <- map(included_terms, function(var) {
    #var <- included_terms[1]
    
  # Re name predictors
  predictor_lab <- case_when(var == "dbhSD" ~ "sd DBH",
                               var == "gap_prop" ~ "Gap fraction",
                               var == "mean30mFHD_gapless" ~ "Effective # canopy layers",
                               var == "mean30mFHD_gaps" ~ "Effective # canopy layers",
                               var == "ttops_den_las" ~ "Tree density las",
                               var == "stemDensity" ~ "Tree density field",
                               .default = var)
    
    pval <- broom::tidy(model) |> filter(term == var) |> pull(p.value) |> round(3)
    
    pval_label <- paste0("p = ", signif(pval, 3))
    
    #var <- included_terms[[1]]
    # Get predictions with confidence intervals
    pred_df <- get_model_data(model, type = "pred", terms = var, conf = TRUE) |> 
      as_tibble()
    
    # Plot points (raw data), prediction line, ribbon for CI
    ggplot() +
      geom_jitter(data = data, aes(x = !!sym(var),
                                   y = !!sym(response_name),
                                   colour = Source), alpha = 1, size = 3) + 
      geom_line(data = pred_df,
                aes(x = x, y = predicted),
                linewidth = 1) +
      geom_ribbon(data = pred_df,
                  aes(x = x, ymin = conf.low, ymax = conf.high),
                  alpha = 0.1) +
      labs(y = paste0(response_Lab),
           x = predictor_lab) +
      scale_colour_manual(values = source_colors, drop = FALSE) +  # <- this fixes consistency
      labs(y = response_Lab, x = predictor_lab) +
      annotate("text", x = Inf,
               y = Inf, label = pval_label,
               hjust = 1.1, vjust = 1.5, size = 5) +
      theme_gdocs()+
      theme(text = element_text(size = 20))
  })
  
  # Return list of plots for that model
  return(plots)
}


