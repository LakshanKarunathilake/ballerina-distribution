import ballerina/io;
import ballerinax/mysql;
import ballerina/sql;
import ballerina/time;

type BinaryType record {|
    int row_id;
    byte[] blob_type;
    byte[] binary_type;
|};

function getDataFromBinaryTypes(mysql:Client mysqlClient) returns sql:Error? {
    // Since the `rowType` is provided as a `BinaryType`, the `resultStream` 
    // will have `BinaryType` records.
    stream<record{}, error> resultStream = 
                mysqlClient -> query(`SELECT * FROM BINARY_TYPES`, BinaryType);
    stream<BinaryType, sql:Error> binaryResultStream = 
                <stream<BinaryType, sql:Error>> resultStream;

    io:println("Binary types Result :");
    // Iterate the `binaryResultStream`.
    error? e = binaryResultStream.forEach(function(BinaryType result) {
        io:println(result);
    });
}

type JsonType record {|
    int row_id;
    json json_doc;
    json json_array;
|};

function getDataFromJsonTypes(mysql:Client mysqlClient) returns sql:Error? {
    // Since the `rowType` is provided as an `JsonType`, the `resultStream` will
    // have `JsonType` records.
    stream<record{}, error> resultStream = 
                mysqlClient -> query(`SELECT * FROM JSON_TYPES`, JsonType);
    stream<JsonType, sql:Error> jsonResultStream =
                <stream<JsonType, sql:Error>> resultStream;

    io:println("Json type Result :");
    // Iterate the `jsonResultStream`.
    error? e = jsonResultStream.forEach(function(JsonType result) {
        io:println(result);
    });
}

type DateTimeType record {|
    int row_id;
    string date_type;
    int time_type;
    time:Utc timestamp_type;
    string datetime_type;
|};

function getDataFromDateTimeTypes(mysql:Client mysqlClient) returns sql:Error? {
    // Since the `rowType` is provided as a `DateTimeType`, the `resultStream`
    // will have `DateTimeType` records. The Date, Time, DateTime, and
    // Timestamp fields of the database table can be mapped to time:Utc,
    // string, and int types in Ballerina.
    stream<record{}, error> resultStream = 
                mysqlClient -> query(`SELECT * FROM DATE_TIME_TYPES`, DateTimeType);
    stream<DateTimeType, sql:Error> dateResultStream =
                <stream<DateTimeType, sql:Error>>resultStream;

    io:println("DateTime types Result :");
    // Iterate the `dateResultStream`.
    error? e = dateResultStream.forEach(function(DateTimeType result) {
        io:println(result);
    });
}

// Initializes the database as the prerequisite to the example.
function beforeRunningExample() returns sql:Error? {
    mysql:Client mysqlClient = check new (user = "root", password = "Test@123");

    // Create a Database.
    sql:ExecutionResult result =
        check mysqlClient -> execute(`CREATE DATABASE MYSQL_BBE`);
    
    // Create complex data type tables in the database.
    result = check mysqlClient -> execute(`CREATE TABLE MYSQL_BBE.BINARY_TYPES 
            (row_id INTEGER NOT NULL, blob_type BLOB(1024),  
            binary_type BINARY(27), PRIMARY KEY (row_id))`);
    
    result = check mysqlClient -> execute(`CREATE TABLE MYSQL_BBE.JSON_TYPES (row_id 
            INTEGER NOT NULL, json_doc JSON, json_array JSON, PRIMARY KEY (row_id))`);

    result = check mysqlClient -> execute(`CREATE TABLE MYSQL_BBE.DATE_TIME_TYPES(row_id 
            INTEGER NOT NULL, date_type DATE, time_type TIME, 
            timestamp_type timestamp, datetime_type  datetime, 
            PRIMARY KEY (row_id))`);

    // Add records to newly created tables.
    result = check mysqlClient -> execute(`INSERT INTO MYSQL_BBE.BINARY_TYPES (row_id, 
            blob_type, binary_type) VALUES (1, 
            X'77736F322062616C6C6572696E6120626C6F6220746573742E',  
            X'77736F322062616C6C6572696E612062696E61727920746573742E')`);

    result = check mysqlClient -> execute(`INSERT INTO MYSQL_BBE.JSON_TYPES (row_id, 
            json_doc, json_array) VALUES (1, '{"firstName" : "Jhon", "lastName" : 
            "Bob", "age" : 18}', JSON_ARRAY(1, 2, 3))`);

    result = check mysqlClient -> execute(`Insert into MYSQL_BBE.DATE_TIME_TYPES (row_id, 
            date_type, time_type, timestamp_type, datetime_type) values (1, 
            '2017-05-23', '14:15:23', '2017-01-25 16:33:55', 
            '2017-01-25 16:33:55')`);
    check mysqlClient.close();        
}

// Clean up the database after running the example.
function afterRunningExample(mysql:Client mysqlClient) returns sql:Error? {
    // Clean the database.
    sql:ExecutionResult result =
            check mysqlClient -> execute(`DROP DATABASE MYSQL_BBE`);
    // Close the MySQL client.
    check mysqlClient.close();
}

public function main() returns error? {
    // Run the prerequisite setup for the example.
    check beforeRunningExample();

    // Initialize the MySQL client.
    mysql:Client mysqlClient = check new (user = "root",
            password = "Test@123", database = "MYSQL_BBE");

    // Run a query for binary data types. 
    check getDataFromBinaryTypes(mysqlClient);

    // Run a query for json data types.
    check getDataFromJsonTypes(mysqlClient);

    // Run a query for date time data types.
    check getDataFromDateTimeTypes(mysqlClient);

    // Perform cleanup after the example.
    check afterRunningExample(mysqlClient);
}
