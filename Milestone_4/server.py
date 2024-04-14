#Import Libraries
from flask import Flask, render_template, request, session, url_for, redirect, flash
import pymysql.cursors
from flask_mysqldb import MySQL 
import pandas as PD
from werkzeug.security import generate_password_hash
from werkzeug.security import check_password_hash


#Initialize the app from Flask
app = Flask(__name__)
app.secret_key = 'jason'
#Configure MySQL
conn = pymysql.connect(host='localhost',
                       user='root',
                       password='',
                       db='jail',
                       charset='utf8mb4',
                       cursorclass=pymysql.cursors.DictCursor)

#Pass with no arguments/Pass with arguments in a tuple
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

"""
Table storing users for login/registering purposes
CREATE TABLE users (
    id INT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(50) UNIQUE NOT NULL,
    password VARCHAR(255) NOT NULL
);
"""
def register(username, password):
	hashed_password = generate_password_hash(password)
	cursor = conn.cursor()
	query = "INSERT INTO users (username, password) VALUES (%s, %s)"
	cursor.execute(query, (username, hashed_password))
	conn.commit()
	cursor.close()

def login(username, password):
	cursor = conn.cursor()
	query = "SELECT password FROM users WHERE username = %s"
	cursor.execute(query, (username))
	user = cursor.fetchone()
	cursor.close()
	if user and check_password_hash(user['password'], password):
		return True
	else:
		return False

# NEED TO DO conn.close() at the end of each app.route
@app.route('/', methods=['POST', 'GET'])
def home():
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
			#search by everything
			if first_name != '' and last_name != '' and alias != '' and case_id != '':
				query = "SELECT * FROM criminal INNER JOIN CRIME_CASE ON CRIMINAL.criminal_id = CRIME_CASE.criminal_id WHERE criminal_first = %s AND criminal_last = %s AND alias = %s AND crime_case.case_id = %s;"
				df = runstatement(query, (first_name, last_name, alias, case_id))
			#search by alias and case_id
			elif first_name == '' and last_name == '' and alias != '' and case_id != '':
				query = "SELECT * FROM criminal INNER JOIN CRIME_CASE ON CRIMINAL.criminal_id = CRIME_CASE.criminal_id WHERE alias = %s AND crime_case.case_id = %s;"
				df = runstatement(query, (alias, case_id))
			#search by name and alias
			elif first_name != '' and last_name != '' and alias != '' and case_id == '':
				query = "SELECT * FROM criminal WHERE criminal_first = %s AND criminal_last = %s AND alias = %s;"
				df = runstatement(query, (first_name, last_name, alias))
			#search by name and case_id
			elif first_name != '' and last_name != '' and alias == '' and case_id != '':
				query = "SELECT * FROM criminal INNER JOIN CRIME_CASE ON CRIMINAL.criminal_id = CRIME_CASE.criminal_id WHERE criminal_first = %s AND criminal_last = %s AND crime_case.case_id = %s;"
				df = runstatement(query, (first_name, last_name, case_id))
			#search by case_id
			elif first_name == '' and last_name == '' and alias == '' and case_id != '':
				query = "SELECT * FROM criminal INNER JOIN CRIME_CASE ON CRIMINAL.criminal_id = CRIME_CASE.criminal_id WHERE crime_case.case_id = %s;"
				df = runstatement(query, (case_id))
			#search by name
			elif first_name != '' and last_name != '' and alias == '' and case_id == '':
				query = "SELECT * FROM criminal WHERE criminal_first = %s AND criminal_last = %s;"
				df = runstatement(query, (first_name, last_name))
			#search by alias
			elif first_name == '' and last_name == '' and alias != '' and case_id == '':
				query = "SELECT * FROM criminal WHERE alias = %s;"
				df = runstatement(query, (alias))

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
			session['username'] = username
			return render_template('private_probation.html', username=username, password=password)
		else:
			return render_template('error.html')
	else:
		return render_template('home.html')		

@app.route('/register', methods=['GET', 'POST'])
def register_route():
	if request.method == 'POST':
		username = request.form['register_username']
		password = request.form['register_password']
		cursor = conn.cursor()
		query = "SELECT * FROM users WHERE username = %s;"
		cursor.execute(query, (username))
		user = cursor.fetchone()
		if user:
			flash('Username already exists. Please choose a different username.')
			cursor.close()
			return render_template('register.html')
		else:
			register(username, password)
			cursor.close()
			return redirect(url_for('home'))
	return render_template('register.html')


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
