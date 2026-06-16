import re

def migrate(filepath):
    with open(filepath, 'r', encoding='utf-8') as f:
        content = f.read()

    # 1. Imports
    content = content.replace(
        "from pymongo.mongo_client import MongoClient\nfrom pymongo.server_api import ServerApi",
        "from flask_sqlalchemy import SQLAlchemy\nfrom sqlalchemy.dialects.mysql import JSON"
    )

    # 2. Setup
    setup_old = """# DB Config
MONGO_URI = os.getenv("MONGO_URI")
DB_NAME = os.getenv("DB_NAME")
collection_name = os.getenv("COLLECTION_NAME", "users")
port = int(os.getenv("PORT", 5000))

client = MongoClient(MONGO_URI, server_api=ServerApi('1'))
db = client[DB_NAME]
users = db[collection_name]"""

    setup_new = """# DB Config
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
    created_at = db.Column(db.DateTime, nullable=False)

with app.app_context():
    db.create_all()"""
    
    content = content.replace(setup_old, setup_new)

    # 3. Signup
    signup_old = """    if users.find_one({"email": email}):
        return jsonify({"message": "User already exists"}), 400
    data["password"] = generate_password_hash(password)
    users.insert_one(data)"""
    signup_new = """    if User.query.filter_by(email=email).first():
        return jsonify({"message": "User already exists"}), 400
    new_user = User(
        email=email,
        password=generate_password_hash(password),
        name=data.get("name"),
        phone=data.get("phone")
    )
    db.session.add(new_user)
    db.session.commit()"""
    content = content.replace(signup_old, signup_new)

    # 4. Login
    login_old = """    user = users.find_one({"email": data.get("email")})
    if user and check_password_hash(user["password"], data.get("password")):
        user.pop("_id")
        user.pop("password")
        return jsonify({"message": "Login successful", **user}), 200"""
    login_new = """    user = User.query.filter_by(email=data.get("email")).first()
    if user and check_password_hash(user.password, data.get("password")):
        user_dict = {"email": user.email, "name": user.name, "phone": user.phone}
        return jsonify({"message": "Login successful", **user_dict}), 200"""
    content = content.replace(login_old, login_new)

    # 5. Forgot Password
    forgot_old = """    user = users.find_one({"email": email})
    if not user:
        return jsonify({"message": "User not found"}), 404

    otp = ''.join(random.choices(string.digits, k=6))
    expires_at = datetime.now() + timedelta(minutes=10)
    
    db.otps.update_one(
        {"email": email},
        {"$set": {"otp": otp, "expires_at": expires_at}},
        upsert=True
    )"""
    forgot_new = """    user = User.query.filter_by(email=email).first()
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
    db.session.commit()"""
    content = content.replace(forgot_old, forgot_new)

    # 6. Reset Password
    reset_old1 = """    record = db.otps.find_one({"email": email})
    if not record:
        return jsonify({"message": "No OTP requested for this email"}), 400

    if record["otp"] != otp:
        return jsonify({"message": "Invalid OTP"}), 400

    if datetime.now() > record["expires_at"]:
        db.otps.delete_one({"email": email})
        return jsonify({"message": "OTP expired"}), 400

    hashed_pw = generate_password_hash(new_password)
    users.update_one({"email": email}, {"$set": {"password": hashed_pw}})
    db.otps.delete_one({"email": email})"""
    reset_new1 = """    record = OTP.query.filter_by(email=email).first()
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
    db.session.commit()"""
    content = content.replace(reset_old1, reset_new1)

    # 7. Update profile
    update_old = """    users.update_one({"email": email}, {"$set": {"name": data.get("name"), "phone": data.get("phone")}})"""
    update_new = """    user = User.query.filter_by(email=email).first()
    if user:
        if "name" in data: user.name = data.get("name")
        if "phone" in data: user.phone = data.get("phone")
        db.session.commit()"""
    content = content.replace(update_old, update_new)

    # 8. Endpoints mapping (case type names to match UI / expected)
    # I'll use regex to replace all case insertions
    pattern = re.compile(r'db\["([^"]+)"\]\.insert_one\(\{.*?\}\)', re.DOTALL)
    
    def replacer(match):
        coll_name = match.group(1)
        # Determine type based on collection
        type_mapping = {
            "land_fraud_cases": "Land Dispute",
            "cyber_crime_cases": "Cyber Crime",
            "traffic_cases": "Traffic Issue",
            "women_safety_reports": "Women Safety",
            "employee_cases": "Employee Rights",
            "tenant_cases": "Tenant Issue",
            "consumer_cases": "Consumer Complaint",
            "student_cases": "Student Issues",
            "accident_cases": "Accident Claim",
            "dv_cases": "Domestic Violence",
            "generic_cases": "General Report"
        }
        case_type = type_mapping.get(coll_name, "General Report")
        
        # We know that the dictionary inside insert_one has keys: case_id, email, details, analysis, status, created_at
        # Let's just create a generic assignment. Wait, generic_cases has a "type": category field.
        
        if coll_name == "generic_cases":
            return f'''new_case = Case(
            case_id=case_id,
            email=email,
            type=category,
            details={{"description": description}},
            analysis=analysis,
            status="Submitted",
            created_at=datetime.now()
        )
        db.session.add(new_case)
        db.session.commit()'''
        
        return f'''new_case = Case(
            case_id=case_id,
            email=email,
            type="{case_type}",
            details={{k: v for k, v in locals().items() if k == "details"}}.get("details", {{}}), # Hack to get details dict if it was defined, but actually let's just use the local variables that were packed
            analysis=analysis,
            status="Submitted",
            created_at=datetime.now()
        )
        # Wait, the dict actually contains the details dictionary inline in some cases, or maybe it was inline.
        # Let's write the correct Python code. We can extract it from the locals or just build it here since we know the keys.
        # Actually, let's just replace the db["..."] block directly with regex.
        pass'''

    # It's better to manually regex replace the block since it's almost identical.
    
    # We will replace the db insert block with standard SQLAlchemy insert.
    # The insert block looks like:
    '''db["collection_name"].insert_one({
            "case_id": case_id, 
            "email": email, 
            "details": { ... },
            "analysis": analysis,
            "status": "Submitted",
            "created_at": datetime.now().isoformat()
        })'''
        
    # We can just write a slightly smarter regex.
    insert_pattern = re.compile(
        r'db\["(?P<coll>[^"]+)"\]\.insert_one\(\{\s*'
        r'"case_id": case_id,\s*'
        r'"email": email,\s*'
        r'(?P<details_or_type>.*?)\s*'
        r'"analysis": analysis,?\s*'
        r'(?P<status_created>.*?)\s*'
        r'\}\)',
        re.DOTALL
    )

    def insert_replacer(match):
        coll = match.group("coll")
        details_or_type = match.group("details_or_type").strip()
        
        type_mapping = {
            "land_fraud_cases": "Land Dispute",
            "cyber_crime_cases": "Cyber Crime",
            "traffic_cases": "Traffic Issue",
            "women_safety_reports": "Women Safety",
            "employee_cases": "Employee Rights",
            "tenant_cases": "Tenant Issue",
            "consumer_cases": "Consumer Complaint",
            "student_cases": "Student Issues",
            "accident_cases": "Accident Claim",
            "dv_cases": "Domestic Violence",
        }
        
        case_type = type_mapping.get(coll, "General Report")
        
        if coll == "generic_cases":
            return '''new_case = Case(
            case_id=case_id,
            email=email,
            type=category,
            details={"description": description},
            analysis=analysis,
            status="Submitted",
            created_at=datetime.now()
        )
        db.session.add(new_case)
        db.session.commit()'''
        
        # details_or_type usually is `"details": { ... },`
        # we need to pass that to Case details.
        # Let's extract the actual details dict string.
        details_str = details_or_type
        if details_str.startswith('"details":'):
            details_str = details_str[10:].strip()
            if details_str.endswith(','):
                details_str = details_str[:-1].strip()
        
        return f'''new_case = Case(
            case_id=case_id,
            email=email,
            type="{case_type}",
            details={details_str},
            analysis=analysis,
            status="Submitted",
            created_at=datetime.now()
        )
        db.session.add(new_case)
        db.session.commit()'''

    content = insert_pattern.sub(insert_replacer, content)

    # Let's fix land fraud specifically, it didn't have status/created_at
    land_fraud_old = '''db["land_fraud_cases"].insert_one({
            "case_id": case_id, 
            "email": email, 
            "details": {"uploaded_files": uploaded_files},
            "analysis": analysis
        })'''
    land_fraud_new = '''new_case = Case(
            case_id=case_id,
            email=email,
            type="Land Dispute",
            details={"uploaded_files": uploaded_files},
            analysis=analysis,
            status="Submitted",
            created_at=datetime.now()
        )
        db.session.add(new_case)
        db.session.commit()'''
    content = content.replace(land_fraud_old, land_fraud_new)
    
    # Let's fix cyber crime specifically
    cyber_old = '''db["cyber_crime_cases"].insert_one({
            "case_id": case_id, 
            "email": email, 
            "details": {
                "incident_type": incident_type,
                "description": description,
                "amount": amount,
                "uploaded_files": uploaded_files
            },
            "analysis": analysis
        })'''
    cyber_new = '''new_case = Case(
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
        db.session.commit()'''
    content = content.replace(cyber_old, cyber_new)

    # get_my_cases rewrite
    get_cases_old = '''        all_cases = []
        
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
                
        return jsonify(all_cases), 200'''
    get_cases_new = '''        all_cases = []
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
            
        return jsonify(all_cases), 200'''
    content = content.replace(get_cases_old, get_cases_new)

    with open(filepath, 'w', encoding='utf-8') as f:
        f.write(content)

if __name__ == "__main__":
    migrate("d:/PDD/my_app/backend/app.py")
