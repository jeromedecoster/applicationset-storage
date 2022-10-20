.SILENT:
.PHONY: storage test

help:
	{ grep --extended-regexp '^[a-zA-Z0-9_-]+:.*#[[:space:]].*$$' $(MAKEFILE_LIST) || true; } \
	| awk 'BEGIN { FS = ":.*#[[:space:]]*" } { printf "\033[1;32m%-22s\033[0m%s\n", $$1, $$2 }'

env-create: # 1) create .env file + install semver-cli
	./make.sh env-create

terraform-init: # 2) terraform init (updgrade) + validate
	./make.sh terraform-init
	
terraform-create: # 2) terraform create s3 bucket + ecr repo + iam user + setup .env file
	./make.sh terraform-create
	
storage: # 3) run storage server using npm - dev mode
	./make.sh storage

test: # 3) test storage
	./make.sh test

dev-build: # 4) build storage-dev image
	./make.sh dev-build

dev-run: # 4) run storage-dev image
	./make.sh dev-run

dev-stop: # 4) stop storage-dev container
	./make.sh dev-stop

prod-build: # 4) build storage image
	./make.sh prod-build

prod-run: # 4) run storage image
	./make.sh prod-run

prod-stop: # 4) stop storage container
	./make.sh prod-stop

update-patch: # 4) update patch version
	./make.sh update-patch

ecr-push: # 5) push storage image to ecr
	./make.sh ecr-push

ecr-run: # 5) run latest image pushed to ecr
	./make.sh ecr-run

increase-build-push: # 5) update-patch + ecr-push
	./make.sh increase-build-push

terraform-destroy: # 6) terraform destroy s3 bucket + ecr repo + iam user
	./make.sh terraform-destroy

clear: # 6) clear docker images
	./make.sh clear
