--PL/SQL
--Procedures
--1
--This procedure is useful in assessing staff performance based on client feedback and session details
CREATE OR REPLACE PROCEDURE GenerateStaffSessionsWithFeedbackReport (
    p_staff_id IN INT
)
    IS
    CURSOR staff_sessions_cursor IS
        SELECT s.SessionID, s.SessionDate, s.StartTime, s.EndTime,
               r.RoomTypeName, c.ClientName, f.Rating, f.Comments
        FROM Sessions s
                 JOIN RoomType r ON s.RoomTypeID = r.RoomTypeID
                 JOIN Client c ON s.ClientID = c.ClientID
                 LEFT JOIN Feedback f ON s.SessionID = f.SessionID
        WHERE s.StaffID = p_staff_id
        ORDER BY s.SessionDate, s.StartTime;

    v_session_id INT;
    v_session_date DATE;
    v_start_time TIMESTAMP;
    v_end_time TIMESTAMP;
    v_room_type VARCHAR2(30);
    v_client_name VARCHAR2(30);
    v_rating INT;
    v_comments CLOB;
BEGIN
    OPEN staff_sessions_cursor;

    LOOP
        FETCH staff_sessions_cursor INTO v_session_id, v_session_date, v_start_time, v_end_time, v_room_type, v_client_name, v_rating, v_comments;
        EXIT WHEN staff_sessions_cursor%NOTFOUND;

        DBMS_OUTPUT.PUT_LINE('Session ID: ' || v_session_id ||
                             ', Date: ' || TO_CHAR(v_session_date, 'YYYY-MM-DD') ||
                             ', Start: ' || TO_CHAR(v_start_time, 'HH24:MI:SS') ||
                             ', End: ' || TO_CHAR(v_end_time, 'HH24:MI:SS') ||
                             ', Room: ' || v_room_type ||
                             ', Client: ' || v_client_name);

        -- Display feedback if available
        IF v_rating IS NOT NULL THEN
            DBMS_OUTPUT.PUT_LINE('    Rating: ' || v_rating ||
                                 ', Comments: ' || NVL(v_comments, 'No comments provided'));
        ELSE
            DBMS_OUTPUT.PUT_LINE('    No feedback available');
        END IF;
    END LOOP;

    CLOSE staff_sessions_cursor;
END;
/


--Result
BEGIN
    GenerateStaffSessionsWithFeedbackReport(1);
END;
--Session ID: 1, Date: 2024-03-18, Start: 10:00:00, End: 13:00:00, Room: Recording Booth, Client: Nina
--Rating: 5, Comments: Great session!
--Session ID: 2, Date: 2024-03-28, Start: 15:00:00, End: 18:00:00, Room: Vocal Booth, Client: James
--Rating: 5, Comments: Loved the engineer!



--2
--This procedure helps monitor the status and condition of the studio's equipment.
CREATE OR REPLACE PROCEDURE GenerateEquipmentConditionReport (
    p_studio_id IN INT
)
    IS
    CURSOR equipment_condition_cursor IS
        SELECT e.EquipmentName, et.TypeName,
               ce.ConditionDescription, COUNT(*) AS ConditionCount
        FROM Equipment e
                 JOIN EquipmentType et ON e.EquipmentTypeID = et.EquipmentTypeID
                 LEFT JOIN ConditionOfEquipment ce ON e.EquipmentID = ce.EquipmentID
        WHERE e.StudioID = p_studio_id
        GROUP BY e.EquipmentName, et.TypeName, ce.ConditionDescription
        ORDER BY e.EquipmentName, ce.ConditionDescription;

    v_equipment_name VARCHAR2(30);
    v_type_name VARCHAR2(30);
    v_condition_description VARCHAR2(100);
    v_condition_count INT;
BEGIN
    OPEN equipment_condition_cursor;

    LOOP
        FETCH equipment_condition_cursor INTO v_equipment_name, v_type_name, v_condition_description, v_condition_count;
        EXIT WHEN equipment_condition_cursor%NOTFOUND;

        DBMS_OUTPUT.PUT_LINE('Equipment: ' || v_equipment_name ||
                             ', Type: ' || v_type_name ||
                             ', Condition: ' || v_condition_description ||
                             ', Quantity: ' || v_condition_count);
    END LOOP;

    CLOSE equipment_condition_cursor;
END;
/

--Result
BEGIN
    GenerateEquipmentConditionReport(1);
END;
--Equipment: Shure SM58, Type: Microphone, Condition: Good, Quantity: 1
--Equipment: Sony MDR7506, Type: Headphones, Condition: Excellent, Quantity: 1
--Equipment: Yamaha NS-10, Type: Monitor Speakers, Condition: Broken, Quantity: 1


--Trigers

--1
-- Prevent_Overlapping_Sessions
CREATE OR REPLACE TRIGGER Prevent_Overlapping_Sessions
    BEFORE INSERT OR UPDATE ON Sessions
    FOR EACH ROW
DECLARE
    overlapping_count INTEGER;
BEGIN
    SELECT COUNT(*)
    INTO overlapping_count
    FROM Sessions
    WHERE StudioID = :NEW.StudioID
      AND RoomTypeID = :NEW.RoomTypeID
      AND SessionDate = :NEW.SessionDate
      AND (
        :NEW.StartTime < EndTime
            AND :NEW.EndTime > StartTime
        );

    IF overlapping_count > 0 THEN
        RAISE_APPLICATION_ERROR(-20003, 'Overlapping sessions are not allowed in the same studio room.');
    END IF;
END;
/


--Result
INSERT INTO Sessions (SessionID, StudioID, ClientID, RoomTypeID, StaffID, ActivityTypeID, SessionDate, StartTime, EndTime, Purpose)
VALUES (4, 1, 2, 1, 2, 1, TO_DATE('2024-03-18', 'YYYY-MM-DD'), TO_TIMESTAMP('12:00:00', 'HH24:MI:SS'), TO_TIMESTAMP('14:00:00', 'HH24:MI:SS'), 'Recording');
/ --ORA-20003: Overlapping sessions are not allowed in the same studio room.

--2
--trigger that checks if a client has any unpaid invoices before allowing a new session to be created for that client
CREATE OR REPLACE TRIGGER BeforeSessionInsert_CheckUnpaidInvoices
    BEFORE INSERT ON Sessions
    FOR EACH ROW
DECLARE
    v_unpaid_count INT;
BEGIN
    -- Check if the client has any unpaid invoices
    SELECT COUNT(*) INTO v_unpaid_count
    FROM Invoice
    WHERE ClientID = :NEW.ClientID AND PaymentStatus = 'NOT Paid';

    -- If there are unpaid invoices, raise an error and prevent session creation
    IF v_unpaid_count > 0 THEN
        RAISE_APPLICATION_ERROR(-20003, 'Client has unpaid invoices. New session cannot be created.');
    END IF;
END;

--Result
INSERT INTO Sessions (SessionID, StudioID, ClientID, RoomTypeID, StaffID, ActivityTypeID, SessionDate, StartTime, EndTime, Purpose)
VALUES (5, 1, 3, 2, 3, 1, TO_DATE('2025-01-10', 'YYYY-MM-DD'), TO_TIMESTAMP('2025-01-10 10:00:00', 'YYYY-MM-DD HH24:MI:SS'), TO_TIMESTAMP('2025-01-10 12:00:00', 'YYYY-MM-DD HH24:MI:SS'), 'Test Session');
--ORA-20003: Client has unpaid invoices. New session cannot be created.

