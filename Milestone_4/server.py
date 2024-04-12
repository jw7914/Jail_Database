#Import Flask Library
from flask import Flask, render_template, request, session, url_for, redirect
import pymysql.cursors

#Initialize the app from Flask
app = Flask(__name__)

#Configure MySQL
conn = pymysql.connect(host='localhost',
                       user='root',
                       password='',
                       db='jail',
                       charset='utf8mb4',
                       cursorclass=pymysql.cursors.DictCursor)


@app.route('/')
def home():
	return render_template('base.html')

@app.route('/login')
def login():
	return render_template('login.html')

@app.route('/help')
def help():
	return render_template('help.html')


if __name__ == "__main__":
	app.run('127.0.0.1', 5000, debug = True)
