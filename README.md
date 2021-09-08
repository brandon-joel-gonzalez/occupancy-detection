# occupancy-detection
Code repository for master's thesis - hybrid sensor system for human occupancy detection

A combination of C++ and MATLAB code was used for this project.

The C++ directory holds the main file, grideye-PIR.ino, that was run on the ATmega328p. The folder marked "miscellaneous" contains files which were used in the development process.

The MATLAB directory contains three subdirectories.
"camera" contains the code that was used to test the camera baseline. There are also subdirectories which hold the data and photos collected for testing and analysis.
"hybrid" contains the code that was used to test the hybrid sensor system. There are also subdirectories which hold the data and photos collected for testing and analysis.
"miscellaneous" contains files which were used in the development process.

There is also a Python directory, which contains code that was considered but ultimately not used for this project. The project was done entirely in C++ and MATLAB, but could have been implemented in Python. (In fact, it might be cleaner to implement both the C++ and MATLAB code in Python on a Raspberry Pi. This system would be capable of both reading and processing data on a single platform.)

Here is a [link](https://drive.google.com/file/d/1XuO7aYj0PdFYrlUzApT3siJoRKO-D-IN/view) to the presentation of my thesis from May 2021.
