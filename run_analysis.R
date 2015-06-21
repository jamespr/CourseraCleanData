# -----------------------------------------------------------------------------

# Fetch data

# Source data set
zippedSource = "getdata-projectfiles-UCI HAR Dataset.zip"

# Unpack files inside the zip into tables
activityLabels = read.table(unz(zippedSource, "UCI HAR Dataset/activity_labels.txt"))
features = read.table(unz(zippedSource, "UCI HAR Dataset/features.txt"))

trainSet = read.table(unz(zippedSource, "UCI HAR Dataset/train/X_train.txt"))
trainLabels = read.table(unz(zippedSource, "UCI HAR Dataset/train/y_train.txt"))
trainSubjects = read.table(unz(zippedSource, "UCI HAR Dataset/train/subject_train.txt"))

testSet = read.table(unz(zippedSource, "UCI HAR Dataset/test/X_test.txt"))
testLabels = read.table(unz(zippedSource, "UCI HAR Dataset/test/y_test.txt"))
testSubjects = read.table(unz(zippedSource, "UCI HAR Dataset/test/subject_test.txt"))

# -----------------------------------------------------------------------------

# Build tables

# Merge the training and test tables together into a master table (STEP 1)
masterTable <- rbind(trainSet, testSet)

# Set the column names feature variable names (STEP 4)
names(masterTable) <- features[,2]

# Take only the variables labelled with "-std()" and "-mean()" (STEP 2)
masterTable <- masterTable[, grep(".*-(std\\(\\)|mean\\(\\))", names(masterTable))]

# Sanitize variable names
# First remove any non-characters at the end of the name
names(masterTable) <- gsub("\\W+$", "", names(masterTable))

# Then replace any leftover non-characters with underscores
names(masterTable) <- gsub("\\W+", "_", names(masterTable))

# Add in the activity labels (STEP 3)
label_raw <- rbind(trainLabels, testLabels)
masterTable$Activity <- activityLabels[label_raw[,1],2]

# Add in the subject numbers
masterTable$Subject <- rbind(trainSubjects, testSubjects)[[1]]

# Aggregate into a new table the average of all variables by Subject and Activity (Step 5)
avgBySubjectActivity <- aggregate(
  masterTable[1:66],
  by=list(Subject = masterTable$Subject, Activity = masterTable$Activity), 
  FUN=mean
)

# Write out the tidy dataset
write.table(avgBySubjectActivity, "tidyData.txt", row.name=FALSE)
