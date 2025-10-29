This uses Dockerfile and docker-compose.yml to run. To deploy, we use a docker image build and push. 

This is the overlay repo and a standardized template for many Ruby on Rails projects, where they use this base image, and then overlay their own app, tests, config, and db folder over this repo. So this is an extremely important repo for downstream users. 

To run any Ruby or Rails commands, it MUST be through docker commands, specifically `docker compose exec -it llamapress bin/rails ...` etc.

We never run Rails on the bare metal in this project.

Same with tests, they must be run through the docker container.