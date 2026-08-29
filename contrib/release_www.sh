#!/bin/bash
#
# env vars:
# - WWW_DIR: path to "bedrock-web" git clone
# - for signing the version announcement file:
#   - BEDROCK_SIGNING_ADDRESS (required)
#   - BEDROCK_SIGNING_WALLET (required)
#

set -e

PROJECT_ROOT="$(dirname "$(readlink -e "$0")")/.."
CONTRIB="$PROJECT_ROOT/contrib"

cd "$PROJECT_ROOT"

. "$CONTRIB"/build_tools_util.sh


echo -n "Remember to run add_cosigner to add any additional sigs.  Continue (y/n)? "
read answer
if [ "$answer" != "y" ]; then
    echo "exit"
    exit 1
fi


if [ -z "$WWW_DIR" ] ; then
    WWW_DIR=/opt/bedrock-web
fi

if [ -z "$BEDROCK_SIGNING_WALLET" ] || [ -z "$BEDROCK_SIGNING_ADDRESS" ]; then
    echo "You need to set env vars BEDROCK_SIGNING_WALLET and BEDROCK_SIGNING_ADDRESS!"
    exit 1
fi

VERSION=$("$CONTRIB"/print_bedrock_version.py)
info "VERSION: $VERSION"

ANDROID_VERSIONCODE_NULLARCH=$("$CONTRIB"/android/get_apk_versioncode.py "null")
# ^ note: should parse as an integer in the final json
info "ANDROID_VERSIONCODE_NULLARCH: $ANDROID_VERSIONCODE_NULLARCH"

set -x

info "updating www repo"
./contrib/make_download "$WWW_DIR"
info "signing the version announcement file"
sig=$(./run_bedrock -o signmessage "$BEDROCK_SIGNING_ADDRESS" "$VERSION" -w "$BEDROCK_SIGNING_WALLET")
# note: the contents of "extradata" are currently not signed. We could add another field, extradata_sigs,
#       containing signature(s) for "extradata". extradata, being json, would have to be canonically
#       serialized before signing.
cat <<EOF > "$WWW_DIR"/version
{
    "version": "$VERSION",
    "signatures": {"$BEDROCK_SIGNING_ADDRESS": "$sig"},
    "extradata": {
        "android_versioncode_nullarch": $ANDROID_VERSIONCODE_NULLARCH
    }
}
EOF

# push changes to website repo
pushd "$WWW_DIR"
git diff
git commit -a -m "version $VERSION"
git push
popd


info "release_www.sh finished successfully."
info "now you should run WWW_DIR/publish.sh to sign the website commit and upload signature"
