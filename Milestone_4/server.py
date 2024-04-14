#Import Libraries
from flask import Flask, render_template, request, session, url_for, redirect
import pymysql.cursors
from flask_mysqldb import MySQL 
import pandas as PD

#Initialize the app from Flask
app = Flask(__name__)

#Configure MySQL
conn = pymysql.connect(host='localhost',
                       user='root',
                       password='',
                       db='jail',
                       charset='utf8mb4',
                       cursorclass=pymysql.cursors.DictCursor)

def runstatement(query):
    cursor = conn.cursor()
    cursor.execute(query)
    results = cursor.fetchall()
    conn.commit()
    column_names = [desc[0] for desc in cursor.description]
    # Create a DataFrame
    df = PD.DataFrame(results, columns=column_names)
    # Close the cursor
    cursor.close()
    return df

# NEED TO DO conn.close() at the end of each app.route
@app.route('/', methods=['POST', 'GET'])
def home():
	return render_template('home_test.html')

@app.route('/login')
def login():
	return render_template('login.html')

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
