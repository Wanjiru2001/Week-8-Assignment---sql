-- Library Management System Database
-- Drop database if exists (for clean setup)
DROP DATABASE IF EXISTS library_management;
CREATE DATABASE library_management;
USE library_management;

-- 1. Categories Table
CREATE TABLE categories (
    category_id INT PRIMARY KEY AUTO_INCREMENT,
    category_name VARCHAR(100) NOT NULL UNIQUE,
    description TEXT,
    created_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 2. Authors Table
CREATE TABLE authors (
    author_id INT PRIMARY KEY AUTO_INCREMENT,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    birth_date DATE,
    nationality VARCHAR(50),
    biography TEXT,
    created_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE KEY unique_author (first_name, last_name, birth_date)
);

-- 3. Publishers Table
CREATE TABLE publishers (
    publisher_id INT PRIMARY KEY AUTO_INCREMENT,
    publisher_name VARCHAR(100) NOT NULL UNIQUE,
    address TEXT,
    phone VARCHAR(20),
    email VARCHAR(100),
    website VARCHAR(200),
    created_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 4. Books Table
CREATE TABLE books (
    book_id INT PRIMARY KEY AUTO_INCREMENT,
    isbn VARCHAR(13) UNIQUE,
    title VARCHAR(200) NOT NULL,
    category_id INT NOT NULL,
    publisher_id INT,
    publication_year YEAR,
    pages INT CHECK (pages > 0),
    language VARCHAR(50) DEFAULT 'English',
    description TEXT,
    total_copies INT NOT NULL DEFAULT 1 CHECK (total_copies > 0),
    available_copies INT NOT NULL DEFAULT 1 CHECK (available_copies >= 0),
    location_shelf VARCHAR(20),
    price DECIMAL(8,2) CHECK (price >= 0),
    created_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE 
CURRENT_TIMESTAMP,
    FOREIGN KEY (category_id) REFERENCES categories(category_id) ON DELETE 
RESTRICT,
    FOREIGN KEY (publisher_id) REFERENCES publishers(publisher_id) ON 
DELETE SET NULL,
    CHECK (available_copies <= total_copies)
);

-- 5. Book-Author Junction Table (Many-to-Many relationship)
CREATE TABLE book_authors (
    book_id INT,
    author_id INT,
    role ENUM('Author', 'Co-Author', 'Editor', 'Translator') DEFAULT 
'Author',
    PRIMARY KEY (book_id, author_id),
    FOREIGN KEY (book_id) REFERENCES books(book_id) ON DELETE CASCADE,
    FOREIGN KEY (author_id) REFERENCES authors(author_id) ON DELETE 
CASCADE
);

-- 6. Member Types Table
CREATE TABLE member_types (
    type_id INT PRIMARY KEY AUTO_INCREMENT,
    type_name VARCHAR(50) NOT NULL UNIQUE,
    max_books_allowed INT NOT NULL DEFAULT 3 CHECK (max_books_allowed > 
0),
    loan_duration_days INT NOT NULL DEFAULT 14 CHECK (loan_duration_days > 
0),
    fine_per_day DECIMAL(5,2) NOT NULL DEFAULT 0.50 CHECK (fine_per_day >= 
0),
    membership_fee DECIMAL(6,2) DEFAULT 0.00 CHECK (membership_fee >= 0)
);

-- 7. Members Table
CREATE TABLE members (
    member_id INT PRIMARY KEY AUTO_INCREMENT,
    member_number VARCHAR(20) NOT NULL UNIQUE,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    email VARCHAR(100) UNIQUE,
    phone VARCHAR(20),
    address TEXT,
    date_of_birth DATE,
    type_id INT NOT NULL,
    registration_date DATE NOT NULL DEFAULT (CURRENT_DATE),
    membership_expiry DATE NOT NULL,
    status ENUM('Active', 'Inactive', 'Suspended', 'Expired') DEFAULT 
'Active',
    created_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE 
CURRENT_TIMESTAMP,
    FOREIGN KEY (type_id) REFERENCES member_types(type_id) ON DELETE 
RESTRICT,
    CHECK (membership_expiry > registration_date),
    CHECK (date_of_birth < CURRENT_DATE)
);

-- 8. Staff Roles Table
CREATE TABLE staff_roles (
    role_id INT PRIMARY KEY AUTO_INCREMENT,
    role_name VARCHAR(50) NOT NULL UNIQUE,
    description TEXT,
    permissions TEXT
);

-- 9. Staff Table
CREATE TABLE staff (
    staff_id INT PRIMARY KEY AUTO_INCREMENT,
    employee_id VARCHAR(20) NOT NULL UNIQUE,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    email VARCHAR(100) NOT NULL UNIQUE,
    phone VARCHAR(20),
    role_id INT NOT NULL,
    hire_date DATE NOT NULL,
    salary DECIMAL(10,2) CHECK (salary > 0),
    status ENUM('Active', 'Inactive', 'On Leave') DEFAULT 'Active',
    created_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE 
CURRENT_TIMESTAMP,
    FOREIGN KEY (role_id) REFERENCES staff_roles(role_id) ON DELETE 
RESTRICT
);

-- 10. Borrowing Transactions Table
CREATE TABLE borrowings (
    borrowing_id INT PRIMARY KEY AUTO_INCREMENT,
    member_id INT NOT NULL,
    book_id INT NOT NULL,
    staff_id INT NOT NULL,
    borrow_date DATE NOT NULL DEFAULT (CURRENT_DATE),
    due_date DATE NOT NULL,
    return_date DATE NULL,
    status ENUM('Borrowed', 'Returned', 'Overdue', 'Lost') DEFAULT 
'Borrowed',
    renewal_count INT DEFAULT 0 CHECK (renewal_count >= 0),
    notes TEXT,
    created_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE 
CURRENT_TIMESTAMP,
    FOREIGN KEY (member_id) REFERENCES members(member_id) ON DELETE 
RESTRICT,
    FOREIGN KEY (book_id) REFERENCES books(book_id) ON DELETE RESTRICT,
    FOREIGN KEY (staff_id) REFERENCES staff(staff_id) ON DELETE RESTRICT,
    CHECK (due_date > borrow_date),
    CHECK (return_date IS NULL OR return_date >= borrow_date)
);

-- 11. Reservations Table
CREATE TABLE reservations (
    reservation_id INT PRIMARY KEY AUTO_INCREMENT,
    member_id INT NOT NULL,
    book_id INT NOT NULL,
    reservation_date DATE NOT NULL DEFAULT (CURRENT_DATE),
    expiry_date DATE NOT NULL,
    status ENUM('Active', 'Fulfilled', 'Cancelled', 'Expired') DEFAULT 
'Active',
    priority_number INT,
    notification_sent BOOLEAN DEFAULT FALSE,
    created_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE 
CURRENT_TIMESTAMP,
    FOREIGN KEY (member_id) REFERENCES members(member_id) ON DELETE 
CASCADE,
    FOREIGN KEY (book_id) REFERENCES books(book_id) ON DELETE CASCADE,
    UNIQUE KEY unique_active_reservation (member_id, book_id, status),
    CHECK (expiry_date > reservation_date)
);

-- 12. Fines Table
CREATE TABLE fines (
    fine_id INT PRIMARY KEY AUTO_INCREMENT,
    borrowing_id INT NOT NULL,
    member_id INT NOT NULL,
    fine_amount DECIMAL(8,2) NOT NULL CHECK (fine_amount > 0),
    fine_reason ENUM('Overdue', 'Lost Book', 'Damaged Book', 'Other') NOT 
NULL,
    fine_date DATE NOT NULL DEFAULT (CURRENT_DATE),
    payment_date DATE NULL,
    payment_amount DECIMAL(8,2) DEFAULT 0.00 CHECK (payment_amount >= 0),
    status ENUM('Pending', 'Paid', 'Waived', 'Partial') DEFAULT 'Pending',
    waived_by INT NULL,
    notes TEXT,
    created_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE 
CURRENT_TIMESTAMP,
    FOREIGN KEY (borrowing_id) REFERENCES borrowings(borrowing_id) ON 
DELETE RESTRICT,
    FOREIGN KEY (member_id) REFERENCES members(member_id) ON DELETE 
RESTRICT,
    FOREIGN KEY (waived_by) REFERENCES staff(staff_id) ON DELETE SET NULL,
    CHECK (payment_date IS NULL OR payment_date >= fine_date),
    CHECK (payment_amount <= fine_amount)
);

-- 13. Book Reviews Table (Optional feature)
CREATE TABLE book_reviews (
    review_id INT PRIMARY KEY AUTO_INCREMENT,
    book_id INT NOT NULL,
    member_id INT NOT NULL,
    rating INT CHECK (rating BETWEEN 1 AND 5),
    review_text TEXT,
    review_date DATE NOT NULL DEFAULT (CURRENT_DATE),
    is_approved BOOLEAN DEFAULT FALSE,
    approved_by INT NULL,
    created_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (book_id) REFERENCES books(book_id) ON DELETE CASCADE,
    FOREIGN KEY (member_id) REFERENCES members(member_id) ON DELETE 
CASCADE,
    FOREIGN KEY (approved_by) REFERENCES staff(staff_id) ON DELETE SET 
NULL,
    UNIQUE KEY unique_member_book_review (member_id, book_id)
);

-- Create Indexes for Better Performance
CREATE INDEX idx_books_title ON books(title);
CREATE INDEX idx_books_isbn ON books(isbn);
CREATE INDEX idx_books_category ON books(category_id);
CREATE INDEX idx_members_number ON members(member_number);
CREATE INDEX idx_members_email ON members(email);
CREATE INDEX idx_members_status ON members(status);
CREATE INDEX idx_borrowings_member ON borrowings(member_id);
CREATE INDEX idx_borrowings_book ON borrowings(book_id);
CREATE INDEX idx_borrowings_status ON borrowings(status);
CREATE INDEX idx_borrowings_due_date ON borrowings(due_date);
CREATE INDEX idx_reservations_member ON reservations(member_id);
CREATE INDEX idx_reservations_book ON reservations(book_id);
CREATE INDEX idx_reservations_status ON reservations(status);
CREATE INDEX idx_fines_member ON fines(member_id);
CREATE INDEX idx_fines_status ON fines(status);
CREATE INDEX idx_authors_name ON authors(last_name, first_name);

-- Create Views for Common Queries
CREATE VIEW available_books AS
SELECT 
    b.book_id,
    b.isbn,
    b.title,
    c.category_name,
    p.publisher_name,
    b.available_copies,
    b.total_copies,
    GROUP_CONCAT(CONCAT(a.first_name, ' ', a.last_name) SEPARATOR ', ') as 
authors
FROM books b
JOIN categories c ON b.category_id = c.category_id
LEFT JOIN publishers p ON b.publisher_id = p.publisher_id
LEFT JOIN book_authors ba ON b.book_id = ba.book_id
LEFT JOIN authors a ON ba.author_id = a.author_id
WHERE b.available_copies > 0
GROUP BY b.book_id, b.isbn, b.title, c.category_name, p.publisher_name, 
b.available_copies, b.total_copies;

CREATE VIEW overdue_books AS
SELECT 
    br.borrowing_id,
    m.member_number,
    CONCAT(m.first_name, ' ', m.last_name) as member_name,
    b.title,
    br.borrow_date,
    br.due_date,
    DATEDIFF(CURRENT_DATE, br.due_date) as days_overdue
FROM borrowings br
JOIN members m ON br.member_id = m.member_id
JOIN books b ON br.book_id = b.book_id
WHERE br.status = 'Borrowed' 
AND br.due_date < CURRENT_DATE;

CREATE VIEW member_borrowing_summary AS
SELECT 
    m.member_id,
    m.member_number,
    CONCAT(m.first_name, ' ', m.last_name) as member_name,
    COUNT(br.borrowing_id) as total_borrowed,
    SUM(CASE WHEN br.status = 'Borrowed' THEN 1 ELSE 0 END) as 
currently_borrowed,
    SUM(CASE WHEN br.status = 'Overdue' THEN 1 ELSE 0 END) as 
overdue_count,
    COALESCE(SUM(f.fine_amount - f.payment_amount), 0) as 
outstanding_fines
FROM members m
LEFT JOIN borrowings br ON m.member_id = br.member_id
LEFT JOIN fines f ON m.member_id = f.member_id AND f.status != 'Paid'
WHERE m.status = 'Active'
GROUP BY m.member_id, m.member_number, m.first_name, m.last_name;
