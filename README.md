# bare-land-values

## Notes on Bare Land Value Calculations
- Separate calculations for distinct site classes  
  - white pine  
  - spruce fir  
  - mixedwood  
  - poor hardwoods (red maple - beech)  
  - rich hardwoods (sugar maple - white ash)  
- Initialize a single plot for each site class to start, can go back and stochastically generate numerous plots for each site class later, to make it more robust.  
- Initial data should be of successfully regenerated even-aged forests, at some age just prior to when they might want to be thinned the first time. Age 30 prob. best (20 has a lot of trees)  
- Use 1/35 acre plots  

## White Pine
### @barrett_growth_1976 (wp in NH, reportedly ~average for wp in New England)  
- mean dbh age 20 ~3.8”; age 30 ~5.5
- ba age 20 ~ 123 sqft; age 30 ~ 167 sqft (based on dbh and stand density curve)

### @seymour_new_1987
- CR in 6.1” trees averages ~30%

### @lancaster_silvicultural_1978
- BA for 3.8” mean dbh is ~138 sqft @ a-line
- BA for 5.5” mean dbh is ~175 sqft @ a-line

### FIA data (my exploration)
- wp 4” - 7” in stands 140 - 200 sqft: mean CR is 35%, sd CR is 16%

### @eyre_forest_1980
- type 21; wp predominant, can be pure; common associates sm, asp, sometimes pb & yb

### Franklin Falls
- 480a plan shows sm, bf, pb as main associates

## Spruce-Fir
### @frank_silvicultural_1973
- spp composition on primary sw sites dominated by sp & fr. Other sw can include eh, wp, cd, tam. <25% hw. Hw are pb, yb, asp, sm, occassional be or hm

### @eyre_forest_1980
- corroborate frank on composition, in red spruce-balsam fir cover type (#33)

### @olson_forty_2012 central Maine
- at age 29, control (unthinned no herbicide) had ~11,000 trees/hectare, 37 sqm/ha ba (4,400 tpa, 160 sqft/ac ba)
- same stand was dominated by sp, bf, sm, asp, some pb. Bf ~ 3x more prevalent than sp

## Poor Hardwoods

We should treat this as a poorer nhw site (more like a beech ridge); can upgrade bare land value for better poor hardwoods. Our poor and rich values can show the overall range, and we can make judgments about specific sites after the fact.

### @leak_silvicultural_2014
- beech – red maple type on noncalcareous sandy tills, dominated by those spp, often w/ sw component, can include pb & asp; nhw type on noncalcareous finer tills have more hm & yb, but with a lot of be. Red oak in the right places.  
- Mean dbh on SI 60 stand @ age 30 is ~ 4” (reprod. From Solomon & Leak 1986)  
- a-line on hw chart for 4” dbh is ~ 90 sqft ba & ~ 1050 trees/ac  

### @marquis_clearcutting_1967 Bartlett stand after clearcutting
- 2684 stems/ac @ 30 yrs
- 30% be, 29% hm, 12% yb, 11% pb, & minimal pin cherry, sm, stm, sw @ 30 yrs.
- Mean dbh 1.8” @ 25 yrs.
- @ age 25, crop trees have:
  - mean dbh of 4.4 for pb, 3.9 ash, 3.5 sm, 3.2 yb, 2.8 hm, 2.7 be, 3.7 overall
  - CR ~ .5 for pb, ash, sm; ~.57 yb, hm, be
  - total of 385 crop trees/ac

### Franklin Falls
- hw stands in 480a dominated by sm, be, bf, eh, yb, bc, hm, in roughly that order

But think about how young stand composition is different!

## Rich Hardwoods

We should treat this as a nice enriched VT site; can downgrade bare land value for more intermediate sites.

### @leak_silvicultural_2014
- hm & ash dominate on enriched and calcareous sites, bw also w/ more calcium; on moderately enriched sites at Bartlett, patch cutting got 31% hm, 34% yb & pb, 11% ash & 16% be. Bill thinks better sites could get more hm & ash. On beech ridges, he saw 26% be, 41% birch & 11% hm.  
- Mean dbh on SI 60 stand @ age 30 is ~ 4” (reprod. From Solomon & Leak 1986)  
- a-line on hw chart for 4” dbh is ~ 90 sqft ba & ~ 1050 trees/ac

### See Poor Hardwoods notes from Marquis

## Mixedwoods

We’re talking about sites that are naturally mixed b/c of softwoody soils, not old field mixedwood.
In Franklin Falls, pine stands are really mixedwood (now); there are also sp-fr mixedwood sites:
- wp mixed has plurality of wp, also sm, bf, pb
- spfr mixed has bf, sm, yb, be, sp; in different proportions, but often in roughly that order

### @leak_silvicultural_2014
- a-line on mixed chart for 4” dbh is ~ 100 sqft ba & ~ 1150 trees/ac

### See poor hardwood notes from marquis

## AS BUILT: 1st TIME, FOR FRANKLIN FALLS
- (1) 1/35 ac plot for each type
- Used the 5 types above
- All plots are age 30

### Process
1. Used researched stocking numbers to determine #trees
2. assigned spp % based on research and experience and figured # plot trees proportionally
3. randomly sampled dbh from log normal dist (giving skew in line with @marquis) within spp (b/c pines will be bigger, eg.), adjusting mean dbhs for each spp to get desired overall mean dbh (from stocking research). Used std. dev. of 1.4 (in `rlnorm` as log(1.4)) b/c it consistantly gave good looking skews, without any wierdly large individuals.
4. Checked mean dbh & plot stocking; re-sampled dbh if necessary to get them close to target
5. randomly sampled from normal dist (histograms show they’re appx. normal) for CR within spp, using means and sds from FIA data (filtered for appropriate dbh and stand ba).
6. Assigned CRs to DBHs by hand, somewhat random, but bigger dbh getting bigger CR
7. Assigned log calls stochastically with RQM (all at once in R)

## AS BUILT: MARQUIS VERSION
- (1) 1/24.072 ac plot (24' radius, like FIA subplots)
- Representing one forest type: a kind of medium hw site on granitic tills (Marquis was at Bartlett)
- Plot is age 25 b/c Marquis has that data and that's often the preferred precommercial thinning date.
- Mostly based on @marquis_clearcutting_1967

### Process
1. Assumed softwood in Marquis was EH, because they listed that as the common softwood associate at the start of the paper. Used 169 trees total (would have been 170 based on Marquis total stocking numbers, but rounding in spp specific percentages changed it a bit). Spp percentages directly from Marquis' year 25 measurements: 25% BE (42 trees), 26% HM (44), 12% YB (20), 10% PB (17), 16% Other HW (was pin cherry in Marquis, 27 trees), 4% SM (7), 3% STM (5), 1% EH (2), 2% ASH (3), and 1% ASP (2).
2. Built log normal dbh distributions for intolerants, intermediates, and tolerants based on mean dbhs reported by Marquis (2.7, 1.8, and 1.3", respectively) and choosing SD for each to match the actual observed distributions that Marquis shows in Fig. 1. Std dev for intolerants was determined to be 1.8, intermediates 2.0, and tolerants 1.4. In R, written as rlnorm(n, log(mean), log(sd)).
3. Sampled from distributions (using Marquis definitions of which species belong to which tolerance group) to get 100 lists of potential dbhs for the plot.
4. Used list whose mean dbh and basal area most closely matched Marquis' observed values, by minimizing the difference between the harmonic mean of the Marquis measures and the harmonic mean of the diameter lists' measures.
5. Determined from FIA data that CR distributions are appx. normal. Grouped FIA data by species, 1" dbh classes, and 20sqft bal classes, then calculated mean and sd of crown ratios in each group.
6. Randomly sampled CR from normal distributions for each spp/dbh/bal group in plot data, using means and sds calculated in step 5, to generate unique CR for each tree.
