-- ------------------
-- ------------------
-- 1. FIRST QUERY
-- Create a Table ranking the reviewer
-- ------------------
DROP TABLE IF EXISTS reviewer_ranking;
CREATE TABLE reviewer_ranking AS
SELECT
    reviewer,
    reviews_number,
    first_year,
    last_year,
    RANK() OVER (ORDER BY reviews_number DESC) AS reviewer_rank
FROM (
    SELECT 
        reviewer,
        COUNT(*) AS reviews_number,
        MIN(year) as first_year,
        MAX(year) as last_year
    FROM
        df_reviews
    GROUP BY
        reviewer
) AS best_reviewer
ORDER BY
    reviewer_rank;
-- ------------------
-- ------------------
-- ------------------
-- ------------------
-- 2. SECOND QUERY
-- Reviewer with most review by gender
-- ------------------

SELECT 
    ranked_data.reviewer,
    ranked_data.gender,
    ranked_data.reviews_number
FROM (
    SELECT 
        reviewer_ranking.reviewer,
        df_reviewer_genderVF.gender,
        reviewer_ranking.reviews_number,
        ROW_NUMBER() OVER (PARTITION BY df_reviewer_genderVF.gender ORDER BY reviewer_ranking.reviews_number DESC) AS rn
    FROM 
        reviewer_ranking
    LEFT JOIN 
        df_reviewer_genderVF ON reviewer_ranking.reviewer = df_reviewer_genderVF.reviewer
) AS ranked_data
WHERE 
    ranked_data.rn <= 5
ORDER BY
    ranked_data.gender,
    ranked_data.reviews_number DESC;
-- ------------------
-- ------------------
-- ------------------
-- ------------------
-- 3. THIRD QUERY
-- Artists with most reviews
-- ------------------

SELECT 
	artist, 
    COUNT(*) as times_in_ranking
FROM
	df_songs
GROUP BY
	artist
ORDER BY
	times_in_ranking DESC
LIMIT
	10;
-- ------------------
-- ------------------
-- ------------------
-- ------------------
-- 4. FOURTH QUERY 
-- Clean the collaborators columns 
-- ------------------
UPDATE df_songs
SET
  collaborator_1 = COALESCE(NULLIF(collaborator_1, ''), NULLIF(collaborator_2, ''), NULLIF(collaborator_3, ''), NULLIF(collaborator_4, ''), NULLIF(collaborator_5, ''), ''),
  collaborator_2 = COALESCE(NULLIF(CASE WHEN collaborator_1 IS NOT NULL AND collaborator_1 <> '' THEN collaborator_2 END, ''), NULLIF(collaborator_3, ''), NULLIF(collaborator_4, ''), NULLIF(collaborator_5, ''), ''),
  collaborator_3 = COALESCE(NULLIF(CASE WHEN collaborator_2 IS NOT NULL AND collaborator_2 <> '' THEN collaborator_3 END, ''), NULLIF(collaborator_4, ''), NULLIF(collaborator_5, ''), ''),
  collaborator_4 = COALESCE(NULLIF(CASE WHEN collaborator_3 IS NOT NULL AND collaborator_3 <> '' THEN collaborator_4 END, ''), NULLIF(collaborator_5, ''), ''),
  collaborator_5 = COALESCE(NULLIF(CASE WHEN collaborator_4 IS NOT NULL AND collaborator_4 <> '' THEN collaborator_5 END, ''), '')
WHERE collaborator_1 IS NULL OR collaborator_1 = ''
   OR collaborator_2 IS NULL OR collaborator_2 = ''
   OR collaborator_3 IS NULL OR collaborator_3 = ''
   OR collaborator_4 IS NULL OR collaborator_4 = ''
   OR collaborator_5 IS NULL OR collaborator_5 = '';

SET SQL_SAFE_UPDATES = 0;

-- 5. FIFTH QUERY
-- Create a Keys Table
-- ------------------
DROP TABLE IF EXISTS keys_table;
CREATE TABLE keys_table AS
SELECT 
	df_reviews.year_rank as year_rank,
    df_reviewer_genderVF.reviewer_id as reviewer_id,
    df_sources.Playlist_ID as playlist_id,
    df_sources.Title as title
FROM df_reviews
LEFT JOIN 
	df_reviewer_genderVF
    ON
    df_reviews.reviewer = df_reviewer_genderVF.reviewer
LEFT JOIN
	df_sources
    ON
    df_reviews.year = df_sources.Year;
    
UPDATE keys_table
SET Title = REPLACE(LOWER(Title), ' ', '_')
WHERE Title IS NOT NULL;
	