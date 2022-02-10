-- phpMyAdmin SQL Dump
-- version 4.9.2
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Generation Time: Feb 09, 2022 at 05:34 PM
-- Server version: 10.4.10-MariaDB
-- PHP Version: 7.3.12

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
SET AUTOCOMMIT = 0;
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `crud_app`
--

DELIMITER $$
--
-- Procedures
--
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp-add_book` (IN `_title` VARCHAR(100), IN `_isbn` VARCHAR(100), IN `_author` VARCHAR(100), IN `_publisher` VARCHAR(100), IN `_year_published` VARCHAR(100), IN `_category` VARCHAR(100))  BEGIN

    # check for duplicate book
    SELECT title INTO @is_duplicate_book FROM book_tbl 
    WHERE UPPER(CONCAT(TRIM(title),TRIM(isbn),TRIM(author),TRIM(publisher),TRIM(year_published),TRIM(category))) = UPPER(CONCAT(TRIM(_title),TRIM(_isbn),TRIM(_author),TRIM(_publisher),TRIM(_year_published),TRIM(_category))) LIMIT 1;

    IF(@is_duplicate_book IS NOT NULL) THEN
        SELECT
            @is_duplicate_book as 'is_duplicate_book'
        ;
    ELSE 
        INSERT INTO book_tbl (
            title,
			isbn,
			author,
			publisher,
			year_published,
			category,
            status,
            added_date
        )
        VALUES (
			_title,
			_isbn,
			_author,
			_publisher,
			_year_published,
			_category,
            1,
            now()
        );

    END IF;

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp-delete_book` (IN `_tbl_id` INT(11))  BEGIN
	
    #instead of delete i used status
    UPDATE book_tbl SET 
		status = 0
	WHERE tbl_id = _tbl_id;

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp-get_all_books_filterable` (IN `_limit_offset` INT(11), IN `_search_string` VARCHAR(255), IN `_sort_direction` ENUM('asc','desc'), IN `_sort_by` VARCHAR(255), OUT `_total_count` INT(11))  BEGIN
	DECLARE search_string VARCHAR(255);
    
    SET search_string = CASE WHEN _search_string = '' THEN NULL ELSE TRIM(Replace(Replace(Replace(_search_string,'\t',''),'\n',''),'\r','')) END;
    
	SELECT SQL_CALC_FOUND_ROWS
	  *
	FROM book_tbl
	WHERE 
		CASE WHEN search_string IS NULL THEN
			1 = 1
		ELSE
			CONCAT(title,isbn,author,publisher,year_published,category) LIKE CONCAT('%',search_string,'%')
		END
        AND status = 1
    ORDER BY
      CASE WHEN _sort_direction = 'asc'
        THEN
          CASE _sort_by
			  WHEN 'tbl_id' THEN tbl_id
			  WHEN 'title' THEN title
			  WHEN 'isbn' THEN isbn
			  WHEN 'author' THEN author
			  WHEN 'publisher' THEN publisher
			  WHEN 'year_published' THEN year_published
			  WHEN 'category' THEN category
          END
      END ASC,
      CASE WHEN _sort_direction = 'desc'
        THEN
          CASE _sort_by
			  WHEN 'tbl_id' THEN tbl_id
			  WHEN 'title' THEN title
			  WHEN 'isbn' THEN isbn
			  WHEN 'author' THEN author
			  WHEN 'publisher' THEN publisher
			  WHEN 'year_published' THEN year_published
			  WHEN 'category' THEN category

          END
      END DESC
	LIMIT 10 OFFSET _limit_offset;
    
    SET _total_count = FOUND_ROWS();

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp-get_book` (IN `_search_string` VARCHAR(255))  BEGIN
	DECLARE search_string VARCHAR(255);
    
    SET search_string = CASE WHEN _search_string = '' THEN NULL ELSE TRIM(Replace(Replace(Replace(_search_string,'\t',''),'\n',''),'\r','')) END;
    
	SELECT 
		title,isbn,author,publisher,year_published,category
	FROM
		book_tbl
	WHERE
		CONCAT(title,
				isbn,
				author,
				publisher,
				year_published,
				category) LIKE CONCAT('%', search_string, '%')
			AND status = 1;
    
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp-get_book_details` (IN `_tbl_id` INT(11))  BEGIN
	
    SELECT 
		title,
        isbn,
        author,
        publisher,
        year_published,
        category
	FROM book_tbl WHERE tbl_id = _tbl_id LIMIT 1;
    
    
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp-get_book_new_old` (IN `_type` VARCHAR(25))  BEGIN
	
    CASE _type
        WHEN 'new' THEN
            SELECT 
				title,isbn,author,publisher,year_published,category
			FROM book_tbl
		WHERE year_published = year(curdate()) AND status = 1;
        
        WHEN 'old' THEN
            SELECT 
				title,isbn,author,publisher,year_published,category
			FROM book_tbl
		WHERE year_published < year(curdate()) AND status = 1;
    END CASE;
    

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp-update_book` (IN `_tbl_id` INT, IN `_title` VARCHAR(100), IN `_isbn` VARCHAR(100), IN `_author` VARCHAR(100), IN `_publisher` VARCHAR(100), IN `_year_published` VARCHAR(100), IN `_category` VARCHAR(100))  BEGIN

    # check for duplicate book before update
    SELECT title INTO @is_duplicate_book FROM book_tbl 
    WHERE UPPER(CONCAT(TRIM(title),TRIM(isbn),TRIM(author),TRIM(publisher),TRIM(year_published),TRIM(category))) = UPPER(CONCAT(TRIM(_title),TRIM(_isbn),TRIM(_author),TRIM(_publisher),TRIM(_year_published),TRIM(_category)))
	AND tbl_id != _tbl_id LIMIT 1; 


    IF(@is_duplicate_book IS NOT NULL) THEN
        SELECT
            @is_duplicate_book as 'is_duplicate_book'
        ;
    ELSE 
        
        UPDATE book_tbl
			SET
				title = _title,
				isbn = _isbn,
				author = _author,
				publisher = _publisher,
				year_published = _year_published,
				category = _category,
				last_update_date = NOW()
			WHERE tbl_id = _tbl_id;

    END IF;

END$$

DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `book_tbl`
--

CREATE TABLE `book_tbl` (
  `tbl_id` int(11) NOT NULL,
  `title` varchar(100) DEFAULT NULL,
  `isbn` varchar(100) DEFAULT NULL,
  `author` varchar(100) DEFAULT NULL,
  `publisher` text DEFAULT NULL,
  `year_published` varchar(20) DEFAULT NULL,
  `category` varchar(100) DEFAULT NULL,
  `status` int(1) DEFAULT NULL COMMENT '0 = deleted, 1 = active',
  `added_date` datetime DEFAULT NULL,
  `last_update_date` datetime DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Dumping data for table `book_tbl`
--

INSERT INTO `book_tbl` (`tbl_id`, `title`, `isbn`, `author`, `publisher`, `year_published`, `category`, `status`, `added_date`, `last_update_date`) VALUES
(1, 'After Many a Summer Dies the Swan', '1-4028-9462-7', 'Aldous Huxley', 'test pub', '2022', 'test cat', 1, '2022-02-09 22:32:11', NULL),
(2, 'Ah, Wilderness!', '1-4028-9462-7', 'Eugene O\'Neill', 'test pub', '2022', 'test cat', 1, '2022-02-09 22:32:11', NULL),
(3, 'Alien Corn (play)', '1-4028-9462-7', 'Sidney Howard', 'test pub', '2022', 'test cat', 1, '2022-02-09 22:32:11', NULL),
(4, '\"The Alien Corn\" (short story)', '1-4028-9462-7', 'W. Somerset Maugham', 'test pub', '2022', 'test cat', 1, '2022-02-09 22:32:11', NULL),
(5, 'All Passion Spent', '1-4028-9462-7', 'Vita Sackville-West', 'test pub', '2022', 'test cat', 1, '2022-02-09 22:32:11', NULL),
(6, 'All the King\'s Men', '1-4028-9462-7', 'Robert Penn Warren', 'test pub', '2022', 'test cat', 1, '2022-02-09 22:32:11', NULL),
(7, 'Alone on a Wide, Wide Sea', '1-4028-9462-7', 'Michael Morpurgo', 'test pub', '2022', 'test cat', 1, '2022-02-09 22:32:11', NULL),
(8, 'An Acceptable Time', '1-4028-9462-7', 'Madeleine L Engle', 'test pub', '2021', 'test cat', 1, '2022-02-09 22:32:11', NULL),
(9, 'Antic Hay', '1-4028-9462-7', 'Aldous Huxley', 'test pub', '2021', 'test cat2', 1, '2022-02-09 22:32:11', NULL),
(10, 'Arms and the Man', '1-4028-9462-7', 'George Bernard Shaw', 'test pub', '2021', 'test cat2', 1, '2022-02-09 22:32:11', NULL),
(11, 'As I Lay Dying', '1-4028-9462-7', 'William Faulkner', 'test pub', '2021', 'test cat2', 1, '2022-02-09 22:32:11', NULL),
(12, 'Behold the Man', '1-4028-9462-7', 'Michael Moorcock', 'test pub', '2021', 'test cat2', 1, '2022-02-09 22:32:11', NULL),
(13, 'Beneath the Bleeding', '1-4028-9462-7', 'Val McDermid', 'test pub', '2020', 'test cat2', 1, '2022-02-09 22:32:11', NULL),
(14, 'Beyond the Mexique Bay', '1-4028-9462-7', 'Aldous Huxley', 'test pub', '2020', 'test cat2', 1, '2022-02-09 22:32:11', NULL),
(15, 'Blithe Spirit', '1-4028-9462-7', 'Noël Coward', 'test pub', '2020', 'test cat2', 1, '2022-02-09 22:32:11', NULL),
(16, 'Blood\'s a Rover', '1-4028-9462-7', 'James Ellroy', 'test pub2', '2020', 'test cat3', 1, '2022-02-09 22:32:11', NULL),
(17, 'Blue Remembered Earth', '1-4028-9462-7', 'Alastair Reynolds', 'test pub2', '2020', 'test cat3', 1, '2022-02-09 22:32:11', NULL),
(18, 'Blue Remembered Hills', '1-4028-9462-7', 'Rosemary Sutcliff', 'test pub2', '2020', 'test cat3', 1, '2022-02-09 22:32:11', NULL),
(19, 'Bonjour Tristesse', '1-4028-9462-7', 'Françoise Sagan', 'test pub2', '2020', 'test cat4', 1, '2022-02-09 22:32:11', NULL),
(20, 'Brandy of the Damned', '1-4028-9462-7', 'Colin Wilson', 'test pub3', '2000', 'test cat4', 1, '2022-02-09 22:32:11', NULL),
(21, 'Bury My Heart at Wounded Knee', '1-4028-9462-7', 'Dee Brown', 'test pub3', '2000', 'test cat4', 1, '2022-02-09 22:32:11', NULL),
(22, 'Butter In a Lordly Dish', '1-4028-9462-7', 'Agatha Christie', 'test pub3', '2000', 'test cat4', 1, '2022-02-09 22:32:11', NULL),
(23, 'By Grand Central Station I Sat Down and Wept', '1-4028-9462-7', 'Elizabeth Smart', 'test pub3', '2000', 'test cat5', 1, '2022-02-09 22:32:11', NULL),
(24, 'Cabbages and Kings', '1-4028-9462-7', 'O. Henry', 'test pub3', '2000', 'test cat5', 1, '2022-02-09 22:32:11', NULL),
(25, 'Captains Courageous', '1-4028-9462-7', 'Rudyard Kipling', 'test pub3', '2000', 'test cat6', 1, '2022-02-09 22:32:11', NULL),
(26, 'Carrion Comfort', '1-4028-9462-7', 'Dan Simmons', 'test pub4', '1988', 'test cat7', 1, '2022-02-09 22:32:11', NULL),
(27, 'A Catskill Eagle', '1-4028-9462-7', 'Robert B. Parker', 'test pub4', '1988', 'test cat7', 1, '2022-02-09 22:32:11', NULL),
(28, 'The Children of Men', '1-4028-9462-7', 'P. D. James', 'test pub4', '1988', 'test cat7', 1, '2022-02-09 22:32:11', NULL),
(29, 'Clouds of Witness', '1-4028-9462-7', 'Dorothy L. Sayers', 'test pub4', '1988', 'test cat7', 1, '2022-02-09 22:32:11', NULL),
(30, 'A Confederacy of Dunces', '1-4028-9462-7', 'John Kennedy Toole', 'test pub4', '2001', 'test cat9', 1, '2022-02-09 22:32:11', NULL),
(31, 'test', '1-4028-9462-7', 'test a', 'test p', '2017', 'test cat', 1, '2022-02-09 22:37:36', '2022-02-09 22:39:07');

--
-- Indexes for dumped tables
--

--
-- Indexes for table `book_tbl`
--
ALTER TABLE `book_tbl`
  ADD PRIMARY KEY (`tbl_id`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `book_tbl`
--
ALTER TABLE `book_tbl`
  MODIFY `tbl_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=32;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
