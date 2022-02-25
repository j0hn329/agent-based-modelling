library("Hmisc")
library("tidyr")

data = read.csv("/Users/jp/desktop/CSCU9Z7/Experiments/landuse-study-experiment-table.csv", skip = 6, stringsAsFactors = FALSE)

colnames(data) <- c("run", "agro.rate", "bio.rate", "step", "total.hectares", "total.cost")

# selecting the data subsets to be used in the plots
df1 = subset(data, agro.rate == 500 & bio.rate == 500)
df2 = subset(data, agro.rate == 1000 & bio.rate == 1000)
df3 = subset(data, agro.rate == 1500 & bio.rate == 1500)
df4 = subset(data, agro.rate == 2000 & bio.rate == 2000)
df5 = subset(data, agro.rate == 2500 & bio.rate == 2500)
df6 = subset(data, agro.rate == 3000 & bio.rate == 3000)

# combining the data subsets, represents the new dataframe to be used in the plots
x <- rbind(df1,df2,df3,df4,df5,df6)

xy <- unite(x, "payment.rate", c(agro.rate,bio.rate), sep=" ")

agg.mean <- aggregate(x, by = list(init.agro.rate = x$agro.rate, init.bio.rate = x$bio.rate), FUN = mean)
agg.sd <- aggregate(x, by = list(init.agro.rate = x$agro.rate, init.bio.rate = x$bio.rate), FUN = sd)

cbind(init.agro.rate = agg.mean$init.agro.rate, init.bio.rate = agg.mean$init.bio.rate, mean = agg.mean$total.hectares, sd = agg.sd$total.hectares, mean2 = agg.mean$total.cost, sd2 = agg.sd$total.cost)

plot(data$bio.rate, data$total.hectares, main = "Total Hectares in EFS's at Different Payment Rates", xlab = "Payment Rates (£)", ylab = "Total Hectares Planted (ha)")

## total hectares plot with standard deviation
errbar(agg.mean$init.bio.rate, agg.mean$total.hectares, agg.mean$total.hectares + agg.sd$total.hectares, agg.mean$total.hectares -  agg.sd$total.hectares, xlab = "Payment Rates (£)", ylab = "Total Hectares Planted (ha)", type = "b")
title(main = "Total Hectares in EFS's at Different Payment Rates")
quartz.save("/Users/jp/desktop/hectares-sd.png")

## total hectares plot with standard error
nruns = nrow(data) / nrow(agg.sd)
agg.sd$se <- agg.sd$total.hectares / sqrt (nruns)
errbar(agg.mean$init.bio.rate, agg.mean$total.hectares, agg.mean$total.hectares + agg.sd$se, agg.mean$total.hectares -  agg.sd$se, xlab = "Payment Rates (£)", ylab = "Total Hectares Planted (ha)", type = "b")
title(main = "Total Hectares in EFS's at Different Payment Rates")
quartz.save("/Users/jp/desktop/hectares-se.png")

## total cost plot with standard deviation
errbar(agg.mean$init.bio.rate, agg.mean$total.cost, agg.mean$total.cost + agg.sd$total.cost, agg.mean$total.cost -  agg.sd$total.cost, xlab = "Payment Rates (£)", ylab = "Total Cost (£)", type = "b")
title(main = "Total Cost of EFS's at Different Payment Rates")
quartz.save("/Users/jp/desktop/cost-sd.png")
