Authors: Michael Olacsi

This is a user-friendly music recommendation system developed in R, designed to simplify music discovery. 
With its Graphical User Interface (GUI), Spot-R-fi offers easy accessibility without intrusive advertisements commonly 
found in other recommendation systems.

## Installation and Usage:

### Installing R:
   - sudo apt install r-base-core
   - R can also be installed from source. [Official site](https://www.r-project.org/)

### Installing and loading the necessary packages:
   - To install packages, you would generally run install.packages(package_name).
   - To load them you would then use library(package_name)
   - However, in the code I provided a script to automatically download and load the needed packages. 
     In a R_Resources directory that it creates.

###  Downloading the song data:
   - The dataset below contains 10,000 songs, which is a subset of the larger million song dataset.
     The entire dataset (300 GB) is available elsewhere, such as AWS.
   - To download the needed data, you will need to create an account with Kaggle
   - [User Data](https://www.kaggle.com/datasets/anuragbanerjee/million-song-data-set-subset?select=10000.txt)
   - [Song Data](https://www.kaggle.com/datasets/anuragbanerjee/million-song-data-set-subset?select=song_data.csv)
   - Unzip the files, and name them: `song_data.csv` and `10000.txt` respective to their file types. 
     Then add them to the R directory.

   - If desired, the code can be modified to work with the million song datasets. To do so, you will need to
     download and extract the data of the million song datasets, then place it in the R directory.
     It will also be necessary to edit main.r by changing the referenced csv and txt files (song_data.csv and 10000.txt).
     Further modifications of the code would likely also be necessary.

## Running the program:
   To run the program use:

```
Rscript Main.r
```
    
