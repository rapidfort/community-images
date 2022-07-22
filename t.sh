

declare -a URLS=$(minikube service apache-release -n apache-a4f879e9d6 --url)

for url in "$URLS"; do

echo $url
echo "next"

done
