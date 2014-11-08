# rough draft - shows how I went through data and messed around to figure out beta values 

library(ggplot2)

var22 = table(data$C22, data$click)

C22 = data$C22					
index33 = which(C22 %in% 33)	#index of all values in C22 == 33

#C22[index33[1]] 				#1st time C22 == 33 

instances33 = length(C22[index33])

index35 = which(C22 %in% 35)
instances35 = length(C22[index35])

index39 = which(C22 %in% 39)
instances39 = length(C22[index39])

index41 = which(C22 %in% 41)
instances41 = length(C22[index41])

index43 = which(C22 %in% 43)
instances43 = length(C22[index43])

index46 = which(C22 %in% 46)
instances46 = length(C22[index46])


index47 = which(C22 %in% 47)
instances47 = length(C22[index47])

index163 = which(C22 %in% 163)
instances163 = length(C22[index163])

index167 = which(C22 %in% 167)
instances167 = length(C22[index167])


index169 = which(C22 %in% 169)
instances169 = length(C22[index169])

index171 = which(C22 %in% 171)
instances171 = length(C22[index171])

index175 = which(C22 %in% 175)
instances175 = length(C22[index175])

index291 = which(C22 %in% 291)
instances291 = length(C22[index291])

index295 = which(C22 %in% 295)
instances295 = length(C22[index295])

index297 = which(C22 %in% 297)
instances297 = length(C22[index297])

index303 = which(C22 %in% 303)
instances303 = length(C22[index303])

index425 = which(C22 %in% 425)
instances425 = length(C22[index425])

index427 = which(C22 %in% 427)
instances427 = length(C22[index427])

index431 = which(C22 %in% 431)
instances431 = length(C22[index431])

index547 = which(C22 %in% 547)
instances547 = length(C22[index547])

index559 = which(C22 %in% 559)
instances559 = length(C22[index559])

index681 = which(C22 %in% 681)
instances681 = length(C22[index681])

index683 = which(C22 %in% 683)
instances683 = length(C22[index683])

index1059 = which(C22 %in% 1059)
instances1059 = length(C22[index1059])

index1063 = which(C22 %in% 1063)
instances1063 = length(C22[index1063])

index1071 = which(C22 %in% 1071)
instances1071 = length(C22[index1071])

index1187 = which(C22 %in% 1187)
instances1187 = length(C22[index1187])

index1195 = which(C22 %in% 1195)
instances1195 = length(C22[index1195])

index1319 = which(C22 %in% 1319)
instances1319 = length(C22[index1319])

index1327 = which(C22 %in% 1327)
instances1327 = length(C22[index1327])

index1451 = which(C22 %in% 1451)
instances1451 = length(C22[index1451])

index1705 = which(C22 %in% 1705)
instances1705 = length(C22[index1705])

index1707 = which(C22 %in% 1707)
instances1707 = length(C22[index1707])

index1827 = which(C22 %in% 1827)
instances1827 = length(C22[index1827])

index1955 = which(C22 %in% 1955)
instances1955 = length(C22[index1955])

index1959 = which(C22 %in% 1959)
instances1959 = length(C22[index1959])

click33 = var22[1,2]
click35 = var22[2,2]
click39 = var22[3,2]
click41 = var22[4,2]
click43 = var22[5,2]
click46 = var22[6,2]
click47 = var22[7,2]
click163 = var22[8,2]
click167 = var22[9,2]
click169 = var22[10,2]
click171 = var22[11,2]
click175 = var22[12,2]
click291 = var22[13,2]
click295 = var22[14,2]
click297 = var22[15,2]
click303 = var22[16,2]
click425 = var22[17,2]
click427 = var22[18,2]
click431 = var22[19,2]
click547 = var22[20,2]
click559 = var22[21,2]
click681 = var22[22,2]
click683 = var22[23,2]
click1059 = var22[24,2]
click1063 = var22[25,2]
click1071 = var22[26,2]
click1187 = var22[27,2]
click1195 = var22[28,2]
click1319 = var22[29,2]
click1327 = var22[30,2]
click1451 = var22[31,2]
click1705 = var22[32,2]
click1707 = var22[33,2]
click1827 = var22[34,2]
click1955 = var22[35,2]
click1959 = var22[36,2]

alpha = 0.14
beta = runif(100, 50, 150)
smooth = alpha * beta

clicks = c(click33, click35, click39, click41, click43, click46, click47, click163, click167, click169, click171, click175, click291, click295, click297, click303, click425, click427, click431, click547, click559, click681, click683, click1059, click1063, click1071, click1187, click1195, click1319, click1327, click1451, click1705, click1707, click1827, click1955, click1959)

inst = c(instances33, instances35, instances39, instances41, instances43, instances46, instances47, instances163, instances167, instances169, instances171, instances175, instances291, instances295, instances297, instances303, instances425, instances427, instances431, instances547, instances559, instances681, instances683, instances1059, instances1063, instances1071, instances1187, instances1195, instances1319, instances1327, instances1451, instances1705, instances1707, instances1827, instances1955, instances1959)

num = clicks + smooth[1]
den = inst + beta[1]
m1 = mean(num / den)
med1 = median(num / den) 

num = clicks + smooth[2]
den = inst + beta[2]  
m2 = mean(num / den)
med2 = median(num / den) 

num = clicks + smooth[3]
den = inst + beta[3] 
m3 = mean(num / den)
med3 = median(num / den) 

num = clicks + smooth[4]
den = inst + beta[4] 
m4 = mean(num / den)
med4 = median(num / den) 

num = clicks + smooth[5]
den = inst + beta[5] 
m5 = mean(num / den)
med5 = median(num / den) 

num = clicks + smooth[6]
den = inst + beta[6] 
m6 = mean(num / den)
med6 = median(num / den) 

num = clicks + smooth[7]
den = inst + beta[7] 
m7 = mean(num / den)
med7 = median(num / den) 

num = clicks + smooth[8]
den = inst + beta[8] 
m8 = mean(num / den)
med8 = median(num / den) 

num = clicks + smooth[9]
den = inst + beta[9] 
m9 = mean(num / den)
med9 = median(num / den) 

num = clicks + smooth[10]
den = inst + beta[10] 
m10 = mean(num / den)
med10 = median(num / den) 

num = clicks + smooth[11]
den = inst + beta[11] 
m11 = mean(num / den)
med11 = median(num / den) 

num = clicks + smooth[12]
den = inst + beta[12] 
m12 = mean(num / den)
med12 = median(num / den) 

num = clicks + smooth[13]
den = inst + beta[13] 
m13 = mean(num / den)
med13 = median(num / den) 

num = clicks + smooth[14]
den = inst + beta[14] 
m14 = mean(num / den)
med14 = median(num / den) 

num = clicks + smooth[15]
den = inst + beta[15] 
m15 = mean(num / den)
med15 = median(num / den) 

num = clicks + smooth[16]
den = inst + beta[16] 
m16 = mean(num / den)
med16 = median(num / den) 

num = clicks + smooth[17]
den = inst + beta[17] 
m17 = mean(num / den)
med17 = median(num / den) 

num = clicks + smooth[18]
den = inst + beta[18] 
m18 = mean(num / den)
med18 = median(num / den) 

num = clicks + smooth[19]
den = inst + beta[19] 
m19 = mean(num / den)
med19 = median(num / den) 

num = clicks + smooth[20]
den = inst + beta[20] 
m20 = mean(num / den)
med20 = median(num / den) 

m = c(m1, m2, m3, m4, m5, m6, m7, m8, m9, m10, m11, m12, m13, m14, m15, m16, m17, m18, m19, m20)
med = c(med1, med2, med3, med4, med5, med6, med7, med8, med9, med10, med11, med12, med13, med14, med15, med16, med17, med18, med19, med20)

beta20 = c(beta[1], beta[2], beta[3], beta[4], beta[5], beta[6], beta[7], beta[8], beta[9], beta[10], beta[11], beta[12], beta[13], beta[14], beta[15], beta[16], beta[17], beta[18], beta[19], beta[20])

num = clicks + (alpha * 307)
den = inst + 307 
m307 = mean(num / den)
med307 = median(num / den)

num = clicks + (alpha * 200)
den = inst + 200 
m200 = mean(num / den)
med200 = median(num / den)

num = clicks + (alpha * 180)
den = inst + 180 
m180 = mean(num / den)
med180 = median(num / den)

num = clicks + (alpha * 220)
den = inst + 220 
m220 = mean(num / den)
med220 = median(num / den)

num = clicks + (alpha * 250)
den = inst + 250 
m250 = mean(num / den)
med250 = median(num / den)

num = clicks + (alpha * 275)
den = inst + 275 
m275 = mean(num / den)
med275 = median(num / den)

num = clicks + (alpha * 300)
den = inst + 300 
m300 = mean(num / den)
med300 = median(num / den)

num = clicks + (alpha * 325)
den = inst + 325 
m325 = mean(num / den)
med325 = median(num / den)

num = clicks + (alpha * 350)
den = inst + 350 
m350 = mean(num / den)
med350 = median(num / den)

num = clicks + (alpha * 375)
den = inst + 375 
m375 = mean(num / den)
med375 = median(num / den)

m666 = c(m1, m2, m3, m4, m5, m6, m7, m8, m9, m10, m11, m12, m13, m14, m15, m16, m17, m18, m19, m20, m307, m200, m180, m220, m250, m275, m300, m325, m350, m375)
med666 = c(med1, med2, med3, med4, med5, med6, med7, med8, med9, med10, med11, med12, med13, med14, med15, med16, med17, med18, med19, med20, med307, med200, med180, med220, med250, med275, med300, med325, med350, med375)

beta666 = c(beta[1], beta[2], beta[3], beta[4], beta[5], beta[6], beta[7], beta[8], beta[9], beta[10], beta[11], beta[12], beta[13], beta[14], beta[15], beta[16], beta[17], beta[18], beta[19], beta[20], 307, 200, 180, 220, 250, 275, 300, 325, 350, 375)

# make dataframe
x = c(beta66, beta666)
y = c(m666, med666) 	# mean, median

fac1 = rep("mean", length(m666))
fac2 = rep("median", length(med666))
fac = c(fac1, fac2)

bigbooty = data.frame(x, y, fac)
booty = ggplot(bigbooty, aes(x=x, y=y, colour=fac)) + geom_point()
booty = booty + ggtitle("Smoothing. Mean and median vs beta values")
booty = booty + ylab("") + xlab("Beta Values")
