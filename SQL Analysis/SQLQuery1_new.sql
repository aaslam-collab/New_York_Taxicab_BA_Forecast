
-- Let's see the entire table from the yellow taxi cab dataset 1
SELECT *
From yellow_tripdata yt 
Where tip_amount is null
Order by 1

-- Because most of the data for airport_fee is empty, I will remove the column from this dataset as it is no help. This column was recently added so it understandabl why it's mostly empty
Select *
From yellow_tripdata yt 
order by airport_fee DESC 

-- Deleting column airport_dee
alter table yellow_tripdata 
drop column airport_fee

Select *
from yellow_tripdata yt 


-- Need to delete 'Column1' as it was added by python. Converted Parquet format to CSV and it added Column1
Alter table yellow_tripdata 
Drop column Column1

Select RatecodeID
From yellow_tripdata yt 


-- RatecodeID is the "The final rate code in effect at the end of the trip." There 6 types of rate codes. Need add the text names to make it easier to read.
  -- 1=Standard rate
  -- 2=JFK
  -- 3=Newark
  -- 4=Nassau or Westchester
  -- 5=Negotiated fare
  -- 6=Group ride

Select RatecodeID 
, case when RatecodeID = 1 then CAST('Standard_Rate' as VARCHAR(255))
			when RatecodeID = 2 then CAST('JFK' as VARCHAR(255))
			when RatecodeID = 3 then CAST('Newark' as VARCHAR(255))
			when RatecodeID = 4 then CAST('Nassau/Westchester' as VARCHAR(255))
			when RatecodeID = 5 then CAST('Negotiated_Fare' as VARCHAR(255))
			when RatecodeID = 6 then CAST('Group_Ride'  as VARCHAR(255))
			ELSE CAST('RatecodeID' AS VARCHAR(255))
			END
From yellow_tripdata 

-- The above line of code is working, before I Update the table, I want to create a copy of column RarecodeID and make the changes there. This will preseve the original column 
ALTER TABLE yellow_tripdata
ADD RatecodeID_Text VARCHAR(255)

UPDATE yellow_tripdata SET RatecodeID_Text = RatecodeID

-- Now to run the script below, this will update the new column with the text data
UPDATE yellow_tripdata 
SET RatecodeID_Text = case when RatecodeID = 1 then CAST('Standard_Rate' as VARCHAR(255))
			when RatecodeID = 2 then CAST('JFK' as VARCHAR(255))
			when RatecodeID = 3 then CAST('Newark' as VARCHAR(255))
			when RatecodeID = 4 then CAST('Nassau/Westchester' as VARCHAR(255))
			when RatecodeID = 5 then CAST('Negotiated_Fare' as VARCHAR(255))
			when RatecodeID = 6 then CAST('Group_Ride'  as VARCHAR(255))
			ELSE CAST('RatecodeID' AS VARCHAR(255))
			END
-- Check to see if everything works -- Looks like everything worked. 			
Select RatecodeID, RatecodeID_Text
From yellow_tripdata yt 

-- I will be updating the Store_and_fwd_flag and Payment_type just like before.

SELECT store_and_fwd_flag  
, case when store_and_fwd_flag  = 'Y' then 'Store_and_Forward_Trip'
			when store_and_fwd_flag  = 'N' then 'Not_Store_and_Forward_Trip'
			ELSE store_and_fwd_flag 
			END
From yellow_tripdata yt 

ALTER TABLE yellow_tripdata
ADD store_and_fwd_flag_text varchar(255)

UPDATE yellow_tripdata SET store_and_fwd_flag_text = store_and_fwd_flag


Update yellow_tripdata 
Set store_and_fwd_flag_text = case when store_and_fwd_flag_text  = 'Y' then 'Store_and_Forward_Trip'
			when store_and_fwd_flag_text  = 'N' then 'Not_Store_and_Forward_Trip'
			ELSE store_and_fwd_flag_text 
			END
			
select *
from yellow_tripdata yt 

-- Updating payment_type categories to names for ease of viewing and analysis. Same steps as above.
Select payment_type 
, case when payment_type = 1 then CAST('Credit_card' as varchar(255))
			when payment_type = 2 then cast('Cash' as varchar(255))
			when payment_type = 3 then cast('No_charge' as varchar(255))
			when payment_type = 4 then cast('Dispute' as varchar(255))
			when payment_type = 5 then cast('Unknown' as varchar(255))
			when payment_type = 6 then cast('Voided_trip' as varchar(255))
			ELSE cast('payment_type' as varchar(255))
			END
From yellow_tripdata yt 

ALTER TABLE yellow_tripdata
ADD payment_type_text varchar(255)

UPDATE yellow_tripdata SET payment_type_text = payment_type

SELECT *
FROM yellow_tripdata yt 

Update yellow_tripdata 
Set payment_type_text = case when payment_type = 1 then CAST('Credit_card' as varchar(255))
			when payment_type = 2 then cast('Cash' as varchar(255))
			when payment_type = 3 then cast('No_charge' as varchar(255))
			when payment_type = 4 then cast('Dispute' as varchar(255))
			when payment_type = 5 then cast('Unknown' as varchar(255))
			when payment_type = 6 then cast('Voided_trip' as varchar(255))
			ELSE cast('payment_type' as varchar(255))
			END


--With diff_seconds as (			
--SELECT VendorID, tpep_pickup_datetime, tpep_dropoff_datetime, DATEDIFF(SECOND, tpep_pickup_datetime, tpep_dropoff_datetime) as Seconds
--From yellow_tripdata
--), 


Select *
from yellow_tripdata

-- total and average fare amount per vendorID based on the ratecodeID_text

select VendorID
, Round(Avg(Fare_amount), 2) as avg_fare_amt
, Round(SUM(Fare_amount), 2) as total_fare_amt
, RatecodeID_text
, payment_type_text
, Round(sum(trip_distance), 2) as total_trip_distance
, Round(Sum(passenger_count), 2) as total_passengers
from yellow_tripdata
Group by VendorID, RatecodeID_Text, payment_type_text
Order by 1, 2

-- save the above query in a temp table for further calculations
Drop table if exists #table_1
Create table #table_1
(
VendorID varchar (255),
avg_fare_amt varchar (255),
total_fare_amt varchar (255),
RatecodeID_text varchar (255),
payment_type_text varchar (255),
total_trip_distance varchar (255),
total_passengers varchar (255)
)
Insert into #table_1
select VendorID
, Round(Avg(Fare_amount), 2) as avg_fare_amt
, Round(SUM(Fare_amount), 2) as total_fare_amt
, RatecodeID_text
, payment_type_text
, Round(sum(trip_distance), 2) as total_trip_distance
, Round(Sum(passenger_count), 2) as total_passengers
from yellow_tripdata
Group by VendorID, RatecodeID_Text, payment_type_text
Order by 1, 2

Select *
From #table_1

-- From table_1, let's take a look at the sum of the averages for the columns queried below and group them by VendorID. This will give us an idea where the Vendors stand in comparison to each other. 
Select VendorID
, Sum(convert(float, avg_fare_amt)) as Sum_of_avg_fare_amt
, Sum(convert(float, total_fare_amt)) as Sum_of_total_fare_amt
, Sum(convert(float, total_trip_distance)) as Sum_of_total_trip_distance
, Sum(convert(float, total_passengers)) as Sum_of_total_passengers
from #table_1
Group by VendorID

-- Table shows a total count of Number_of_RateCodeIDs for Vendor = 1
Select Distinct RatecodeID_text, Count(VendorID) as Number_of_RateCodeIDs
From #table_1
Where VendorID = 1
Group by RatecodeID_text 
Order by 2

-- Table shows a total count of Number_of_RateCodeIDs for Vendor = 2
Select Distinct RatecodeID_text, Count(VendorID) as Number_of_RateCodeIDs
From #table_1
Where VendorID = 2
Group by RatecodeID_text 
Order by 2


--------------------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------------

-- For the rest of the SQL query, the dataset 'green_tripdata' will be used and will follow similar proceedures as above. Then we can compare the yellow and green datasets for further analysis

Select *
from dbo.green_tripdata 

-- Need to delete 'Column1' as it was added by python. Converted Parquet format to CSV and it added Column1
Alter table green_tripdata 
Drop column F1

Select RatecodeID 
, case when RatecodeID = 1 then CAST('Standard_Rate' as VARCHAR(255))
			when RatecodeID = 2 then CAST('JFK' as VARCHAR(255))
			when RatecodeID = 3 then CAST('Newark' as VARCHAR(255))
			when RatecodeID = 4 then CAST('Nassau/Westchester' as VARCHAR(255))
			when RatecodeID = 5 then CAST('Negotiated_Fare' as VARCHAR(255))
			when RatecodeID = 6 then CAST('Group_Ride'  as VARCHAR(255))
			ELSE CAST('RatecodeID' AS VARCHAR(255))
			END
From green_tripdata 

-- The above line of code is working, before I Update the table, I want to create a copy of column RarecodeID and make the changes there. This will preseve the original column 
ALTER TABLE green_tripdata
ADD RatecodeID_Text VARCHAR(255)

UPDATE green_tripdata SET RatecodeID_Text = RatecodeID

-- Now to run the script below, this will update the new column with the text data
UPDATE green_tripdata 
SET RatecodeID_Text = case when RatecodeID = 1 then CAST('Standard_Rate' as VARCHAR(255))
			when RatecodeID = 2 then CAST('JFK' as VARCHAR(255))
			when RatecodeID = 3 then CAST('Newark' as VARCHAR(255))
			when RatecodeID = 4 then CAST('Nassau/Westchester' as VARCHAR(255))
			when RatecodeID = 5 then CAST('Negotiated_Fare' as VARCHAR(255))
			when RatecodeID = 6 then CAST('Group_Ride'  as VARCHAR(255))
			ELSE CAST('RatecodeID' AS VARCHAR(255))
			END
-- Check to see if everything works -- Looks like everything worked. 			
Select RatecodeID, RatecodeID_Text
From green_tripdata

-- I will be updating the Store_and_fwd_flag and Payment_type just like RatecodeID.

SELECT store_and_fwd_flag  
, case when store_and_fwd_flag  = 'Y' then 'Store_and_Forward_Trip'
			when store_and_fwd_flag  = 'N' then 'Not_Store_and_Forward_Trip'
			ELSE store_and_fwd_flag 
			END
From green_tripdata

ALTER TABLE green_tripdata
ADD store_and_fwd_flag_text varchar(255)

UPDATE green_tripdata SET store_and_fwd_flag_text = store_and_fwd_flag


Update green_tripdata 
Set store_and_fwd_flag_text = case when store_and_fwd_flag_text  = 'Y' then 'Store_and_Forward_Trip'
			when store_and_fwd_flag_text  = 'N' then 'Not_Store_and_Forward_Trip'
			ELSE store_and_fwd_flag_text 
			END
			
select *
from green_tripdata

-- Changing the payment_type from numbers to words for ease of read and analysis
Select payment_type 
, case when payment_type = 1 then CAST('Credit_card' as varchar(255))
			when payment_type = 2 then cast('Cash' as varchar(255))
			when payment_type = 3 then cast('No_charge' as varchar(255))
			when payment_type = 4 then cast('Dispute' as varchar(255))
			when payment_type = 5 then cast('Unknown' as varchar(255))
			when payment_type = 6 then cast('Voided_trip' as varchar(255))
			ELSE cast('payment_type' as varchar(255))
			END
From green_tripdata

ALTER TABLE green_tripdata
ADD payment_type_text varchar(255)

UPDATE green_tripdata SET payment_type_text = payment_type  

Update green_tripdata 
Set payment_type_text = case when payment_type = 1 then CAST('Credit_card' as varchar(255))
			when payment_type = 2 then cast('Cash' as varchar(255))
			when payment_type = 3 then cast('No_charge' as varchar(255))
			when payment_type = 4 then cast('Dispute' as varchar(255))
			when payment_type = 5 then cast('Unknown' as varchar(255))
			when payment_type = 6 then cast('Voided_trip' as varchar(255))
			ELSE cast('payment_type' as varchar(255))
			END

SELECT *
FROM green_tripdata

-- ehail_fee has no values, the entire column is null. This column will be removed. 
Alter table green_tripdata
Drop column ehail_fee

Select *
from yellow_tripdata

-- total and average fare amount per vendorID based on the ratecodeID_text

select VendorID
, Round(Avg(Fare_amount), 2) as avg_fare_amt
, Round(SUM(Fare_amount), 2) as total_fare_amt
, RatecodeID_text
, payment_type_text
, Round(sum(trip_distance), 2) as total_trip_distance
, Round(Sum(passenger_count), 2) as total_passengers
from green_tripdata
Group by VendorID, RatecodeID_Text, payment_type_text
Order by 1, 2

-- save the above query in a temp table for further calculations
Drop table if exists #table_2
Create table #table_2
(
VendorID varchar (255),
avg_fare_amt varchar (255),
total_fare_amt varchar (255),
RatecodeID_text varchar (255),
payment_type_text varchar (255),
total_trip_distance varchar (255),
total_passengers varchar (255)
)
Insert into #table_2
select VendorID
, Round(Avg(Fare_amount), 2) as avg_fare_amt
, Round(SUM(Fare_amount), 2) as total_fare_amt
, RatecodeID_text
, payment_type_text
, Round(sum(trip_distance), 2) as total_trip_distance
, Round(Sum(passenger_count), 2) as total_passengers
from green_tripdata
Group by VendorID, RatecodeID_Text, payment_type_text
Order by 1, 2

Select *
From #table_2

-- Table shows the sum of the averages in each of the numerical columns and then grouped by the vendor id
Select VendorID
, Sum(convert(float, avg_fare_amt)) as Sum_of_avg_fare_amt
, Sum(convert(float, total_fare_amt)) as Sum_of_total_fare_amt
, Sum(convert(float, total_trip_distance)) as Sum_of_total_trip_distance
, Sum(convert(float, total_passengers)) as Sum_of_total_passengers
from #table_2
Group by VendorID

-- Table shows a total count of Number_of_RateCodeIDs for Vendor = 1
Select Distinct RatecodeID_text, Count(VendorID) as Number_of_RateCodeIDs
From #table_2
Where VendorID = 1
Group by RatecodeID_text 
Order by 2

-- Table shows a total count of Number_of_RateCodeIDs for Vendor = 2
Select Distinct RatecodeID_text, Count(VendorID) as Number_of_RateCodeIDs
From #table_2
Where VendorID = 2
Group by RatecodeID_text 
Order by 2

--------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------

-- The following code shows both green and yellow datasets combined together into a table for analysis.

-- Join table to compare green and yellow cab data
select yel.VendorID, yel.fare_amount, yel.RatecodeID_text, yel.payment_type_text
, yel.passenger_count, gre.vendorID, gre.fare_amount,  gre.RatecodeID_text, gre.payment_type_text, gre.passenger_count
from Taxi_cab..yellow_tripdata as yel
Join Taxi_cab..green_tripdata as gre
    on gre.vendorID = yel.vendorID
	and gre.RatecodeID_Text = yel.RatecodeID_Text
order by 1
