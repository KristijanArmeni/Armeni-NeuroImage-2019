### ABOUT

This repository hosts the code that was used for analysis pipeline in the paper
_Frequency-specific brain dynamics related to prediction during language comprehension_
([https://doi.org/10.1016/j.neuroimage.2019.04.083](https://doi.org/10.1016/j.neuroimage.2019.04.083)).
The repository is a streamlined clone of the
[original repository (v1.0)](https://github.com/KristijanArmeni/dyncon_streams/releases/tag/v1.0)

### Directory structure

* [matlab](matlab) (meg analysis pipeline)
  * [external](matlab/external) (external code)
* [language](language) (for processing language stimuli used in the experiment)
* [ploting](ploting) (code for ploting the results)

### Toolboxes used

The pipeline relies on the following MATLAB toolboxes and software:

* [Fieldtrip][Fieldtrip] (for MEG data analysis)
* [Freesurfer][Freesurfer] (for cortical sheet reconstruction in source analysis)
* [FSL][FSL] (part of MRI image preprocessing in cortical sheet reconstruction)
* [Workbench][Workbench] (for a part of MRI preprocessing in cortical sheet reconstruction)

### Data availability

Data used in the project are available through [Donders repository](http://donders.data.ru.nl).
See [this link](http://www.ru.nl/donders/research/data/user-manual/access-shared-data)
for instructions on how to access the shared data.

### Licence

MIT License

Copyright (c) 2019 Kristijan Armeni

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.

[Fieldtrip]: http://fieldtriptoolbox.org
[Freesurfer]: https://surfer.nmr.mgh.harvard.edu
[FSL]: https://fsl.fmrib.ox.ac.uk/fsl/fslwiki
[Workbench]: http://www.humanconnectome.org/software/connectome-workbench
