library(cyberframer)
library(dplyr)
library(stringr)

exp <- load_experiment("example-data/01_19-05-2025")
str(exp$data$experiment_log)
View(exp$data$experiment_log$data)

data <- exp$data$experiment_log$data

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
View(out)