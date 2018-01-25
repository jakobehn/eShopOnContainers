Param(
    [parameter(Mandatory=$false)][string]$registryFDQN,
    [parameter(Mandatory=$false)][string]$dockerUser,
    [parameter(Mandatory=$false)][string]$dockerPassword
)

# create registry key secret
kubectl create secret docker-registry registry-key `
    --docker-server=$registryFDQN `
    --docker-username=$dockerUser `
    --docker-password=$dockerPassword `
    --docker-email=not@used.com