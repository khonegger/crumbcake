# CRuMBCaKe

<img src="https://cdn.rawgit.com/khonegger/crumbcake/master/crmbck_icon_two.svg" width="100%" height="256">


## What is it?
CRuMBCaKe is a MATLAB package for Bayesian linear modeling.  It stands for Censored Regression Modeling using Bayesian methods with Conditional heterosKedasticity.  Currently, it is capable of implementing Normal, Binomial, and "heavy-tailed" Student's t models.


## What is it for?
CRuMBCaKe handles cases of **data censoring** (where measurements are bounded on one or both ends) and **conditional heteroskedasticity** (where variance is a function of one or more independent variables).

### An example
Let's say we're interested in determining how a certain drug affects cognitive performance in a task.  Being good little experimentalists, we recruit some participants and randomly assign half of them to the drug group and half to placebo.  We then give them a cognitive test, grade it, and collect the scores.  We're really excited to run some statistical tests on our data, but we notice two issues that make the data difficult to interpret by typical methods: 1) the test seems to be too easy and many of the participants in both groups got perfect scores; and 2) the variance of scores from the drug group is much larger than placebo.

This is problematic because many of our beloved null hypothesis significance tests, e.g. t-test, assume that the variance of our two groups does not differ [(homoskedasticity)](https://en.wikipedia.org/wiki/Homoscedasticity) and that the data are not heavily skewed.  Since our data clearly violate these assumptions, inference made from standard out-of-the-box t-tests is technically invalid.  Obviously, the score pileup at 100% will obscure any estimated experimental effects on the mean and variance.  What are we to do?

### Another example
Let's say we're pretty sure that our drug treatment is having some effect on score variance, but not necessarily the mean.  Furthermore, we believe that the increase in score variability is only seen in male subjects, and not females.  To complicate matters further, it looks like females have higher scores on average and, thus, suffer from more pileup at 100%. To translate this into a statistical problem - we'd like to test the [interaction](https://en.wikipedia.org/wiki/Interaction_(statistics)) between sex and drug treatment on variance, while taking into account the difference in means and the effect it may have on variance estimates.   Keep in mind that pileup at 100% will shrink variance estimates.  In addition, we'd like to be able to estimate the actual size of those effects (how much does score variability change in females relative to males), controlling for the effects of mean differences and pileup (data censoring).


## Installation in MATLAB
Clone (or download) the repository and add the **crumbcake** package, with subdirectories, to MATLAB's path:
```
addpath(genpath('/local/path/to/crumbcake'))
```

## Usage
Usage examples to come...
