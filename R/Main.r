# Set the repository options to CRAN (Comprehensive R Archive Network) for package installation
options(repos = c(CRAN = "https://cloud.r-project.org"))

# List of packages to install and load
packages <- c("data.table", "dplyr", "shiny", "shinythemes", "memoise","cachem", "bslib")

# Directory where packages are stored
library_directory <- "R_Resources"

# Ensure the directory exists, if not, create it
if (!dir.exists(library_directory)) {
  dir.create(library_directory)
}

# Function to install and load packages if missing
invisible({
  packages_to_install <- packages[!packages %in% list.files(path = library_directory)]
  if (length(packages_to_install) > 0) {
    install.packages(packages_to_install, lib = library_directory)
  }
  lapply(packages, function(p) suppressPackageStartupMessages(library(p, lib.loc = library_directory, character.only = TRUE)))
})

# Read user play data and song data
file_paths <- c("10000.txt", "song_data.csv")
data <- lapply(file_paths, fread, na.strings = "")

# Rename columns in 1000.txt
names(data[[1]]) <- c('user_id', 'song_id', 'num_plays')

# Remove duplicates in song_data.csv
song_data <- unique(data[[2]], by = "song_id")

# Condense play data by grouping it based on user ID and song ID, calculating the total number of plays for each unique user-song combination.
play_summary <- data[[1]][, .(plays = sum(num_plays, na.rm = TRUE)), by = .(user_id, song_id)]

# Join summarized play data with song data
all_data <- merge(play_summary, song_data, by = "song_id")

# Organize data for the top 1000 songs by calculating the total number of plays associated with each song
top_1k_songs <- all_data[, .(sum_plays = sum(plays)), by = .(song_id, title, artist_name)][order(-sum_plays)][1:1000]

# Combine all_data with top_1k_songs to ensure we have all relevant songs
merged_data <- unique(merge(all_data, top_1k_songs, by = "song_id"))

# Convert to a wide format with users as rows and songs as columns
wide_data <- dcast(merged_data, user_id ~ song_id, value.var = "plays", fill = 0)

# Extract the ratings from wide_data and convert to a matrix
ratings <- as.matrix(wide_data[, -1])

# Calculate norms to measure the 'size' of each song's play count vector
# This helps to ensure all songs are measured on the same scale for comparison
norms <- sqrt(colSums(ratings^2))

# Function to calculate cosine similarity
calc_cos_sim <- function(song_title, artist_name, return_n = 5) {
  # Get the song code from the title and artist name
  song_code <- unique(all_data$song_id[all_data$title == song_title & all_data$artist_name == artist_name])
  if (length(song_code) == 0) {
     return(data.frame(notification = "Sorry, but the song you requested is not available in our dataset"))
  }

  # Find the column index corresponding to the song
  song_col_index <- match(song_code, colnames(ratings))
  song_col <- ratings[, song_col_index]

  # Compute dot products of the given song with all other songs
  dot_products <- colSums(ratings * song_col)

  # Calculate cosine similarities using dot products and norms
  cos_sims <- dot_products / (norms * norms[song_col_index])

  # Convert similarity values to percentages
  cos_sims_percent <- round(cos_sims * 100)

  # Create a dataframe to store song similarities
  result_df <- data.frame(song_id = colnames(ratings), similarity = cos_sims_percent, stringsAsFactors = FALSE)

  # Exclude the given song from the result
  result_df <- result_df[result_df$song_id != song_code, , drop = FALSE]

  # Merge with top 1k songs and order by similarity
  result_df <- merge(result_df, top_1k_songs, by = "song_id")[order(-result_df$similarity), ][1:return_n, ]

  # Select relevant columns and return the result
  result_df <- result_df[, c("title", "artist_name", "similarity")]
  return(result_df)
}

shiny::runApp("app.r")

# Use below for debugging
# song_title <- "21 Guns [feat. Green Day & The Cast Of American Idiot] (Album Version)"
# artist_name <- "Green Day"
# cat(sprintf("\nHere are some similar songs to '%s' by '%s':\n", song_title, artist_name))
# knitr::kable(calc_cos_sim(song_title, artist_name))
# write.csv(top_1k_songs, "top_1000_songs.csv", row.names = FALSE)