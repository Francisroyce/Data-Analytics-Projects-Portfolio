USE Data_Analytics_Portfolio
GO

SELECT *
FROM constituencywise_results

-- TO CHECK FACT TABLES
SELECT 
    t.name AS TableName,
    COUNT(fk.name) AS ForeignKeyCount,
    SUM(CASE WHEN ty.name IN ('int', 'decimal', 'float', 'money', 'bigint', 'numeric') THEN 1 ELSE 0 END) AS NumericColumnCount
FROM 
    sys.tables t
    LEFT JOIN sys.foreign_keys fk ON t.object_id = fk.parent_object_id
    INNER JOIN sys.columns c ON t.object_id = c.object_id
    INNER JOIN sys.types ty ON c.user_type_id = ty.user_type_id
GROUP BY 
    t.name
ORDER BY 
    ForeignKeyCount DESC, NumericColumnCount DESC;

--Compare Column Names Across Tables/ clues about the entity-relationship diagram (ERD)
SELECT 
    COLUMN_NAME,
    STRING_AGG(TABLE_NAME, ', ') AS TablesContainingColumn
FROM 
    INFORMATION_SCHEMA.COLUMNS
WHERE 
    TABLE_NAME IN ('constituencywise_results', 'constituencywise_details', 'partywise_results', 
                   'statewise_results', 'states')
GROUP BY 
    COLUMN_NAME
HAVING 
    COUNT(DISTINCT TABLE_NAME) > 1
ORDER BY 
    COLUMN_NAME;

-- TOTAL SEATS
SELECT COUNT(Parliament_Constituency) AS TOTAL_SEATS
FROM constituencywise_results;


-- TOTAL NUMBER OF SEATS AVAILABLE IN EACH STATE
SELECT
    S.STATE AS state_name,
    COUNT(CR.Parliament_Constituency) AS total_seats
FROM 
    constituencywise_results CR
INNER JOIN 
    statewise_results SR ON CR.Parliament_Constituency = SR.Parliament_Constituency
INNER JOIN 
    states S ON SR.State_ID = S.State_ID
GROUP BY 
    S.STATE;


-- TOTAL SEATS WON BY NDA ALLIANCE
SELECT Party, SUM(Won)
FROM partywise_results
GROUP BY Party


SELECT
	SUM(CASE	
			WHEN Party IN(
				'Bharatiya Janata Party - BJP',
				'Telugu Desam - TDP',
				'Janata Dal  (United) - JD(U)',
				'Shiv Sena - SHS',
				'AJSU Party - AJSUP',
				'Apna Dal (Soneylal) - ADAL',
				'Asom Gana Parishad - AGP',
				'Hindustani Awam Morcha (Secular) - HAMS',
				'Janasena Party - JnP',
				'Janata Dal  (Secular) - JD(S)',
				'Lok Janshakti Party(Ram Vilas) - LJPRV',
				'Nationalist Congress Party - NCP',
				'Rashtriya Lok Dal - RLD',
				'Sikkim Krantikari Morcha - SKM')
				THEN [Won]
				ELSE 0
				END
	) AS NDA_Total_seats_Won
FROM 
partywise_results;


--SEAT WON BY NDA ALLIANCE PARTIES
SELECT
		Party AS Party_Name,
		Won as Seats_Won
FROM partywise_results
	WHERE
		Party IN(
				'Bharatiya Janata Party - BJP',
				'Telugu Desam - TDP',
				'Janata Dal  (United) - JD(U)',
				'Shiv Sena - SHS',
				'AJSU Party - AJSUP',
				'Apna Dal (Soneylal) - ADAL',
				'Asom Gana Parishad - AGP',
				'Hindustani Awam Morcha (Secular) - HAMS',
				'Janasena Party - JnP',
				'Janata Dal  (Secular) - JD(S)',
				'Lok Janshakti Party(Ram Vilas) - LJPRV',
				'Nationalist Congress Party - NCP',
				'Rashtriya Lok Dal - RLD',
				'Sikkim Krantikari Morcha - SKM')
ORDER BY Seats_Won DESC;


-- INDIAN NATIONAL DEVELOPMENT INCLUSIVE(I.N.D.I.A)
--TOTAL SEAT WON BY I.N.D.I.A ALLIANCE
SELECT
	SUM(CASE	
			WHEN Party IN(
				'Indian National Congress - INC',
				'Aam Aadmi Party - AAAP',
				'Bharat Adivasi Party - BHRTADVSIP',
				'Communist Party of India  (Marxist) - CPI(M)',
				'Communist Party of India  (Marxist-Leninist)  (Liberation) - CPI(ML)(L)',
				'Communist Party of India - CPI',
				'Dravida Munnetra Kazhagam - DMK',
				'Indian Union Muslim League - IUML',
				'Jammu & Kashmir National Conference - JKN',
				'Kerala Congress - KEC',
				'Marumalarchi Dravida Munnetra Kazhagam - MDMK',
				'Nationalist Congress Party Sharadchandra Pawar - NCPSP',
				'Rashtriya Janata Dal - RJD',
				'Rashtriya Loktantrik Party - RLTP',
				'Revolutionary Socialist Party - RSP',
				'Samajwadi Party - SP',
				'Shiv Sena (Uddhav Balasaheb Thackrey) - SHSUBT',
				'Viduthalai Chiruthaigal Katchi - VCK',
				'All India Trinamool Congress - AITC',
				'Jharkhand Mukti Morcha - JMM'
				)
				THEN [Won]
				ELSE 0
				END
	) AS INDIA_Total_seats_Won
FROM 
partywise_results;


--SEAT WON BY I.N.D.I.A ALLIANCE PARTIES
SELECT
		Party AS Party_Name,
		Won as Seats_Won
FROM partywise_results
	WHERE Party IN (
				'Indian National Congress - INC',
				'Aam Aadmi Party - AAAP',
				'Bharat Adivasi Party - BHRTADVSIP',
				'Communist Party of India  (Marxist) - CPI(M)',
				'Communist Party of India  (Marxist-Leninist)  (Liberation) - CPI(ML)(L)',
				'Communist Party of India - CPI',
				'Dravida Munnetra Kazhagam - DMK',
				'Indian Union Muslim League - IUML',
				'Jammu & Kashmir National Conference - JKN',
				'Kerala Congress - KEC',
				'Marumalarchi Dravida Munnetra Kazhagam - MDMK',
				'Nationalist Congress Party Sharadchandra Pawar - NCPSP',
				'Rashtriya Janata Dal - RJD',
				'Rashtriya Loktantrik Party - RLTP',
				'Revolutionary Socialist Party - RSP',
				'Samajwadi Party - SP',
				'Shiv Sena (Uddhav Balasaheb Thackrey) - SHSUBT',
				'Viduthalai Chiruthaigal Katchi - VCK',
				'All India Trinamool Congress - AITC',
				'Jharkhand Mukti Morcha - JMM'
				)
ORDER BY Seats_Won DESC


-- ADD NEW COLUMN FIELD IN TABLE PARTYWISE_RESULTS TO GET THE PARTY ALLIANCE AS NDA, INDIA AND OTHER
ALTER TABLE partywise_results
ADD Party_alliance VARCHAR(50)

UPDATE partywise_results
SET Party_alliance = 'I.N.D.I.A'
	WHERE Party IN (
				'Indian National Congress - INC',
				'Aam Aadmi Party - AAAP',
				'Bharat Adivasi Party - BHRTADVSIP',
				'Communist Party of India  (Marxist) - CPI(M)',
				'Communist Party of India  (Marxist-Leninist)  (Liberation) - CPI(ML)(L)',
				'Communist Party of India - CPI',
				'Dravida Munnetra Kazhagam - DMK',
				'Indian Union Muslim League - IUML',
				'Jammu & Kashmir National Conference - JKN',
				'Kerala Congress - KEC',
				'Marumalarchi Dravida Munnetra Kazhagam - MDMK',
				'Nationalist Congress Party Sharadchandra Pawar - NCPSP',
				'Rashtriya Janata Dal - RJD',
				'Rashtriya Loktantrik Party - RLTP',
				'Revolutionary Socialist Party - RSP',
				'Samajwadi Party - SP',
				'Shiv Sena (Uddhav Balasaheb Thackrey) - SHSUBT',
				'Viduthalai Chiruthaigal Katchi - VCK',
				'All India Trinamool Congress - AITC',
				'Jharkhand Mukti Morcha - JMM'
				);

UPDATE partywise_results
SET Party_alliance = 'NDA'
	WHERE
		Party IN(
				'Bharatiya Janata Party - BJP',
				'Telugu Desam - TDP',
				'Janata Dal  (United) - JD(U)',
				'Shiv Sena - SHS',
				'AJSU Party - AJSUP',
				'Apna Dal (Soneylal) - ADAL',
				'Asom Gana Parishad - AGP',
				'Hindustani Awam Morcha (Secular) - HAMS',
				'Janasena Party - JnP',
				'Janata Dal  (Secular) - JD(S)',
				'Lok Janshakti Party(Ram Vilas) - LJPRV',
				'Nationalist Congress Party - NCP',
				'Rashtriya Lok Dal - RLD',
				'Sikkim Krantikari Morcha - SKM');

UPDATE partywise_results
SET Party_alliance = 'OTHER'
WHERE Party_alliance IS NULL

SELECT
	Party_alliance,
	SUM(Won) AS Total_seats_Won
FROM 
	partywise_results
GROUP BY Party_alliance;


SELECT Party, Won
FROM partywise_results
WHERE Party_alliance = 'I.N.D.I.A'
ORDER BY Won DESC;

SELECT Party, Won
FROM partywise_results
WHERE Party_alliance = 'NDA'
ORDER BY Won DESC;

SELECT Party, Won
FROM partywise_results
WHERE Party_alliance = 'OTHER'
ORDER BY Won DESC;


-- WINNING CANDIDATE'S NAME, THEIR PARTY NAME, TOTAL VOTES, AND
-- THE MARGIN OF VICTORY FOR A SPECIFIC STATE AND CONSTITUENCY NAME?

SELECT *
FROM constituencywise_results;


SELECT 
	CR.Winning_Candidate,
	CR.Constituency_Name,
	CR.Margin,
	CR.Total_Votes,
	PR.Party,
	PR.Party_alliance,
	S.State
FROM 
	constituencywise_results CR INNER JOIN partywise_results PR --table
		ON CR.Party_ID = PR.Party_ID --part
	INNER JOIN statewise_results SR --table
	ON CR.Parliament_Constituency = SR.Parliament_Constituency -- part
	INNER JOIN states S -- table
	ON SR.State_ID = S.State_ID --part
WHERE CR.Constituency_Name = 'AGRA'

-- WHAT IS THE DISTRIBUTION OF EVM VOTES VERSUS POSTAL VOTES FOR CANDIDATES IN A SPECIFIC CONSTITUENCY?
SELECT
	CD.EVM_Votes,
	CD.Postal_Votes,
	CD.Total_Votes,
	CD.Candidate,
	CR.Constituency_Name
FROM constituencywise_results CR INNER JOIN constituencywise_details CD
ON CR.Constituency_ID =CD.Constituency_ID
WHERE Constituency_Name = 'AGRA'

--CHECKING FOR BEED CONSTITUENCY
SELECT
	CD.EVM_Votes,
	CD.Postal_Votes,
	CD.Total_Votes,
	CD.Candidate,
	CR.Constituency_Name
FROM constituencywise_results CR INNER JOIN constituencywise_details CD
ON CR.Constituency_ID =CD.Constituency_ID
WHERE Constituency_Name = 'BEED'

--WHICH PARTY WON THE MOST SEATS IN A STATE, AND HOW MANY SEATS DID EACH PARTY WIN?
SELECT 
	PR.Party,
	COUNT(PR.Won) AS Seats_Won,
	S.State,
	SUM(PR.Won) AS Total_seats
FROM partywise_results PR INNER JOIN constituencywise_results CR
ON PR.Party_ID = CR.Party_ID INNER JOIN statewise_results SR
ON CR.Parliament_Constituency = SR.Parliament_Constituency INNER JOIN states S
ON SR.State_ID = S.State_ID
GROUP BY 
	PR.Party,
	PR.Won,
	S.State
ORDER BY Won DESC;

-- With filter for each state
--WHICH PARTY WON THE MOST SEATS IN A STATE, AND HOW MANY SEATS DID EACH PARTY WIN?
SELECT 
	PR.Party,
	COUNT(PR.Won) AS Seats_Won,
	S.State,
	SUM(PR.Won) AS Total_seats
FROM partywise_results PR INNER JOIN constituencywise_results CR
ON PR.Party_ID = CR.Party_ID INNER JOIN statewise_results SR
ON CR.Parliament_Constituency = SR.Parliament_Constituency INNER JOIN states S
ON SR.State_ID = S.State_ID
where S.State = 'Andhra Pradesh'
GROUP BY 
	PR.Party,
	PR.Won,
	S.State
ORDER BY Won DESC;



-- WHAT IS THE TOTAL NUMBER OF SEATS WON BY EACH PARTY ALLIANCE (NDA, I.N.D.I.A AND OTHERS)
-- IN EACH STATE

SELECT
	Party_alliance,
	COUNT(*) AS Total_seats_Won,
	S.state
FROM 
	partywise_results PR INNER JOIN constituencywise_results CR
	ON CR.Party_ID = PR.Party_ID INNER JOIN statewise_results SR
	ON SR.Parliament_Constituency = CR.Parliament_Constituency INNER JOIN states S
	ON SR.State_ID = S.State_ID
--WHERE S.State = 'Uttar Pradesh'
GROUP BY Party_alliance, S.state
ORDER BY Total_seats_Won 



SELECT
    S.State,
    PR.Party_alliance,
    COUNT(Won) AS Row_Count,
    SUM(CASE WHEN PR.Party_alliance = 'NDA' THEN 1 ELSE 0 END) AS NDA_Seat_won,
    SUM(CASE WHEN PR.Party_alliance = 'I.N.D.I.A' THEN 1 ELSE 0 END) AS INDIA_Seat_won,
    SUM(CASE WHEN PR.Party_alliance = 'OTHER' THEN 1 ELSE 0 END) AS OTHER_Seat_won
FROM 
    constituencywise_results CR
INNER JOIN
    partywise_results PR ON CR.Party_ID = PR.Party_ID
INNER JOIN
    statewise_results SR ON CR.Parliament_Constituency = SR.Parliament_Constituency
INNER JOIN 
    states S ON SR.State_ID = S.State_ID
GROUP BY 
    S.State, PR.Party_alliance
ORDER BY 
    S.State;


--WHICH CANDIDATE RECIEVED THE HIGHEST NUMBER OF EVM VOTES IN EACH CONSTITUENCY (TOP)?
SELECT TOP 10
	CR.Constituency_Name,
	CD.Constituency_ID,
	CD.Candidate,
	CD.EVM_Votes

FROM constituencywise_details CD
INNER JOIN constituencywise_results CR
ON CD.Constituency_ID = CR.Constituency_ID
ORDER BY CD.EVM_Votes DESC;
