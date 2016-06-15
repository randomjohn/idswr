
# getting help ------------------------------------------------------------

?data.frame
help("data.frame")
help.search("data frame")
apropos("data.fr")

# atomic values -----------------------------------------------------------------

# scalars - covers integers and floats but we'll skip that detail
a <- 2
2+2
3+a

#characters
b <- "foo"
b

# dates and times exist, but will be covered in detail another time
c <- Sys.Date()
c
c - as.Date("2015/11/25")

# times can be used to assess performance
# d <- Sys.time()
# some complicated algorithm
# Sys.time()-d

# but better to use system.time( < your stuff here > )
# system.time( for (i in 1:10000) { do.simulation(parm1,parm2) })

# factors - will be covered with vectors

# R is technically an object-oriented language, so all sorts of objects can exist from these building blocks

# booleans - TRUE/FALSE - very useful with vectors

d <- TRUE
e <- FALSE


# clean up
rm(a,b,c,d,e)

# vectors -----------------------------------------------------------------

# most common way of creating is with c()
a <- c(1,2,3,4,5)
a

b <- c(2,4,6,8,10)
b

c <- a + b # elementwise addition
c

d <-  a + 1 # addition of a scalar to a vector
d

a[3] # subscripting
a[3] <- 18 # subscripted assignments
a
a[3] <- 3 # back to normal
a[1:2] # subscripting more than one element at a time

a[-1] # chopping off elements
a[-2]
a[-(2:3)]

a.1 <- 1:5 # what's behind this colon notation
a.1

# you can create vectors of strings, too
e <- c("foo","bar","bat")
e

# lists - flexible, named collections
f <- list(a=1, b="foo", c=c(1,2,3))
f
f$a
f[[1]]
f$c
f[[3]]

# flow control

for (i in c(2,3,4)) {
  print(i,a[i])
}
# for is sometimes, but not very commonly used, because of vectorization or sophisticated subscripting

a[2:4]

# instead of
# for (i in 2:4) {
#   a[i] <- a[i]+1
# }
# use
a[2:4] <- a[2:4]+1
a

# fancy subscripting
for (i in 1:5) {
  if (a[i]>3) {
    print(a[i])
  }
}
# or
print(a[a>3])
# you can do all sorts of fancy subscripting
a[b>=6]
# what's going on?
b >= 6
a[c(FALSE,FALSE,TRUE,TRUE,TRUE)]

# factors - for categorical variables
g <- c(1,2,1,2,1,2,1,2)
g.1 <- factor(g,labels=c("Low","High"))
g
g.1
# ordered factors exist for ordinal variables, not covered here

# functions exist as in other languages
do.it <- function(x,y=1) {
  return(x+y)
}
do.it(1)
do.it(x=1)
do.it(1,2)
do.it(1,y=2)
do.it(y=2) # error

# clean up
rm(a,b,c,d,e,f,g,g.1,do.it) # note we didn't have to clean up x,y - local scoping usually works as expected
                            #   at least in the beginning


# simple aggregated statistics --------------------------------------------

# the hard way
# define some groups
grp <- rep(c(1,2),4) # rep is one way to create structured vectors
grp
grp.fac <- factor(grp,labels=c("Low","High"))

# define some data
dat <- rnorm(8) + grp - 1 # rnorm generates standard normal random variables
                          # here, we create noise, and add some signal based on group
# basic statistics
mean(dat)
sd(dat)

# basic statistics by group
tapply(dat,grp.fac,mean)
tapply(dat,grp.fac,sd)


# the data frame ----------------------------------------------------------

# a list of vectors, can be mixed (number, character, vector, Date, etc.)

data("iris")
iris
View(iris)
str(iris)

# the data frame is the central object of a data analysis

# quick analysis
head(iris)
summary(iris)
# subscripting
iris[35,1]
iris[35,]
iris[,1]
iris$Sepal.Length
iris[[1]] # almost never used

iris$Sepal.Width[1]

# basic exploration, the hard way
mean(iris$Sepal.Width)
cor(iris$Sepal.Width,iris$Sepal.Length)
cor(iris[,1:4])

tapply(iris$Sepal.Width,iris$Species,mean)
tapply(iris$Sepal.Width,iris$Species,sd)

# functions work on data frames, too
add_1_to_col_1 <- function(df) {
  df[,1] <- df[,1]+1
  return(df)
}

iris2 <- add_1_to_col_1(iris)
head(iris); head(iris2)

# brushing over importing data --------------------------------------------

# internal: read.csv & read.table are the workhorses
# readr: readr package read_csv and read_table are more robust


# data analysis with dplyr ------------------------------------------------

# represents a shift in thinking over the last few years
# from vector-based like tapply to data frame centered
# dplyr (and sister packages) can be used to manipulate and clean data, but can also be used for data analysis

library(dplyr)
mean_stat_all <- iris %>% 
  summarise(n=n(),mean_Sepal_Width=mean(Sepal.Width),mean_Sepal_Length=mean(Sepal.Length),
            sd_Sepal_Width=sd(Sepal.Width),sd_Sepal_Length=sd(Sepal.Length))
mean_stat_all

mean_stat <- iris %>% 
  group_by(Species) %>% 
  summarise(n=n(),mean_Sepal_Width=mean(Sepal.Width),mean_Sepal_Length=mean(Sepal.Length),
            sd_Sepal_Width=sd(Sepal.Width),sd_Sepal_Length=sd(Sepal.Length))
mean_stat

# define a new variable and summarize that
mean_stat_trans <- iris %>% 
  mutate(Sepal.Area=Sepal.Length*Sepal.Width) %>% 
  group_by(Species) %>% 
  summarise(n=n(),mean_Sepal_Area=mean(Sepal.Area),sd_Sepal_Area=sd(Sepal.Area))
mean_stat_trans

# let's say that we know for a fact that any Sepal Length over 6.9 can only be Virginica, and,
# from another source, we know that anything indicating otherwise is a transcription error or some
# other administrative issue
mean_stat <- iris %>% 
  filter(Sepal.Length <= 6.9 | Species=="virginica") %>% 
  group_by(Species) %>% 
  summarise(n=n(),mean_Sepal_Width=mean(Sepal.Width),mean_Sepal_Length=mean(Sepal.Length),
            sd_Sepal_Width=sd(Sepal.Width),sd_Sepal_Length=sd(Sepal.Length))
mean_stat

# getting a grouped correlation matrix is a little harder, but not too bad:
cor_stat <- iris %>% 
  group_by(Species) %>% 
  do(data.frame(cor(.[,1:4])))
cor_stat

# data analysis with ggplot2 ----------------------------------------------

# ggplot2 enables you to do data visualization from an exploratory point of view

library(ggplot2)

# ggplot2 can be confusing at first
plot1 <- ggplot(iris,aes(x=Species,y=Sepal.Width))
plot1 # nothing is displayed because nothing was requested to be displayed

# layering demo
plot1 + geom_point()
plot1 + geom_boxplot()
plot1 + geom_boxplot() + geom_point()
plot1 + geom_boxplot() + geom_jitter()
plot1 + geom_boxplot() + geom_jitter(width=0.1)

plot2 <- ggplot(iris,aes(x=Sepal.Width,y=Sepal.Length))
plot2 + geom_point()
plot2 + geom_point(aes(colour=Species))
plot2 + geom_point(aes(shape=Species))

plot2 + geom_point(aes(shape=Species)) + geom_smooth(method="lm")
plot2 + geom_point(aes(shape=Species)) + geom_smooth(aes(colour=Species),method="lm")

plot2 + geom_point() + geom_smooth(method="lm") + facet_wrap(~Species)

# making plots pretty/publication ready with labels, annotations, etc. is hard and not covered here


# basic least squares -----------------------------------------------------

fit1 <- lm(Sepal.Length~Sepal.Width,data=iris)
fit1
coef(fit1)
summary(fit1)
plot(fit1) # uses base plotting system
 # base plot system, which this uses, is good for a lot of things

iris %>% 
  group_by(Species) %>% 
  do(data.frame(t(coef(lm(Sepal.Length~Sepal.Width,data=.)))))
