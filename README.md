# CALCULATE REFERENCE VALUES OF MORPHOMETRIC PARAMETERS WITH R IN PERINATAL PERIOD OF HUMAN DEVELOPMENT

---

Authors:

- K. Zhur
- V. A. Dravgelis
- A.I. Kulgaeva
- N. Tsurikova

Curators:

- D.A. Zhakota
- M. Slavenko

## The aim of the study

To create a script in the R programming language for the formation of morphometric parameters reference values from the original Excel file template. The result of the script should be presented in the form of tables and graphs.

## Objective

Each period of development of a human embryo, fetus and newborn baby is characterized by its own morphometric features of body size and internal organs, as well as their weight parameters. In clinical practice, obstetricians-gynecologists and neonatologists draw conclusions about the development and degree of maturity, as well as the predicted risks of developing a variety of diseases of various genesis, in a human embryo, fetus, and newborn child based on the available reference values. Due to the presence of references on the development of the embryo and fetus, as well as dynamic control over the development of the embryo and fetus, clinicians justify the need for additional examinations and preventive measures, and pathologists make a conclusion about the maturity of the fetus and formulate a final pathoanatomical diagnosis. Morphometric data is collected and updated periodically in all countries [1-3]. No such studies have been conducted in the Russian Federation.

## Methods

Retrospective monocentric cohort study was performed. Data was collected from the 10639 records of consecutive fetal and perinatal autopsies performed at the pathoanatomical department of pediatric profile (Moscow, Russia) between 2005 and 2014 years (autopsy protocols).  General exclusion criteria were: (1) chromosomal abnormalities, (2) congenital malformations, (3) missing, (4) gestational age < 20 weeks, (5) gestational age >42 weeks, (6) inconclusive gestational age, (7) live-birth > 24 hours, (8) multiple gestation, (9) infections, (10) intrauterine growth retardation (IUGR), (11) maceration. All of the data extracted were pooled into a single data set. This included male and female fetuses, stillbirths and livebirths. The following data served as the object of analysis: body weight, body height, head circumference, chest circumference, weight of internal organs (brain, lung, liver, kidney, pancreas, heart, thymus, spleen, adrenal, placenta). The sample population that was used in this study is truly representative of the mixed population present in Russian society.

## Repository description

The *raw_data_processing* folder contains the scripts that were used to load, preprocess and filter the raw data. The *script_data_20\*\** scripts are responsible for working with the raw data of the corresponding year. The document *2005_2014_data_processing.Rmd* combines the result of these scripts and plots violin plots for data. *graphics* folder contains script *comparative_plots.rmd*, which is responsible for visualising all comparative plots.

## Statistical analysis

Data analysis for this study was performed using R software (version: x64 4.2.2) [4] and Reference Value Advisor v2.1 (set of macroinstructions to calculate reference intervals with Microsoft Excel) [5].

## Results

A total of 1695 post-mortem examination reports were analysed for this study. There were 805 (47.5%) females and 890 (52.5%) males. Reference ranges comprising mean and standard deviation (SD), 25th, 50th and 75th percentiles for each parameter at each gestational age have been produced using R software and Reference Value Advisor v2.1. The obtained results (mean and standard deviation) were verified by comparison reference values that were calculated using our script 1) with reference values that were computed with Reference Value Advisor V2.1 on the same set of data and 2) with reference values that were developed by Sung, by Bartosch et al. for the Portuguese populations and by Phillips et al. for the Australian populations, respectively [2,3,6]. Comparison of reference values was made graphically by using line charts. The trends of the charts were consistent and did not have pronounced deviations from each other for all of the compared characteristics.

## Сonclusion

The obtained morphometric parameters reference values are in agreement with the literature data and with the results of proprietary software. Our R script that was developed using open-source software allows the user to automate data cleaning, formation of reference values and generation of summary tables and graphs according to generally accepted standards.

## References

1. Archie JG, Collins JS, Lebel RR. Quantitative standards for fetal and neonatal autopsy. Am J Clin Pathol. 2006 Aug;126(2):256-65. doi: 10.1309/FK9D-5WBA-1UEP-T5BB. PMID: 16891202.
2. Bartosch C, Vilar I, Rodrigues M, Costa L, Botelho N, Brandão O. Fetal autopsy parameters standards: biometry, organ weights, and long bone lengths. Virchows Arch. 2019 Oct;475(4):499-511. doi: 10.1007/s00428-019-02639-0. Epub 2019 Aug 16. PMID: 31420733.
3. Phillips JB, Billson VR, Forbes AB. Autopsy standards for fetal lengths and organ weights of an Australian perinatal population. Pathology. 2009;41(6):515-26. doi: 10.1080/00313020903041093. PMID: 19588281.
4. R Core Team (2022). R: A language and environment for statistical computing. R Foundation for Statistical Computing, Vienna, Austria.  URL https://www.R-project.org/.
5. Geffré A, Concordet D, Braun JP, Trumel C. Reference Value Advisor: a new freeware set of macroinstructions to calculate reference intervals with Microsoft Excel. Vet Clin Pathol. 2011 Mar;40(1):107-12. doi: 10.1111/j.1939-165X.2011.00287.x. Epub 2011 Feb 7. PMID: 21366659.
6. Sung CJ, Singer DB. Compiled 1st October 1988 with 1975–1984 data from Women and Infants' Hospital, Providence, Rhode Island. In: Stocker JT, Dehner LP, eds. Pediatric Pathology. Vol. 2. Philadelphia: Lippincott Williams & Wilkins, 2001;1436.
