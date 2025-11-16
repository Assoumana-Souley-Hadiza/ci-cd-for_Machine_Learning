import gradio as gr
import skops.io as sio
import numpy as np
import os

# Chemin vers ton pipeline Skops
model_path = os.path.join("Model", "breast_pipeline.skops")  # vérifie le dossier exact
pipeline = sio.load(model_path, trusted=True)

# Fonction de prédiction
def predict(*features):
    X = np.array(features).reshape(1, -1)
    pred = pipeline.predict(X)[0]
    return "Malignant" if pred == 0 else "Benign"

# Création des entrées pour Gradio
inputs = [gr.Number(label=f"Feature {i}") for i in range(30)]  # 30 features pour Breast Cancer

# Interface Gradio
demo = gr.Interface(
    fn=predict,
    inputs=inputs,
    outputs="text",
    title="Breast Cancer Classifier",
    description="Random Forest classifier for Breast Cancer dataset (Skops pipeline)"
)

# Lancer l'application
demo.launch()
