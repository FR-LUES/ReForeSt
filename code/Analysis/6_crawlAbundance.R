source("code/Analysis/0_setup.R")

sppLidar<- glm(q0 ~
                gap_prop +
                mean30mEffCan +
                area_ha,
               data = crawler,
               family = poisson(link = "log"))
summary(sppLidar)
