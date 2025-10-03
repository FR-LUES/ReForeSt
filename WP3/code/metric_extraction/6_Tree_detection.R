# Now run ine execution script ---- !#
# ### preamble
#


# define range list for map function
chmRange <- seq(1:length(chms))

# count tree tops
ttops_list <- map(chmRange, function(x) count_ttops(chms[[x]], shapes[x,]))

df_ttops <- data.frame(ID = shapes$ID,
                       ttops = unlist(ttops_list))

# write out 
write.csv(df_ttops, file = paste0(path_outputs_ttops, "ttops_alt.csv"))