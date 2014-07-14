# BayesCovertAttention


Code associated with the paper **Vincent (submitted) Bayesian accounts of covert selective attention: a tutorial review**.

## How to run the code
To run the models, set the `code` folder as the current directory in Matlab. Then run these files:

* `SCRIPTLocalisation.m`
* `SCRIPTcuedLocalisation.m`
* `SCRIPTdetection.m`

## Dependencies
* This is Matlab code, so you need a working copy of Matlab. It was tested on version 2014a, on Mac OS X, but should hopefully work with other versions and OS's.
* This code requires an install of JAGS, which can be downloaded from [http://mcmc-jags.sourceforge.net](http://mcmc-jags.sourceforge.net).
* Included is a copy of matjags. The repository for that, which may contain updates is [https://github.com/msteyvers/matjags](https://github.com/msteyvers/matjags).
* Subfolders of the `code` folder contain code written by other people, available from Mathworks File Exchange. These folder contain the license files. The code `export_eps` may require you to install Ghostscript, but more information is available [here](https://github.com/ojwoodford/export_fig).