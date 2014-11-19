coursera-R-getdata
==================

## Intro

This is about the project as discribed on 
https://class.coursera.org/getdata-009/human_grading/index

## About the project

The project is about doing this:

You should create one R script called run_analysis.R that does the following. 

1. Merges the training and the test sets to create one data set.
2. Extracts only the measurements on the mean and standard deviation for each measurement. 
3. Uses descriptive activity names to name the activities in the data set
4. Appropriately labels the data set with descriptive variable names. 
   From the data set in step 4, creates a second, independent tidy data set with the average of each variable for each activity and each subject.

The data for this project contains both processed and preprocessed data (in subdirectory "Inertial Signals").
The project description was not clear about which 
data to use and merging both data sets did not make any sense to me. So I assumed only the processed data
needs to be considered.

As often, there are several ways to solve the project.
I choosed to use data.table, because I have seen
amazing improvements when large datasets are used. Basically it
made certain operations possible in less than a minute, while the computer was slowly dieing when 
data frames were used. Although the datasets in the project are small, I prefer to use data.table, because I
I think it is very useful to get more experience with this package. On the way I found a bug and filed
a [bug report]: https://github.com/Rdatatable/data.table/issues/956 (bug report fread)

When both packages dplyr and data.table are loaded,
several warnings are thrown about functions of one packages being hidden by the other. To avoid confusing 
situations with that, I choosed not to load dplyr and to do everything the data.table way. So here I
use `data.table.subset()` instead of `dplyr::select`.

To show which part of the code deals with which part of the project description, you can search for
'project', e.g. 

     # (**part 4 of the project)

For memory usage reasons I choosed to read and proces/reduce data per data set (test/train). So there is no
moment all the data is loaded.

## Usage

The script is named `run_analysis.R` and needs data 
which can be downloaded [here]: https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip
Extract this zip-file in the directory of the script.

The script needs to be started from the directory where it can be found. 
(I use `./run_analysis.R` on my Linux box, but I am sure you know how to start an R-script)
The script can be started without parameters. The output can be found in file `project-result.txt` in the current working directory.

The script will check if the top level directory of the data is there and if so it will go on.

The source code is pretty verbose (many commands in the source code), so I suppose it will be clear.


## Code book

    `NR` - number of rows to read from data file. Use "-1" to read all rows.
    `act_labels` - table with columns `activity_id` and `activity` which maps numbers to descriptions.
    `features` - contents of features.txt, columns "V2" contains the descriptive labels.
    `data` - local variable used in function read_data() for holding the data of a given data set (test or train)
    `all_data` - data of both train and test data (already subsetted according to step 2 of the project).
    `data_per_act` - this is `all_data` grouped by `activity`, holding the mean() values of all columns.
    `fn` - the name of the output file
