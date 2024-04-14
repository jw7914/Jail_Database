#Import Libraries
from flask import Flask, render_template, request, session, url_for, redirect
import pymysql.cursors
from flask_mysqldb import MySQL 
import pandas as PD
from werkzeug.exceptions import BadRequestKeyError

#Initialize the app from Flask
app = Flask(__name__)

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
		column_names = [desc[0] for desc in cursor.description]
		df = PD.DataFrame(results, columns=column_names)
	cursor.close()
	return df



# NEED TO DO conn.close() at the end of each app.route
@app.route('/', methods=['POST', 'GET'])
def home():
	if request.method == 'GET':
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
			case_idsearch = False
			#search by everything
			if first_name != '' and last_name != '' and alias != '' and case_id != '':
				query = "SELECT * FROM criminal INNER JOIN CRIME_CASE ON CRIMINAL.criminal_id = CRIME_CASE.criminal_id WHERE criminal_first = %s AND criminal_last = %s AND alias = %s AND crime_case.case_id = %s;"
				df = runstatement(query, (first_name, last_name, alias, case_id))
			#search by alias and case_id
			elif first_name == '' and last_name == '' and alias != '' and case_id != '':
				query = "SELECT * FROM criminal INNER JOIN CRIME_CASE ON CRIMINAL.criminal_id = CRIME_CASE.criminal_id WHERE alias = %s AND crime_case.case_id = %s;"
				df = runstatement(query, (alias, case_id))
				case_idsearch = True
			#search by name and alias
			elif first_name != '' and last_name != '' and alias != '' and case_id == '':
				query = "SELECT * FROM criminal WHERE criminal_first = %s AND criminal_last = %s AND alias = %s;"
				df = runstatement(query, (first_name, last_name, alias))
			#search by name and case_id
			elif first_name != '' and last_name != '' and alias == '' and case_id != '':
				query = "SELECT * FROM criminal INNER JOIN CRIME_CASE ON CRIMINAL.criminal_id = CRIME_CASE.criminal_id WHERE criminal_first = %s AND criminal_last = %s AND crime_case.case_id = %s;"
				df = runstatement(query, (first_name, last_name, case_id))
				case_idsearch = True
			#search by case_id
			elif first_name == '' and last_name == '' and alias == '' and case_id != '':
				query = "SELECT * FROM criminal INNER JOIN CRIME_CASE ON CRIMINAL.criminal_id = CRIME_CASE.criminal_id WHERE crime_case.case_id = %s;"
				df = runstatement(query, (case_id))
				case_idsearch = True
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
				if case_idsearch:
					criminal_id_list.append(j['criminal_id'].values[0])
				else:
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
	elif request.method == 'POST':
		username = request.form['username']
		password = request.form['password']
		#need to call an sql statement to validate which type officer to return right template
		return render_template('private_probation.html', username=username, password=password)
	else:
		return render_template('home_test.html')		

@app.route('/register')
def login():
	return render_template('register.html')

@app.route('/help')
def help():
	return render_template('help.html')

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
