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
   * [Additional information](#additional-information)
      * [Reference](#reference)
      * [Contributors](#contributors)

## Description #
This repository contains the analysis code and data associated with Zhu et al., "Hedonic eating is controlled by dopamine neurons that oppose GLP-1R satiety"<br/>
![](/Diagrams/Figure_abstract_V8.png)

### Updates #
- Released the GitHub page, code, and data on 01/06/25. <br/>

### Installation #
- Data Collection: Based on Arduino and Bonsai.
- Analysis: Conducted using MATLAB R2022B and RStudio.

## Modules #

### Data collection #
- Behavioral data were collected using custom Arduino code to extract and analyze behavioral events. These data were analyzed using MATLAB.
- For more details, see the code and details in the [periLC paper](https://www.sciencedirect.com/science/article/pii/S0092867420309399), and the [CaRMA paper](https://www.science.org/doi/10.1126/science.abb2494). <br/>

### Photometry analysis #
- Fiber photometry data were recorded and extracted using the [FP3002 system (Neurophotometrics, CA)](https://neurophotometrics.com/). Fluorescent signals and behavioral events were collected with a [Bonsai workflow](https://bonsai-rx.org/). MATLAB was used to analyze fiber-photometry recordings and associated behavioral data.

### NBGLMM #
- To compare distributions of lick rates during variable palatability sessions, photostimulation, and photoinhibition, we used the glmmTMB package in R. This package fits negative binomial generalized linear mixed models (NB GLMM) to evaluate the effect of treatment conditions (e.g., laser on vs. off) on lick counts across time bins.<br/>
- Detailed comparisons for each condition are provided in the NBGLMM folder. <br/>

## Data #

### Photometry data #
- This repository includes related fiber photometry data from example mice for signal extraction. For additional data requests, please contact the authors. <br/>

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
