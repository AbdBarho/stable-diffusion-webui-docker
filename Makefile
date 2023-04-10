.PHONY: build start run stop restart refresh

# Build the docker container
#
# docker compose --profile download up --build
build:
	@docker compose --profile download up --build

# Start the docker container
#
# docker compose --profile [ui] up --build
# Where [ui] is one of: invoke | auto | auto-cpu | sygil | sygil-sl
# + invoke: One of the earliest forks, stunning UI Repo by InvokeAI
# + auto: The most popular fork, many features with neat UI, Repo by AUTOMATIC1111
# + auto-cpu: for users without a GPU.
# + sygil: Another great fork Repo by Sygil-Dev
# + sygil-sl: A second version of the above using streamlit (still in development, has bugs)
#
# docker compose --profile auto up -d
# Web UI: http://localhost:7860/
start:
	@docker compose --profile auto up -d

# Stop the docker container
stop:
	@docker compose --profile auto down

run: start

refresh: start

restart: stop start

shell:
	@docker exec -it $(shell docker ps -qf "name=auto") /bin/bash