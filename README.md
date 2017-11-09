
# Program 6

## Due data 11/13/17

## Objective
- Work with databases
- Restoring a database from a backup file

## Assignment
Download the sql file from Blackboard. This will be used to create the database.
Restore the database using MySQL Workbench as demonstrated in class.
Write a program to add allow the user to work with the library database. The program
should be able to add records, display all the books, search for a book by either author
or title, check out a book or check in a book.
To simplify the testing process use a menu to ask the user what action they wish to do.
PLEASE use the following numbers for each action; again, this will help with the testing
process.
1. Add a book. Ask for the author, title, and total copies
2. Display all books. Show all relevant information for each book in neatly formatted
columns. Sort by title.
3. Search for a book. Ask for the search criteria. The results displayed should
include books with a match (partial, not complete) to either the author or title.
Show all relevant information for each book in neatly formatted columns. Sort by
title. No
4. Check out a book. Show all the books. Ask for an index number, 1 through the
number of books. The index numbers will be used to “hide” the libraryID number
from the user.Don’t allow the user to check out a book that isn’t available.
5. Check in a book. Show all the books. Ask for an index number, 1 through the
number of books. The index numbers will be used to “hide” the libraryID number
from the user. Don’t allow the user to check in a book that isn’t checked out.

The specifics of the tables are as follows:
```
Database:
Table: library
Fields (and in order but that shouldn’t matter):
libraryID – autoincrement integer
author – text – maximum 100 characters
title – text – maximum 100 characters
totalCopies – integer
copiesAvailable – integer
```
## If you missed the in-class demonstration here are the steps needed to create the database.
Within the image, go to Blackboard and save the f17db_library.sql file. Then run the
MySQL Workbench program. If required the login is root and the password is password.
Once you start the program, click on Data Import/Restore. Click on ‘Import from Selfcontained
File’ and select the folder where you saved the sql files, I put them on the
Desktop just to make it easy to find. Select f17db_library and click on Ok and then Start
Import. To confirm it worked, click on Schemas at the bottom of the menu to the left.
Click on the refresh icon, and should see f17db (the name of the database, don’t
confuse it with the name of the sql file) along with the previously installed databases.
