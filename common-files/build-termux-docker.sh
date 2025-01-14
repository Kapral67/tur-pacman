#!/bin/sh
set -e -u

: ${TERMUX_BUILDER_IMAGE_NAME:=ghcr.io/termux-user-repository/termux-docker-android-7:$ARCH}
: ${CONTAINER_NAME:=termux-$ARCH}

CONTAINER_HOME_DIR=/data/data/com.termux/files/home
REPOROOT="$(dirname $(readlink -f $0))/../"

# Check whether attached to tty and adjust docker flags accordingly.
if [ -t 1 ]; then
	echo 'YES TTY'
	DOCKER_TTY=" --tty"
else
	echo 'NO TTY'
	DOCKER_TTY=""
fi

if [ -n "${TERMUX_DOCKER_USE_SUDO-}" ]; then
	SUDO="sudo"
else
	SUDO=""
fi

echo "Running container '$CONTAINER_NAME' from image '$TERMUX_BUILDER_IMAGE_NAME'..."

$SUDO docker start $CONTAINER_NAME >/dev/null 2>&1 || {
	echo "Creating new container..."
	$SUDO docker run \
		--detach \
		--name $CONTAINER_NAME \
		--network=host \
		--volume $REPOROOT:$CONTAINER_HOME_DIR/termux-packages \
		--security-opt seccomp=unconfined \
		--tty \
		-w $CONTAINER_HOME_DIR/termux-packages \
		$TERMUX_BUILDER_IMAGE_NAME
}

echo "Running existing container..."

if [ "$#" -eq "0" ]; then
	echo "bash"
	$SUDO docker exec --interactive $DOCKER_TTY $CONTAINER_NAME bash
else
	echo '$@'
	$SUDO docker exec --interactive $DOCKER_TTY $CONTAINER_NAME "$@"
fi

echo "FIN"
