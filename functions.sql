CREATE OR REPLACE FUNCTION patindex(
  pattern VARCHAR, expression VARCHAR
) RETURNS INT AS $BODY$ 
SELECT 
  COALESCE(
    STRPOS(
      $2, 
      (
        SELECT 
          (
            REGEXP_MATCHES(
              $2, 
              '(' || REPLACE(
                REPLACE(
                  TRIM($1, '%'), 
                  '%', 
                  '.*?'
                ), 
                '_', 
                '.'
              ) || ')', 
              'i'
            )
          ) [ 1 ] 
        LIMIT 
          1
      )
    ), 0
  );
$BODY$ LANGUAGE 'sql' IMMUTABLE;

CREATE OR REPLACE FUNCTION likeescape(str text) RETURNS text AS $$ 
SELECT 
  replace(
    replace(
      replace($1, '^', '^^'), 
      '%', 
      '^%'
    ), 
    '_', 
    '^_'
  );
$$ LANGUAGE sql IMMUTABLE;

CREATE or replace FUNCTION startwith(cstr text, algusosa text) RETURNS bool AS $$ 
SELECT 
  $2 is null or $1 like likeescape($2) || '%' ESCAPE '^';
$$ LANGUAGE sql IMMUTABLE;


CREATE OR REPLACE FUNCTION valida_cpf(text) RETURNS BOOLEAN AS $$ 
SELECT 
  CASE WHEN 
  (text = '11111111111' OR text = '22222222222' OR text = '99999999999') THEN FALSE
  WHEN LENGTH($1) = 11 THEN(
    SELECT 
      SUBSTR($1, 10, 1) = CAST(digit1 AS text) 
      AND SUBSTR($1, 11, 1) = CAST(digit2 AS text) 
    FROM 
      (
        SELECT 
          CASE res2 WHEN 0 THEN 0 WHEN 1 THEN 0 ELSE 11 - res2 END AS digit2, 
          digit1 
        FROM 
          (
            SELECT 
              MOD(
                SUM(
                  m * CAST(
                    SUBSTR($1, 12 - m, 1) AS INTEGER
                  )
                ) + digit1 * 2, 
                11
              ) AS res2, 
              digit1 
            FROM 
              generate_series(11, 3, -1) AS m, 
              (
                SELECT 
                  CASE res1 WHEN 0 THEN 0 WHEN 1 THEN 0 ELSE 11 - res1 END AS digit1 
                FROM 
                  (
                    SELECT 
                      MOD(
                        SUM(
                          n * CAST(
                            SUBSTR($1, 11 - n, 1) AS INTEGER
                          )
                        ), 
                        11
                      ) AS res1 
                    FROM 
                      generate_series(10, 2, -1) AS n
                  ) AS sum1
              ) AS first_digit 
            GROUP BY 
              digit1
          ) AS sum2
      ) AS first_sec_digit
  ) ELSE FALSE END;
$$ LANGUAGE 'sql' IMMUTABLE STRICT;

CREATE 
OR REPLACE FUNCTION valida_cns(cns text) returns boolean as $$ declare msg varchar(50);
primeiroNumero int;
soma int;
resto int;
dv float;
pis varchar(15);
resultado varchar(15);
begin cns = replace(
  replace(cns, '.', ''), 
  '-', 
  ''
);
if(
  cns is null 
  OR cns = '' 
  OR cns is null 
  OR LENGTH(cns) <> 15
) THEN RETURN FALSE;
END IF;
primeiroNumero = SUBSTRING(cns, 1, 1);
if (primeiroNumero = 1 or primeiroNumero = 2) THEN 
	pis = Substring(cns, 1, 11);
soma = (
  cast(
    SUBSTRING(cns, 1, 1) as integer
  ) * 15
) + (
  cast(
    SUBSTRING(cns, 2, 1) as integer
  ) * 14
) + (
  cast(
    SUBSTRING(cns, 3, 1) as integer
  ) * 13
) + (
  cast(
    SUBSTRING(cns, 4, 1) as integer
  ) * 12
) + (
  cast(
    SUBSTRING(cns, 5, 1) as integer
  ) * 11
) + (
  cast(
    SUBSTRING(cns, 6, 1) as integer
  ) * 10
) + (
  cast(
    SUBSTRING(cns, 7, 1) as integer
  ) * 9
) + (
  cast(
    SUBSTRING(cns, 8, 1) as integer
  ) * 8
) + (
  cast(
    SUBSTRING(cns, 9, 1) as integer
  ) * 7
) + (
  cast(
    SUBSTRING(cns, 10, 1) as integer
  ) * 6
) + (
  cast(
    SUBSTRING(cns, 11, 1) as integer
  ) * 5
);
resto = soma % 11;
dv = 11 - resto;
if (dv = 11) THEN dv = 0;
end IF;
if (dv = 10) THEN soma = soma + 2;
resto = soma % 11;
dv = 11 - resto;
resultado = concat(
  pis, 
  '001', 
  (dv :: text)
);
else resultado = concat(
  pis, 
  '000', 
  (dv :: text)
);
end if;
if (cns = resultado) THEN return true;
else return false;
END IF;
END IF;
if (primeiroNumero = 7 or primeiroNumero = 8 or primeiroNumero = 9) THEN 
soma = (
  cast(
    SUBSTRING(cns, 1, 1) as integer
  ) * 15
) + (
  cast(
    SUBSTRING(cns, 2, 1) as integer
  ) * 14
) + (
  cast(
    SUBSTRING(cns, 3, 1) as integer
  ) * 13
) + (
  cast(
    SUBSTRING(cns, 4, 1) as integer
  ) * 12
) + (
  cast(
    SUBSTRING(cns, 5, 1) as integer
  ) * 11
) + (
  cast(
    SUBSTRING(cns, 6, 1) as integer
  ) * 10
) + (
  cast(
    SUBSTRING(cns, 7, 1) as integer
  ) * 9
) + (
  cast(
    SUBSTRING(cns, 8, 1) as integer
  ) * 8
) + (
  cast(
    SUBSTRING(cns, 9, 1) as integer
  ) * 7
) + (
  cast(
    SUBSTRING(cns, 10, 1) as integer
  ) * 6
) + (
  cast(
    SUBSTRING(cns, 11, 1) as integer
  ) * 5
) + (
  cast(
    SUBSTRING(cns, 12, 1) as integer
  ) * 4
) + (
  cast(
    SUBSTRING(cns, 13, 1) as integer
  ) * 3
) + (
  cast(
    SUBSTRING(cns, 14, 1) as integer
  ) * 2
) + (
  cast(
    SUBSTRING(cns, 15, 1) as integer
  ) * 1
);
resto = soma % 11;
if (resto = 0) then return true;
else return false;
end IF;
end IF;
return false;
end $$ LANGUAGE plpgsql;
