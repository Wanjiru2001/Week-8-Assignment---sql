Library Management System Database
A comprehensive MySQL database system for managing library operations including books, members, staff, borrowing transactions, reservations, and fines.
Table of Contents

Overview
Database Schema
Installation
Database Structure
Key Features
Usage Examples
Views and Reports
Business Rules
Sample Data
Maintenance

Overview
This Library Management System is designed to handle all core library operations for a modern public or academic library. The system manages books with multiple authors, member accounts with different privileges, staff roles, borrowing transactions, reservations, and fine calculations.
Database Schema
The database consists of 13 main tables with proper relationships:
Categories (1) ←→ (M) Books (M) ←→ (M) Authors
Publishers (1) ←→ (M) Books
MemberTypes (1) ←→ (M) Members
StaffRoles (1) ←→ (M) Staff
Members (1) ←→ (M) Borrowings (M) ←→ (1) Books
Members (1) ←→ (M) Reservations (M) ←→ (1) Books
Members (1) ←→ (M) Fines
Staff (1) ←→ (M) Borrowings
Installation
Prerequisites

MySQL 8.0 or higher
MySQL client or MySQL Workbench

Setup Instructions

Create the Database:
bashmysql -u root -p < library_management.sql

Verify Installation:
sqlUSE library_management;
SHOW TABLES;

Check Table Structure:
sqlDESCRIBE books;
DESCRIBE members;


Database Structure
Core Tables
Books Management

categories: Book categories (Fiction, Science, History, etc.)
authors: Author information with biographical data
publishers: Publisher details and contact information
books: Main book catalog with inventory tracking
book_authors: Many-to-many relationship between books and authors

Member Management

member_types: Different membership levels (Student, Adult, Senior, etc.)
members: Library member accounts and profiles

Staff Management

staff_roles: Staff positions (Librarian, Assistant, Manager, etc.)
staff: Employee records and authentication

Transaction Management

borrowings: Book checkout and return transactions
reservations: Book reservation system with priority queue
fines: Overdue and damage penalties
book_reviews: Member book ratings and reviews

Key Features
Data Integrity

Foreign Key Constraints: Maintain referential integrity
Check Constraints: Validate data ranges and logic
Unique Constraints: Prevent duplicate records
Cascading Actions: Handle related record updates/deletions

Business Logic

Inventory Tracking: Automatic available copy management
Member Limits: Enforce borrowing limits by member type
Fine Calculations: Automatic overdue fine computation
Reservation Queue: Priority-based book reservations
Renewal System: Track and limit book renewals

Performance Optimization

Indexes: Strategic indexing on frequently queried columns
Views: Pre-built queries for common reports
Partitioning Ready: Structure supports future partitioning

Usage Examples
Basic Operations
Add a New Book:
sql-- Insert publisher
INSERT INTO publishers (publisher_name, address) 
VALUES ('Penguin Random House', '123 Publishing St, NY');

-- Insert category
INSERT INTO categories (category_name, description) 
VALUES ('Fiction', 'Literary and commercial fiction');

-- Insert author
INSERT INTO authors (first_name, last_name, nationality) 
VALUES ('George', 'Orwell', 'British');

-- Insert book
INSERT INTO books (isbn, title, category_id, publisher_id, total_copies, available_copies, location_shelf) 
VALUES ('9780451524935', '1984', 1, 1, 5, 5, 'A-101');

-- Link book to author
INSERT INTO book_authors (book_id, author_id, role) 
VALUES (1, 1, 'Author');
Register a New Member:
sql-- Add member type
INSERT INTO member_types (type_name, max_books_allowed, loan_duration_days, fine_per_day) 
VALUES ('Adult', 5, 21, 0.50);

-- Register member
INSERT INTO members (member_number, first_name, last_name, email, phone, type_id, membership_expiry) 
VALUES ('LIB001', 'John', 'Doe', 'john.doe@email.com', '555-1234', 1, '2025-12-31');
Process Book Borrowing:
sql-- Check out a book
INSERT INTO borrowings (member_id, book_id, staff_id, due_date) 
VALUES (1, 1, 1, DATE_ADD(CURRENT_DATE, INTERVAL 21 DAY));

-- Update available copies
UPDATE books SET available_copies = available_copies - 1 WHERE book_id = 1;
Return a Book:
sql-- Mark as returned
UPDATE borrowings 
SET status = 'Returned', return_date = CURRENT_DATE 
WHERE borrowing_id = 1;

-- Update available copies
UPDATE books SET available_copies = available_copies + 1 WHERE book_id = 1;
Advanced Queries
Find Overdue Books:
sqlSELECT * FROM overdue_books;
Check Member Borrowing History:
sqlSELECT 
    b.title,
    br.borrow_date,
    br.due_date,
    br.return_date,
    br.status
FROM borrowings br
JOIN books b ON br.book_id = b.book_id
WHERE br.member_id = 1
ORDER BY br.borrow_date DESC;
Search Books by Author:
sqlSELECT 
    b.title,
    b.isbn,
    CONCAT(a.first_name, ' ', a.last_name) as author,
    c.category_name,
    b.available_copies
FROM books b
JOIN book_authors ba ON b.book_id = ba.book_id
JOIN authors a ON ba.author_id = a.author_id
JOIN categories c ON b.category_id = c.category_id
WHERE a.last_name LIKE 'Orwell%';
Views and Reports
Pre-built Views

available_books: Shows all books currently available for borrowing
overdue_books: Lists all overdue items with days overdue
member_borrowing_summary: Member statistics and outstanding fines

Common Reports
Monthly Circulation Report:
sqlSELECT 
    DATE_FORMAT(borrow_date, '%Y-%m') as month,
    COUNT(*) as books_borrowed,
    COUNT(DISTINCT member_id) as active_members
FROM borrowings 
WHERE borrow_date >= DATE_SUB(CURRENT_DATE, INTERVAL 12 MONTH)
GROUP BY DATE_FORMAT(borrow_date, '%Y-%m')
ORDER BY month;
Popular Books Report:
sqlSELECT 
    b.title,
    COUNT(br.borrowing_id) as borrow_count,
    AVG(COALESCE(rv.rating, 0)) as avg_rating
FROM books b
LEFT JOIN borrowings br ON b.book_id = br.book_id
LEFT JOIN book_reviews rv ON b.book_id = rv.book_id
GROUP BY b.book_id, b.title
ORDER BY borrow_count DESC
LIMIT 10;
Business Rules
Borrowing Rules

Members can only borrow up to their type's limit
Books must be available (available_copies > 0)
Members with overdue books or unpaid fines may be restricted
Renewals are limited and extend the due date

Reservation Rules

Members can reserve unavailable books
Reservations expire after a set period
Priority is first-come-first-served unless specified otherwise
Members are notified when reserved books become available

Fine Rules

Fines are calculated daily for overdue books
Different member types have different fine rates
Fines can be waived by authorized staff
Lost books incur replacement costs

Sample Data
Here's a script to populate the database with sample data:
sql-- Sample data insertion
INSERT INTO member_types VALUES 
(1, 'Student', 3, 14, 0.25, 10.00),
(2, 'Adult', 5, 21, 0.50, 25.00),
(3, 'Senior', 5, 28, 0.25, 15.00);

INSERT INTO categories VALUES 
(1, 'Fiction', 'Literary and commercial fiction'),
(2, 'Science', 'Scientific literature and textbooks'),
(3, 'History', 'Historical accounts and biographies');

INSERT INTO staff_roles VALUES 
(1, 'Librarian', 'Main library operations'),
(2, 'Assistant', 'Support library operations'),
(3, 'Manager', 'Library administration');

-- Add more sample data as needed...
Maintenance
Regular Maintenance Tasks
Update Overdue Status:
sqlUPDATE borrowings 
SET status = 'Overdue' 
WHERE status = 'Borrowed' 
AND due_date < CURRENT_DATE;
Calculate Overdue Fines:
sqlINSERT INTO fines (borrowing_id, member_id, fine_amount, fine_reason)
SELECT 
    br.borrowing_id,
    br.member_id,
    DATEDIFF(CURRENT_DATE, br.due_date) * mt.fine_per_day,
    'Overdue'
FROM borrowings br
JOIN members m ON br.member_id = m.member_id
JOIN member_types mt ON m.type_id = mt.type_id
WHERE br.status = 'Overdue'
AND NOT EXISTS (
    SELECT 1 FROM fines f 
    WHERE f.borrowing_id = br.borrowing_id 
    AND f.fine_reason = 'Overdue'
);
Archive Old Records:
sql-- Archive completed borrowings older than 2 years
CREATE TABLE borrowings_archive LIKE borrowings;
INSERT INTO borrowings_archive 
SELECT * FROM borrowings 
WHERE status = 'Returned' 
AND return_date < DATE_SUB(CURRENT_DATE, INTERVAL 2 YEAR);
Backup Strategy

Daily Backups: Transaction tables (borrowings, reservations, fines)
Weekly Backups: Complete database backup
Monthly Backups: Archive and compress old backups

bash# Daily backup
mysqldump library_management borrowings reservations fines > daily_backup_$(date +%Y%m%d).sql

# Weekly full backup
mysqldump library_management > weekly_backup_$(date +%Y%m%d).sql
Security Considerations

Use appropriate user privileges for different system components
Implement application-level authentication
Regular security audits of user access
Encrypt sensitive data in production environments
Implement proper backup encryption

License
This database schema is provided as-is for educational and commercial use. Please ensure compliance with your local data protection regulations when implementing with real user data.
