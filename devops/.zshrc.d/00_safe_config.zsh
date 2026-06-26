alias k=kubectl
alias kns='kubectl config set-context --current --namespace '
alias kall='kubectl api-resources --verbs=list --namespaced -o name | xargs -n 1 kubectl get --show-kind --ignore-not-found' # add -n <namespace>

# useful devops commands
# shell into container:
# kubectl exec -it <pod> [-c <container>] -- sh
# kubectl debug -it debugcontainer --image=busybox:1.28 --target=<pod>
# kubectl debug myapp -it --image=debugcontainerimage --share-processes --copy-to=myapp-debug

# stop and delete docker containers by their image id
dsi() { docker stop $(docker ps -a | awk -v i="^$1.*" '{if($2~i){print$1}}'); }
drmi() { docker rm $(dsi $1  | tr '\n' ' '); }
