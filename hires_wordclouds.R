library(tidyverse)
library(tidytext)
library(dplyr)
library(nflscrapR)
library(stringr)
library(wordcloud2)
library(htmlwidgets)
library(webshot)
library(kableExtra)

# Theme for plots
source("theme_pff.R")

set.seed(42)

# Import stop words to exclude in the word clouds (the, to, but, etc.)
data("stop_words")
# List of common words to drop from the word clouds
drop_words = c("coach", "browns", "nfl", "hire", "https", "cleveland",
               "game", "games", "season", "play", "head", "guy", "team", "time",
               "fans", "fan", "lot", "gonna", "guys", "yeah", "people",
               "freddie", "kitchens", "kitchen", "kevin",
               "stefanski", "vikings", "minnesota", "brownies", "top")

# Load in comment data (originally gathered with a Python script)
comments <- read_csv("comments_data.csv")

# Break comments down into words
# Combine "offensive" into "offense" same for "defensive"
# Remove any words containing numbers or punctuation
words <- comments %>%
    unnest_tokens(word, body, strip_punct = TRUE) %>%
    anti_join(stop_words, by="word") %>%
    mutate(word = gsub("offensive", "offense", word)) %>%
    mutate(word = gsub("defensive", "defense", word)) %>%
    filter(nchar(word) > 2 & !grepl("[0-9]", word) &
               !grepl("[[:punct:]]", word) & !grepl("’", word) &
               !word %in% drop_words)

# Split out words specific to Kitchens and Stefanski, count up word frequencies,
# Create word clouds and save as images (save as HTML, then image)
kitchens_words <- words %>%
    filter(name == "Kitchens") %>%
    count(word, sort = TRUE) %>%
    mutate(n = n/sum(n)) 
kitchens_cloud <- kitchens_words %>%
    head(40) %>%
    wordcloud2(color = "#fb4f14", backgroundColor = "#F0F0F0")
saveWidget(kitchens_cloud,"1.html", selfcontained = F)
webshot("1.html","kitchens_cloud.png", vwidth = 600, vheight = 600, delay = 10)

stefanski_words <- words %>%
    filter(name == "Stefanski") %>%
    count(word, sort = TRUE) %>%
    mutate(n = n/sum(n))
stefanski_cloud <- stefanski_words %>%
    head(40) %>%
    wordcloud2(color = "#5c3920", backgroundColor = "#F0F0F0")
saveWidget(stefanski_cloud,"2.html", selfcontained = F)
webshot("2.html","stefanski_cloud.png", vwidth = 700, vheight = 700, delay = 10)

# Create tables
# kitchens_kable <- kitchens_words %>%
#     head(20) %>%
#     mutate(n = format(n *100, digits = 1)) %>%
#     kable(col.names = c("Word", "Relative Frequency (%)"),
#           align = c("l", "c")) %>%
#     kable_styling(bootstrap_options = "striped",
#                   full_width = F) %>%
#     save_kable(file = "kitchens_kable.png")
# 
# stefanski_kable <- stefanski_words %>%
#     head(20) %>%
#     mutate(n = format(n *100, digits = 1)) %>%
#     kable(col.names = c("Word", "Relative Frequency (%)"),
#           align = c("l", "c")) %>%
#     kable_styling(bootstrap_options = "striped",
#                   full_width = F) %>%
#     save_kable(file = "stefanski_kable.png")