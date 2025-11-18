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

hf-login:
	pip install -U huggingface_hub
	git pull origin update
	git switch update
	python -m huggingface_hub.login --token $(HF_TOKEN) --add-to-git-credential

push-hub:
	python -m huggingface_hub.upload_file --repo_id Assoumana/breast-cancer-app --repo_type space --path app --path_in_repo app --commit_message "Sync App files"
	python -m huggingface_hub.upload_file --repo_id Assoumana/breast-cancer-app --repo_type space --path model --path_in_repo model --commit_message "Sync Model"
	python -m huggingface_hub.upload_file --repo_id Assoumana/breast-cancer-app --repo_type space --path results --path_in_repo results --commit_message "Sync Results"

deploy: hf-login push-hub

all: install format train eval update-branch deploy
