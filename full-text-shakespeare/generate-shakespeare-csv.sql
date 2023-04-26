.echo on
-- We want to create a simple "flat" table from the nested structure here:
--    'https://raw.githubusercontent.com/grokify/kibana-tutorial-go/master/shakespeare.json',
--
-- In addition, we need to generate a unique identifier for each line, since that is
-- required for full text search to work properly.

create table corpus as select 'x' as line_id, play_name, line_number,speaker, text_entry
  from read_json(
         'https://raw.githubusercontent.com/grokify/kibana-tutorial-go/master/shakespeare.json',
         auto_detect=true)
   where play_name is not null and line_number is not null and speaker is not null and text_entry is not null;

-- Get rid of stage directions, Act and Scene number headers, etc.

delete from corpus where line_number = '';

-- Chat GPT claims these abbreviations are commonly used by Shakespeare scholars,
-- and helpfully provides this information in the form of an update.
-- Hope Chat GPT isn't hallucinating about this!

UPDATE corpus
SET line_id = 
    CASE 
        WHEN play_name = 'Alls well that ends well' THEN 'AWW/' || line_number
        WHEN play_name = 'Antony and Cleopatra' THEN 'A&C/' || line_number
        WHEN play_name = 'As you like it' THEN 'AYLI/' || line_number
        WHEN play_name = 'A Comedy of Errors' THEN 'CE/' || line_number
        WHEN play_name = 'Coriolanus' THEN 'COR/' || line_number
        WHEN play_name = 'Cymbeline' THEN 'CYM/' || line_number
        WHEN play_name = 'Hamlet' THEN 'HAM/' || line_number
        WHEN play_name = 'Henry IV' THEN 'H4/' || line_number
        WHEN play_name = 'Henry VI Part 1' THEN '1H6/' || line_number
        WHEN play_name = 'Henry VI Part 2' THEN '2H6/' || line_number
        WHEN play_name = 'Henry VI Part 3' THEN '3H6/' || line_number
        WHEN play_name = 'Henry V' THEN 'H5/' || line_number
        WHEN play_name = 'Henry VIII' THEN 'H8/' || line_number
        WHEN play_name = 'Julius Caesar' THEN 'JC/' || line_number
        WHEN play_name = 'King John' THEN 'KJ/' || line_number
        WHEN play_name = 'King Lear' THEN 'KL/' || line_number
        WHEN play_name = 'Loves Labours Lost' THEN 'LLL/' || line_number
        WHEN play_name = 'Macbeth' THEN 'MAC/' || line_number
        WHEN play_name = 'Measure for measure' THEN 'MM/' || line_number
        WHEN play_name = 'Merchant of Venice' THEN 'MV/' || line_number
        WHEN play_name = 'Merry Wives of Windsor' THEN 'MWW/' || line_number
        WHEN play_name = 'A Midsummer nights dream' THEN 'MSND/' || line_number
        WHEN play_name = 'Much Ado about nothing' THEN 'MAAN/' || line_number
        WHEN play_name = 'Othello' THEN 'OTH/' || line_number
        WHEN play_name = 'Pericles' THEN 'PER/' || line_number
        WHEN play_name = 'Richard II' THEN 'R2/' || line_number
        WHEN play_name = 'Richard III' THEN 'R3/' || line_number
        WHEN play_name = 'Romeo and Juliet' THEN 'R&J/' || line_number
        WHEN play_name = 'Taming of the Shrew' THEN 'TOTS/' || line_number
        WHEN play_name = 'The Tempest' THEN 'TEMP/' || line_number
        ELSE 'unknown/' || line_number
    END;

-- Finally, save the data in whatever format you like.
-- Or just use it in-memory!

copy corpus TO 'shakespeare.csv' (header, delimiter '|');
copy corpus TO 'shakespeare.parquet' (format parquet, compression zstd);
