#!/bin/bash

QUIET_ARG=""
[ "$1" == "--quiet" ] && QUIET_ARG="--quiet"

# Enter source directory
cd $( dirname $0 )

echo "Clean previous build..."
rm -fr dist

echo "Detect version using git describe..."
VERSION="$( git describe --tags|sed 's/^[^0-9]*//' )"

echo "Create building environemt..."
BDIR=dist/check-syncrepl-extended-$VERSION
mkdir -p $BDIR
[ -z "$QUIET_ARG" ] && RSYNC_ARG="-v" || RSYNC_ARG=""
rsync -a $RSYNC_ARG debian/ $BDIR/debian/
cp check_syncrepl_extended $BDIR/

echo "Set VERSION=$VERSION in gitdch using sed..."
sed -i "s/^VERSION *=.*$/VERSION = '$VERSION'/" $BDIR/check_syncrepl_extended

if [ -z "$DEBIAN_CODENAME" ]
then
	echo "Retreive debian codename using lsb_release..."
	DEBIAN_CODENAME=$( lsb_release -c -s )
else
	echo "Use debian codename from environment ($DEBIAN_CODENAME)"
fi

echo "Generate debian changelog using gitdch..."
GITDCH_ARGS=('--verbose')
[ -n "$QUIET_ARG" ] && GITDCH_ARGS=('--warning')
if [ -n "$MAINTAINER_NAME" ]
then
	echo "Use maintainer name from environment ($MAINTAINER_NAME)"
	GITDCH_ARGS+=("--maintainer-name" "${MAINTAINER_NAME}")
fi
if [ -n "$MAINTAINER_EMAIL" ]
then
	echo "Use maintainer email from environment ($MAINTAINER_EMAIL)"
	GITDCH_ARGS+=("--maintainer-email" "$MAINTAINER_EMAIL")
fi
gitdch \
	--package-name check-syncrepl-extended \
	--version "${VERSION}" \
	--code-name $DEBIAN_CODENAME \
	--output $BDIR/debian/changelog \
	--release-notes dist/release_notes.md \
	"${GITDCH_ARGS[@]}"

if [ -n "$MAINTAINER_NAME" -a -n "$MAINTAINER_EMAIL" ]
then
	echo "Set Maintainer field in debian control file ($MAINTAINER_NAME <$MAINTAINER_EMAIL>)..."
	sed -i "s/^Maintainer: .*$/Maintainer: $MAINTAINER_NAME <$MAINTAINER_EMAIL>/" $BDIR/debian/control
fi

echo "Build debian package..."
cd $BDIR
dpkg-buildpackage
