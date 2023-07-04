--
-- PostgreSQL database dump
--

-- Dumped from database version 15.3
-- Dumped by pg_dump version 15.3

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: isrested(integer, date); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.isrested(team_id integer, match_date date) RETURNS integer
    LANGUAGE sql
    AS $$
    SELECT COUNT(team_id) 
    FROM Matches 
    WHERE (team_id = hometeamid OR team_id = awayteamid) 
    AND (mdate BETWEEN match_date - INTERVAL '10 days' AND match_date + INTERVAL '10 days');
$$;


ALTER FUNCTION public.isrested(team_id integer, match_date date) OWNER TO postgres;

--
-- Name: numofplayers(integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.numofplayers(team_id integer) RETURNS integer
    LANGUAGE sql
    AS $$
    SELECT count(t_id) AS num_of_players FROM Players WHERE t_id=team_id;
$$;


ALTER FUNCTION public.numofplayers(team_id integer) OWNER TO postgres;

--
-- Name: trigger_fun(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.trigger_fun() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
    BEGIN
        INSERT INTO Teams_Deleted (t_id, t_name, stadium, description, hwins, awins, hlosses, alosses, hdraws, adraws)
		VALUES (OLD.t_id, OLD.t_name, OLD.stadium, OLD.description, OLD.hwins, OLD.awins, OLD.hlosses, OLD.alosses, OLD.hdraws, OLD.adraws);
		RETURN OLD;
    END;        
$$;


ALTER FUNCTION public.trigger_fun() OWNER TO postgres;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: badgoals; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.badgoals (
    p_id integer,
    m_id integer,
    time_stamp integer
);


ALTER TABLE public.badgoals OWNER TO postgres;

--
-- Name: matches; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.matches (
    m_id integer NOT NULL,
    hometeamid integer,
    awayteamid integer,
    hscore integer,
    ascore integer,
    mdate date,
    CONSTRAINT ateam_rested CHECK ((public.isrested(awayteamid, mdate) <= 1)),
    CONSTRAINT different_teams CHECK ((hometeamid <> awayteamid)),
    CONSTRAINT hteam_rested CHECK ((public.isrested(hometeamid, mdate) <= 1))
);


ALTER TABLE public.matches OWNER TO postgres;

--
-- Name: teams; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.teams (
    t_id integer NOT NULL,
    t_name character varying(50),
    stadium character varying(50),
    description text,
    hwins integer,
    awins integer,
    hlosses integer,
    alosses integer,
    hdraws integer,
    adraws integer
);


ALTER TABLE public.teams OWNER TO postgres;

--
-- Name: championship_schedule; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.championship_schedule AS
 SELECT DISTINCT ( SELECT teams.stadium
           FROM public.teams
          WHERE (matches.hometeamid = teams.t_id)) AS match_location,
    '90'::text AS duration,
    home_team.t_name AS home_team,
    away_team.t_name AS away_team,
    matches.hscore AS home_team_score,
    matches.ascore AS away_team_score
   FROM ((public.matches
     JOIN public.teams home_team ON ((matches.hometeamid = home_team.t_id)))
     JOIN public.teams away_team ON ((matches.awayteamid = away_team.t_id)))
  WHERE ((matches.mdate >= '2022-09-01'::date) AND (matches.mdate <= '2023-06-30'::date))
  ORDER BY ( SELECT teams.stadium
           FROM public.teams
          WHERE (matches.hometeamid = teams.t_id));


ALTER TABLE public.championship_schedule OWNER TO postgres;

--
-- Name: coaches; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.coaches (
    c_id integer NOT NULL,
    c_name character varying(10),
    c_surname character varying(10),
    t_id integer,
    pos character varying(20),
    yellow_cards integer,
    red_cards integer,
    goals integer,
    active_time integer,
    description character varying(20)
);


ALTER TABLE public.coaches OWNER TO postgres;

--
-- Name: coaches_c_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.coaches_c_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.coaches_c_id_seq OWNER TO postgres;

--
-- Name: coaches_c_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.coaches_c_id_seq OWNED BY public.coaches.c_id;


--
-- Name: corners; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.corners (
    p_id integer,
    m_id integer,
    time_stamp integer
);


ALTER TABLE public.corners OWNER TO postgres;

--
-- Name: goals; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.goals (
    p_id integer,
    m_id integer,
    time_stamp integer
);


ALTER TABLE public.goals OWNER TO postgres;

--
-- Name: matches_m_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.matches_m_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.matches_m_id_seq OWNER TO postgres;

--
-- Name: matches_m_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.matches_m_id_seq OWNED BY public.matches.m_id;


--
-- Name: players; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.players (
    p_id integer NOT NULL,
    p_name character varying(10),
    p_surname character varying(10),
    t_id integer,
    pos character varying(20),
    yellow_cards integer,
    red_cards integer,
    goals integer,
    active_time integer,
    CONSTRAINT numofplayers CHECK ((public.numofplayers(t_id) < 11))
);


ALTER TABLE public.players OWNER TO postgres;

--
-- Name: red_cards; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.red_cards (
    p_id integer,
    m_id integer,
    time_stamp integer
);


ALTER TABLE public.red_cards OWNER TO postgres;

--
-- Name: yellow_cards; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.yellow_cards (
    p_id integer,
    m_id integer,
    time_stamp integer
);


ALTER TABLE public.yellow_cards OWNER TO postgres;

--
-- Name: matches_schedule; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.matches_schedule AS
 SELECT ( SELECT teams_1.stadium
           FROM public.teams teams_1
          WHERE (matches.hometeamid = teams_1.t_id)) AS match_location,
    '90'::text AS duration,
    teams.t_name AS team_name,
    matches.hscore AS host_team_score,
    matches.ascore AS away_team_score,
    players.p_name AS players_names,
    players.p_surname AS players_surnames,
    players.pos AS match_position,
    ( SELECT count(*) AS count
           FROM public.yellow_cards yellow_cards_1
          WHERE ((yellow_cards_1.p_id = players.p_id) AND (yellow_cards_1.m_id = matches.m_id))) AS yellow_cards,
    ( SELECT count(*) AS count
           FROM public.red_cards red_cards_1
          WHERE ((red_cards_1.p_id = players.p_id) AND (red_cards_1.m_id = matches.m_id))) AS red_cards,
    goals.time_stamp AS goal_time
   FROM (((((public.matches
     JOIN public.teams ON (((matches.hometeamid = teams.t_id) OR (matches.awayteamid = teams.t_id))))
     JOIN public.players ON ((teams.t_id = players.t_id)))
     LEFT JOIN public.goals ON (((goals.p_id = players.p_id) AND (goals.m_id = matches.m_id))))
     LEFT JOIN public.yellow_cards ON (((yellow_cards.p_id = players.p_id) AND (yellow_cards.m_id = matches.m_id))))
     LEFT JOIN public.red_cards ON (((red_cards.p_id = players.p_id) AND (red_cards.m_id = matches.m_id))))
  WHERE (matches.mdate = '2022-02-01'::date)
  ORDER BY teams.t_name;


ALTER TABLE public.matches_schedule OWNER TO postgres;

--
-- Name: penalties; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.penalties (
    p_id integer,
    m_id integer,
    time_stamp integer
);


ALTER TABLE public.penalties OWNER TO postgres;

--
-- Name: players_p_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.players_p_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.players_p_id_seq OWNER TO postgres;

--
-- Name: players_p_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.players_p_id_seq OWNED BY public.players.p_id;


--
-- Name: teams_deleted; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.teams_deleted (
    t_id integer,
    t_name character varying(50),
    stadium character varying(50),
    description text,
    hwins integer,
    awins integer,
    hlosses integer,
    alosses integer,
    hdraws integer,
    adraws integer
);


ALTER TABLE public.teams_deleted OWNER TO postgres;

--
-- Name: teams_t_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.teams_t_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.teams_t_id_seq OWNER TO postgres;

--
-- Name: teams_t_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.teams_t_id_seq OWNED BY public.teams.t_id;


--
-- Name: coaches c_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.coaches ALTER COLUMN c_id SET DEFAULT nextval('public.coaches_c_id_seq'::regclass);


--
-- Name: matches m_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.matches ALTER COLUMN m_id SET DEFAULT nextval('public.matches_m_id_seq'::regclass);


--
-- Name: players p_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.players ALTER COLUMN p_id SET DEFAULT nextval('public.players_p_id_seq'::regclass);


--
-- Name: teams t_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.teams ALTER COLUMN t_id SET DEFAULT nextval('public.teams_t_id_seq'::regclass);


--
-- Data for Name: badgoals; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.badgoals (p_id, m_id, time_stamp) FROM stdin;
41	50	34
7	59	34
40	39	56
50	56	17
35	60	41
40	57	88
21	54	34
50	41	49
28	40	11
25	53	50
44	49	25
13	62	38
11	48	65
16	62	44
46	36	40
9	62	61
23	52	64
16	52	55
37	59	66
14	55	83
22	46	8
23	41	14
19	35	90
18	55	61
46	43	50
\.


--
-- Data for Name: coaches; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.coaches (c_id, c_name, c_surname, t_id, pos, yellow_cards, red_cards, goals, active_time, description) FROM stdin;
1	Τάκης	Κωνστάντης	1	Center back	7	2	54	17865	good listener
2	Γιάννης	Λεωντίδης	2	Right Back	10	2	84	16365	effective
3	Πέτρος	Χαρμπίλας	3	Libero	8	3	42	15584	goal setting
4	Ελένη	Γιαγίας	4	Right Back	8	6	70	14905	feedback delivery
5	Θάνος	Παππάς	5	Center Back	7	3	85	9062	empathy
6	Ειρήνη	Αλφρέντο	6	Goalkeeper	3	5	99	9075	problem-solving
7	Νίκος	Καστανάς	7	Libero	12	3	60	10327	motivational
8	Σοφία	Αλφρέντο	8	Center Back	5	6	87	10038	reflection
9	Αντώνης	Καφέτσης	9	Center back	18	2	26	10863	inpirational
10	Αλέξης	Πουλίδας	10	Left Back	7	7	41	13927	self-awareness
\.


--
-- Data for Name: corners; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.corners (p_id, m_id, time_stamp) FROM stdin;
31	54	17
31	52	30
36	56	63
36	59	37
39	42	4
48	44	45
23	41	30
6	42	32
11	34	52
38	35	26
48	48	13
29	46	80
30	44	20
31	36	9
32	62	43
49	34	45
18	50	46
41	48	30
34	44	86
49	41	37
36	50	80
45	51	49
40	34	2
31	54	26
2	51	39
34	51	29
5	42	62
29	42	29
29	43	50
48	48	52
26	52	65
46	40	28
18	40	12
26	35	71
11	36	7
33	57	64
13	40	26
9	50	57
3	50	80
14	40	46
32	37	9
33	37	9
43	42	53
11	34	87
25	52	39
33	62	62
9	56	81
23	50	11
36	41	18
25	60	12
6	54	86
28	36	49
37	40	77
10	56	20
10	49	25
43	34	43
20	50	42
4	42	15
12	44	42
50	60	64
32	42	11
10	58	60
28	40	63
47	36	76
6	59	78
26	39	79
25	54	51
2	62	21
18	40	80
26	46	78
34	48	67
33	35	21
19	44	51
2	56	16
7	53	40
14	40	11
6	59	45
11	37	41
30	36	25
37	49	7
\.


--
-- Data for Name: goals; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.goals (p_id, m_id, time_stamp) FROM stdin;
49	62	16
39	58	25
40	52	76
46	48	55
25	36	63
22	56	67
30	58	58
35	54	43
39	39	11
44	52	51
32	36	64
22	48	57
10	35	22
17	46	70
18	56	44
4	35	53
47	36	31
17	37	62
5	48	85
49	51	63
39	35	88
29	49	17
32	56	11
40	44	77
29	41	66
24	35	8
21	53	28
9	62	12
32	42	67
11	54	66
48	57	14
47	49	11
8	44	3
40	35	69
23	50	77
38	53	57
27	40	62
26	46	58
15	59	66
45	41	56
50	37	29
4	51	83
5	42	71
15	43	51
15	55	4
38	50	22
50	42	49
4	57	63
3	41	83
27	42	75
36	42	8
32	49	25
12	41	4
9	40	52
22	46	42
28	39	65
37	50	3
42	51	83
1	53	1
42	62	86
27	59	18
39	57	55
29	57	10
5	52	59
32	53	52
35	49	88
26	46	74
39	57	58
1	36	37
5	52	10
49	60	47
16	37	29
40	48	75
34	58	81
29	35	9
32	40	21
6	59	25
25	35	54
5	62	76
49	39	47
\.


--
-- Data for Name: matches; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.matches (m_id, hometeamid, awayteamid, hscore, ascore, mdate) FROM stdin;
34	10	6	2	7	2022-03-22
35	3	6	1	8	2022-05-20
36	5	6	\N	\N	2023-10-11
37	7	4	1	5	2022-06-25
39	2	3	\N	\N	2023-08-27
40	2	9	4	20	2022-01-16
41	6	1	\N	\N	2023-07-03
42	1	2	\N	\N	2024-04-04
44	9	8	\N	\N	2023-07-19
46	4	8	\N	\N	2023-09-10
48	1	7	7	9	2023-06-19
49	9	6	6	2	2022-02-01
50	7	4	\N	\N	2024-02-12
51	2	5	1	4	2022-02-06
52	5	6	\N	\N	2023-07-29
53	8	9	\N	\N	2024-03-19
54	9	10	2	19	2022-05-23
55	9	8	7	10	2022-07-31
56	3	10	1	17	2022-10-14
57	1	9	1	6	2023-02-12
58	10	1	1	3	2022-07-03
59	6	8	\N	\N	2024-01-18
60	8	2	4	8	2023-06-24
62	10	3	6	19	2023-02-26
43	3	1	\N	\N	2023-10-11
\.


--
-- Data for Name: penalties; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.penalties (p_id, m_id, time_stamp) FROM stdin;
48	48	37
2	58	85
41	48	80
5	40	64
11	43	76
24	51	15
23	46	59
48	52	17
4	60	24
41	35	39
23	34	54
32	55	45
5	49	62
36	40	78
4	49	86
35	53	8
15	60	29
46	49	64
35	39	38
41	39	35
44	54	79
32	48	82
12	56	21
8	49	76
35	57	72
17	35	75
30	49	75
26	55	74
42	59	26
33	49	64
40	60	45
31	53	79
3	50	46
32	62	30
16	48	50
28	51	83
9	46	1
15	39	85
23	50	84
49	59	57
15	43	60
8	44	5
25	42	17
32	58	21
11	35	33
31	48	41
17	57	59
13	35	58
41	42	57
13	49	78
7	59	25
5	35	58
35	49	49
5	44	6
9	48	14
23	54	68
28	41	81
15	54	9
17	43	16
21	36	84
42	37	37
49	57	12
1	40	56
47	37	64
49	49	86
14	56	2
11	42	46
32	62	90
18	58	71
8	39	87
7	43	6
44	37	67
28	60	52
37	41	28
1	34	54
46	42	63
15	56	14
37	57	83
48	35	58
31	35	18
39	50	79
46	43	35
21	36	74
31	39	51
21	42	65
14	39	90
31	40	53
\.


--
-- Data for Name: players; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.players (p_id, p_name, p_surname, t_id, pos, yellow_cards, red_cards, goals, active_time) FROM stdin;
1	Γιάννης	Καφίρη	4	Centre-back	7	1	0	584
2	Βίκυ	Λεωντίδης	10	Midfielder	9	4	6	765
3	Άννα	Παππάς	7	Wingback	1	5	30	481
4	Ελένη	Φρίκας	9	Sweeper	8	1	12	96
5	Σοφία	Λολίδη	10	Sweeper	4	3	5	1227
6	Γιώργος	Δημάκης	2	Wingback	2	2	9	821
7	Ελένη	Κυριακός	8	Midfielder	5	2	2	1749
8	Τάκης	Πουλίδας	7	Centre-back	4	4	12	215
9	Όλγα	Μπότσι	6	Wingback	7	1	0	1206
10	Κατερίνα	Έννο	4	Sweeper	10	1	23	285
11	Ειρήνη	Καινούριος	6	Sweeper	2	5	15	360
12	Εύα	Μπουλές	2	Sweeper	4	5	3	1511
13	Κώστας	Κυριακός	7	Wingback	3	2	18	673
14	Εύα	Πέτρου	2	Full-back	5	3	23	1560
15	Κική	Κυριακίδης	4	Wingback	6	2	15	217
16	Νίκος	Βέρο	8	Centre-back	9	1	9	1249
17	Γιάννης	Μπότσι	7	Midfielder	8	4	7	1599
18	Πάνος	Καμπάνης	8	Striker	7	2	16	1326
19	Σοφία	Λολίδη	9	Wingback	3	4	9	1402
20	Σοφία	Λολίδη	6	Wingback	5	1	8	886
21	Κική	Παπαδόπ	4	Striker	5	2	23	1147
22	Νικόλαος	Μανουσάκης	3	Sweeper	10	2	26	419
23	Κώστας	Παπαδόπ	2	Wingback	5	5	23	1513
24	Μάριος	Κυριακίδης	3	Wingback	8	4	6	1680
25	Κική	Χαρμπίλας	8	Midfielder	5	4	18	972
26	Στέλλα	Κοσμάς	3	Midfielder	10	3	0	1450
27	Γιάννης	Λολίδη	3	Full-back	7	2	7	625
28	Κατερίνα	Βέρο	8	Midfielder	5	2	23	1254
29	Γιάννης	Μαρμαράς	1	Midfielder	1	3	26	403
30	Μάριος	Γράψας	3	Midfielder	1	3	22	858
31	Όλγα	Πέτρου	2	Full-back	7	5	4	880
32	Χρήστος	Πέτρου	5	Sweeper	4	5	25	1686
33	Ελένη	Καμπάνης	6	Striker	1	5	14	1433
34	Λένα	Καινούριος	5	Sweeper	6	1	9	562
35	Κατερίνα	Πέτρου	6	Full-back	4	2	21	1524
36	Κατερίνα	Καραπέτσα	6	Striker	4	1	8	1376
37	Ελένη	Καφίρη	10	Centre-back	8	3	20	572
38	Ελένη	Καστανάς	3	Sweeper	6	4	0	716
39	Μαρίνα	Υφαντής	4	Goalkeeper	4	5	26	130
40	Βίκυ	Καμπάνης	2	Sweeper	10	2	11	1236
41	Όλγα	Καφίρη	7	Striker	4	3	28	575
42	Αλέξης	Γερανιός	9	Sweeper	1	1	14	392
43	Χρήστος	Γάλλος	2	Midfielder	3	2	11	945
44	Νίκος	Σωτηρίου	5	Wingback	4	5	28	927
45	Κική	Καφίρη	9	Midfielder	2	1	11	1048
46	Αλέξης	Καμπάνης	3	Striker	3	4	13	507
47	Μάριος	Αλφρέντο	7	Centre-back	9	2	14	625
48	Βίκυ	Μάρης	7	Full-back	3	1	21	138
49	Αντώνης	Φρίκας	9	Striker	4	4	26	317
50	Βίκυ	Μαρμαράς	5	Goalkeeper	4	1	3	1532
\.


--
-- Data for Name: red_cards; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.red_cards (p_id, m_id, time_stamp) FROM stdin;
5	51	20
8	44	55
39	56	9
44	55	43
33	52	60
17	56	85
38	52	60
10	52	63
40	36	32
22	56	74
36	56	22
50	54	32
\.


--
-- Data for Name: teams; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.teams (t_id, t_name, stadium, description, hwins, awins, hlosses, alosses, hdraws, adraws) FROM stdin;
1	Tresom	Koffiefontein	The underdog team that rose from the ashes	1	11	3	2	19	19
2	Quo Lux	Paris 20	The team with a legendary coach and a troubled past	17	4	12	10	2	12
3	Tin	Angers	The team that overcame adversity and became champions	17	20	13	5	10	8
4	Subin	Zhuxing Chaoxianzu	The team with a mysterious benefactor	12	6	5	3	5	17
5	Konklux	Ágios Athanásios	The team with a secret training regimen	1	19	2	18	9	7
6	Zontrax	Vallenar	The team with a haunted stadium	9	3	3	10	17	20
7	Bamity	Dugongan	The team with a legendary rivalry	6	5	16	9	3	5
8	Aerified	Rio Grande da Serra	The team with a cursed mascot	3	15	2	13	8	2
9	Fix San	Lazaro Cardenas	The team with a forgotten championship	13	14	7	5	13	5
10	Voltsillam	Obiliq	The team with a controversial owner	1	16	8	10	1	5
\.


--
-- Data for Name: teams_deleted; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.teams_deleted (t_id, t_name, stadium, description, hwins, awins, hlosses, alosses, hdraws, adraws) FROM stdin;
11	aek	\N	\N	\N	\N	\N	\N	\N	\N
\.


--
-- Data for Name: yellow_cards; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.yellow_cards (p_id, m_id, time_stamp) FROM stdin;
36	58	9
24	34	45
6	53	52
18	55	31
20	52	69
40	54	14
10	39	79
13	44	26
2	41	42
29	60	84
46	34	16
25	40	89
14	54	79
47	54	88
25	37	16
14	62	29
3	44	70
17	35	20
15	40	87
42	39	66
3	58	35
17	55	53
29	57	9
29	41	75
46	44	47
33	46	48
6	52	15
34	58	8
39	41	8
41	56	10
9	48	14
19	56	10
19	37	12
24	39	14
13	35	49
15	62	15
41	58	80
11	44	40
5	36	81
23	44	9
37	40	60
19	59	6
48	40	83
36	57	80
39	50	3
50	43	20
16	46	68
8	36	39
20	52	84
28	39	57
21	53	37
25	34	48
\.


--
-- Name: coaches_c_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.coaches_c_id_seq', 10, true);


--
-- Name: matches_m_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.matches_m_id_seq', 66, true);


--
-- Name: players_p_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.players_p_id_seq', 50, true);


--
-- Name: teams_t_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.teams_t_id_seq', 11, true);


--
-- Name: coaches coaches_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.coaches
    ADD CONSTRAINT coaches_pkey PRIMARY KEY (c_id);


--
-- Name: matches matches_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.matches
    ADD CONSTRAINT matches_pkey PRIMARY KEY (m_id);


--
-- Name: players players_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.players
    ADD CONSTRAINT players_pkey PRIMARY KEY (p_id);


--
-- Name: teams teams_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.teams
    ADD CONSTRAINT teams_pkey PRIMARY KEY (t_id);


--
-- Name: teams trigger_fun; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER trigger_fun AFTER DELETE ON public.teams FOR EACH ROW EXECUTE FUNCTION public.trigger_fun();


--
-- Name: badgoals badgoals_m_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.badgoals
    ADD CONSTRAINT badgoals_m_id_fkey FOREIGN KEY (m_id) REFERENCES public.matches(m_id);


--
-- Name: badgoals badgoals_p_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.badgoals
    ADD CONSTRAINT badgoals_p_id_fkey FOREIGN KEY (p_id) REFERENCES public.players(p_id);


--
-- Name: coaches coaches_t_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.coaches
    ADD CONSTRAINT coaches_t_id_fkey FOREIGN KEY (t_id) REFERENCES public.teams(t_id);


--
-- Name: corners corners_m_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.corners
    ADD CONSTRAINT corners_m_id_fkey FOREIGN KEY (m_id) REFERENCES public.matches(m_id);


--
-- Name: corners corners_p_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.corners
    ADD CONSTRAINT corners_p_id_fkey FOREIGN KEY (p_id) REFERENCES public.players(p_id);


--
-- Name: goals goals_m_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.goals
    ADD CONSTRAINT goals_m_id_fkey FOREIGN KEY (m_id) REFERENCES public.matches(m_id);


--
-- Name: goals goals_p_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.goals
    ADD CONSTRAINT goals_p_id_fkey FOREIGN KEY (p_id) REFERENCES public.players(p_id);


--
-- Name: matches matches_awayteamid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.matches
    ADD CONSTRAINT matches_awayteamid_fkey FOREIGN KEY (awayteamid) REFERENCES public.teams(t_id);


--
-- Name: matches matches_hometeamid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.matches
    ADD CONSTRAINT matches_hometeamid_fkey FOREIGN KEY (hometeamid) REFERENCES public.teams(t_id);


--
-- Name: penalties penalties_m_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.penalties
    ADD CONSTRAINT penalties_m_id_fkey FOREIGN KEY (m_id) REFERENCES public.matches(m_id);


--
-- Name: penalties penalties_p_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.penalties
    ADD CONSTRAINT penalties_p_id_fkey FOREIGN KEY (p_id) REFERENCES public.players(p_id);


--
-- Name: players players_t_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.players
    ADD CONSTRAINT players_t_id_fkey FOREIGN KEY (t_id) REFERENCES public.teams(t_id);


--
-- Name: red_cards red_cards_m_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.red_cards
    ADD CONSTRAINT red_cards_m_id_fkey FOREIGN KEY (m_id) REFERENCES public.matches(m_id);


--
-- Name: red_cards red_cards_p_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.red_cards
    ADD CONSTRAINT red_cards_p_id_fkey FOREIGN KEY (p_id) REFERENCES public.players(p_id);


--
-- Name: yellow_cards yellow_cards_m_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.yellow_cards
    ADD CONSTRAINT yellow_cards_m_id_fkey FOREIGN KEY (m_id) REFERENCES public.matches(m_id);


--
-- Name: yellow_cards yellow_cards_p_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.yellow_cards
    ADD CONSTRAINT yellow_cards_p_id_fkey FOREIGN KEY (p_id) REFERENCES public.players(p_id);


--
-- PostgreSQL database dump complete
--

