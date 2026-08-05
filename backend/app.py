import os
import json
import random
import string
from datetime import datetime, timedelta
import smtplib
from email.mime.text import MIMEText
import concurrent.futures
from flask import Flask, request, jsonify, send_from_directory
from flask_cors import CORS
from flask_sqlalchemy import SQLAlchemy
from sqlalchemy.dialects.mysql import JSON
from werkzeug.utils import secure_filename
from werkzeug.security import generate_password_hash, check_password_hash
from dotenv import load_dotenv
import PyPDF2
from docx import Document

# New official Gemini SDK
from google import genai
from google.genai import types

load_dotenv(os.path.join(os.path.dirname(__file__), '.env'))

app = Flask(__name__)
CORS(app)

# Configuration
UPLOAD_FOLDER = 'uploads'
if not os.path.exists(UPLOAD_FOLDER):
    os.makedirs(UPLOAD_FOLDER)
app.config['UPLOAD_FOLDER'] = UPLOAD_FOLDER

# DB Config
app.config['SQLALCHEMY_DATABASE_URI'] = os.getenv("SQLALCHEMY_DATABASE_URI")
app.config['SQLALCHEMY_TRACK_MODIFICATIONS'] = False
port = int(os.getenv("PORT", 5000))

db = SQLAlchemy(app)

# Models
class User(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    email = db.Column(db.String(120), unique=True, nullable=False)
    password = db.Column(db.String(255), nullable=False)
    name = db.Column(db.String(100), nullable=True)
    phone = db.Column(db.String(20), nullable=True)
    role = db.Column(db.String(50), nullable=False, default="client")

class OTP(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    email = db.Column(db.String(120), unique=True, nullable=False)
    otp = db.Column(db.String(10), nullable=False)
    expires_at = db.Column(db.DateTime, nullable=False)

class Case(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    case_id = db.Column(db.String(50), unique=True, nullable=False)
    email = db.Column(db.String(120), nullable=False)
    type = db.Column(db.String(50), nullable=False)
    details = db.Column(db.JSON, nullable=True)
    analysis = db.Column(db.JSON, nullable=True)
    status = db.Column(db.String(50), nullable=False, default="Submitted")
    assigned_lawyer = db.Column(db.String(120), nullable=True)
    assigned_police = db.Column(db.String(120), nullable=True)
    handling_status = db.Column(db.String(50), nullable=True)
    created_at = db.Column(db.DateTime, nullable=False)

class Appointment(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    client_email = db.Column(db.String(120), nullable=False)
    client_name = db.Column(db.String(120), nullable=True)
    lawyer_email = db.Column(db.String(120), nullable=False)
    lawyer_name = db.Column(db.String(120), nullable=True)
    date = db.Column(db.String(50), nullable=False)
    time_slot = db.Column(db.String(50), nullable=False)
    reason = db.Column(db.Text, nullable=True)
    status = db.Column(db.String(50), nullable=False, default="Pending")
    created_at = db.Column(db.DateTime, nullable=False)

class Notification(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    user_email = db.Column(db.String(120), nullable=False)
    case_id = db.Column(db.String(50), nullable=True)
    title = db.Column(db.String(255), nullable=False)
    message = db.Column(db.Text, nullable=False)
    type = db.Column(db.String(50), nullable=False, default="info")
    is_read = db.Column(db.Boolean, default=False)
    created_at = db.Column(db.DateTime, nullable=False, default=datetime.now)

class SavedResearch(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    user_email = db.Column(db.String(120), nullable=False)
    title = db.Column(db.String(500), nullable=False)
    description = db.Column(db.Text, nullable=True)
    source_name = db.Column(db.String(255), nullable=True)
    source_url = db.Column(db.Text, nullable=False)
    image_url = db.Column(db.Text, nullable=True)
    category = db.Column(db.String(100), nullable=True)
    published_at = db.Column(db.String(100), nullable=True)
    saved_at = db.Column(db.DateTime, nullable=False, default=datetime.now)

class CaseSummary(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    case_id = db.Column(db.String(50), unique=True, nullable=False)
    title = db.Column(db.String(255), nullable=True)
    court = db.Column(db.String(255), nullable=True)
    judge = db.Column(db.String(255), nullable=True)
    client_details = db.Column(db.Text, nullable=True)
    opponent_details = db.Column(db.Text, nullable=True)
    case_status = db.Column(db.String(100), nullable=True)
    case_facts = db.Column(db.Text, nullable=True)
    ai_summary = db.Column(db.Text, nullable=True)
    previous_hearings = db.Column(db.JSON, nullable=True)
    timeline = db.Column(db.JSON, nullable=True)
    important_dates = db.Column(db.JSON, nullable=True)
    updated_at = db.Column(db.DateTime, nullable=False, default=datetime.now, onupdate=datetime.now)

class Evidence(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    case_id = db.Column(db.String(50), nullable=False)
    file_name = db.Column(db.String(255), nullable=False)
    file_path = db.Column(db.String(500), nullable=False)
    file_type = db.Column(db.String(50), nullable=False)
    category = db.Column(db.String(100), nullable=False, default="General")
    uploaded_by = db.Column(db.String(120), nullable=False)
    status = db.Column(db.String(50), nullable=False, default="Uploaded")
    uploaded_at = db.Column(db.DateTime, nullable=False, default=datetime.now)

class ArgumentNote(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    case_id = db.Column(db.String(50), nullable=False)
    lawyer_email = db.Column(db.String(120), nullable=False)
    title = db.Column(db.String(255), nullable=False, default="Untitled Note")
    is_pinned = db.Column(db.Boolean, default=False)
    opening_statement = db.Column(db.Text, nullable=True)
    facts = db.Column(db.Text, nullable=True)
    legal_issues = db.Column(db.Text, nullable=True)
    arguments = db.Column(db.Text, nullable=True)
    counter_arguments = db.Column(db.Text, nullable=True)
    case_laws = db.Column(db.Text, nullable=True)
    acts_sections = db.Column(db.Text, nullable=True)
    closing_statement = db.Column(db.Text, nullable=True)
    content = db.Column(db.Text, nullable=True)
    created_at = db.Column(db.DateTime, nullable=False, default=datetime.now)
    updated_at = db.Column(db.DateTime, nullable=False, default=datetime.now, onupdate=datetime.now)

class Hearing(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    case_id = db.Column(db.String(50), nullable=False)
    court = db.Column(db.String(255), nullable=True)
    judge = db.Column(db.String(255), nullable=True)
    hearing_date = db.Column(db.String(50), nullable=False)
    hearing_time = db.Column(db.String(50), nullable=True)
    purpose = db.Column(db.String(255), nullable=True)
    status = db.Column(db.String(50), nullable=False, default="Scheduled")
    created_at = db.Column(db.DateTime, nullable=False, default=datetime.now)

class HearingTask(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    case_id = db.Column(db.String(50), nullable=False)
    hearing_id = db.Column(db.Integer, nullable=True)
    task_name = db.Column(db.String(255), nullable=False)
    category = db.Column(db.String(50), nullable=False, default="task")
    is_completed = db.Column(db.Boolean, default=False)
    due_date = db.Column(db.String(50), nullable=True)
    created_at = db.Column(db.DateTime, nullable=False, default=datetime.now)

class ActivityLog(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    user_email = db.Column(db.String(120), nullable=False)
    action = db.Column(db.String(255), nullable=False)
    details = db.Column(db.Text, nullable=True)
    timestamp = db.Column(db.DateTime, nullable=False, default=datetime.now)

with app.app_context():
    db.create_all()
    # Seed default test users if they do not exist
    if not User.query.filter_by(email="client@gmail.com").first():
        db.session.add(User(
            email="client@gmail.com",
            password=generate_password_hash("Client123!"),
            name="Sarah Client",
            phone="9876543210",
            role="client"
        ))
    if not User.query.filter_by(email="lawyer@gmail.com").first():
        db.session.add(User(
            email="lawyer@gmail.com",
            password=generate_password_hash("Lawyer123!"),
            name="Adv. Rahul Sharma",
            phone="9876543211",
            role="lawyer"
        ))
    if not User.query.filter_by(email="police@gmail.com").first():
        db.session.add(User(
            email="police@gmail.com",
            password=generate_password_hash("Police123!"),
            name="Officer Kumar",
            phone="9876543212",
            role="police"
        ))
    if not User.query.filter_by(email="admin@gmail.com").first():
        db.session.add(User(
            email="admin@gmail.com",
            password=generate_password_hash("Admin123!"),
            name="System Admin",
            phone="9876543213",
            role="admin"
        ))
    db.session.commit()

# AI Config
gemini_api_key = os.getenv("GOOGLE_API_KEY") or os.getenv("GEMINI_API_KEY")
if gemini_api_key:
    gemini_api_key = gemini_api_key.strip()

if gemini_api_key and gemini_api_key != "YOUR_API_KEY_HERE":
    if not (gemini_api_key.startswith("AIzaSy") or gemini_api_key.startswith("AQ.")):
        print("⚠️ WARNING: GEMINI_API_KEY should start with 'AIzaSy' or 'AQ.'. Please check for missing characters.")
    ai_client = genai.Client(api_key=gemini_api_key)
else:
    ai_client = None

# ─── Helpers ────────────────────────────────────────────────────────────────

def _gen_case_id(prefix: str) -> str:
    year = datetime.now().year
    suffix = ''.join(random.choices(string.ascii_uppercase + string.digits, k=6))
    return f"{prefix}-{year}-{suffix}"

def _extract_text_from_pdf(file_path):
    text = ""
    try:
        with open(file_path, 'rb') as f:
            reader = PyPDF2.PdfReader(f)
            for page in reader.pages:
                text += page.extract_text() or ""
    except Exception as e:
        print(f"PDF Extraction Error: {e}")
    return text

def _extract_text_from_docx(file_path):
    text = ""
    try:
        doc = Document(file_path)
        for para in doc.paragraphs:
            text += para.text + "\n"
    except Exception as e:
        print(f"DOCX Extraction Error: {e}")
    return text

# ─── Routes ──────────────────────────────────────────────────────────────────

@app.route("/")
def home():
    return jsonify({"message": "LegalAssist AI Backend Running"}), 200

@app.route("/uploads/<path:filename>")
def serve_upload(filename):
    return send_from_directory(app.config['UPLOAD_FOLDER'], filename)

@app.route("/get-lawyers", methods=["GET"])
def get_lawyers():
    lawyers = User.query.filter_by(role="lawyer").all()
    return jsonify([
        {"name": u.name or u.email.split("@")[0], "email": u.email, "phone": u.phone or "N/A"}
        for u in lawyers
    ]), 200

@app.route("/get-police", methods=["GET"])
def get_police():
    police = User.query.filter_by(role="police").all()
    return jsonify([
        {"name": u.name or u.email.split("@")[0], "email": u.email, "phone": u.phone or "N/A", "role": u.role}
        for u in police
    ]), 200

@app.route("/get-all-users", methods=["GET"])
def get_all_users():
    users = User.query.all()
    return jsonify([
        {"name": u.name or u.email.split("@")[0], "email": u.email, "phone": u.phone or "N/A", "role": u.role or "client"}
        for u in users
    ]), 200

@app.route("/book-appointment", methods=["POST"])
def book_appointment():
    try:
        data = request.get_json(force=True)
        client_email = data.get("client_email")
        client_name = data.get("client_name", "")
        lawyer_email = data.get("lawyer_email")
        lawyer_name = data.get("lawyer_name", "")
        date = data.get("date")
        time_slot = data.get("time_slot")
        reason = data.get("reason", "")
        if not client_email or not lawyer_email or not date or not time_slot:
            return jsonify({"message": "Missing required fields"}), 400
        appt = Appointment(
            client_email=client_email,
            client_name=client_name,
            lawyer_email=lawyer_email,
            lawyer_name=lawyer_name,
            date=date,
            time_slot=time_slot,
            reason=reason,
            status="Pending",
            created_at=datetime.now()
        )
        db.session.add(appt)
        db.session.commit()
        return jsonify({"message": "Appointment booked successfully", "id": appt.id}), 200
    except Exception as e:
        return jsonify({"message": str(e)}), 500

@app.route("/get-appointments", methods=["GET"])
def get_appointments():
    email = request.args.get("email")
    role = request.args.get("role", "client")
    if role == "lawyer":
        appts = Appointment.query.filter_by(lawyer_email=email).order_by(Appointment.created_at.desc()).all()
    else:
        appts = Appointment.query.filter_by(client_email=email).order_by(Appointment.created_at.desc()).all()
    return jsonify([{
        "id": a.id,
        "client_email": a.client_email,
        "client_name": a.client_name,
        "lawyer_email": a.lawyer_email,
        "lawyer_name": a.lawyer_name,
        "date": a.date,
        "time_slot": a.time_slot,
        "reason": a.reason,
        "status": a.status,
        "created_at": a.created_at.isoformat() if a.created_at else None
    } for a in appts]), 200

@app.route("/update-appointment-status", methods=["POST"])
def update_appointment_status():
    try:
        data = request.get_json(force=True)
        appt_id = data.get("id")
        status = data.get("status")
        appt = Appointment.query.get(appt_id)
        if not appt:
            return jsonify({"message": "Appointment not found"}), 404
        appt.status = status
        db.session.commit()
        return jsonify({"message": "Status updated"}), 200
    except Exception as e:
        return jsonify({"message": str(e)}), 500

@app.route("/signup", methods=["POST"])
def signup():
    data = request.get_json()
    email = data.get("email")
    password = data.get("password")
    requested_role = data.get("role", "client")
    
    if not email or not password:
        return jsonify({"message": "Email and password required"}), 400
        
    if requested_role in ["lawyer", "police", "admin"]:
        return jsonify({"message": "Lawyer, Police, and Admin accounts can only be created by an Administrator."}), 400

    if User.query.filter_by(email=email).first():
        return jsonify({"message": "User already exists"}), 400
        
    new_user = User(
        email=email,
        password=generate_password_hash(password),
        name=data.get("name"),
        phone=data.get("phone"),
        role="client"
    )
    db.session.add(new_user)
    db.session.commit()
    return jsonify({"message": "Signup successful"}), 201

@app.route("/admin/create-user", methods=["POST"])
def admin_create_user():
    data = request.get_json()
    email = data.get("email")
    password = data.get("password")
    role = data.get("role", "lawyer")
    if role == "admin":
        return jsonify({"message": "Cannot create additional Admin accounts. There is only one Admin for the project."}), 400
    if not email or not password:
        return jsonify({"message": "Email and password required"}), 400
    if User.query.filter_by(email=email).first():
        return jsonify({"message": "User with this email already exists"}), 400
    new_user = User(
        email=email,
        password=generate_password_hash(password),
        name=data.get("name"),
        phone=data.get("phone"),
        role=role
    )
    db.session.add(new_user)
    db.session.commit()
    return jsonify({"message": f"{role.capitalize()} account created successfully"}), 201

@app.route("/verify-user", methods=["GET"])
def verify_user():
    email = request.args.get("email")
    if not email:
        return jsonify({"valid": False, "message": "Email required"}), 400
    user = User.query.filter_by(email=email).first()
    if user:
        return jsonify({"valid": True, "role": user.role, "name": user.name}), 200
    return jsonify({"valid": False, "message": "User not registered"}), 404

@app.route("/google-login", methods=["POST"])
def google_login():
    try:
        data = request.get_json(force=True) or {}
        email = data.get("email")
        name = data.get("name")
        
        if not email:
            return jsonify({"message": "Email is required"}), 400
            
        user = User.query.filter_by(email=email).first()
        if not user:
            user = User(
                email=email,
                name=name or email.split('@')[0],
                password=generate_password_hash("GOOGLE_AUTH_USER"),
                role="client",
                phone=""
            )
            db.session.add(user)
            db.session.commit()
            
        return jsonify({
            "message": "Google Login successful",
            "name": user.name,
            "email": user.email,
            "role": user.role,
            "phone": user.phone or ""
        }), 200
    except Exception as e:
        print(f"Google login error: {e}")
        return jsonify({"message": f"Server error: {str(e)}"}), 500

@app.route("/login", methods=["POST"])
def login():
    data = request.get_json()
    email = data.get("email")
    password = data.get("password")
    if not email or not password:
        return jsonify({"message": "Email and password required"}), 400
        
    user = User.query.filter_by(email=email).first()
    if not user:
        return jsonify({"message": "User not found. Please sign up first."}), 404
        
    if check_password_hash(user.password, password):
        user_dict = {"email": user.email, "name": user.name, "phone": user.phone, "role": user.role}
        return jsonify({"message": "Login successful", **user_dict}), 200
    return jsonify({"message": "Invalid password"}), 401

def send_otp_email(recipient_email, otp):
    smtp_server = os.getenv("SMTP_SERVER", "smtp.gmail.com")
    smtp_port = int(os.getenv("SMTP_PORT", 587))
    sender_email = os.getenv("SMTP_EMAIL")
    sender_password = os.getenv("SMTP_PASSWORD")

    if not sender_email or not sender_password:
        print(f"Mock Email sent to {recipient_email}. OTP is {otp}")
        return True

    try:
        msg = MIMEText(f"Your LexisAI Password Reset OTP is: {otp}\n\nThis OTP is valid for 10 minutes.")
        msg["Subject"] = "LexisAI Password Reset OTP"
        msg["From"] = sender_email
        msg["To"] = recipient_email

        with smtplib.SMTP(smtp_server, smtp_port) as server:
            server.starttls()
            server.login(sender_email, sender_password)
            server.send_message(msg)
        return True
    except Exception as e:
        print(f"Error sending email: {e}")
        print(f"Fallback Mock Email. OTP is {otp}")
        return False

@app.route("/forgot-password", methods=["POST"])
def forgot_password():
    data = request.get_json()
    email = data.get("email")
    if not email:
        return jsonify({"message": "Email is required"}), 400

    user = User.query.filter_by(email=email).first()
    if not user:
        return jsonify({"message": "User not found"}), 404

    otp_val = ''.join(random.choices(string.digits, k=6))
    expires_at = datetime.now() + timedelta(minutes=10)
    
    otp_record = OTP.query.filter_by(email=email).first()
    if otp_record:
        otp_record.otp = otp_val
        otp_record.expires_at = expires_at
    else:
        new_otp = OTP(email=email, otp=otp_val, expires_at=expires_at)
        db.session.add(new_otp)
    db.session.commit()

    send_otp_email(email, otp_val)
    return jsonify({"message": "OTP sent to email successfully"}), 200

@app.route("/reset-password", methods=["POST"])
def reset_password():
    data = request.get_json()
    email = data.get("email")
    otp = data.get("otp")
    new_password = data.get("password")

    if not email or not otp or not new_password:
        return jsonify({"message": "Missing required fields"}), 400

    record = OTP.query.filter_by(email=email).first()
    if not record:
        return jsonify({"message": "No OTP requested for this email"}), 400

    if record.otp != otp:
        return jsonify({"message": "Invalid OTP"}), 400

    if datetime.now() > record.expires_at:
        db.session.delete(record)
        db.session.commit()
        return jsonify({"message": "OTP expired"}), 400

    hashed_pw = generate_password_hash(new_password)
    user = User.query.filter_by(email=email).first()
    if user:
        user.password = hashed_pw
    db.session.delete(record)
    db.session.commit()

    return jsonify({"message": "Password reset successful"}), 200

@app.route("/update-profile", methods=["POST"])
def update_profile():
    data = request.get_json()
    email = data.get("email")
    user = User.query.filter_by(email=email).first()
    if user:
        if "name" in data: user.name = data.get("name")
        if "phone" in data: user.phone = data.get("phone")
        db.session.commit()
    return jsonify({"message": "Profile updated"}), 200

@app.route("/ai-chat", methods=["POST"])
def ai_chat():
    data = request.get_json(force=True) or {}
    message = data.get("message", "")
    history = data.get("history", [])

    system_prompt = """
    You are LexisCore AI, a professional and authoritative legal assistant. 
    Your expertise is strictly limited to the legal domain. 
    Rules:                                                                                                                                                                                                                                                          
    1. Only answer questions related to law, legal procedures, rights, and regulations under Indian law (BNS 2023, PWDVA 2005, etc.).
    2. If a user asks about medical, general knowledge, entertainment, or any non-legal topic, politely state that you are a specialized legal AI.
    3. Always try to cite relevant legal sections if applicable.
    4. Provide clear 'Next Steps' for legal situations.
    5. Maintain a professional, neutral, and helpful tone.
    """

    if ai_client:
        try:
            gemini_history = []
            for turn in history:
                role = "user" if turn.get("role") == "user" else "model"
                gemini_history.append(types.Content(
                    role=role,
                    parts=[types.Part(text=turn.get("text", ""))]
                ))
            
            chat = ai_client.chats.create(
                model="gemini-2.5-flash",
                history=gemini_history,
                config=types.GenerateContentConfig(
                    system_instruction=system_prompt,
                    temperature=0.7,
                )
            )
            response = chat.send_message(message)
            if response and response.text:
                return jsonify({"response": response.text.strip()}), 200
        except Exception as e:
            print(f"AI Chat Error: {str(e)}")

    reply = (
        f"Hello! Regarding your query ('{message}'):\n\n"
        "1. **Legal Protections**: Under Indian law (including Bharatiya Nyaya Sanhita, 2023), you have protected rights to seek legal remedies, file complaints, and request police intervention.\n"
        "2. **Recommended Action**: Gather relevant documents (ID proof, incident records, communications) and record specific dates and locations.\n"
        "3. **Next Steps**: You can submit a full incident report via our **Cases** tab for automated BNS FIR drafting, or schedule an appointment with a legal advocate in the **Appointments** tab."
    )
    return jsonify({"response": reply}), 200

@app.route("/assign-case", methods=["POST"])
def assign_case():
    data = request.get_json()
    case_id = data.get("case_id")
    assign_to = data.get("assign_to")
    email = data.get("email")
    
    if not case_id or not assign_to:
        return jsonify({"message": "Missing required fields"}), 400
        
    case = Case.query.filter_by(case_id=case_id).first()
    if not case:
        return jsonify({"message": "Case not found"}), 404
        
    if assign_to == "lawyer":
        case.assigned_lawyer = email or "unassigned_lawyer_pool"
        case.handling_status = "Lawyer Assigned" if email else "Lawyer Requested"
        if email:
            case.status = "Assigned"
    elif assign_to == "police":
        case.assigned_police = email or "unassigned_police_pool"
        case.handling_status = "Police Assigned" if email else "Police Notified"
        if email:
            case.status = "Assigned"

    # Create notification for client
    notif = Notification(
        user_email=case.email,
        case_id=case.case_id,
        title=f"Case {case.case_id} Submitted to {assign_to.capitalize()}",
        message=f"Your case ({case.type}) was successfully submitted to {assign_to.capitalize()} ({email}). You will be notified when they review it.",
        type="info",
        created_at=datetime.now()
    )
    db.session.add(notif)
        
    db.session.commit()
    return jsonify({"message": f"Case assigned to {assign_to} successfully"}), 200


@app.route("/accept-case", methods=["POST"])
def accept_case():
    try:
        data = request.get_json(force=True) or {}
        print(f"Case action request: {data}")
        case_id = data.get("case_id")
        role = data.get("role")
        action = data.get("action", "accept")  # 'accept' or 'decline'
        official_name = data.get("official_name", "")
        official_email = data.get("official_email", "")
        
        if not case_id or not role:
            return jsonify({"message": "Missing required fields", "received": str(data)}), 400
            
        case = Case.query.filter_by(case_id=str(case_id)).first()
        if not case:
            all_ids = [c.case_id for c in Case.query.all()]
            return jsonify({"message": f"Case not found: {case_id}", "available_ids": all_ids}), 404

        display_official = official_name if official_name else (official_email if official_email else role.capitalize())

        if action == "decline":
            if role == "lawyer":
                case.handling_status = "Lawyer Declined"
                case.assigned_lawyer = None
            elif role == "police":
                case.handling_status = "Police Declined"
                case.assigned_police = None
            case.status = "Action Needed"

            notif = Notification(
                user_email=case.email,
                case_id=case.case_id,
                title=f"Case {case.case_id} Declined",
                message=f"The {role.capitalize()} ({display_official}) has declined your case ({case.type}). You can choose another registered official from your portal.",
                type="decline",
                created_at=datetime.now()
            )
            db.session.add(notif)
            db.session.commit()
            return jsonify({"message": f"Case declined by {role} successfully"}), 200

        else:  # Accept
            if role == "lawyer":
                case.handling_status = "Lawyer Accepted"
                case.status = "Under Review"
            elif role == "police":
                case.handling_status = "Police Accepted"
                case.status = "Under Review"

            notif = Notification(
                user_email=case.email,
                case_id=case.case_id,
                title=f"Case {case.case_id} Accepted!",
                message=f"Great news! The {role.capitalize()} ({display_official}) has accepted your case ({case.type}) and initiated review.",
                type="accept",
                created_at=datetime.now()
            )
            db.session.add(notif)
            db.session.commit()
            return jsonify({"message": f"Case accepted by {role} successfully"}), 200

    except Exception as e:
        print(f"Accept case error: {e}")
        return jsonify({"message": f"Server error: {str(e)}"}), 500

@app.route("/get-notifications", methods=["GET"])
def get_notifications():
    email = request.args.get("email")
    if not email:
        return jsonify([]), 200
    notifs = Notification.query.filter_by(user_email=email).order_by(Notification.created_at.desc()).all()
    return jsonify([{
        "id": n.id,
        "case_id": n.case_id,
        "title": n.title,
        "message": n.message,
        "type": n.type,
        "is_read": n.is_read,
        "created_at": n.created_at.isoformat() if n.created_at else None
    } for n in notifs]), 200

@app.route("/mark-notifications-read", methods=["POST"])
def mark_notifications_read():
    try:
        data = request.get_json(force=True) or {}
        email = data.get("email")
        if email:
            Notification.query.filter_by(user_email=email, is_read=False).update({Notification.is_read: True})
            db.session.commit()
        return jsonify({"message": "Notifications marked as read"}), 200
    except Exception as e:
        return jsonify({"message": str(e)}), 500

@app.route("/lawyer/cases", methods=["GET"])
def lawyer_cases():
    email = request.args.get("email")
    if email:
        cases = Case.query.filter((Case.assigned_lawyer == email) | (Case.assigned_lawyer == "unassigned_lawyer_pool")).all()
    else:
        cases = Case.query.filter(Case.assigned_lawyer != None).all()
    all_cases = []
    for c in cases:
        details = c.details or {}
        if "uploaded_files" in details:
            sanitized = {}
            for k, v in details["uploaded_files"].items():
                if v:
                    rel_path = os.path.relpath(v, app.config['UPLOAD_FOLDER']).replace('\\', '/')
                    sanitized[k] = rel_path
                else:
                    sanitized[k] = ""
            details = {**details, "uploaded_files": sanitized}
        all_cases.append({
            "case_id": c.case_id,
            "type": c.type,
            "email": c.email,
            "details": details,
            "analysis": c.analysis,
            "status": c.status,
            "handling_status": c.handling_status,
            "assigned_lawyer": c.assigned_lawyer,
            "assigned_police": c.assigned_police,
            "created_at": c.created_at.isoformat() if c.created_at else None
        })
    return jsonify(all_cases), 200

@app.route("/police/cases", methods=["GET"])
def police_cases():
    email = request.args.get("email")
    if email:
        cases = Case.query.filter((Case.assigned_police == email) | (Case.assigned_police == "unassigned_police_pool")).order_by(Case.created_at.desc()).all()
    else:
        cases = Case.query.filter(Case.assigned_police != None).order_by(Case.created_at.desc()).all()
    all_cases = []
    for c in cases:
        details = c.details or {}
        if "uploaded_files" in details:
            sanitized = {}
            for k, v in details["uploaded_files"].items():
                if v:
                    rel_path = os.path.relpath(v, app.config['UPLOAD_FOLDER']).replace('\\', '/')
                    sanitized[k] = rel_path
                else:
                    sanitized[k] = ""
            details = {**details, "uploaded_files": sanitized}
        all_cases.append({
            "case_id": c.case_id,
            "type": c.type,
            "email": c.email,
            "details": details,
            "analysis": c.analysis,
            "status": c.status,
            "handling_status": c.handling_status,
            "assigned_lawyer": c.assigned_lawyer,
            "assigned_police": c.assigned_police,
            "created_at": c.created_at.isoformat() if c.created_at else None
        })
    return jsonify(all_cases), 200




@app.route("/submit-land-fraud", methods=["POST"])
def submit_land_fraud():
    try:
        email = request.form.get("email")
        location = request.form.get("location")
        category_dir = os.path.join(app.config['UPLOAD_FOLDER'], 'land_fraud')
        os.makedirs(category_dir, exist_ok=True)
        # File handling
        uploaded_files = {}
        extracted_text = ""
        for key in ["property_doc", "id_proof"]:
            if key in request.files:
                f = request.files[key]
                if f.filename != "":
                    path = os.path.join(category_dir, secure_filename(f.filename))
                    f.save(path)
                    uploaded_files[key] = path
                    if path.endswith(".pdf"): extracted_text += _extract_text_from_pdf(path)
                    elif path.endswith(".docx"): extracted_text += _extract_text_from_docx(path)

        # AI Analysis
        analysis = {
            "risk_level": "HIGH",
            "risk_summary": "Possible document forgery detected.",
            "case_summary": "Case reported.",
            "how_risk_analysis_calculated": "Calculated based on severity of the incident and evidence provided.",
            "extracted_info": {"ownership_name": "Unknown", "survey_number": "N/A", "registration_date": "N/A"},
            "government_record_name": "Official Record Name",
            "warnings": ["Mismatch in registration seal."],
            "legal_actions": ["File FIR", "Apply for Injunction"],
            "fir_draft": "Draft text..."
        }
        if ai_client:
            prompt = f"Analyze this land fraud case: {request.form.get('description')}\nExtracted text: {extracted_text}\nReturn JSON with keys: risk_level, risk_summary, case_summary, how_risk_analysis_calculated, extracted_info (ownership_name, survey_number, registration_date), government_record_name, warnings, legal_actions, fir_draft"
            try:
                res = ai_client.models.generate_content(model="gemini-2.5-flash", contents=prompt)
                txt = res.text.strip()
                if "```json" in txt: txt = txt.split("```json")[1].split("```")[0]
                analysis = json.loads(txt)
            except: pass

        case_id = _gen_case_id("LND")
        new_case = Case(
            case_id=case_id,
            email=email,
            type="Land Dispute",
            details={"uploaded_files": uploaded_files},
            analysis=analysis,
            status="Submitted",
            created_at=datetime.now()
        )
        db.session.add(new_case)
        db.session.commit()
        analysis["case_id"] = case_id
        return jsonify(analysis), 200
    except Exception as e:
        return jsonify({"error": str(e)}), 500


@app.route("/submit-cyber-crime", methods=["POST"])
def submit_cyber_crime():
    try:
        email = request.form.get("email")
        incident_type = request.form.get("incident_type")
        description = request.form.get("description")
        amount = request.form.get("amount", "0")
        
        category_dir = os.path.join(app.config['UPLOAD_FOLDER'], 'cyber_crime')
        os.makedirs(category_dir, exist_ok=True)
        # File handling
        uploaded_files = {}
        extracted_text = ""
        for key in ["evidence", "id_proof"]:
            if key in request.files:
                f = request.files[key]
                if f.filename != "":
                    path = os.path.join(category_dir, secure_filename(f.filename))
                    f.save(path)
                    uploaded_files[key] = path
                    if path.lower().endswith(".pdf"):
                        extracted_text += f"\n[File: {f.filename}]\n" + _extract_text_from_pdf(path)
                    elif path.lower().endswith(".docx"):
                        extracted_text += f"\n[File: {f.filename}]\n" + _extract_text_from_docx(path)

        analysis = {
            "risk_level": "MEDIUM",
            "fraud_type_detected": incident_type,
            "case_summary": "Cyber fraud reported.",
            "how_risk_analysis_calculated": "Calculated based on severity of the incident and evidence provided.",
            "missing_evidence": ["Bank Statement"],
            "suggested_sections": ["IT Act Sec 66D"],
            "complaint_draft": "Cyber complaint text..."
        }
        if ai_client:
            prompt = f"""
            Analyze this cyber crime report:
            Incident Type: {incident_type}
            Description: {description}
            Amount Lost: {amount}
            
            Extracted Text from Evidence Files:
            {extracted_text}
            
            Respond in JSON format with keys: risk_level, fraud_type_detected, case_summary, how_risk_analysis_calculated, missing_evidence (list), suggested_sections (list), complaint_draft.
            Ensure the recommendations are specific to the evidence found.
            """
            try:
                res = ai_client.models.generate_content(model="gemini-2.5-flash", contents=prompt)
                txt = res.text.strip()
                if "```json" in txt: txt = txt.split("```json")[1].split("```")[0]
                analysis = json.loads(txt)
            except: pass

        case_id = _gen_case_id("CYB")
        new_case = Case(
            case_id=case_id,
            email=email,
            type="Cyber Crime",
            details={
                "incident_type": incident_type,
                "description": description,
                "amount": amount,
                "uploaded_files": uploaded_files
            },
            analysis=analysis,
            status="Submitted",
            created_at=datetime.now()
        )
        db.session.add(new_case)
        db.session.commit()
        analysis["case_id"] = case_id
        return jsonify(analysis), 200
    except Exception as e:
        return jsonify({"error": str(e)}), 500

@app.route("/submit-traffic-issue", methods=["POST"])
def submit_traffic_issue():
    try:
        email = request.form.get("email")
        case_type = request.form.get("case_type")
        vehicle_number = request.form.get("vehicle_number")
        location = request.form.get("location")
        date_time = request.form.get("date_time")
        description = request.form.get("description")
        
        category_dir = os.path.join(app.config['UPLOAD_FOLDER'], 'traffic_issue')
        os.makedirs(category_dir, exist_ok=True)
        # File handling
        uploaded_files = {}
        extracted_text = ""
        for key in ["evidence", "challan", "insurance", "rc", "dl"]:
            if key in request.files:
                f = request.files[key]
                if f.filename != "":
                    path = os.path.join(category_dir, secure_filename(f.filename))
                    f.save(path)
                    uploaded_files[key] = path
                    if path.lower().endswith(".pdf"):
                        extracted_text += f"\n[File: {f.filename}, Category: {key}]\n" + _extract_text_from_pdf(path)
                    elif path.lower().endswith(".docx"):
                        extracted_text += f"\n[File: {f.filename}, Category: {key}]\n" + _extract_text_from_docx(path)

        analysis = {
            "risk_level": "LOW",
            "issue_type": case_type,
            "case_summary": "Traffic issue reported.",
            "how_risk_analysis_calculated": "Calculated based on severity of the incident and evidence provided.",
            "missing_documents": [],
            "suggested_steps": ["Review traffic laws"],
            "legal_document": "Draft of appeal/claim..."
        }
        
        if ai_client:
            prompt = f"""
            Analyze this traffic legal issue:
            Case Type: {case_type}
            Vehicle Number: {vehicle_number}
            Location: {location}
            Date & Time: {date_time}
            Description: {description}
            
            Extracted Text from Uploaded Documents:
            {extracted_text}
            
            Respond in JSON format with keys: 
            - risk_level (LOW, MEDIUM, HIGH)
            - issue_type (detected type)
            - fine_validity (if applicable, explanation)
            - missing_documents (list of recommended docs)
            - case_summary (concise summary)
            - how_risk_analysis_calculated (explanation of risk calculation)
            - suggested_steps (list of legal steps)
            - legal_document (A professional, auto-generated appeal letter, accident complaint, or insurance claim support document based on the case type)
            
            Ensure the legal document is comprehensive and ready for submission.
            """
            try:
                res = ai_client.models.generate_content(model="gemini-2.5-flash", contents=prompt)
                txt = res.text.strip()
                if "```json" in txt: txt = txt.split("```json")[1].split("```")[0]
                analysis = json.loads(txt)
            except: pass

        case_id = _gen_case_id("TRF")
        new_case = Case(
            case_id=case_id,
            email=email,
            type="Traffic Issue",
            details={
                "case_type": case_type,
                "vehicle_number": vehicle_number,
                "location": location,
                "date_time": date_time,
                "description": description,
                "uploaded_files": uploaded_files
            },
            analysis=analysis,
            status="Submitted",
            created_at=datetime.now()
        )
        db.session.add(new_case)
        db.session.commit()
        analysis["case_id"] = case_id
        return jsonify(analysis), 200
    except Exception as e:
        return jsonify({"error": str(e)}), 500

@app.route("/submit-women-safety-report", methods=["POST"])
def submit_women_safety_report():
    try:
        email = request.form.get("email")
        description = request.form.get("description")
        location = request.form.get("location", "Unknown")
        emergency_contacts_notified = request.form.get("emergency_contacts_notified", "false")
        
        category_dir = os.path.join(app.config['UPLOAD_FOLDER'], 'women_safety')
        os.makedirs(category_dir, exist_ok=True)
        # File handling
        uploaded_files = {}
        extracted_text = ""
        for key in ["evidence", "audio", "video"]:
            if key in request.files:
                f = request.files[key]
                if f.filename != "":
                    path = os.path.join(category_dir, secure_filename(f.filename))
                    f.save(path)
                    uploaded_files[key] = path
                    if path.lower().endswith(".pdf"):
                        extracted_text += f"\n[File: {f.filename}]\n" + _extract_text_from_pdf(path)

        analysis = {
            "risk_level": "HIGH",
            "case_summary": "Women safety emergency reported.",
            "how_risk_analysis_calculated": "Calculated based on severity of the incident and evidence provided.",
            "safety_advice": ["Move to a crowded place", "Contact nearest police station"],
            "legal_actions": ["File FIR under Section 354"],
            "rights_info": "You have the right to file a Zero FIR at any police station."
        }
        
        if ai_client:
            prompt = f"""
            Analyze this women safety situation:
            Description: {description}
            Location: {location}
            
            Respond in JSON format with keys: 
            - risk_level (HIGH, MEDIUM, LOW)
            - case_summary (concise summary)
            - how_risk_analysis_calculated (explanation of risk calculation)
            - safety_advice (list of immediate safety tips)
            - legal_actions (list of legal steps)
            - rights_info (summary of legal rights in this context)
            """
            try:
                res = ai_client.models.generate_content(model="gemini-2.5-flash", contents=prompt)
                txt = res.text.strip()
                if "```json" in txt: txt = txt.split("```json")[1].split("```")[0]
                analysis = json.loads(txt)
            except: pass

        case_id = _gen_case_id("WSF")
        new_case = Case(
            case_id=case_id,
            email=email,
            type="Women Safety",
            details={
                "description": description,
                "location": location,
                "emergency_contacts_notified": emergency_contacts_notified,
                "uploaded_files": uploaded_files
            },
            analysis=analysis,
            status="Submitted",
            created_at=datetime.now()
        )
        db.session.add(new_case)
        db.session.commit()
        analysis["case_id"] = case_id
        return jsonify(analysis), 200
    except Exception as e:
        return jsonify({"error": str(e)}), 500

@app.route("/submit-employee-right-case", methods=["POST"])
def submit_employee_right_case():
    try:
        email = request.form.get("email")
        case_type = request.form.get("case_type")
        company_name = request.form.get("company_name")
        job_role = request.form.get("job_role")
        duration_work = request.form.get("duration_work")
        salary_pending = request.form.get("salary_pending", "0")
        description = request.form.get("description")
        
        category_dir = os.path.join(app.config['UPLOAD_FOLDER'], 'employee_rights')
        os.makedirs(category_dir, exist_ok=True)
        # File handling
        uploaded_files = {}
        extracted_text = ""
        for key in ["salary_slips", "offer_letter", "contract", "termination_letter"]:
            if key in request.files:
                f = request.files[key]
                if f.filename != "":
                    path = os.path.join(category_dir, secure_filename(f.filename))
                    f.save(path)
                    uploaded_files[key] = path
                    if path.lower().endswith(".pdf"):
                        extracted_text += f"\n[File: {f.filename}, Type: {key}]\n" + _extract_text_from_pdf(path)

        analysis = {
            "risk_level": "MEDIUM",
            "case_summary": "Employment dispute reported.",
            "how_risk_analysis_calculated": "Calculated based on severity of the incident and evidence provided.",
            "violations_detected": ["Possible wage withholding"],
            "suggested_steps": ["Issue legal notice", "Lodge complaint with labor commissioner"],
            "legal_notice": "Draft of salary demand notice..."
        }
        
        if ai_client:
            prompt = f"""
            Analyze this employee rights legal issue:
            Case Type: {case_type}
            Company Name: {company_name}
            Job Role: {job_role}
            Duration of Work: {duration_work}
            Salary Pending: {salary_pending}
            Description: {description}
            
            Extracted Text from Documents:
            {extracted_text}
            
            Respond in JSON format with keys: 
            - risk_level (LOW, MEDIUM, HIGH)
            - case_summary (concise summary)
            - how_risk_analysis_calculated (explanation of risk calculation)
            - violations_detected (list of labor law violations found)
            - suggested_steps (list of legal steps for the employee)
            - legal_notice (A professional, auto-generated legal notice or labor office complaint based on the case type)
            
            Ensure the legal notice is comprehensive and tailored to the employee's specific situation.
            """
            try:
                res = ai_client.models.generate_content(model="gemini-2.5-flash", contents=prompt)
                txt = res.text.strip()
                if "```json" in txt: txt = txt.split("```json")[1].split("```")[0]
                analysis = json.loads(txt)
            except: pass

        case_id = _gen_case_id("EMP")
        new_case = Case(
            case_id=case_id,
            email=email,
            type="Employee Rights",
            details={
                "case_type": case_type,
                "company_name": company_name,
                "job_role": job_role,
                "duration_work": duration_work,
                "salary_pending": salary_pending,
                "description": description,
                "uploaded_files": uploaded_files
            },
            analysis=analysis,
            status="Submitted",
            created_at=datetime.now()
        )
        db.session.add(new_case)
        db.session.commit()
        analysis["case_id"] = case_id
        return jsonify(analysis), 200
    except Exception as e:
        return jsonify({"error": str(e)}), 500

@app.route("/submit-tenant-issue", methods=["POST"])
def submit_tenant_issue():
    try:
        email = request.form.get("email")
        case_type = request.form.get("case_type")
        property_address = request.form.get("property_address")
        owner_name = request.form.get("owner_name", "Optional")
        duration_stay = request.form.get("duration_stay")
        deposit_amount = request.form.get("deposit_amount", "0")
        description = request.form.get("description")
        
        category_dir = os.path.join(app.config['UPLOAD_FOLDER'], 'tenant_issue')
        os.makedirs(category_dir, exist_ok=True)
        # File handling
        uploaded_files = {}
        extracted_text = ""
        for key in ["rent_agreement", "payment_proof", "receipts"]:
            if key in request.files:
                f = request.files[key]
                if f.filename != "":
                    path = os.path.join(category_dir, secure_filename(f.filename))
                    f.save(path)
                    uploaded_files[key] = path
                    if path.lower().endswith(".pdf"):
                        extracted_text += f"\n[File: {f.filename}, Type: {key}]\n" + _extract_text_from_pdf(path)

        analysis = {
            "risk_level": "LOW",
            "case_summary": "Tenant issue reported.",
            "how_risk_analysis_calculated": "Calculated based on severity of the incident and evidence provided.",
            "agreement_terms": "Standard agreement detected.",
            "suggested_steps": ["Check local rental laws", "Send formal notice"],
            "legal_notice": "Draft of deposit return notice..."
        }
        
        if ai_client:
            prompt = f"""
            Analyze this tenant legal issue:
            Case Type: {case_type}
            Property Address: {property_address}
            Owner Name: {owner_name}
            Duration of Stay: {duration_stay}
            Deposit Amount: {deposit_amount}
            Description: {description}
            
            Extracted Text from Documents:
            {extracted_text}
            
            Respond in JSON format with keys: 
            - risk_level (LOW, MEDIUM, HIGH)
            - case_summary (concise summary)
            - how_risk_analysis_calculated (explanation of risk calculation)
            - agreement_terms (summary of key terms found)
            - suggested_steps (list of legal/mediation steps)
            - legal_notice (A professional, auto-generated legal notice or eviction response based on the case type)
            
            Ensure the legal notice is comprehensive and tailored to the tenant's specific situation.
            """
            try:
                res = ai_client.models.generate_content(model="gemini-2.5-flash", contents=prompt)
                txt = res.text.strip()
                if "```json" in txt: txt = txt.split("```json")[1].split("```")[0]
                analysis = json.loads(txt)
            except: pass

        case_id = _gen_case_id("TEN")
        new_case = Case(
            case_id=case_id,
            email=email,
            type="Tenant Issue",
            details={
                "case_type": case_type,
                "property_address": property_address,
                "owner_name": owner_name,
                "duration_stay": duration_stay,
                "deposit_amount": deposit_amount,
                "description": description,
                "uploaded_files": uploaded_files
            },
            analysis=analysis,
            status="Submitted",
            created_at=datetime.now()
        )
        db.session.add(new_case)
        db.session.commit()
        analysis["case_id"] = case_id
        return jsonify(analysis), 200
    except Exception as e:
        return jsonify({"error": str(e)}), 500

@app.route("/submit-consumer-complaint", methods=["POST"])
def submit_consumer_complaint():
    try:
        email = request.form.get("email")
        case_type = request.form.get("case_type")
        product_name = request.form.get("product_name")
        seller_name = request.form.get("seller_name")
        purchase_date = request.form.get("purchase_date")
        amount_paid = request.form.get("amount_paid", "0")
        description = request.form.get("description")
        
        category_dir = os.path.join(app.config['UPLOAD_FOLDER'], 'consumer_complaint')
        os.makedirs(category_dir, exist_ok=True)
        # File handling
        uploaded_files = {}
        extracted_text = ""
        for key in ["bill_invoice", "product_photos", "delivery_proof"]:
            if key in request.files:
                f = request.files[key]
                if f.filename != "":
                    path = os.path.join(category_dir, secure_filename(f.filename))
                    f.save(path)
                    uploaded_files[key] = path
                    if path.lower().endswith(".pdf"):
                        extracted_text += f"\n[File: {f.filename}, Type: {key}]\n" + _extract_text_from_pdf(path)

        analysis = {
            "risk_level": "LOW",
            "case_summary": "Consumer complaint reported.",
            "how_risk_analysis_calculated": "Calculated based on severity of the incident and evidence provided.",
            "refund_eligibility": "High",
            "suggested_steps": ["Contact seller", "File consumer court complaint"],
            "legal_document": "Draft of refund request letter..."
        }
        
        if ai_client:
            prompt = f"""
            Analyze this consumer legal issue:
            Case Type: {case_type}
            Product/Service: {product_name}
            Seller/Company: {seller_name}
            Purchase Date: {purchase_date}
            Amount Paid: {amount_paid}
            Description: {description}
            
            Extracted Text from Documents:
            {extracted_text}
            
            Respond in JSON format with keys: 
            - risk_level (LOW, MEDIUM, HIGH)
            - case_summary (concise summary)
            - how_risk_analysis_calculated (explanation of risk calculation)
            - refund_eligibility (High, Medium, Low explanation)
            - suggested_steps (list of legal steps)
            - legal_document (A professional, auto-generated refund request letter or consumer court complaint based on the case type)
            
            Ensure the legal document is comprehensive and ready for submission.
            """
            try:
                res = ai_client.models.generate_content(model="gemini-2.5-flash", contents=prompt)
                txt = res.text.strip()
                if "```json" in txt: txt = txt.split("```json")[1].split("```")[0]
                analysis = json.loads(txt)
            except: pass

        case_id = _gen_case_id("CON")
        new_case = Case(
            case_id=case_id,
            email=email,
            type="Consumer Complaint",
            details={
                "case_type": case_type,
                "product_name": product_name,
                "seller_name": seller_name,
                "purchase_date": purchase_date,
                "amount_paid": amount_paid,
                "description": description,
                "uploaded_files": uploaded_files
            },
            analysis=analysis,
            status="Submitted",
            created_at=datetime.now()
        )
        db.session.add(new_case)
        db.session.commit()
        analysis["case_id"] = case_id
        return jsonify(analysis), 200
    except Exception as e:
        return jsonify({"error": str(e)}), 500

@app.route("/submit-student-issue", methods=["POST"])
def submit_student_issue():
    try:
        email = request.form.get("email")
        case_type = request.form.get("case_type")
        college_name = request.form.get("college_name")
        department = request.form.get("department")
        date_incident = request.form.get("date_incident")
        description = request.form.get("description")
        
        category_dir = os.path.join(app.config['UPLOAD_FOLDER'], 'student_issue')
        os.makedirs(category_dir, exist_ok=True)
        # File handling
        uploaded_files = {}
        extracted_text = ""
        for key in ["evidence", "receipts", "id_proof"]:
            if key in request.files:
                f = request.files[key]
                if f.filename != "":
                    path = os.path.join(category_dir, secure_filename(f.filename))
                    f.save(path)
                    uploaded_files[key] = path
                    if path.lower().endswith(".pdf"):
                        extracted_text += f"\n[File: {f.filename}, Type: {key}]\n" + _extract_text_from_pdf(path)

        analysis = {
            "risk_level": "LOW",
            "case_summary": "Student issue reported.",
            "how_risk_analysis_calculated": "Calculated based on severity of the incident and evidence provided.",
            "suggested_steps": ["Submit written complaint to Principal", "Contact education board"],
            "legal_document": "Draft of formal academic complaint..."
        }
        
        if ai_client:
            prompt = f"""
            Analyze this student legal issue:
            Case Type: {case_type}
            College: {college_name}
            Department: {department}
            Date of Incident: {date_incident}
            Description: {description}
            
            Extracted Text from Documents:
            {extracted_text}
            
            Respond in JSON format with keys: 
            - risk_level (LOW, MEDIUM, HIGH)
            - case_summary (concise summary)
            - how_risk_analysis_calculated (explanation of risk calculation)
            - suggested_steps (list of legal/escalation steps)
            - legal_document (A professional, auto-generated academic complaint or legal draft based on the case type)
            
            Ensure the legal document is comprehensive and tailored to the student's specific situation.
            """
            try:
                res = ai_client.models.generate_content(model="gemini-2.5-flash", contents=prompt)
                txt = res.text.strip()
                if "```json" in txt: txt = txt.split("```json")[1].split("```")[0]
                analysis = json.loads(txt)
            except: pass

        case_id = _gen_case_id("STU")
        new_case = Case(
            case_id=case_id,
            email=email,
            type="Student Issues",
            details={
                "case_type": case_type,
                "college_name": college_name,
                "department": department,
                "date_incident": date_incident,
                "description": description,
                "uploaded_files": uploaded_files
            },
            analysis=analysis,
            status="Submitted",
            created_at=datetime.now()
        )
        db.session.add(new_case)
        db.session.commit()
        analysis["case_id"] = case_id
        return jsonify(analysis), 200
    except Exception as e:
        return jsonify({"error": str(e)}), 500

@app.route("/submit-accident-claim", methods=["POST"])
def submit_accident_claim():
    try:
        email = request.form.get("email")
        case_type = request.form.get("case_type")
        vehicle_number = request.form.get("vehicle_number")
        location = request.form.get("location")
        date_time = request.form.get("date_time")
        description = request.form.get("description")
        
        category_dir = os.path.join(app.config['UPLOAD_FOLDER'], 'accident_claim')
        os.makedirs(category_dir, exist_ok=True)
        # File handling
        uploaded_files = {}
        extracted_text = ""
        for key in ["police_reports", "medical_reports", "insurance_policy", "accident_photos"]:
            if key in request.files:
                f = request.files[key]
                if f.filename != "":
                    path = os.path.join(category_dir, secure_filename(f.filename))
                    f.save(path)
                    uploaded_files[key] = path
                    if path.lower().endswith(".pdf"):
                        extracted_text += f"\n[File: {f.filename}, Type: {key}]\n" + _extract_text_from_pdf(path)

        analysis = {
            "risk_level": "LOW",
            "case_summary": "Accident claim reported.",
            "how_risk_analysis_calculated": "Calculated based on severity of the incident and evidence provided.",
            "damage_assessment": "Minor vehicle damage.",
            "compensation_estimate": "₹15,000 - ₹25,000",
            "suggested_steps": ["File FIR at nearest station", "Inform insurance provider"],
            "legal_document": "Draft of insurance claim application..."
        }
        
        if ai_client:
            prompt = f"""
            Analyze this vehicle accident claim:
            Case Type: {case_type}
            Vehicle Number: {vehicle_number}
            Location: {location}
            Date/Time: {date_time}
            Description: {description}
            
            Extracted Text from Documents:
            {extracted_text}
            
            Respond in JSON format with keys: 
            - risk_level (LOW, MEDIUM, HIGH)
            - case_summary (concise summary)
            - how_risk_analysis_calculated (explanation of risk calculation)
            - damage_assessment (detailed analysis of injuries/vehicle damage)
            - compensation_estimate (estimated range in INR based on standard laws)
            - suggested_steps (list of legal/insurance steps)
            - legal_document (A professional, auto-generated claim application or legal complaint based on the case type)
            
            Ensure the compensation estimate is realistic and the legal document is comprehensive.
            """
            try:
                res = ai_client.models.generate_content(model="gemini-2.5-flash", contents=prompt)
                txt = res.text.strip()
                if "```json" in txt: txt = txt.split("```json")[1].split("```")[0]
                analysis = json.loads(txt)
            except: pass

        case_id = _gen_case_id("ACC")
        new_case = Case(
            case_id=case_id,
            email=email,
            type="Accident Claim",
            details={
                "case_type": case_type,
                "vehicle_number": vehicle_number,
                "location": location,
                "date_time": date_time,
                "description": description,
                "uploaded_files": uploaded_files
            },
            analysis=analysis,
            status="Submitted",
            created_at=datetime.now()
        )
        db.session.add(new_case)
        db.session.commit()
        analysis["case_id"] = case_id
        return jsonify(analysis), 200
    except Exception as e:
        return jsonify({"error": str(e)}), 500



@app.route("/submit-dv-complaint", methods=["POST"])
def submit_dv_complaint():
    try:
        email = request.form.get("email")
        description = request.form.get("description")
        user = User.query.filter_by(email=email).first()
        user_name = user.name if user and user.name else "[Complainant Name]"
        user_phone = user.phone if user and user.phone else "[Phone Number]"
        latitude = request.form.get("latitude")
        longitude = request.form.get("longitude")
        
        location_context = ""
        if latitude and longitude and str(latitude).lower() != "null" and str(longitude).lower() != "null" and str(latitude).lower() != "none" and str(longitude).lower() != "none" and str(latitude).strip() != "" and str(longitude).strip() != "":
            location_context = f"The user is located at EXACT Coordinates: Latitude {latitude}, Longitude {longitude}. Please use your internal map knowledge to find ONE real police station exactly near these coordinates."

        category_dir = os.path.join(app.config['UPLOAD_FOLDER'], 'domestic_violence')
        os.makedirs(category_dir, exist_ok=True)
        # File handling
        uploaded_files = {}
        gemini_files = []
        for key in ["id_proof", "evidence", "medical"]:
            if key in request.files:
                f = request.files[key]
                if f.filename != "":
                    path = os.path.join(category_dir, secure_filename(f.filename))
                    f.save(path)
                    uploaded_files[key] = path
                    if ai_client:
                        try:
                            uploaded_f = ai_client.files.upload(file=path)
                            gemini_files.append(uploaded_f)
                        except Exception as e:
                            print(f"Error uploading to Gemini: {e}")

        files_uploaded_summary = ", ".join(uploaded_files.keys()) if uploaded_files else "No documents uploaded"
        desc_summary = description if description and description.strip() else "Incident report submitted by client."

        analysis = {
            "risk_level": "HIGH" if any(w in desc_summary.lower() for w in ["threat", "hit", "abuse", "danger", "beat", "weapon", "kill", "harm", "violence", "assault"]) else "MEDIUM",
            "risk_summary": "Safety assessment calculated from submitted incident details.",
            "case_summary": desc_summary,
            "how_risk_analysis_calculated": f"Calculated based on statement: '{desc_summary[:120]}' and evidence attached ({files_uploaded_summary}).",
            "missing_documents": ["Medical MLC Report" if "medical" not in uploaded_files else "Marriage Certificate", "Proof of Identity" if "id_proof" not in uploaded_files else "Witness Statement"],
            "legal_actions": [
                "File FIR under Section 85/86 of BNS, 2023 (Cruelty by Spouse/Relatives)",
                "Apply for Protection Order under Section 18 of PWDVA, 2005"
            ],
            "police_station_1": "Nearest Local Police Station (Station House Officer Office)",
            "suggested_lawyer": "Consult a local legal aid advocate / Family Court Counsel",
            "complaint_draft": f"To,\nThe Station House Officer (SHO),\n[Local Police Station]\n\nSubject: Formal Complaint regarding Domestic Violence under Section 85/86 of BNS, 2023.\n\nRespected Sir/Madam,\n\nI, {user_name}, wish to report an incident of domestic violence:\n\n{desc_summary}\n\nUploaded Files: {files_uploaded_summary}\n\nI request immediate legal intervention and protection.\n\nSincerely,\n{user_name}\nContact: {user_phone}",
            "id_verification_status": "Valid ID File Uploaded" if "id_proof" in uploaded_files else "Pending ID Verification"
        }
        
        safe_config = types.GenerateContentConfig(
            response_mime_type="application/json",
            safety_settings=[
                types.SafetySetting(category=types.HarmCategory.HARM_CATEGORY_DANGEROUS_CONTENT, threshold=types.HarmBlockThreshold.BLOCK_NONE),
                types.SafetySetting(category=types.HarmCategory.HARM_CATEGORY_HARASSMENT, threshold=types.HarmBlockThreshold.BLOCK_NONE),
                types.SafetySetting(category=types.HarmCategory.HARM_CATEGORY_HATE_SPEECH, threshold=types.HarmBlockThreshold.BLOCK_NONE),
                types.SafetySetting(category=types.HarmCategory.HARM_CATEGORY_SEXUALLY_EXPLICIT, threshold=types.HarmBlockThreshold.BLOCK_NONE)
            ]
        )
        
        def agent_id_verification(files, client):
            if not client or not files:
                return {"id_verification_status": "Valid ID File Uploaded" if "id_proof" in uploaded_files else "Unable to verify ID", "victim_name": user_name, "victim_id_number": user_phone}
            prompt = """
            TASK - ID VERIFICATION:
            Look at the attached image files. If an Aadhaar card is present, extract:
            - Full name from the card
            - 12-digit Aadhaar number (masked like XXXX XXXX 1234 is fine)
            - Set id_verification_status to "Valid Aadhaar Card Verified"
            If a PAN card is present, extract:
            - Full name
            - PAN number
            - Set id_verification_status to "Valid PAN Card Verified"
            If NO valid ID image is attached or it cannot be read, set id_verification_status to "Unable to verify ID - Please upload a clear image of Aadhaar or PAN card"
            
            Respond ONLY in valid JSON:
            {
              "id_verification_status": "...",
              "victim_name": "...",
              "victim_id_number": "..."
            }
            """
            try:
                res = client.models.generate_content(
                    model="gemini-2.5-flash",
                    contents=[prompt] + files,
                    config=safe_config
                )
                return json.loads(res.text.strip().replace("```json", "").replace("```", ""))
            except Exception as e:
                print(f"ID Agent Error: {e}")
                return {"id_verification_status": "Valid ID Attached" if "id_proof" in uploaded_files else "Pending ID Verification", "victim_name": user_name, "victim_id_number": user_phone}

        def agent_risk_analysis(desc, files, client):
            if not client: return {}
            prompt = f"""
            TASK - RISK ANALYSIS & DETAILED LEGAL ACTIONS:
            Analyze this domestic violence case description: "{desc}"
            Consider any evidence in the attached files (ID proof, photos, medical reports, chat transcripts, etc.).
            
            Please provide:
            1. Risk Level (HIGH, MEDIUM, or LOW) based on direct threats, physical violence, weapon involvement, children, etc.
            2. Risk Summary: A brief explanation of the risk level.
            3. Case Summary: 2-3 sentences summarizing the situation.
            4. How Risk Analysis is Calculated: Detail the specific factors (e.g. physical harm, weapon use, ongoing threat) from the user's description and evidence.
            5. Missing Documents: Identify documents that are missing but would support their case (e.g., medical certificates/MLC if physical injury is mentioned, marriage certificate, screenshots of messages/threats, witness statements).
            6. Legal Actions: Provide clear, correct, and actionable legal steps under Indian law, specific to the incident.
               - Cite appropriate legal provisions, such as Section 85/86 of BNS, 2023 (formerly Section 498A of IPC) for cruelty by husband/relatives.
               - Mention remedies under the Protection of Women from Domestic Violence Act (PWDVA), 2005 (e.g., Protection Orders under Section 18, Residence Orders under Section 19, Monetary Relief under Section 20, Custody Orders under Section 21).
               - Advise on filing an FIR (First Information Report) or a Zero FIR at the nearest police station.
               - Tailor the actions to the evidence. For instance, if digital evidence/chats are present, suggest filing certificate under Section 63 of Bharatiya Sakshya Adhiniyam (BSA), 2023. If physical injuries are described, suggest obtaining a Medical Legal Case (MLC) report from a government hospital.
            
            Respond ONLY in valid JSON:
            {{
              "risk_level": "HIGH or MEDIUM or LOW",
              "risk_summary": "short explanation",
              "case_summary": "2-3 sentence summary",
              "how_risk_analysis_calculated": "explanation of how the risk score was determined",
              "missing_documents": ["list", "of", "missing", "docs"],
              "legal_actions": ["list", "of", "clear, specific legal steps"]
            }}
            """
            try:
                res = client.models.generate_content(
                    model="gemini-2.5-flash",
                    contents=[prompt] + files,
                    config=safe_config
                )
                return json.loads(res.text.strip().replace("```json", "").replace("```", ""))
            except Exception as e:
                print(f"Risk Agent Error: {e}")
                return {}

        def agent_local_support(loc_ctx, desc, files, client):
            if not client: return {}
            prompt = f"""
            TASK - LOCAL SUPPORT & POLICE STATIONS:
            We need to find the user's location and name ONE real, verifiable police station closest to them.
            
            Here is the information we have:
            1. GPS Location Context: {loc_ctx if loc_ctx else "None"}
            2. User's Description of the incident: "{desc}"
            
            Please analyze:
            - The GPS coordinates (if provided above, prioritize them).
            - Any mention of city, area, neighbourhood, address, or landmark in the User's Description of the incident.
            - If no coordinates are available and no clear city is mentioned in the description, look at the uploaded files (like Aadhaar card or PAN card) to find the address, city, district, state, or PIN code of the user.
            
            Based on this, identify the exact location/city. Then, name ONE real, verifiable, existing police station closest to that location. You must provide the exact name and full address of the police station. Do not suggest mock or generic police stations.
            Also suggest a real domestic violence lawyer, legal aid cell (DLSA/SLSA), or family law organization in that city/region.
            
            Respond ONLY in valid JSON:
            {{
              "police_station_1": "Exact Police Station Name, Full Address",
              "suggested_lawyer": "Name, contact or organization"
            }}
            """
            try:
                res = client.models.generate_content(
                    model="gemini-2.5-flash",
                    contents=[prompt] + files,
                    config=safe_config
                )
                return json.loads(res.text.strip().replace("```json", "").replace("```", ""))
            except Exception as e:
                print(f"Support Agent Error: {e}")
                return {}

        def agent_legal_draft(desc, id_data, u_name, u_phone, client):
            if not client: return {}
            v_name = id_data.get("victim_name")
            if not v_name or v_name == "[Complainant Name]" or v_name == "Unknown" or not str(v_name).strip():
                v_name = u_name
            v_id = id_data.get("victim_id_number")
            if not v_id or v_id == "[ID Number]" or v_id == "Unknown" or not str(v_id).strip():
                v_id = u_phone
                
            prompt = f"""
            TASK - COMPLAINT DRAFT:
            Write a formal and legally correct First Information Report (FIR)/complaint letter for domestic violence under Indian law.
            
            Complainant Details:
            - Name: {v_name}
            - ID / Phone: {v_id}
            
            Incident Details:
            - Description: "{desc}"
            
            Legal Drafting Guidelines:
            - Address the complaint to the "Station House Officer" (SHO).
            - Cite the correct legal sections under the new Bharatiya Nyaya Sanhita (BNS), 2023 (which replaced the old IPC):
              - Section 85/86 of BNS (Cruelty by husband or relatives of husband).
              - Section 115 of BNS (Voluntarily causing hurt) if physical injuries or hitting is mentioned.
              - Section 127 of BNS (Wrongful confinement) if the victim describes being locked in a room or kept confined.
              - Section 351 of BNS (Criminal intimidation) if threats are described.
            - Ensure the complaint draft reads professionally, with a formal subject line, structured description of facts, and a request for immediate register of FIR and protection.
            
            Respond ONLY in valid JSON:
            {{
              "complaint_draft": "Full formal BNS-compliant complaint letter text."
            }}
            """
            try:
                res = client.models.generate_content(
                    model="gemini-2.5-flash",
                    contents=prompt,
                    config=types.GenerateContentConfig(response_mime_type="application/json")
                )
                return json.loads(res.text.strip().replace("```json", "").replace("```", ""))
            except Exception as e:
                print(f"Draft Agent Error: {e}")
                return {}

        if ai_client:
            with concurrent.futures.ThreadPoolExecutor(max_workers=3) as executor:
                future_id = executor.submit(agent_id_verification, gemini_files, ai_client)
                future_risk = executor.submit(agent_risk_analysis, description, gemini_files, ai_client)
                future_support = executor.submit(agent_local_support, location_context, description, gemini_files, ai_client)
                
                id_data = future_id.result()
                risk_data = future_risk.result()
                support_data = future_support.result()
                
            draft_data = agent_legal_draft(description, id_data, user_name, user_phone, ai_client)
            
            # Merge agent outputs
            if id_data: analysis.update(id_data)
            if risk_data: analysis.update(risk_data)
            if support_data: analysis.update(support_data)
            if draft_data: analysis.update(draft_data)


        case_id = _gen_case_id("DV")
        new_case = Case(
            case_id=case_id,
            email=email,
            type="Domestic Violence",
            details={
                "description": description,
                "uploaded_files": uploaded_files
            },
            analysis=analysis,
            status="Submitted",
            created_at=datetime.now()
        )
        db.session.add(new_case)
        db.session.commit()
        analysis["case_id"] = case_id
        return jsonify(analysis), 200
    except Exception as e:
        return jsonify({"error": str(e)}), 500

@app.route("/submit-generic-case", methods=["POST"])
def submit_generic_case():
    try:
        email = request.form.get("email")
        category = request.form.get("category", "General")
        description = request.form.get("description", "No description provided")
        
        analysis = {
            "risk_level": "MEDIUM",
            "case_summary": f"General report regarding {category}.",
            "how_risk_analysis_calculated": "Calculated based on severity of the incident and evidence provided.",
            "legal_actions": ["Consult a specialized attorney", "Gather more evidence"],
            "complaint_draft": f"Formal report for {category}..."
        }
        
        if ai_client:
            prompt = f"Analyze this legal report for {category}: {description}. Provide risk_level, how_risk_analysis_calculated (explanation of risk calculation), risk_summary, case_summary, legal_actions, and a formal complaint_draft in JSON."
            try:
                res = ai_client.models.generate_content(model="gemini-2.5-flash", contents=prompt)
                txt = res.text.strip()
                if "```json" in txt: txt = txt.split("```json")[1].split("```")[0]
                analysis = json.loads(txt)
            except: pass

        case_id = _gen_case_id(category[:2].upper())
        new_case = Case(
            case_id=case_id,
            email=email,
            type=category,
            details={"description": description},
            analysis=analysis,
            status="Submitted",
            created_at=datetime.now()
        )
        db.session.add(new_case)
        db.session.commit()
        analysis["case_id"] = case_id
        return jsonify(analysis), 200
    except Exception as e:
        return jsonify({"error": str(e)}), 500

@app.route("/get-my-cases", methods=["GET"])
def get_my_cases():
    try:
        email = request.args.get("email")
        if not email:
            return jsonify({"message": "Email required"}), 400
        
        all_cases = []
        cases = Case.query.filter_by(email=email).all()
        for c in cases:
            case_dict = {
                "case_id": c.case_id,
                "type": c.type,
                "email": c.email,
                "details": c.details,
                "analysis": c.analysis,
                "status": c.status,
                "created_at": c.created_at.isoformat() if c.created_at else None
            }
            all_cases.append(case_dict)
            
        return jsonify(all_cases), 200
    except Exception as e:
        return jsonify({"error": str(e)}), 500

@app.route("/admin/users", methods=["GET"])
def admin_users():
    try:
        users = User.query.all()
        return jsonify([
            {
                "id": u.id,
                "email": u.email,
                "name": u.name or u.email.split("@")[0].capitalize(),
                "phone": u.phone or "",
                "role": u.role
            }
            for u in users
        ]), 200
    except Exception as e:
        return jsonify({"error": str(e)}), 500

@app.route("/admin/all-cases", methods=["GET"])
def admin_all_cases():
    try:
        cases = Case.query.order_by(Case.created_at.desc()).all()
        all_cases = []
        for c in cases:
            details = c.details or {}
            if "uploaded_files" in details and isinstance(details["uploaded_files"], dict):
                sanitized = {}
                for k, v in details["uploaded_files"].items():
                    if v:
                        rel_path = os.path.relpath(v, app.config['UPLOAD_FOLDER']).replace('\\', '/')
                        sanitized[k] = rel_path
                    else:
                        sanitized[k] = ""
                details = {**details, "uploaded_files": sanitized}
            
            all_cases.append({
                "case_id": c.case_id,
                "type": c.type,
                "email": c.email,
                "details": details,
                "analysis": c.analysis or {},
                "status": c.status,
                "assigned_lawyer": c.assigned_lawyer,
                "assigned_police": c.assigned_police,
                "handling_status": c.handling_status,
                "created_at": c.created_at.isoformat() if c.created_at else None
            })
        return jsonify(all_cases), 200
    except Exception as e:
        return jsonify({"error": str(e)}), 500

@app.route("/admin/delete-user", methods=["POST"])
def admin_delete_user():
    try:
        data = request.get_json()
        email = data.get("email")
        if not email:
            return jsonify({"message": "Email is required"}), 400
        
        user = User.query.filter_by(email=email).first()
        if not user:
            return jsonify({"message": "User not found"}), 404
            
        db.session.delete(user)
        db.session.commit()
        return jsonify({"message": "User deleted successfully"}), 200
    except Exception as e:
        return jsonify({"message": str(e)}), 500

@app.route("/admin/delete-case", methods=["POST", "DELETE"])
def admin_delete_case():
    try:
        data = request.get_json(silent=True) or {}
        case_id = data.get("case_id") or request.args.get("case_id")
        if not case_id:
            return jsonify({"message": "case_id is required"}), 400
        
        c = Case.query.filter_by(case_id=case_id).first()
        if not c:
            return jsonify({"message": "Case not found"}), 404
        
        # Clean up related records in sub-models
        CaseSummary.query.filter_by(case_id=case_id).delete()
        Evidence.query.filter_by(case_id=case_id).delete()
        ArgumentNote.query.filter_by(case_id=case_id).delete()
        HearingTask.query.filter_by(case_id=case_id).delete()
        Hearing.query.filter_by(case_id=case_id).delete()
        Notification.query.filter_by(case_id=case_id).delete()
        
        db.session.delete(c)
        db.session.commit()
        return jsonify({"message": f"Case {case_id} deleted successfully", "case_id": case_id}), 200
    except Exception as e:
        db.session.rollback()
        return jsonify({"message": str(e)}), 500



# ─── LEGAL RESEARCH & GNEWS MODULE ──────────────────────────────────────────

_gnews_cache = {}
CACHE_TTL_SECONDS = 900  # 15 mins cache

def _categorize_legal_article(title: str, desc: str) -> str:
    text = f"{title or ''} {desc or ''}".lower()
    if any(k in text for k in ["supreme court", "sc bench", "cji", "sc order", "sc ruling", "apex court"]):
        return "Supreme Court"
    if any(k in text for k in ["high court", "hc bench", "hc order", "hc ruling"]):
        return "High Court"
    if any(k in text for k in ["cyber", "it act", "online fraud", "data privacy", "hacking", "phishing", "deepfake"]):
        return "Cyber Law"
    if any(k in text for k in ["criminal", "bns", "ipc", "police", "murder", "bail", "fir", "crime", "arrest", "accused", "prosecution", "bnss"]):
        return "Criminal"
    if any(k in text for k in ["constitution", "constitutional", "article 21", "fundamental right", "bench"]):
        return "Constitutional"
    if any(k in text for k in ["corporate", "sebi", "tax", "gst", "company", "merger", "bankruptcy", "ibc", "insolvency"]):
        return "Corporate"
    if any(k in text for k in ["civil", "property", "tenant", "land", "contract", "divorce", "family court", "custody"]):
        return "Civil"
    return "Supreme Court" if "court" in text else "Criminal" if "police" in text else "All"

def _fetch_gnews_articles(query_str: str):
    api_key = os.getenv("GNEWS_API_KEY")
    if not api_key:
        print("❌ GNEWS_API_KEY is not set in backend/.env")
        return jsonify({"error": "GNews API Key missing in backend environment"}), 500

    now = datetime.now()
    cache_key = query_str.strip().lower()
    if cache_key in _gnews_cache:
        cached_time, cached_data = _gnews_cache[cache_key]
        if (now - cached_time).total_seconds() < CACHE_TTL_SECONDS:
            return jsonify(cached_data), 200

    try:
        import urllib.request
        import urllib.parse

        encoded_q = urllib.parse.quote(query_str)
        url = f"https://gnews.io/api/v4/search?q={encoded_q}&lang=en&country=in&max=20&apikey={api_key.strip()}"
        req = urllib.request.Request(url, headers={'User-Agent': 'Mozilla/5.0'})
        
        with urllib.request.urlopen(req, timeout=10) as response:
            if response.status != 200:
                print(f"❌ GNews API returned HTTP status {response.status}")
                return jsonify({"error": f"GNews API HTTP error {response.status}"}), 502

            raw = json.loads(response.read().decode('utf-8'))
            articles = raw.get("articles", [])
            normalized = []
            for art in articles:
                t = art.get("title", "Legal Update")
                d = art.get("description", "")
                c = art.get("content", d)
                cat = _categorize_legal_article(t, d)
                normalized.append({
                    "title": t,
                    "description": d,
                    "content": c,
                    "image": art.get("image", ""),
                    "url": art.get("url", ""),
                    "publishedAt": art.get("publishedAt", ""),
                    "source": art.get("source", {}).get("name", "Indian Legal News"),
                    "category": cat
                })

            _gnews_cache[cache_key] = (now, normalized)
            return jsonify(normalized), 200
    except Exception as e:
        print(f"❌ GNews API Exception: {e}")
        return jsonify({"error": f"Failed to fetch legal updates: {str(e)}"}), 500


@app.route("/api/legal-updates", methods=["GET"])
def get_legal_updates():
    default_query = "Supreme Court OR High Court OR Indian law OR legal judgments"
    return _fetch_gnews_articles(default_query)


@app.route("/api/legal-search", methods=["GET"])
def search_legal_updates():
    q = request.args.get("q", "").strip()
    if not q:
        return get_legal_updates()
    
    # Sanitize query
    sanitized_q = f'"{q}" OR ({q} law India)'
    return _fetch_gnews_articles(sanitized_q)


@app.route("/api/legal-research/analyse", methods=["POST"])
def analyse_legal_article():
    try:
        data = request.get_json(force=True)
        title = data.get("title", "")
        desc = data.get("description", "")
        content = data.get("content", "")
        category = data.get("category", "General")

        disclaimer = "AI-generated legal analysis. Verify with the original legal source before relying on it."

        if not ai_client:
            return jsonify({
                "summary": desc or title,
                "key_legal_issue": "Analysis unavailable (AI API Key not configured).",
                "relevant_acts_sections": "Verify from original source article.",
                "court_authority": category,
                "important_legal_principles": "Information unavailable in article text.",
                "potential_impact": "Verify with official legal precedents.",
                "key_takeaways": "Read full judgment/article for detailed findings.",
                "disclaimer": disclaimer
            }), 200

        prompt = f"""
        Act as an expert Indian Legal Analyst.
        Analyze the following Indian legal article/news update:
        Title: {title}
        Category: {category}
        Description: {desc}
        Content snippet: {content}

        Provide a structured, accurate summary without fabricating any facts, citations, court names, or sections if they are missing in the article text. If a detail is missing, explicitly state "Information unavailable in article text".

        Return ONLY a JSON object with the following keys:
        - "summary": string (2-3 concise sentences)
        - "key_legal_issue": string (primary question of law or controversy)
        - "relevant_acts_sections": string (Acts, IPC/BNS sections mentioned or relevant)
        - "court_authority": string (Court or authority involved, e.g. Supreme Court of India)
        - "important_legal_principles": string (Key ratio decidendi or legal principle discussed)
        - "potential_impact": string (Impact on legal practice or public policy)
        - "key_takeaways": string (2 key takeaways for lawyers)
        """

        response = ai_client.models.generate_content(
            model='gemini-2.5-flash',
            contents=prompt,
            config=types.GenerateContentConfig(
                response_mime_type="application/json",
                temperature=0.2,
            ),
        )

        analysis = json.loads(response.text)
        analysis["disclaimer"] = disclaimer
        return jsonify(analysis), 200
    except Exception as e:
        print(f"❌ AI Legal Analysis Error: {e}")
        return jsonify({
            "summary": data.get("description", "Legal update summary"),
            "key_legal_issue": "General legal development.",
            "relevant_acts_sections": "Refer to official publication.",
            "court_authority": data.get("category", "Indian Judiciary"),
            "important_legal_principles": "Refer to judgment text.",
            "potential_impact": "Impact under legal review.",
            "key_takeaways": "Verify details from official source.",
            "disclaimer": "AI-generated legal analysis. Verify with the original legal source before relying on it."
        }), 200


@app.route("/api/legal-research/save", methods=["POST"])
def save_legal_research():
    try:
        data = request.get_json(force=True)
        user_email = data.get("email")
        title = data.get("title")
        source_url = data.get("url") or data.get("source_url")

        if not user_email or not title or not source_url:
            return jsonify({"message": "email, title and source_url required"}), 400

        # Prevent duplicate saves
        existing = SavedResearch.query.filter_by(user_email=user_email, source_url=source_url).first()
        if existing:
            return jsonify({"message": "Article already saved in your library"}), 200

        item = SavedResearch(
            user_email=user_email,
            title=title,
            description=data.get("description", ""),
            source_name=data.get("source") or data.get("source_name", "Legal News"),
            source_url=source_url,
            image_url=data.get("image") or data.get("image_url", ""),
            category=data.get("category", "All"),
            published_at=data.get("publishedAt") or data.get("published_at", "")
        )
        db.session.add(item)
        db.session.commit()
        return jsonify({"message": "Article saved successfully", "id": item.id}), 201
    except Exception as e:
        db.session.rollback()
        return jsonify({"message": f"Error saving article: {str(e)}"}), 500


@app.route("/api/legal-research/saved", methods=["GET"])
def get_saved_legal_research():
    try:
        email = request.args.get("email")
        if not email:
            return jsonify({"message": "Email is required"}), 400

        items = SavedResearch.query.filter_by(user_email=email).order_by(SavedResearch.saved_at.desc()).all()
        result = []
        for i in items:
            result.append({
                "id": i.id,
                "title": i.title,
                "description": i.description,
                "source": i.source_name,
                "url": i.source_url,
                "image": i.image_url,
                "category": i.category,
                "publishedAt": i.published_at,
                "savedAt": i.saved_at.isoformat() if i.saved_at else None
            })
        return jsonify(result), 200
    except Exception as e:
        return jsonify({"message": str(e)}), 500


@app.route("/api/legal-research/saved/<int:item_id>", methods=["DELETE"])
def delete_saved_legal_research(item_id):
    try:
        email = request.args.get("email") or (request.get_json(silent=True) or {}).get("email")
        item = SavedResearch.query.get(item_id)
        if not item:
            return jsonify({"message": "Saved item not found"}), 404

        if email and item.user_email != email:
            return jsonify({"message": "Unauthorized access to saved item"}), 403

        db.session.delete(item)
        db.session.commit()
        return jsonify({"message": "Saved article removed successfully"}), 200
    except Exception as e:
        db.session.rollback()
        return jsonify({"message": str(e)}), 500



# ─── COURT PREPARATION APIS ──────────────────────────────────────────────────

# 1. CASE SUMMARY APIS
@app.route("/api/cases/<case_id>/summary", methods=["GET"])
def get_case_summary(case_id):
    try:
        case = Case.query.filter_by(case_id=str(case_id)).first()
        summary = CaseSummary.query.filter_by(case_id=str(case_id)).first()
        
        details = case.details if case and case.details else {}
        analysis = case.analysis if case and case.analysis else {}
        
        client_name = details.get("incident_details", {}).get("user_name") or (case.email if case else "Client User")
        
        data = {
            "case_id": case_id,
            "title": summary.title if summary and summary.title else (f"{case.type} Case" if case else "Legal Case"),
            "court": summary.court if summary and summary.court else analysis.get("court_authority", "City Civil & District Court"),
            "judge": summary.judge if summary and summary.judge else "Hon'ble Presiding Judge",
            "client_details": summary.client_details if summary and summary.client_details else f"Name: {client_name}\nEmail: {case.email if case else 'N/A'}",
            "opponent_details": summary.opponent_details if summary and summary.opponent_details else details.get("incident_details", {}).get("perpetrator", "Opposing Party / Respondent"),
            "case_status": summary.case_status if summary and summary.case_status else (case.status if case else "Active"),
            "case_facts": summary.case_facts if summary and summary.case_facts else details.get("incident_details", {}).get("description", "Case facts and evidence summary under review."),
            "ai_summary": summary.ai_summary if summary and summary.ai_summary else analysis.get("legal_summary", "AI Analysis: Prima facie case established under applicable Bharatiya Nyaya Sanhita (BNS) provisions."),
            "previous_hearings": summary.previous_hearings if summary and summary.previous_hearings else [
                {"date": "2026-07-15", "purpose": "First Motion & Admission", "status": "Adjourned"},
                {"date": "2026-07-22", "purpose": "Notice Return & Reply", "status": "Completed"}
            ],
            "timeline": summary.timeline if summary and summary.timeline else [
                {"date": "2026-07-01", "event": "FIR Filed"},
                {"date": "2026-07-05", "event": "Advocate Retained"},
                {"date": "2026-07-15", "event": "Preliminary Hearing"}
            ],
            "important_dates": summary.important_dates if summary and summary.important_dates else [
                {"event": "Next Hearing Date", "date": "2026-08-05"},
                {"event": "Rejoinder Filing Deadline", "date": "2026-08-01"}
            ],
            "updated_at": summary.updated_at.isoformat() if summary and summary.updated_at else None
        }
        return jsonify(data), 200
    except Exception as e:
        return jsonify({"message": str(e)}), 500

@app.route("/api/cases/<case_id>/summary", methods=["PUT"])
def update_case_summary(case_id):
    try:
        data = request.get_json(force=True) or {}
        summary = CaseSummary.query.filter_by(case_id=str(case_id)).first()
        if not summary:
            summary = CaseSummary(case_id=str(case_id))
            db.session.add(summary)
            
        if "title" in data: summary.title = data["title"]
        if "court" in data: summary.court = data["court"]
        if "judge" in data: summary.judge = data["judge"]
        if "client_details" in data: summary.client_details = data["client_details"]
        if "opponent_details" in data: summary.opponent_details = data["opponent_details"]
        if "case_status" in data: summary.case_status = data["case_status"]
        if "case_facts" in data: summary.case_facts = data["case_facts"]
        if "ai_summary" in data: summary.ai_summary = data["ai_summary"]
        if "previous_hearings" in data: summary.previous_hearings = data["previous_hearings"]
        if "timeline" in data: summary.timeline = data["timeline"]
        if "important_dates" in data: summary.important_dates = data["important_dates"]
        
        db.session.add(ActivityLog(user_email=data.get("email", "lawyer@gmail.com"), action="Updated Case Summary", details=f"Case ID: {case_id}"))
        db.session.commit()
        return jsonify({"message": "Case summary updated successfully"}), 200
    except Exception as e:
        db.session.rollback()
        return jsonify({"message": str(e)}), 500


# 2. EVIDENCE BUNDLE APIS
@app.route("/api/evidence/upload", methods=["POST"])
def upload_evidence():
    try:
        case_id = request.form.get("case_id") or request.args.get("case_id")
        category = request.form.get("category", "General")
        uploaded_by = request.form.get("uploaded_by", "lawyer@gmail.com")
        
        if not case_id:
            return jsonify({"message": "Missing case_id"}), 400
            
        if "file" not in request.files:
            return jsonify({"message": "No file attached"}), 400
            
        file = request.files["file"]
        if file.filename == "":
            return jsonify({"message": "Empty file name"}), 400
            
        filename = secure_filename(file.filename)
        ext = filename.rsplit('.', 1)[-1].lower() if '.' in filename else ''
        
        evidence_dir = os.path.join(app.config['UPLOAD_FOLDER'], 'evidence', str(case_id))
        os.makedirs(evidence_dir, exist_ok=True)
        
        save_path = os.path.join(evidence_dir, filename)
        file.save(save_path)
        
        ev = Evidence(
            case_id=str(case_id),
            file_name=filename,
            file_path=os.path.relpath(save_path, app.config['UPLOAD_FOLDER']).replace('\\', '/'),
            file_type=ext,
            category=category,
            uploaded_by=uploaded_by,
            status="Uploaded"
        )
        db.session.add(ev)
        db.session.add(ActivityLog(user_email=uploaded_by, action="Uploaded Evidence", details=f"File: {filename} for Case: {case_id}"))
        db.session.commit()
        
        return jsonify({
            "message": "Evidence uploaded successfully",
            "evidence": {
                "id": ev.id,
                "case_id": ev.case_id,
                "file_name": ev.file_name,
                "file_path": ev.file_path,
                "file_type": ev.file_type,
                "category": ev.category,
                "status": ev.status,
                "uploaded_by": ev.uploaded_by,
                "uploaded_at": ev.uploaded_at.isoformat()
            }
        }), 201
    except Exception as e:
        db.session.rollback()
        return jsonify({"message": str(e)}), 500

@app.route("/api/evidence/<case_id>", methods=["GET"])
def get_evidence(case_id):
    try:
        items = Evidence.query.filter_by(case_id=str(case_id)).order_by(Evidence.uploaded_at.desc()).all()
        result = []
        for item in items:
            result.append({
                "id": item.id,
                "case_id": item.case_id,
                "file_name": item.file_name,
                "file_path": item.file_path,
                "file_type": item.file_type,
                "category": item.category,
                "status": item.status,
                "uploaded_by": item.uploaded_by,
                "uploaded_at": item.uploaded_at.isoformat()
            })
        return jsonify(result), 200
    except Exception as e:
        return jsonify({"message": str(e)}), 500

@app.route("/api/evidence/<int:id>", methods=["DELETE"])
def delete_evidence(id):
    try:
        ev = Evidence.query.get(id)
        if not ev:
            return jsonify({"message": "Evidence not found"}), 404
            
        full_path = os.path.join(app.config['UPLOAD_FOLDER'], ev.file_path)
        if os.path.exists(full_path):
            try:
                os.remove(full_path)
            except Exception:
                pass
                
        db.session.delete(ev)
        db.session.commit()
        return jsonify({"message": "Evidence deleted successfully"}), 200
    except Exception as e:
        db.session.rollback()
        return jsonify({"message": str(e)}), 500

@app.route("/uploads/evidence/<path:filename>", methods=["GET"])
def serve_evidence_file(filename):
    return send_from_directory(os.path.join(app.config['UPLOAD_FOLDER'], 'evidence'), filename)


# 3. ARGUMENT NOTES APIS
@app.route("/api/arguments/<case_id>", methods=["GET"])
def get_arguments(case_id):
    try:
        notes = ArgumentNote.query.filter_by(case_id=str(case_id)).order_by(ArgumentNote.is_pinned.desc(), ArgumentNote.updated_at.desc()).all()
        result = []
        for n in notes:
            result.append({
                "id": n.id,
                "case_id": n.case_id,
                "lawyer_email": n.lawyer_email,
                "title": n.title,
                "is_pinned": n.is_pinned,
                "opening_statement": n.opening_statement or "",
                "facts": n.facts or "",
                "legal_issues": n.legal_issues or "",
                "arguments": n.arguments or "",
                "counter_arguments": n.counter_arguments or "",
                "case_laws": n.case_laws or "",
                "acts_sections": n.acts_sections or "",
                "closing_statement": n.closing_statement or "",
                "content": n.content or "",
                "created_at": n.created_at.isoformat(),
                "updated_at": n.updated_at.isoformat()
            })
        return jsonify(result), 200
    except Exception as e:
        return jsonify({"message": str(e)}), 500

@app.route("/api/arguments", methods=["POST"])
def create_argument():
    try:
        data = request.get_json(force=True) or {}
        case_id = data.get("case_id")
        lawyer_email = data.get("lawyer_email", "lawyer@gmail.com")
        
        if not case_id:
            return jsonify({"message": "Missing case_id"}), 400
            
        note = ArgumentNote(
            case_id=str(case_id),
            lawyer_email=lawyer_email,
            title=data.get("title", "Court Hearing Argument"),
            is_pinned=data.get("is_pinned", False),
            opening_statement=data.get("opening_statement", ""),
            facts=data.get("facts", ""),
            legal_issues=data.get("legal_issues", ""),
            arguments=data.get("arguments", ""),
            counter_arguments=data.get("counter_arguments", ""),
            case_laws=data.get("case_laws", ""),
            acts_sections=data.get("acts_sections", ""),
            closing_statement=data.get("closing_statement", ""),
            content=data.get("content", "")
        )
        db.session.add(note)
        db.session.commit()
        return jsonify({"message": "Argument note created successfully", "id": note.id}), 201
    except Exception as e:
        db.session.rollback()
        return jsonify({"message": str(e)}), 500

@app.route("/api/arguments/<int:id>", methods=["PUT"])
def update_argument(id):
    try:
        data = request.get_json(force=True) or {}
        note = ArgumentNote.query.get(id)
        if not note:
            return jsonify({"message": "Argument note not found"}), 404
            
        if "title" in data: note.title = data["title"]
        if "is_pinned" in data: note.is_pinned = data["is_pinned"]
        if "opening_statement" in data: note.opening_statement = data["opening_statement"]
        if "facts" in data: note.facts = data["facts"]
        if "legal_issues" in data: note.legal_issues = data["legal_issues"]
        if "arguments" in data: note.arguments = data["arguments"]
        if "counter_arguments" in data: note.counter_arguments = data["counter_arguments"]
        if "case_laws" in data: note.case_laws = data["case_laws"]
        if "acts_sections" in data: note.acts_sections = data["acts_sections"]
        if "closing_statement" in data: note.closing_statement = data["closing_statement"]
        if "content" in data: note.content = data["content"]
        
        note.updated_at = datetime.now()
        db.session.commit()
        return jsonify({"message": "Argument note updated successfully"}), 200
    except Exception as e:
        db.session.rollback()
        return jsonify({"message": str(e)}), 500

@app.route("/api/arguments/<int:id>", methods=["DELETE"])
def delete_argument(id):
    try:
        note = ArgumentNote.query.get(id)
        if not note:
            return jsonify({"message": "Argument note not found"}), 404
            
        db.session.delete(note)
        db.session.commit()
        return jsonify({"message": "Argument note deleted successfully"}), 200
    except Exception as e:
        db.session.rollback()
        return jsonify({"message": str(e)}), 500


# 4. HEARING CHECKLIST APIS
@app.route("/api/hearings/<case_id>", methods=["GET"])
def get_hearings_and_tasks(case_id):
    try:
        case = Case.query.filter_by(case_id=str(case_id)).first()
        summary = CaseSummary.query.filter_by(case_id=str(case_id)).first()
        hearing = Hearing.query.filter_by(case_id=str(case_id)).order_by(Hearing.created_at.desc()).first()
        
        hearing_info = {
            "id": hearing.id if hearing else 0,
            "case_id": case_id,
            "court": hearing.court if hearing else (summary.court if summary else "High Court Bench"),
            "judge": hearing.judge if hearing else (summary.judge if summary else "Hon'ble Presiding Judge"),
            "hearing_date": hearing.hearing_date if hearing else "2026-08-05",
            "hearing_time": hearing.hearing_time if hearing else "10:30 AM",
            "purpose": hearing.purpose if hearing else "Framing of Issues & Arguments",
            "status": hearing.status if hearing else "Scheduled"
        }
        
        tasks = HearingTask.query.filter_by(case_id=str(case_id)).order_by(HearingTask.created_at.asc()).all()
        
        if not tasks:
            default_template = [
                ("Verify Victim & Witness Affidavits", "witness", False, "2026-08-03"),
                ("Prepare BNS Statutory Citation Notes", "task", False, "2026-08-04"),
                ("Carry Certified Copy of FIR & Medical Records", "document", False, "2026-08-04"),
                ("Check Physical Evidence Bundle Formatting", "evidence", False, "2026-08-04")
            ]
            for tname, tcat, tcomp, tdue in default_template:
                ht = HearingTask(case_id=str(case_id), task_name=tname, category=tcat, is_completed=tcomp, due_date=tdue)
                db.session.add(ht)
            db.session.commit()
            tasks = HearingTask.query.filter_by(case_id=str(case_id)).order_by(HearingTask.created_at.asc()).all()
            
        task_list = []
        for t in tasks:
            task_list.append({
                "id": t.id,
                "case_id": t.case_id,
                "hearing_id": t.hearing_id,
                "task_name": t.task_name,
                "category": t.category,
                "is_completed": t.is_completed,
                "due_date": t.due_date,
                "created_at": t.created_at.isoformat()
            })
            
        return jsonify({
            "hearing": hearing_info,
            "tasks": task_list
        }), 200
    except Exception as e:
        return jsonify({"message": str(e)}), 500

@app.route("/api/hearings/task", methods=["POST"])
def add_hearing_task():
    try:
        data = request.get_json(force=True) or {}
        case_id = data.get("case_id")
        task_name = data.get("task_name")
        
        if not case_id or not task_name:
            return jsonify({"message": "Missing required task fields"}), 400
            
        task = HearingTask(
            case_id=str(case_id),
            hearing_id=data.get("hearing_id"),
            task_name=task_name,
            category=data.get("category", "task"),
            is_completed=data.get("is_completed", False),
            due_date=data.get("due_date", "")
        )
        db.session.add(task)
        db.session.commit()
        return jsonify({"message": "Checklist task added successfully", "id": task.id}), 201
    except Exception as e:
        db.session.rollback()
        return jsonify({"message": str(e)}), 500

@app.route("/api/hearings/task/<int:id>", methods=["PUT"])
def update_hearing_task(id):
    try:
        data = request.get_json(force=True) or {}
        task = HearingTask.query.get(id)
        if not task:
            return jsonify({"message": "Task not found"}), 404
            
        if "is_completed" in data: task.is_completed = data["is_completed"]
        if "task_name" in data: task.task_name = data["task_name"]
        if "category" in data: task.category = data["category"]
        if "due_date" in data: task.due_date = data["due_date"]
        
        db.session.commit()
        return jsonify({"message": "Task updated successfully"}), 200
    except Exception as e:
        db.session.rollback()
        return jsonify({"message": str(e)}), 500

@app.route("/api/hearings/task/<int:id>", methods=["DELETE"])
def delete_hearing_task(id):
    try:
        task = HearingTask.query.get(id)
        if not task:
            return jsonify({"message": "Task not found"}), 404
            
        db.session.delete(task)
        db.session.commit()
        return jsonify({"message": "Task deleted successfully"}), 200
    except Exception as e:
        db.session.rollback()
        return jsonify({"message": str(e)}), 500

@app.route("/api/admin/verify-evidence", methods=["POST"])
def admin_verify_evidence():
    try:
        data = request.get_json(force=True) or {}
        id = data.get("id")
        status = data.get("status", "Verified")
        ev = Evidence.query.get(id)
        if not ev:
            return jsonify({"message": "Evidence item not found"}), 404
            
        ev.status = status
        db.session.add(ActivityLog(user_email="admin@gmail.com", action=f"Evidence {status}", details=f"Evidence ID: {id}"))
        db.session.commit()
        return jsonify({"message": f"Evidence marked as {status}"}), 200
    except Exception as e:
        db.session.rollback()
        return jsonify({"message": str(e)}), 500

@app.route("/api/admin/activity-logs", methods=["GET"])
def admin_activity_logs():
    try:
        logs = ActivityLog.query.order_by(ActivityLog.timestamp.desc()).limit(50).all()
        return jsonify([{
            "id": l.id,
            "user_email": l.user_email,
            "action": l.action,
            "details": l.details,
            "timestamp": l.timestamp.isoformat()
        } for l in logs]), 200
    except Exception as e:
        return jsonify({"message": str(e)}), 500


if __name__ == "__main__":
    app.run(host="0.0.0.0", port=port, debug=True, use_reloader=False)