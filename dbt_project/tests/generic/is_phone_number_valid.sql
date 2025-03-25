{% test is_phone_number_valid(model, column_name) %}

-- Ensures that the phone number is exactly 10 digits long (no other character tyeps)

SELECT 
    {{ column_name }} 
FROM {{ model }}
WHERE NOT REGEXP_LIKE({{ column_name }}, '^[0-9]{10}$')

{% endtest %}