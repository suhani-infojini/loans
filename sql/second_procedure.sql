create or replace procedure sp_calculate_credit_eligibility(p_customer_id varchar, p_product_id varchar)
returns varchar
language sql
as
$$
declare
    v_customer_count number;
    v_product_count number;
    v_credit_score_number;
    v_min_credit_score_number;
    v_product_name varchar;

begin
    select count(*)
    into :v_customer_count
    from customers
    where customer_id = :p_customer_id;

    if (v_customer_count = 0) then
        return 'INVALID: Customer does not exist';
    end if;

    --check whether loan product exists
    select count(*)
    into :v_product_count
    from loan_products
    where product_id= :p_product_id;

    if (v_product_count=0) then 
        return 'INVALID: Loan product does not exist';
    end if;
    
    --retrieve customers score
    
    select credit_score
    into :v_credit_score
    from customers
    where customer_id = :p_customer_id;
    
    -- retrieve products credit requirements
    select min_credit_score, product_name
    into :v_min_credit_score, :v_product_name
    from loan_products
    where product_id = :p_product_id;
    
    -- check for missing credit score
    if (v_credit_score is null or v_min_credit_score is null) then
        return 'invalid: credit score information is missing';
    end if;

    -- compare credit scores
    if(v_credit_score >= v_min_credit_score) then
        return 'eligible: Customer qualifies for '
                || v_product_name
                ||'. Customer score: '
                || v_credit_score
                ||', Required score: '
                || v_min_credit_score;
    else
        return 'not eligible: Customer does not qualify for'
                || v_product_name
                ||'. Customer score: '
                || v_credit_score
                ||', Required score: '
                || v_min_credit_score;
    end if;
end;
$$;
