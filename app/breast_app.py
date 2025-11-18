import gradio as gr
import skops.io as sio
import numpy as np
import os
from sklearn.datasets import load_breast_cancer

# ------------------------------------------------------------
# Chargement du pipeline Skops
# ------------------------------------------------------------
model_path = os.path.join("Model", "breast_pipeline.skops")

# Récupérer les types non sûrs (API Skops >= 0.10)
trusted_types = sio.get_untrusted_types(file=model_path)

# Charger avec la liste des types
pipeline = sio.load(model_path, trusted=trusted_types)

# ------------------------------------------------------------
# Fonction de prédiction
# ------------------------------------------------------------
def predict(*features):
    X = np.array(features).reshape(1, -1)
    pred = pipeline.predict(X)[0]
    return "🔴 Malignant" if pred == 0 else "🟢 Benign"

# ------------------------------------------------------------
# Noms réels des caractéristiques
# ------------------------------------------------------------
dataset = load_breast_cancer()
feature_names = dataset.feature_names  # tableau de 30 noms

# Création des inputs avec les vrais noms
inputs = [gr.Number(label=name, precision=None) for name in feature_names]

# ------------------------------------------------------------
# Exemples réalistes (première ligne du dataset)
# ------------------------------------------------------------
example_values = dataset.data[0].tolist()  # première ligne
examples = [example_values]  # tu peux ajouter d'autres lignes si tu veux

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
    examples=examples,
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
