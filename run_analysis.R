#Read in all the relevant tables 
Xtest <- read.table("./UCI HAR Dataset/test/X_test.txt")
Xtrain <- read.table("./UCI HAR Dataset/train/X_train.txt")
ytest <- read.table("./UCI HAR Dataset/test/y_test.txt")
ytrain <- read.table("./UCI HAR Dataset/train/y_train.txt")
subjecttest <- read.table("./UCI HAR Dataset/test/subject_test.txt")
subjecttrain <- read.table("./UCI HAR Dataset/train/subject_train.txt")
features <- read.table("./UCI HAR Dataset/features.txt")

#Merge the data frames with the 561 feature variables for test and train sets
Xtesttrain <- rbind(Xtest,Xtrain)

#Merge the data frames containing subject labels for test and train sets
subjecttesttrain <- rbind(subjecttest,subjecttrain)

#Merge the data frames containing activity info for test and train sets
activitytesttrain <- rbind(ytest,ytrain)

#Add subject and activity info to the data set with 561 feature variables
Xtesttrain <- cbind(subjecttesttrain,activitytesttrain,Xtesttrain)

#Keep only the columns that contain mean or standard deviation info
#Keep first 2 columns because of the merging above
Xtesttrain <- Xtesttrain[,c(1,2,grep("mean|std",features[,2])+2)]


#Replace activity labels with descriptive labels
Xtesttrain[,2] <- sub("1","WALKING",Xtesttrain[,2])
Xtesttrain[,2] <- sub("2","WALKING_UPSTAIRS",Xtesttrain[,2])
Xtesttrain[,2] <- sub("3","WALKING_DOWNSTAIRS",Xtesttrain[,2])
Xtesttrain[,2] <- sub("4","SITTING",Xtesttrain[,2])
Xtesttrain[,2] <- sub("5","STANDING",Xtesttrain[,2])
Xtesttrain[,2] <- sub("6","LAYING",Xtesttrain[,2])

#Label the columns in this data set according to their names in the features data frame
names(Xtesttrain) <- c("Subject label","Activity",as.character(features[grep("mean|std",features[,2]),2]))

#Sort the rows by subject label
Xtesttrain <- Xtesttrain[order(Xtesttrain$`Subject label`),]

#Create new data set with averages for each subject and each activity (30 subjects x 6 activities = 180 rows)
condensedData <- matrix(0, nrow = 180, ncol = 81)
condensedData <- data.frame(condensedData)
names(condensedData) <- names(Xtesttrain)

actlabels <- c("STANDING","SITTING","LAYING","WALKING","WALKING_DOWNSTAIRS","WALKING_UPSTAIRS")

for (i in 1:30) {
        count <- 6*(i-1)
        for (j in 1:6) {
                #subset of measurements for subject i, activity j
                subset <- Xtesttrain[Xtesttrain[,1] == i & Xtesttrain[,2] == actlabels[j],3:81]
                condensedData[count+j,1] <- i
                condensedData[count+j,2] <- actlabels[j]
                condensedData[count+j,3:81] <- colMeans(subset)
        }
}