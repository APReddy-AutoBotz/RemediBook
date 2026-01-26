import csv
import re
from typing import List, Dict, Optional

class TriageAgent:
    def __init__(self, data_path: str):
        self.data_path = data_path
        self.ailments = self._load_data()

    def _load_data(self) -> List[Dict]:
        ailments = []
        try:
            with open(self.data_path, mode='r', encoding='utf-8') as csvfile:
                reader = csv.DictReader(csvfile)
                for row in reader:
                    ailments.append(row)
        except FileNotFoundError:
            print(f"Error: {self.data_path} not found.")
        return ailments

    def _match_keywords(self, text: str, keywords_str: str) -> bool:
        """
        Splits keywords by comma and checks if any exist in the text using regex.
        """
        keywords = [k.strip().lower() for k in keywords_str.split(',')]
        text = text.lower()
        for kw in keywords:
            if re.search(rf"\b{re.escape(kw)}\b", text):
                return True
        return False

    def triage(self, user_input: str) -> Dict:
        """
        Evaluates user input for Red Flags and Safe Symptoms.
        Returns a result dictionary with status and details.
        """
        user_input_lower = user_input.lower()

        # 1. Check for DANGER first (Red Flags)
        for ailment in self.ailments:
            if self._match_keywords(user_input_lower, ailment['Red_Flags']):
                return {
                    "status": "DANGER",
                    "reason": f"Red flag detected for {ailment['Ailment']}: {ailment['Red_Flags']}",
                    "ailment": ailment['Ailment'],
                    "action": "IMMEDIATE MEDICAL ESCALATION REQUIRED"
                }

        # 2. Check for SAFE symptoms
        for ailment in self.ailments:
            if self._match_keywords(user_input_lower, ailment['Minor_Symptoms']):
                return {
                    "status": "SAFE",
                    "reason": f"Symptom matches {ailment['Ailment']}.",
                    "ailment": ailment['Ailment'],
                    "remedy": ailment['Remedy_Name'],
                    "ingredients": ailment['Ingredients'],
                    "preparation": ailment['Preparation'],
                    "practice": ailment['Mind_Body_Practice'],
                    "practitioner": ailment['Practitioner_Type'],
                    "evidence": ailment['Evidence_Badge']
                }

        # 3. Handle UNKNOWN cases
        return {
            "status": "UNKNOWN",
            "reason": "Input does not match documented safe symptoms or specific red flags.",
            "action": "Please describe your symptoms more clearly or consult a professional if you feel unwell."
        }

if __name__ == "__main__":
    # Test cases
    agent = TriageAgent("d:/RemediBook_G/RemediBook_Golden_Ailments_V1.csv")
    
    test_inputs = [
        "I have a runny nose and sneezing",
        "I am coughing up blood and have chest pain",
        "I have a mild throat tickle",
        "I feel very weak and pale",
        "I have a blue toe"
    ]

    print("--- RemediBook Triage Agent Test ---")
    for text in test_inputs:
        result = agent.triage(text)
        print(f"\nUser: {text}")
        print(f"Status: {result['status']}")
        print(f"Reason: {result.get('reason')}")
        if result['status'] == 'SAFE':
            print(f"Suggested Remedy: {result['remedy']}")
