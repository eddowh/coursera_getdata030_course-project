# check if data directory exists, if not download file and unzip
if(!file.exists("./UCI HAR Dataset")){
    download.file("https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip",
                  destfile = "./UCI HAR Dataset.zip")
    unzip("UCI HAR Dataset.zip")
}

# load in the test and train subject and activity label datasets
testSubject <- read.table("./UCI HAR Dataset/test/subject_test.txt",
                          col.names = "subject")
trainSubject <- read.table("./UCI HAR Dataset/train/subject_train.txt",
                           col.names = "subject")
testActivity <- read.table("./UCI HAR Dataset/test/y_test.txt",
                           col.names = "activity")
trainActivity <- read.table("./UCI HAR Dataset/train/y_train.txt",
                            col.names = "activity")

# loading ctivity labels 
actLabel <- read.table("./UCI HAR Dataset/activity_labels.txt", 
                       col.names = c("activityNumber", "activity"))

# loading feature/variable names
colName <- read.table("./UCI HAR Dataset/features.txt",
                      check.names = FALSE)

# loading train dataset
# define column classes as numeric, assigning them as the rows read from 'features.txt'
train <- read.table("./UCI HAR Dataset/train/X_train.txt",
                    colClasses = rep("numeric", 561),
                    col.names = colName[[2]], check.names = FALSE)

# loading test dataset
test <- read.table("./UCI HAR Dataset/test/X_test.txt",
                   colClasses = rep("numeric", 561),
                   col.names = colName[[2]], check.names = FALSE)

# put train and test subject data as a column, activity data as a column, and combine them
subAndAct <- cbind(rbind(trainSubject, testSubject), # combine column for subject number
                   rbind(trainActivity, testActivity))   # combine column for activity

# replace activity column with corresponding text labels from the activity label dataframe
subAndAct$activity <- actLabel[match(subAndAct$activity, actLabel$activityNumber),
                               "activity"]

# find all column/variable that contain "mean" or "std"
meanAndStd <- grep("mean|std", colName[[2]])

# combine train/test datasets, subset to mean/std variables, combine w/ subject/activity columns
allData <- cbind(subAndAct, 
                 rbind(train, test)[,meanAndStd]) # select columns with filters of only "mean" or "std" 

# get names of all variables 
varName <- names(allData)

# abbreviated strings in varName
vague <- c("^f",
          "^t",
          "Acc",
          "-mean\\(\\)",
          "-meanFreq\\(\\)",
          "-std\\(\\)",
          "Gyro",
          "Mag",
          "BodyBody")

# corrected strings (using descriptive activity names)
descriptive <- c("freq",
               "time",
               "Acceleration",
               "Mean",
               "MeanFrequency",
               "Std",
               "Gyroscope",
               "Magnitude", 
               "Body")

# replace each vague abbreviated string with the corrected descriptive one
for(i in seq_along(vague)){
    varName <- sub(vague[i], descriptive[i], varName)
}

# replace column names of allData with corrected descriptions
names(allData) <- varName

# create independent data set with average for each variable/activity/subject
newData <- aggregate(allData[, 3:length(allData)],  # every column except subject and activity name
                     list(subject = allData$subject, activity = allData$activity), 
                     mean)

# write newData to output file
write.table(newData, file = "UCI HAR Tidy Averages DataSet.txt", row.name = FALSE)

## if one wants to read the newData output file, uncomment code below
## (read.table("UCI HAR Tidy Averages DataSet.txt", header = TRUE)
## 'header = TRUE' is to ensure the column names are read instead of "V1, V2, V3 ... "