all:

cron: pull etag check

I=	public.ecr.aws/lambda/provided
pull:
	@docker pull $(I):al2 > .log-al2
	@docker image inspect $(I):al2 | jq -r '.[0].Id' > .id-provided-al2

etag:
	@curl -s -D- --head HEAD https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip | \
	grep ^ETag | uniq | sed -e 's|^ETag: ||' | jq -r . > .etag-awscli

check:
	@if git status -s | grep -q M; then\
		date=`date +%Y%m%d`; \
		git add .etag-awscli .id-provided-* && git commit -m "Update IDs ($$date)."; git push;\
	fi

test:
	sed -e 's|%%VER%%|al2|' Dockerfile.tmpl > Dockerfile
	docker build -t aws-lambda-provided-awscli:latest .
	rm -f Dockerfile
