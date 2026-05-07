from flask_wtf import FlaskForm
from wtforms import StringField, PasswordField, BooleanField, SubmitField
from wtforms.validators import DataRequired, Length, EqualTo

class LoginForm(FlaskForm):
    """Login form for user authentication."""
    username = StringField('Username', validators=[
        DataRequired(message='Username is required'),
        Length(min=1, max=50, message='Username must be between 1 and 50 characters')
    ])
    password = PasswordField('Password', validators=[
        DataRequired(message='Password is required')
    ])
    remember_me = BooleanField('Remember Me')
    submit = SubmitField('Sign In')


class ForgotPasswordForm(FlaskForm):
    """Form to request a password reset link using email."""
    # Use simple validation to avoid external dependency on `email_validator`.
    email = StringField('Email', validators=[DataRequired(), Length(max=255)])
    submit = SubmitField('Send Reset Link')


class ResetPasswordForm(FlaskForm):
    """Form to set a new password after following reset link."""
    password = PasswordField('New Password', validators=[DataRequired(), Length(min=6)])
    confirm_password = PasswordField('Confirm Password', validators=[DataRequired(), EqualTo('password', message='Passwords must match')])
    submit = SubmitField('Reset Password')
