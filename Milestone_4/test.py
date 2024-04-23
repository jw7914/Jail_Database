#! /Applications/XAMPP/xamppfiles/htdocs/Jail_Database/env/bin/python
#Import Libraries
from flask import Flask, render_template, request, session, url_for, redirect, flash, jsonify
import pymysql.cursors
import pandas as PD
from werkzeug.security import generate_password_hash
from werkzeug.security import check_password_hash

#Initialize the app from Flask

conn = pymysql.connect(host='localhost',
						  		user='root',
								password="",
								db='jail',
								charset='utf8mb4',
								cursorclass=pymysql.cursors.DictCursor)

conn = conn.cursor()
conn.execute("SELECT * FROM OFFICER")
print(conn.fetchall())