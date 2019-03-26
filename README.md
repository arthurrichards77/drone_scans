# drone_scans
Matlab code for designing flight paths for UAVs scanning fields in wind.

# Publication
Results and method are described in "Flight Optimization for an Agricultural Unmanned Air Vehicle" by A. Richards, European Control Conference, 2018, available at: https://ieeexplore.ieee.org/document/8550307

# About the Code
Each of the scripts "comp...m" runs a sweep of different flight angles for a particular field and wind.  For each angle, the function "tspSequence" will divide the field polygon into strips, cutting along the current angle choice, and then find the optimal sequence with with to fly every strip.

The travelling salesman solver uses the free [GLPSOL](https://en.wikibooks.org/wiki/GLPK/Using_GLPSOL) utility, either in Linux or via [Cygwin](https://www.cygwin.com/) on Windows.  The rest of the code runs in Matlab, so the whole package can run on Windows or Linux.

By far the slowest bit of the method is the calculation of the fastest flights paths between all pairs of strips, which uses a Dubins-like method with corrections for wind, by [Mcgee, Spry and Hedrick](https://arc.aiaa.org/doi/10.2514/6.2005-6186).  To speed things up, this has been compiled to a MEX file in Matlab.  Cross-platform users will have to run the code generation script to compile it for their OS etc.

## Dependencies
* Matlab
* GLPSOL (part of the GLPK suite)

## Source subdirectories:
* ampltools: utilities for writing the datafiles for the TSP, which share their format with the [AMPL](https://ampl.com/) language
* heading: functions to determine aircraft heading to fly a given ground track in wind, plus determine the ground speed
* sim: a simple simulator for validation, implemented in Simulink
* strips: robust code for dividing a polygon into strips, which was surprisingly hard!
* tsp: the AMPL/GLPSOL model file (.mod) and other files should you want to run it in AMPL
* windpath: determination of fastest path between two poses in wind.  Run "codegenWindPath" to compile the MEX.
