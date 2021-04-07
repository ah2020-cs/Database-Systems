import pandas as pd
import psycopg2
import streamlit as st
from configparser import ConfigParser
import re
# from datetime import datetime


'# Project Demo'


@st.cache
def get_config(filename='database.ini', section='postgresql'):
    parser = ConfigParser()
    parser.read(filename)
    return {k: v for k, v in parser.items(section)}


@st.cache
def query_db(sql: str):
    # print(f'Running query_db(): {sql}')

    db_info = get_config()

    # Connect to an existing database
    conn = psycopg2.connect(**db_info)

    # Open a cursor to perform database operations
    cur = conn.cursor()

    # Execute a command: this creates a new table
    cur.execute(sql)

    # Obtain data
    data = cur.fetchall()

    column_names = [desc[0] for desc in cur.description]

    # Make the changes to the database persistent
    conn.commit()

    # Close communication with the database
    cur.close()
    conn.close()

    df = pd.DataFrame(data=data, columns=column_names)

    return df


def etl(x, y):
    if x.empty:
        st.write(f"No search results.")
    else:
        x_dict = {}
        x_set = set()
        for _, r in x.iterrows():
            fid, name, employees, revenue, email, phone, projs = r.loc['fed_id'], r.loc['name'], \
                                                                 r.loc['num_employees'], \
                                                                 r.loc['revenue'], r.loc['email'], \
                                                                 r.loc['phone_number'], \
                                                                 r.loc['num_proj']
            if r.loc['revenue'] == -1:
                revenue = 'unknown'
            if r.loc['num_employees'] == -1:
                employees = 'unknown'
            if r.loc['email'] is None:
                email = 'unknown'
            if r.loc['phone_number'] is None:
                phone = 'unknown'
            x_info = 'Name: ' + name + '  \nNumber of Employees: ' \
                     + (employees if employees == "unknown" else "{:,}".format(employees)) \
                     + '  \nAnnual revenues: ' \
                     + (revenue if revenue == "unknown" else "${:,.2f}mm".format(revenue))
            x_contact = '  \nContract info (email / phone #): ' + (email + ' / ' + phone) + '.'
            if y == 'd' or y == 'e' or y == 'a':
                p_type = r.loc['type_name']
                reg, c_type = None, None
                if y == 'd':
                    reg = r.loc['regional_focus']
                    if r.loc['regional_focus'] is None:
                        reg = 'unknown'
                if y == 'e' or y == 'a':
                    c_type = r.loc['type']
                if fid not in x_dict:
                    x_dict[fid] = [name, (employees if employees == "unknown" else "{:,}".format(employees)),
                                   (revenue if revenue == "unknown" else "${:,.2f}mm".format(revenue)),
                                   reg if y == 'd' else c_type, [], str(projs), email, phone]
                x_dict[fid][4].append(p_type)
            if y == 'c':
                complete, under_cons = r.loc['sqft_completed_5yrs'], r.loc['sqft_under_construction']
                if r.loc['sqft_completed_5yrs'] == -1:
                    complete = 'unknown'
                if r.loc['sqft_under_construction'] == -1:
                    under_cons = 'unknown'
                x_info += '  \nSpace Completed over the past 5 years (sqft): ' \
                          + (complete if complete == "unknown" else "{:,.2f}mm".format(complete)) \
                          + '  \nSpace Currently under constructions (sqft): ' \
                          + (under_cons if under_cons == "unknown" else "{:,.2f}mm".format(under_cons)) \
                          + '  \nNumber of projects in database: ' + str(projs) \
                          + x_contact
                x_set.add(x_info)
            if y == 'l':
                maxl, minl, maxr, minr, ltc = r.loc['max_loan'], r.loc['min_loan'], r.loc['max_rate'], \
                                              r.loc['min_rate'], r.loc['max_ltc']
                if r.loc['max_loan'] == -1:
                    maxl = 'unknown'
                if r.loc['min_loan'] == -1:
                    minl = 'unknown'
                if r.loc['max_rate'] == -1:
                    maxr = 'unknown'
                if r.loc['min_rate'] == -1:
                    minr = 'unknown'
                if r.loc['max_ltc'] == -1:
                    ltc = 'unknown'
                x_info += '  \nLoan Amounts : ' \
                          + (minl if minl == "unknown" else "${:,.2f}mm".format(minl)) \
                          + ' - ' + (maxl if maxl == "unknown" else "${:,.2f}mm".format(maxl)) \
                          + '  \nLoan Rates: ' + (minr if minr == "unknown" else "{:,.2f}%".format(minr)) \
                          + ' - ' + (maxr if maxr == "unknown" else "{:,.2f}%".format(maxr)) \
                          + '  \nMaximum Loan-to-cost ratio: ' \
                          + (ltc if ltc == "unknown" else "{:,.2f}%".format(ltc)) \
                          + '  \nNumber of projects in database: ' + str(projs) \
                          + x_contact
                x_set.add(x_info)

        if y == 'l' or y == 'c':
            x_out = '  \n\n'.join(x_set)
            st.write(f" {len(x_set)} result(s):  \n{x_out}")
        else:
            st.write(f" {len(x_dict)} result(s):  \n")
            for key, val in sorted(x_dict.items(), key=lambda p: p[1][0]):
                x_info = 'Name: ' + val[0] + '  \n Number of Employees: ' + val[1] \
                         + '  \nAnnual revenues: ' + val[2] + ('  \nRegional Focus: ' if y == 'd'
                                                               else '  \nType: ') + val[3] \
                         + ('  \nSpecialization: ' if y == 'd' else '  \nAssociated Property types: ') \
                         + ', '.join(val[4]) \
                         + '  \nNumber of projects in database: ' + val[5] \
                         + '  \nContract info (email / phone #): ' + (val[6] + ' / ' + val[7]) + '.'
                st.write(f"{x_info}  \n")


def bd_process(x):
    if x.empty:
        st.write(f"No building found using search parameters.")
    else:
        developer_names = None
        x_status = None
        completion_date = 'n/a'
        designer_names = set()
        contractor_names = set()
        lender_names = set()
        owner_names = set()
        award_set = set()
        for i, r in x.iterrows():
            developer_names = r.loc['developer']
            designer_names.add(r.loc['designer'])
            contractor_names.add(r.loc['contractor'])
            lender_names.add(r.loc['lender'])
            owner_names.add(r.loc['owner'])
            x_status = r.loc['status']
            if r.loc['a_name'] != 'No Awards':
                award = r.loc['a_name'] + ', ' + r.loc['a_org'] + '(' + str(r.loc['a_year']) + ')'
                award_set.add(award)
            if x_status == 'completed':
                completion_date = r.loc['completion_date']
            else:
                completion_date = (r.loc['completion_date']).strftime("%Y-%m-%d") + ' (anticipated)'

        developer = developer_names
        designers = ', '.join(designer_names)
        x_contractors = ', '.join(contractor_names)
        x_lenders = ', '.join(lender_names)
        owners = ', '.join(owner_names)
        awards = 'None'
        if len(award_set) > 0:
            awards = '; '.join(award_set)
        st.write(f"Owner(s): {owners}  \n", f"Developed by: {developer}  \n",
                 f"Designed by: {designers}  \n", f"Built by: {x_contractors}  \n",
                 f"Financed by: {x_lenders}  \n", f"Status: {x_status}  \n",
                 f"Completion Date: {completion_date}  \n", f"Awards won: {awards}  \n")


def b_process(x):
    if x.empty:
        st.write(f"No search results.")
    else:
        x_dict = {}
        for _, r in x.iterrows():
            name, s_num, s_name, city, state, zip, sqft, p_type, p_class, s, p_id = \
                r.loc['name'], r.loc['street_num'], r.loc['street_name'], r.loc['city'], r.loc['state'], \
                r.loc['zip'], r.loc['size_sqf_0000'], r.loc['type_name'], r.loc['property_class'], r.loc['status'], \
                r.loc['building_id']

            if r.loc['name'] is None:
                name = 'None'
            if r.loc['property_class'] is None:
                p_class = 'TBD'

            if p_id not in x_dict:
                x_dict[p_id] = [name, ' '.join([str(s_num), s_name, city, state, str(zip)]),
                                "{:,.2f}mm".format(sqft), [], p_class, s]
            x_dict[p_id][3].append(p_type)

        st.write(f" {len(x_dict)} result(s):  \n")
        for key, val in x_dict.items():
            x_info = 'Name: ' + val[0] + '  \n Address: ' + val[1] \
                     + '  \nSize (sqft): ' + val[2] + '  \nType: ' \
                     + (val[3][0] if len(val[3]) == 1 else ('Mixed-use consisting of ' + ', '.join(val[3]))) \
                     + '  \nProperty Class: ' + val[4] \
                     + '  \nStatus: ' + val[5] + '.'
            st.write(f"{x_info}  \n")


'## How can we help you?'

options = ['Select an option', 'Projects', 'Project details', 'Lead Generation']

search_choice = st.selectbox('What can we help you find today?', options)
if search_choice:
    states = ['AK', 'AL', 'AR', 'AS', 'AZ', 'CA', 'CO', 'CT', 'DC', 'DE', 'FL', 'GA', 'GU', 'HI', 'IA', 'ID', 'IL',
              'IN', 'KS', 'KY', 'LA', 'MA', 'MD', 'ME', 'MI', 'MN', 'MO', 'MP', 'MS', 'MT', 'NC', 'ND', 'NE', 'NH',
              'NJ', 'NM', 'NV', 'NY', 'OH', 'OK', 'OR', 'PA', 'PR', 'RI', 'SC', 'SD', 'TN', 'TX', 'UM', 'UT', 'VA',
              'VI', 'VT', 'WA', 'WI', 'WV', 'WY']
    property_types = ['Office', 'Residential', 'Retail', 'Hospitality', 'Industrial']
    property_classes = ['AA', 'A', 'B', 'C']
    status_list = ['completed', 'under construction', 'planned']
    regions_list = ['National', 'New England', 'Mid-Atlantic', 'Midwest', 'S.Atlantic', 'S.Central', 'West']
    type_list = ['Architect', 'Architect-Engineer']
    space_list = [' Any', '>= 5', '>= 10', '>= 15', '>= 20']
    if search_choice == 'Select an option':
        st.write(f"Select an option to get started")
    if search_choice == 'Projects':
        state = st.selectbox('State (required):', states)
        city = st.text_input('City (required):')
        zipcode = st.text_input("ZIP Code (optional):")
        property_type = st.multiselect('Property Type:', property_types, default=property_types)
        property_class = st.multiselect('Property Class:', property_classes, default=property_classes)
        status = st.multiselect('Status:', status_list, default=status_list)

        type_tuple = tuple(property_type)
        class_tuple = tuple(property_class)
        status_tuple = tuple(status)

        if len(property_type) < 2:
            if len(property_type) < 1:
                type_tuple = ('######', '######')
            else:
                type_tuple = (property_type[0], '######')
        if len(property_class) < 2:
            if len(property_class) < 1:
                class_tuple = ('######', '######')
            else:
                class_tuple = (property_class[0], '######')
        if len(status) < 2:
            if len(status) < 1:
                status_tuple = ('######', '######')
            else:
                status_tuple = (status[0], '######')

        try:
            if state and city:
                city = city.lower()
                if zipcode:
                    sql_building = f"""SELECT DISTINCT B.*, U2.* FROM Buildings B INNER JOIN Used_as U 
                                        ON B.building_id = U.b_id LEFT OUTER JOIN Used_as U2 
                                        ON B.building_id = U2.b_id
                                        WHERE B.state = '{state}' 
                                        AND LOWER(B.city) = '{city}' AND B.zip = {zipcode}
                                        AND U.type_name IN {type_tuple}
                                        AND B.property_class IN {class_tuple}
                                        AND B.status IN {status_tuple};"""
                else:
                    sql_building = f"""SELECT DISTINCT B.*, U2.* FROM Buildings B INNER JOIN Used_as U 
                                        ON B.building_id = U.b_id LEFT OUTER JOIN Used_as U2
                                        ON B.building_id = U2.b_id
                                        WHERE B.state = '{state}' 
                                        AND LOWER(B.city) = '{city}'
                                        AND U.type_name IN {type_tuple}
                                        AND B.property_class IN {class_tuple}
                                        AND B.status IN {status_tuple};"""
                building_info = query_db(sql_building)
                b_process(building_info)
        except KeyError:
            st.write(f"An error occurred.")
    elif search_choice == 'Project details':
        street_address = st.text_input('Street Address (required):')
        city = st.text_input('City (required):')
        state = st.selectbox('State (required):', states)
        zipcode = st.text_input('ZIP Code (required):')

        try:
            if street_address and city and state and zipcode:
                st_num, st_name = street_address.split(" ", 1)
                st_name = st_name.lower()
                st_name = re.sub(r'[^\w\s]', '', st_name)
                city = city.lower()
                st_num = int(st_num)
                sql_building_details = f"""SELECT DISTINCT C5.name as owner, C4.name as developer, C1.name as designer,
                                            C2.name as contractor, C3.name as lender, B.status, P.completion_date, 
                                            COALESCE(A.award_name, 'No Awards') as a_name, 
                                            COALESCE(A.award_org, 'No Awards') as a_org, 
                                            COALESCE(A.award_year, 0) as a_year
                                            FROM BUILDINGS B, PROJECTS P, COMPANIES C1, COMPANIES C2, 
                                            COMPANIES C3, COMPANIES C4, COMPANIES C5, Owned_by O,  
                                            (SELECT DISTINCT B2.building_id, R.award_name, R.award_org, R.award_year 
                                            FROM BUILDINGS B2 LEFT OUTER JOIN Recieved_award R 
                                            ON B2.building_id = R.b_id) as A
                                            WHERE B.building_id = P.b_id AND B.building_id = O.b_id 
                                            AND B.street_num = {st_num} AND LOWER(B.street_name) LIKE '%{st_name}%'
                                            AND LOWER(B.city) = '{city}' AND B.state = '{state}'
                                            AND P.designer_id = C1.fed_id AND P.contractor_id = C2.fed_id
                                            AND P.lender_id = C3.fed_id AND P.developer_id = C4.fed_id
                                            AND O.fed_id = C5.fed_id AND B.building_id = A.building_id;"""

                building_details = query_db(sql_building_details)
                bd_process(building_details)
        except KeyError:
            st.write(f"An error occurred.")
    elif search_choice == 'Lead Generation':
        lead_options = ['Developers', 'Architects', 'Engineers', 'Contractors', 'Lenders']
        lead_search_options = st.selectbox('What kind of companies are you interested in learning more about?',
                                           lead_options)
        if lead_search_options == 'Developers':
            property_type = st.multiselect('Property Type:', property_types)
            region = st.multiselect('Regional Focus:', regions_list)
            developer_name = st.text_input('Developer Name:')
            type_tuple = tuple(property_type)
            if len(property_type) == 1:
                type_tuple = (property_type[0], property_type[0])
            region_tuple = tuple(region)
            if len(region_tuple) < 2:
                if len(region_tuple) < 1:
                    regions_sql = "SELECT regional_focus FROM Developers;"
                    regions = query_db(regions_sql)['regional_focus'].tolist()
                    region_tuple = tuple(regions)
                else:
                    region_tuple = (region[0], region[0])
            if len(developer_name) == 0:
                developer_name = '_'
            else:
                developer_name = developer_name.lower()

            try:
                if not property_type:
                    sql_developers = f"""SELECT DISTINCT CO.fed_id, CO.name, CO.email, CO.phone_number,  
                                            COALESCE(CO.num_of_employees, -1) num_employees, 
                                            COALESCE(CO.revenue_$mm, -1) as revenue, D.regional_focus, 
                                            COALESCE(S2.type_name,'None') as type_name, 
                                            COALESCE(COUNT(DISTINCT P.b_id),0) as num_proj 
                                            FROM Developers D INNER JOIN Companies CO ON D.fed_id = CO.fed_id 
                                            LEFT OUTER JOIN Projects P ON D.fed_id = P.developer_id 
                                            LEFT OUTER JOIN Specializes_in S ON D.fed_id = S.fed_id 
                                            LEFT OUTER JOIN Specializes_in S2 ON D.fed_id = S2.fed_id 
                                            WHERE LOWER(CO.name) LIKE '%{developer_name}%'
                                            AND D.regional_focus IN {region_tuple}
                                            GROUP BY CO.fed_id, CO.name, CO.email, CO.phone_number, 
                                            CO.num_of_employees, CO.revenue_$mm, D.regional_focus, S2.type_name;"""
                    developers = query_db(sql_developers)
                    etl(developers, 'd')
                else:
                    sql_developers = f"""SELECT DISTINCT CO.fed_id, CO.name, CO.email, CO.phone_number, 
                                            COALESCE(CO.num_of_employees, -1) num_employees, 
                                            COALESCE(CO.revenue_$mm, -1) as revenue, D.regional_focus, 
                                            COALESCE(S2.type_name,'None') as type_name, 
                                            COALESCE(COUNT(DISTINCT P.b_id),0) as num_proj 
                                            FROM Developers D INNER JOIN Companies CO ON D.fed_id = CO.fed_id 
                                            LEFT OUTER JOIN Projects P ON D.fed_id = P.developer_id 
                                            LEFT OUTER JOIN Specializes_in S ON D.fed_id = S.fed_id 
                                            LEFT OUTER JOIN Specializes_in S2 ON D.fed_id = S2.fed_id
                                            WHERE D.regional_focus IN {region_tuple} AND S.type_name IN {type_tuple} 
                                            AND LOWER(CO.name) LIKE '%{developer_name}%'
                                            GROUP BY CO.fed_id, CO.name, CO.email, CO.phone_number, 
                                            CO.num_of_employees, CO.revenue_$mm, D.regional_focus, S2.type_name;"""
                    developers = query_db(sql_developers)
                    etl(developers, 'd')
            except KeyError:
                st.write(f"An error occurred.")
        elif lead_search_options == 'Architects':
            property_type = st.multiselect('Property Type:', property_types)
            arch_name = st.text_input('Architect Name :')
            type_tuple = tuple(property_type)
            if len(property_type) == 1:
                type_tuple = (property_type[0], property_type[0])
            if len(arch_name) == 0:
                arch_name = '_'
            else:
                arch_name = arch_name.lower()

            try:
                if not property_type:
                    sql_archs = f"""SELECT DISTINCT CO.fed_id, CO.name, CO.email, CO.phone_number, 
                                    COALESCE(CO.num_of_employees, -1) num_employees, 
                                    COALESCE(CO.revenue_$mm, -1) as revenue, D.type, S2.type_name, 
                                    COALESCE(COUNT(DISTINCT P.b_id),0) as num_proj 
                                    FROM Designers D INNER JOIN Companies CO 
                                    ON (D.fed_id = CO.fed_id AND 
                                    (D.type = 'Architect' OR D.type = 'Architect-Engineer')) 
                                    INNER JOIN Specializes_in S ON D.fed_id = S.fed_id 
                                    LEFT OUTER JOIN Projects P ON D.fed_id = P.designer_id 
                                    INNER JOIN Specializes_in S2 ON D.fed_id = S2.fed_id 
                                    WHERE LOWER(CO.name) LIKE '%{arch_name}%'
                                    GROUP BY CO.fed_id, CO.name, CO.email, CO.phone_number, 
                                    CO.num_of_employees, CO.revenue_$mm, D.type, S2.type_name;"""
                    archs = query_db(sql_archs)
                    etl(archs, 'a')
                else:
                    sql_archs = f"""SELECT DISTINCT CO.fed_id, CO.name, CO.email, CO.phone_number, 
                                    COALESCE(CO.num_of_employees, -1) num_employees, 
                                    COALESCE(CO.revenue_$mm, -1) as revenue, D.type, S2.type_name, 
                                    COALESCE(COUNT(DISTINCT P.b_id),0) as num_proj 
                                    FROM Designers D INNER JOIN Companies CO 
                                    ON (D.fed_id = CO.fed_id AND 
                                    (D.type = 'Architect' OR D.type = 'Architect-Engineer')) 
                                    INNER JOIN Specializes_in S ON (D.fed_id = S.fed_id 
                                    AND S.type_name IN {type_tuple}) 
                                    LEFT OUTER JOIN Projects P ON D.fed_id = P.designer_id 
                                    INNER JOIN Specializes_in S2 ON D.fed_id = S2.fed_id 
                                    WHERE LOWER(CO.name) LIKE '%{arch_name}%'
                                    GROUP BY CO.fed_id, CO.name, CO.email, CO.phone_number, 
                                    CO.num_of_employees, CO.revenue_$mm, D.type, S2.type_name;"""
                    archs = query_db(sql_archs)
                    etl(archs, 'a')
            except KeyError:
                st.write(f"An error occurred")
        elif lead_search_options == 'Engineers':
            property_type = st.multiselect('Engineers who have experience with the following:', property_types)
            eng_name = st.text_input('Engineering Company Name :')
            type_tuple = tuple(property_type)
            if len(property_type) == 1:
                type_tuple = (property_type[0], property_type[0])
            if len(eng_name) == 0:
                eng_name = '_'
            else:
                eng_name = eng_name.lower()

            try:
                if not property_type:
                    sql_engineers = f"""SELECT DISTINCT CO.fed_id, CO.name, CO.email, CO.phone_number,  
                                    COALESCE(CO.num_of_employees, -1) num_employees, 
                                    COALESCE(CO.revenue_$mm, -1) as revenue, D.type, U.type_name, 
                                    COALESCE(COUNT(DISTINCT P.b_id),0) as num_proj 
                                    FROM Designers D INNER JOIN Companies CO 
                                    ON (D.fed_id = CO.fed_id AND 
                                    (D.type = 'Engineer' OR D.type = 'Architect-Engineer')) 
                                    LEFT OUTER JOIN Projects P ON D.fed_id = P.designer_id 
                                    INNER JOIN Used_as U ON P.b_id = U.b_id
                                    WHERE LOWER(CO.name) LIKE '%{eng_name}%'
                                    GROUP BY CO.fed_id, CO.name, CO.email, CO.phone_number, 
                                    CO.num_of_employees, CO.revenue_$mm, D.type, U.type_name;"""
                    engs = query_db(sql_engineers)
                    etl(engs, 'e')
                else:
                    sql_engineers = f"""SELECT DISTINCT CO.fed_id, CO.name, CO.email, CO.phone_number,  
                                    COALESCE(CO.num_of_employees, -1) num_employees, 
                                    COALESCE(CO.revenue_$mm, -1) as revenue, D.type, U.type_name, 
                                    COALESCE(COUNT(DISTINCT P.b_id),0) as num_proj 
                                    FROM Designers D INNER JOIN Companies CO 
                                    ON (D.fed_id = CO.fed_id AND 
                                    (D.type = 'Engineer' OR D.type = 'Architect-Engineer')) 
                                    LEFT OUTER JOIN Projects P ON D.fed_id = P.designer_id
                                    INNER JOIN Used_as U ON P.b_id = U.b_id
                                    WHERE LOWER(CO.name) LIKE '%{eng_name}%' 
                                    AND U.type_name IN {type_tuple}
                                    GROUP BY CO.fed_id, CO.name, CO.email, CO.phone_number, 
                                    CO.num_of_employees, CO.revenue_$mm, D.type, U.type_name;"""
                    engs = query_db(sql_engineers)
                    etl(engs, 'e')
            except KeyError:
                st.write(f"An error occurred")
        elif lead_search_options == 'Contractors':
            space = st.selectbox('Space completed over the previous 5 years (millions):', space_list)
            contractor_name = st.text_input('Contractor Name:')
            if space:
                space = space.split(" ")[1]
                if space == 'Any':
                    space = 0.0
                else:
                    space = int(space)
            if len(contractor_name) == 0:
                contractor_name = '_'
            else:
                contractor_name = contractor_name.lower()

            try:
                sql_contractors = f"""SELECT CO.fed_id, CO.name, CO.email, CO.phone_number, 
                                        COALESCE(CO.num_of_employees, -1) num_employees, 
                                        COALESCE(CO.revenue_$mm, -1) as revenue, 
                                        COALESCE(CC.sqft_completed_5yrs, -1) as sqft_completed_5yrs,
                                        COALESCE(CC.sqft_under_construction, -1) as sqft_under_construction,
                                        COALESCE(COUNT(DISTINCT P.b_id),0) as num_proj
                                        FROM Contractors CC INNER JOIN Companies CO ON CC.fed_id = CO.fed_id 
                                        LEFT OUTER JOIN Projects P ON CC.fed_id = P.contractor_id 
                                        WHERE CC.sqft_completed_5yrs >= {space} 
                                        AND LOWER(CO.name) LIKE '%{contractor_name}%' 
                                        GROUP BY CO.fed_id, CO.name, CO.email, CO.phone_number, CO.num_of_employees, 
                                        CO.revenue_$mm, CC.sqft_completed_5yrs, CC.sqft_under_construction;"""
                contractors = query_db(sql_contractors)
                etl(contractors, 'c')
            except KeyError:
                st.write(f"An error occurred")
        elif lead_search_options == 'Lenders':
            loan_amt = st.number_input('How much are you looking to raise? (in $mm):', min_value=0.0, step=5.0)
            loan_rate = st.number_input('What rate are you willing to pay? (in %)', min_value=0.0,
                                        max_value=100.0, step=0.25)
            loan_ltc = st.number_input('How much of the construction cost will you be financing (in %)?',
                                       min_value=0.0, max_value=100.0, step=5.0)
            lender_name = st.text_input('Lender Name: ')
            if len(lender_name) == 0:
                lender_name = '_'
            else:
                lender_name = lender_name.lower()

            try:
                if loan_amt or loan_rate or loan_ltc:
                    sql_lenders = f"""SELECT CO.fed_id, CO.name, CO.email, CO.phone_number, 
                                        COALESCE(CO.num_of_employees, -1) num_employees, 
                                        COALESCE(CO.revenue_$mm, -1) as revenue, 
                                        COALESCE(L.min_loan_size_$mm, -1) as min_loan,
                                        COALESCE(L.max_loan_size_$mm, -1) as max_loan, 
                                        COALESCE(L.min_rate, -1) as min_rate,
                                        COALESCE(L.max_rate, -1) as max_rate,
                                        COALESCE(L.max_ltc, -1) as max_ltc,
                                        COALESCE(COUNT(DISTINCT P.b_id),0) as num_proj
                                        FROM Lenders L INNER JOIN Companies CO ON L.fed_id = CO.fed_id
                                        LEFT OUTER JOIN Projects P ON L.fed_id = P.lender_id 
                                        WHERE L.min_loan_size_$mm <= {loan_amt} AND L.max_loan_size_$mm >= {loan_amt} 
                                        AND L.min_rate <= {loan_rate} AND L.max_rate >= {loan_rate} 
                                        AND L.max_ltc >= {loan_ltc} AND LOWER(CO.name) LIKE '%{lender_name}%' 
                                        GROUP BY CO.fed_id, CO.name, CO.email, CO.phone_number, 
                                        CO.num_of_employees, CO.revenue_$mm, 
                                        L.min_loan_size_$mm, L.max_loan_size_$mm, L.min_rate, L.max_rate, L.max_ltc;"""
                    lenders = query_db(sql_lenders)
                    etl(lenders, 'l')
            except KeyError:
                st.write(f"An error occurred.")
