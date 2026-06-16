import os

lib_dir = r"d:\PDD\my_app\lib\client"

for filename in os.listdir(lib_dir):
    if filename.endswith(".dart"):
        filepath = os.path.join(lib_dir, filename)
        with open(filepath, 'r', encoding='utf-8') as f:
            content = f.read()
            
        original_content = content
        
        if 'Text("Case Summary"' in content:
            new_text = '''Text("Risk Analysis", style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text(_caseResult?['how_risk_analysis_calculated'] ?? 'Calculated based on severity and evidence provided.', style: GoogleFonts.inter(fontSize: 13, color: Colors.black87, height: 1.5)),
          const SizedBox(height: 24),
          Text("Case Summary"'''
            content = content.replace('Text("Case Summary"', new_text)
            
        elif "_caseResult?['case_summary']" in content and 'how_risk_analysis_calculated' not in content:
            new_text = '''Text("Risk Analysis:", style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 12)),
                  Text(_caseResult?['how_risk_analysis_calculated'] ?? 'Calculated based on evidence.', style: GoogleFonts.inter(fontSize: 12, color: Colors.black87)),
                  const SizedBox(height: 12),
                  Text("Case Summary:", style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 12)),
                  Text(_caseResult?['case_summary']'''
            content = content.replace("Text(_caseResult?['case_summary']", new_text)

        if content != original_content:
            with open(filepath, 'w', encoding='utf-8') as f:
                f.write(content)
            print(f"Updated {filename}")
