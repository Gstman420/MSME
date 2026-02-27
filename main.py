from fastapi import FastAPI
from pydantic import BaseModel, Field
import joblib
import pandas as pd
from fastapi.middleware.cors import CORSMiddleware
from database.connection import db
from bson import ObjectId
from datetime import datetime

app = FastAPI(title="MSME AI Engine")

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# =========================
# MongoDB Collections
# =========================
products_collection = db["products"]
history_collection = db["prediction_history"]

# =========================
# Load ML Models
# =========================
price_model = joblib.load("price_model.pkl")
demand_model = joblib.load("demand_model.pkl")
stock_model = joblib.load("stock_model.pkl")

price_features = joblib.load("price_features.pkl")
demand_features = joblib.load("demand_features.pkl")
stock_features = joblib.load("stock_features.pkl")

# =========================
# Health Check
# =========================
@app.get("/")
def health():
    return {"status": "ok", "message": "MSME AI backend is running"}

@app.get("/test-db")
def test_db():
    try:
        count = products_collection.count_documents({})
        return {
            "success": True,
            "message": "Connected to MongoDB",
            "product_count": count
        }
    except Exception as e:
        return {
            "success": False,
            "error": str(e)
        }

# =========================
# Request Model
# =========================
class AnalyzeRequest(BaseModel):
    product_id: str
    competitor_price: float = Field(gt=0)
    discount: float = Field(ge=0, le=1)
    marketing_effect: float = Field(ge=0.5, le=2.0)
    is_holiday: bool

# =========================
# AI ANALYZE ENDPOINT
# =========================
@app.post("/ai/analyze")
def analyze(data: AnalyzeRequest):

    clean_id = data.product_id.strip()

    if not ObjectId.is_valid(clean_id):
        return {"success": False, "error": "Invalid product_id format"}

    obj_id = ObjectId(clean_id)

    product = products_collection.find_one({"_id": obj_id})

    if not product:
        return {"success": False, "error": "Product not found"}

    row = pd.DataFrame([{
        "Base_Sales": product.get("base_sales", 100),
        "Marketing_Effect": data.marketing_effect,
        "Seasonal_Effect": 1.2 if data.is_holiday else 1.0,
        "Discount": data.discount,
        "Competitor_Price": data.competitor_price,
        "Stock_Availability": product.get("stock_quantity", 50),
        "Public_Holiday": 1 if data.is_holiday else 0
    }])

    X_price = row.reindex(columns=price_features, fill_value=0)
    X_demand = row.reindex(columns=demand_features, fill_value=0)
    X_stock = row.reindex(columns=stock_features, fill_value=0)

    price = float(price_model.predict(X_price)[0])
    demand = str(demand_model.predict(X_demand)[0])
    stock_action = str(stock_model.predict(X_stock)[0])

    # =========================
    # UPDATED INTELLIGENT ALERT LOGIC
    # =========================
    alerts = []

    current_stock = product.get("stock_quantity", 0)

    # Pricing Alerts
    if price > data.competitor_price * 1.15:
        pricing_flag = "Too High"
        alerts.append("⚠ Price significantly higher than competitor — risk of losing customers")

    elif price < data.competitor_price * 0.85:
        pricing_flag = "Too Low"
        alerts.append("⚠ Price too low — margin risk")

    else:
        pricing_flag = "Competitive"

    # Demand + Inventory Alerts
    if demand == "High" and current_stock < 20:
        alerts.append("🚨 Urgent: High demand but very low stock — restock immediately")

    elif demand == "Medium" and current_stock < 15:
        alerts.append("⚠ Moderate demand with limited stock — monitor closely")

    elif demand == "Low" and current_stock > 120:
        alerts.append("📦 Overstock risk — consider promotions")

    # Discount Risk Alert
    if data.discount > 0.3:
        alerts.append("💰 Heavy discount applied — check profit margins")

    # Marketing Efficiency Alert
    if data.marketing_effect > 1.5 and demand == "Low":
        alerts.append("📉 Marketing spending high but demand still low — review campaign strategy")

    # Customer Behavior Logic (unchanged)
    if data.discount > 0.2:
        customer_behavior = "Price Sensitive"
    elif data.is_holiday:
        customer_behavior = "Seasonal Driven"
    elif data.marketing_effect > 1.2:
        customer_behavior = "Promotion Driven"
    else:
        customer_behavior = "Stable Demand"

    # Store prediction history
    history_collection.insert_one({
        "product_id": product["_id"],
        "recommended_price": round(price, 2),
        "demand_level": demand,
        "inventory_action": stock_action,
        "created_at": datetime.utcnow()
    })

    return {
        "success": True,
        "data": {
            "product_name": product.get("product_name"),
            "recommended_price": round(price, 2),
            "pricing_flag": pricing_flag,
            "demand_level": demand,
            "inventory_action": stock_action,
            "customer_behavior": customer_behavior,
            "alerts": alerts
        }
    }