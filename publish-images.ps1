Param(
    [parameter(Mandatory=$false)][string]$registry,
    [parameter(Mandatory=$false)][string]$imageTag
)

$eshopImage = $registry + '/eshop/webmvc' + ':' + $imageTag
$webstatusImage = $registry + '/eshop/webstatus' + ':' + $imageTag
$orderingImage = $registry + '/eshop/ordering.api' + ':' + $imageTag
$catalogImage = $registry + '/eshop/catalog.api' + ':' + $imageTag
$marketingImage = $registry + '/eshop/marketing.api' + ':' + $imageTag
$identityImage = $registry + '/eshop/identity.api' + ':' + $imageTag
$paymentImage = $registry + '/eshop/payment.api' + ':' + $imageTag
$basketImage = $registry + '/eshop/basket.api' + ':' + $imageTag
$locationsImage = $registry + '/eshop/locations.api' + ':' + $imageTag

docker tag 'eshop/webmvc' $eshopImage ; docker push $eshopImage
docker tag 'eshop/webstatus' $webstatusImage ; docker push $webstatusImage
docker tag 'eshop/ordering.api' $orderingImage ; docker push $orderingImage
docker tag 'eshop/catalog.api' $catalogImage ; docker push $catalogImage
docker tag 'eshop/marketing.api' $marketingImage ; docker push $marketingImage
docker tag 'eshop/identity.api' $identityImage ; docker push $identityImage
docker tag 'eshop/payment.api' $paymentImage ; docker push $paymentImage
docker tag 'eshop/basket.api' $basketImage ; docker push $basketImage
docker tag 'eshop/locations.api' $locationsImage ; docker push $locationsImage

