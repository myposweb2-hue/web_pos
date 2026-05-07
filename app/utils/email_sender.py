import smtplib
from email.message import EmailMessage
from flask import current_app


def send_email(to_email, subject, body, attachments=None):
    """Send a simple email using SMTP settings from app config.
    Expects `SMTP_SERVER`, `SMTP_PORT`, `SMTP_USERNAME`, `SMTP_PASSWORD`, `SMTP_USE_TLS` in config.
    """
    smtp_server = current_app.config.get('SMTP_SERVER')
    smtp_port = current_app.config.get('SMTP_PORT', 587)
    smtp_user = current_app.config.get('SMTP_USERNAME')
    smtp_pass = current_app.config.get('SMTP_PASSWORD')
    use_tls = current_app.config.get('SMTP_USE_TLS', True)
    from_addr = current_app.config.get('DEFAULT_FROM_EMAIL', smtp_user)

    msg = EmailMessage()
    msg['Subject'] = subject
    msg['From'] = from_addr
    msg['To'] = to_email
    msg.set_content(body)

    # Attach files if provided (list of tuples (filename, bytes, mimetype))
    if attachments:
        for filename, data, mimetype in attachments:
            maintype, subtype = mimetype.split('/', 1)
            msg.add_attachment(data, maintype=maintype, subtype=subtype, filename=filename)

    # Basic SMTP send
    try:
        if use_tls:
            server = smtplib.SMTP(smtp_server, smtp_port)
            server.starttls()
        else:
            server = smtplib.SMTP_SSL(smtp_server, smtp_port)

        if smtp_user and smtp_pass:
            server.login(smtp_user, smtp_pass)

        server.send_message(msg)
        server.quit()
        return True, 'Email sent'
    except Exception as e:
        return False, str(e)
