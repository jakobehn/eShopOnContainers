Param(
    [parameter(Mandatory=$false)][string]$registry,
    [parameter(Mandatory=$false)][string]$imageTag
)

Write-Host "Deploying infrastructure..." -ForegroundColor Yellow
kubectl apply -f .\rabbitmq.yaml
kubectl apply -f .\basket-data.yaml
kubectl apply -f .\keystore-data.yaml
kubectl apply -f .\nosql-data.yaml
kubectl apply -f .\sql-data.yaml
kubectl apply -f .\frontend.yaml


Write-Host "Waiting for frontend's external ip..." -ForegroundColor Yellow
while ($true) {
    $frontendUrl = & kubectl get svc frontend -o=jsonpath="{.status.loadBalancer.ingress[0].ip}"
    if ([bool]($frontendUrl -as [ipaddress])) {
        break
    }
    Start-Sleep -s 5
}
$externalDns = $frontendUrl
Write-Host "Using $externalDns as the external DNS/IP of the k8s cluster" -ForegroundColor Yellow

Write-Host "Deploy config maps" -ForegroundColor Yellow
kubectl delete configmaps urls
kubectl create configmap urls `
    --from-literal=BasketUrl=http://basket `
    --from-literal=BasketHealthCheckUrl=http://basket/hc `
    --from-literal=CatalogUrl=http://$($externalDns)/catalog-api `
    --from-literal=CatalogHealthCheckUrl=http://catalog/hc `
    --from-literal=PicBaseUrl=http://$($externalDns)/catalog-api/api/v1/catalog/items/[0]/pic/ `
    --from-literal=Marketing_PicBaseUrl=http://$($externalDns)/marketing-api/api/v1/campaigns/[0]/pic/ `
    --from-literal=IdentityUrl=http://$($externalDns)/identity `
    --from-literal=IdentityHealthCheckUrl=http://identity/hc `
    --from-literal=OrderingUrl=http://ordering `
    --from-literal=OrderingHealthCheckUrl=http://ordering/hc `
    --from-literal=MvcClientExternalUrl=http://$($externalDns)/webmvc `
    --from-literal=WebMvcHealthCheckUrl=http://webmvc/hc `
    --from-literal=MvcClientOrderingUrl=http://ordering `
    --from-literal=MvcClientCatalogUrl=http://catalog `
    --from-literal=MvcClientBasketUrl=http://basket `
    --from-literal=MvcClientMarketingUrl=http://marketing `
	--from-literal=MvcClientLocationsUrl=http://locations `
    --from-literal=MarketingHealthCheckUrl=http://marketing/hc `
    --from-literal=LocationsHealthCheckUrl=http://locations/hc `
    --from-literal=LocationApiClient=http://$($externalDns)/locations-api `
    --from-literal=MarketingApiClient=http://$($externalDns)/marketing-api `
    --from-literal=BasketApiClient=http://$($externalDns)/basket-api `
    --from-literal=OrderingApiClient=http://$($externalDns)/ordering-api `
    --from-literal=PaymentHealthCheckUrl=http://payment/hc
	
kubectl label configmap urls app=eshop

Write-Host "Deploying configuration from externalcfg.yaml" -ForegroundColor Yellow
kubectl delete configmap externalcfg
kubectl create -f ./externalcfg.yaml

Write-Host "Deploying nginx config map" -ForegroundColor Yellow
kubectl delete configmap config-files
kubectl create configmap config-files --from-file=nginx-conf=nginx.conf
kubectl label configmap config-files app=eshop

Write-Host "Deploy application in paused state" -ForegroundColor Yellow
kubectl apply -f .\basket.yaml
kubectl apply -f .\identity.yaml
kubectl apply -f .\payment.yaml
kubectl apply -f .\locations.yaml
kubectl apply -f .\marketing.yaml
kubectl apply -f .\catalog.yaml
kubectl apply -f .\ordering.yaml
kubectl apply -f .\webmvc.yaml
kubectl apply -f .\webstatus.yaml

Write-Host "Update Image containers to use prefix '$registry' and tag '$imageTag'" -ForegroundColor Yellow

kubectl set image deployments/basket basket=${registry}/eshop/basket.api:$imageTag
kubectl set image deployments/catalog catalog=${registry}/eshop/catalog.api:$imageTag
kubectl set image deployments/identity identity=${registry}/eshop/identity.api:$imageTag
kubectl set image deployments/ordering ordering=${registry}/eshop/ordering.api:$imageTag
kubectl set image deployments/marketing marketing=${registry}/eshop/marketing.api:$imageTag
kubectl set image deployments/locations locations=${registry}/eshop/locations.api:$imageTag
kubectl set image deployments/payment payment=${registry}/eshop/payment.api:$imageTag
kubectl set image deployments/webmvc webmvc=${registry}/eshop/webmvc:$imageTag
kubectl set image deployments/webstatus webstatus=${registry}/eshop/webstatus:$imageTag

Write-Host "Resume rollout..." -ForegroundColor Yellow
kubectl rollout resume deployments/basket
kubectl rollout resume deployments/catalog
kubectl rollout resume deployments/identity
kubectl rollout resume deployments/marketing
kubectl rollout resume deployments/locations
kubectl rollout resume deployments/payment
kubectl rollout resume deployments/webmvc
kubectl rollout resume deployments/webstatus
kubectl rollout resume deployments/ordering


Write-Host "WebMVC at http://$externalDns/webmvc, WebStatus at http://$externalDns/webstatus" -ForegroundColor Yellow

