import pandas as pd
import praw
from statistics import mean
from vaderSentiment.vaderSentiment import SentimentIntensityAnalyzer
from textblob import TextBlob

# Import dictionary of Reddit URLs for each coaching hire
# Convert the dictionary to a dataframe
from reddit_hire_urls import reddit_hire_urls
hires_df = pd.DataFrame.from_dict(reddit_hire_urls, orient='index')

# Import Reddit credentials to access API
# Edit the reddit_creds file to access the reddit API through your own app
# instructions here (https://praw.readthedocs.io/en/latest/getting_started/quick_start.html)
import reddit_creds

# Insert Reddit credentials and create access point to Reddit API
reddit = praw.Reddit(client_id = reddit_creds.client_id,
                     client_secret = reddit_creds.client_secret,
                     user_agent = reddit_creds.user_agent,
                     username = reddit_creds.username,
                     password = reddit_creds.password)

# Create VADER sentiment analyser
analyser = SentimentIntensityAnalyzer()

# Create empty dataframe to house each comment as a new row
comments_df = pd.DataFrame()

# Loop through each recent coaching hire
for index, row in hires_df.iterrows():
    name = index
    team = row['team']
    
    nfl_url = row['nfl_url']
    team_url = row['team_url']
    
    # Loop through r/nfl and the teams respective subreddit ('nfl' or 'team')
    for url in [nfl_url, team_url]:
        if url == nfl_url:
            subreddit = 'nfl'
        else:
            subreddit = 'team'
            
        submission = reddit.submission(url = url)
        
        # Loop through each comment
        submission.comments.replace_more(limit=None)
        for comment in submission.comments.list():
            comment_id = comment.id
            author = comment.author
            time = comment.created_utc
            upvote_score = comment.score
            body = comment.body

            scores = analyser.polarity_scores(body)
            vader_neg = scores['neg']
            vader_neu = scores['neu']
            vader_pos = scores['pos']
            vader_compound = scores['compound']

            blob = TextBlob(body)
            blob_polarity = blob.sentiment.polarity
            blob_subjectivity = blob.sentiment.subjectivity

            comments_df = comments_df.append({'name': name, 'team': team, 'subreddit': subreddit, 'url': url,
                                              'comment_id': comment_id, 'author': author, 'time': time, 'upvote_score': upvote_score,
                                              'vader_neg': vader_neg, 'vader_neu': vader_neu, 'vader_pos': vader_pos, 'vader_compound': vader_compound,
                                              'blob_polarity': blob_polarity, 'blob_subjectivity': blob_subjectivity,
                                              'body': body}, ignore_index=True)

# Save dataframe to csv file 
comments_df.to_csv('comments_data.csv', index = False)
