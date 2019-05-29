### General
This subdirectory contains the matlab code for analysing meg data in the streams project. 

### Naming convention

* streams\__analysisstep_

   matlab functions taking (normally) subject MEG data as input and performing the _analysisstep_ via fieldtrip functions

* pipeline\__analysisstep_

   matlab scripts taking care of bookkeeping (paths, subject strings etc.) and running loops in which streams functions are called
