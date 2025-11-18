# === INSTALLATION DES PACKAGES PYTHON ===
install:
	pip install --upgrade pip && \
	pip install -r requirements.txt

# === FORMATAGE DU CODE ===
format:
	black *.py

# === ENTRAINEMENT DU MODELE ===
train:
	python train.py

# === GENERATION DU RAPPORT ET COMMENTAIRE CML ===
eval:
	@echo "## Model Metrics" > report.md
	@cat ./results/metrics.txt >> report.md
	@echo '\n## Confusion Matrix Plot' >> report.md
	@echo '![Confusion Matrix](./results/confusion_matrix.png)' >> report.md
	@cml comment create report.md


# === MISE À JOUR DE LA BRANCHE UPDATE ===
update-branch:
	git config --global user.name $(USER_NAME)
	git config --global user.email $(USER_EMAIL)
	git add model/ results/
	git commit -m "Update with new results and model" || echo "Rien à commit"
	git push --force origin HEAD:update


# === LOGIN HUGGING FACE ===
hf-login:
	git pull origin update
	git switch update
	pip install -U "huggingface_hub[cli]"
	huggingface-cli login --token $(HF_TOKEN) --add-to-git-credential


# === DEPOT DES FICHIERS SUR LE SPACE HUGGINGFACE ===
push-hub:
	# Push de l'application Gradio
	huggingface-cli upload Assoumana/breast-cancer-app ./app --repo-type=space --commit-message="Sync App files"

	# Push du modèle
	huggingface-cli upload Assoumana/breast-cancer-app ./model --repo-type=space --commit-message="Sync Model"

	# Push des résultats
	huggingface-cli upload Assoumana/breast-cancer-app ./results --repo-type=space --commit-message="Sync Results"


# === PIPELINE COMPLET DE DEPLOIEMENT ===
deploy: hf-login push-hub
