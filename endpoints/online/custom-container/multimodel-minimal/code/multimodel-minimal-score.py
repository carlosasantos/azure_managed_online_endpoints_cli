import joblib
import os
import pandas as pd
from pathlib import Path
import json


def init():
    global model_iris
    global model_diabetes

    model_dir = Path(os.getenv("AZUREML_MODEL_DIR"))
    model_iris = joblib.load(model_dir / "models/iris.sav")
    model_diabetes = joblib.load(model_dir / "models/diabetes.sav")


def run(data):
    data = json.loads(data)
    model = data["model"]
    data = pd.DataFrame(data["data"])

    if model == "iris":
        return model_iris.predict(data).tolist()
    elif model == "diabetes":
        return model_diabetes.predict(data).tolist()
    else:
        return "No such model"
