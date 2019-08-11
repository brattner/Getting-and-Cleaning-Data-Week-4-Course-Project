## 1. Merge the training and the test sets to create one data set.

# Load the packages dplyr and data.table (if not previously installed, you will need to install
# using install.package first)

library(data.table)
library(dplyr)

# Set the working directory

setwd("C:/Users/brattner/OneDrive - SAGE Publishing/Desktop/Barbara/Data Scientist Certificate - Coursera/Working Directory/data")

# Download data files, unzip files (record the date downladed)

url <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"

destFile <- "CourseDataset.zip"
if (!file.exists(destFile)){
  download.file(url, destfile = destFile, mode='wb')
}
if (!file.exists("./UCI HAR Dataset")){
  unzip(destFile)
}
dateDownloaded <- date()

# Read files

setwd("./UCI HAR Dataset")

# Read activity files from train and test forlder

ActivityTest <- read.table("./test/y_test.txt", header = F)
ActivityTrain <- read.table("./train/y_train.txt", header = F)

# Read features files from train and test folders

FeaturesTest <- read.table("./test/X_test.txt", header = F)
FeaturesTrain <- read.table("./train/X_train.txt", header = F)

# Read subject files from train and test forlder

SubjectTest <- read.table("./test/subject_test.txt", header = F)
SubjectTrain <- read.table("./train/subject_train.txt", header = F)

# Read activity Labels

ActivityLabels <- read.table("./activity_labels.txt", header = F)

# Read feature Names

FeaturesNames <- read.table("./features.txt", header = F)

# Merge activity, subject and feature data from Train and Test

FeaturesData <- rbind(FeaturesTest, FeaturesTrain)
SubjectData <- rbind(SubjectTest, SubjectTrain)
ActivityData <- rbind(ActivityTest, ActivityTrain)

# Rename columns in ActivityData and ActivityLabels

names(ActivityData) <- "ActivityN"
names(ActivityLabels) <- c("ActivityN", "Activity")

# Create a factor with Activity names 

Activity <- left_join(ActivityData, ActivityLabels, "ActivityN")[, 2]

# Rename SubjectData column

names(SubjectData) <- "Subject"

# Rename FeaturesData columns using columns from FeaturesNames

names(FeaturesData) <- FeaturesNames[,2]

# Create one Dataset with the variables SubjectData,  Activity,  and FeaturesData

DataSet <- cbind(SubjectData, Activity)
DataSet <- cbind(DataSet, FeaturesData)

## 2. Extract only the measurements on the mean and standard deviation (std) for each measurement.

# Extract the only measurements on the mean and std for each measurement and assign them 
# to new DataSet

subFeaturesNames <- FeaturesNames$V2[grep("mean\\(\\)|std\\(\\)", FeaturesNames$V2)]
DataNames <- c("Subject", "Activity", as.character(subFeaturesNames))
DataSet <- subset(DataSet, select=DataNames)

## 3. Use descriptive activity names to name the activities in the data set

##already done above


## 4. Label the data set with descriptive variable names

names(DataSet)<-gsub("^t", "time", names(DataSet))
names(DataSet)<-gsub("^f", "frequency", names(DataSet))
names(DataSet)<-gsub("Acc", "Accelerometer", names(DataSet))
names(DataSet)<-gsub("Gyro", "Gyroscope", names(DataSet))
names(DataSet)<-gsub("Mag", "Magnitude", names(DataSet))
names(DataSet)<-gsub("BodyBody", "Body", names(DataSet))

## 5. From the data set in step 4, create a second, independent tidy data set
##    with the average of each variable for each activity and each subject, and save it as a
##    local file

SecondDataSet<-aggregate(. ~Subject + Activity, DataSet, mean)
SecondDataSet<-SecondDataSet[order(SecondDataSet$Subject,SecondDataSet$Activity),]
write.table(SecondDataSet, file = "tidydata.txt", row.name = FALSE)