PKG_VERSION=4.2.0
PKG_REL_PREFIX=1hn1
ifdef NO_CACHE
DOCKER_NO_CACHE=--no-cache
endif
LUAJIT_DEB_VERSION=2.1.20240815-1hn1
MOSECURITY_DEB_VERSION=3.0.13-1hn1

LOGUNLIMITED_BUILDER=logunlimited

# Ubuntu 24.04
deb-ubuntu2404: build-ubuntu2404
	docker run --rm -v ./wrk-${PKG_VERSION}-${PKG_REL_PREFIX}ubuntu24.04:/dist wrk-ubuntu2404 bash -c \
	"cp /src/*${PKG_VERSION}* /dist/"
	sudo tar zcf wrk-${PKG_VERSION}-${PKG_REL_PREFIX}ubuntu24.04.tar.gz ./wrk-${PKG_VERSION}-${PKG_REL_PREFIX}ubuntu24.04/

build-ubuntu2404: buildkit-logunlimited
	sudo mkdir -p wrk-${PKG_VERSION}-${PKG_REL_PREFIX}ubuntu24.04
	PKG_REL_DISTRIB=ubuntu24.04; \
	(set -x; \
	git config -l | sed -n '/^submodule\.[^.]*\.url/{s|^submodule\.||;s|\.url=|=|;p}' | sort; \
	git submodule status; \
	docker buildx build --progress plain --builder ${LOGUNLIMITED_BUILDER} --load \
		${DOCKER_NO_CACHE} \
		--build-arg OS_TYPE=ubuntu --build-arg OS_VERSION=24.04 \
		--build-arg PKG_REL_DISTRIB=$${PKG_REL_DISTRIB} \
		--build-arg PKG_VERSION=${PKG_VERSION} \
		--build-arg LUAJIT_DEB_VERSION=${LUAJIT_DEB_VERSION} \
		--build-arg LUAJIT_DEB_OS_ID=ubuntu24.04 \
		--build-arg MODSECURITY_DEB_VERSION=${MOSECURITY_DEB_VERSION} \
		--build-arg MODSECURITY_DEB_OS_ID=ubuntu24.04 \
		-t wrk-ubuntu2404 . \
	) 2>&1 | sudo tee wrk-${PKG_VERSION}-${PKG_REL_PREFIX}ubuntu24.04/wrk_${PKG_VERSION}-${PKG_REL_PREFIX}${PKG_REL_DISTRIB}.build.log && \
	sudo xz --force wrk-${PKG_VERSION}-${PKG_REL_PREFIX}ubuntu24.04/wrk_${PKG_VERSION}-${PKG_REL_PREFIX}${PKG_REL_DISTRIB}.build.log

run-ubuntu2404:
	docker run --rm -it wrk-ubuntu2404 bash

# Ubuntu 22.04
deb-ubuntu2204: build-ubuntu2204
	docker run --rm -v ./wrk-${PKG_VERSION}-${PKG_REL_PREFIX}ubuntu22.04:/dist wrk-ubuntu2204 bash -c \
	"cp /src/*${PKG_VERSION}* /dist/"
	sudo tar zcf wrk-${PKG_VERSION}-${PKG_REL_PREFIX}ubuntu22.04.tar.gz ./wrk-${PKG_VERSION}-${PKG_REL_PREFIX}ubuntu22.04/

build-ubuntu2204: buildkit-logunlimited
	sudo mkdir -p wrk-${PKG_VERSION}-${PKG_REL_PREFIX}ubuntu22.04
	PKG_REL_DISTRIB=ubuntu22.04; \
	(set -x; \
	git config -l | sed -n '/^submodule\.[^.]*\.url/{s|^submodule\.||;s|\.url=|=|;p}' | sort; \
	git submodule status; \
	docker buildx build --progress plain --builder ${LOGUNLIMITED_BUILDER} --load \
		${DOCKER_NO_CACHE} \
		--build-arg OS_TYPE=ubuntu --build-arg OS_VERSION=22.04 \
		--build-arg PKG_REL_DISTRIB=$${PKG_REL_DISTRIB} \
		--build-arg PKG_VERSION=${PKG_VERSION} \
		--build-arg LUAJIT_DEB_VERSION=${LUAJIT_DEB_VERSION} \
		--build-arg LUAJIT_DEB_OS_ID=ubuntu22.04 \
		--build-arg MODSECURITY_DEB_VERSION=${MOSECURITY_DEB_VERSION} \
		--build-arg MODSECURITY_DEB_OS_ID=ubuntu22.04 \
		-t wrk-ubuntu2204 . \
	) 2>&1 | sudo tee wrk-${PKG_VERSION}-${PKG_REL_PREFIX}ubuntu22.04/wrk_${PKG_VERSION}-${PKG_REL_PREFIX}${PKG_REL_DISTRIB}.build.log && \
	sudo xz --force wrk-${PKG_VERSION}-${PKG_REL_PREFIX}ubuntu22.04/wrk_${PKG_VERSION}-${PKG_REL_PREFIX}${PKG_REL_DISTRIB}.build.log

run-ubuntu2204:
	docker run --rm -it wrk-ubuntu2204 bash

buildkit-logunlimited:
	if ! docker buildx inspect logunlimited 2>/dev/null; then \
		docker buildx create --bootstrap --name ${LOGUNLIMITED_BUILDER} \
			--driver-opt env.BUILDKIT_STEP_LOG_MAX_SIZE=-1 \
			--driver-opt env.BUILDKIT_STEP_LOG_MAX_SPEED=-1; \
	fi

exec:
	docker exec -it $$(docker ps -q) bash

.PHONY: deb-debian12 run-debian12 build-debian12 deb-ubuntu2204 run-ubuntu2204 build-ubuntu2204 buildkit-logunlimited exec
