import json
from triage_agent import TriageAgent
from fulfillment_agent import FulfillmentAgent

class RemediBookWorkflow:
    def __init__(self):
        self.triage_agent = TriageAgent("d:/RemediBook_G/RemediBook_Golden_Ailments_V1.csv")
        self.fulfillment_agent = FulfillmentAgent()

    def run(self, user_input: str) -> str:
        """
        Orchestrates the Triage and Fulfillment process.
        Returns a JSON string for the Flutter frontend.
        """
        # Step 1: Triage
        triage_result = self.triage_agent.triage(user_input)
        
        final_response = {
            "input_received": user_input,
            "triage": triage_result,
            "fulfillment": None,
            "display_card": "TriageOnly"
        }

        # Step 2: Fulfillment (Only if SAFE)
        if triage_result["status"] == "SAFE":
            raw_ingredients = triage_result.get("ingredients", "")
            clean_ingredients = self.fulfillment_agent.extract_ingredients(raw_ingredients)
            fulfillment_data = self.fulfillment_agent.get_comparison(clean_ingredients)
            
            final_response["fulfillment"] = fulfillment_data
            final_response["display_card"] = "FullRemedy"
            
            # Add regional legal disclaimer as per blueprint
            final_response["legal_disclaimer"] = "RemediBook provides home remedy suggestions based on traditional texts. Please consult a registered medical practitioner for persistent or severe symptoms. Not for emergency use."

        elif triage_result["status"] == "DANGER":
            final_response["display_card"] = "MedicalAlert"
            final_response["legal_disclaimer"] = "EMERGENCY: Please proceed to the nearest emergency room immediately."

        return json.dumps(final_response, indent=2)

if __name__ == "__main__":
    workflow = RemediBookWorkflow()
    
    # Example 1: Safe Ailment
    print("--- Scenario 1: Common Cold (SAFE) ---")
    print(workflow.run("I have a runny nose and sneezing"))
    
    print("\n\n--- Scenario 2: Dry Cough with Blood (DANGER) ---")
    # Example 2: Danger Ailment
    print(workflow.run("I am coughing up blood"))

    print("\n\n--- Scenario 3: Unknown Input ---")
    # Example 3: Unknown
    print(workflow.run("My knees are purple"))
