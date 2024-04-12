from flask import Flask, render_template, url_for

app = Flask(__name__)

@app.route('/')
def home():
    return render_template('base.html')
    

if __name__ == "__main__":
    app.run('127.0.0.1', 5000, debug = True)