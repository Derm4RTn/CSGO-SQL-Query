# Retrieve your in-game stats via a Steam Web API request and use them in your own projects.

## What is it?
This is an SQL query that takes the JSON file of your ingame data and makes it nice and usable for further use.
The data provided in this JSON is hard to use because it is all in one column. This query turns it into a nice and organized database.

## Why do this?
We wanted to play with our ingame data in Power BI.
We could not use the data as it is provided by the web API, so we put some work into a query that makes the data easy to use.

## How?
- [not part of our project]: Get your CSGO data as JSON via a Web API query. 
    https://developer.valvesoftware.com/wiki/Steam_Web_API#GetUserStatsForGame_.28v0002.29
    https://steamcommunity.com/discussions/forum/1/5077247524960444296/

- Download or copy the query.

- Change the document location to your document

- Run the query in Azure Data Studio or SSMS to transform the JSON into a usable database.

- [not part of our project]: Use the database for the project of your choice.

- Be thankful for what you have and enjoy a cup of coffee!
