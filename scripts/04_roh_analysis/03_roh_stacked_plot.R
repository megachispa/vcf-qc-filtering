library(ggplot2)

WORKDIR <- "/mnt/tank/scratch/ebarabanova/roh"
setwd(WORKDIR)

# Read table correctly
data <- read.table("roh_summary_table.txt",
                   header=TRUE,
                   sep="\t")

# Define class order
data$Class <- factor(data$Class,
                     levels=c("<1Mb","1-2Mb","2-4Mb","4-8Mb"))

# Plot
p <- ggplot(data,
            aes(x=Individual,
                y=Length,
                fill=Class)) +
  geom_bar(stat="identity") +
  scale_fill_brewer(palette="YlOrRd") +
  theme_bw() +
  ylab("Total ROH length (Mb)") +
  xlab("Individual") +
  theme(axis.text.x=element_text(angle=45, hjust=1))

# Save
ggsave("roh_stacked_plot.pdf",
       plot=p,
       width=8,
       height=5)
