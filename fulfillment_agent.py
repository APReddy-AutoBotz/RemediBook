import json
import random

class FulfillmentAgent:
    def __init__(self):
        # Mock Catalog for Blinkit and Zepto
        # Prices are in INR (₹)
        self.catalog = {
            "Blinkit": {
                "Ginger": 45,
                "Tulsi leaves": 25,
                "Honey": 180,
                "Black Pepper": 35,
                "Fennel seeds": 40,
                "Ajwain": 30,
                "Ashwagandha": 220,
                "Milk": 35,
                "Brahmi": 150,
                "Sesame oil": 95,
                "Turmeric": 40,
                "Triphala": 180,
                "Amla juice": 120,
                "Coconut oil": 85,
                "Eucalyptus oil": 120
            },
            "Zepto": {
                "Ginger": 42,
                "Tulsi leaves": 30,
                "Honey": 175,
                "Black Pepper": 32,
                "Fennel seeds": 45,
                "Ajwain": 28,
                "Ashwagandha": 210,
                "Milk": 33,
                "Brahmi": 160,
                "Sesame oil": 100,
                "Turmeric": 38,
                "Triphala": 190,
                "Amla juice": 115,
                "Coconut oil": 80,
                "Eucalyptus oil": 110
            }
        }
        
    def extract_ingredients(self, raw_string: str) -> list:
        """
        Mocking Gemini 3 parsing logic. 
        In a real scenario, this would call Gemini 3 Pro to extract clean nouns.
        """
        # Mapping known keywords from the CSV ingredients to their clean names
        keywords_map = {
            "ginger": "Ginger",
            "tulsi": "Tulsi leaves",
            "honey": "Honey",
            "black pepper": "Black Pepper",
            "fennel seeds": "Fennel seeds",
            "saunf": "Fennel seeds",
            "ajwain": "Ajwain",
            "carom seeds": "Ajwain",
            "ashwagandha": "Ashwagandha",
            "milk": "Milk",
            "brahmi": "Brahmi",
            "sesame oil": "Sesame oil",
            "turmeric": "Turmeric",
            "triphala": "Triphala",
            "amla": "Amla juice",
            "coconut oil": "Coconut oil",
            "eucalyptus oil": "Eucalyptus oil"
        }
        
        extracted = []
        raw_lower = raw_string.lower()
        for key, clean_name in keywords_map.items():
            if key in raw_lower:
                if clean_name not in extracted:
                    extracted.append(clean_name)
        return extracted

    def get_comparison(self, ingredients: list) -> dict:
        consultation_fee = 500
        
        results = {
            "Blinkit": {"total": 0, "eta": f"{random.randint(10, 20)} mins"},
            "Zepto": {"total": 0, "eta": f"{random.randint(8, 18)} mins"}
        }
        
        for item in ingredients:
            for store in ["Blinkit", "Zepto"]:
                price = self.catalog[store].get(item, 50) # default to 50 if missing
                results[store]["total"] += price
                
        # Comparison and recommendation
        b_total = results["Blinkit"]["total"]
        z_total = results["Zepto"]["total"]
        
        best_value = "Zepto" if z_total < b_total else "Blinkit"
        cheapest_remedy_cost = min(b_total, z_total)
        savings = consultation_fee - cheapest_remedy_cost

        return {
            "comparison": results,
            "best_value": best_value,
            "savings_amount": savings,
            "ingredients_extracted": ingredients
        }

    async def identify_herb(self, image_bytes: bytes, target_herb: Optional[str] = None) -> dict:
        """
        Simulates Gemini 3 Vision analysis of an herb photo.
        """
        # In a real setup, this would use:
        # model = genai.GenerativeModel('gemini-1.5-pro')
        # response = model.generate_content(['Identify this herb and verify if it is ' + target_herb, image])
        
        # Simulated responses for demo purposes
        herb_data = {
            "ginger": {"name": "Ginger", "fact": "Ginger has been used for over 5,000 years in Ayurveda to treat digestive and respiratory issues."},
            "turmeric": {"name": "Turmeric", "fact": "Turmeric contains curcumin, a powerful anti-inflammatory compound that is best absorbed with black pepper."},
            "tulsi": {"name": "Tulsi leaves", "fact": "Tulsi, or Holy Basil, is known as the 'Queen of Herbs' for its stress-relieving and immune-boosting properties."}
        }
        
        # Mock detection: We'll assume the photo is 'Ginger' for the demo if 'ginger' is in the target or input
        detected_key = "ginger"
        if target_herb and target_herb.lower() in herb_data:
            detected_key = target_herb.lower()
            
        detected = herb_data[detected_key]
        is_match = True if target_herb and target_herb.lower() == detected_key else False
        
        return {
            "detected_herb": detected["name"],
            "is_match": is_match,
            "confidence": 0.98,
            "fun_fact": detected["fact"]
        }

if __name__ == "__main__":
    agent = FulfillmentAgent()
    raw = "1-inch Ginger, 5-7 Tulsi leaves, 1 tsp Honey"
    clean = agent.extract_ingredients(raw)
    print(json.dumps(agent.get_comparison(clean), indent=2))
