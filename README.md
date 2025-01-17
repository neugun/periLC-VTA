## Analysis for periLC-VTA paper

## Table of Contents #
   * [Description](#description)
   * [Installation](#Installation)
   * [Modules](#modules)
      * [Data collection](#Data-collection)
      * [Photometry analysis](#Photometry-analysis)
      * [NBGLMM](#NBGLMM)
   * [Data](#Data)
      * [Photometry data](#example-data)
      * [Source data](#Source-data)
   * [Additional information](#additional-information)
      * [Reference](#reference)
      * [Contributors](#contributors)

## Description #
The analysis code and data associated with Zhu et al. "Hedonic eating is controlled by dopamine neurons that oppose GLP-1R satiety", Science, in revision .  <br/><br/>
![](/Diagrams/Figure_abstract_V8.png)

### Updates #
- Released the github page, code and data on 01/06/25. <br/>

### Installation #
Data collection are based on Arduino and Bonsai;
Analysis are based on MATLAB R2022B and R studio;

## Modules #

### Data collection #
- To extract and analyze the behavior data, behavioral events were collected using a custom Arduino code. Behavioral data were analyzed using MATLAB.
- See more details in [periLC paper](https://www.sciencedirect.com/science/article/pii/S0092867420309399), and [CaRMA paper](https://www.science.org/doi/10.1126/science.abb2494). <br/>

### Photometry analysis #
- To extract and analyze the fiber photometry data, we used the commercial fiber photometry FP3002 system (Neurophotometrics, CA). Using this setup, fluorescent signals and behavioral events were collected using a custom Bonsai workflow. Fiber-photometry recordings and associated behavioral data were analyzed using MATLAB.

### NBGLMM #
- In the comparison of distributions of lick rate during variable palatability session, photostimulation, and photoinhibition, we used the glmmTMB package in [R]
(https://cran.r-project.org/web/packages/glmmTMB/index.html) to fit negative binomial generalized linear mixed models (NB GLMM) to evaluate the effect of treatment condition (e.g., laser on vs. off) on lick number across time bins.<br/>
- More details for each comparison can be found inside the NBGLMM folders. <br/>

## Data #

### Photometry data #
- We provide the related fiber photometry data of example mice for signal extraction. Additional data request can be sent to authors. <br/>

### Source data #
- Source data for each figures are also provided.

## Additional information #

### Reference #

**Hedonic eating is controlled by dopamine neurons that oppose GLP-1R satiety** <br/>
*Zhenggang Zhu, Rong Gong, Vicente Rodriguez, Kathleen T. Quach, Xinyu Chen,
Scott M. Sternson* <br/>
[zenodo](https://doi.org/10.5281/zenodo.14679761)

### Contributors#
Zhenggang Zhu <br/>
Rong Gong <br/>
Kathleen T. Quach <br/>
Scott M. Sternson <br/>
