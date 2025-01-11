======
README
======

----------------------------------------------------
Detailed description of analysis for methods section
----------------------------------------------------
We used the glmmTMB package in R (https://cran.r-project.org/web/packages/glmmTMB/index.html) to fit negative binomial generalized linear mixed models (NB GLMM) to evaluate the effect of laser condition (on vs. off) on lick number across time bins. The model included laser, time bin, and their interaction (laser * time bin) as fixed effects, with random intercepts for animals and bouts nested within animals to account for repeated measures within animals and bouts. Zero-inflated NB GLMM were used if they provided a better goodness of fit than standard NB GLMM, as assessed using the likelihood ratio test (LRT), and if they had an overdispersion ratio of ~1. The zero inflation formula used time bin as a predictor, since the observed proportion of zeros generally increased over time. Post-hoc pairwise comparisons between the laser-on and laser-off conditions were conducted within each time bin using estimated marginal means (EMMs) derived from the full model via the emmeans package in R (https://cran.r-project.org/web/packages/emmeans/index.html). Differences between laser conditions were assessed using Wald tests, and p-values were adjusted for multiple comparisons using the Benjamini-Hochberg method. Significance of interaction between laser and time bin was assessed using the LRT to compare models with and without an interaction term. All analyses were performed in R (version 4.4.2). 

--------------------------------------
Succinct description for figure legend
--------------------------------------
Wald tests based on negative binomial GLMM of data

-----------------------
Files in this directory
-----------------------
--[ reshape_data.R ]--
R script used to reshape raw data provided by Zhenggang. Data is reshaped into a long format such that each row represents a single observation of lick count, and the new columns are animal_id, bout_num, time_bin, licks, and laser. The script iterates through each subdirectory in this directory and deposits an output file reshaped_data.txt into the subdirectory. 

--------------------------
Files in each subdirectory
--------------------------
--[ analyze_nb_glmm.Rmd ]--
This R Markdown file allows for R code to be executed in chunks and integrates outputs into the file. The results of executing the code on a particular dataset can be documented and assessed individually within each subdirectory. 

This script takes reshaped_data.txt from the same subdirectory and outputs the following files:
- interaction.txt
- laser_significance.txt
- nb_significance.txt
- observed_predicted_zeros.txt
- overdispersion_ratio.txt
- pairwise_comparisons.txt
- predicted_plot.jpg
- predicted_plot.svg
- predicted_values.txt
- workspace.RData
- zero_inflation_significance.txt. 

Models are specified as having the following structure : laser and time bin are interacting fixed effects, animal id and bouts nested within animal id are random effects. Data is initially fitted to a standard negative binomial generalized linear mixed model (NB GLMM). The standard NB GLMM is compared to a Poisson GLMM to justify its use over a simpler model for count data. The inclusion of zero-inflation in the model (ZI-NB GLMM) is assessed for its contribution to goodness of fit. This final best fit model (standard or zero-inflated) is used to determine the significance of interaction between laser and time bin, as well as to perform pairwise comparisons between laser-ON and laser-OFF conditions within each time bin.  

--[ ANMid_lickF_OFF.txt, ANMid_lickF_ON.txt ]-- 
Raw data provided by Zhenggang, with separate files for laser-ON and laser-OFF conditions. These files were used as input into reshape_data.R to generate a combined dataset, reshaped_data.txt.

--[ final_model.txt ]-- 
Describes the final model that best explains the dataset. This model is used to generate predicted values and pairwise comparisons. 

--[ interaction_significance.txt ]--
Comparison of models with and without interaction between laser condition and time bin, using likelihood ratio test (LRT). A significant p-value indicates that the interaction is significant. This method is preferred over a type III ANOVA when comparing nested models with complex random effects, and when we are primarily interested in overall contribution of an interaction. Lack of significance does not preclude local interaction effects. 

--[ laser_significance.txt ] --
Comparison of models with and without laser to assess the main effect of laser. 

--[ nb_significance.txt ]-- 
Comparison of poisson and negative binomial models, using likelihood ratio test (LRT). A significant p-value and a lower AIC value for the negative binomial model indicates that it has better goodness of fit. 

--[ observed_predicted_zeros.txt ]--
Comparison of the proportion of zeros observed in the dataset and those predicted by the NB GLMM and ZI-NB GLMM

--[ overdispersion_ratio.txt ]--
An overdispersion ratio of ~1 indicates that variance in the data aligns well with the variance assumed by the model. Overdispersion ratios are calculated for Poisson, NB, and ZI-NB GLMMs. 

--[ pairwise_comparisons.txt ]--
Pairwise comparisons between laser-ON and laser-OFF within each time bin. Estimated marginal means (EMMs) are computed from the fitted model. P-values for pairwise comparisons are derived from Wald tests (z-tests), which test whether the estimated difference in marginal means is significantly different from zero. The Benjamini-Hochberg adjustment method was used to adjust for multiple pairwise comparisons, which is appropriate for many comparisons that are not entirely independent. The contents of this .txt file can be easily copy-pasted into a spreadsheet for ease of viewing and manipulation.  

---[ predicted_plot.jpg, predicted_plot.svg ]--
Plots of the predicted values of the model, which are raw outputs from the log link function. These are not on the response (real-world) scale, but are instead are log(predicted licks). The response variable itself is not log-transformed; instead, the link function transforms the expected mean. Since the fitting of count data is conducted in this log-transformed space, the SE and CI computed from the model also make the most sense in this log scale. Since log(predicted licks) is not readily interpretable, these plots are not intended for publishing. Rather, it is meant to be used internally to visualize the effect sizes between ON and OFF laser conditions. 

--[ predicted_values.txt ]-- 
Predicted values generated by the final model. log(predicted licks) in the "emmean" column. Lower and upper confidence limits are indicated by "asymp.LCL" and "asymp.UCL", respectively. 

--[ reshaped_data.txt ]-- 
Data formatted by reshape_data.R for use as input into analyze_nb_glmm.Rmd.  

--[ time_bin_significance.txt ] --
Comparison of models with and without time_bin to assess the main effect of time_bin. 

--[ workspace.RData ]-- 
All objects created/loaded during the execution of analyze_nb_glmm.Rmd. Load workspace.RData to quickly manipulate and investigate analysis components without re-running full analysis.

--[ zero_inflation_significance.txt ]--
Comparison of models with and without zero-inflation, using likelihood ratio test (LRT). A significant p-value and a lower AIC value for the zi model indicates that zero-inflation improves goodness of fit.  

