#!/usr/bin/Rscript

library(data.table)

# N.B. corrected version after I found out I missed the fact that results
# needed to be grouped on both activity AND SUBJECT.

# You should create one R script called run_analysis.R that does the following. 
# 1. Merges the training and the test sets to create one data set.
# 2. Extracts only the measurements on the mean and standard deviation for
#    each measurement. 
# 3. Uses descriptive activity names to name the activities in the data set
# 4. Appropriately labels the data set with descriptive variable names. 
# 5. From the data set in step 4, creates a second, independent tidy data set
#    with the average of each variable for each activity and each subject.
# In the code is referred to the above with "(**part <number> of this project)"

# In this exercise I use data.table, because I love it! Why? It is very
# memory efficient and the possibility to index columns (using setkey())
# makes joining and grouping data very fast. It is a game changer for large
# data sets. On top of that is has handy features for different kind of
# operations, which are also memory efficient..
# It makes certain operations possible that are not possible with alternatives.

# For developing and testing, we don't want to read and use all rows.
# Use NR to limit the amount rows.  Change the value to -1 if you want
# to read all rows
NR  <- -1
dir <- 'UCI HAR Dataset/'

if (!file.exists(dir)) {
    stop(paste("missing directory", dir,
               "make sure the data is in the current working directory"))
}
# First read data that applies to both test and train data

# activity labels
act_labels <- fread(paste(dir, 'activity_labels.txt', sep=''),
                    stringsAsFactor = TRUE, header = FALSE)
setnames(act_labels, c("activity_id", "activity"))
setkey(act_labels, activity_id)

# features
features <- fread(paste(dir, 'features.txt', sep=''),
                  stringsAsFactor = TRUE, header = FALSE)

# this function reads the data for a given type (test or train)
read_data <- function (type = 'test') {
    file_data     = paste0(dir, type, '/X_', type, '.txt')
    file_activity = paste0(dir, type, '/y_', type, '.txt')
    file_subject  = paste0(dir, type, '/subject_', type, '.txt')

    # Unfortunately there is a bug in fread() of the data.table package
    # (version 1.9.4). This leads to a fatal error (buffer overflow:
    #     data <- fread(input = file_data, header = FALSE)
    # Bug report: https://github.com/Rdatatable/data.table/issues/956
    # So for now we use read.table and convert it to data.table format:
    data <- as.data.table(read.table(file_data, header=FALSE, nrows=NR))

    # Give useful names to the columns
    # (**part 4 of the project)
    setnames(data, features$V2);

    # We could use the select() function of the dplyr package like this:
    #   data <- select(data, contains('mean'), contains('std'))
    # But since data.table has the subset() function as alternative,
    # we don't need to load the dplyr package.
    # (**part 2 of the project)
    data <- subset(data, select = grep('-mean|-std', names(data)))

    # add activity as column to data (the name of the activity, not the id).
    # (**part 3. of the project)
    activity = fread(file_activity, header = FALSE, nrows=NR)
    setnames(activity, 1, 'activity_id')

    # because we need to preserve order, and setkey() changes the order, we need
    # to add activity_id to the data table before calling setkey()
    data[ , activity_id := activity$activity_id ] 

    # same thing for subject_id
    subject = fread(file_subject, header = FALSE, nrows=NR)
    setnames(subject, 1, 'subject_id')
    data[ , subject_id := subject$subject_id ]

    # now we can put an index on activity_id add the descriptive column
    # in an fast and efficient way
    setkey(data, activity_id)
    data <- merge(data, act_labels)
    data[,activity_id := NULL]     # drop the label id

    data    # return the data
}

# merge the test and train data
# (**part 1. of the project)
all_data <- rbindlist(
    list(
        read_data(type='test'),
        read_data(type='train')
    ),
    use.names=FALSE, fill = FALSE
)

# group by activity
# (**part 5 of the project)
setkey(all_data, activity, subject_id)
data_per_act <- all_data[, lapply(.SD, mean), by = "activity,subject_id"]

# and export the file as requested
fn <- "project-result.txt"
write.table(data_per_act, row.names = FALSE, file=fn)
cat(paste("data exported to file", fn, "\n")) 
