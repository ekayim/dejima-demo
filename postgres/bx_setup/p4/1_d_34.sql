
/*view definition (get):
d_34(ID, VALUE) :- p_0(ID, VALUE).
p_0(ID, VALUE) :- s(ID, VALUE).
*/

CREATE OR REPLACE VIEW public.d_34 AS 
SELECT __dummy__.COL0 AS ID,__dummy__.COL1 AS VALUE 
FROM (SELECT d_34_a2_0.COL0 AS COL0, d_34_a2_0.COL1 AS COL1 
FROM (SELECT p_0_a2_0.COL0 AS COL0, p_0_a2_0.COL1 AS COL1 
FROM (SELECT s_a2_0.ID AS COL0, s_a2_0.VALUE AS COL1 
FROM public.s AS s_a2_0  ) AS p_0_a2_0  ) AS d_34_a2_0  ) AS __dummy__;

CREATE EXTENSION IF NOT EXISTS plsh;

CREATE OR REPLACE FUNCTION public.d_34_run_shell(text) RETURNS text AS $$
#!/bin/sh
echo "true"
$$ LANGUAGE plsh;

CREATE OR REPLACE FUNCTION public.s_materialization()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
text_var1 text;
text_var2 text;
text_var3 text;
BEGIN
    IF NOT EXISTS (SELECT * FROM information_schema.tables WHERE table_name = '__temp__Δ_ins_s' OR table_name = '__temp__Δ_del_s')
    THEN
        -- RAISE LOG 'execute procedure s_materialization';
        CREATE TEMPORARY TABLE __temp__Δ_ins_s ( LIKE public.s INCLUDING ALL ) WITH OIDS ON COMMIT DROP;
        CREATE TEMPORARY TABLE __temp__Δ_del_s ( LIKE public.s INCLUDING ALL ) WITH OIDS ON COMMIT DROP;
        CREATE TEMPORARY TABLE __temp__s WITH OIDS ON COMMIT DROP AS (SELECT * FROM public.s);
        
    END IF;
    RETURN NULL;
EXCEPTION
    WHEN object_not_in_prerequisite_state THEN
        RAISE object_not_in_prerequisite_state USING MESSAGE = 'no permission to insert or delete or update to public.s';
    WHEN OTHERS THEN
        GET STACKED DIAGNOSTICS text_var1 = RETURNED_SQLSTATE,
                                text_var2 = PG_EXCEPTION_DETAIL,
                                text_var3 = MESSAGE_TEXT;
        RAISE SQLSTATE 'DA000' USING MESSAGE = 'error on the trigger of public.s ; error code: ' || text_var1 || ' ; ' || text_var2 ||' ; ' || text_var3;
        RETURN NULL;
END;
$$;

DROP TRIGGER IF EXISTS s_trigger_materialization ON public.s;
CREATE TRIGGER s_trigger_materialization
    BEFORE INSERT OR UPDATE OR DELETE ON
    public.s FOR EACH STATEMENT EXECUTE PROCEDURE public.s_materialization();

CREATE OR REPLACE FUNCTION public.s_update()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
text_var1 text;
text_var2 text;
text_var3 text;
BEGIN
    -- RAISE LOG 'execute procedure s_update';
    IF TG_OP = 'INSERT' THEN
    -- RAISE LOG 'NEW: %', NEW;
    IF (SELECT count(*) FILTER (WHERE j.value = jsonb 'null') FROM  jsonb_each(to_jsonb(NEW)) j) > 0 THEN 
        RAISE check_violation USING MESSAGE = 'Invalid update: null value is not accepted';
    END IF;
    DELETE FROM __temp__Δ_del_s WHERE ROW(ID,VALUE) = NEW;
    INSERT INTO __temp__Δ_ins_s SELECT (NEW).*; 
    ELSIF TG_OP = 'UPDATE' THEN
    IF (SELECT count(*) FILTER (WHERE j.value = jsonb 'null') FROM  jsonb_each(to_jsonb(NEW)) j) > 0 THEN 
        RAISE check_violation USING MESSAGE = 'Invalid update: null value is not accepted';
    END IF;
    DELETE FROM __temp__Δ_ins_s WHERE ROW(ID,VALUE) = OLD;
    INSERT INTO __temp__Δ_del_s SELECT (OLD).*;
    DELETE FROM __temp__Δ_del_s WHERE ROW(ID,VALUE) = NEW;
    INSERT INTO __temp__Δ_ins_s SELECT (NEW).*; 
    ELSIF TG_OP = 'DELETE' THEN
    -- RAISE LOG 'OLD: %', OLD;
    DELETE FROM __temp__Δ_ins_s WHERE ROW(ID,VALUE) = OLD;
    INSERT INTO __temp__Δ_del_s SELECT (OLD).*;
    END IF;
    RETURN NULL;
EXCEPTION
    WHEN object_not_in_prerequisite_state THEN
        RAISE object_not_in_prerequisite_state USING MESSAGE = 'no permission to insert or delete or update to public.s';
    WHEN OTHERS THEN
        GET STACKED DIAGNOSTICS text_var1 = RETURNED_SQLSTATE,
                                text_var2 = PG_EXCEPTION_DETAIL,
                                text_var3 = MESSAGE_TEXT;
        RAISE SQLSTATE 'DA000' USING MESSAGE = 'error on the trigger of public.s ; error code: ' || text_var1 || ' ; ' || text_var2 ||' ; ' || text_var3;
        RETURN NULL;
END;
$$;

DROP TRIGGER IF EXISTS s_trigger_update ON public.s;
CREATE TRIGGER s_trigger_update
    AFTER INSERT OR UPDATE OR DELETE ON
    public.s FOR EACH ROW EXECUTE PROCEDURE public.s_update();

CREATE OR REPLACE FUNCTION public.s_detect_update_on_d_34()
RETURNS trigger
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
text_var1 text;
text_var2 text;
text_var3 text;
func text;
tv text;
deletion_data text;
insertion_data text;
json_data text;
result text;
user_name text;
BEGIN
IF NOT EXISTS (SELECT * FROM information_schema.tables WHERE table_name = 'd_34_delta_action_flag') THEN
    insertion_data := (SELECT (array_to_json(array_agg(t)))::text FROM (SELECT __dummy__.COL0 AS ID,__dummy__.COL1 AS VALUE 
FROM (SELECT ∂_ins_d_34_a2_0.COL0 AS COL0, ∂_ins_d_34_a2_0.COL1 AS COL1 
FROM (SELECT p_0_a2_0.COL0 AS COL0, p_0_a2_0.COL1 AS COL1 
FROM (SELECT __temp__Δ_ins_s_a2_0.ID AS COL0, __temp__Δ_ins_s_a2_0.VALUE AS COL1 
FROM __temp__Δ_ins_s AS __temp__Δ_ins_s_a2_0  ) AS p_0_a2_0  ) AS ∂_ins_d_34_a2_0  ) AS __dummy__) as t);
    IF insertion_data IS NOT DISTINCT FROM NULL THEN 
        insertion_data := '[]';
    END IF; 
    deletion_data := (SELECT (array_to_json(array_agg(t)))::text FROM (SELECT __dummy__.COL0 AS ID,__dummy__.COL1 AS VALUE 
FROM (SELECT ∂_del_d_34_a2_0.COL0 AS COL0, ∂_del_d_34_a2_0.COL1 AS COL1 
FROM (SELECT p_0_a2_0.COL0 AS COL0, p_0_a2_0.COL1 AS COL1 
FROM (SELECT __temp__Δ_del_s_a2_0.ID AS COL0, __temp__Δ_del_s_a2_0.VALUE AS COL1 
FROM __temp__Δ_del_s AS __temp__Δ_del_s_a2_0  ) AS p_0_a2_0  ) AS ∂_del_d_34_a2_0  ) AS __dummy__) as t);
    IF deletion_data IS NOT DISTINCT FROM NULL THEN 
        deletion_data := '[]';
    END IF; 
    IF (insertion_data IS DISTINCT FROM '[]') OR (deletion_data IS DISTINCT FROM '[]') THEN 
        user_name := (SELECT session_user);
        IF NOT (user_name = 'dejima') THEN 
            json_data := concat('{"view": ' , '"public.d_34"', ', ' , '"insertions": ' , insertion_data , ', ' , '"deletions": ' , deletion_data , '}');
            result := public.d_34_run_shell(json_data);
            IF result = 'true' THEN 
                DROP TABLE __temp__Δ_ins_s;
                DROP TABLE __temp__Δ_del_s;
                DROP TABLE __temp__s;
            ELSE
                -- RAISE LOG 'result from running the sh script: %', result;
                RAISE check_violation USING MESSAGE = 'update on view is rejected by the external tool, result from running the sh script: ' 
                || result;
            END IF;
        ELSE 
            RAISE LOG 'function of detecting dejima update is called by % , no request sent to dejima proxy', user_name;
        END IF;
    END IF;
END IF;
RETURN NULL;
EXCEPTION
    WHEN object_not_in_prerequisite_state THEN
        RAISE object_not_in_prerequisite_state USING MESSAGE = 'no permission to insert or delete or update to public.s';
    WHEN OTHERS THEN
        GET STACKED DIAGNOSTICS text_var1 = RETURNED_SQLSTATE,
                                text_var2 = PG_EXCEPTION_DETAIL,
                                text_var3 = MESSAGE_TEXT;
        RAISE SQLSTATE 'DA000' USING MESSAGE = 'error on the function public.s_detect_update_on_d_34() ; error code: ' || text_var1 || ' ; ' || text_var2 ||' ; ' || text_var3;
        RETURN NULL;
END;
$$;

CREATE OR REPLACE FUNCTION public.non_trigger_d_34_detect_update()
RETURNS text
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
text_var1 text;
text_var2 text;
text_var3 text;
func text;
tv text;
deletion_data text;
insertion_data text;
json_data text;
result text;
user_name text;
BEGIN
IF NOT EXISTS (SELECT * FROM information_schema.tables WHERE table_name = 'd_34_delta_action_flag') THEN
    insertion_data := (SELECT (array_to_json(array_agg(t)))::text FROM (SELECT __dummy__.COL0 AS ID,__dummy__.COL1 AS VALUE 
FROM (SELECT ∂_ins_d_34_a2_0.COL0 AS COL0, ∂_ins_d_34_a2_0.COL1 AS COL1 
FROM (SELECT p_0_a2_0.COL0 AS COL0, p_0_a2_0.COL1 AS COL1 
FROM (SELECT __temp__Δ_ins_s_a2_0.ID AS COL0, __temp__Δ_ins_s_a2_0.VALUE AS COL1 
FROM __temp__Δ_ins_s AS __temp__Δ_ins_s_a2_0  ) AS p_0_a2_0  ) AS ∂_ins_d_34_a2_0  ) AS __dummy__) as t);
    IF insertion_data IS NOT DISTINCT FROM NULL THEN 
        insertion_data := '[]';
    END IF; 
    deletion_data := (SELECT (array_to_json(array_agg(t)))::text FROM (SELECT __dummy__.COL0 AS ID,__dummy__.COL1 AS VALUE 
FROM (SELECT ∂_del_d_34_a2_0.COL0 AS COL0, ∂_del_d_34_a2_0.COL1 AS COL1 
FROM (SELECT p_0_a2_0.COL0 AS COL0, p_0_a2_0.COL1 AS COL1 
FROM (SELECT __temp__Δ_del_s_a2_0.ID AS COL0, __temp__Δ_del_s_a2_0.VALUE AS COL1 
FROM __temp__Δ_del_s AS __temp__Δ_del_s_a2_0  ) AS p_0_a2_0  ) AS ∂_del_d_34_a2_0  ) AS __dummy__) as t);
    IF deletion_data IS NOT DISTINCT FROM NULL THEN 
        deletion_data := '[]';
    END IF; 
    IF (insertion_data IS DISTINCT FROM '[]') OR (deletion_data IS DISTINCT FROM '[]') THEN 
        -- user_name := (SELECT session_user);
        -- IF NOT (user_name = 'dejima') THEN 
            json_data := concat('{"view": ' , '"public.d_34"', ', ' , '"insertions": ' , insertion_data , ', ' , '"deletions": ' , deletion_data , '}');
            -- result := public.d_34_run_shell(json_data);
            -- IF result = 'true' THEN 
                DROP TABLE __temp__Δ_ins_s;
                DROP TABLE __temp__Δ_del_s;
                DROP TABLE __temp__s;
            -- ELSE
                -- RAISE LOG 'result from running the sh script: %', result;
                -- RAISE check_violation USING MESSAGE = 'update on view is rejected by the external tool, result from running the sh script: ' 
                -- || result;
            -- END IF;
        -- ELSE 
            -- RAISE LOG 'function of detecting dejima update is called by % , no request sent to dejima proxy', user_name;
        -- END IF;
    END IF;
END IF;
RETURN json_data;
EXCEPTION
    WHEN object_not_in_prerequisite_state THEN
        RAISE object_not_in_prerequisite_state USING MESSAGE = 'no permission to insert or delete or update to public.s';
    WHEN OTHERS THEN
        GET STACKED DIAGNOSTICS text_var1 = RETURNED_SQLSTATE,
                                text_var2 = PG_EXCEPTION_DETAIL,
                                text_var3 = MESSAGE_TEXT;
        RAISE SQLSTATE 'DA000' USING MESSAGE = 'error on the function public.s_detect_update_on_d_34() ; error code: ' || text_var1 || ' ; ' || text_var2 ||' ; ' || text_var3;
        RETURN NULL;
END;
$$;

DROP TRIGGER IF EXISTS s_detect_update_on_d_34 ON public.s;
CREATE TRIGGER s_detect_update_on_d_34
    AFTER INSERT OR UPDATE OR DELETE ON
    public.s FOR EACH STATEMENT EXECUTE PROCEDURE public.s_detect_update_on_d_34();



CREATE OR REPLACE FUNCTION public.d_34_delta_action()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
  DECLARE
  text_var1 text;
  text_var2 text;
  text_var3 text;
  deletion_data text;
  insertion_data text;
  json_data text;
  result text;
  user_name text;
  temprecΔ_del_s public.s%ROWTYPE;
temprecΔ_ins_s public.s%ROWTYPE;
  BEGIN
    -- IF NOT EXISTS (SELECT * FROM information_schema.tables WHERE table_name = 'd_34_delta_action_flag') THEN
        -- RAISE LOG 'execute procedure d_34_delta_action';
        CREATE TEMPORARY TABLE IF NOT EXISTS d_34_delta_action_flag ON COMMIT DROP AS (SELECT true as finish);
        IF EXISTS (SELECT WHERE false )
        THEN 
          RAISE check_violation USING MESSAGE = 'Invalid view update: constraints on the view are violated';
        END IF;
        IF EXISTS (SELECT WHERE false )
        THEN 
          RAISE check_violation USING MESSAGE = 'Invalid view update: constraints on the source relations are violated';
        END IF;
        CREATE TEMPORARY TABLE Δ_del_s WITH OIDS ON COMMIT DROP AS SELECT (ROW(COL0,COL1) :: public.s).* 
            FROM (SELECT Δ_del_s_a2_0.COL0 AS COL0, Δ_del_s_a2_0.COL1 AS COL1 
FROM (SELECT s_a2_0.ID AS COL0, s_a2_0.VALUE AS COL1 
FROM public.s AS s_a2_0 
WHERE NOT EXISTS ( SELECT * 
FROM (SELECT d_34_a2_0.ID AS COL0, d_34_a2_0.VALUE AS COL1 
FROM public.d_34 AS d_34_a2_0 
WHERE NOT EXISTS ( SELECT * 
FROM __temp__Δ_del_d_34 AS __temp__Δ_del_d_34_a2 
WHERE __temp__Δ_del_d_34_a2.VALUE = d_34_a2_0.VALUE AND __temp__Δ_del_d_34_a2.ID = d_34_a2_0.ID )  UNION SELECT __temp__Δ_ins_d_34_a2_0.ID AS COL0, __temp__Δ_ins_d_34_a2_0.VALUE AS COL1 
FROM __temp__Δ_ins_d_34 AS __temp__Δ_ins_d_34_a2_0  ) AS new_d_34_a2 
WHERE new_d_34_a2.COL1 = s_a2_0.VALUE AND new_d_34_a2.COL0 = s_a2_0.ID ) ) AS Δ_del_s_a2_0  ) AS Δ_del_s_extra_alias;

CREATE TEMPORARY TABLE Δ_ins_s WITH OIDS ON COMMIT DROP AS SELECT (ROW(COL0,COL1) :: public.s).* 
            FROM (SELECT Δ_ins_s_a2_0.COL0 AS COL0, Δ_ins_s_a2_0.COL1 AS COL1 
FROM (SELECT new_d_34_a2_0.COL0 AS COL0, new_d_34_a2_0.COL1 AS COL1 
FROM (SELECT d_34_a2_0.ID AS COL0, d_34_a2_0.VALUE AS COL1 
FROM public.d_34 AS d_34_a2_0 
WHERE NOT EXISTS ( SELECT * 
FROM __temp__Δ_del_d_34 AS __temp__Δ_del_d_34_a2 
WHERE __temp__Δ_del_d_34_a2.VALUE = d_34_a2_0.VALUE AND __temp__Δ_del_d_34_a2.ID = d_34_a2_0.ID )  UNION SELECT __temp__Δ_ins_d_34_a2_0.ID AS COL0, __temp__Δ_ins_d_34_a2_0.VALUE AS COL1 
FROM __temp__Δ_ins_d_34 AS __temp__Δ_ins_d_34_a2_0  ) AS new_d_34_a2_0 
WHERE NOT EXISTS ( SELECT * 
FROM public.s AS s_a2 
WHERE s_a2.VALUE = new_d_34_a2_0.COL1 AND s_a2.ID = new_d_34_a2_0.COL0 ) ) AS Δ_ins_s_a2_0  ) AS Δ_ins_s_extra_alia 
            EXCEPT 
            SELECT * FROM  public.s; 

FOR temprecΔ_del_s IN ( SELECT * FROM Δ_del_s) LOOP 
            DELETE FROM public.s WHERE ROW(ID,VALUE) =  temprecΔ_del_s;
            END LOOP;
DROP TABLE Δ_del_s;

INSERT INTO public.s (SELECT * FROM  Δ_ins_s) ; 
DROP TABLE Δ_ins_s;
        
        insertion_data := (SELECT (array_to_json(array_agg(t)))::text FROM (SELECT * FROM __temp__Δ_ins_d_34) as t);
        IF insertion_data IS NOT DISTINCT FROM NULL THEN 
            insertion_data := '[]';
        END IF; 
        deletion_data := (SELECT (array_to_json(array_agg(t)))::text FROM (SELECT * FROM __temp__Δ_del_d_34) as t);
        IF deletion_data IS NOT DISTINCT FROM NULL THEN 
            deletion_data := '[]';
        END IF; 
        IF (insertion_data IS DISTINCT FROM '[]') OR (deletion_data IS DISTINCT FROM '[]') THEN 
            user_name := (SELECT session_user);
            IF NOT (user_name = 'dejima') THEN 
                json_data := concat('{"view": ' , '"public.d_34"', ', ' , '"insertions": ' , insertion_data , ', ' , '"deletions": ' , deletion_data , '}');
                result := public.d_34_run_shell(json_data);
                IF NOT (result = 'true') THEN
                    -- RAISE LOG 'result from running the sh script: %', result;
                    RAISE check_violation USING MESSAGE = 'update on view is rejected by the external tool, result from running the sh script: ' 
                    || result;
                END IF;
            ELSE 
                RAISE LOG 'function of detecting dejima update is called by % , no request sent to dejima proxy', user_name;
            END IF;
        END IF;
    -- END IF;
    RETURN NULL;
  EXCEPTION
    WHEN object_not_in_prerequisite_state THEN
        RAISE object_not_in_prerequisite_state USING MESSAGE = 'no permission to insert or delete or update to source relations of public.d_34';
    WHEN OTHERS THEN
        GET STACKED DIAGNOSTICS text_var1 = RETURNED_SQLSTATE,
                                text_var2 = PG_EXCEPTION_DETAIL,
                                text_var3 = MESSAGE_TEXT;
        RAISE SQLSTATE 'DA000' USING MESSAGE = 'error on the trigger of public.d_34 ; error code: ' || text_var1 || ' ; ' || text_var2 ||' ; ' || text_var3;
        RETURN NULL;
  END;
$$;

CREATE OR REPLACE FUNCTION public.d_34_materialization()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
  DECLARE
  text_var1 text;
  text_var2 text;
  text_var3 text;
  BEGIN
    IF NOT EXISTS (SELECT * FROM information_schema.tables WHERE table_name = '__temp__Δ_ins_d_34' OR table_name = '__temp__Δ_del_d_34')
    THEN
        -- RAISE LOG 'execute procedure d_34_materialization';
        CREATE TEMPORARY TABLE __temp__Δ_ins_d_34 ( LIKE public.d_34 INCLUDING ALL ) WITH OIDS ON COMMIT DROP;
        CREATE CONSTRAINT TRIGGER __temp__d_34_trigger_delta_action
        AFTER INSERT OR UPDATE OR DELETE ON 
            __temp__Δ_ins_d_34 DEFERRABLE INITIALLY IMMEDIATE 
            FOR EACH ROW EXECUTE PROCEDURE public.d_34_delta_action();

        CREATE TEMPORARY TABLE __temp__Δ_del_d_34 ( LIKE public.d_34 INCLUDING ALL ) WITH OIDS ON COMMIT DROP;
        CREATE CONSTRAINT TRIGGER __temp__d_34_trigger_delta_action
        AFTER INSERT OR UPDATE OR DELETE ON 
            __temp__Δ_del_d_34 DEFERRABLE INITIALLY IMMEDIATE 
            FOR EACH ROW EXECUTE PROCEDURE public.d_34_delta_action();
    END IF;
    RETURN NULL;
  EXCEPTION
    WHEN object_not_in_prerequisite_state THEN
        RAISE object_not_in_prerequisite_state USING MESSAGE = 'no permission to insert or delete or update to source relations of public.d_34';
    WHEN OTHERS THEN
        GET STACKED DIAGNOSTICS text_var1 = RETURNED_SQLSTATE,
                                text_var2 = PG_EXCEPTION_DETAIL,
                                text_var3 = MESSAGE_TEXT;
        RAISE SQLSTATE 'DA000' USING MESSAGE = 'error on the trigger of public.d_34 ; error code: ' || text_var1 || ' ; ' || text_var2 ||' ; ' || text_var3;
        RETURN NULL;
  END;
$$;

DROP TRIGGER IF EXISTS d_34_trigger_materialization ON public.d_34;
CREATE TRIGGER d_34_trigger_materialization
    BEFORE INSERT OR UPDATE OR DELETE ON
      public.d_34 FOR EACH STATEMENT EXECUTE PROCEDURE public.d_34_materialization();

CREATE OR REPLACE FUNCTION public.d_34_update()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
  DECLARE
  text_var1 text;
  text_var2 text;
  text_var3 text;
  BEGIN
    -- RAISE LOG 'execute procedure d_34_update';
    IF TG_OP = 'INSERT' THEN
      -- RAISE LOG 'NEW: %', NEW;
      IF (SELECT count(*) FILTER (WHERE j.value = jsonb 'null') FROM  jsonb_each(to_jsonb(NEW)) j) > 0 THEN 
        RAISE check_violation USING MESSAGE = 'Invalid update on view: view does not accept null value';
      END IF;
      DELETE FROM __temp__Δ_del_d_34 WHERE ROW(ID,VALUE) = NEW;
      INSERT INTO __temp__Δ_ins_d_34 SELECT (NEW).*; 
    ELSIF TG_OP = 'UPDATE' THEN
      IF (SELECT count(*) FILTER (WHERE j.value = jsonb 'null') FROM  jsonb_each(to_jsonb(NEW)) j) > 0 THEN 
        RAISE check_violation USING MESSAGE = 'Invalid update on view: view does not accept null value';
      END IF;
      DELETE FROM __temp__Δ_ins_d_34 WHERE ROW(ID,VALUE) = OLD;
      INSERT INTO __temp__Δ_del_d_34 SELECT (OLD).*;
      DELETE FROM __temp__Δ_del_d_34 WHERE ROW(ID,VALUE) = NEW;
      INSERT INTO __temp__Δ_ins_d_34 SELECT (NEW).*; 
    ELSIF TG_OP = 'DELETE' THEN
      -- RAISE LOG 'OLD: %', OLD;
      DELETE FROM __temp__Δ_ins_d_34 WHERE ROW(ID,VALUE) = OLD;
      INSERT INTO __temp__Δ_del_d_34 SELECT (OLD).*;
    END IF;
    RETURN NULL;
  EXCEPTION
    WHEN object_not_in_prerequisite_state THEN
        RAISE object_not_in_prerequisite_state USING MESSAGE = 'no permission to insert or delete or update to source relations of public.d_34';
    WHEN OTHERS THEN
        GET STACKED DIAGNOSTICS text_var1 = RETURNED_SQLSTATE,
                                text_var2 = PG_EXCEPTION_DETAIL,
                                text_var3 = MESSAGE_TEXT;
        RAISE SQLSTATE 'DA000' USING MESSAGE = 'error on the trigger of public.d_34 ; error code: ' || text_var1 || ' ; ' || text_var2 ||' ; ' || text_var3;
        RETURN NULL;
  END;
$$;

DROP TRIGGER IF EXISTS d_34_trigger_update ON public.d_34;
CREATE TRIGGER d_34_trigger_update
    INSTEAD OF INSERT OR UPDATE OR DELETE ON
      public.d_34 FOR EACH ROW EXECUTE PROCEDURE public.d_34_update();

