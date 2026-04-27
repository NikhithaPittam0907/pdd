from flask import Flask, request, jsonify
import json
from google import genai

from flask_cors import CORS
from pymongo import MongoClient
from werkzeug.security import generate_password_hash, check_password_hash
from dotenv import load_dotenv
import os
from werkzeug.utils import secure_filename
from PyPDF2 import PdfReader
from docx import Document


load_dotenv("D:/PDD/my_app/backend/.env")

app = Flask(__name__)
CORS(app)

mongo_uri = os.getenv("MONGO_URI")
db_name = os.getenv("DB_NAME")
collection_name = os.getenv("COLLECTION_NAME")
port = int(os.getenv("PORT", 5000))
gemini_api_key = os.getenv("GEMINI_API_KEY")

# Initialize Gemini Client
ai_client = genai.Client(api_key=gemini_api_key) if gemini_api_key and gemini_api_key != "YOUR_API_KEY_HERE" else None

client = MongoClient(mongo_uri)
db = client[db_name]
users = db[collection_name]

@app.route("/")
def home():
    return jsonify({"message": "Backend Running"})

UPLOAD_FOLDER = "uploads"
os.makedirs(UPLOAD_FOLDER, exist_ok=True)

@app.route("/extract-text", methods=["POST"])
def extract_text():
    if "file" not in request.files:
        return jsonify({"message": "No file uploaded"}), 400

    file = request.files["file"]

    if file.filename == "":
        return jsonify({"message": "Empty filename"}), 400

    filename = secure_filename(file.filename)
    filepath = os.path.join(UPLOAD_FOLDER, filename)
    file.save(filepath)

    text = ""

    try:
        if filename.lower().endswith(".pdf"):
            reader = PdfReader(filepath)
            for page in reader.pages:
                page_text = page.extract_text()
                if page_text:
                    text += page_text + "\n"

        elif filename.lower().endswith(".docx"):
            doc = Document(filepath)
            for para in doc.paragraphs:
                text += para.text + "\n"

        else:
            return jsonify({"message": "Only PDF and DOCX supported"}), 400

        if not text.strip():
            return jsonify({"message": "No text extracted from document"}), 400

        # AI Analysis
        analysis = {}
        if ai_client:
            prompt = f"""
            You are a specialized legal AI assistant. Analyze the following extracted text from a document.
            
            IMPORTANT:
            1. If the document is NOT a legal document, court case, contract, or law-related, strictly respond with ONLY the following text: "NON_LEGAL_DOCUMENT"
            2. If it is a legal document, provide a detailed analysis in valid JSON format with EXACTLY these keys:
               - case_type (Type of case)
               - duration (Estimated duration)
               - strategy_to_reduce_period (How to reduce case period)
               - winning_probability (As a percentage or range)
               - risk_analysis (Detailed risk assessment)
               - strategic_execution_plan (Step by step plan)
               - settlement_outlook (Possibility and terms of settlement)
               - current_strategy (Analysis of the existing approach)

            Extracted Text:
            {text[:5000]}  # Limiting to 5000 characters for context window safety
            """
            
            try:
                response = ai_client.models.generate_content(
                    model="gemini-2.0-flash",
                    contents=prompt
                )
                
                ai_text = response.text.strip()
                
                if "NON_LEGAL_DOCUMENT" in ai_text:
                    return jsonify({"message": "This document is not related to legal cases."}), 400
                
                # Extract JSON if AI wrapped it in markdown code blocks
                if "```json" in ai_text:
                    ai_text = ai_text.split("```json")[1].split("```")[0].strip()
                elif "```" in ai_text:
                    ai_text = ai_text.split("```")[1].strip()
                
                analysis = json.loads(ai_text)
            except Exception as ai_err:
                print(f"AI Analysis Error: {ai_err}")
                analysis = {"error": "Could not perform AI analysis"}

        return jsonify({
            "filename": filename,
            "content": text.strip(),
            "analysis": analysis
        }), 200

    except Exception as e:
        return jsonify({"message": str(e)}), 500
        
@app.route("/signup", methods=["POST"])
def signup():
    data = request.get_json()

    name = data.get("name")
    email = data.get("email")
    phone = data.get("phone")
    password = data.get("password")
    role = data.get("role")

    if not email or not password:
        return jsonify({"message": "Email and password required"}), 400

    if users.find_one({"email": email}):
        return jsonify({"message": "User already exists"}), 400

    hashed_password = generate_password_hash(password)

    users.insert_one({
        "name": name,
        "email": email,
        "phone": phone,
        "password": hashed_password,
        "role": role
    })

    return jsonify({"message": "Signup successful"}), 201

@app.route("/login", methods=["POST"])
def login():
    data = request.get_json()

    email = data.get("email")
    password = data.get("password")

    user = users.find_one({"email": email})

    if user and check_password_hash(user["password"], password):
        return jsonify({
            "message": "Login successful",
            "name": user.get("name"),
            "email": user.get("email"),
            "phone": user.get("phone"),
            "role": user.get("role")
        }), 200

    return jsonify({"message": "Invalid credentials"}), 401

@app.route("/reset-password", methods=["POST"])
def reset_password():
    data = request.get_json()

    email = data.get("email")
    new_password = data.get("password")

    user = users.find_one({"email": email})

    if not user:
        return jsonify({"message": "User not found"}), 404

    hashed_password = generate_password_hash(new_password)

    users.update_one(
        {"email": email},
        {"$set": {"password": hashed_password}}
    )

    return jsonify({"message": "Password updated successfully"}), 200

@app.route("/update-profile", methods=["POST"])
def update_profile():
    data = request.get_json()

    email = data.get("email")
    new_name = data.get("name")
    new_phone = data.get("phone")

    user = users.find_one({"email": email})

    if not user:
        return jsonify({"message": "User not found"}), 404

    users.update_one(
        {"email": email},
        {"$set": {"name": new_name, "phone": new_phone}}
    )

    return jsonify({"message": "Profile updated successfully"}), 200


if __name__ == "__main__":
    app.run(
        host="0.0.0.0",
        port=port,
        debug=True
    )