# CRuMBCaKe

<img src="https://cdn.rawgit.com/khonegger/crumbcake/master/proj_ico.svg" height="180">


## What is it?
CRuMBCaKe is a MATLAB package for Bayesian linear modeling.  It stands for **C**ensored **R**egression **M**odeling using **B**ayesian methods with **C**onditional Heteros**k**edasticity.  Currently, it supports modeling with Normal, Binomial, and "heavy-tailed" Student's *t*-distributions.


## What is it good for?
CRuMBCaKe does vanilla linear modeling right out of the box, *plus* it handles cases of **data censoring** (where measurements are bounded on one or both ends) and **conditional heteroskedasticity** (where variance is a function of one or more independent variables) when you tell it to.  It takes a Bayesian approach to model fitting, using a Markov Chain Monte Carlo process to sample from posterior distributions of model parameters (via slice sampling).  This has a number of advantages over traditional Maximum Likelihood Estimation methods, like being able to incorporate prior information on parameters into the model and the ability to construct conditional posterior distributions.  Users unfamiliar with the process of Bayesian estimation are encouraged to check out John Kruschke's [Doing Bayesian Data Analysis](https://www.amazon.com/Doing-Bayesian-Data-Analysis-Second/dp/0124058884) for a gentle introduction, or Adrew Gelman's classic [Bayesian Data Analysis](https://www.amazon.com/Bayesian-Analysis-Chapman-Statistical-Science/dp/1439840954) for a more challenging read.

### An example
Let's say we're interested in determining how a certain drug affects cognitive performance in a task.  Being good experimentalists, we recruit some participants and randomly assign half of them to the drug group and half to placebo.  We then give them a cognitive test, grade it, and collect the scores.  We're really excited to run some statistical tests on our data, but we notice two issues that make the data difficult to interpret by typical methods: 1) the cognitive test seems to be too easy and many of the participants in both groups got perfect scores; and 2) the variance of scores from the drug group is much larger than placebo.

This is problematic because many of our beloved null hypothesis significance tests, e.g. t-test, assume that the variance of our two groups does not differ (i.e. [homoskedasticity](https://en.wikipedia.org/wiki/Homoscedasticity)) and that the data are not heavily skewed.  Since our data clearly violate these assumptions, inference made from standard out-of-the-box t-tests is technically invalid.  Obviously, the score pileup at 100% will obscure any estimated experimental effects on the mean and variance.  What are we to do?

### Another example
Let's say we're pretty sure that our drug treatment is having some effect on score variance, but not necessarily the mean.  Furthermore, we believe that the increase in score variability is only seen in male subjects, and not females.  To complicate matters further, it looks like females have higher scores on average and, thus, suffer from more pileup at 100%. To translate this into a statistical problem - we'd like to test the [interaction](https://en.wikipedia.org/wiki/Interaction_(statistics)) between sex and drug treatment on variance, while taking into account the difference in means and the effect it may have on variance estimates.   Keep in mind that pileup at 100% will shrink variance estimates.  In addition, we'd like to be able to estimate the actual size of those effects (how much does score variability change in females relative to males), controlling for the effects of mean differences and pileup (data censoring).


## Getting started

### Installation in MATLAB
Installing MATLAB packages is straightforward.  Simply clone (or download) the repository to your local machine and add the **crumbcake** package, with subdirectories, to MATLAB's path:
```
addpath(genpath('/local_path_to/crumbcake'))
```

## Usage
Getting started with CRuMBCaKe is pretty easy.  After adding the **crumbcake** directory to MATLAB's path, we can pass a properly formatted data matrix (more about that below) to the `crmbck` function and get back a Bayes Linear Model (blm) object containing the Markov chain with model parameter estimates and associated methods (well, technically function handles since the blm object right now is just a structured array).

### Input data formatting
CRuMBCaKe expects a matrix with a specific structure.  The observations must be arranged as rows and variables as columns.  If you'd like the model to fit an intercept term (highly recommended) include a column of ones as the first column of the matrix:
```
my_data_with_intercept = [ones(size(my_data,1),1) my_data];
```
If you'd like the model to fit an(y) interaction term(s), append the product of the two categorical variables as a new column:
```
my_data_with_X1_x_X2_interaction = [my_data my_data(:,1).*my_data(:,2)];
```
The **final column** must correspond to the dependent (a.k.a. outcome, response, predicted) variable.

### Example using simulated data
We'll use the fuction `crumbTestData` included in the repo to simulate some data:
```
test_data = crumbTestData('normal', 0.7, 0.1, [-Inf 1], 1e3);
```
This will create a test dataset with 1000 simulated outcomes.  We've specified that the data be drawn from a normal distribution with overall mean of 0.5 and standard deviation of 0.1.  The `[-Inf 1]` gives the censoring interval - any simulated values greater than 1 will be set to one.

## Contributors
CRuMBCaKe was written by, and is maintained by, Kyle Honegger (Harvard University).

## License
Released under MIT License.  See LICENSE for more details.
