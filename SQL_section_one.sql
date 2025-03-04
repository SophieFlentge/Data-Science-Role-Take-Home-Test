//////////////////////////////////////////////////////////////////////////////
///   TAKE HOME TEST FOR DATA SCIENCE ROLE                                 ///
//////////////////////////////////////////////////////////////////////////////
------------------------------------------------------------------------------
--- This creates the dummy datasets so query will actually run             ---
------------------------------------------------------------------------------
with org_card as (select * from 
        (values (1, 'Active', 'US'),
                (2, 'Deleted', 'UK'),
                (3, 'Active', 'AU'),
                (4, 'Active', 'US'),
                (5, 'Active', 'US')) 
            as t(orgid, status, marketcode)
    ),

user_card as (select * from 
        (values(1, 1),
                (2, 0),
                (3, 0), 
                (4, 1),
                (5, 0),
                (6, 0), 
                (7, 1),
                (8, 0)) 
            as t(userid, practicestaff)
    ),

report_views as (select * from 
        (values (1, 1, '2020-09-28'::TIMESTAMP),
                (1, 2, '2021-05-01'::TIMESTAMP),
                (1, 2, '2021-05-01'::TIMESTAMP),
                (2, 3, '2021-05-01'::TIMESTAMP),
                (3, 4, '2021-05-01'::TIMESTAMP),
                (4, 5, '2021-05-01'::TIMESTAMP),
                (4, 6, '2021-05-01'::TIMESTAMP),
                (5, 7, '2021-05-01'::TIMESTAMP),
                (5, 8, '2021-05-01'::TIMESTAMP)) 
            as t(orgid, userid, visitdate)
    ),

------------------------------------------------------------------------------
--- This next part is the query for Section One                            ---
------------------------------------------------------------------------------
--
--  Write a SQL query to return a simple report of who is running this report for US-based active
--  orgs by month since 2021:
--  ● Include one or more columns to indicate the year & month
--  ● A column for how many orgs had only practice staff users running the report that month
--  ● A column for how many orgs had only non-practice staff users running the report that month
--  ● A column for how many orgs had a mix of practice staff and non practice staff running the
--    report that month

-- This CTE creates a count of distinct practice vs non practice users per org, per month.
org_users as (select date_trunc('month',t1.visitdate) as report_month,
            t3.orgid,
            count(distinct case when t2.practicestaff = 0 then t2.userid else NULL end) as non_practice_users,
            count(distinct case when t2.practicestaff = 1 then t2.userid else NULL end) as practice_users
            
        from report_views t1
            inner join user_card t2 on t1.userid = t2.userid
                inner join org_card t3 on t1.orgid = t3.orgid
    
        where t3.marketcode = 'US'
            and t3.status = 'Active'
            and t1.visitdate >= '2021-01-01'
    
        group by all
    )


-- This is the final output where orgs are counted as per their 3 category make up of users.
select date_trunc('year',t1.report_month) as report_year,
        report_month,
        sum(case when t1.non_practice_users > 0 and t1.practice_users = 0 then 1 else 0 end) as non_practice_only,
        sum(case when t1.non_practice_users = 0 and t1.practice_users > 0 then 1 else 0 end) as practice_only,
        sum(case when t1.non_practice_users > 0 and t1.practice_users > 0 then 1 else 0 end) as mixed_users,
    
    from org_users t1
    
    group by all
