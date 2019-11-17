# Velodrome Auction

https://github.com/markcoppa/velodrome-auction.git#velodrome-auction

DB and web interface for MVA auction support.

## Description

This project contains a combined database and very simple web interface.  It is an ongoing project, used to provide support for a local charity auction (auction is for the Jerry Baker Memorial Velodrome aka Marymoor and MVA).  As such, this is a specialized project and not intended to be a general auction support project.

## Requirements

I've been using this with a local machine running Abyss Web Server and sqlite.

## Upgrades

* Provide a way for remote machines to access the formatted reciepts.  This would allow for faster check out by bidders.  Currently everyone has to wait for me to enter all the information into the main machine.
* Clean up how year is specified.  Generalize for any auction.
* Abstract out the HTML elements as resources.

## Use instructions

As stated above, this is a specialized system and not generalized for all auction types.  These use instructions are perforce specialized as well.

Software required:
* Abyss Web Server
* sqlite (just need the .exe, don't need the .dll)
* ActivePerl (download from http://www.activestate.com/Products/ActivePerl)
* Perl libraries needed to format and print PDF.  PDF::API2::Simple and PDF::Table.


Install the files from git to c:\auction\\\<year>\web\ (or location of choice).

### Abyss Server

Default password is password

Server configuration when running is at http://127.0.0.1:9999/

If Abyss Web Server is not running, open the Start menu, choose Programs, then Abyss Web Server and select Abyss Web Server X1.  You can also open the directory where you have installed it and double-click on the abyssws.exe or abyssws icon. 

How to add a page for a new year (replace \<year\> with actual year).  This will add for example http://127.0.0.1/2019/.
* Go to http://127.0.0.1:9999/
* Log in with username, password as configured.
* Hosts --> Configure
* Click Aliases
* Virtual path: /\<year\>/
* Real path: c:\auction\\\<year>\web\
* Restart web server (prompted from web page)

### sqlite

sqlite is a simple database file interface.  It isn't a database server.

* mkdir c:\sqlite3
* copy sqlite3.exe c:\sqlite3
* edit PATH, appending c:\sqlite3
* mkdir c:\auction\\\<year>
* modify c:\aucion\\\<year>\database\create_schema.sql if necessary
* sqlite3 \<year>db.db

Other useful sqlite commands

* .read create_schema.sql --> to DELETE and import the database schema
* .q
* .tables
* .schema

### How to run

Everything is located under c:\auction\\\<year>
Database file is c:\auction\\\<year>\datbase\\\\<year>db.db
Enter it by running "sqlite3 \<year>db.db"
Create a new database by:

* cd c:\auction\<year>\database
* sqlite3 \<year>db.db, where \<year>db.db doesn't exist (or will be overwritten if exists)
* .read create_schema.sql

### Perl

Perl files are placed under c:\auction\\\<year>\web
Start server by Start-->All Programs-->Abyss Web Server-->Abyss WebServer X1
Go to web site by opening browser to http://127.0.0.1/\<year>/main.pl

### Utilities

To import buyers

* Get .CSV file from registration (provided by auction manager)
* Use import_buyers_data.pl to do just that.  Might have to update script to match .csv format, since format changes every year.

To import items

* Get .CSV file from registration
* Use import_items_data.pl to do just that.  Might have to update script to match .csv format.
* Extra carriage returns in the fields are typically a problem.

To print reciepts, use print_receipts.pl.  It will read the database for all buyers and what they have won.  Then it will print nicely formatted .PDF reciepts for all.


