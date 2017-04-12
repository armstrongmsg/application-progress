require(ggplot2)
require(dplyr)

completion.data <- read.csv("results/experiment-completion-many-caps.csv")
completion.data$cap <- as.factor(completion.data$cap)
completion.times <- filter(completion.data, completion == 1)

ggplot(completion.data, aes(timestamp, completion, color = cap)) + geom_line()
ggsave("results/completion.png")

ggplot(completion.times, aes(cap, timestamp)) + geom_bar(stat = "identity")
ggsave("results/completion-times.png")
ggplot(completion.times, aes(cap, (as.integer(cap)*timestamp)/100.0)) + geom_bar(stat = "identity")
ggsave("results/completion-times2.png")

# -------------------------------------------------------

completion.data.repeat <- read.csv("results/experiment-completion-repeat.csv")

completion.data.repeat$cap <- as.factor(completion.data.repeat$cap)

completion.data.repeat.25 <- filter(completion.data.repeat, cap == "25")
completion.data.repeat.50 <- filter(completion.data.repeat, cap == "50")
completion.data.repeat.75 <- filter(completion.data.repeat, cap == "75")
completion.data.repeat.100 <- filter(completion.data.repeat, cap == "100")

ggplot(completion.data.repeat.25, aes(timestamp, completion)) + 
  geom_point() +
  ggtitle("Completion X Time - CAP 25%") +
  xlab("Time") +
  ylab("Completion")

ggplot(completion.data.repeat.50, aes(timestamp, completion)) + 
  geom_point() +
  ggtitle("Completion X Time - CAP 50%") +
  xlab("Time") +
  ylab("Completion")

ggplot(completion.data.repeat.75, aes(timestamp, completion)) + 
  geom_point() +
  ggtitle("Completion X Time - CAP 75%") +
  xlab("Time") +
  ylab("Completion")

ggplot(completion.data.repeat.100, aes(timestamp, completion)) + 
  geom_point() +
  ggtitle("Completion X Time - CAP 100%") +
  xlab("Time") +
  ylab("Completion")

ggplot(completion.data.repeat, aes(timestamp, completion)) + 
  geom_point() + 
  facet_wrap(~cap) +
  xlab("Time") +
  ylab("Completion") +
  ggtitle("Completion X Time X CAP")

ggsave("results/completion.repeat.png")

completion.times.repeat <- filter(completion.data.repeat, completion == 1)

completion.times.repeat.ci <- c(lower=c(), upper=c(), cap=c())

for(cap_ in c(25, 50, 75, 100)){
  ci <- wilcox.test(filter(completion.times.repeat, cap == cap_)$timestamp, conf.int = TRUE)$conf.int
  completion.times.repeat.ci <- rbind(completion.times.repeat.ci, data.frame(lower=ci[1], upper=ci[2], cap=as.character(cap_)))
}

limits <- aes(ymax = upper, ymin = lower)
ggplot(completion.times.repeat.ci, aes(cap, (lower+upper)/2)) + 
  geom_bar(stat="identity") + 
  geom_errorbar(limits, width = 0.5) +
  xlab("CAP") +
  ylab("Completion time") +
  ggtitle("CAP X Completion Time")

ggsave("results/completioncap.repeat.png")

cpu.usage <- read.csv("results/cpu.usage", sep = ";")

cpu.usage$timestamp <- cpu.usage$timestamp - 60*60*3
ggplot(cpu.usage, aes(timestamp, user)) + geom_line()
