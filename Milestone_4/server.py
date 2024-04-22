#! /Applications/XAMPP/xamppfiles/htdocs/Jail_Database/env/bin/python
#Import Libraries
from flask import Flask, render_template, request, session, url_for, redirect, flash, jsonify
import pymysql.cursors
import pandas as PD
from werkzeug.security import generate_password_hash
from werkzeug.security import check_password_hash

#Initialize the app from Flask
app = Flask(__name__)
#Doesn't matter just used for flask verification
app.secret_key = 'jason'

#Configure MySQL and connect to certain user defualt too root user
def connectDB(role = 'public_user', pw = ''):
	if role == 'admin':
		try:
			conn = pymysql.connect(host='localhost',
						  		user='root',
								password=pw,
								db='jail',
								charset='utf8mb4',
								cursorclass=pymysql.cursors.DictCursor)
			print("==================\nConnected to the database!\n==================")
			print('ADMIN')
		except pymysql.Error as e:
			print(f"Error connecting to MySQL: {e}")
			# Raise the exception to handle it further up the call stack if needed
			raise
	else:
		try:
			conn = pymysql.connect(host='localhost',
								user=role,
								password=pw,
								db='jail',
								charset='utf8mb4',
								cursorclass=pymysql.cursors.DictCursor)
			print("==================\nConnected to the database!\n==================")
			print(role)
			return conn
		except pymysql.Error as e:
			print(f"Error connecting to MySQL: {e}")
			# Raise the exception to handle it further up the call stack if needed
			raise

#Connect to lowest permission connection
conn = connectDB(role='public_user', pw='')

#Default if only query is passed then it will execute with root user with no arguments
#Runs query and returns values in a Dataframe for traversing purposes
def run_statement(query, arguments=None):
	cursor = conn.cursor()
	if arguments == None:
		cursor.execute(query)
		results = cursor.fetchall()
		conn.commit()
		column_names = [desc[0] for desc in cursor.description]
		df = PD.DataFrame(results, columns=column_names)
	else:
		cursor.execute(query, arguments)
		results = cursor.fetchall()
		conn.commit()
		column_names = list(set(desc[0] for desc in cursor.description)) #Syntax to remove duplicate columns from joining tables
		df = PD.DataFrame(results, columns=column_names)
	cursor.close()
	return df

#Checking for valid registration creds
def register_auth(username, id):
	#Check if username or badge number exists
	cursor = conn.cursor()
	query = "SELECT * FROM users WHERE username = %s OR badge_number = %s;"
	cursor.execute(query, (username, id))
	user = cursor.fetchone()
	if user:
		cursor.close()
		return(("User already exists", False))
	cursor.close()
	#Check if they are an officer
	cursor = conn.cursor()
	query = "SELECT * FROM officer WHERE badge_number = %s;"
	cursor.execute(query, (id))
	auth = cursor.fetchone()
	if auth:
		cursor.close()
		return(("", True))
	else:
		cursor.close()
		return(("Invalid Officer Badge Number", False))

#Register by putting values into users table
def register(username, password, id):
	hashed_password = generate_password_hash(password)
	cursor = conn.cursor()
	query = "INSERT INTO users (username, password, badge_number) VALUES (%s, %s, %s)"
	cursor.execute(query, (username, hashed_password, id))
	conn.commit()
	cursor.close()

#Reference user table to see if they are registered. login if registered
def login(username, password):
	cursor = conn.cursor()
	query = "SELECT password FROM users WHERE username = %s;"
	cursor.execute(query, (username))
	user = cursor.fetchone()
	cursor.close()
	if user and check_password_hash(user['password'], password):
		return True
	else:
		return False

def admin_auth(username, password):
	cursor = conn.cursor()
	query = "SELECT password FROM ADMINS WHERE username = %s AND password = SHA(%s);"
	cursor.execute(query, (username, password))
	admin = cursor.fetchone()
	cursor.close()
	if admin:
		return True
	else:
		return False

def search_criminal(first_name="", last_name="", alias="", case_id=""):
    print("RECEIVED:", first_name, "|", last_name, "|", alias, "|", case_id)
    df = PD.DataFrame()
    query = "SELECT * FROM criminal INNER JOIN CRIME_CASE ON CRIMINAL.criminal_id = CRIME_CASE.criminal_id WHERE"
    params = []
    if (case_id != ""):
        query += " crime_case.case_id = %s"
        params.append(case_id)
    if (first_name != ""):
        query += " AND criminal.criminal_first = %s" if len(params) > 0 else " criminal.criminal_first = %s"
        params.append(first_name)
    if (last_name != ""):
        query += " AND criminal.criminal_last = %s" if len(params) > 0 else " criminal.criminal_last = %s"
        params.append(last_name)
    if (alias != ""):
        query += " AND criminal.alias = %s" if len(params) > 0 else " criminal.criminal_alias = %s"
        params.append(alias)
    if len(params) == 0:
        print("ERROR")
        return df

    query += ";"
    df = run_statement(query, tuple(params))
    return df

def search_officer(first_name, last_name, badge_number):
    df = PD.DataFrame()
    query = "SELECT * FROM officer WHERE"
    params = []
    if badge_number != "":
        query += " badge_number = %s"
        params.append(badge_number)
    if first_name != "":
        query += " AND officer_first = %s" if len(params) > 0 else " officer_first = %s"
        params.append(first_name)
    if last_name != "":
        query += " AND officer_last = %s" if len(params) > 0 else " officer_last = %s"
        params.append(last_name)
    if len(params) == 0:
        print("ERROR")
        return df
    query += ";"
    df = run_statement(query, tuple(params))
    return df

#=============================================================== Seperate functions and routes

# NEED TO DO conn.close() at the end of each app.route
@app.route('/', methods=['POST', 'GET'])
def home():
	if "badge_number" in session:
		badge_number = session['badge_number']
		return redirect(url_for("officer_home", badge_number=badge_number))
	if "admin" in session:
		return redirect(url_for("admin"))
	if request.method == 'GET': #Basically if searching through public inmate
		first_name_input = request.args.get('first-name', '')
		last_name_input = request.args.get('last-name', '')
		alias_input = request.args.get('alias', '')
		case_id_input = request.args.get('case-num', '')
		if first_name_input == '' and last_name_input == '' and alias_input == '' and case_id_input == '':
			return render_template('home.html')
		else:
			# Initialize lists to store data
			name = []
			criminal_id = []
			alias = []
			# criminal_address = []
			# criminal_phonenum = []
			violent = []
			probation = []

			df = search_criminal(first_name_input, last_name_input, alias_input, case_id_input)
			# Populate lists from DataFrame
			for i, j in df.iterrows():
				name.append(j['criminal_first'] + ' ' + j['criminal_last'])
				alias.append(j['alias'])
				criminal_id.append(j['criminal_id'])
				# criminal_address.append(j['criminal_address'])
				violent.append(j['violent_offender_stat'])
				probation.append(j['probation_status'])
				# criminal_phonenum.append(j['criminal_phonenum'])
			if (len(name) == 0):
				return render_template ('inmate_search_results.html', empty=True)
			else:
				# Zip the lists together
				zipped_data = zip(name, criminal_id, alias, violent, probation)
				# Render the template with zipped_data
				return render_template('public_inmate.html', zipped_data=zipped_data)
	elif request.method == 'POST': #If logging in
		username = request.form['username']
		password = request.form['password']
		if login(username, password):
			query = "SELECT officer_first, badge_number FROM OFFICER WHERE badge_number IN (SELECT badge_number FROM users WHERE username = %s)"
			conn = connectDB(role='Officer_Role', pw='password')
			cursor = conn.cursor()
			cursor.execute(query, (username,))
			details = cursor.fetchone()
			session['badge_number'] = details['badge_number']
			return redirect(url_for("officer_home", badge_number=details['badge_number']))
		else:
			return render_template('error_cred.html')
	else:
		return render_template('home.html')

@app.route('/register', methods=['GET', 'POST'])
def register_route():
	if request.method == 'POST':
		username = request.form['register_username']
		password = request.form['register_password']
		id = int(request.form['register_id'])
		results = register_auth(username, id)
		message = results[0]
		access = results[1]
		if access:
			register(username, password, id)
			return redirect(url_for('home'))
		else:
			flash(message)
			return render_template('register.html')
	return render_template('register.html')

@app.route("/<badge_number>", methods=['POST', 'GET'])
def officer_home(badge_number):
    officer_types = {
        "Probation" : {
            "badge_check" : " PROBATION ON officer.badge_number = probation.badge_number WHERE probation.badge_number = %s AND officer.badge_number = %s;",
            "criminal_query" : "SELECT criminal.criminal_first, criminal.criminal_last FROM criminal INNER JOIN probation ON probation.criminal_id  = criminal.criminal_id WHERE probation.criminal_id = %s AND criminal.criminal_id = %s;",
            "officer_site" : "private_probation.html"
        },
        "Arrest" : {
            "badge_check" : " ARREST ON officer.badge_number = arrest.badge_number WHERE arrest.badge_number = %s AND officer.badge_number = %s;",
            "criminal_query" : "SELECT criminal.criminal_first, criminal.criminal_last FROM criminal INNER JOIN arrest ON arrest.criminal_id = criminal.criminal_id WHERE arrest.criminal_id = %s AND criminal.criminal_id = %s;",
            "officer_site" : "private_arrest.html"
        }
    }
    if "badge_number" not in session:
        return redirect(url_for('home'))
    session_auth = str(session['badge_number'])
    if session_auth != badge_number:
        return render_template('error_access.html')

    inmate_search_fields = ['inmate-first-name','inmate-last-name', 'alias', 'case-num']
    officer_search_fields = ['officer-first-name', 'officer-last-name', 'badge-number']

    search_type = ""
    if request.method == 'POST':
        print("FORM:", request.form)
        for field in inmate_search_fields:
            if field in request.form:
                search_type = "inmate"
        for field in officer_search_fields:
            if field in request.form:
                search_type = "officer"
        if search_type == "":
            return

        search_args = []
        if search_type == "inmate":
            search_args = list([request.form[field] if request.form[field] != "" else "" for field in inmate_search_fields])
            df = search_criminal(*search_args)
			# Initialize lists to store data
            name = []
            criminal_id = []
            alias = []
            criminal_address = []
            criminal_phonenum = []
            violent = []
            probation = []

            # Populate lists from DataFrame
            for i, j in df.iterrows():
                name.append(j['criminal_first'] + ' ' + j['criminal_last'])
                alias.append(j['alias'])
                criminal_id.append(j['criminal_id'])
                criminal_address.append(j['criminal_address'])
                violent.append(j['violent_offender_stat'])
                probation.append(j['probation_status'])
                criminal_phonenum.append(j['criminal_phonenum'])
            if (len(name) == 0):
                return render_template ('private_inmate.html', empty=True)
            else:
                # Zip the lists together
                zipped_data = zip(name, criminal_id, alias, criminal_address, criminal_phonenum, violent, probation)
                return render_template('private_inmate.html', zipped_data=zipped_data)

        if search_type == "officer":
            search_args = list([request.form[field] if request.form[field] != "" else "" for field in officer_search_fields])
            df = search_officer(*search_args)
            # Initialize lists to store data
            badge_number = []
            name = []
            precinct = []
            officer_phonenum = []
            activity_status = []
            officer_type = []
            officer_address = []

            # Populate lists from DataFrame
            for i, j in df.iterrows():
                badge_number.append(j['badge_number'])
                name.append(j['officer_first'] + ' ' + j['officer_last'])
                precinct.append(j['precinct'])
                officer_phonenum.append(j['officer_phonenum'])
                activity_status.append(j['activity_status'])
                officer_type.append(j['officer_type'])
                officer_address.append(j['officer_address'])
            if (len(name) == 0):
                return render_template ('inmate_search_results.html', empty=True)
            else:
                # Zip the lists together
                zipped_data = zip(badge_number, name, precinct, officer_phonenum, activity_status, officer_type, officer_address)
                # Render the template with zipped_data
                return render_template('officer_search_results.html', zipped_data=zipped_data)

    cursor = conn.cursor()
    query = "SELECT * FROM officer WHERE officer.badge_number = %s;"
    cursor.execute(query, (badge_number))
    result = cursor.fetchone()
    officer_type = result['officer_type']

    query = "SELECT * FROM officer INNER JOIN "
    query += officer_types[officer_type]["badge_check"]
    cursor.execute(query, (badge_number, badge_number))
    result = cursor.fetchone()
    f_name = result['officer_first']
    l_name = result['officer_last']
    precinct=result['precinct']
    officer_address = result['officer_address']
    officer_phonenum = result['officer_phonenum']
    activity_status = result['activity_status']
    criminal_id = result['criminal_id']
    if officer_type == 'arrest':
        crime_code = result['crime_code']
    query = officer_types[officer_type]["criminal_query"]
    cursor.execute(query, (criminal_id, criminal_id))
    result = cursor.fetchone()
    cf_name = result['criminal_first']
    cl_name = result['criminal_last']
    return render_template(officer_types[officer_type]["officer_site"] ,f_name=f_name, l_name=l_name, badge_number=badge_number, precinct=precinct, officer_address=officer_address, officer_phonenum=officer_phonenum, activity_status=activity_status, criminal_id=criminal_id, cf_name=cf_name, cl_name=cl_name)



@app.route('/logout/officer')
def officer_logout():
	session.pop("badge_number", None)
	conn = connectDB(role='public_user', pw='')
	return redirect(url_for("home"))

@app.route('/logout/admin', methods=['POST'])
def admin_logout():
	session.pop("admin", None)
	conn = connectDB(role='public_user', pw='')
	return redirect(url_for("home"))


@app.route('/login', methods=['POST', 'GET'])
def admin_login():
	if request.method == 'POST':
		username = request.form['admin_username']
		password = request.form['admin_password']
		if admin_auth(username, password):
			session['admin'] = username
			return redirect(url_for("admin"))
		else:
			flash("Wrong Credentials")
	return render_template("admin_login.html")

@app.route('/admin')
def admin():
	if 'admin' in session:
		query = "SELECT username, badge_number FROM users"
		badge_numbers = []
		usernames = []
		df = run_statement(query)
		for i, j in df.iterrows():
			badge_numbers.append(j['badge_number'])
			usernames.append(j['username'])
		zipped_data = zip(badge_numbers, usernames)
		return render_template('admin.html', zipped_data=zipped_data)
	else:
		redirect(url_for('home'))

@app.route('/admin/officer', methods=['GET', 'POST'])
def admin_officer():
	if 'admin' in session:
		edit_badge_number = -1
		if request.method == 'GET':
			edit_badge_number = request.args.get('edit', -1)
		query = "SELECT * FROM OFFICER"
		df = run_statement(query)
		badge_number = []
		officer_first = []
		officer_last = []
		precinct = []
		officer_phonenum = []
		activity_status = []
		officer_type = []
		officer_address = []
		edit = []
		for i, j in df.iterrows():
			badge_number.append(j['badge_number'])
			officer_first.append(j['officer_first'])
			officer_last.append(j['officer_last'])
			precinct.append(j['precinct'])
			officer_phonenum.append(j['officer_phonenum'])
			activity_status.append(j['activity_status'])
			officer_type.append(j['officer_type'])
			officer_address.append(j['officer_address'])
			edit.append(1) if str(j['badge_number']) == edit_badge_number else edit.append(0)
		if len(badge_number) == 0:
			return render_template('admin_officer.html', empty=True)
		else:
			zipped_data = zip(badge_number, officer_first, officer_last, precinct, officer_phonenum, activity_status, officer_type, officer_address, edit)
			return render_template('admin_officer.html', zipped_data=zipped_data)
	else:
		return redirect(url_for('home'))

@app.route('/admin/criminal', methods=['GET', 'POST'])
def admin_criminal():
	if 'admin' in session:
		query = "SELECT * FROM CRIMINAL"
		df = run_statement(query)
		edit_criminal_id = -1
		if request.method == 'GET':
			edit_criminal_id = request.args.get('edit', -1)
		criminal_first = []
		criminal_last = []
		criminal_id = []
		alias = []
		criminal_address = []
		criminal_phonenum = []
		violent = []
		probation = []
		edit = []
		for i, j in df.iterrows():
			criminal_first.append(j['criminal_first'])
			criminal_last.append(j['criminal_last'])
			alias.append(j['alias'])
			criminal_id.append(j['criminal_id'])
			criminal_address.append(j['criminal_address'])
			violent.append(j['violent_offender_stat'])
			probation.append(j['probation_status'])
			criminal_phonenum.append(j['criminal_phonenum'])
			edit.append(1) if str(j['criminal_id']) == edit_criminal_id else edit.append(0)
		if len(criminal_first) == 0:
			return render_template("admin_criminal.html", empty=True)
		else:
			zipped_data = zip(criminal_first, criminal_last, criminal_id, alias, criminal_address, criminal_phonenum, violent, probation, edit)
			return render_template("admin_criminal.html", zipped_data=zipped_data)
	else:
		return redirect(url_for('home'))

@app.route('/crimes', methods=['POST', 'GET'])
def display_crimes():
	query = "SELECT * FROM crime;"
	df = run_statement(query)
	crime_codes = []
	classifications = []
	descriptions = []
	for i, j in df.iterrows():
		crime_codes.append(j['crime_code'])
		classifications.append(j['classification'])
		descriptions.append(j['crime_description'])
	zipped_data = zip(crime_codes, classifications, descriptions)
	return render_template('crimes.html', zipped_data=zipped_data)

@app.route('/make_payment', methods=['POST'])
def make_payment():
    if request.method == 'POST':
        amount = request.form['payment_amount']
        criminal_id = request.form['criminal_id']
        cursor = conn.cursor()
        query = "UPDATE fine SET paid_amount = paid_amount + %s WHERE criminal_id = %s"
        cursor.execute(query, (amount, criminal_id))
        conn.commit()
        cursor.close()
    return redirect(url_for('criminal_info', criminal_id=criminal_id))

@app.route('/criminal_info/<criminal_id>')
def criminal_info(criminal_id):
	query = "SELECT criminal_first, criminal_last FROM CRIMINAL WHERE criminal_id = %s;"
	df = run_statement(query, (criminal_id))
	for i,j in df.iterrows():
		name = j['criminal_first'] + " " + j['criminal_last']
	query = "SELECT * FROM SENTENCING INNER JOIN charge ON SENTENCING.criminal_id = charge.criminal_id INNER JOIN crime ON crime.crime_code = charge.crime_code WHERE SENTENCING.criminal_id =%s;"
	df = run_statement(query, (criminal_id))
	date_charged = []
	crime_code = []
	classification = []
	description = []
	for i,j in df.iterrows():
		date_charged.append(j['date_charged'])
		crime_code.append(j['crime_code'])
		classification.append(j['classification'])
		description.append(j['crime_description'])
	crime_details = zip(date_charged, crime_code, classification, description)
	query = "SELECT * FROM SENTENCING INNER JOIN VIOLATION ON VIOLATION.violation_code = SENTENCING.violation_code INNER JOIN CRIME_CASE ON SENTENCING.sentence_id = CRIME_CASE.sentence_id WHERE SENTENCING.criminal_id = %s;"
	df = run_statement(query, (criminal_id))
	sentence_type = []
	starting_date =[]
	ending_date = []
	violation_code = []
	charge_status = []
	num_violation = []
	violation_description = []
	for i,j in df.iterrows():
		sentence_type.append(j['sentence_type'])
		starting_date.append(j['starting_date'])
		ending_date.append(j['end_date'])
		violation_code.append(j['violation_code'])
		charge_status.append(j['charge_status'])
		num_violation.append(j['num_violations'])
		violation_description.append(j['violation_description'])
	sentencing_details = zip(sentence_type,starting_date,ending_date,violation_code,charge_status,num_violation,violation_description)
	query = "SELECT * FROM APPEAL WHERE criminal_id = %s;"
	df = run_statement(query, (criminal_id))
	appeal_file_date = []
	appeal_hearing_date = []
	appeal_status = []
	num_appeal = []
	for i,j in df.iterrows():
		appeal_file_date.append(j['appeal_file_date'])
		appeal_hearing_date.append(j['appeal_hearing_date'])
		appeal_status.append(j['appeal_status'])
		num_appeal.append(j['num_appeal_remaining'])
	appeal_detials = zip(appeal_file_date,appeal_hearing_date,appeal_status,num_appeal)
	query = "SELECT * FROM FINE WHERE criminal_id = %s;"
	df = run_statement(query, (criminal_id))
	fine_amount = []
	court_fee = []
	paid_amount = []
	payment_due_date = []
	print(df)
	criminal_id_list = []
	for i,j in df.iterrows():
		fine_amount.append(j['fine_amount'])
		court_fee.append(j['court_fee'])
		paid_amount.append(j['paid_amount'])
		payment_due_date.append(j['payment_due_date'])
		criminal_id_list.append(criminal_id)
	fine_details = zip(fine_amount, court_fee, paid_amount, payment_due_date, criminal_id_list)
	return render_template('criminal_info.html', name=name,crime_details=crime_details, sentencing_details=sentencing_details, appeal_detials=appeal_detials,fine_details=fine_details)
	
#Delete routes
@app.route('/delete/<badge_num>', methods=["GET"])
def delete_user(badge_num):
	if 'admin' in session:
		cursor = conn.cursor()
		query = "DELETE FROM users WHERE badge_number = %s;"
		cursor.execute(query, (badge_num))
		conn.commit()
		cursor.close()
		return redirect(url_for('admin'))
	else:
		return "Unauthorized", 401

@app.route('/delete_officer/<badge_number>', methods=["GET"])
def delete_officer(badge_number):
	if 'admin' in session:
		cursor = conn.cursor()
		query = "SELECT badge_number FROM users WHERE badge_number = %s"
		cursor.execute(query, (badge_number))
		inusers = cursor.fetchone()
		conn.commit()
		cursor.close()
		if inusers:
			cursor = conn.cursor()
			query = "DELETE FROM users WHERE badge_number = %s;"
			cursor.execute(query, (badge_number))
			conn.commit()
			cursor.close()
		cursor = conn.cursor()
		query = "DELETE FROM officer WHERE badge_number = %s;"
		cursor.execute(query, (badge_number))
		conn.commit()
		cursor.close()
		return redirect(url_for('admin_officer'))
	else:
		return "Unauthorized", 401

@app.route('/delete_criminal/<criminal_id>', methods=["GET"])
def delete_criminal(criminal_id):
	if 'admin' in session:
		cursor = conn.cursor()
		query = "DELETE FROM CRIMINAL WHERE criminal_id = %s"
		cursor.execute(query, (criminal_id))
		conn.commit()
		cursor.close()
		return redirect(url_for('admin_criminal'))
	else:
		return "Unauthorized", 401

@app.route('/insert_officer', methods=["POST"])
def insert_officer():
    if 'admin' not in session:
        return "Unauthorized", 401

    data = request.json
    badge_number = data['fields']['badge_number']
    first_name = data['fields']['first_name']
    last_name = data['fields']['last_name']
    precinct = data['fields']['precinct']
    phone_number = data['fields']['phone_number']
    status = data['fields']['status']
    type_ = data['fields']['type']
    address = data['fields']['address']
    cursor = conn.cursor()

    query = "INSERT INTO officer (badge_number, officer_first, officer_last, precinct, officer_phonenum, activity_status, officer_type, officer_address) VALUES (%s, %s, %s, %s, %s, %s, %s, %s)"
    cursor.execute(query, (badge_number, first_name, last_name, precinct, phone_number, status, type_, address))
    conn.commit()
    cursor.close()
    return redirect(url_for('admin_officer'))

@app.route('/insert_criminal', methods=["POST"])
def insert_criminal():
    if 'admin' not in session:
        return "Unauthorized", 401

    data = request.json
    criminal_id = data['fields']['criminal_id']
    first_name = data['fields']['first_name']
    last_name = data['fields']['last_name']
    address = data['fields']['address']
    phone_number = data['fields']['phone_number']
    violent = data['fields']['violent']
    probation = data['fields']['probation']
    alias = data['fields']['alias']
    cursor = conn.cursor()

    query = "INSERT INTO criminal (criminal_id, criminal_first, criminal_last, criminal_address, criminal_phonenum, violent_offender_stat, probation_status, alias) VALUES (%s, %s, %s, %s, %s, %s, %s, %s)"
    cursor.execute(query, (criminal_id, first_name, last_name, address, phone_number, violent, probation, alias))
    conn.commit()
    cursor.close()
    return redirect(url_for('admin_criminal'))

@app.route('/update_officer', methods=['POST'])
def update_officer():
    if 'admin' not in session:
        return "Unauthorized", 401

    data = request.json
    badge_num = data['fields']['badge_number']
    first_name = data['fields']['first_name']
    last_name = data['fields']['last_name']
    precinct = data['fields']['precinct']
    phone_number = data['fields']['phone_number']
    status = data['fields']['status']
    type_ = data['fields']['type']
    address = data['fields']['address']
    cursor = conn.cursor()

    query = "UPDATE officer SET officer_first = %s, officer_last = %s, precinct = %s, officer_phonenum = %s, activity_status = %s, officer_type = %s, officer_address = %s WHERE badge_number = %s"
    cursor.execute(query, (first_name, last_name, precinct, phone_number, status, type_, address, badge_num))
    conn.commit()
    cursor.close()
    return redirect(url_for('admin_officer'))

@app.route('/update_criminal', methods=['POST'])
def update_criminal():
    if 'admin' not in session:
        return "Unauthorized", 401

    data = request.json
    criminal_id = data['fields']['criminal_id']
    first_name = data['fields']['first_name']
    last_name = data['fields']['last_name']
    address = data['fields']['address']
    phone_number = data['fields']['phone_number']
    violent = data['fields']['violent']
    probation = data['fields']['probation']
    alias = data['fields']['alias']
    cursor = conn.cursor()

    query = "UPDATE criminal SET criminal_first = %s, criminal_last = %s, criminal_address = %s, criminal_phonenum = %s, violent_offender_stat = %s, probation_status = %s, alias = %s WHERE criminal_id = %s"
    cursor.execute(query, (first_name, last_name, address, phone_number, violent, probation, alias, criminal_id))
    conn.commit()
    cursor.close()
    return redirect(url_for('admin_criminal'))

if __name__ == "__main__":
	app.run('127.0.0.1', 5000, debug = True)