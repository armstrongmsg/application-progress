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
ggplot() + geom_line(data = data, aes(timestamp2, completion, colour = data$stage, group = 1)) + 
  facet_grid(. ~ cap)

# Scale-free
ggplot() + 
  geom_line(data = data, aes(timestamp2, completion, colour = data$stage, group = 1)) + 
  facet_grid(. ~ cap, scales = "free")

ggsave("allcases.png")

# Individual caps
ggplot(filter(data, cap == "25"), aes(timestamp2, completion, colour = stage)) + 
  geom_line(group = 1) +
  ggtitle("CAP = 25")

ggsave("cap25.png")

ggplot(filter(data, cap == "50"), aes(timestamp2, completion, colour = stage)) + 
  geom_line(group = 1) +
  ggtitle("CAP = 50")

ggsave("cap50.png")

ggplot(filter(data, cap == "75"), aes(timestamp2, completion, colour = stage)) + 
  geom_line(group = 1) +
  ggtitle("CAP = 75")

ggsave("cap75.png")

ggplot(filter(data, cap == "100"), aes(timestamp2, completion, colour = stage)) + 
  geom_line(group = 1) +
  ggtitle("CAP = 100")

ggsave("cap100.png")

# Get the time spent in the stages
stage.times <- data.frame(stage = c(), cap = c(), time = c())

for (stage_ in c(0,1,2,3)) { 
  for (cap_ in c(25,50,75,100)) { 
    stage_data <- filter(data, stage == stage_ & cap == cap_) 
    stage.times <- rbind(stage.times, data.frame(stage=c(stage_), cap=c(cap_), time=c(max(stage_data$timestamp2)-min(stage_data$timestamp2))))
  }
}

# Get the ratio between the stage times using cap == 25% and cap == 100%
stage.times.ratio.100.25 <- stage.times %>% group_by(stage) %>% summarise(ratio = time[1]/time[4])
# Get the ratio between the stage times using cap == 50% and cap == 100%
stage.times.ratio.100.50 <- stage.times %>% group_by(stage) %>% summarise(ratio = time[2]/time[4])
# Get the ratio between the stage times using cap == 75% and cap == 100%
stage.times.ratio.100.75 <- stage.times %>% group_by(stage) %>% summarise(ratio = time[3]/time[4])

ggplot(stage.times.ratio.100.25, aes(stage, ratio)) + geom_bar(stat = "identity")
ggplot(stage.times.ratio.100.50, aes(stage, ratio)) + geom_bar(stat = "identity")
ggplot(stage.times.ratio.100.75, aes(stage, ratio)) + geom_bar(stat = "identity")

stage.times.ratio.all <- data.frame(case=c(), stage=c(), ratio=c())
stage.times.ratio.all <- rbind(stage.times.ratio.all, data.frame(case="25", stage=stage.times.ratio.100.25$stage, ratio=stage.times.ratio.100.25$ratio))
stage.times.ratio.all <- rbind(stage.times.ratio.all, data.frame(case="50", stage=stage.times.ratio.100.50$stage, ratio=stage.times.ratio.100.50$ratio))
stage.times.ratio.all <- rbind(stage.times.ratio.all, data.frame(case="75", stage=stage.times.ratio.100.75$stage, ratio=stage.times.ratio.100.75$ratio))

ggplot(stage.times.ratio.all, aes(stage, ratio)) + 
  geom_bar(stat = "identity") + 
  facet_grid(. ~ case) +
  ylab("ratio (cap X / cap 100%)")

ggsave("ratio.png")
