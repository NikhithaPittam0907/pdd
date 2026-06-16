import os
import json
import random
import string
from datetime import datetime, timedelta
import smtplib
from email.mime.text import MIMEText
import concurrent.futures
from flask import Flask, request, jsonify
from flask_cors import CORS
from pymongo.mongo_client import MongoClient
from pymongo.server_api import ServerApi
from werkzeug.utils import secure_filename
from werkzeug.security import generate_password_hash, check_password_hash
from dotenv import load_dotenv
import PyPDF2
from docx import Document

# New official Gemini SDK
from google import genai
from google.genai import types

load_dotenv()

app = Flask(__name__)
CORS(app)

# Configuration
UPLOAD_FOLDER = 'uploads'
if not os.path.exists(UPLOAD_FOLDER):
    os.makedirs(UPLOAD_FOLDER)
app.config['UPLOAD_FOLDER'] = UPLOAD_FOLDER

# DB Config
MONGO_URI = os.getenv("MONGO_URI")
DB_NAME = os.getenv("DB_NAME")
collection_name = os.getenv("COLLECTION_NAME", "users")
port = int(os.getenv("PORT", 5000))

client = MongoClient(MONGO_URI, server_api=ServerApi('1'))
db = client[DB_NAME]
users = db[collection_name]

# AI Config
gemini_api_key = os.getenv("GEMINI_API_KEY")
ai_client = genai.Client(api_key=gemini_api_key) if gemini_api_key and gemini_api_key != "YOUR_API_KEY_HERE" else None

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

@app.route("/signup", methods=["POST"])
def signup():
    data = request.get_json()
    email = data.get("email")
    password = data.get("password")
    if not email or not password:
        return jsonify({"message": "Email and password required"}), 400
    if users.find_one({"email": email}):
        return jsonify({"message": "User already exists"}), 400
    data["password"] = generate_password_hash(password)
    users.insert_one(data)
    return jsonify({"message": "Signup successful"}), 201

@app.route("/login", methods=["POST"])
def login():
    data = request.get_json()
    user = users.find_one({"email": data.get("email")})
    if user and check_password_hash(user["password"], data.get("password")):
        user.pop("_id")
        user.pop("password")
        return jsonify({"message": "Login successful", **user}), 200
    return jsonify({"message": "Invalid credentials"}), 401

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

    user = users.find_one({"email": email})
    if not user:
        return jsonify({"message": "User not found"}), 404

    otp = ''.join(random.choices(string.digits, k=6))
    expires_at = datetime.now() + timedelta(minutes=10)
    
    db.otps.update_one(
        {"email": email},
        {"$set": {"otp": otp, "expires_at": expires_at}},
        upsert=True
    )

    send_otp_email(email, otp)
    return jsonify({"message": "OTP sent to email successfully"}), 200

@app.route("/reset-password", methods=["POST"])
def reset_password():
    data = request.get_json()
    email = data.get("email")
    otp = data.get("otp")
    new_password = data.get("password")

    if not email or not otp or not new_password:
        return jsonify({"message": "Missing required fields"}), 400

    record = db.otps.find_one({"email": email})
    if not record:
        return jsonify({"message": "No OTP requested for this email"}), 400

    if record["otp"] != otp:
        return jsonify({"message": "Invalid OTP"}), 400

    if datetime.now() > record["expires_at"]:
        db.otps.delete_one({"email": email})
        return jsonify({"message": "OTP expired"}), 400

    hashed_pw = generate_password_hash(new_password)
    users.update_one({"email": email}, {"$set": {"password": hashed_pw}})
    db.otps.delete_one({"email": email})

    return jsonify({"message": "Password reset successful"}), 200

@app.route("/update-profile", methods=["POST"])
def update_profile():
    data = request.get_json()
    email = data.get("email")
    users.update_one({"email": email}, {"$set": {"name": data.get("name"), "phone": data.get("phone")}})
    return jsonify({"message": "Profile updated"}), 200

@app.route("/ai-chat", methods=["POST"])
def ai_chat():
    if not ai_client:
        return jsonify({"message": "AI not configured"}), 500
    
    try:
        data = request.get_json()
        message = data.get("message")
        history = data.get("history", [])
        
        system_prompt = """
        You are LexisCore AI, a professional and authoritative legal assistant. 
        Your expertise is strictly limited to the legal domain. 
        Rules:
        1. Only answer questions related to law, legal procedures, rights, and regulations.
        2. If a user asks about medical, general knowledge, entertainment, or any non-legal topic, politely state that you are a specialized legal AI and cannot assist with that.
        3. Always try to cite relevant legal sections (e.g., from BNS, IPC, CRPC, etc.) if applicable.
        4. Provide clear 'Next Steps' for legal situations.
        5. Maintain a professional, neutral, and helpful tone.
        """
        
        # Format history for the new Google GenAI SDK
        gemini_history = []
        for turn in history:
            role = "user" if turn.get("role") == "user" else "model"
            gemini_history.append(types.Content(
                role=role,
                parts=[types.Part(text=turn.get("text", ""))]
            ))
        
        # Using the chat session for better context handling
        chat = ai_client.chats.create(
            model="gemini-3-flash-preview",
            history=gemini_history,
            config=types.GenerateContentConfig(
                system_instruction=system_prompt,
                temperature=0.7,
            )
        )
        response = chat.send_message(message)
        return jsonify({"response": response.text.strip()}), 200
    except Exception as e:
        print(f"AI Chat Error: {str(e)}")
        return jsonify({"message": f"AI Error: {str(e)}"}), 500




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
                res = ai_client.models.generate_content(model="gemini-3-flash-preview", contents=prompt)
                txt = res.text.strip()
                if "```json" in txt: txt = txt.split("```json")[1].split("```")[0]
                analysis = json.loads(txt)
            except: pass

        case_id = _gen_case_id("LND")
        db["land_fraud_cases"].insert_one({
            "case_id": case_id, 
            "email": email, 
            "details": {"uploaded_files": uploaded_files},
            "analysis": analysis
        })
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
                res = ai_client.models.generate_content(model="gemini-3-flash-preview", contents=prompt)
                txt = res.text.strip()
                if "```json" in txt: txt = txt.split("```json")[1].split("```")[0]
                analysis = json.loads(txt)
            except: pass

        case_id = _gen_case_id("CYB")
        db["cyber_crime_cases"].insert_one({
            "case_id": case_id, 
            "email": email, 
            "details": {
                "incident_type": incident_type,
                "description": description,
                "amount": amount,
                "uploaded_files": uploaded_files
            },
            "analysis": analysis
        })
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
                res = ai_client.models.generate_content(model="gemini-3-flash-preview", contents=prompt)
                txt = res.text.strip()
                if "```json" in txt: txt = txt.split("```json")[1].split("```")[0]
                analysis = json.loads(txt)
            except: pass

        case_id = _gen_case_id("TRF")
        db["traffic_cases"].insert_one({
            "case_id": case_id, 
            "email": email, 
            "details": {
                "case_type": case_type,
                "vehicle_number": vehicle_number,
                "location": location,
                "date_time": date_time,
                "description": description,
                "uploaded_files": uploaded_files
            },
            "analysis": analysis,
            "status": "Submitted",
            "created_at": datetime.now().isoformat()
        })
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
                res = ai_client.models.generate_content(model="gemini-3-flash-preview", contents=prompt)
                txt = res.text.strip()
                if "```json" in txt: txt = txt.split("```json")[1].split("```")[0]
                analysis = json.loads(txt)
            except: pass

        case_id = _gen_case_id("WSF")
        db["women_safety_reports"].insert_one({
            "case_id": case_id, 
            "email": email, 
            "details": {
                "description": description,
                "location": location,
                "emergency_contacts_notified": emergency_contacts_notified,
                "uploaded_files": uploaded_files
            },
            "analysis": analysis,
            "status": "Submitted",
            "created_at": datetime.now().isoformat()
        })
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
                res = ai_client.models.generate_content(model="gemini-3-flash-preview", contents=prompt)
                txt = res.text.strip()
                if "```json" in txt: txt = txt.split("```json")[1].split("```")[0]
                analysis = json.loads(txt)
            except: pass

        case_id = _gen_case_id("EMP")
        db["employee_cases"].insert_one({
            "case_id": case_id, 
            "email": email, 
            "details": {
                "case_type": case_type,
                "company_name": company_name,
                "job_role": job_role,
                "duration_work": duration_work,
                "salary_pending": salary_pending,
                "description": description,
                "uploaded_files": uploaded_files
            },
            "analysis": analysis,
            "status": "Submitted",
            "created_at": datetime.now().isoformat()
        })
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
                res = ai_client.models.generate_content(model="gemini-3-flash-preview", contents=prompt)
                txt = res.text.strip()
                if "```json" in txt: txt = txt.split("```json")[1].split("```")[0]
                analysis = json.loads(txt)
            except: pass

        case_id = _gen_case_id("TEN")
        db["tenant_cases"].insert_one({
            "case_id": case_id, 
            "email": email, 
            "details": {
                "case_type": case_type,
                "property_address": property_address,
                "owner_name": owner_name,
                "duration_stay": duration_stay,
                "deposit_amount": deposit_amount,
                "description": description,
                "uploaded_files": uploaded_files
            },
            "analysis": analysis,
            "status": "Submitted",
            "created_at": datetime.now().isoformat()
        })
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
                res = ai_client.models.generate_content(model="gemini-3-flash-preview", contents=prompt)
                txt = res.text.strip()
                if "```json" in txt: txt = txt.split("```json")[1].split("```")[0]
                analysis = json.loads(txt)
            except: pass

        case_id = _gen_case_id("CON")
        db["consumer_cases"].insert_one({
            "case_id": case_id, 
            "email": email, 
            "details": {
                "case_type": case_type,
                "product_name": product_name,
                "seller_name": seller_name,
                "purchase_date": purchase_date,
                "amount_paid": amount_paid,
                "description": description,
                "uploaded_files": uploaded_files
            },
            "analysis": analysis,
            "status": "Submitted",
            "created_at": datetime.now().isoformat()
        })
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
                res = ai_client.models.generate_content(model="gemini-3-flash-preview", contents=prompt)
                txt = res.text.strip()
                if "```json" in txt: txt = txt.split("```json")[1].split("```")[0]
                analysis = json.loads(txt)
            except: pass

        case_id = _gen_case_id("STU")
        db["student_cases"].insert_one({
            "case_id": case_id, 
            "email": email, 
            "details": {
                "case_type": case_type,
                "college_name": college_name,
                "department": department,
                "date_incident": date_incident,
                "description": description,
                "uploaded_files": uploaded_files
            },
            "analysis": analysis,
            "status": "Submitted",
            "created_at": datetime.now().isoformat()
        })
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
                res = ai_client.models.generate_content(model="gemini-3-flash-preview", contents=prompt)
                txt = res.text.strip()
                if "```json" in txt: txt = txt.split("```json")[1].split("```")[0]
                analysis = json.loads(txt)
            except: pass

        case_id = _gen_case_id("ACC")
        db["accident_cases"].insert_one({
            "case_id": case_id, 
            "email": email, 
            "details": {
                "case_type": case_type,
                "vehicle_number": vehicle_number,
                "location": location,
                "date_time": date_time,
                "description": description,
                "uploaded_files": uploaded_files
            },
            "analysis": analysis,
            "status": "Submitted",
            "created_at": datetime.now().isoformat()
        })
        analysis["case_id"] = case_id
        return jsonify(analysis), 200
    except Exception as e:
        return jsonify({"error": str(e)}), 500

@app.route("/submit-dv-complaint", methods=["POST"])
def submit_dv_complaint():
    try:
        email = request.form.get("email")
        description = request.form.get("description")
        latitude = request.form.get("latitude")
        longitude = request.form.get("longitude")
        
        location_context = ""
        if latitude and longitude:
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

        analysis = {
            "risk_level": "HIGH",
            "risk_summary": "Immediate legal protection recommended.",
            "case_summary": "Victim reports continuous abuse.",
            "how_risk_analysis_calculated": "Calculated based on severity of the incident and evidence provided.",
            "missing_documents": ["Medical report from recent incident"],
            "legal_actions": ["File FIR under Section 498A", "Apply for Protection Order"],
            "complaint_draft": "To,\nThe Officer-in-Charge...",
            "id_verification_status": "Unable to verify ID"
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
                return {"id_verification_status": "Unable to verify ID", "victim_name": "", "victim_id_number": ""}
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
                    model="gemini-2.5-pro",
                    contents=[prompt] + files,
                    config=safe_config
                )
                return json.loads(res.text.strip().replace("```json", "").replace("```", ""))
            except Exception as e:
                print(f"ID Agent Error: {e}")
                return {"id_verification_status": "Error verifying ID", "victim_name": "", "victim_id_number": ""}

        def agent_risk_analysis(desc, files, client):
            if not client: return {}
            prompt = f"""
            TASK - RISK ANALYSIS:
            Analyze this domestic violence case description: {desc}
            Consider any evidence in the attached files.
            
            Respond ONLY in valid JSON:
            {{
              "risk_level": "HIGH or MEDIUM or LOW",
              "risk_summary": "short explanation",
              "case_summary": "2-3 sentence summary",
              "how_risk_analysis_calculated": "explanation of how the risk score was determined",
              "missing_documents": ["list", "of", "missing", "docs"],
              "legal_actions": ["list", "of", "legal", "steps"]
            }}
            """
            try:
                res = client.models.generate_content(
                    model="gemini-2.5-pro",
                    contents=[prompt] + files,
                    config=safe_config
                )
                return json.loads(res.text.strip().replace("```json", "").replace("```", ""))
            except Exception as e:
                print(f"Risk Agent Error: {e}")
                return {}

        def agent_local_support(loc_ctx, client):
            if not client: return {}
            prompt = f"""
            TASK - LOCAL SUPPORT & POLICE STATIONS:
            {loc_ctx if loc_ctx else "Location not provided. Suggest 1 major real police station in New Delhi."}
            Based on the location, name ONE real, verifiable police station closest to that location. Include full address.
            Also suggest a generic but real lawyer category or organization for domestic violence.
            
            Respond ONLY in valid JSON:
            {{
              "police_station_1": "Name, Full Address",
              "suggested_lawyer": "Name and contact or organization"
            }}
            """
            try:
                res = client.models.generate_content(
                    model="gemini-2.5-pro",
                    contents=prompt,
                    config=safe_config
                )
                return json.loads(res.text.strip().replace("```json", "").replace("```", ""))
            except Exception as e:
                print(f"Support Agent Error: {e}")
                return {}

        def agent_legal_draft(desc, id_data, client):
            if not client: return {}
            v_name = id_data.get("victim_name", "[Complainant Name]")
            if not v_name: v_name = "[Complainant Name]"
            v_id = id_data.get("victim_id_number", "[ID Number]")
            if not v_id: v_id = "[ID Number]"
            prompt = f"""
            TASK - COMPLAINT DRAFT:
            Write a formal FIR/complaint letter for domestic violence.
            Victim Name: {v_name}
            Victim ID: {v_id}
            Description of Incident: {desc}
            
            Respond ONLY in valid JSON:
            {{
              "complaint_draft": "Full formal complaint text with victim name and ID filled in"
            }}
            """
            try:
                res = client.models.generate_content(
                    model="gemini-2.5-pro",
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
                future_support = executor.submit(agent_local_support, location_context, ai_client)
                
                id_data = future_id.result()
                risk_data = future_risk.result()
                support_data = future_support.result()
                
            draft_data = agent_legal_draft(description, id_data, ai_client)
            
            # Merge agent outputs
            if id_data: analysis.update(id_data)
            if risk_data: analysis.update(risk_data)
            if support_data: analysis.update(support_data)
            if draft_data: analysis.update(draft_data)


        case_id = _gen_case_id("DV")
        db["dv_cases"].insert_one({
            "case_id": case_id, 
            "email": email, 
            "details": {
                "description": description,
                "uploaded_files": uploaded_files
            },
            "analysis": analysis,
            "status": "Submitted",
            "created_at": datetime.now().isoformat()
        })
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
                res = ai_client.models.generate_content(model="gemini-3-flash-preview", contents=prompt)
                txt = res.text.strip()
                if "```json" in txt: txt = txt.split("```json")[1].split("```")[0]
                analysis = json.loads(txt)
            except: pass

        case_id = _gen_case_id(category[:2].upper())
        db["generic_cases"].insert_one({
            "case_id": case_id,
            "email": email,
            "type": category,
            "details": {"description": description},
            "analysis": analysis,
            "status": "Submitted",
            "created_at": datetime.now().isoformat()
        })
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
        
        # Collect from all collections
        for coll_name, type_label in [
            ("cyber_crime_cases", "Cyber Crime"),
            ("land_fraud_cases", "Land Dispute"),
            ("dv_cases", "Domestic Violence"),
            ("traffic_cases", "Traffic Issue"),
            ("women_safety_reports", "Women Safety"),
            ("employee_cases", "Employee Rights"),
            ("tenant_cases", "Tenant Issue"),
            ("consumer_cases", "Consumer Complaint"),
            ("student_cases", "Student Issues"),
            ("accident_cases", "Accident Claim"),
            ("generic_cases", "General Report")
        ]:
            cases = list(db[coll_name].find({"email": email}))
            for c in cases:
                c.pop("_id", None)
                c["type"] = type_label
                # Normalize status if missing
                if "status" not in c: c["status"] = "Submitted"
                all_cases.append(c)
                
        return jsonify(all_cases), 200
    except Exception as e:
        return jsonify({"error": str(e)}), 500


if __name__ == "__main__":
    app.run(host="0.0.0.0", port=port, debug=True, use_reloader=False)