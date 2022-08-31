<!-- ABOUT THE PROJECT -->
## About The Project: Statistical Analysis of Stimulant Use Risk Factors at Dartmouth

## Introduction and Rationale

The FiveThirtyEight Article [“College Students Aren’t The Only Ones Abusing Adderall”](https://fivethirtyeight.com/features/college-students-arent-the-only-ones-abusing-adderall/) notes that there is a need to better understand to the risk factors behind recreational stimulant use and abuse among college students. One of the key findings of the FiveThirtyEight analysis was that students at more selective institutions are more likely to report that the non-prescription use of stimulants as study drugs was popular on campus, making the opportunity to understand the extent to which this FiveThirtyEight claim regarding non-prescription stimulant use at selective institutions replicates at Dartmouth intriguing. 

The project sought to identify specific demographic risk factors that may induce a Dartmouth student to abuse stimulants. This question was addressed by a number of methods, including a linear regression with multiple predictors and regression analyses of individual risk factors which appear to be of greatest importance in the broader analysis. By digging deeper and building the models described in the methods, our project transforms a topic of frequent casual discussion with an immense impact on student lives into actionable insights for those involved in student wellbeing. 

## Methods

###Data Collection

The project’s method of data collection was through the use of an anonymous survey. The survey asked for the following demographic information: class year, race, sex, ethnicity, LGBTQIA+ identification, FGLI identification, major identification, Greek affiliation, and varsity athletic status. The race and major identification categories allowed respondents to choose multiple categories, while the rest required students to choose either yes/no or a single category. Furthermore, the survey asked the two core questions underlying the analyses: whether respondents used stimulants that were not prescribed to them in the past 6 months, and whether respondents believed the non-prescription use of stimulants as "study drugs" is popular on campus. Both of these questions were binary, yes/no questions, which follows the methodology of the survey conducted by FiveThirtyEight. Finally, the survey had an optional open-ended asking for student input for the Student Wellness center or campus leadership, in support of the project’s vision of providing actionable insight for key stakeholders in student wellbeing.  

###Data Analysis
* The logistic regression methodology was as follows: *
   1. Constructing a logistic regression model on multiple predictors
   2. Looking at the specific categorical factors with the seemingly greatest correlation with stimulant use and belief in stimulant use, running two logistic regressions with just this predictor and both stimulant use and belief in stimulant use to further discern whether the data point had an effect 
   3. For each of these categorical features of interest, we ran two logistic regressions with just this predictor and both stimulant use and belief in stimulant use to further discern whether the data point had an effect 

This methodology mirrors that of the analyses of categorical variables conducted by the authors of the original FiveThirtyEight analysis. For instance, the authors of the FiveThirtyEight analysis created binary categorical variables for suicidal ideation among respondents (a variable titled “seriously_thought_about_killing_oneself_last_year”) and then ran a logistic regression on it against their binary stimulant use and stimulant belief variables, just as this analysis does for a multitude of categorical predictors. 

* Applying data simulations to understand population effect sizes given the small survey sample size: *

###Data Analysis


## Built With

* [VHDL](https://www.seas.upenn.edu/~ese171/vhdl/vhdl_primer.html) - The VHSIC Hardware Description Language is a hardware description language that can model the behavior and structure of digital systems at multiple levels of abstraction, ranging from the system level down to that of logic gates, for design entry, documentation, and verification purposes

