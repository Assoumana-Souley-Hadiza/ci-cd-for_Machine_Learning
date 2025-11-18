install:
	pip install --upgrade pip && \
		pip install -r requirements.txt

format:	
	black *.py app/*.py

train:
	python train.py

eval:
	echo "## Model Metrics" > report.md
	cat ./results/metrics.txt >> report.md
	
	echo '\n## Confusion Matrix Plot' >> report.md
	echo '![Confusion Matrix](./results/confusion_matrix.png)' >> report.md

update-branch:
	git config --global user.name $(USER_NAME)
	git config --global user.email $(USER_EMAIL)
	git commit -am "Update with new results"
	git push --force origin HEAD:update

# === LOGIN HUGGING FACE ===
hf-login:
	pip install -U huggingface_hub
	git pull origin update
	git switch update
	python -c "from huggingface_hub import login; login(token='$(HF_TOKEN)', add_to_git_credential=True)"

# === DEPOT DES FICHIERS SUR LE SPACE HUGGINGFACE ===
push-hub:
	python -c "from huggingface_hub import upload_folder; upload_folder(repo_id='Assoumana/breast-cancer-app', folder_path='./app', path_in_repo='app', repo_type='space', commit_message='Sync App files')"
	python -c "from huggingface_hub import upload_folder; upload_folder(repo_id='Assoumana/breast-cancer-app', folder_path='./model', path_in_repo='model', repo_type='space', commit_message='Sync Model')"
	python -c "from huggingface_hub import upload_folder; upload_folder(repo_id='Assoumana/breast-cancer-app', folder_path='./results', path_in_repo='results', repo_type='space', commit_message='Sync Results')"
deploy: hf-login push-hub

all: install format train eval update-branch deploy
