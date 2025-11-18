# === INSTALLATION DES PACKAGES PYTHON ===
install:
	pip install --upgrade pip
	pip install -r requirements.txt

# === FORMATAGE DU CODE ===
format:
	black *.py app/*.py

# === ENTRAINEMENT DU MODELE ===
train:
	python train.py

# === GENERATION DU RAPPORT ET COMMENTAIRE CML ===
eval:
	@echo "## Model Metrics" > report.md
	@cat ./results/metrics.txt >> report.md
	@echo '\n## Confusion Matrix Plot' >> report.md
	@echo '![Confusion Matrix](./results/confusion_matrix.png)' >> report.md
	# @cml comment create report.md   # Décommenter si CML est utilisé

# === MISE À JOUR DE LA BRANCHE UPDATE ===
update-branch:
	git config --global user.name $(USER_NAME)
	git config --global user.email $(USER_EMAIL)
	git add model/ results/
	git commit -am "Update with new results"
	git push --force origin HEAD:update

# === LOGIN HUGGING FACE ===
hf-login:
	pip install --upgrade huggingface_hub
	huggingface-cli login --token $(HF_TOKEN) --add-to-git-credential
	git pull origin update
	git switch update

# === DEPOT DES FICHIERS SUR LE SPACE HUGGINGFACE ===
push-hub:
	huggingface-cli upload Assoumana/breast-cancer-app ./app --repo-type=space --commit-message="Sync App files"
	huggingface-cli upload Assoumana/breast-cancer-app ./model --repo-type=space --commit-message="Sync Model"
	huggingface-cli upload Assoumana/breast-cancer-app ./results --repo-type=space --commit-message="Sync Results"

# === PIPELINE COMPLET DE DEPLOIEMENT ===
deploy: hf-login push-hub

# === PIPELINE TOTALE DU PROJET ===
all: install format train eval update-branch deploy