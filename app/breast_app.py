import gradio as gr
import skops.io as sio
import numpy as np
import os

# ------------------------------------------------------------
# Chargement du pipeline Skops
# ------------------------------------------------------------
model_path = os.path.join("Model", "breast_pipeline.skops")

if not os.path.exists(model_path):
    raise FileNotFoundError(f"❌ Le fichier modèle est introuvable : {model_path}")

pipeline = sio.load(model_path, trusted=True)

# ------------------------------------------------------------
# Fonction de prédiction
# ------------------------------------------------------------
def predict(*features):
    X = np.array(features).reshape(1, -1)
    pred = pipeline.predict(X)[0]
    return "🔴 Malignant" if pred == 0 else "🟢 Benign"

# ------------------------------------------------------------
# Création des inputs (30 features)
# Tu peux les renommer si tu veux les vrais noms du dataset
# ------------------------------------------------------------
inputs = [
    gr.Number(label=f"Feature {i+1}", precision=None)  # precision=None pour éviter les warnings
    for i in range(30)
]

# ------------------------------------------------------------
# Interface Gradio
# ------------------------------------------------------------
demo = gr.Interface(
    fn=predict,
    inputs=inputs,
    outputs=gr.Textbox(label="Prediction"),
    title="🩺 Breast Cancer Classification App",
    description=(
        "Cette application utilise un **pipeline Scikit-learn** "
        "exporté avec **Skops** pour prédire si une tumeur est "
        "**Maligne** ou **Bénigne** à partir des données médicales. "
        "Modèle : Random Forest."
    ),
    theme=gr.themes.Soft(),
    examples=[
        [14.5, 20.5, 90.2, 600.1, 0.12, 0.10, 0.07, 0.06, 0.18, 0.06,
         0.30, 1.20, 2.40, 25.0, 0.01, 0.02, 0.03, 0.01, 0.02, 0.004,
         16.2, 28.0, 110.3, 800.2, 0.14, 0.12, 0.10, 0.09, 0.30, 0.08]
    ],
    article=(
        "<p style='text-align:center; font-size:14px; color:gray;'>"
        "Développé avec ❤️ — Modèle Random Forest, export Skops.<br>"
        "Projet Master IA."
        "</p>"
    )
)

# ------------------------------------------------------------
# Lancement de l'app
# ------------------------------------------------------------
demo.launch()
