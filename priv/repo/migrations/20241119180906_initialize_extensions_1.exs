defmodule Warui.Repo.Migrations.InitializeExtensions1 do
  @moduledoc """
  Installs any extensions that are mentioned in the repo's `installed_extensions/0` callback

  This file was autogenerated with `mix ash_postgres.generate_migrations`
  """

  use Ecto.Migration

  def up do
    execute("""
    CREATE OR REPLACE FUNCTION ash_elixir_or(left BOOLEAN, in right ANYCOMPATIBLE, out f1 ANYCOMPATIBLE)
    AS $$ SELECT COALESCE(NULLIF($1, FALSE), $2) $$
    LANGUAGE SQL
    IMMUTABLE;
    """)

    execute("""
    CREATE OR REPLACE FUNCTION ash_elixir_or(left ANYCOMPATIBLE, in right ANYCOMPATIBLE, out f1 ANYCOMPATIBLE)
    AS $$ SELECT COALESCE($1, $2) $$
    LANGUAGE SQL
    IMMUTABLE;
    """)

    execute("""
    CREATE OR REPLACE FUNCTION ash_elixir_and(left BOOLEAN, in right ANYCOMPATIBLE, out f1 ANYCOMPATIBLE) AS $$
      SELECT CASE
        WHEN $1 IS TRUE THEN $2
        ELSE $1
      END $$
    LANGUAGE SQL
    IMMUTABLE;
    """)

    execute("""
    CREATE OR REPLACE FUNCTION ash_elixir_and(left ANYCOMPATIBLE, in right ANYCOMPATIBLE, out f1 ANYCOMPATIBLE) AS $$
      SELECT CASE
        WHEN $1 IS NOT NULL THEN $2
        ELSE $1
      END $$
    LANGUAGE SQL
    IMMUTABLE;
    """)

    execute("""
    CREATE OR REPLACE FUNCTION ash_trim_whitespace(arr text[])
    RETURNS text[] AS $$
    DECLARE
        start_index INT = 1;
        end_index INT = array_length(arr, 1);
    BEGIN
        WHILE start_index <= end_index AND arr[start_index] = '' LOOP
            start_index := start_index + 1;
        END LOOP;

        WHILE end_index >= start_index AND arr[end_index] = '' LOOP
            end_index := end_index - 1;
        END LOOP;

        IF start_index > end_index THEN
            RETURN ARRAY[]::text[];
        ELSE
            RETURN arr[start_index : end_index];
        END IF;
    END; $$
    LANGUAGE plpgsql
    IMMUTABLE;
    """)

    execute("""
    CREATE OR REPLACE FUNCTION ash_raise_error(json_data jsonb)
    RETURNS BOOLEAN AS $$
    BEGIN
        -- Raise an error with the provided JSON data.
        -- The JSON object is converted to text for inclusion in the error message.
        RAISE EXCEPTION 'ash_error: %', json_data::text;
        RETURN NULL;
    END;
    $$ LANGUAGE plpgsql;
    """)

    execute("""
    CREATE OR REPLACE FUNCTION ash_raise_error(json_data jsonb, type_signal ANYCOMPATIBLE)
    RETURNS ANYCOMPATIBLE AS $$
    BEGIN
        -- Raise an error with the provided JSON data.
        -- The JSON object is converted to text for inclusion in the error message.
        RAISE EXCEPTION 'ash_error: %', json_data::text;
        RETURN NULL;
    END;
    $$ LANGUAGE plpgsql;
    """)

    execute("""
    CREATE OR REPLACE FUNCTION uuid_generate_v7()
    RETURNS UUID
    AS $$
    DECLARE
      timestamp    TIMESTAMPTZ;
      microseconds INT;
    BEGIN
      timestamp    = clock_timestamp();
      microseconds = (cast(extract(microseconds FROM timestamp)::INT - (floor(extract(milliseconds FROM timestamp))::INT * 1000) AS DOUBLE PRECISION) * 4.096)::INT;

      RETURN encode(
        set_byte(
          set_byte(
            overlay(uuid_send(gen_random_uuid()) placing substring(int8send(floor(extract(epoch FROM timestamp) * 1000)::BIGINT) FROM 3) FROM 1 FOR 6
          ),
          6, (b'0111' || (microseconds >> 8)::bit(4))::bit(8)::int
        ),
        7, microseconds::bit(8)::int
      ),
      'hex')::UUID;
    END
    $$
    LANGUAGE PLPGSQL
    VOLATILE;
    """)

    execute("""
    CREATE OR REPLACE FUNCTION timestamp_from_uuid_v7(_uuid uuid)
    RETURNS TIMESTAMP WITHOUT TIME ZONE
    AS $$
      SELECT to_timestamp(('x0000' || substr(_uuid::TEXT, 1, 8) || substr(_uuid::TEXT, 10, 4))::BIT(64)::BIGINT::NUMERIC / 1000);
    $$
    LANGUAGE SQL
    IMMUTABLE PARALLEL SAFE STRICT;
    """)
  end

  def down do
    # Uncomment this if you actually want to uninstall the extensions
    # when this migration is rolled back:
    execute(
      "DROP FUNCTION IF EXISTS uuid_generate_v7(), timestamp_from_uuid_v7(uuid), ash_raise_error(jsonb), ash_raise_error(jsonb, ANYCOMPATIBLE), ash_elixir_and(BOOLEAN, ANYCOMPATIBLE), ash_elixir_and(ANYCOMPATIBLE, ANYCOMPATIBLE), ash_elixir_or(ANYCOMPATIBLE, ANYCOMPATIBLE), ash_elixir_or(BOOLEAN, ANYCOMPATIBLE), ash_trim_whitespace(text[])"
    )
  end
end
