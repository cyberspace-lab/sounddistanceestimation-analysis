library(cyberframer)
library(dplyr)
library(stringr)

exp <- load_experiment("example-data/01_19-05-2025")
exp <- load_experiment("data/01_19-05-2025")

dirs <- list.dirs("data/", full.names = TRUE, recursive = FALSE)
View(exp$data$experiment_log$data)

extract_trial_data <- function(data) {
  out <- data %>%
    filter(Sender == "Trial",
           Type == "Event",
           grepl("PositionConfirmed", Event)) %>%
    pull(Event) %>%
    lapply(., function(x) {
      parsed <- unlist(jsonlite::fromJSON(x))
      # Convert to data frame with one row
      as.data.frame(t(parsed), stringsAsFactors = FALSE)
    }) %>%
    bind_rows()
  return(out)
}
out <- extract_trial_data(exp$data$experiment_log$data)
View(out)


## Multiple files

exps <- list()
for (dir in dirs) {
  if (dir != "." && dir != "..") {
    print(dir)
    exp <- load_experiment(dir)
    exps[[dir]] <- exp
  }
}

df_trials <- data.frame()
for (i in seq_along(exps)) {
  exp <- exps[[i]]
  trial_data <- extract_trial_data(exp$data$experiment_log$data)
  trial_data$participant_id <- exp$participant_id
  trial_data$Timestamp <- exp$timestamp
  df_trials <- bind_rows(df_trials, trial_data)
}
str(df_trials)
View(df_trials)

write_csv(df_trials, "data/all_trial_data.csv")
