CREATE DATABASE CSGO;
GO 
USE CSGO;
GO
CREATE SCHEMA stats;
GO
CREATE SCHEMA info;
GO
CREATE TABLE stats.cs_stats_raw (
    statname NVARCHAR(50), 
    statvalue int 
) ON [PRIMARY]
GO



DECLARE @json NVARCHAR(MAX);

SELECT @json = BulkColumn
FROM OPENROWSET(BULK 'C:\Users\MartinPlöcker\OneDrive - IUVOPOINT GmbH\Dokumente - Consultants\Training\Martin_CSGO\CSGO_PURE.json', SINGLE_CLOB) as j;


SET @json = SUBSTRING (@json, CHARINDEX ('[', @json), (CHARINDEX (']', @json) - CHARINDEX ('[', @json)+1) ) 


INSERT INTO stats.cs_stats_raw
SELECT statname, statvalue
FROM OPENJSON(@json) WITH (
    statname NVARCHAR(50) '$.name',
    statvalue int '$.value'
    )


--select * from stats.cs_stats_raw;

GO

--Tabellen erstellen

CREATE TABLE [info].[Weapon] (
    WeaponPK INT  IDENTITY(1,1) PRIMARY KEY,
    WeaponName VARCHAR(20) NOT NULL,
    WeaponCategoryFK INT NOT NULL,
    WeaponSpecific bit NULL
) ON [PRIMARY];

CREATE TABLE [info].[WeaponCategory] (
    WeaponCategoryPK INT  IDENTITY(1,1) PRIMARY KEY,
    WeaponCategrory VARCHAR(20) NOT NULL
) ON [PRIMARY];

CREATE TABLE [info].[WeaponTeam] (
    Team VARCHAR(5) NOT NULL,
    TeamValue bit NULL
) ON [PRIMARY];


CREATE TABLE [info].[MapPrefix] (
    MapPrefixPK INT IDENTITY(1,1) PRIMARY KEY,
    MapPrefix VARCHAR(5) NOT NULL,
    MapType VARCHAR(25) NOT NULL
) ON [PRIMARY];

CREATE TABLE [info].[Map] (
    MapPK INT IDENTITY(1,1) PRIMARY KEY,
    MapName VARCHAR(25) NOT NULL,
    MapPrefixFK INT NOT NULL
) ON [PRIMARY];


CREATE TABLE [stats].[Map] (
    MapPK INT NOT NULL PRIMARY KEY,
    Rounds INT NULL,
    Wins INT NULL,
    Losses INT NULL
) ON [PRIMARY];


CREATE TABLE [stats].[Weapon] (
	WeaponPK INT NOT NULL PRIMARY KEY,
	Shots int NULL,
	Hits int NULL,
	Kills int NULL
) ON [PRIMARY];


--Tabellen füllen (Mit von CS vorgegebenen Werten)


INSERT INTO info.Weapon(WeaponName, WeaponCategoryFK, WeaponSpecific)
VALUES 
    ('ak47', 6, 0),
    ('aug', 6, 1),
    ('awp', 7, NULL),
    ('bizon', 5, NULL),
    ('deagle', 2, NULL),
    ('elite', 2, NULL),
    ('famas', 6, 1),
    ('fiveseven', 2, 1),
    ('g3sg1', 7, 0),
    ('galilar', 6, 0),
    ('glock', 2, 0),
    ('hegrenade', 8, NULL),
    ('hkp2000', 2, 1),
    ('knife', 1, NULL),
    ('m249', 4, NULL),
    ('m4a1', 6, 1),
    ('mac10', 5, 0),
    ('mag7', 3, 1),
    ('molotov', 8, NULL),
    ('mp7', 5, NULL),
    ('mp9', 5, 1),
    ('negev', 4, NULL),
    ('nova', 3, NULL),
    ('p250', 2, NULL),
    ('p90', 5, NULL),
    ('sawedoff', 3, 0),
    ('scar20', 7, 1),
    ('sg556', 6, 0),
    ('ssg08', 7, NULL),
    ('taser', 1, NULL),
    ('tec9', 2, 0),
    ('ump45', 5, NULL),
    ('xm1014', 3, NULL);


INSERT INTO info.WeaponCategory  (WeaponCategrory)
VALUES 
    ('Meele'),
    ('Pistols'),
    ('Shotguns'),
    ('Machine Guns'),
    ('SMGs'),
    ('Assault Riffles'),
    ('Sniper Rifles'),
    ('Grenade');
    

INSERT INTO info.WeaponTeam (Team, TeamValue)
VALUES 
    ('T', 0),
    ('CT', 1),
    ('Beide', NULL);



INSERT INTO info.MapPrefix (MapPrefix, MapType)
VALUES 
    ('ar_', 'Arms Race'),
    ('de_', 'Demolition'),
    ('de_', 'Defusal'),
	('cs_', 'Hostage'),
	('gd_', 'Guardian'),
	('coop_', 'Coop'),
    ('dz_', 'Danger Zone');

INSERT INTO info.Map(MapName, MapPrefixFK)
VALUES 
    ('ar_baggage', 1),
    ('ar_monastery', 1),
    ('ar_shoots', 1),
    ('ar_lake', 1),
    ('ar_safehouse', 1),
    ('ar_st. Marc', 1),
    ('ar_lunacy', 1),
    ('de_bank', 2),
    ('de_lake', 2),
    ('de_safehouse', 2),
    ('de_stmarc', 2),
    ('de_shortdust', 2),
    ('de_sugarcane', 2),
    ('de_cache', 3),
    ('de_canals', 3),
    ('de_mirage', 3),
    ('de_overpass', 3),
    ('de_ancient', 3),
    ('de_anubis', 3),
    ('de_cbble', 3),
    ('de_dust2', 3),
    ('de_inferno', 3),
    ('de_nuke', 3),
    ('de_train', 3),
    ('de_vertigo', 3),
    ('cs_italy', 4),
    ('cs_militia', 4),
    ('cs_office', 4),
    ('cs_assault', 4),
    ('cs_agency', 4),
    ('dz_blacksite', 7),
    ('dz_sirocco', 7),
    ('dz_ember', 7),
    ('dz_vineyard', 7);
 
/*
Select * from info.Weapon;
Select * from info.WeaponCategory;
Select * from info.WeaponTeam;
Select * from info.MapPrefix;
Select * from info.Map;
Select * from stats.Map;
Select * from stats.Weapon;
select * from stats.cs_stats_raw;
TRUNCATE table stats.weapon;
*/


-------------------------------------

/*
select  W.WeaponName, R.statvalue from
(select distinct statname, statvalue from stats.cs_stats_raw
where statname like '%total_shots%'
and statname not like '%fired%'
and statname not like '%hit%') as R
right outer join info.Weapon as W
on R.statname like ('%' + W.WeaponName)


select distinct R.statname, R.statvalue from stats.cs_stats_raw as  R
where statname like '%total_kills%'
--and statname not like '%fired%'
--and statname not like '%hit%';
*/

-- Befüllen von stats.Weapon mit den Werten aus cs_stats_raw

insert into stats.Weapon (WeaponPK, Shots, Hits, Kills)
select W.WeaponPK, R.statvalue, Q.statvalue, K.statvalue from

(select distinct statname, statvalue from stats.cs_stats_raw
where statname like '%total_shots%'
and statname not like '%fired%'
and statname not like '%hit%') as R

right join info.Weapon as W
on R.statname like ('%' + W.WeaponName)

left join (select distinct statname, statvalue from stats.cs_stats_raw
where statname like '%total_hits%') as Q 
on Q.statname like ('%' + W.WeaponName)
left join (select distinct statname, statvalue from stats.cs_stats_raw
where statname like '%total_kills%') as K
on K.statname like ('%' + W.WeaponName)

/*
insert into stats.Weapon (Weapon, Hits)
select W.WeaponName, R.statvalue from
(select distinct statname, statvalue from stats.cs_stats_raw
where statname like '%total_hits%') as R
right join info.Weapon as W
on R.statname like ('%' + W.WeaponName + '%')


drop table info.Weapon;
drop table info.WeaponCategory;
drop table info.WeaponTeam;
drop table info.MapPrefix;
drop table info.Map;
drop table stats.Map;
drop table stats.Weapon;
truncate table info.Weapon;

*/

-- Befüllen von stats.Map mit den Werten aus cs_stats_raw

go
insert into stats.Map (MapPK, Rounds, Wins, Losses)

select C.MapPK, A.statvalue, B.statvalue, A.statvalue - B.statvalue from

(select distinct statname, statvalue from stats.cs_stats_raw
where statname like '%total_rounds_map%') as A

right join info.Map as C
on A.statname like ('%' + C.MapName)

left join (select distinct statname, statvalue from stats.cs_stats_raw
where statname like '%total_wins_map%') as B
on B.statname like ('%' + C.MapName)

SELECT * FROM stats.Map;
SELECT * FROM stats.Weapon

--Show me the top 3  maps with the most rounds from stats.map


/*SELECT * FROM stats.Map ORDER BY Rounds DESC

SELECT * FROM stats.Map M
JOIN info.Map P
ON M.MapPK = P.MapPK
ORDER BY Rounds DESC

SELECT * FROM info.Map

Select MapName from info.Map group by MapName having count(MapName) > 1;*/

