--T-sql
--procedures
--1
--Calculate the total revenue and total outstanding payments for all clients and generate a summary
CREATE PROCEDURE Generate_Invoice_Summary
AS
BEGIN
    DECLARE @ClientID INT, @TotalPaid DECIMAL(12, 2), @TotalOutstanding DECIMAL(12, 2);
    DECLARE client_cursor CURSOR FOR
        SELECT ClientID FROM Client;

    OPEN client_cursor;
    FETCH NEXT FROM client_cursor INTO @ClientID;

    WHILE @@FETCH_STATUS = 0
        BEGIN
            SELECT
                @TotalPaid = ISNULL(SUM(AmountPaid), 0),
                @TotalOutstanding = ISNULL(SUM(AmountDue - AmountPaid), 0)
            FROM Invoice
            WHERE ClientID = @ClientID;

            PRINT 'ClientID: ' + CAST(@ClientID AS VARCHAR) +
                  ', Total Paid: ' + CAST(@TotalPaid AS VARCHAR) +
                  ', Total Outstanding: ' + CAST(@TotalOutstanding AS VARCHAR);

            FETCH NEXT FROM client_cursor INTO @ClientID;
        END;

    CLOSE client_cursor;
    DEALLOCATE client_cursor;
END;

    --Result as text in console
    EXEC Generate_Invoice_Summary;

    --ClientID: 1, Total Paid: 150.00, Total Outstanding: 0.00
    --ClientID: 2, Total Paid: 0.00, Total Outstanding: 0.00
    --ClientID: 3, Total Paid: 150.00, Total Outstanding: -30.00
    --ClientID: 4, Total Paid: 120.00, Total Outstanding: 0.00



--2
    --This procedure is useful for managers/accounting team to evaluate staff workload and performance during specific periods
    CREATE PROCEDURE Calculate_Staff_Activity_Summary
        @StartDate DATE,
        @EndDate DATE
    AS
    BEGIN
        SELECT
            s.StaffID,
            CONCAT(sf.StaffName, ' ', sf.StaffSurname) AS StaffFullName,
            COUNT(s.SessionID) AS TotalSessions,
            SUM(DATEDIFF(MINUTE, s.StartTime, s.EndTime) / 60.0) AS TotalHours
        FROM Session s
                 JOIN Staff sf ON s.StaffID = sf.StaffID
        WHERE s.SessionDate BETWEEN @StartDate AND @EndDate
        GROUP BY s.StaffID, sf.StaffName, sf.StaffSurname
        ORDER BY TotalSessions DESC, TotalHours DESC;
    END;

        --Result as a table
        EXEC Calculate_Staff_Activity_Summary '2024-03-01', '2025-03-31';

        -- StaffID, StaffFullName, TotalSessions, TotalHours
        --     1  , Alicia Keys  , 2            , 6.0
        --     3  , Marvin Gaye  , 1            , 3.0


--trigers

--1
        --Updates PaymentStatus and PaymentDate when the AmountPaid is updated.
        CREATE TRIGGER Invoice_Payment_Status_Update
            ON Invoice
            AFTER UPDATE
            AS
        BEGIN
            DECLARE @InvoiceID INT, @AmountPaid DECIMAL(12, 2), @AmountDue DECIMAL(12, 2);

            DECLARE updated_cursor CURSOR FOR
                SELECT InvoiceID, AmountPaid, AmountDue FROM inserted;

            OPEN updated_cursor;
            FETCH NEXT FROM updated_cursor INTO @InvoiceID, @AmountPaid, @AmountDue;

            WHILE @@FETCH_STATUS = 0
                BEGIN
                    IF @AmountPaid >= @AmountDue
                        BEGIN
                            UPDATE Invoice
                            SET PaymentStatus = 'Paid', PaymentDate = GETDATE()
                            WHERE InvoiceID = @InvoiceID;
                        END

                    FETCH NEXT FROM updated_cursor INTO @InvoiceID, @AmountPaid, @AmountDue;
                END;

            CLOSE updated_cursor;
            DEALLOCATE updated_cursor;
        END;

            --Result
            UPDATE Invoice SET AmountPaid = 150.00 WHERE InvoiceID = 3;

            -- 3 rows retrieved starting from; and for Client Kanye West we updated info in table that he paid


--2
            --Ensures that feedback can only be given for completed sessions
            CREATE TRIGGER Feedback_Validation
                ON Feedback
                INSTEAD OF INSERT
                AS
            BEGIN
                IF EXISTS (
                    SELECT 1
                    FROM inserted i
                             JOIN Session s ON i.SessionID = s.SessionID
                    WHERE s.SessionDate > GETDATE()
                )
                    BEGIN
                        RAISERROR ('Feedback cannot be given for sessions in the future.', 16, 1);
                    END
                ELSE
                    BEGIN
                        INSERT INTO Feedback (FeedbackID, ClientID, SessionID, Rating, FeedbackDate, Comments)
                        SELECT FeedbackID, ClientID, SessionID, Rating, FeedbackDate, Comments FROM inserted;
                    END;
            END;

        --Result
        INSERT INTO Feedback (FeedbackID, ClientID, SessionID, Rating, FeedbackDate, Comments)
        VALUES (3, 3, 3, 5, GETDATE(), 'Excellent!');
        -- [2025-01-07 23:59:05] [S1000][50000] Feedback cannot be given for sessions in the future.