library(readr)
library(dplyr)

# Load training and test data
train_folder <- 'UCI HAR Dataset/train/'
train_X <- read_delim(paste0(train_folder, 'X_train.txt'), delim = ' ', col_names = FALSE)
train_y <- read_csv(paste0(train_folder, 'y_train.txt'), col_names = FALSE)

test_folder <- 'UCI HAR Dataset/test/'
test_X <- read_delim(paste0(test_folder, 'X_test.txt'), delim = ' ', col_names = FALSE)
test_y <- read_csv(paste0(test_folder, 'y_test.txt'), col_names = FALSE)

#Combine training and test data
X <- rbind(train_X, test_X)
y <- rbind(train_y, test_y)
X <- as.data.frame(apply(X,2, as.numeric))

#Extract only mean and std variables
features <- read_csv('UCI HAR Dataset/features.txt', col_names = FALSE)
mean_indices <- grepl('.*mean', features$X1)
std_indices <- grepl('.*std', features$X1)

mean_values <- X[, mean_indices]
std_values <- X[, std_indices]

mean_variable_names <- grep('.*mean', features$X1, value = TRUE)
mean_variable_names <- gsub('^[0-9]* ', '', mean_variable_names)

std_variable_names <- grep('.*std', features$X1, value = TRUE)
std_variable_names <- gsub('^[0-9]* ', '', std_variable_names)

#Convert activity labels from numbers to what they represent
y <- as.factor(y$X1)
levels(y) <- c('Walking', 'Walking Upstairs', 'Walking Downstairs', 'Sitting', 'Standing', 'Laying')

subject_test <- read_csv(paste0(test_folder, 'subject_test.txt'), col_names = FALSE)
subject_train <- read_csv(paste0(train_folder, 'subject_train.txt'), col_names = FALSE)
subject <- rbind(subject_train, subject_test)

#Combine all data into one tidy dataset
data_set <- cbind(mean_values, std_values, subject, y)
names(data_set) <- c(mean_variable_names, std_variable_names, 'Subject', 'Activity')

#Average variable values for each subject and activity
second_data_set <- data_set %>% group_by(Subject, Activity) %>% summarise(across(everything(), list(mean)))

#Create tidy datasets into csv files for further downstream analysis
write_csv(data_set, 'tidy1.csv')
write_csv(second_data_set, 'tidy2.csv')
