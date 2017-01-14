library(ggplot2)
library(dplyr)

data <- read.csv("experiment-completion.csv")

data$cap <- as.factor(data$cap)
data$stage <- as.factor(data$stage)

# For now we just want to analyse data of the period when the application was actually running
# (remove warmup data)
data <- filter(data, completion > 0)

# To improve the visualization, we shift the timestamps so that the first one, for each cap, is zero.
timestamp2 <- c(c(filter(data, cap == "25")$timestamp - filter(data, cap == "25")$timestamp[1]),
c(filter(data, cap == "50")$timestamp - filter(data, cap == "50")$timestamp[1]),
c(filter(data, cap == "75")$timestamp - filter(data, cap == "75")$timestamp[1]),
c(filter(data, cap == "100")$timestamp - filter(data, cap == "100")$timestamp[1]))

data$timestamp2 <- timestamp2
# We are using number of complete stages as base to get the current stage. Therefore, the last stage number
# is useless
data <- filter(data, stage != 4)

# All caps together
ggplot() + geom_line(data = data, aes(log(timestamp2), completion, colour = data2$stage, group = 1)) + 
  facet_grid(. ~ cap)

# Scale-free
ggplot() + 
  geom_line(data = data, aes(log(timestamp2), completion, colour = data2$stage, group = 1)) + 
  facet_grid(. ~ cap, scales = "free")

# Individual caps
ggplot(filter(data, cap == "25"), aes(log(timestamp2), completion, colour = stage)) + 
  geom_line(group = 1) +
  ggtitle("CAP = 25")

ggplot(filter(data, cap == "50"), aes(log(timestamp2), completion, colour = stage)) + 
  geom_line(group = 1) +
  ggtitle("CAP = 50")

ggplot(filter(data, cap == "75"), aes(log(timestamp2), completion, colour = stage)) + 
  geom_line(group = 1) +
  ggtitle("CAP = 75")

ggplot(filter(data, cap == "100"), aes(log(timestamp2), completion, colour = stage)) + 
  geom_line(group = 1) +
  ggtitle("CAP = 100")

ggsave("progress.png")
