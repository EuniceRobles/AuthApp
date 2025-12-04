# bb88p1

SETTING UP DATABASE

CREATE DATABASE users;                     //users can be changed but will have to be edited in the php doc
USE users;

CREATE TABLE users (
  id INT AUTO_INCREMENT PRIMARY KEY,
  email VARCHAR(100) NOT NULL,
  password VARCHAR(100) NOT NULL
