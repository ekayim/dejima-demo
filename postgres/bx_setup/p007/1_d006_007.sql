
/*view definition (get):
d006_007(A, B, C) :- p_0(A, B, C).
p_0(A, B, C) :- s(A, B, C).
*/

CREATE OR REPLACE VIEW public.d006_007 AS 
SELECT __dummy__.COL0 AS A,__dummy__.COL1 AS B,__dummy__.COL2 AS C 
FROM (SELECT d006_007_a3_0.COL0 AS COL0, d006_007_a3_0.COL1 AS COL1, d006_007_a3_0.COL2 AS COL2 
FROM (SELECT p_0_a3_0.COL0 AS COL0, p_0_a3_0.COL1 AS COL1, p_0_a3_0.COL2 AS COL2 
FROM (SELECT s_a3_0.A AS COL0, s_a3_0.B AS COL1, s_a3_0.C AS COL2 
FROM public.s AS s_a3_0  ) AS p_0_a3_0  ) AS d006_007_a3_0  ) AS __dummy__;

DROP MATERIALIZED VIEW IF EXISTS public.__dummy__materialized_d006_007;

CREATE  MATERIALIZED VIEW public.__dummy__materialized_d006_007 AS 
SELECT * FROM public.d006_007;

CREATE EXTENSION IF NOT EXISTS plsh;

CREATE OR REPLACE FUNCTION public.d006_007_run_shell(text) RETURNS text AS $$
#!/bin/sh
echo "true"
$$ LANGUAGE plsh;
CREATE OR REPLACE FUNCTION public.d006_007_detect_update()
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
  IF NOT EXISTS (SELECT * FROM information_schema.tables WHERE table_name = 'd006_007_delta_action_flag') THEN
    insertion_data := (SELECT (array_to_json(array_agg(t)))::text FROM (SELECT * FROM public.d006_007 EXCEPT SELECT * FROM public.__dummy__materialized_d006_007) as t);
    IF insertion_data IS NOT DISTINCT FROM NULL THEN 
        insertion_data := '[]';
    END IF; 
    deletion_data := (SELECT (array_to_json(array_agg(t)))::text FROM (SELECT * FROM public.__dummy__materialized_d006_007 EXCEPT SELECT * FROM public.d006_007) as t);
    IF deletion_data IS NOT DISTINCT FROM NULL THEN 
        deletion_data := '[]';
    END IF; 
    IF (insertion_data IS DISTINCT FROM '[]') OR (deletion_data IS DISTINCT FROM '[]') THEN 
        user_name := (SELECT session_user);
        IF NOT (user_name = 'dejima') THEN 
            json_data := concat('{"view": ' , '"public.d006_007"', ', ' , '"insertions": ' , insertion_data , ', ' , '"deletions": ' , deletion_data , '}');
            result := public.d006_007_run_shell(json_data);
            IF result = 'true' THEN 
                REFRESH MATERIALIZED VIEW public.__dummy__materialized_d006_007;
                FOR func IN (select distinct trigger_schema||'.non_trigger_'||substring(action_statement, 19) as function 
                from information_schema.triggers where trigger_schema = 'public' and event_object_table='d006_007'
                and action_timing='AFTER' and (event_manipulation='INSERT' or event_manipulation='DELETE' or event_manipulation='UPDATE')
                and action_statement like 'EXECUTE PROCEDURE %') 
                LOOP
                    EXECUTE 'SELECT ' || func into tv;
                END LOOP;
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
        RAISE object_not_in_prerequisite_state USING MESSAGE = 'no permission to insert or delete or update to source relations of public.d006_007';
    WHEN OTHERS THEN
        GET STACKED DIAGNOSTICS text_var1 = RETURNED_SQLSTATE,
                                text_var2 = PG_EXCEPTION_DETAIL,
                                text_var3 = MESSAGE_TEXT;
        RAISE SQLSTATE 'DA000' USING MESSAGE = 'error on the function (non_trigger_)public.d006_007_detect_update() ; error code: ' || text_var1 || ' ; ' || text_var2 ||' ; ' || text_var3;
        RETURN NULL;
  END;
$$;

CREATE OR REPLACE FUNCTION public.non_trigger_d006_007_detect_update()
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
  IF NOT EXISTS (SELECT * FROM information_schema.tables WHERE table_name = 'd006_007_delta_action_flag') THEN
    insertion_data := (SELECT (array_to_json(array_agg(t)))::text FROM (SELECT * FROM public.d006_007 EXCEPT SELECT * FROM public.__dummy__materialized_d006_007) as t);
    IF insertion_data IS NOT DISTINCT FROM NULL THEN 
        insertion_data := '[]';
    END IF; 
    deletion_data := (SELECT (array_to_json(array_agg(t)))::text FROM (SELECT * FROM public.__dummy__materialized_d006_007 EXCEPT SELECT * FROM public.d006_007) as t);
    IF deletion_data IS NOT DISTINCT FROM NULL THEN 
        deletion_data := '[]';
    END IF; 
    IF (insertion_data IS DISTINCT FROM '[]') OR (deletion_data IS DISTINCT FROM '[]') THEN 
        user_name := (SELECT session_user);
        -- IF NOT (user_name = 'dejima') THEN 
            json_data := concat('{"view": ' , '"public.d006_007"', ', ' , '"insertions": ' , insertion_data , ', ' , '"deletions": ' , deletion_data , '}');
            -- result := public.d006_007_run_shell(json_data);
            -- IF result = 'true' THEN 
                REFRESH MATERIALIZED VIEW public.__dummy__materialized_d006_007;
                FOR func IN (select distinct trigger_schema||'.non_trigger_'||substring(action_statement, 19) as function 
                from information_schema.triggers where trigger_schema = 'public' and event_object_table='d006_007'
                and action_timing='AFTER' and (event_manipulation='INSERT' or event_manipulation='DELETE' or event_manipulation='UPDATE')
                and action_statement like 'EXECUTE PROCEDURE %') 
                LOOP
                    EXECUTE 'SELECT ' || func into tv;
                END LOOP;
            -- ELSE
                -- -- RAISE LOG 'result from running the sh script: %', result;
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
        RAISE object_not_in_prerequisite_state USING MESSAGE = 'no permission to insert or delete or update to source relations of public.d006_007';
    WHEN OTHERS THEN
        GET STACKED DIAGNOSTICS text_var1 = RETURNED_SQLSTATE,
                                text_var2 = PG_EXCEPTION_DETAIL,
                                text_var3 = MESSAGE_TEXT;
        RAISE SQLSTATE 'DA000' USING MESSAGE = 'error on the function (non_trigger_)public.d006_007_detect_update() ; error code: ' || text_var1 || ' ; ' || text_var2 ||' ; ' || text_var3;
        RETURN NULL;
  END;
$$;

DROP TRIGGER IF EXISTS s_detect_update_d006_007 ON public.s;
        CREATE TRIGGER s_detect_update_d006_007
            AFTER INSERT OR UPDATE OR DELETE ON
            public.s FOR EACH STATEMENT EXECUTE PROCEDURE public.d006_007_detect_update();

CREATE OR REPLACE FUNCTION public.d006_007_delta_action()
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
    IF NOT EXISTS (SELECT * FROM information_schema.tables WHERE table_name = 'd006_007_delta_action_flag') THEN
        -- RAISE LOG 'execute procedure d006_007_delta_action';
        CREATE TEMPORARY TABLE d006_007_delta_action_flag ON COMMIT DROP AS (SELECT true as finish);
        IF EXISTS (SELECT WHERE false )
        THEN 
          RAISE check_violation USING MESSAGE = 'Invalid view update: constraints on the view are violated';
        END IF;
        IF EXISTS (SELECT WHERE false )
        THEN 
          RAISE check_violation USING MESSAGE = 'Invalid view update: constraints on the source relations are violated';
        END IF;
        CREATE TEMPORARY TABLE Δ_del_s WITH OIDS ON COMMIT DROP AS SELECT (ROW(COL0,COL1,COL2) :: public.s).* 
            FROM (SELECT Δ_del_s_a3_0.COL0 AS COL0, Δ_del_s_a3_0.COL1 AS COL1, Δ_del_s_a3_0.COL2 AS COL2 
FROM (SELECT s_a3_0.A AS COL0, s_a3_0.B AS COL1, s_a3_0.C AS COL2 
FROM public.s AS s_a3_0 
WHERE NOT EXISTS ( SELECT * 
FROM (SELECT d006_007_a3_0.A AS COL0, d006_007_a3_0.B AS COL1, d006_007_a3_0.C AS COL2 
FROM public.d006_007 AS d006_007_a3_0 
WHERE NOT EXISTS ( SELECT * 
FROM __temp__Δ_del_d006_007 AS __temp__Δ_del_d006_007_a3 
WHERE __temp__Δ_del_d006_007_a3.C = d006_007_a3_0.C AND __temp__Δ_del_d006_007_a3.B = d006_007_a3_0.B AND __temp__Δ_del_d006_007_a3.A = d006_007_a3_0.A )  UNION SELECT __temp__Δ_ins_d006_007_a3_0.A AS COL0, __temp__Δ_ins_d006_007_a3_0.B AS COL1, __temp__Δ_ins_d006_007_a3_0.C AS COL2 
FROM __temp__Δ_ins_d006_007 AS __temp__Δ_ins_d006_007_a3_0  ) AS new_d006_007_a3 
WHERE new_d006_007_a3.COL2 = s_a3_0.C AND new_d006_007_a3.COL1 = s_a3_0.B AND new_d006_007_a3.COL0 = s_a3_0.A ) ) AS Δ_del_s_a3_0  ) AS Δ_del_s_extra_alias;

CREATE TEMPORARY TABLE Δ_ins_s WITH OIDS ON COMMIT DROP AS SELECT (ROW(COL0,COL1,COL2) :: public.s).* 
            FROM (SELECT Δ_ins_s_a3_0.COL0 AS COL0, Δ_ins_s_a3_0.COL1 AS COL1, Δ_ins_s_a3_0.COL2 AS COL2 
FROM (SELECT new_d006_007_a3_0.COL0 AS COL0, new_d006_007_a3_0.COL1 AS COL1, new_d006_007_a3_0.COL2 AS COL2 
FROM (SELECT d006_007_a3_0.A AS COL0, d006_007_a3_0.B AS COL1, d006_007_a3_0.C AS COL2 
FROM public.d006_007 AS d006_007_a3_0 
WHERE NOT EXISTS ( SELECT * 
FROM __temp__Δ_del_d006_007 AS __temp__Δ_del_d006_007_a3 
WHERE __temp__Δ_del_d006_007_a3.C = d006_007_a3_0.C AND __temp__Δ_del_d006_007_a3.B = d006_007_a3_0.B AND __temp__Δ_del_d006_007_a3.A = d006_007_a3_0.A )  UNION SELECT __temp__Δ_ins_d006_007_a3_0.A AS COL0, __temp__Δ_ins_d006_007_a3_0.B AS COL1, __temp__Δ_ins_d006_007_a3_0.C AS COL2 
FROM __temp__Δ_ins_d006_007 AS __temp__Δ_ins_d006_007_a3_0  ) AS new_d006_007_a3_0 
WHERE NOT EXISTS ( SELECT * 
FROM public.s AS s_a3 
WHERE s_a3.C = new_d006_007_a3_0.COL2 AND s_a3.B = new_d006_007_a3_0.COL1 AND s_a3.A = new_d006_007_a3_0.COL0 ) ) AS Δ_ins_s_a3_0  ) AS Δ_ins_s_extra_alia 
            EXCEPT 
            SELECT * FROM  public.s; 

FOR temprecΔ_del_s IN ( SELECT * FROM Δ_del_s) LOOP 
            DELETE FROM public.s WHERE ROW(A,B,C) =  temprecΔ_del_s;
            END LOOP;
DROP TABLE Δ_del_s;

INSERT INTO public.s (SELECT * FROM  Δ_ins_s) ; 
DROP TABLE Δ_ins_s;
        
        insertion_data := (SELECT (array_to_json(array_agg(t)))::text FROM (SELECT * FROM __temp__Δ_ins_d006_007 EXCEPT SELECT * FROM public.__dummy__materialized_d006_007) as t);
        IF insertion_data IS NOT DISTINCT FROM NULL THEN 
            insertion_data := '[]';
        END IF; 
        deletion_data := (SELECT (array_to_json(array_agg(t)))::text FROM (SELECT * FROM __temp__Δ_del_d006_007 INTERSECT SELECT * FROM public.__dummy__materialized_d006_007) as t);
        IF deletion_data IS NOT DISTINCT FROM NULL THEN 
            deletion_data := '[]';
        END IF; 
        IF (insertion_data IS DISTINCT FROM '[]') OR (deletion_data IS DISTINCT FROM '[]') THEN 
            user_name := (SELECT session_user);
            IF NOT (user_name = 'dejima') THEN 
                json_data := concat('{"view": ' , '"public.d006_007"', ', ' , '"insertions": ' , insertion_data , ', ' , '"deletions": ' , deletion_data , '}');
                result := public.d006_007_run_shell(json_data);
                IF result = 'true' THEN 
                    REFRESH MATERIALIZED VIEW public.__dummy__materialized_d006_007;
                ELSE
                    -- RAISE LOG 'result from running the sh script: %', result;
                    RAISE check_violation USING MESSAGE = 'update on view is rejected by the external tool, result from running the sh script: ' 
                    || result;
                END IF;
            ELSE 
                RAISE LOG 'function of detecting dejima update is called by % , no request sent to dejima proxy', user_name;
            END IF;
        END IF;
    REFRESH MATERIALIZED VIEW public.__dummy__materialized_d006_007;
    END IF;
    RETURN NULL;
  EXCEPTION
    WHEN object_not_in_prerequisite_state THEN
        RAISE object_not_in_prerequisite_state USING MESSAGE = 'no permission to insert or delete or update to source relations of public.d006_007';
    WHEN OTHERS THEN
        GET STACKED DIAGNOSTICS text_var1 = RETURNED_SQLSTATE,
                                text_var2 = PG_EXCEPTION_DETAIL,
                                text_var3 = MESSAGE_TEXT;
        RAISE SQLSTATE 'DA000' USING MESSAGE = 'error on the trigger of public.d006_007 ; error code: ' || text_var1 || ' ; ' || text_var2 ||' ; ' || text_var3;
        RETURN NULL;
  END;
$$;

CREATE OR REPLACE FUNCTION public.d006_007_materialization()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
  DECLARE
  text_var1 text;
  text_var2 text;
  text_var3 text;
  BEGIN
    IF NOT EXISTS (SELECT * FROM information_schema.tables WHERE table_name = '__temp__Δ_ins_d006_007' OR table_name = '__temp__Δ_del_d006_007')
    THEN
        -- RAISE LOG 'execute procedure d006_007_materialization';
        CREATE TEMPORARY TABLE __temp__Δ_ins_d006_007 ( LIKE public.d006_007 INCLUDING ALL ) WITH OIDS ON COMMIT DROP;
        CREATE CONSTRAINT TRIGGER __temp__d006_007_trigger_delta_action
        AFTER INSERT OR UPDATE OR DELETE ON 
            __temp__Δ_ins_d006_007 DEFERRABLE INITIALLY IMMEDIATE 
            FOR EACH ROW EXECUTE PROCEDURE public.d006_007_delta_action();

        CREATE TEMPORARY TABLE __temp__Δ_del_d006_007 ( LIKE public.d006_007 INCLUDING ALL ) WITH OIDS ON COMMIT DROP;
        CREATE CONSTRAINT TRIGGER __temp__d006_007_trigger_delta_action
        AFTER INSERT OR UPDATE OR DELETE ON 
            __temp__Δ_del_d006_007 DEFERRABLE INITIALLY IMMEDIATE 
            FOR EACH ROW EXECUTE PROCEDURE public.d006_007_delta_action();
    END IF;
    RETURN NULL;
  EXCEPTION
    WHEN object_not_in_prerequisite_state THEN
        RAISE object_not_in_prerequisite_state USING MESSAGE = 'no permission to insert or delete or update to source relations of public.d006_007';
    WHEN OTHERS THEN
        GET STACKED DIAGNOSTICS text_var1 = RETURNED_SQLSTATE,
                                text_var2 = PG_EXCEPTION_DETAIL,
                                text_var3 = MESSAGE_TEXT;
        RAISE SQLSTATE 'DA000' USING MESSAGE = 'error on the trigger of public.d006_007 ; error code: ' || text_var1 || ' ; ' || text_var2 ||' ; ' || text_var3;
        RETURN NULL;
  END;
$$;

DROP TRIGGER IF EXISTS d006_007_trigger_materialization ON public.d006_007;
CREATE TRIGGER d006_007_trigger_materialization
    BEFORE INSERT OR UPDATE OR DELETE ON
      public.d006_007 FOR EACH STATEMENT EXECUTE PROCEDURE public.d006_007_materialization();

CREATE OR REPLACE FUNCTION public.d006_007_update()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
  DECLARE
  text_var1 text;
  text_var2 text;
  text_var3 text;
  BEGIN
    -- RAISE LOG 'execute procedure d006_007_update';
    IF TG_OP = 'INSERT' THEN
      -- RAISE LOG 'NEW: %', NEW;
      IF (SELECT count(*) FILTER (WHERE j.value = jsonb 'null') FROM  jsonb_each(to_jsonb(NEW)) j) > 0 THEN 
        RAISE check_violation USING MESSAGE = 'Invalid update on view: view does not accept null value';
      END IF;
      DELETE FROM __temp__Δ_del_d006_007 WHERE ROW(A,B,C) = NEW;
      INSERT INTO __temp__Δ_ins_d006_007 SELECT (NEW).*; 
    ELSIF TG_OP = 'UPDATE' THEN
      IF (SELECT count(*) FILTER (WHERE j.value = jsonb 'null') FROM  jsonb_each(to_jsonb(NEW)) j) > 0 THEN 
        RAISE check_violation USING MESSAGE = 'Invalid update on view: view does not accept null value';
      END IF;
      DELETE FROM __temp__Δ_ins_d006_007 WHERE ROW(A,B,C) = OLD;
      INSERT INTO __temp__Δ_del_d006_007 SELECT (OLD).*;
      DELETE FROM __temp__Δ_del_d006_007 WHERE ROW(A,B,C) = NEW;
      INSERT INTO __temp__Δ_ins_d006_007 SELECT (NEW).*; 
    ELSIF TG_OP = 'DELETE' THEN
      -- RAISE LOG 'OLD: %', OLD;
      DELETE FROM __temp__Δ_ins_d006_007 WHERE ROW(A,B,C) = OLD;
      INSERT INTO __temp__Δ_del_d006_007 SELECT (OLD).*;
    END IF;
    RETURN NULL;
  EXCEPTION
    WHEN object_not_in_prerequisite_state THEN
        RAISE object_not_in_prerequisite_state USING MESSAGE = 'no permission to insert or delete or update to source relations of public.d006_007';
    WHEN OTHERS THEN
        GET STACKED DIAGNOSTICS text_var1 = RETURNED_SQLSTATE,
                                text_var2 = PG_EXCEPTION_DETAIL,
                                text_var3 = MESSAGE_TEXT;
        RAISE SQLSTATE 'DA000' USING MESSAGE = 'error on the trigger of public.d006_007 ; error code: ' || text_var1 || ' ; ' || text_var2 ||' ; ' || text_var3;
        RETURN NULL;
  END;
$$;

DROP TRIGGER IF EXISTS d006_007_trigger_update ON public.d006_007;
CREATE TRIGGER d006_007_trigger_update
    INSTEAD OF INSERT OR UPDATE OR DELETE ON
      public.d006_007 FOR EACH ROW EXECUTE PROCEDURE public.d006_007_update();

