library("Hmisc")
library("tidyr")

# loading the data 
data = read.csv("/Users/jp/desktop/CSCU9Z7/Experiments/landuse-study-experiment-runtime-table.csv", skip = 6, stringsAsFactors = FALSE)

# setting the column names 
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

xy <- unite(x, "payment.rate", c(bio.rate,agro.rate), sep=" ")

# graph of all data 
plot(xy$step, xy$total.hectares, main = "Hectares Planted over Time", xlab = "Steps", ylab = "Hectares Planted")

# graph of all data cleaned up 
plot(xy$step, xy$total.hectares, pch = c(1,2,3,4,5,6)[as.numeric(as.factor(xy$payment.rate))], col= c(1,2,3,4,5,6)[as.numeric(as.factor(xy$payment.rate))], main = "Hectares Planted at Different Payment Rates over Time", xlab = "Steps", ylab = "Hectares Planted")
legend("bottomright", legend = levels(as.factor(xy$payment.rate)), pch = c(1,2,3,4,5,6), col = c(1,2,3,4,5,6), title = "Payment Rate")
quartz.save("/Users/jp/desktop/runtime-all.png")

agg.mean <- aggregate(x, by = list(init.bio.rate = x$bio.rate, init.agro.rate = x$agro.rate, init.step = x$step), FUN = mean)
agg.sd <- aggregate(x, by = list(init.bio.rate = x$bio.rate, init.agro.rate = x$agro.rate, init.step = x$step), FUN = sd)

errbar(agg.mean$init.step, agg.mean$total.hectares, agg.mean$total.hectares + agg.sd$total.hectares, agg.mean$total.hectares - agg.sd$total.hectares, xlab = "Steps", ylab = "Hectares Planted", type = "p")

agg.mean.sub = subset(agg.mean, init.step %% 10 == 0)
agg.sd.sub = subset(agg.sd, init.step %% 10 == 0)

agg.sub = as.data.frame(cbind(init.step = agg.mean.sub[,"init.step"], bio.rate = agg.mean.sub[,"bio.rate"], mean = agg.mean.sub[,"total.hectares"], sd = agg.sd.sub[,"total.hectares"]))

with(agg.sub[agg.sub$bio.rate == 500,], plot(init.step, mean, pch=1, col=1, main = "Hectares Planted at Different Payment Rates over Time", xlab = "Steps", ylab = "Hectares Planted", ylim = c(0,20000), type = "b"))
with(agg.sub[agg.sub$bio.rate == 1000,], points(init.step, mean, pch=2, col=2, type = "b"))
with(agg.sub[agg.sub$bio.rate == 1500,], points(init.step, mean, pch=3, col=3, type = "b"))
with(agg.sub[agg.sub$bio.rate == 2000,], points(init.step, mean, pch=4, col=4, type = "b"))
with(agg.sub[agg.sub$bio.rate == 2500,], points(init.step, mean, pch=5, col=5, type = "b"))
with(agg.sub[agg.sub$bio.rate == 3000,], points(init.step, mean, pch=6, col=6, type = "b"))
legend("bottomright", legend = c("500,500", "1000,1000", "1500,1500", "2000,2000", "2500,2500", "3000,3000"), pch = c(1,2,3,4,5,6), col = c(1,2,3,4,5,6), title = "Payment Rate")
quartz.save("/Users/jp/desktop/runtime-clean.png")



 











 
