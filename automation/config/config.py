import os

# Target Application URL (GitHub Pages Live Environment)
# Default is parameterized for NikhithaPittam0907's pdd repository
BASE_URL = os.environ.get("BASE_URL", "https://NikhithaPittam0907.github.io/pdd/").strip()

# Simulation Settings
SIMULATE_TESTS = os.environ.get("SIMULATE_TESTS", "true").lower() == "true"

# Headless Settings
HEADLESS = os.environ.get("HEADLESS", "true").lower() == "true"
