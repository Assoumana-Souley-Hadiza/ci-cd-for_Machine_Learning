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
	pip install -U "huggingface_hub[cli]"
	git pull origin update
	git switch update
	python -m huggingface_hub.cli.login --token $(HF_TOKEN) --add-to-git-credential

push-hub:
	python -m huggingface_hub.cli.upload Assoumana/breast-cancer-app ./app --repo-type=space --commit-message="Sync App files"
	python -m huggingface_hub.cli.upload Assoumana/breast-cancer-app ./model --repo-type=space --commit-message="Sync Model"
	python -m huggingface_hub.cli.upload Assoumana/breast-cancer-app ./results --repo-type=space --commit-message="Sync Results"

deploy: hf-login push-hub

all: install format train eval update-branch deploy
