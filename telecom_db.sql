SELECT * FROM customer_communications;


-- 1. How many users received a NIN call even after linking their NIN?
SELECT COUNT(*) AS users_called_after_nin_linked
FROM customer_communications
WHERE NIN_Linked = TRUE
  AND Received_Call_NIN = TRUE;


--2. How many users received promo messages for a plan they already subscribed to?
SELECT COUNT(*) AS users_messaged_after_nin_linked
FROM customer_communications
WHERE Plan_Active = TRUE
AND Received_Message_Plan = TRUE;

--3. Plans with the highest rate of duplicate messaging after activation
SELECT Plan_Name,
COUNT(*) AS duplicate_messages
FROM customer_communications
WHERE Plan_Active = TRUE
AND Received_Message_Plan = TRUE
GROUP BY Plan_Name
ORDER BY duplicate_messages DESC;

--4. Locations with the most duplicated communications
SELECT location,
COUNT (*) AS duplicate_comms
FROM customer_communications
WHERE (Plan_Active = TRUE AND Received_Message_Plan = TRUE)
	 OR (NIN_Linked = TRUE AND Received_Call_NIN = TRUE)
GROUP BY location
ORDER BY duplicate_comms DESC;

-- 5. Percentage of total communication efforts that are potentially wasteful
SELECT 
    ROUND(100.0 * COUNT(*) FILTER (
        WHERE (NIN_Linked = TRUE AND Received_Call_NIN = TRUE)
           OR (Plan_Active = TRUE AND Received_Message_Plan = TRUE)
    ) / COUNT(*), 2) AS percent_waste_communication
FROM customer_communications;

--6. Users receiving communications unrelated to their needs
SELECT COUNT(*) AS off_target_communications
FROM customer_communications
WHERE (Channel_Targeted = 'NIN' AND NIN_Linked = TRUE AND Received_Call_NIN = TRUE)
   OR (Channel_Targeted = 'Plan' AND Plan_Active = TRUE AND Received_Message_Plan = TRUE);

--Correlation-like breakdown: Are well-targeted users more engaged?
SELECT 
    CASE 
        WHEN (NIN_Linked = TRUE AND Received_Call_NIN = TRUE)
          OR (Plan_Active = TRUE AND Received_Message_Plan = TRUE)
        THEN 'Mismatched Communication'
        ELSE 'Clean Targeting'
    END AS communication_type,
    AVG(active_Days) AS avg_active_days
FROM customer_communications
GROUP BY communication_type;

--8. Potential customer segments for better targeting
SELECT plan_name,
       location,
       COUNT(*) AS total_users
FROM customer_communications
GROUP BY plan_Name, location
ORDER BY total_users DESC;

--9. Users who received messages/calls but never acted
SELECT COUNT(*) AS users_ignoring_campaigns
FROM customer_communications
WHERE (Received_Message_Plan = TRUE AND Plan_Active = FALSE)
   OR (Received_Call_NIN = TRUE AND NIN_Linked = FALSE);
   
/*Estimate cost of redundant communication (e.g., ₦4 per SMS or call)
Assume ₦4 per SMS or call:*/
SELECT 
    COUNT(*) FILTER (
        WHERE NIN_Linked = TRUE AND Received_Call_NIN = TRUE
    ) * 4 +
    COUNT(*) FILTER (
        WHERE Plan_Active = TRUE AND Received_Message_Plan = TRUE
    ) * 4 AS estimated_naira_lost
FROM customer_communications;







