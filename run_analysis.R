## Creating directory.
if(!file.exists("Course3")){
  dir.create("Course3")
}

setwd("Course3")

## Downloading data.
if(!file.exists("project3.zip")){
  url = "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
  download.file(url, "project3.zip")
  unzip("project3.zip")
  setwd("UCI HAR Dataset")
}

library(data.table)
library(dplyr)

## 1.Merges the training and test sets to create one data set.
## a) creating required objects:
features = fread("features.txt", col.names = c("Observation", "Variables"))
xtrain = fread("train/X_train.txt", col.names = features$Variables)
xtest = fread("test/X_test.txt", col.names = features$Variables)
subjectTrain = fread("train/subject_train.txt", col.names= "Subject")

activity = fread("activity_labels.txt", col.names =c("Id", "Activity"))
ytrain = fread("train/y_train.txt", col.names = "Activity")
ytest = fread("test/y_test.txt", col.names = "Activity")
subjectTest = fread("test/subject_test.txt", col.names = "Subject")

## b) Merging datasets:
Subjects = rbind(subjectTrain, subjectTest)
Xdata = rbind(xtrain, xtest)
Ydata = rbind(ytrain, ytest)

## Single final dataset:
dataMerged = cbind(Subjects, Ydata, Xdata)

## 2) Extracts only the measurements on the mean and standard deviation for each measurement.
## a) Creating a character vector with all column names of interest:
featuresCHA = as.character(features$Variables)
vectorCol = featuresCHA[grep("mean\\(\\)|std\\(\\)", featuresCHA)]
vectorCol = c("Subject", "Activity", vectorCol)

## b) Subsetting on vectorCol
mean_std_subset = subset(dataMerged, select = vectorCol)

## 3) Uses descriptive activity names to name the activities in the data set.
## a) Substituting activities "Id´s" by the labels named in "activity_labels.txt"
mean_std_subset$Activity = activity[mean_std_subset$Activity, 2]
## use str(mean_std_subset) to check whether "Activity" column is populated with label.

## 4) Appropriately labels the data set with descriptive variable names.
## a) Apply "gsub" function to localize and substitute unclear strings to 
## improve data readability.
names(mean_std_subset) = gsub("^t", "Time", names(mean_std_subset))
names(mean_std_subset) = gsub("^f", "Frequency", names(mean_std_subset))
names(mean_std_subset) = gsub("gravity", "Gravity", names(mean_std_subset))
names(mean_std_subset) = gsub("mean", "Mean", names(mean_std_subset))
names(mean_std_subset) = gsub("std", "Std", names(mean_std_subset))
names(mean_std_subset) = gsub("[Aa]cc", "Accelerometer", names(mean_std_subset))
names(mean_std_subset) = gsub("[Gg]yro", "Gyroscope", names(mean_std_subset))
names(mean_std_subset) = gsub("[Bb]ody[Bb]ody", "Body", names(mean_std_subset))
names(mean_std_subset) = gsub("^[Aa]nglet", "AngleTime", names(mean_std_subset))
names(mean_std_subset) = gsub("[Mm]ag", "Magnitude", names(mean_std_subset))

## 5) From the data set in step 4, creates a second, independent tidy data set. 
## with the average of each variable for each activity and each subject.
## a) Group the dataset by "Activity" and "Subject" and assign it to a new object. 
GroupedData = group_by(mean_std_subset, Subject, Activity)

## b) Apply "summarize_all" to calculate the mean value of each variable for each group.
GroupedData = summarise_all(GroupedData, funs(mean))

## str(GroupedData) to check.

## Create new table for GroupedData
write.table(GroupedData, "GroupedData.txt", row.names = FALSE)


