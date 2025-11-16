# Installer les packages Python
install:
	pip install --upgrade pip &&\
	pip install -r requirements.txt

# Formater le code avec Black
format:
	black *.py

# Entraîner le modèle
train:
	python train.py

# Générer le rapport d'évaluation et commenter avec CML
eval:
	@echo "## Model Metrics" > report.md
	@cat ./results/classification_report.json >> report.md
	@echo '\n## Confusion Matrix Plot' >> report.md
	@echo '![Confusion Matrix](./results/confusion_matrix.png)' >> report.md
	@cml comment create report.md
# Mettre à jour la branche 'update' avec les résultats et le modèle
update-branch:
	git config --global user.name $(USER_NAME)
	git config --global user.email $(USER_EMAIL)
	git add model/ results/
	git commit -m "Update with new results and model"
	git push --force origin HEAD:update
