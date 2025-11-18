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
	#@cml comment create report.md

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
	pip install --upgrade huggingface_hub
	python -m huggingface_hub login $(HF_TOKEN)

# === DEPOT DES FICHIERS SUR LE SPACE HUGGINGFACE ===
push-hub:
	python -c "\
from huggingface_hub import upload_folder;\
upload_folder('app', repo_id='Assoumana/breast-cancer-app', path_in_repo='app', repo_type='space', commit_message='Sync App files');\
upload_folder('model', repo_id='Assoumana/breast-cancer-app', path_in_repo='model', repo_type='space', commit_message='Sync Model');\
upload_folder('results', repo_id='Assoumana/breast-cancer-app', path_in_repo='results', repo_type='space', commit_message='Sync Results');\
"

# === PIPELINE COMPLET DE DEPLOIEMENT ===
deploy: hf-login push-hub
