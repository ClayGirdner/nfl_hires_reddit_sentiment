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

# Import NFL logo URLs, sub Titans' for one with transparent background
nfl_logos <- read_csv("https://raw.githubusercontent.com/statsbylopez/BlogPosts/master/nfl_teamlogos.csv")
nfl_logos[nfl_logos$team_code == "TEN", "url"] <- "https://media.socastsrm.com/wordpress/wp-content/blogs.dir/258/files/2019/10/tennessee_titans_1999-pres.png"

# Load in comment data (originally gathered with a Python script)
comments <- read_csv("comments_data.csv")

# Aggregate comments by coach and subreddit (nfl or team)
# Compute counts and average scores for each polarity/subjectivity score
# When averaging polarity scores, exclude scores equal to zero
comments_agg <- comments %>%
    group_by(name, team, subreddit) %>%
    summarize(count = sum(!is.na(name)),
              vader = mean(vader_compound[vader_compound != 0]),
              blob = mean(blob_polarity[blob_polarity != 0]),
              blob_subjectivity = mean(blob_subjectivity),
              vader_subjectivity = mean(abs(vader_compound))) %>%
    left_join(nfl_logos, by = c("team" = "team_code")) %>%
    left_join(nflteams, by = c("team" = "abbr"))
    

# Scatter plot featuring both polarity scores
polarity_plot <- comments_agg %>%
    filter(subreddit == "nfl") %>%
    ggplot(aes(x = vader, y = blob)) +
    geom_image(aes(image = url)) +
    geom_text_repel(aes(label = name,
                        color = primary),
                    point.padding = 0.5) +
    scale_color_identity() +
    labs(x = "Average VADER Polarity",
         y = "Average TextBlob Polarity",
         title = "Reddit Comment Polarity",
         subtitle = "r/nfl hire threads",
         caption = "excludes neutral comments (polarity score = 0)") +
    theme_pff

ggsave("nfl_polarity.png", dpi = 1200, height = 7, width = 7)


# Scatter plot of both subjectivity scores
subjectivity_plot <- comments_agg %>%
    filter(subreddit == "nfl") %>%
    ggplot(aes(x = vader_subjectivity, y = blob_subjectivity)) +
    geom_image(aes(image = url)) +
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
count_plot <- comments_agg %>%
    filter(subreddit == "nfl") %>%
    ggplot(aes(y = count, x = reorder(name, count))) +
    geom_col(aes(fill = lighten(primary)),
             color = "black") +
    scale_fill_identity() +
    geom_image(aes(image = url,
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
         title = "Comment Count") +
    theme_pff +
    theme(panel.grid.major.y = element_blank(),
          axis.text.y = element_blank(),
          plot.title = element_text(hjust = 0.5))

# Combining subjectivity and count plots side by side
subjectivity_count_plot <- ggarrange(subjectivity_plot, count_plot,
                                   ncol = 2, nrow = 1)
ggsave("nfl_subjectivity_count.png", dpi = 1200, height = 6, width = 9)

# Plot showing the difference between VADER polarity scores in r/nfl and team
# subreddits
subreddit_plot <- comments_agg %>%
    ggplot(aes(x = vader,
               group = name,
               y = reorder(name, vader))) +
    geom_line(aes(color = primary),
              size = 1) +
    scale_color_identity() +
    geom_image(data = filter(comments_agg, subreddit == "nfl"),
               size = 0.045,
               image = "https://upload.wikimedia.org/wikipedia/en/thumb/a/a2/National_Football_League_logo.svg/1200px-National_Football_League_logo.svg.png") +
    geom_image(data = filter(comments_agg, subreddit == "team"),
               aes(image = url),
               size = 0.06) +
    labs(x = "Average VADER Polarity", 
         y = NULL,
         title = "VADER Polarity Comparison",
         subtitle = "r/nfl vs team subreddits") +
    theme_pff +
    theme(panel.grid.major.y = element_blank(),
          axis.text.y = element_text(size = 13))
ggsave("subreddit_comp.png", dpi = 1200, height = 7, width = 7)