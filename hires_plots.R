library(nflscrapR)
library(tidyverse)
library(dplyr)
library(ggplot2)
library(ggimage)
library(ggrepel)
library(ggpubr)

# Theme for plots
source("theme_pff.R")

# Function to lighten up colors by 10%
lighten <- function(color, factor = 0.1) {
    if ((factor > 1) | (factor < 0)) stop("factor needs to be within [0,1]")
    col <- col2rgb(color)
    col <- col + (255 - col)*factor
    col <- rgb(t(col), maxColorValue=255)
    col
}

# Load in comment data (originally gathered with a Python script)
comments <- read_csv("comments_data.csv")

# Import NFL logo URLs, sub Titans' for one with transparent background
nfl_logos <- read_csv("https://raw.githubusercontent.com/ClayGirdner/nfl_hires_reddit_sentiment/master/nfl_team_logos.csv")

# Join up the data sets
comments <- comments %>%
    left_join(nfl_logos, by = c("team" = "team_code")) %>%
    left_join(nflteams, by = c("team" = "abbr"))

# Scatter plot of all 31k observations
vader_textblob_scatter <- comments %>%
    ggplot(aes(x = vader_compound, y = blob_polarity)) + 
    geom_point(alpha = 0.1) +
    geom_smooth(method = lm, size = 1.5) +
    labs(x = "VADER Polarity",
         y = "TextBlob Polarity") +
    theme_pff
ggsave("vader_textblob_scatter.png", dpi = 1200, height = 7, width = 7)


# Polarity plot excluding neutral observations
polarity_plot_exclude <- comments %>%
    filter(subreddit == "nfl") %>%
    group_by(name, team, url.y, primary) %>%
    summarize(vader_polarity = mean(vader_compound[vader_compound != 0]),
              blob_polarity = mean(blob_polarity[blob_polarity != 0])) %>%
    ggplot(aes(x = vader_polarity, y = blob_polarity)) +
    geom_image(aes(image = url.y)) +
    geom_text_repel(aes(label = name,
                        color = primary),
                    point.padding = 0.5) +
    scale_color_identity() +
    labs(x = "Average VADER Polarity",
         y = "Average TextBlob Polarity",
         title = "Reddit Comment Polarity",
         subtitle = "r/nfl HC hiring threads since 2018",
         caption = "excludes neutral comments (polarity score = 0)") +
    theme_pff
ggsave("nfl_polarity.png", dpi = 1200, height = 7, width = 7)


# Scatter plot of both subjectivity scores
subjectivity_plot <- comments %>%
    filter(subreddit == "nfl") %>%
    group_by(name, team, url.y, primary) %>%
    summarize(vader_subjectivity = mean(abs(vader_compound)),
              blob_subjectivity = mean(blob_subjectivity)) %>%
    ggplot(aes(x = vader_subjectivity, y = blob_subjectivity)) +
    geom_image(aes(image = url.y)) +
    geom_text_repel(aes(label = name,
                        color = primary),
                    point.padding = 0.5) +
    scale_color_identity() +
    labs(x = "Average VADER Subjectivity",
         y = "Average TextBlob Subjectivity",
         title = "Comment Subjectivity") +
    theme_pff +
    theme(plot.title = element_text(hjust = 0.5))

# Total comments for each r/nfl thread
count_plot <- comments %>%
    filter(subreddit == "nfl") %>%
    group_by(name, team, url.y, primary) %>%
    summarize(count = sum(!is.na(name))) %>%
    ggplot(aes(y = count, x = reorder(name, count))) +
    geom_col(aes(fill = lighten(primary)),
             color = "black") +
    scale_fill_identity() +
    geom_image(aes(image = url.y,
                   y = count + 175),
               size = 0.058) +
    geom_text(aes(label = name, 
                  color = primary,
                  y = count + 350),
              hjust = 0) +
    scale_color_identity() +
    ylim(0, 3750) + 
    coord_flip() +
    labs(x = NULL, 
         y = NULL,
         title = "Comment Count",
         caption = "r/nfl comment threads since 2018") +
    theme_pff +
    theme(panel.grid.major.y = element_blank(),
          axis.text.y = element_blank(),
          plot.title = element_text(hjust = 0.5))

# Combining subjectivity and count plots side by side
subjectivity_count_plot <- ggarrange(subjectivity_plot, count_plot,
                                     ncol = 2, nrow = 1)
ggsave("nfl_subjectivity_count.png", dpi = 1200, height = 6, width = 9)

# Plot showing the difference between VADER polarity scores in r/nfl and team
# subreddits, first we need to aggregate the comments data though
comments_subs <- comments %>%
    group_by(name, team, subreddit, url.y, primary) %>%
    summarize(vader_polarity = mean(vader_compound[vader_compound != 0]))

subreddit_plot <- comments_subs %>%
    ggplot(aes(x = vader_polarity,
               group = name,
               y = reorder(name, vader_polarity))) +
    geom_line(aes(color = primary),
              size = 1) +
    scale_color_identity() +
    geom_image(data = filter(comments_subs, subreddit == "nfl"),
               size = 0.045,
               image = "https://upload.wikimedia.org/wikipedia/en/thumb/a/a2/National_Football_League_logo.svg/1200px-National_Football_League_logo.svg.png") +
    geom_image(data = filter(comments_subs, subreddit == "team"),
               aes(image = url.y),
               size = 0.06) +
    labs(x = "Average VADER Polarity", 
         y = NULL,
         title = "VADER Polarity Comparison",
         subtitle = "r/nfl vs team subreddits") +
    theme_pff +
    theme(panel.grid.major.y = element_blank(),
          axis.text.y = element_text(size = 13))
ggsave("subreddit_comp.png", dpi = 1200, height = 7, width = 7)