-- Race view 
CREATE VIEW race_view AS 
	SELECT 
		g08.sa2_code_2021 as sa2_code_2021,
		(g08.aust_tot_resp + g08.croatian_tot_resp + g08.dutch_tot_resp + g08.english_tot_resp + g08.french_tot_resp + g08.german_tot_resp + g08.greek_tot_resp + g08.hungarian_tot_resp + g08.irish_tot_resp + g08.lebanese_tot_resp + g08.macedonian_tot_resp + g08.maltese_tot_resp + g08.nz_tot_resp + g08.polish_tot_resp + g08.russian_tot_resp + g08.scottish_tot_resp + g08.serbian_tot_resp + g08.sth_african_tot_resp + g08.spanish_tot_resp + g08.welsh_tot_resp) as white,
		0 as hispanic,
		0 as black,
		(g08.chinese_tot_resp + g08.filipino_tot_resp + g08.indian_tot_resp + g08.korean_tot_resp + g08.maori_tot_resp + g08.samoan_tot_resp + g08.sri_lankan_tot_resp + g08.vietnamese_tot_resp) as asian,
		g08.aust_abor_tot_resp as native,
		g08.tot_p_tot_resp as total
	FROM g08;

--- The main query!
SELECT
	g01.sa2_code_2021 as "ID", 						-- city identifier (SA2 code)
	substring(g01.sa2_code_2021,1,5) as "COUNTY",	-- county identifier (SA3 code)
	geog_desc."Census_Name_2021" as "NAME", 		-- city name (from SA2)
	(	SELECT "Census_Name_2021"					-- State name
		FROM geog_desc 
		WHERE "Census_Code_2021"=substring(g01.sa2_code_2021,1,1) 
	) as "STNAME",
	g01.Tot_P_P as "POPESTIMATE2015",				-- City population
	(	SELECT "Census_Name_2021"					-- County name 
		FROM geog_desc 
		WHERE "Census_Code_2021"=substring(g01.sa2_code_2021,1,5) 
	) as "CTYNAME",
	g01.tot_p_p as "TOT_POP",							-- Totoal population, and percentage as male & female 
	COALESCE(CAST(g01.tot_p_m as REAL)/NULLIF(g01.tot_p_p ,0), 0) as "TOT_MALE",
	COALESCE(CAST(g01.tot_p_f as REAL)/NULLIF(g01.tot_p_p ,0), 0) as "TOT_FEMALE",
	
	-- Race... 
	1.0 - COALESCE(CAST(race_view.asian + g01.Indigenous_psns_Aboriginal_P as REAL)/NULLIF(race_view.total, 0), 0) as "WHITE",										-- TODO: calculate this based on the other two values... 
	0 as "HISPANIC",
	0 as "BLACK",
	COALESCE(CAST(race_view.asian as REAL)/NULLIF(race_view.total, 0), 0) as "ASIAN",
	COALESCE(CAST(g01.Indigenous_psns_Aboriginal_P as REAL)/NULLIF(g01.tot_p_p ,0), 0) as "NATIVE",
	0 as "OTHER",

	-- Age groups (From G04)
	COALESCE(CAST(g04.age_yr_0_4_p as REAL)/NULLIF(g04.tot_p ,0), 0) as "1",
	COALESCE(CAST(g04.age_yr_5_9_p as REAL)/NULLIF(g04.tot_p ,0), 0) as "2",
	COALESCE(CAST(g04.age_yr_10_14_p as REAL)/NULLIF(g04.tot_p ,0), 0) as "3",
	COALESCE(CAST(g04.age_yr_15_19_p as REAL)/NULLIF(g04.tot_p ,0), 0) as "4",
	COALESCE(CAST(g04.age_yr_20_24_p as REAL)/NULLIF(g04.tot_p ,0), 0) as "5",
	COALESCE(CAST(g04.age_yr_25_29_p as REAL)/NULLIF(g04.tot_p ,0), 0) as "6",
	COALESCE(CAST(g04.age_yr_30_34_p as REAL)/NULLIF(g04.tot_p ,0), 0) as "7",
	COALESCE(CAST(g04.age_yr_35_39_p as REAL)/NULLIF(g04.tot_p ,0), 0) as "8",
	COALESCE(CAST(g04.age_yr_40_44_p as REAL)/NULLIF(g04.tot_p ,0), 0) as "9",
	COALESCE(CAST(g04.age_yr_45_49_p as REAL)/NULLIF(g04.tot_p ,0), 0) as "10",
	COALESCE(CAST(g04.age_yr_50_54_p as REAL)/NULLIF(g04.tot_p ,0), 0) as "11",
	COALESCE(CAST(g04.age_yr_55_59_p as REAL)/NULLIF(g04.tot_p ,0), 0) as "12",
	COALESCE(CAST(g04.age_yr_60_64_p as REAL)/NULLIF(g04.tot_p ,0), 0) as "13",
	COALESCE(CAST(g04.age_yr_65_69_p as REAL)/NULLIF(g04.tot_p ,0), 0) as "14",
	COALESCE(CAST(g04.age_yr_70_74_p as REAL)/NULLIF(g04.tot_p ,0), 0) as "15",
	COALESCE(CAST(g04.age_yr_75_79_p as REAL)/NULLIF(g04.tot_p ,0), 0) as "16",
	COALESCE(CAST(g04.age_yr_80_84_p as REAL)/NULLIF(g04.tot_p ,0), 0) as "17",
	COALESCE(CAST(g04.age_yr_85_89_p + g04.age_yr_90_94_p + g04.age_yr_95_99_p + g04.age_yr_100_yr_over_p as REAL)/NULLIF(g04.tot_p ,0), 0) as "18",
	
	-- Incomes (from G17 - note that these are ** weekly ** incomes, not yearly! All values are therefore multiplied by 52... )
	COALESCE(CAST(g17.p_neg_nil_income_tot + g17.p_1_149_tot + g17.p_150_299_tot as REAL)/NULLIF(g17.P_Tot_Tot ,0), 0) as "00..10", --  0  .. 10k / year
	COALESCE(CAST(g17.p_300_399_tot + g17.p_400_499_tot as REAL)/NULLIF(g17.P_Tot_Tot ,0), 0) as "10..15", -- 10k .. 15k / year
	COALESCE(CAST(g17.p_500_649_tot + g17.p_650_799_tot as REAL)/NULLIF(g17.P_Tot_Tot ,0), 0) as "15..25", -- 10k .. 15k / year
	COALESCE(CAST(g17.p_800_999_tot as REAL)/NULLIF(g17.P_Tot_Tot ,0), 0) as "25..35", -- 10k .. 15k / year
	COALESCE(CAST(g17.p_1000_1249_tot + g17.p_1250_1499_tot as REAL)/NULLIF(g17.P_Tot_Tot ,0), 0) as "35..50", -- 10k .. 15k / year
	COALESCE(CAST(g17.p_1500_1749_tot as REAL)/NULLIF(g17.P_Tot_Tot ,0), 0) as "50..75", -- 10k .. 15k / year
	COALESCE(CAST(g17.p_1750_1999_tot as REAL)/NULLIF(g17.P_Tot_Tot ,0), 0) as "75..100", -- 10k .. 15k / year
	COALESCE(CAST(g17.p_2000_2999_tot as REAL)/NULLIF(g17.P_Tot_Tot ,0), 0) as "100..150", -- 10k .. 15k / year
	COALESCE(CAST(g17.p_3000_3499_tot as REAL)/NULLIF(g17.P_Tot_Tot ,0), 0) as "150..200", -- 10k .. 15k / year
	COALESCE(CAST(g17.p_3500_more_tot as REAL)/NULLIF(g17.P_Tot_Tot ,0), 0) as "200..999", -- 10k .. 15k / year
	
	-- Education (from G1 and G49)
	COALESCE(CAST(g01.high_yr_schl_comp_yr_11_eq_p + g01.high_yr_schl_comp_yr_10_eq_p + g01.high_yr_schl_comp_yr_9_eq_p + g01.high_yr_schl_comp_yr_8_belw_p as REAL)/NULLIF(g17.P_Tot_Tot ,0), 0) as "LESS_THAN_HS",
	COALESCE(CAST(g01.High_yr_schl_comp_Yr_12_eq_P as REAL)/NULLIF(g17.P_Tot_Tot ,0), 0) as "HS",
	COALESCE(CAST(g15.tert_tot_tert_p as REAL)/NULLIF(g15.tot_p ,0), 0) as "SOME_COLLEGE",
	COALESCE(CAST(g49.p_bachdeg_total + g49.p_graddip_and_gradcert_total + g49.p_pgrad_deg_total as REAL)/NULLIF(g17.P_Tot_Tot ,0), 0) as "BS_DEGREE"
FROM 
	g01
	INNER JOIN geog_desc ON g01.sa2_code_2021=geog_desc."AGSS_Code_2021"	-- Geographic names
	INNER JOIN g04 on g01.sa2_code_2021 = g04.sa2_code_2021 				-- Age data
	INNER JOIN g08 on g01.sa2_code_2021 = g08.sa2_code_2021					-- Racial data
	INNER JOIN g17 on g01.sa2_code_2021 = g17.sa2_code_2021					-- Income
	INNER JOIN g49 on g01.sa2_code_2021 = g49.sa2_code_2021					-- Education
	INNER JOIN g15 on g01.sa2_code_2021 = g15.sa2_code_2021					-- Education (current enrolment)
	INNER JOIN race_view on g01.sa2_code_2021 = race_view.sa2_code_2021 	-- Attempt at a racial view 
	
	
--WHERE g01.sa2_code_2021='103031075'
--LIMIT(20)
;
