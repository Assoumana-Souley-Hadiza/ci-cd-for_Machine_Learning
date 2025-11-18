import os
import pandas as pd
import skops.io as sio
from sklearn.model_selection import train_test_split
from sklearn.preprocessing import StandardScaler
from sklearn.pipeline import Pipeline
from sklearn.ensemble import RandomForestClassifier
from sklearn.metrics import classification_report, confusion_matrix
import matplotlib.pyplot as plt
import seaborn as sns
import json
from sklearn.datasets import load_breast_cancer

# ✅ Créer les dossiers si non existants
os.makedirs("model", exist_ok=True)
os.makedirs("results", exist_ok=True)
os.makedirs("data", exist_ok=True)

# ✅ Générer dataset Breast Cancer
dataset = load_breast_cancer()
X = dataset.data
y = dataset.target
df = pd.DataFrame(X, columns=dataset.feature_names)
df["target"] = y
df.to_csv("data/breast_cancer.csv", index=False)

# ✅ Split train/test
X_train, X_test, y_train, y_test = train_test_split(
    X, y, test_size=0.2, random_state=42
)

# ✅ Créer un pipeline avec StandardScaler + RandomForest
pipe = Pipeline(
    [
        ("scaler", StandardScaler()),
        ("clf", RandomForestClassifier(n_estimators=100, random_state=42)),
    ]
)

# ✅ Entraînement
pipe.fit(X_train, y_train)

# ✅ Sauvegarde complète du pipeline avec Skops
sio.dump(pipe, "model/breast_pipeline.skops")

# ✅ Évaluation
y_pred = pipe.predict(X_test)
report = classification_report(y_test, y_pred, output_dict=True)

from sklearn.metrics import classification_report

# Rapport texte
report_text = classification_report(y_test, y_pred)

# Sauvegarde en txt
with open("results/metrics.txt", "w") as f:
    f.write(report_text)


# Sauvegarde du rapport
with open("results/classification_report.json", "w") as f:
    json.dump(report, f)

# Matrice de confusion
cm = confusion_matrix(y_test, y_pred)
plt.figure(figsize=(6, 4))
sns.heatmap(cm, annot=True, fmt="d", cmap="Blues")
plt.title("Confusion Matrix")
plt.savefig("results/confusion_matrix.png")
plt.close()

print(
    "✅ Entraînement terminé et pipeline sauvegardé dans 'model/breast_pipeline.skops'"
)
