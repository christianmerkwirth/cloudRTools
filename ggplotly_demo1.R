# Plotly demo scripts

library(data.table)
library(dplyr)
library(ggplot2)
library(plotly)

source('generate_theme.R')

df.car <- read.csv(url("http://www.sharpsightlabs.com/wp-content/uploads/2015/01/auto-snout_car-specifications_COMBINED.txt"))
df.car$year <- as.character(df.car$year)

g <- ggplot(data=df.car, aes(x=horsepower_bhp, y=top_speed_mph)) +
  geom_point(alpha=.4, size=2, color="#880011") 
print(g)

g <- g + ggtitle("Horsepower vs. Top Speed") +
  labs(x="Horsepower, bhp", y="Top Speed,\n mph")
print(g) 

g <- g + theme_bw()
print(g)

g <- ggplot(data=df.car, aes(x=top_speed_mph)) +
  geom_histogram(fill="#880011") +  
  ggtitle("Histogram of Top Speed") +
  labs(x="Top Speed, mph", y="Count\nof Records") +
  theme.car_chart_HIST
print(g)

g <- df.car %>%
  dplyr::filter(top_speed_mph >149 & top_speed_mph <159) %>%
  ggplot(aes(x= as.factor(top_speed_mph))) +
  geom_bar(fill="#880011") +
  labs(x="Top Speed, mph") +
  theme.car_chart
print(g)


g<- ggplot(data=df.car, aes(x=top_speed_mph)) +
  geom_histogram(fill="#880011") +
  ggtitle("Histogram of Top Speed\nby decade") +
  labs(x="Top Speed, mph", y="Count\nof Records") +
  facet_wrap(~decade) +
  theme.car_chart_SMALLM
print(g)


#-------------------------------
# BHP by SPEED (faceted: decade)
#-------------------------------
g <- ggplot(data=df.car, aes(x=horsepower_bhp, y=top_speed_mph)) +
  geom_point(alpha=.6,color="#880011") +
  facet_wrap(~decade) +
  ggtitle("Horsepower vs Top Speed\nby decade") +
  labs(x="Horsepower, bhp", y="Top Speed\n mph") +
  theme.car_chart_SMALLM
print(g)

g <- g + stat_smooth()
print(g)

g <- df.car %>%
  dplyr::group_by(year) %>%
  dplyr::summarize(max_speed = max(top_speed_mph, na.rm=TRUE)) %>%
  ggplot(aes(x=year,y=max_speed,group=1)) + 
  geom_point(size=5, alpha=.8, color="#880011") +
  stat_smooth(method="auto",size=1.5) +
  scale_x_discrete(breaks = c("1950","1960","1970","1980","1990","2000","2010")) +
  ggtitle("Speed of Year's Fastest Car by Year") +
  labs(x="Year",y="Top Speed\n(fastest car)") +
  theme.car_chart_SCATTER
print(g)


g <- ggplot(data=df.car, aes(x=horsepower_bhp,y=car_0_60_time_seconds)) +
  geom_point()
print(g)

g <- ggplot(data=df.car, aes(x=horsepower_bhp,y=car_0_60_time_seconds)) +
  geom_point(position = 'jitter') + 
  geom_smooth() + 
  theme.car_chart_SCATTER
print(g)

df <- as.data.table(df.car)
df[, weight_class := ceiling(car_weight_tons*10)]
df <- df[, if (.N >= 5) .SD, by = weight_class]
g <- ggplot(data=df, aes(x=horsepower_bhp,y=car_0_60_time_seconds)) +
  geom_point(position = 'jitter') + 
   geom_smooth() + 
  theme.car_chart_SCATTER +
  facet_wrap(~ weight_class, scales = 'fixed')
print(g)

theme_set(theme_classic())

# Histogram on a Continuous (Numeric) Variable
g <- ggplot(mpg, aes(x = displ)) + scale_fill_brewer(palette = "Spectral")

gg <- g + geom_histogram(aes(fill=class), 
                         binwidth = .3, 
                         col="black", 
                         size=.1) +  # change binwidth
  labs(title="Histogram with Auto Binning", 
       subtitle="Engine Displacement across Vehicle Classes")  
print(gg)


gg <- g + geom_histogram(aes(fill=class), 
                   bins=5, 
                   col="black", 
                   size=.1) +   # change number of bins
  labs(title="Histogram with Fixed Bins", 
       subtitle="Engine Displacement across Vehicle Classes") 
print(gg)

g <- ggplot(mpg, aes(x = cty))
g + geom_density(aes(fill=factor(cyl)), alpha=0.8) + 
  labs(title="Density plot", 
       subtitle="City Mileage Grouped by Number of cylinders",
       caption="Source: mpg",
       x="City Mileage",
       fill="# Cylinders")
print(g)

# Now to Plotly:

p <- ggplotly(gg)
print(p)

# Create a shareable link to your chart
# Set up API credentials: https://plot.ly/r/getting-started
chart_link = api_create(p)
chart_link

# For more graphs, see http://r-statistics.co/Top50-Ggplot2-Visualizations-MasterList-R-Code.html