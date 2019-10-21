#run_analysis.R
#Taahir Hoosen
#Getting and Cleaning Data - Week 4 Project
# October 2019

#Load necessary packages
library(data.table)
library(dplyr)

#Set your working directory
setwd("C:/Users/taahirh/Documents/Taahir Hoosen/Data Science Course/03. Getting and Cleaning Data/Week 4 Project")

#Connecting to URL
URL <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
downloadFile <- "CourseDataset.zip"

#Creating function to download files
if (!file.exists(downloadFile)){
  download.file(URL, downloadFile = downloadFile, mode='wb')
}

#Unzip all files
if (!file.exists("./UCI_HAR_Dataset")){
  unzip(downloadFile)
}
#specify time/date settings
dateDownloaded <- date()

#Start reading files
#setwd("./UCI_HAR_Dataset")

#Read Activity files
ActivityTest <- read.table("./test/y_test.txt", header = F)
ActivityTrain <- read.table("./train/y_train.txt", header = F)

#Read features files
FeaturesTest <- read.table("./test/X_test.txt", header = F)
FeaturesTrain <- read.table("./train/X_train.txt", header = F)

#Read subject files
SubjectTest <- read.table("./test/subject_test.txt", header = F)
SubjectTrain <- read.table("./train/subject_train.txt", header = F)

#Read Activity Labels
ActivityLabels <- read.table("./activity_labels.txt", header = F)

#Read Feature Names
FeaturesNames <- read.table("./features.txt", header = F)

#Merg dataframes: Features Test&Train,Activity Test&Train, Subject Test&Train
FeaturesData <- rbind(FeaturesTest, FeaturesTrain)
SubjectData <- rbind(SubjectTest, SubjectTrain)
ActivityData <- rbind(ActivityTest, ActivityTrain)

#Renaming colums in ActivityData & ActivityLabels dataframes
names(ActivityData) <- "ActivityN"
names(ActivityLabels) <- c("ActivityN", "Activity")

#Get factor of Activity names
Activity <- left_join(ActivityData, ActivityLabels, "ActivityN")[, 2]

#Rename SubjectData columns
names(SubjectData) <- "Subject"
#Rename FeaturesData columns using columns from FeaturesNames
names(FeaturesData) <- FeaturesNames$V2

#Create one large Dataset with only these variables: SubjectData,  Activity,  FeaturesData
OuputDataSet <- cbind(SubjectData, Activity)
OuputDataSet <- cbind(OuputDataSet, FeaturesData)

#Create New datasets by extracting only the measurements on the mean and standard deviation for each measurement
subFeaturesNames <- FeaturesNames$V2[grep("mean\\(\\)|std\\(\\)", FeaturesNames$V2)]
DataNames <- c("Subject", "Activity", as.character(subFeaturesNames))
DataSet <- subset(OuputDataSet, select=DataNames)

#Rename the columns of the large dataset using more descriptive activity names
names(OuputDataSet)<-gsub("^t", "time", names(OuputDataSet))
names(OuputDataSet)<-gsub("^f", "frequency", names(OuputDataSet))
names(OuputDataSet)<-gsub("Acc", "Accelerometer", names(OuputDataSet))
names(OuputDataSet)<-gsub("Gyro", "Gyroscope", names(OuputDataSet))
names(OuputDataSet)<-gsub("Mag", "Magnitude", names(OuputDataSet))
names(OuputDataSet)<-gsub("BodyBody", "Body", names(OuputDataSet))

#Create a second, independent tidy data set with the average of each variable for each activity and each subject
SecondOutputDataSet<-aggregate(. ~Subject + Activity, OuputDataSet, mean)
SecondOutputDataSet<-SecondOutputDataSet[order(SecondOutputDataSet$Subject,SecondOutputDataSet$Activity),]

#Save this tidy dataset to local file
write.table(SecondOutputDataSet, file = "tidydata.txt",row.name=FALSE)
