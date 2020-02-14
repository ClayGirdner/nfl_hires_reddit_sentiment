import praw
from statistics import mean
from vaderSentiment.vaderSentiment import SentimentIntensityAnalyzer
import pandas as pd

analyser = SentimentIntensityAnalyzer()

# Credentials to access the Reddit api
reddit = praw.Reddit(client_id='uX8BAInNimcFmg',
                     client_secret='XPyGg4prTLXuj5Ld2lIdZ7JZUzU',
                     user_agent='chrome:first_app:v1.2.3 (by u/DrewMuhammad2001)',
                     username='DrewMuhammad2001',
                     password='Jumper33')


nfl_hires = {'Vrabel': {'team': 'TEN',
                        'nfl_url': 'https://www.reddit.com/r/nfl/comments/7rtt33/titans_hire_mike_vrabel_for_head_coaching_job/',
                        'team_url': 'https://www.reddit.com/r/Tennesseetitans/comments/7rtt6o/the_new_head_coach_of_the_tennessee_titans_is/'},
            'Wilks': {'team': 'ARI',
                        'nfl_url': 'https://www.reddit.com/r/nfl/comments/7s6yoc/arizona_cardinals_likely_going_with_panthers/',
                        'team_url': 'https://www.reddit.com/r/AZCardinals/comments/7s847y/steve_wilks_is_officially_the_new_arizona/'},
            'Gruden': {'team': 'OAK',
                        'nfl_url': 'https://www.reddit.com/r/nfl/comments/7od651/raiders_are_giving_new_head_coach_jon_gruden_a/',
                        'team_url': 'https://www.reddit.com/r/oaklandraiders/comments/7od69t/raiders_are_giving_new_head_coach_jon_gruden_a/'},
            'Reich': {'team': 'IND',
                        'nfl_url': 'https://www.reddit.com/r/nfl/comments/7wvyum/colts_its_official_colts_fans_frank_reich_is_your/',
                        'team_url': 'https://www.reddit.com/r/Colts/comments/7wvz8s/its_official_colts_fans_frank_reich_is_your_new/'},
            'Patricia': {'team': 'DET',
                        'nfl_url': 'https://www.reddit.com/r/nfl/comments/7vhh9c/the_lions_have_hired_matt_patricia_as_the/',
                        'team_url': 'https://www.reddit.com/r/detroitlions/comments/7vhhxm/the_lions_have_hired_matt_patricia_as_the/'},
            'Nagy': {'team': 'CHI',
                        'nfl_url': 'https://www.reddit.com/r/nfl/comments/7ozt19/bears_to_name_matt_nagy_new_head_coach/',
                        'team_url': 'https://www.reddit.com/r/CHIBears/comments/7ozspn/jahns_source_bears_to_name_matt_nagy_new_head/'},
            'Arians': {'team': 'TB',
                        'nfl_url': 'https://www.reddit.com/r/nfl/comments/adzob5/schefter_buccaneers_now_finalizing_deal_to_make/',
                        'team_url': 'https://www.reddit.com/r/buccaneers/comments/adzp0i/schefter_buccaneers_now_finalizing_deal_to_make/'},
            'Gase': {'team': 'NYJ',
                        'nfl_url': 'https://www.reddit.com/r/nfl/comments/aedk8e/schefter_jets_expected_to_hire_hc_adam_gase_per/',
                        'team_url': 'https://www.reddit.com/r/nyjets/comments/aedkbm/jets_expected_to_hire_hc_adam_gase_per_me_and/'},
            'Flores': {'team': 'MIA',
                        'nfl_url': 'https://www.reddit.com/r/nfl/comments/af0pz8/dolphins_expected_to_hire_patriots_brian_flores/',
                        'team_url': 'https://www.reddit.com/r/miamidolphins/comments/an5kzx/official_twitter_welcome_to_miami_flores/'},
            'Kitchens': {'team': 'CLE',
                        'nfl_url': 'https://www.reddit.com/r/nfl/comments/ae8r61/mort_freddie_kitchens_will_be_named_new_browns/',
                        'team_url': 'https://www.reddit.com/r/Browns/comments/ae8r9o/freddie_kitchens_will_be_named_new_browns_head/'},           
            'LaFleur': {'team': 'GB',
                        'nfl_url': 'https://www.reddit.com/r/nfl/comments/advoa3/pelissero_done_deal_the_packers_and_matt_lafleur/',
                        'team_url': 'https://www.reddit.com/r/GreenBayPackers/comments/adnp9d/packers_to_hire_titans_oc_matt_lafleur_as_head/'},
            'Fangio': {'team': 'DEN',
                        'nfl_url': 'https://www.reddit.com/r/nfl/comments/ae8tm0/schefter_denver_reached_agreement_with_bears_dc/',
                        'team_url': 'https://www.reddit.com/r/DenverBroncos/comments/ae8tm8/denver_reached_agreement_with_bears_dc_vic_fangio/'},
            'Taylor': {'team': 'CIN',
                        'nfl_url': 'https://www.reddit.com/r/nfl/comments/aeof9b/andy_furman_zac_taylor_to_be_named_bengals_coach/',
                        'team_url': 'https://www.reddit.com/r/bengals/comments/aeoulo/zac_taylor_is_the_next_hc_of_the_cincinnati/'},
            'Kingsbury': {'team': 'ARI',
                        'nfl_url': 'https://www.reddit.com/r/nfl/comments/ady9oy/schrager_per_sources_kliff_kingsbury_is/',
                        'team_url': 'https://www.reddit.com/r/AZCardinals/comments/adzbak/cardinals_are_giving_new_hc_kliff_kingsbury_a/'},
            'Rivera': {'team': 'WAS',
                        'nfl_url': 'https://www.reddit.com/r/nfl/comments/ei32ez/silver_the_ron_rivera_deal_is_done_he_has_reached/',
                        'team_url': 'https://www.reddit.com/r/Redskins/comments/ei344e/rapoportthe_redskins_are_making_ron_rivera_their/'},
            'Judge': {'team': 'NYG',
                        'nfl_url': 'https://www.reddit.com/r/nfl/comments/eldksd/schefter_new_york_giants_are_finalizing_a_deal_to/',
                        'team_url': 'https://www.reddit.com/r/NYGiants/comments/eldqyu/new_hc_joe_judge_megathread/'},
            'McCarthy': {'team': 'DAL',
                        'nfl_url': 'https://www.reddit.com/r/nfl/comments/ekv55p/glazer_scoopage_alert_the_dallascowboys_have/',
                        'team_url': 'https://www.reddit.com/r/cowboys/comments/ekv5l8/glazer_the_dallas_cowboys_have_agreed_to_terms/'},
            'Stefanski': {'team': 'CLE',
                        'nfl_url': 'https://www.reddit.com/r/nfl/comments/enq0t8/rap_sources_the_browns_are_planning_to_hire/',
                        'team_url': 'https://www.reddit.com/r/Browns/comments/enq0xn/rapoport_sources_the_browns_are_planning_to_hire/'},
            'Rhule': {'team': 'CAR',
                        'nfl_url': 'https://www.reddit.com/r/nfl/comments/elciq2/thamel_sources_baylor_coach_matt_rhule_finalizing/',
                        'team_url': 'https://www.reddit.com/r/panthers/comments/elcihe/thamel_sources_baylor_coach_matt_rhule_finalizing/'},
            }

hires_df = pd.DataFrame.from_dict(nfl_hires)

print(hires_df)

# submission = reddit.submission(url=stefanski_browns)

# submission.comment_sort = 'top'

# counter = 0
# vader_scores = []

# submission.comments.replace_more(limit=None)
# for comment in submission.comments.list():

#     score = analyser.polarity_scores(comment.body)['compound']
    
#     if score > 0:
#         vader_scores.append(score)
        
#     counter += 1
