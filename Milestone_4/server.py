#! /Applications/XAMPP/xamppfiles/htdocs/Jail_Database/env/bin/python
#Import Libraries
from flask import Flask, render_template, request, session, url_for, redirect, flash
import pymysql.cursors
import pandas as PD
from werkzeug.security import generate_password_hash
from werkzeug.security import check_password_hash

#Initialize the app from Flask
app = Flask(__name__)
#Doesn't matter just used for flask verification
app.secret_key = 'jason'

#Configure MySQL and connect to certain user defualt too root user
def connectDB(u = 'root', pw = ''):
	try:
		conn = pymysql.connect(host='localhost',
							user=u,
							password=pw,
							db='jail',
							charset='utf8mb4',
							cursorclass=pymysql.cursors.DictCursor)
		print("==================\nConnected to the database!\n==================")
		return conn
	except pymysql.Error as e:
		print(f"Error connecting to MySQL: {e}")
		# Raise the exception to handle it further up the call stack if needed
		raise

#Connect to root user -- probably change to lowest permission privilege and then work way up in each route
conn = connectDB()

#Default if only query is passed then it will execute with root user with no arguments
#Runs query and returns values in a Dataframe for traversing purposes
def runstatement(query, arguments=None):
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

def search_criminal(first_name, last_name, alias, case_id):
	if(case_id != ''):
		if(first_name != '' and last_name == ''):
			#Search function arguements in runstatment are what its running search by
			if(alias == ''):
				query = "SELECT * FROM criminal INNER JOIN CRIME_CASE ON CRIMINAL.criminal_id = CRIME_CASE.criminal_id WHERE crime_case.case_id = %s AND criminal_first = %s;"
				df = runstatement(query, (case_id, first_name))
			else:
				query = "SELECT * FROM criminal INNER JOIN CRIME_CASE ON CRIMINAL.criminal_id = CRIME_CASE.criminal_id WHERE crime_case.case_id = %s AND criminal_first = %s AND alias = %s;"   
				df = runstatement(query, (case_id, first_name, alias))
		elif(first_name == '' and last_name != ''):
			if alias == '':
				query = "SELECT * FROM criminal INNER JOIN CRIME_CASE ON CRIMINAL.criminal_id = CRIME_CASE.criminal_id WHERE crime_case.case_id = %s AND criminal_last = %s;"
				df = runstatement(query, (case_id, last_name))
			else:
				query = "SELECT * FROM criminal INNER JOIN CRIME_CASE ON CRIMINAL.criminal_id = CRIME_CASE.criminal_id WHERE crime_case.case_id = %s AND criminal_last = %s AND alias = %s;"
				df = runstatement(query, (case_id, last_name, alias))
		elif first_name != '' and last_name != '':
			if alias == '':
				query = "SELECT * FROM criminal INNER JOIN CRIME_CASE ON CRIMINAL.criminal_id = CRIME_CASE.criminal_id WHERE crime_case.case_id = %s AND criminal_first = %s AND criminal_last = %s;"
				df = runstatement(query, (case_id, first_name, last_name))
			else:
				query = "SELECT * FROM criminal INNER JOIN CRIME_CASE ON CRIMINAL.criminal_id = CRIME_CASE.criminal_id WHERE crime_case.case_id = %s AND criminal_first = %s AND criminal_last = %s AND alias = %s;"   
				df = runstatement(query, (case_id, first_name, last_name, alias))
		else:
			if alias == '':
				query = "SELECT * FROM criminal INNER JOIN CRIME_CASE ON CRIMINAL.criminal_id = CRIME_CASE.criminal_id WHERE crime_case.case_id = %s;"
				df = runstatement(query, (case_id))
			else:
				query = "SELECT * FROM criminal INNER JOIN CRIME_CASE ON CRIMINAL.criminal_id = CRIME_CASE.criminal_id WHERE crime_case.case_id = %s AND alias = %s;"   
				df = runstatement(query, (case_id, alias))
	else:
		if first_name != '' and last_name == '':
			if alias == '':
				query = "SELECT * FROM criminal WHERE criminal_first = %s;"
				df = runstatement(query, (first_name))
			else:
				query = "SELECT * FROM criminal WHERE criminal_first = %s AND alias = %s;"   
				df = runstatement(query, (first_name, alias))
		elif first_name == '' and last_name != '':
			if alias == '':
				query = "SELECT * FROM criminal WHERE criminal_last = %s;"
				df = runstatement(query, (last_name))
			else:
				query = "SELECT * FROM criminal WHERE criminal_last = %s AND alias = %s;"
				df = runstatement(query, (last_name, alias))
		elif first_name != '' and last_name != '':
			if alias == '':
				query = "SELECT * FROM criminal WHERE criminal_first = %s AND criminal_last = %s;"
				df = runstatement(query, (first_name, last_name))
			else:
				query = "SELECT * FROM criminal criminal_first = %s AND criminal_last = %s AND alias = %s;"   
				df = runstatement(query, (first_name, last_name, alias))
		else:
			if alias != '':
				query = "SELECT * FROM criminal WHERE alias = %s;"
				df = runstatement(query, (alias))
	return df

def search_officer(first_name, last_name, badge_number):
	pass

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
		first_name = request.args.get('first-name', '')
		last_name = request.args.get('last-name', '')
		alias = request.args.get('alias', '')
		case_id = request.args.get('case-num', '')
		if first_name == '' and last_name == '' and alias == '' and case_id == '':
			return render_template('home.html')
		else:
			# Initialize lists to store data
			name_list = []
			criminal_id_list = []
			alias_list = []
			criminal_address_list = []
			criminal_phonenum_list = []
			violent_list = []
			probation_list = []
			
			df = search_criminal(first_name, last_name, alias, case_id)
			# Populate lists from DataFrame
			for i, j in df.iterrows():
				name_list.append(j['criminal_first'] + ' ' + j['criminal_last'])
				alias_list.append(j['alias'])
				criminal_id_list.append(j['criminal_id'])
				criminal_address_list.append(j['criminal_address'])
				violent_list.append(j['violent_offender_stat'])
				probation_list.append(j['probation_status'])
				criminal_phonenum_list.append(j['criminal_phonenum'])
			if (len(name_list) == 0):
				return render_template ('search_results.html', empty=True)
			else:
				# Zip the lists together
				zipped_data = zip(name_list, criminal_id_list, alias_list, criminal_address_list, criminal_phonenum_list, violent_list, probation_list)
				# Render the template with zipped_data
				return render_template('search_results.html', zipped_data=zipped_data)
	elif request.method == 'POST': #If logging in
		username = request.form['username']
		password = request.form['password']
		if login(username, password):
			query = "SELECT officer_first, badge_number FROM OFFICER WHERE badge_number IN (SELECT badge_number FROM users WHERE username = %s)"
			cursor = conn.cursor()
			cursor.execute(query, (username))
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
    if "badge_number" in session:
        session_auth = str(session['badge_number'])
        if session_auth == badge_number:
            cursor = conn.cursor()
            query = "SELECT * FROM officer WHERE officer.badge_number = %s;"
            cursor.execute(query, (badge_number))
            result = cursor.fetchone()
            officer_type = result['officer_type']
            if officer_type == 'Probation':
                query = "SELECT * FROM officer INNER JOIN PROBATION ON officer.badge_number = probation.badge_number WHERE probation.badge_number = %s AND officer.badge_number = %s;"
                cursor.execute(query, (badge_number, badge_number))
                result = cursor.fetchone()
                f_name = result['officer_first']
                l_name = result['officer_last']
                precinct=result['precinct']
                officer_address = result['officer_address']
                officer_phonenum = result['officer_phonenum']
                activity_status = result['activity_status']
                criminal_id = result['criminal_id']
                query = "SELECT criminal.criminal_first, criminal.criminal_last FROM criminal INNER JOIN probation ON probation.criminal_id  = criminal.criminal_id WHERE probation.criminal_id = %s AND criminal.criminal_id = %s;"
                cursor.execute(query, (criminal_id, criminal_id))
                result = cursor.fetchone()
                cf_name = result['criminal_first']
                cl_name = result['criminal_last']
                return render_template("private_probation.html", f_name=f_name, l_name=l_name, badge_number=badge_number, precinct=precinct, officer_address=officer_address, officer_phonenum=officer_phonenum, activity_status=activity_status, criminal_id=criminal_id, cf_name=cf_name, cl_name=cl_name)
            elif officer_type == 'Arrest':
                query = "SELECT * FROM officer INNER JOIN ARREST ON officer.badge_number = arrest.badge_number WHERE arrest.badge_number = %s AND officer.badge_number = %s;"
                cursor.execute(query, (badge_number, badge_number))
                result = cursor.fetchone()
                f_name = result['officer_first']
                l_name = result['officer_last']
                precinct=result['precinct']
                officer_address = result['officer_address']
                officer_phonenum = result['officer_phonenum']
                activity_status = result['activity_status']
                criminal_id = result['criminal_id']
                crime_code = result['crime_code']
                query = "SELECT criminal.criminal_first, criminal.criminal_last FROM criminal INNER JOIN arrest ON arrest.criminal_id = criminal.criminal_id WHERE arrest.criminal_id = %s AND criminal.criminal_id = %s;"
                cursor.execute(query, (criminal_id, criminal_id))
                result = cursor.fetchone()
                cf_name = result['criminal_first']
                cl_name = result['criminal_last']
                return render_template("private_arrest.html", f_name=f_name, l_name=l_name, badge_number=badge_number, precinct=precinct, officer_address=officer_address, officer_phonenum=officer_phonenum, activity_status=activity_status, criminal_id=criminal_id, cf_name=cf_name, cl_name=cl_name)
            else:
                return render_template('error_access.html')
        else:
            return render_template('error_access.html')
    else:
        return redirect(url_for('home'))



@app.route('/logout/officer')
def officer_logout():
	session.pop("badge_number", None)
	return redirect(url_for("home"))

@app.route('/logout/admin')
def admin_logout():
	session.pop("admin", None)
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
		df = runstatement(query)
		for i, j in df.iterrows():
			badge_numbers.append(j['badge_number'])
			usernames.append(j['username'])
		zipped_data = zip(badge_numbers, usernames)
		return render_template('admin.html', zipped_data=zipped_data)
	else:
		redirect(url_for('home'))

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


@app.route('/test', methods=['POST', 'GET'])
def test():
	first_name = request.get_data
	df = runstatement("SELECT * FROM CRIMINAL;")
	criminal_ids = []
	for i, j in df.iterrows():
		criminal_ids.append(j['criminal_id'])
	return render_template('test.html', criminal_ids=criminal_ids)

if __name__ == "__main__":
	app.run('127.0.0.1', 5000, debug = True)