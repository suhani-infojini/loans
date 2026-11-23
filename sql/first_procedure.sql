create or replace procedure sp_customer_validation(p_customer_id VARCHAR)
returns varchar
language sql
as
$$
declare
    v_count number;
    v_name varchar;
    v_dob varchar;
    v_income number;
    v_employment varchar;
    v_employer varchar;
    v_email varchar;
    v_phone varchar;
    v_credit_score number;
    v_errors varchar default '';

begin
    --check if customer exists
    select count(*)
    into :v_count
    from customers
    where customer_id = :p_customer_id;
    
    if (v_count = 0) then
    return 'INVALID: Customer does not exist';
    end if;
    
    --fetch customer details
    select
        customer_name,
        date_of_birth,
        monthly_income,
        employment_type,
        employer_name,
        email,
        phone,
        credit_score
    into
        :v_name,
        :v_dob,
        :v_income,
        :v_employment,
        :v_employer,
        :v_email,
        :v_phone,
        :v_credit_score
    from customers
    where customer_id = :p_customer_id;

    --validate customer name
    if (v_name is null or trim(v_name) = '') then
        v_errors := v_errors || 'Missing customer name; ';
    end if;

    --validate date of birth
    if (try_to_date(:v_dob, 'YYYY-MM-DD') is null) then
        v_errors := v_errors || 'Invalid date of birth; ';
    else
        if (try_to_date(:v_dob, 'YYYY-MM-DD') > current_date()) then
            v_errors := v_errors || 'Date of birth cannot be in the future; ';
        else
            if (dateadd(year, 21, try_to_date(:v_dob, 'YYYY-MM-DD')) > current_date()) then
                v_errors := v_errors || 'Customer must be at least 21 years old; ';
            end if;
        end if;
    end if;

    --validate monthly income
    if (v_income <= 0) then
        v_errors := v_errors || 'Invalid monthly income; ';
    end if;

    --validate employement type
    if (upper(trim(:v_employment)) not in ('SALARIED', 'SELF-EMPLOYED')) then
        v_errors := v_errors || 'Invalid employment type; ';
    end if;

    --validate employer name
    if (v_employer is null or trim(v_employer) = '') then
        v_errors := v_errors || 'Missing employer name; ';
    end if;

    --validate email
    if (v_email is null or trim(v_email) = '') then
        v_errors := v_errors || 'Missing email; ';
    end if;

    --validate phone
    if (v_phone is null or trim(v_phone) = '') then
        v_errors := v_errors || 'Missing phone number; ';
    end if;

    --validate credit score
    if (v_credit_score is null or
        v_credit_score < 600 or v_credit_score > 900) then

        v_errors := v_errors || 'Invalid credit score; ';
    end if;

    --return result
    if (v_errors = '') then
        return 'VALID: Customer details passed all validations';
    else
        return 'INVALID: ' || v_errors;
    end if;

end;
$$;
