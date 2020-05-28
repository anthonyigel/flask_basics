import os
from flask import Flask, flash, request, redirect, url_for, send_from_directory, render_template
from wtforms import Form, TextField, TextAreaField, validators, StringField, SubmitField, DateField
from werkzeug.utils import secure_filename


ALLOWED_EXTENSIONS = {"csv"}
UPLOAD_FOLDER = './uploads'

# Define Flask App
app = Flask(__name__)
app.config.from_object(__name__)
app.config['UPLOAD_FOLDER'] = UPLOAD_FOLDER
app.secret_key = "super secret key"

###############################################################
## UTILS
# Limit type of upload to valid responses
def allowed_file(filename):
    return '.' in filename and \
           filename.rsplit('.', 1)[1].lower() in ALLOWED_EXTENSIONS

###############################################################
## Menu seleciton functions
# Home
@app.route("/")
def go_home():
    return render_template("homepage.html")

# Instructions
@app.route("/directions")
def how_to():
    return render_template("how_to.html")

# Questions


###############################################################
class ReusableForm(Form):
    month = DateField('Month:', validators=[validators.required()])
    file = SubmitField('File:', validators=[validators.required()])

    # Create landing message for DG app
    @app.route('/upload', methods=['GET', 'POST'])
    def upload_file():
        form = ReusableForm(request.form)

        if request.method == 'POST':
            # Ensure a month was selected
            if 'submitted_month' not in request.form or request.form['submitted_month'] == '':
                flash(u'Error: You must select a month to submit Demand Group data for', 'Error')
                return redirect(url_for('go_home'))

            month = request.form['submitted_month']




            if form.validate():
                # Save the comment here.
                flash(u'Great job', 'success')
            return render_template("successful_upload.html", month_submission=month)

        return render_template('how_to.html')



@app.route('/uploads/<filename>')
def uploaded_file(filename):
    return send_from_directory(app.config['UPLOAD_FOLDER'],
                               filename)


if __name__ == "__main__":
    app.secret_key = 'super secret key'
    app.config['SESSION_TYPE'] = 'filesystem'

    app.debug = True
    app.run()
