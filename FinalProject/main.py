import psycopg2

# database shenanigans
conn = psycopg2.connect(
    host="localhost",
    database="ergasia",
    user="postgres",
    password="1234")
cursor = conn.cursor()

def ShowActions():
    print("")
    print("ΕΠΙΛΟΓΕΣ:")
    print("1 - Ποιος είναι προπονητής μιας συγκεκριμένης ομάδας σε συγκεκριμένο αγώνα;")
    print("2 - Τα γκολ, πέναλτι που έγιναν σε συγκεκριμένο αγώνα, ποια χρονική στιγμή και από ποιόν παίκτη")
    print("3 - Την αγωνιστική εικόνα ενός συγκεκριμένου παίκτη για μια αγωνιστική σεζόν: γκολ, πέναλτι, κάρτες, λεπτά αγώνα, θέση που έπαιξε.")
    print("""4 - Την αγωνιστική εικόνα μιας συγκεκριμένης ομάδας για μια αγωνιστική σεζόν: σε πόσους αγώνες συμμετείχε,
    σε πόσους ήταν γηπεδούχος και σε πόσους φιλοξενούμενη, πόσες ήττες /νίκες/ ισοπαλίες, πόσες φορές νίκησε/ έχασε/ έφερε ισοπαλία εντός/ εκτός έδρας.""")
    print("")

while True:
    ShowActions()
    ans = input("Διάλεξε μια επιλογή:")
    if ans == "1":
        match_id = input("Βάλε το ID του μάτς:")
        team_name = input("Βάλε το ID της ομάδας:")
        query = """SELECT Coaches.c_name, Coaches.c_surname
                FROM Matches
                JOIN Teams ON (Matches.hometeamid = Teams.t_id OR Matches.awayteamid = Teams.t_id)
                JOIN Coaches ON Teams.t_id = Coaches.t_id
                WHERE Matches.m_id = {}
                AND Teams.t_id = {};""".format(match_id, team_name)
        cursor.execute(query)
        print("Το όνοματεπώνυμο του προπονητή είναι {}".format(cursor.fetchone()))
    elif ans == "2":
        match_id = input("Βάλε το ID του μάτς:")
        # Ολα τα goal του ματς
        query = """SELECT
                Players.p_name,
                Players.p_surname,
                Goals.time_stamp
                FROM
                Goals
                INNER JOIN Players ON Goals.p_id = Players.p_id
                INNER JOIN Matches ON Goals.m_id = Matches.m_id
                WHERE
                Matches.m_id = {};""".format(match_id)
        cursor.execute(query)
        print("Ολα τα goals (ονοματεπώνυμο, λεπτό): {}".format(cursor.fetchall()))
        # Ολα τα pentalty του ματς
        query = """SELECT
                Players.p_name,
                Players.p_surname,
                penalties.time_stamp
                FROM
                penalties
                INNER JOIN Players ON penalties.p_id = Players.p_id
                INNER JOIN Matches ON penalties.m_id = Matches.m_id
                WHERE
                Matches.m_id = {};""".format(match_id)
        cursor.execute(query)
        print("Ολα τα penalities (ονοματεπώνυμο, λεπτό): {}".format(cursor.fetchall()))
    elif ans == "3":
        player_id = input("Βάλε το ID ενος παίκτη:")
        season = input("Βάλε την χρονολογία μιας αγωνιστικής season:")
        # Goal του παικτη
        query = """SELECT COUNT(*)
                FROM Goals
                JOIN Matches ON Goals.m_id = Matches.m_id
                WHERE Goals.p_id = {}
                AND Matches.mdate BETWEEN '{}/1/1' AND '{}/12/31';""".format(player_id, season, season)
        cursor.execute(query)
        print("Goals που σκοραρε ο παίκτης: {}".format(cursor.fetchone()[0]))
        # penalty του παικτη
        query = """SELECT COUNT(*)
                FROM Penalties
                JOIN Matches ON Penalties.m_id = Matches.m_id
                WHERE Penalties.p_id = {}
                AND Matches.mdate BETWEEN '{}/1/1' AND '{}/12/31';""".format(player_id, season, season)
        cursor.execute(query)
        print("Pentalties που έκανε ο παίκτης: {}".format(cursor.fetchone()[0]))
        # Κιτρινες κάρτες του παικτη
        query = """SELECT COUNT(*)
                FROM yellow_cards
                JOIN Matches ON yellow_cards.m_id = Matches.m_id
                WHERE yellow_cards.p_id = {}
                AND Matches.mdate BETWEEN '{}/1/1' AND '{}/12/31';""".format(player_id, season, season)
        cursor.execute(query)
        print("Κίτρινες κάρτες που πείρε ο παίκτης: {}".format(cursor.fetchone()[0]))
        # Kόκκινες κάρτες του παικτη
        query = """SELECT COUNT(*)
                FROM red_cards
                JOIN Matches ON red_cards.m_id = Matches.m_id
                WHERE red_cards.p_id = {}
                AND Matches.mdate BETWEEN '{}/1/1' AND '{}/12/31';""".format(player_id, season, season)
        cursor.execute(query)
        print("Κόκκινες κάρτες που πείρε ο παίκτης: {}".format(cursor.fetchone()[0]))
        # Λεπτά αγωνισμού του παικτη
        query = """SELECT COUNT(*) * 90
                FROM Matches
                JOIN Teams ON Matches.hometeamid=Teams.t_id OR Matches.awayteamid=Teams.t_id
                JOIN Players ON Teams.t_id=Players.t_id
                WHERE Players.p_id = {}
                AND Matches.mdate BETWEEN '{}/1/1' AND '{}/12/31';""".format(player_id, season, season)
        cursor.execute(query)
        print("Έχει αγωνιστεί: {} λεπτά".format(cursor.fetchone()[0]))
        # Θέση του παικτη
        query = """SELECT pos FROM Players
                WHERE p_id = {};""".format(player_id)
        cursor.execute(query)
        print("Στην θέση: {}".format(cursor.fetchone()[0]))
    elif ans == "4":
        team_id = input("Βάλε το ID μιας ομάδας:")
        season = input("Βάλε την χρονολογία μιας αγωνιστικής season:")
        # 
        query = """SELECT
                    COUNT(*) AS total_matches,
                    SUM(CASE WHEN hscore > ascore THEN 1 ELSE 0 END),
                    SUM(CASE WHEN hscore < ascore THEN 1 ELSE 0 END),
                    SUM(CASE WHEN hscore = ascore THEN 1 ELSE 0 END)
                    FROM Matches
                    WHERE (hometeamid = {} OR awayteamid = {}) 
                    AND mdate BETWEEN '{}/1/1' AND '{}/12/31' 
                    AND (hscore IS NOT NULL or ascore IS NOT NULL);""".format(team_id, team_id, season, season)
        cursor.execute(query)
        print("συνολικα αματς (συνολικός αριθμός, νίκες, ήττες, ισοπαλίες): {}".format(cursor.fetchone()))
        # 
        query = """SELECT
                SUM(CASE WHEN hometeamid = {} THEN 1 ELSE 0 END) AS home_matches,
                SUM(CASE WHEN hometeamid = {} AND hscore > ascore THEN 1 ELSE 0 END),
                SUM(CASE WHEN hometeamid = {} AND hscore < ascore THEN 1 ELSE 0 END),
                SUM(CASE WHEN hometeamid = {} AND hscore = ascore THEN 1 ELSE 0 END)
                FROM Matches
                WHERE (hometeamid = {}) 
                AND mdate BETWEEN '{}/1/1' AND '{}/12/31' 
                AND (hscore IS NOT NULL or ascore IS NOT NULL);""".format(team_id, team_id, team_id, team_id, team_id, season, season)
        cursor.execute(query)
        print("ματς στην έδρα (συνολικός αριθμός, νίκες, ήττες, ισοπαλίες): {}".format(cursor.fetchone()))
        # 
        query = """SELECT
                SUM(CASE WHEN awayteamid = {} THEN 1 ELSE 0 END),
                SUM(CASE WHEN awayteamid = {} AND hscore < ascore THEN 1 ELSE 0 END),
                SUM(CASE WHEN awayteamid = {} AND hscore > ascore THEN 1 ELSE 0 END),
                SUM(CASE WHEN awayteamid = {} AND hscore = ascore THEN 1 ELSE 0 END)
                FROM Matches
                WHERE (awayteamid = {}) 
                AND mdate BETWEEN '{}/1/1' AND '{}/12/31' 
                AND (hscore IS NOT NULL or ascore IS NOT NULL);""".format(team_id, team_id, team_id, team_id, team_id, season, season)
        cursor.execute(query)
        print("ματς εκτός έδρας (συνολικός αριθμός, νίκες, ήττες, ισοπαλίες): {}".format(cursor.fetchone()))
    elif ans == "0":
        break
    else:
        print("Invalid input")
conn.close()