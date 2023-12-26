CREATE TABLE apple_store_description_combined as 

select * from appleStore_description1

union ALL

select * from appleStore_description2

union ALL

select * from appleStore_description3

union ALL

select * from appleStore_description4

---check the number of unique apps in both tablesappAppleStore
select count(DISTINCT id) as uniqueappleid
from AppleStore

select count(DISTINCT id) as uniqueappleid
from apple_store_description_combined

---check for any missing values in key fields 

select count(*) as  MissingValues 
from AppleStore
where track_name is null or user_rating is null  or prime_genre is null

select count(*) as  MissingValues 
from apple_store_description_combined
where app_desc is null 

-----find the number of apps per genre
select prime_genre , count(*) as numApps
from AppleStore
group by prime_genre
order by numApps DESC

---------get an overview of the apps rating----------
select min(user_rating) as MinRating,
       max(user_rating) as MaxRating,
       avg(user_rating) as AvgRating
From AppleStore

---Determine whether paid apps have higher ratings then free apps
select case 
        	when price > 0 then 'Paid'
 			else 'Free'
            end as App_Type,
            avg(user_rating) as Avg_rating 
from AppleStore
group by  App_Type

----check if apps with more supporting languages have higher ratings -----
select case 
			when lang_num < 10 then '<10 langauges'
            when lang_num  between 10 and 30  then '10-30 langauges'
            else '<30 languages'
       end as language_bucket,
       avg(user_rating) as Avg_rating 
from AppleStore
GROUP by language_bucket
order by Avg_rating DESC

-----check genres with low ratings----
select prime_genre,
		       avg(user_rating) as Avg_rating 
from AppleStore
group by prime_genre
order by Avg_rating ASC
limit 10 
------check if there is correlation between the lenght of the app description and the user rating AppleStore
SELECT 
case 
	when length(b.app_desc)< 500 then 'Short'
    when length(b.app_desc)BETWEEN 500 and 1000 then  'medium'
    else 'Long'
end as description_length_bucket ,
avg(user_rating) as Avg_rating 


FROM
 	AppleStore as A
join 
	apple_store_description_combined as b
on 
	a.id = b.id
group by description_length_bucket
order by Avg_rating

-----check the top rated apps for each genre--
select 
	prime_genre,
    track_name,
    user_rating
from (
  	select 
    prime_genre,
    track_name,
    user_rating,
    RANK() OVER (PARTITION BY prime_genre ORDER BY user_rating DESC,rating_count_tot desc) as rank 
    FROM AppleStore	
) AS a
WHERE a.rank = 1