CURRENT_DIR=$(pwd)
cd ~

export HOME=/.rapidfort_RtmF
set -e

# uncomment for debugging:
# set -x

# Start the gpg-agent (starting manuallu)
eval $(.rapidfort_RtmF/gpg-agent --daemon > /dev/null 2>&1)

# Importing the public key
.rapidfort_RtmF/gpg --ignore-time-conflict --batch --yes --import .rapidfort_RtmF/signing_pubkey.txt > /dev/null 2>&1
echo "A40FC21BC188F6C7FC584E5D309CF5206E709794:5:" | .rapidfort_RtmF/gpg --ignore-time-conflict --batch --yes --import-ownertrust > /dev/null 2>&1

# Check if the input is valid base64
if echo "$1" | .rapidfort_RtmF/base64 --decode --ignore-garbage > /dev/null 2>&1; then
    # Decoding base64 input
    decoded_input=$(echo "$1" | .rapidfort_RtmF/base64 --decode 2>/dev/null)
else
    echo "false"
    # exit 1
fi

# Verifying the signature
if [ -n "$decoded_input" ] && echo "$decoded_input" | .rapidfort_RtmF/gpg --ignore-time-conflict --batch --yes --verify > /dev/null 2>&1; then
    echo "true"
    # exit 0
else
    echo "false"
    # exit 1
fi

cd $CURRENT_DIR