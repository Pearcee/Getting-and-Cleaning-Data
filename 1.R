## You should create one R script called run_analysis.R that does the following. 
##1.Merges the training and the test sets to create one data set.
##2.Extracts only the measurements on the mean and standard deviation for each measurement. 
##3.Uses descriptive activity names to name the activities in the data set
##4.Appropriately labels the data set with descriptive variable names. 
##5.From the data set in step 4, creates a second, independent tidy data set with the average of each variable for each activity and each subject.

## Good luck!

##1.Merges the training and the test sets to create one data set.

# Download the file.
if(!file.exists("./data")){dir.create("./data")}
fileName = "./data/Dataset.zip" 
fileUrl <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
download.file(fileUrl,destfile=fileName) # method="curl") # curl does not work in windows so deletr ) #to run else where

# Unzip the file.
unzip(zipfile=fileName,exdir="./data")

# Get the list of the files in the folder 'UCI HAR Dataset'. 
pathUCI <- file.path("./data" , "UCI HAR Dataset")
files<-list.files(pathUCI, recursive=TRUE)
files

# Read data from the files.
dataActivityTest  <- read.table(file.path(pathUCI, "test" , "Y_test.txt" ),header = FALSE)
dataActivityTrain <- read.table(file.path(pathUCI, "train", "Y_train.txt"),header = FALSE)

# Read the Subject files.
dataSubjectTrain <- read.table(file.path(pathUCI, "train", "subject_train.txt"),header = FALSE)
dataSubjectTest  <- read.table(file.path(pathUCI, "test" , "subject_test.txt"),header = FALSE)

# Read Features files
dataFeaturesTest  <- read.table(file.path(pathUCI, "test" , "X_test.txt" ),header = FALSE)
dataFeaturesTrain <- read.table(file.path(pathUCI, "train", "X_train.txt"),header = FALSE)

# Look at the properties of the above varibles
str(dataActivityTest)
str(dataActivityTrain)
str(dataSubjectTrain)
str(dataSubjectTest)
str(dataFeaturesTest)
str(dataFeaturesTrain)

# Merges the training and the test sets to create one data set
# Concatenate the data tables by rows
dataSubject <- rbind(dataSubjectTrain, dataSubjectTest)
dataActivity<- rbind(dataActivityTrain, dataActivityTest)
dataFeatures<- rbind(dataFeaturesTrain, dataFeaturesTest)

# set names to variables
names(dataSubject)<-c("subject")
names(dataActivity)<- c("activity")
dataFeaturesNames <- read.table(file.path(pathUCI, "features.txt"),head=FALSE)
names(dataFeatures)<- dataFeaturesNames$V2

# Merge columns to get the data frame Data for all data
dataCombine <- cbind(dataSubject, dataActivity)
Data <- cbind(dataFeatures, dataCombine)

##2.Extracts only the measurements on the mean and standard deviation for each measurement. 

# Subset Name of Features by measurements on the mean and standard deviation
subdataFeaturesNames<-dataFeaturesNames$V2[grep("mean\\(\\)|std\\(\\)", dataFeaturesNames$V2)]

# Subset the data frame Data by seleted names of Features
selectedNames<-c(as.character(subdataFeaturesNames), "subject", "activity" )
Data<-subset(Data,select=selectedNames)

# Check the structures of the data frame Data
str(Data)

##3.Uses descriptive activity names to name the activities in the data set

# Read descriptive activity names from “activity_labels.txt”
activityLabels <- read.table(file.path(pathUCI, "activity_labels.txt"),header = FALSE)

# facorize Variale activity in the data frame Data using descriptive activity names
head(Data$activity,30)

##4.Appropriately labels the data set with descriptive variable names. 
names(Data)<-gsub("^t", "time", names(Data))
names(Data)<-gsub("^f", "frequency", names(Data))
names(Data)<-gsub("Acc", "Accelerometer", names(Data))
names(Data)<-gsub("Gyro", "Gyroscope", names(Data))
names(Data)<-gsub("Mag", "Magnitude", names(Data))
names(Data)<-gsub("BodyBody", "Body", names(Data))

names(Data)


##5.From the data set in step 4, creates a second, independent tidy data set with the average of each variable for each activity and each subject.

library(plyr);
Data2<-aggregate(. ~subject + activity, Data, mean)
Data2<-Data2[order(Data2$subject,Data2$activity),]
write.table(Data2, file = "tidydata.txt",row.name=FALSE)
write.csv(Data2, file = "tidydata.csv")

# Prouduce Codebook

library(knitr)
knit2html("codebook.Rmd");
