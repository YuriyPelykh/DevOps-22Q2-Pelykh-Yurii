<?php
mysqli_report(MYSQLI_REPORT_ERROR | MYSQLI_REPORT_STRICT);
session_start();

$pconn = mysqli_connect(
  $_ENV["DB_SERVER"],
  $_ENV["DB_USER"],
  $_ENV["MYSQL_ROOT_PASSWORD"]
) or die(mysqli_error($mysqli));


$create_db = mysqli_query($pconn, "CREATE DATABASE IF NOT EXISTS php_mysql_crud;");

$conn = mysqli_connect(
  $_ENV["DB_SERVER"],
  $_ENV["DB_USER"],
  $_ENV["MYSQL_ROOT_PASSWORD"],
  $_ENV["DB_NAME"]
) or die(mysqli_error($mysqli));

$sql_table_exists = "SHOW TABLES FROM php_mysql_crud WHERE Tables_in_php_mysql_crud LIKE 'task';";
$mysqli_result = mysqli_query($conn, $sql_table_exists);
$res_row = mysqli_fetch_assoc($mysqli_result);
if (empty($res_row['Tables_in_php_mysql_crud'])) {
  $sql_table_create = "CREATE TABLE task(
id INT(11) PRIMARY KEY AUTO_INCREMENT,
title VARCHAR(255) NOT NULL,
description TEXT,
created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);";
  if (mysqli_query($conn, $sql_table_create)) {
    echo "Table task created successfully";
  } else {
    echo "Error creating table: " . mysqli_error($conn);
  }
}


?>
