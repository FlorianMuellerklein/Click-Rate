Click-Rate
==========

Three tries:

basiclogitsubmit - first try

feature.eng.r - (4 - Nov, 2014)

testing.feature.eng - current edit

From now on all edits, attempts, etc will be direct edits to testing.feature.eng

Steps: 

1. calculate click rate for each category
2. for low instance category, calculate pseudo-click rate
3. pseudoCR -> click + alpha * beta / instances + beta 
4. alpha = mean click rate = 0.14 
5. beta = SD for category -> see smoothCR.r
