--6 Afisati pretul jocurilor:
CREATE OR REPLACE PROCEDURE price IS  
    TYPE tablou_indexat IS TABLE OF GAMES%ROWTYPE 
    INDEX BY BINARY_INTEGER; 
    t tablou_indexat; 
    
    BEGIN 
        SELECT *BULK COLLECT INTO t
        FROM games
        ORDER BY price;
        FOR i IN 1..11 LOOP 
            DBMS_OUTPUT.PUT_LINE (t(i).id_game || ' ' || t(i).name || ' is ' || t(i).price || '$');
        END LOOP;
END; 
/

BEGIN
    price();
END;
/

--7 Afisati scorul jocurilor:
CREATE OR REPLACE PROCEDURE score IS
    v_scor games.score%TYPE; 
    v_nume games.name%TYPE; 
    CURSOR c IS 
        SELECT g.score scor, g.name nume
        FROM games g
        --WHERE g.score >= 5  
        ORDER BY g.score; 
        
    BEGIN 
        OPEN c; 
        LOOP 
            FETCH c INTO v_scor, v_nume; 
            EXIT WHEN c%NOTFOUND; --or c%ROWCOUNT>5;
            IF v_scor < 5 THEN 
                DBMS_OUTPUT.PUT_LINE('The game '|| v_nume || ' sucks.');
            ELSIF v_scor = 5 THEN 
                DBMS_OUTPUT.PUT_LINE('The game '|| v_nume || ' is decent.'); 
            ELSIF v_scor >= 6 and v_scor<=8 THEN 
                DBMS_OUTPUT.PUT_LINE('The game '|| v_nume || ' is pretty good.'); 
            ELSIF v_scor >= 9 THEN
                DBMS_OUTPUT.PUT_LINE('The game '|| v_nume || ' is a must have!'); 
            END IF; 
        END LOOP; 
        CLOSE c; 
END;
/

BEGIN
    score();
END;
/

--8 Obtineti nr. de clase ale personajelor din The Elder Scrolls 3:
CREATE OR REPLACE FUNCTION classes (g_name games.name%TYPE DEFAULT 'The Elder Scrolls 3') 
    RETURN NUMBER IS
        type tabel IS TABLE OF characters.class%TYPE;
        tab tabel;
        cnt number := 0;
        exceptie EXCEPTION;
    
    BEGIN
        SELECT c.class BULK COLLECT INTO tab
        FROM games g, characters c, game_chars gc
        WHERE c.id_char = gc.id_char AND gc.id_game = g.id_game AND g.name = g_name
        GROUP BY c.class;
        cnt := tab.COUNT;
        
        IF cnt = 0 THEN
            RAISE exceptie;
        ELSE 
            DBMS_OUTPUT.PUT_LINE('The number of classes is: ');
            RETURN cnt;
        END IF;
        
        EXCEPTION
            WHEN exceptie THEN
                DBMS_OUTPUT.PUT_LINE('There is no game named that way.');
                return 0;            
            WHEN OTHERS THEN
                DBMS_OUTPUT.PUT_LINE('There was another error.');
                return -1;
END classes;
/
    
BEGIN
    DBMS_OUTPUT.PUT_LINE(classes('The Elder Scrolls 3'));
END;
/
    
--9 Obtineti personajele care participa la explorare in The Elder Scrolls 5:
CREATE OR REPLACE PROCEDURE charac (g_name games.name%TYPE DEFAULT 'The Elder Scrolls 5', e_name events.name%TYPE DEFAULT 'Exploring') 
  IS
    type tabel IS TABLE OF characters.name%TYPE;
    vec tabel;
    exceptie EXCEPTION;
    
    BEGIN
        SELECT c.name BULK COLLECT INTO vec
        FROM games g, game_chars gc, characters c, char_evs ce, events e, game_evs ge
        WHERE c.id_char = gc.id_char AND g.id_game = gc.id_game 
            AND g.id_game = ge.id_game AND e.id_event = ge.id_event 
            AND e.id_event = ce.id_event AND c.id_char = ce.id_char 
            AND g.name = g_name AND e.name = e_name
        GROUP BY c.name;
        
        IF vec.count = 0 THEN
            RAISE exceptie;
        ELSE 
            DBMS_OUTPUT.PUT_LINE('Names: ');
            DBMS_OUTPUT.PUT_LINE('');
            FOR i IN 1..vec.count LOOP
                DBMS_OUTPUT.PUT_LINE(vec(i));
                END LOOP;
        END IF;
        
        EXCEPTION
            WHEN exceptie THEN
                DBMS_OUTPUT.PUT_LINE('Check if you wrote the names or events correctly.');           
            WHEN OTHERS THEN
                DBMS_OUTPUT.PUT_LINE('There was another error.');
END charac;
/
    
BEGIN
    charac('The Elder Scrolls 5', 'Exploring');
END;
/

--10
CREATE OR REPLACE TRIGGER trig1
    BEFORE INSERT OR UPDATE OR DELETE ON games
    
    BEGIN 
        IF USER != UPPER('varothex') 
            THEN RAISE_APPLICATION_ERROR(-20900, 'Only Varothex may change data!'); 
        END IF; 
END;
/

DROP TRIGGER trig1;

--11
CREATE OR REPLACE TRIGGER trig2
    BEFORE INSERT ON games
    FOR EACH ROW 
    DECLARE 
        exceptie EXCEPTION;
        v_emplid varchar2(50);
    
    BEGIN 
        SELECT g.name INTO v_emplid FROM games g WHERE g.name = :NEW.name;
        IF v_emplid IS NOT NULL
            THEN RAISE exceptie; 
        END IF;
        EXCEPTION 
            WHEN exceptie 
                THEN RAISE_APPLICATION_ERROR (-20005, 'The game is already there.'); 
END; 
/

DROP TRIGGER trig2;

--12
CREATE TABLE user_g 
(nume VARCHAR2(30), nume_bd VARCHAR2(50), data DATE);

CREATE TABLE test11
(nume VARCHAR2(30), nume_bd VARCHAR2(50), data DATE);

CREATE OR REPLACE TRIGGER trig3
    BEFORE DROP ON schema
    BEGIN 
        INSERT INTO user_g
        VALUES (SYS.LOGIN_USER, SYS.DATABASE_NAME, SYSDATE); 
END; 
/

DROP TABLE test11;

SELECT * FROM user_g;

DROP TRIGGER trig3;

--13
CREATE OR REPLACE PACKAGE pachetul_de_la_exercitiul_13 AS

    PROCEDURE price;
    PROCEDURE score;
    FUNCTION classes (g_name games.name%TYPE DEFAULT 'The Elder Scrolls 3') RETURN NUMBER;
    PROCEDURE charac (g_name games.name%TYPE DEFAULT 'The Elder Scrolls 5', e_name events.name%TYPE DEFAULT 'Exploring');

END pachetul_de_la_exercitiul_13;
/

CREATE OR REPLACE PACKAGE BODY pachetul_de_la_exercitiul_13 AS

    PROCEDURE price IS  --6
        TYPE tablou_indexat IS TABLE OF GAMES%ROWTYPE 
        INDEX BY BINARY_INTEGER; 
        t tablou_indexat; 
        
        BEGIN 
            SELECT *BULK COLLECT INTO t
            FROM games
            ORDER BY price;
            FOR i IN 1..11 LOOP 
                DBMS_OUTPUT.PUT_LINE (t(i).id_game || ' ' || t(i).name || ' is ' || t(i).price || '$');
            END LOOP;
    END; 

    --7
    PROCEDURE score IS 
        v_scor games.score%TYPE; 
        v_nume games.name%TYPE; 
        CURSOR c IS 
            SELECT g.score scor, g.name nume
            FROM games g 
            ORDER BY g.score; 
        BEGIN 
            OPEN c; 
            LOOP 
                FETCH c INTO v_scor, v_nume; 
                EXIT WHEN c%NOTFOUND; --or c%ROWCOUNT>5;
                IF v_scor < 5 THEN 
                    DBMS_OUTPUT.PUT_LINE('The game '|| v_nume || ' sucks.');
                ELSIF v_scor = 5 THEN 
                    DBMS_OUTPUT.PUT_LINE('The game '|| v_nume || ' is decent.'); 
                ELSIF v_scor >= 6 and v_scor<=8 THEN 
                    DBMS_OUTPUT.PUT_LINE('The game '|| v_nume || ' is pretty good.'); 
                ELSIF v_scor >= 9 THEN
                    DBMS_OUTPUT.PUT_LINE('The game '|| v_nume || ' is a must have!'); 
                END IF; 
            END LOOP; 
            CLOSE c; 
    END;

    --8
    FUNCTION classes (g_name games.name%TYPE DEFAULT 'The Elder Scrolls 3') 
        RETURN NUMBER IS
            type tabel IS TABLE OF characters.class%TYPE;
            tab tabel;
            cnt number := 0;
            exceptie EXCEPTION;
    
        BEGIN
            SELECT c.class BULK COLLECT INTO tab
            FROM games g, characters c, game_chars gc
            WHERE c.id_char = gc.id_char AND gc.id_game = g.id_game AND g.name = g_name
            GROUP BY c.class;
            cnt := tab.COUNT;
        
            IF cnt = 0 THEN
                RAISE exceptie;
            ELSE 
                DBMS_OUTPUT.PUT_LINE('The number of classes is: ');
                RETURN cnt;
            END IF;
        
            EXCEPTION
                WHEN exceptie THEN
                    DBMS_OUTPUT.PUT_LINE('There is no game named that way.');
                    return 0;            
                WHEN OTHERS THEN
                    DBMS_OUTPUT.PUT_LINE('There was another error.');
                    return -1;
    END classes;
    
    --9
    PROCEDURE charac (g_name games.name%TYPE DEFAULT 'The Elder Scrolls 5', e_name events.name%TYPE DEFAULT 'Exploring') 
        IS
            type tabel IS TABLE OF characters.name%TYPE;
            vec tabel;
            exceptie EXCEPTION;
    
        BEGIN
            SELECT c.name BULK COLLECT INTO vec
            FROM games g, game_chars gc, characters c, char_evs ce, events e, game_evs ge
            WHERE c.id_char = gc.id_char AND g.id_game = gc.id_game 
                AND g.id_game = ge.id_game AND e.id_event = ge.id_event 
                AND e.id_event = ce.id_event AND c.id_char = ce.id_char 
                AND g.name = g_name AND e.name = e_name
            GROUP BY c.name;
        
            IF vec.count = 0 THEN
                RAISE exceptie;
            ELSE 
                DBMS_OUTPUT.PUT_LINE('Names: ');
                DBMS_OUTPUT.PUT_LINE('');
                FOR i IN 1..vec.count LOOP
                    DBMS_OUTPUT.PUT_LINE(vec(i));
                END LOOP;
            END IF;
        
            EXCEPTION
                WHEN exceptie THEN
                    DBMS_OUTPUT.PUT_LINE('Check if you wrote the names or events correctly.');           
                WHEN OTHERS THEN
                    DBMS_OUTPUT.PUT_LINE('There was another error.');
    END charac;
    
END pachetul_de_la_exercitiul_13;
/