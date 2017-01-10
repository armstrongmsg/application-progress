library(ggplot2)

data <- read.csv("progress.csv")

ggplot(data, aes(timestamp, progress)) + geom_line()

ggsave("progress.png")
