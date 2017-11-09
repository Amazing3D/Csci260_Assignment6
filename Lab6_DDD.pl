#!/usr/bin/perl

#Dillon Dall
#dillon.dall@und.edu
#1107601
#program 5
#This perl script is used to interact with a database that contains library books.

use strict;
use DBI;

my ( $mainMenu, $userOption, $title, $author, $copies, $totalCopies, $copiesAvailable, $book, $sql, $libraryID, $dbh, $sth );

################################################################################
# Menu string block
################################################################################
$mainMenu = <<'END_MESSAGE';
Main menu
-----------------------------------------------------------
1) Add a book
2) Display all books
3) Search for a book
4) Check out a book
5) Check in a book
6) exit

Enter an opiton:
END_MESSAGE

################################################################################
# Sql Setup
################################################################################

my $username = "root";
my $password = "password";
my $dsn      = "DBI:mysql:f17db:localhost";
$dbh = DBI->connect( $dsn, $username, $password );

################################################################################
# Subroutines
################################################################################
sub getQuantity {
    my $option = shift;
    my $whereSQL;
    if ( $option == 0 ) { #getQuantity can use either the libraryID or an exact match of the author and title
        $whereSQL = "WHERE title='" . shift . "' AND author='" . shift . "';";
    }
    elsif ( $option == 1 ) {
        $whereSQL = "WHERE libraryID='" . shift . "';";
    }

    $sql = "SELECT libraryID, totalCopies, copiesAvailable FROM library " . $whereSQL; #the quantities we are looking for are the totalCopies and copiesAvailable
    $sth = $dbh->prepare($sql);

    my $recordCount = $sth->execute();
    if ( $recordCount == 0 ) {
        print "\nNo other copies available, adding a new index\n";
        return 0;
    }

    my $hashRef = $sth->fetchrow_hashref();
    my @quantity = ( $hashRef->{'libraryID'}, $hashRef->{'totalCopies'}, $hashRef->{'copiesAvailable'} ); #Return the libraryID, totalCopies, and copiesAvailable

    return \@quantity;
}

sub getInput {
    my $prompt = shift;
    print $prompt;
    chomp( my $value = <STDIN> );
    $value =~ s|\'|\\'|g;
    $value = $` if ( $value =~ /;/ );
    return $value;
}

sub addBook {
    $title  = shift;
    $author = shift;
    $copies = shift;

    $sql = $sql = "INSERT INTO library (title, author, totalCopies, copiesAvailable) VALUES ('" . $title . "', '" . $author . "', '" . $copies . "', '" . $copies . "');";
    # print "\n\n$sql\n\n";

    my $result = $dbh->do($sql);
    if ($result) {
        print "$copies copies of $title by $author were added to the library\n\n";
    }
    else {
        print "Unable to add $copies of $title by $author to the database\n";
    }
}

sub updateBook {
    $libraryID       = shift;
    $copies          = shift;
    $copiesAvailable = shift;

    $sql = "UPDATE library SET totalCopies='" . ($copies) . "', copiesAvailable='" . ($copiesAvailable) . "' WHERE libraryID='" . $libraryID . "';";
    my $result = $dbh->do($sql);
    if ( !$result ) {
        print "Unable to update the book\n\n";
        return 0;
    }
    return 1;
}

sub displayBooks {
    print "\n";
    if ( my $Search = shift ) {
        $sql = "SELECT * FROM library WHERE author LIKE '%" . $Search . "%' OR title LIKE '%" . $Search . "%' ;"; #ORDER BY title;"; #not 100% sure about requirements "Sort by title. No" (separate statements?) if sort by title the commented out part goes at the end
    } #if we are  Searching we will put the search criteria in when calling this Subroutine

    else {
        $sql = "SELECT * FROM library ORDER BY title;"; #if we want to display all the books we won't put anything in while calling this Subroutine
    }

    $sth = $dbh->prepare($sql);
    my $recordCount = $sth->execute();
    if ( int($recordCount) == 0 ) {
        print "No matches Found\n\n";
        return;
    }

    printf "%-5s %-100s %-30s %-10s %-10s\n", "Index", "Title", "Author", "Copies", "Available"; #header
    print "-" x 160 . "\n";                                                                      #bar separating header from info
    my $recordNum = 1;                                                                           #start at index 1 when displaying the books
    my @records;                                                                                 #this is used for when we want to know about the specific books in the list later (this is returned as a reference)

    while ( my $hashRef = $sth->fetchrow_hashref() ) {
        printf "%-5d %-100s %-30s %10d %10d\n", $recordNum, $hashRef->{'title'}, $hashRef->{'author'}, $hashRef->{'totalCopies'}, $hashRef->{'copiesAvailable'};
        $records[$recordNum] = $hashRef;
        $recordNum++;
    }
    print "\n\n";
    return \@records;
}
################################################################################
# Main Loop
################################################################################
print $mainMenu;
chomp( $userOption = <STDIN> );
while ( $userOption != 6 ) {
    ################################################################################
    # Add to library
    ################################################################################
    if ( $userOption == 1 ) {
        $title  = getInput("What is the book title?: ");
        $author = getInput("Who is the author?: ");
        $copies = getInput("How many copies are being added?: ");

        $book = getQuantity( 0, $title, $author );

        if ( $book == 0 ) {
            addBook( $title, $author, $copies );
        }
        else { #$book returns a reference to an array containin the libraryID, totalCopies, and copiesAvailable
            print "\nAdding $copies copies of $title by $author to the library\n\n";
            updateBook( ( $$book[0] ), ( $$book[1] + $copies ), ( $$book[2] + $copies ) );
        }

    }
    ################################################################################
    # Display all books
    ################################################################################
    elsif ( $userOption == 2 ) {
        displayBooks();
    }
    ################################################################################
    # Search for a book
    ################################################################################
    elsif ( $userOption == 3 ) {
        $userOption = getInput("Search (title or author): ");
        displayBooks($userOption);
    }
    ################################################################################
    # Check out a book
    ################################################################################
    elsif ( $userOption == 4 ) {
        my $book = displayBooks();
        $userOption = getInput( "What book do you want to check out? [1-" . ( int(@$book) - 1 ) . "]: " ); # -1 because of the unused index

        my $available = getQuantity( 1, ( $$book[$userOption]->{'libraryID'} ) );                          #get the number of copies Available

        if ( $$available[2] > 0 ) {                                                                        #if all the copies are checked out you cannot check out the book
            if ( updateBook( $$available[0], $$available[1], ( $$available[2] - 1 ) ) ) {
                print "\n" . $$book[$userOption]->{'title'} . " Successfully Checked Out\n\n";
            }
        }
        else {
            print "\nYou cannot check out " . $$book[$userOption]->{'title'} . ". There no copies available.\n\n";
        }
    }
    ################################################################################
    # Check in a book
    ################################################################################
    elsif ( $userOption == 5 ) {
        my $book = displayBooks(); #gets an array reference of hash references
        $userOption = getInput( "What book do you want to check in? [1-" . ( int(@$book) - 1 ) . "]: " ); # -1 because of the unused index

        my $available = getQuantity( 1, ( $$book[$userOption]->{'libraryID'} ) );                         #get the copies Available # $$book[$userOption]->{'libraryID'} is the libraryid of the selected book

        if ( $$available[2] < $$available[1] ) {                                                          # if all the books are checked in you cannot check in another
            print "\n" . $$book[$userOption]->{'title'} . " Successfully Checked in\n\n";
            updateBook( $$available[0], $$available[1], ( $$available[2] + 1 ) );
        }
        else {
            print "\nYou cannot check in " . $$book[$userOption]->{'title'} . ". The book hasn't been checked out.\n\n";
        }
    }
    print $mainMenu;
    chomp( $userOption = <STDIN> );
}
