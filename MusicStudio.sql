CREATE TABLE Address (
                         AddressID INT PRIMARY KEY,
                         StreetAddress VARCHAR(30),
                         City VARCHAR(30),
                         State VARCHAR(30),
                         ZipCode VARCHAR(30),
                         Country VARCHAR(30)
);

CREATE TABLE Studio (
                        StudioID INT PRIMARY KEY,
                        StudioName VARCHAR(30),
                        AddressID INT,
                        Phone VARCHAR(20),
                        Email VARCHAR(30),
                        FOREIGN KEY (AddressID) REFERENCES Address(AddressID)
);

CREATE TABLE EquipmentType (
                               EquipmentTypeID INT PRIMARY KEY,
                               TypeName VARCHAR(30),
                               Description VARCHAR(30)
);

CREATE TABLE Equipment (
                           EquipmentID INT PRIMARY KEY,
                           EquipmentName VARCHAR(30),
                           EquipmentTypeID INT,
                           StudioID INT,
                           FOREIGN KEY (EquipmentTypeID) REFERENCES EquipmentType(EquipmentTypeID),
                           FOREIGN KEY (StudioID) REFERENCES Studio(StudioID)
);

CREATE TABLE ConditionOfEquipment (
                                      ConditionID INT PRIMARY KEY,
                                      EquipmentID INT,
                                      ConditionDate DATE,
                                      ConditionDescription VARCHAR(30),
                                      FOREIGN KEY (EquipmentID) REFERENCES Equipment(EquipmentID)
);

CREATE TABLE Client (
                        ClientID INT PRIMARY KEY,
                        ClientName VARCHAR(30),
                        Surname VARCHAR(30),
                        Phone VARCHAR(30),
                        Email VARCHAR(30)
);

CREATE TABLE StaffRole (
                           RoleID INT PRIMARY KEY,
                           RoleName VARCHAR(30),
                           RoleDescription VARCHAR(30),
);

CREATE TABLE Staff (
                       StaffID INT PRIMARY KEY,
                       StaffName VARCHAR(30),
                       StaffSurname VARCHAR(30),
                       RoleID INT,
                       ContactInfo VARCHAR(30),
                       FOREIGN KEY (RoleID) REFERENCES StaffRole(RoleID)
);

CREATE TABLE RoomType (
                          RoomTypeID INT PRIMARY KEY,
                          RoomTypeName VARCHAR(30),
                          Description VARCHAR(30),
                          HourlyRate DECIMAL(10,2)
);

CREATE TABLE TypeOfActivity (
                                ActivityTypeID INT PRIMARY KEY,
                                ActivityName VARCHAR(30),
                                Description VARCHAR(30)
);

CREATE TABLE Session (
                         SessionID INT PRIMARY KEY,
                         StudioID INT,
                         ClientID INT,
                         RoomTypeID INT,
                         StaffID INT,
                         ActivityTypeID INT,
                         SessionDate DATE,
                         StartTime TIME,
                         EndTime TIME,
                         Purpose VARCHAR(30),
                         FOREIGN KEY (StudioID) REFERENCES Studio(StudioID),
                         FOREIGN KEY (ClientID) REFERENCES Client(ClientID),
                         FOREIGN KEY (RoomTypeID) REFERENCES RoomType(RoomTypeID),
                         FOREIGN KEY (StaffID) REFERENCES Staff(StaffID),
                         FOREIGN KEY (ActivityTypeID) REFERENCES TypeOfActivity(ActivityTypeID)
);

CREATE TABLE Feedback (
                          FeedbackID INT PRIMARY KEY,
                          ClientID INT,
                          SessionID INT,
                          Rating INT,
                          FeedbackDate DATE,
                          Comments TEXT,
                          FOREIGN KEY (ClientID) REFERENCES Client(ClientID),
                          FOREIGN KEY (SessionID) REFERENCES Session(SessionID)
);

CREATE TABLE PaymentType (
                             PaymentTypeID INT PRIMARY KEY,
                             PaymentTypeName VARCHAR(30)
);

CREATE TABLE Invoice (
                         InvoiceID INT PRIMARY KEY,
                         ClientID INT,
                         SessionID INT,
                         PaymentTypeID INT,
                         InvoiceDate DATE,
                         AmountDue DECIMAL(12,2),
                         AmountPaid DECIMAL(12,2),
                         DueDate DATE,
                         PaymentDate DATE,
                         PaymentStatus VARCHAR(20),
                         FOREIGN KEY (ClientID) REFERENCES Client(ClientID),
                         FOREIGN KEY (SessionID) REFERENCES Session(SessionID),
                         FOREIGN KEY (PaymentTypeID) REFERENCES PaymentType(PaymentTypeID)
);

CREATE TABLE StatusForRecord (
                                 StatusID INT PRIMARY KEY,
                                 StatusName VARCHAR(30)
);

CREATE TABLE Records (
                         RecordID INT PRIMARY KEY,
                         SessionID INT,
                         ClientID INT,
                         StaffID INT,
                         RecordTitle VARCHAR(30),
                         RecordDate DATE,
                         RecordLength DECIMAL(10,2),
                         FileType VARCHAR(10),
                         FilePath VARCHAR(255),
                         StatusID INT,
                         FOREIGN KEY (SessionID) REFERENCES Session(SessionID),
                         FOREIGN KEY (ClientID) REFERENCES Client(ClientID),
                         FOREIGN KEY (StaffID) REFERENCES Staff(StaffID),
                         FOREIGN KEY (StatusID) REFERENCES StatusForRecord(StatusID)
);

CREATE TABLE StudioStaff (
                             StudioID INT,
                             StaffID INT,
                             HireDate DATE,
                             FireDate DATE,
                             FOREIGN KEY (StudioID) REFERENCES Studio(StudioID),
                             FOREIGN KEY (StaffID) REFERENCES Staff(StaffID)
);

INSERT INTO Address (AddressID, StreetAddress, City, State, ZipCode, Country) VALUES
    (1, '1 West Washington Boulevard', 'Culver', 'CA', '10202', 'USA');

INSERT INTO Studio (StudioID, StudioName, AddressID, Phone, Email) VALUES
    (1, 'Sound Haven', 1, '+48231789543', 'info@soundhaven.com');

INSERT INTO EquipmentType (EquipmentTypeID, TypeName, Description) VALUES
                                                                       (1, 'Microphone', 'Audio recording device'),
                                                                       (2, 'Headphones', 'Audio monitoring device'),
                                                                       (3, 'Mixing Console', 'Audio mixing equipment'),
                                                                       (4, 'Guitar Amplifier', 'Amplifies guitar signal'),
                                                                       (5, 'Drum Kit', 'Acoustic drum set'),
                                                                       (6, 'Keyboard', 'Electronic keyboard instrument'),
                                                                       (7, 'Monitor Speakers', 'Studio playback speakers'),
                                                                       (8, 'Audio Interface', 'Connects instruments to computer');

INSERT INTO Equipment (EquipmentID, EquipmentName, EquipmentTypeID, StudioID) VALUES
                                                                                  (1, 'Shure SM58', 1, 1),
                                                                                  (2, 'Sony MDR7506', 2, 1),
                                                                                  (8, 'Yamaha NS-10', 7, 1);

INSERT INTO ConditionOfEquipment (ConditionID, EquipmentID, ConditionDate, ConditionDescription) VALUES
                                                                                                     (1, 1, '2024-03-15', 'Good'),
                                                                                                     (2, 2, '2024-03-15', 'Excellent'),
                                                                                                     (8, 8, '2024-03-18', 'Broken');

INSERT INTO Client (ClientID, ClientName, Surname, Phone, Email) VALUES
                                                                     (1, 'John', 'Doe', '+48452922215', 'john.doe@email.com'),
                                                                     (2, 'Jane', 'Smith', '+48922215452', 'jane.smith@email.com'),
                                                                     (3, 'David', 'Lee', '+48099596278', 'david.lee@email.com'),
                                                                     (4, 'Sarah', 'Jones', '+48345987564', 'sarah.jones@email.com');

INSERT INTO StaffRole (RoleID, RoleName, RoleDescription) VALUES
                                                              (1, 'Engineer', 'Records and mixes audio'),
                                                              (2, 'Producer', 'Oversees recording project'),
                                                              (3, 'Assistant Engineer', 'Assists the engineer'),
                                                              (4, 'Session Musician', 'Plays instruments on recordings');

INSERT INTO Staff (StaffID, StaffName, StaffSurname, RoleID, ContactInfo) VALUES
                                                                              (1, 'Bob', 'Johnson', 1, 'bob.johnson@studio.com'),
                                                                              (4, 'Lucy', 'Van Pelt', 4, 'lucy.vanpelt@studio.com'),
                                                                              (3, 'Bob', 'Dylan', 1, 'bob.Dylan@studio.com'),
                                                                              (2, 'Travis', 'Scott', 4, 'trav.scott@studio.com');

INSERT INTO RoomType (RoomTypeID, RoomTypeName, Description, HourlyRate) VALUES
                                                                             (1, 'Recording Booth', 'Soundproof room for recording', 50.00),
                                                                             (2, 'Control Room', 'Room for mixing and mastering', 75.00),
                                                                             (3, 'Live Room', 'Large room for recording bands', 100.00),
                                                                             (4, 'Vocal Booth', 'Small, isolated room for vocal recording', 40.00);

INSERT INTO TypeOfActivity (ActivityTypeID, ActivityName, Description) VALUES
                                                                           (1, 'Recording', 'Audio recording session'),
                                                                           (2, 'Mixing', 'Audio mixing session'),
                                                                           (3, 'Mastering', 'Audio mastering session'),
                                                                           (4, 'Rehearsal', 'Band practice session'),
                                                                           (5, 'Overdubbing', 'Adding additional recordings to a track');

INSERT INTO Session (SessionID, StudioID, ClientID, RoomTypeID, StaffID, ActivityTypeID, SessionDate, StartTime, EndTime, Purpose) VALUES
                                                                                                                                       (1, 1, 1, 1, 1, 1, '2024-03-18', '10:00:00', '13:00:00', 'Voiceover recording'),
                                                                                                                                       (5, 1, 4, 4, 1, 5, '2024-03-28', '15:00:00', '18:00:00', 'Vocal overdubs');

INSERT INTO Feedback (FeedbackID, ClientID, SessionID, Rating, FeedbackDate, Comments) VALUES
                                                                                           (1, 1, 1, 5, '2024-03-19', 'Great session!'),
                                                                                           (5, 4, 5, 5, '2024-03-29', 'Loved the engineer!');

INSERT INTO PaymentType (PaymentTypeID, PaymentTypeName) VALUES
                                                             (1, 'Credit/Debit Card'),
                                                             (2, 'Cash');

INSERT INTO Invoice (InvoiceID, ClientID, SessionID, PaymentTypeID, InvoiceDate, AmountDue, AmountPaid, DueDate, PaymentDate, PaymentStatus) VALUES
                                                                                                                                                 (1, 1, 1, 1, '2024-03-18', 150.00, 150.00, '2024-03-25', '2024-03-19', 'Paid'),
                                                                                                                                                 (5, 4, 5, 4, '2024-03-28', 120.00, 120.00, '2024-04-04', '2024-03-29', 'Paid');

INSERT INTO StatusForRecord (StatusID, StatusName) VALUES
                                                       (1, 'In Progress'),
                                                       (2, 'Completed'),
                                                       (3, 'Archived');

INSERT INTO Records (RecordID, SessionID, ClientID, StaffID, RecordTitle, RecordDate, RecordLength, FileType, FilePath, StatusID) VALUES
                                                                                                                                      (1, 1, 1, 1, 'Voiceover', '2024-03-18', 180.50, 'WAV', '/recordings/voiceover.wav', 2),
                                                                                                                                      (5, 5, 4, 1, 'Edlibs', '2024-03-28', 105.75, 'WAV', '/recordings/vocal_overdubs.wav', 2);

INSERT INTO StudioStaff(StudioID, StaffID, HireDate, FireDate) VALUES
                                                                   (1, 1, '2023-08-15', NULL),
                                                                   (1, 4, '2024-02-01', NULL),
                                                                   (1, 2, '2022-01-12', NULL),
                                                                   (1, 3, '2021-02-13', NULL);

