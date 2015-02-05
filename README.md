# BayesCovertAttention

**This code is also under licence: see LICENCE.txt.** 

This is the Matlab code associated with my paper: 

Vincent (in press) [Bayesian accounts of covert selective attention: A tutorial review]() Attention, Perception, & Psychophysics. DOI: 10.3758/s13414-014-0830-0

If you find the paper and/or code useful, the best way to thank me is by citing me :)

## Problems, suggestions?
Hopefully the code I provide here will be of use to people. If you have problems or require clarifications then I will try to be as responsive as possible. My preferred way of dealing with request is for you to create a GitHub issue. But feel free to email as well.

## Overview

I may periodically update the code for clarity, or to fix bugs. But the plan is for this repository to strictly represent the work done in the paper.

The code here provides TWO separate ways of practically evaluating the models. Two methods were used to gain confidence that any implementation errors have been eliminated.

## Implementation 1: MCMC

MCMC methods are flexible and more generally useful to a wider range of models. Readers interested in inspecting the code for the purpose of learning how to practically implement Bayesian models in general are directed to the MCMC methods. The downside of these methods is that they are slower to compute, and involve a little more Matlab code, so may involve longer to digest and understand.

* This is Matlab code, so you need a working copy of Matlab. It was tested on version 2014a, on Mac OS X, but should hopefully work with other versions and OS's.
* This code requires an install of JAGS, which can be downloaded from [http://mcmc-jags.sourceforge.net](http://mcmc-jags.sourceforge.net).
* A copy of `matjags` is included and so does not require installation. The github repository, which may contain updates is [https://github.com/msteyvers/matjags](https://github.com/msteyvers/matjags).
* Functions in the `code/funcs/bens_helper_functions` folder are written by myself.
* Other subfolders of the `code/funcs/` folder contain code written by other people, available from Mathworks File Exchange. These folders contain the license files. The code `export_eps` may require you to install Ghostscript, but more information is available [here](https://github.com/ojwoodford/export_fig).

*Warning: Running the MCMC version of the code is computationally intensive and takes time to compute.* 

Having set the `code` folder as the path in Matlab, the predictions for all models can be computed by entering the command `runAll('MCMC')` into the Matlab command window. If the Matlab parallel toolbox is available, then it is possible to significantly speed up the MCMC calculations by running each MCMC chain on a different core of the processor. To enable parallel computing then firstly change all instances of `doparallel = 0;` to `doparallel = 1;` in the main files starting `SCRIPT*.m` listed above. Secondly, use of multiple cores must be initiated at the start of each Matlab session by entering `parpool` into the command window.

During the development of the code it was useful to have an options flag to choose between a large number of simulated trials of the optimal observer, and a low number for testing purposes. To check the code works, the flag should be set as `run_type='testing'` in the file `runAll.m`. More accurate optimal observer performance is calculated by simulating more trials, by setting `run_type='publication'`, or one can make manual adjustments to variable `TRIALS`. This is the number of simulated experimental trials for each condition.


## Implementation 2: Grid approximation	
This implementation is fast to compute. The code is also potentially easier to understand. No additional files are required, eg. no JAGS.

Grid approximation is used for the observer's inferences about the display type on each trial. Because the display type is a categorical variable, and the number of display types is quite low, we can compute the joint distribution using grid approximation over the display types. This uses the fact that we can decompose the joint distribution of the probabilistic generative model down into the product of simple posteriors of node values conditional upon their parent node values.
An alternative, faster, implementation is also provided, which does not use MCMC methods. While the code here could be optimised further for speed, I chose to provide code maximising readability. 

Having set the `code` folder as the path in Matlab, the predictions for all models can be computed by entering the command `runAll('nonMCMC')`



## Overview of the code

The core functions that do the work are:

* `evaluateYesNo.m`
* `evaluateCuedYesNo.m`
* `evaluateCuedLocalisation.m`
* `evaluateLocalisation.m`

and, 

* `evaluateYesNoMCMC.m`
* `evaluateCuedYesNoMCMC.m`
* `evaluateCuedLocalisationMCMC.m`
* `evaluateLocalisationMCMC.m`

These functions are called repeatedly, under different simulated experimental conditions from the following functions. These functions are not central to those wishing to understand evaluation of the models as such, the are just wrapper functions.

* `SCRIPTyesno.m`
* `SCRIPTcuedYesNo.m`
* `SCRIPTLocalisation.m`
* `SCRIPTcuedLocalisation.m`
