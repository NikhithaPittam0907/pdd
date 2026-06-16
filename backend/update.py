import re

with open('app.py', 'r', encoding='utf-8') as f:
    content = f.read()

# 1. Update the default dictionaries
# This handles the default 'analysis' dicts.
def insert_keys_in_dict(match):
    # Match is the risk_level line.
    val = match.group(1)
    # We will just inject how_risk_analysis_calculated right after it.
    # case_summary might already exist further down, so we'll just add it if it doesn't.
    # Actually, we can just add both, and then clean up duplicate case_summary.
    res = f'"risk_level": "{val}",\n            "how_risk_analysis_calculated": "Calculated based on severity of the incident and evidence provided.",'
    return res

content = re.sub(r'"risk_level":\s*"([^"]+)",', insert_keys_in_dict, content)

# 2. Update Prompts with bullet points
# Find "- risk_level" and add the new keys
def insert_keys_in_bullet_prompt(match):
    text = match.group(0)
    if 'how_risk_analysis_calculated' not in text:
        return text + '\n            - how_risk_analysis_calculated (explanation of risk calculation)'
    return text

content = re.sub(r'-\s*risk_level\s*\([^)]*\)', insert_keys_in_bullet_prompt, content)


# 3. Update Prompts with inline keys (like 'keys: risk_level, risk_summary')
def insert_keys_in_inline_prompt(match):
    text = match.group(0)
    if 'how_risk_analysis_calculated' not in text:
        return text.replace('risk_level,', 'risk_level, case_summary, how_risk_analysis_calculated (explanation of risk calculation),')
    return text

content = re.sub(r'keys:\s*risk_level,', insert_keys_in_inline_prompt, content)


# 4. Update the DV complaint JSON schema prompt
def insert_keys_in_dv_prompt(match):
    text = match.group(0)
    if 'how_risk_analysis_calculated' not in text:
        return text + ',\n  "how_risk_analysis_calculated": "explanation of risk calculation"'
    return text

content = re.sub(r'"risk_level":\s*"HIGH or MEDIUM or LOW"', insert_keys_in_dv_prompt, content)


# 5. Update Generic Case Prompt
generic_case_old = 'Provide risk_level, risk_summary, case_summary, legal_actions, and a formal complaint_draft in JSON.'
generic_case_new = 'Provide risk_level, how_risk_analysis_calculated (explanation of risk calculation), risk_summary, case_summary, legal_actions, and a formal complaint_draft in JSON.'
content = content.replace(generic_case_old, generic_case_new)

with open('app.py', 'w', encoding='utf-8') as f:
    f.write(content)
print("Updated app.py successfully!")
