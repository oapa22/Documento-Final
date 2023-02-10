USE projectobase;

-- Tabla Original_language--
DROP PROCEDURE IF EXISTS TablaOriginal_language;
DELIMITER $$
CREATE PROCEDURE TablaOriginal_language()
BEGIN
    DECLARE done INT DEFAULT FALSE;
    DECLARE namelanguage VARCHAR(100);
    -- Declarar el cursor
    DECLARE Cursorlanguage CURSOR FOR
        SELECT DISTINCT CONVERT(original_language USING UTF8MB4) from movie_dataset;
    -- Declarar el handler para NOT FOUND (esto es marcar cuando el cursor ha llegado a su fin)
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;
    -- Abrir el cursor
    OPEN Cursorlanguage;
    CursorDirector_loop: LOOP
        FETCH Cursorlanguage INTO namelanguage;
        -- Si alcanzo el final del cursor entonces salir del ciclo repetitivo
        IF done THEN
            LEAVE CursorDirector_loop;
        END IF;
        IF namelanguage IS NULL THEN
            SET namelanguage = '';
        END IF;
        SET @_oStatement = CONCAT('INSERT INTO original_language (language) VALUES (\'',namelanguage,'\');');
        PREPARE sent1 FROM @_oStatement;
        EXECUTE sent1;
        DEALLOCATE PREPARE sent1;
    END LOOP;
    CLOSE Cursorlanguage;
END $$
DELIMITER ;

CALL TablaOriginal_language ();

-- Tabla Status--
DROP PROCEDURE IF EXISTS TablaStatus;
DELIMITER $$
CREATE PROCEDURE TablaStatus()
BEGIN
    DECLARE done INT DEFAULT FALSE;
    DECLARE nameStatus VARCHAR(100);
    -- Declarar el cursor
    DECLARE CursorStatus CURSOR FOR
        SELECT DISTINCT CONVERT(status USING UTF8MB4) from movie_dataset;
    -- Declarar el handler para NOT FOUND (esto es marcar cuando el cursor ha llegado a su fin)
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;
    -- Abrir el cursor
    OPEN CursorStatus;
    CursorDirector_loop: LOOP
        FETCH CursorStatus INTO nameStatus;
        -- Si alcanzo el final del cursor entonces salir del ciclo repetitivo
        IF done THEN
            LEAVE CursorDirector_loop;
        END IF;
        IF nameStatus IS NULL THEN
            SET nameStatus = '';
        END IF;
        SET @_oStatement = CONCAT('INSERT INTO status (status) VALUES (\'',nameStatus,'\');');
        PREPARE sent1 FROM @_oStatement;
        EXECUTE sent1;
        DEALLOCATE PREPARE sent1;
    END LOOP;
    CLOSE CursorStatus;
END $$
DELIMITER ;

CALL TablaStatus ();

-- Tabla Movie--
DROP PROCEDURE IF EXISTS TablaMovie;
DELIMITER $$
CREATE PROCEDURE TablaMovie()
BEGIN
    DECLARE done INT DEFAULT FALSE;
    DECLARE MovidMovie INT;
    DECLARE `Movindex` INT;
    DECLARE Movbudget BIGINT;
    DECLARE Movhomepage VARCHAR(1000);
    DECLARE Movoriginal_title VARCHAR(1000) ;
    DECLARE Movoverview VARCHAR(5000);
    DECLARE Movpopularity DOUBLE;
    DECLARE Movrelease_date DATE;
    DECLARE Movrevenue BIGINT;
    DECLARE Movruntime DOUBLE;
    DECLARE Movtagline VARCHAR(1000);
    DECLARE Movtitle VARCHAR(1000);
    DECLARE Moveywords TEXT;
    DECLARE Movvote_count INT;
    DECLARE Movvote_average DOUBLE;
    DECLARE MovidStatus varchar(100);
    DECLARE MovidStatusid INT;
    DECLARE MovOriginal_languge VARCHAR(100);
    DECLARE MovOriginal_langugeid INT;

    -- Declarar el cursor
    DECLARE CursorMovie CURSOR FOR
        SELECT id,`index`,budget,homepage,original_title,overview,popularity,release_date,revenue,
               runtime,tagline,title,keywords,vote_count,vote_average,status,original_language FROM movie_dataset;
    -- Declarar el handler para NOT FOUND (esto es marcar cuando el cursor ha llegado a su fin)
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;
    -- Abrir el cursor
    OPEN CursorMovie;
    CursorMovie_loop: LOOP
        FETCH CursorMovie INTO MovidMovie,`Movindex`,Movbudget,Movhomepage,Movoriginal_title,Movoverview,
            Movpopularity,Movrelease_date,Movrevenue,Movruntime,Movtagline,Movtitle,Moveywords,Movvote_count,Movvote_average,
            MovidStatus,MovOriginal_languge;
        -- Si alcanzo el final del cursor entonces salir del ciclo repetitivo
        IF done THEN
            LEAVE CursorMovie_loop;
        END IF;
        SELECT idStatus INTO MovidStatusid FROM status WHERE status.status=MovidStatus;
        SELECT idOriginal_language INTO MovOriginal_langugeid FROM original_language
        WHERE original_language.language=MovOriginal_languge;
        INSERT INTO movies
        VALUES (MovidMovie,`Movindex`, Movbudget, Movhomepage, Movoriginal_title, Movoverview, Movpopularity,
                Movrelease_date, Movrevenue, Movruntime, Movtagline, Movtitle,Moveywords,Movvote_count,
                Movvote_average,MovidStatusid,MovOriginal_langugeid);
    END LOOP;
    CLOSE CursorMovie;
END $$
DELIMITER ;

CALL TablaMovie ();

-- Tabla Companie------
DROP PROCEDURE IF EXISTS TablaCompanie ;
DELIMITER $$
CREATE PROCEDURE TablaCompanie ()
BEGIN
    DECLARE done INT DEFAULT FALSE ;
    DECLARE jsonData json ;
    DECLARE jsonId varchar(250) ;
    DECLARE jsonLabel varchar(250) ;
    DECLARE resultSTR LONGTEXT DEFAULT '';
    DECLARE i INT;
    -- Declarar el cursor
    DECLARE myCursor
        CURSOR FOR
        SELECT JSON_EXTRACT(CONVERT(production_companies USING UTF8MB4), '$[*]') FROM movie_dataset ;
    -- Declarar el handler para NOT FOUND (esto es marcar cuando el cursor ha llegado a su fin)
    DECLARE CONTINUE HANDLER
        FOR NOT FOUND SET done = TRUE ;
    -- Abrir el cursor
    OPEN myCursor  ;
    drop table  if exists production_companietem;
    SET @sql_text = 'CREATE TABLE production_companieTem ( id int, nameCom VARCHAR(100));';
    PREPARE stmt FROM @sql_text;
    EXECUTE stmt;
    DEALLOCATE PREPARE stmt;
    cursorLoop: LOOP
        FETCH myCursor INTO jsonData;
        -- Controlador para buscar cada uno de lso arrays
        SET i = 0;
        -- Si alcanzo el final del cursor entonces salir del ciclo repetitivo
        IF done THEN
            LEAVE  cursorLoop ;
        END IF ;
        IF jsonData IS NULL THEN
            SET jsonData = '[]';
        END IF;
        WHILE(JSON_EXTRACT(jsonData, CONCAT('$[', i, ']'))IS NOT NULL) DO
                SET jsonId = IFNULL(JSON_EXTRACT(jsonData,  CONCAT('$[', i, '].id')), '') ;
                SET jsonLabel = IFNULL(JSON_EXTRACT(jsonData, CONCAT('$[', i,'].name')), '') ;
                SET i = i + 1;
                SET @sql_text = CONCAT('INSERT INTO production_companieTem VALUES (', REPLACE(jsonId,'\'',''),
                                       ', ', jsonLabel, '); ');
                PREPARE stmt FROM @sql_text;
                EXECUTE stmt;
                DEALLOCATE PREPARE stmt;
            END WHILE;
    END LOOP ;
    select distinct * from production_companieTem;
    INSERT INTO production_companie
    SELECT DISTINCT id, nameCom
    FROM production_companieTem;
    drop table if exists production_companieTem;
    CLOSE myCursor ;
END$$
DELIMITER ;

CALL TablaCompanie ();


-- Tabla Countrie ----------
DROP PROCEDURE IF EXISTS TablaContries;
DELIMITER $$
CREATE PROCEDURE TablaContries ()
BEGIN
    DECLARE done INT DEFAULT FALSE ;
    DECLARE jsonData json ;
    DECLARE jsonId varchar(250) ;
    DECLARE jsonLabel varchar(250) ;
    DECLARE resultSTR LONGTEXT DEFAULT '';
    DECLARE i INT;
    -- Declarar el cursor
    DECLARE myCursor
        CURSOR FOR
        SELECT JSON_EXTRACT(CONVERT(production_countries USING UTF8MB4), '$[*]') FROM movie_dataset ;
    -- Declarar el handler para NOT FOUND (esto es marcar cuando el cursor ha llegado a su fin)
    DECLARE CONTINUE HANDLER
        FOR NOT FOUND SET done = TRUE ;
    -- Abrir el cursor
    OPEN myCursor  ;
    drop table if exists production_countriesTem;
    SET @sql_text = 'CREATE TABLE production_countriesTem ( iso_3166_1 varchar(2), nameCountrie VARCHAR(100));';
    PREPARE stmt FROM @sql_text;
    EXECUTE stmt;
    DEALLOCATE PREPARE stmt;
    cursorLoop: LOOP
        FETCH myCursor INTO jsonData;
        -- Controlador para buscar cada uno de los arrays
        SET i = 0;
        -- Si alcanzo el final del cursor entonces salir del ciclo repetitivo
        IF done THEN
            LEAVE  cursorLoop ;
        END IF ;
        WHILE(JSON_EXTRACT(jsonData, CONCAT('$[', i, ']')) IS NOT NULL) DO
                SET jsonId = IFNULL(JSON_EXTRACT(jsonData,  CONCAT('$[', i, '].iso_3166_1')), '') ;
                SET jsonLabel = IFNULL(JSON_EXTRACT(jsonData, CONCAT('$[', i,'].name')), '') ;
                SET i = i + 1;
                SET @sql_text = CONCAT('INSERT INTO production_countriesTem VALUES (',
                                       REPLACE(jsonId,'\'',''), ', ', jsonLabel, '); ');
                PREPARE stmt FROM @sql_text;
                EXECUTE stmt;
                DEALLOCATE PREPARE stmt;
            END WHILE;
    END LOOP ;
    select distinct * from production_countriesTem;
    INSERT INTO production_countrie
    SELECT DISTINCT iso_3166_1, nameCountrie
    FROM production_countriesTem;
    drop table if exists production_countriesTem;
    CLOSE myCursor ;
END$$
DELIMITER ;

CALL TablaContries();

-- Tabla Spoken_language --
DROP PROCEDURE IF EXISTS TablaSpokenLan;
DELIMITER $$
CREATE PROCEDURE TablaSpokenLan ()
BEGIN
    DECLARE done INT DEFAULT FALSE ;
    DECLARE jsonData json ;
    DECLARE jsonId varchar(250) ;
    DECLARE jsonLabel varchar(250) ;
    DECLARE resultSTR LONGTEXT DEFAULT '';
    DECLARE i INT;
    -- Declarar el cursor
    DECLARE myCursor
        CURSOR FOR
        SELECT JSON_EXTRACT(CONVERT(spoken_languages USING UTF8MB4), '$[*]') FROM movie_dataset ;
    -- Declarar el handler para NOT FOUND (esto es marcar cuando el cursor ha llegado a su fin)
    DECLARE CONTINUE HANDLER
        FOR NOT FOUND SET done = TRUE ;
    -- Abrir el cursor
    OPEN myCursor  ;
    drop table if exists production_LanguageTem;
    SET @sql_text = 'CREATE TABLE production_LanguageTem ( iso_639_1 varchar(2), nameLanguage VARCHAR(100));';
    PREPARE stmt FROM @sql_text;
    EXECUTE stmt;
    DEALLOCATE PREPARE stmt;
    cursorLoop: LOOP
        FETCH myCursor INTO jsonData;
        -- Controlador para buscar cada uno de los arrays
        SET i = 0;
        -- Si alcanzo el final del cursor entonces salir del ciclo repetitivo
        IF done THEN
            LEAVE  cursorLoop ;
        END IF ;
        WHILE(JSON_EXTRACT(jsonData, CONCAT('$[', i, ']')) IS NOT NULL) DO
                SET jsonId = IFNULL(JSON_EXTRACT(jsonData,  CONCAT('$[', i, '].iso_639_1')), '') ;
                SET jsonLabel = IFNULL(JSON_EXTRACT(jsonData, CONCAT('$[', i,'].name')), '') ;
                SET i = i + 1;
                SET @sql_text = CONCAT('INSERT INTO production_LanguageTem VALUES (', REPLACE(jsonId,'\'',''),
                                       ', ', jsonLabel, '); ');
                PREPARE stmt FROM @sql_text;
                EXECUTE stmt;
                DEALLOCATE PREPARE stmt;
            END WHILE;
    END LOOP ;
    select distinct * from production_LanguageTem;
    INSERT INTO spoken_language
    SELECT DISTINCT iso_639_1, nameLanguage
    FROM production_LanguageTem;
    drop table if exists production_LanguageTem;
    CLOSE myCursor ;
END$$
DELIMITER ;

CALL TablaSpokenLan();

-- Tabla Genre--
DROP PROCEDURE IF EXISTS TablaGenre;
DELIMITER $$
CREATE PROCEDURE TablaGenre()
BEGIN
    DECLARE done INT DEFAULT FALSE;
    DECLARE nameGenre VARCHAR(100);
    -- Declarar el cursor
    DECLARE Cursorgenre CURSOR FOR
        SELECT DISTINCT CONVERT(REPLACE(REPLACE(genres, 'Science Fiction', 'Science-Fiction'),
                                        'TV Movie', 'TV-Movie') USING UTF8MB4) from movie_dataset;
    -- Declarar el handler para NOT FOUND (esto es marcar cuando el cursor ha llegado a su fin)
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;
    -- Abrir el cursor
    OPEN Cursorgenre;
    drop table if exists temperolgenre;
    SET @sql_text = 'CREATE TABLE temperolgenre (name VARCHAR(100));';
    PREPARE stmt FROM @sql_text;
    EXECUTE stmt;
    DEALLOCATE PREPARE stmt;
    CursorDirector_loop: LOOP
        FETCH Cursorgenre INTO nameGenre;
        -- Si alcanzo el final del cursor entonces salir del ciclo repetitivo
        IF done THEN
            LEAVE CursorDirector_loop;
        END IF;
        -- Separar los géneros en una tabla temporal
        DROP TEMPORARY TABLE IF EXISTS temp_genres;
        CREATE TEMPORARY TABLE temp_genres (genre VARCHAR(50));
        SET @_genres = nameGenre;
        WHILE (LENGTH(@_genres) > 0) DO
                SET @_genre = TRIM(SUBSTRING_INDEX(@_genres, ' ', 1));
                INSERT INTO temp_genres (genre) VALUES (@_genre);
                SET @_genres = SUBSTRING(@_genres, LENGTH(@_genre) + 2);
            END WHILE;
        -- Insertar los géneros separados en filas individuales
        INSERT INTO temperolgenre (name)
        SELECT genre FROM temp_genres;
    END LOOP CursorDirector_loop;
    select distinct * from temperolgenre;
    INSERT INTO genre (name)
    SELECT DISTINCT name
    FROM temperolgenre;
    drop table if exists temperolgenre;
    CLOSE Cursorgenre;
END $$
DELIMITER ;

CALL TablaGenre();


-- Tabla Compani_Movie--
DROP PROCEDURE IF EXISTS TablaCompaMov;
DELIMITER $$
CREATE PROCEDURE TablaCompaMov ()
BEGIN
    DECLARE done INT DEFAULT FALSE;
    DECLARE idMovie int;
    DECLARE idProdComp JSON;
    DECLARE idJSON text;
    DECLARE i INT;
    -- Declarar el cursor
    DECLARE myCursor
        CURSOR FOR
        SELECT id, production_companies FROM movie_dataset;
    -- Declarar el handler para NOT FOUND (esto es marcar cuando el cursor ha llegado a su fin)
    DECLARE CONTINUE HANDLER
        FOR NOT FOUND SET done = TRUE ;
    -- Abrir el cursor
    OPEN myCursor  ;
    drop table if exists CompaMovTem;
    SET @sql_text = 'CREATE TABLE CompaMovTem ( id int, idGenre int );';
    PREPARE stmt FROM @sql_text;
    EXECUTE stmt;
    DEALLOCATE PREPARE stmt;
    cursorLoop: LOOP
        FETCH myCursor INTO idMovie, idProdComp;
        -- Controlador para buscar cada uno de los arrays
        SET i = 0;
        -- Si alcanzo el final del cursor entonces salir del ciclo repetitivo
        IF done THEN
            LEAVE  cursorLoop ;
        END IF ;
        WHILE(JSON_EXTRACT(idProdComp, CONCAT('$[', i, '].id')) IS NOT NULL) DO
                SET idJSON = JSON_EXTRACT(idProdComp,  CONCAT('$[', i, '].id')) ;
                SET i = i + 1;
                SET @sql_text = CONCAT('INSERT INTO CompaMovTem VALUES (', idMovie, ', ',
                                       REPLACE(idJSON,'\'',''), '); ');
                PREPARE stmt FROM @sql_text;
                EXECUTE stmt;
                DEALLOCATE PREPARE stmt;
            END WHILE;
    END LOOP ;
    select distinct * from CompaMovTem;
    INSERT INTO companie_movie
    SELECT DISTINCT id, idGenre
    FROM CompaMovTem;
    CLOSE myCursor ;
END$$
DELIMITER ;

CALL TablaCompaMov ();

-- -- CountriesMovies------
DROP PROCEDURE IF EXISTS TablaCounMov;
DELIMITER $$
CREATE PROCEDURE TablaCounMov ()
BEGIN
    DECLARE done INT DEFAULT FALSE;
    DECLARE idMovie int;
    DECLARE idProdCoun text;
    DECLARE idJSON text;
    DECLARE i INT;
    -- Declarar el cursor
    DECLARE myCursor
        CURSOR FOR
        SELECT id, production_countries FROM movie_dataset;
    -- Declarar el handler para NOT FOUND (esto es marcar cuando el cursor ha llegado a su fin)
    DECLARE CONTINUE HANDLER
        FOR NOT FOUND SET done = TRUE ;
    -- Abrir el cursor
    OPEN myCursor  ;
    drop table if exists MovCounTemp;
    SET @sql_text = 'CREATE TABLE MovCounTemp ( id int, idGenre varchar(255) );';
    PREPARE stmt FROM @sql_text;
    EXECUTE stmt;
    DEALLOCATE PREPARE stmt;
    cursorLoop: LOOP
        FETCH myCursor INTO idMovie, idProdCoun;
        -- Controlador para buscar cada uno de los arrays
        SET i = 0;
        -- Si alcanzo el final del cursor entonces salir del ciclo repetitivo
        IF done THEN
            LEAVE  cursorLoop ;
        END IF ;
        WHILE(JSON_EXTRACT(idProdCoun, CONCAT('$[', i, '].iso_3166_1')) IS NOT NULL) DO
                SET idJSON = JSON_EXTRACT(idProdCoun,  CONCAT('$[', i, '].iso_3166_1')) ;
                SET i = i + 1;
                SET @sql_text = CONCAT('INSERT INTO MovCounTemp VALUES (', idMovie, ', ',
                                       REPLACE(idJSON,'\'',''), '); ');
                PREPARE stmt FROM @sql_text;
                EXECUTE stmt;
                DEALLOCATE PREPARE stmt;
            END WHILE;
    END LOOP ;
    select distinct * from MovCounTemp;
    INSERT INTO countrie_movie
    SELECT DISTINCT  idGenre,id
    FROM MovCounTemp;
    CLOSE myCursor ;
END$$
DELIMITER ;

CALL TablaCounMov();

-- Tabla LanguageMovie-------------
DROP PROCEDURE IF EXISTS LanguageMovie;
DELIMITER $$
CREATE PROCEDURE LanguageMovie ()
BEGIN
    DECLARE done INT DEFAULT FALSE;
    DECLARE idMovie int;
    DECLARE idSpokLang text;
    DECLARE idJSON text;
    DECLARE i INT;
    -- Declarar el cursor
    DECLARE myCursor
        CURSOR FOR
        SELECT id, spoken_languages FROM movie_dataset;
    -- Declarar el handler para NOT FOUND (esto es marcar cuando el cursor ha llegado a su fin)
    DECLARE CONTINUE HANDLER
        FOR NOT FOUND SET done = TRUE ;
    -- Abrir el cursor
    OPEN myCursor  ;
    cursorLoop: LOOP
        FETCH myCursor INTO idMovie, idSpokLang;
        -- Controlador para buscar cada uno de los arrays
        SET i = 0;
        -- Si alcanzo el final del cursor entonces salir del ciclo repetitivo
        IF done THEN
            LEAVE  cursorLoop ;
        END IF ;
        WHILE(JSON_EXTRACT(idSpokLang, CONCAT('$[', i, '].iso_639_1')) IS NOT NULL) DO
                SET idJSON = JSON_EXTRACT(idSpokLang,  CONCAT('$[', i, '].iso_639_1')) ;
                SET i = i + 1;
                SET @sql_text = CONCAT('INSERT INTO lenguage_movie VALUES (', idMovie, ', ',
                                       REPLACE(idJSON,'\'',''), '); ');
                PREPARE stmt FROM @sql_text;
                EXECUTE stmt;
                DEALLOCATE PREPARE stmt;
            END WHILE;
    END LOOP ;
    CLOSE myCursor ;
END$$
DELIMITER ;

CALL LanguageMovie();


-- Limpieza crew
SELECT id,
       JSON_VALID(CONVERT (
               REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(crew,
                                                               '"', '\''),
                                                       '{\'', '{"'),
                                               '\': \'', '": "'),
                                       '\', \'', '", "'),
                               '\': ', '": '),
                       ', \'', ', "')
               USING UTF8mb4 )) AS Valid_YN,
       CONVERT (
               REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(crew,
                                                               '"', '\''),
                                                       '{\'', '{"'),
                                               '\': \'', '": "'),
                                       '\', \'', '", "'),
                               '\': ', '": '),
                       ', \'', ', "')
               USING UTF8mb4 ) AS crew_new,
       crew AS crew_old
FROM movie_dataset ;