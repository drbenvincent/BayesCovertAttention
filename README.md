# BayesCovertAttention


Code associated with the paper **Vincent (submitted) [Bayesian accounts of covert selective attention: a tutorial review]()**.

## Dependencies
* This is Matlab code, so you need a working copy of Matlab. It was tested on version 2014a, on Mac OS X, but should hopefully work with other versions and OS's.
* This code requires an install of JAGS, which can be downloaded from [http://mcmc-jags.sourceforge.net](http://mcmc-jags.sourceforge.net).
* A copy of `matjags` is included and so does not require installation. The github repository, which may contain updates is [https://github.com/msteyvers/matjags](https://github.com/msteyvers/matjags).
* Functions in the `code` folder are helper functions written by myself.
* Subfolders of the `code` folder contain code written by other people, available from Mathworks File Exchange. These folders contain the license files. The code `export_eps` may require you to install Ghostscript, but more information is available [here](https://github.com/ojwoodford/export_fig).


## THERE ARE 2 IMPLEMENTATIONS HERE
1. **A non-MCMC implementation.** This code is significantly faster as we are not running MCMC chains etc. This code was used for a sanity check. Not all models will be able to be evaluated in the way achieved here. 
2. **An MCMC implementation.** A more flexible, but involved implementation is provided which uses MCMC sampling.

## How to run the non-MCMC implementation code
But those wishing to not get bogged down in MCMC details should explore this code. The script `/code/runNonMCMCcode.m` runs the models and plots the figures. The code for this implementation is at `/code/nonMCMCcode`.

## How to run the MCMC implementation code
To run the models, set the `code` folder as the current directory in Matlab. Then run these files:

* `SCRIPTLocalisation.m`
* `SCRIPTcuedLocalisation.m`
* `SCRIPTdetection.m`

### Parallel computing
If the Matlab parallel toolbox is available, then it is possible to significantly speed up the MCMC calculations by running each MCMC chain on a different core of the processor. To enable parallel computing then firstly change all instances of `doparallel = 0;` to `doparallel = 1;` in the main files starting `SCRIPT...` listed above. Secondly, use of multiple cores must be initiated at the start of each Matlab session by entering `parpool` into the command window.

### Changing the number of simulated trials
During the development of the code it was useful to have an options flag to choose between a large number of simulated trials of the optimal observer, and a low number for testing purposes. To check the code works, the flag should be set as `run_type='testing'` in the `SCRIPT...` file being run. More accurate optimal observer performance is calculated by simulating more trials, by setting `run_type='publication'`, or one can make manual adjustments to variable `TRIALS`. This is the number of simulated experimental trials for each condition.