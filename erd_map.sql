SELECT *
FROM keys_table
JOIN df_songs ON keys_table.year_rank = df_songs.year_rank
JOIN df_reviews ON keys_table.year_rank = df_reviews.year_rank
JOIN df_reviewer_genderVF ON keys_table.reviewer_id = df_reviewer_genderVF.reviewer_id
JOIN df_sources ON keys_table.playlist_id = df_sources.Playlist_ID
JOIN reviewer
-- JOIN final_project.df_reviews ON final_project.df_reviews.reviewer = df_reviewer.reviewer;


