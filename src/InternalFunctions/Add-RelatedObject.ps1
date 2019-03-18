function Add-RelatedObject {
    param(
        $InputObject,
        $ItemType,
        $RelatedType,
        $RelationProperty,
        $RelationCommand,
        [Switch]$PassThru
    )
    $Relations = Invoke-GetAnsibleInternalJsonResult -ItemType $ItemType -Id $InputObject.Id -ItemSubItem $RelatedType -AnsibleTower $InputObject.AnsibleTower
    foreach($Relation in $Relations) {
        Write-Debug "[Add-RelatedObject] Adding $RelatedType $($Relation.Id) to $ItemType $($InputObject.Id)"
        $RelationKey = "$RelatedType/$($Relation.Id)"
        $RelatedObject = $InputObject.AnsibleTower.Cache.Get($RelationKey)
        if(!$RelatedObject) {
            Write-Debug "[Add-RelatedObject] Looking up $($Relation.Id) using $($RelationCommand)"
            $RelatedObject = &$RelationCommand -Id $Relation.Id -AnsibleTower $InputObject.AnsibleTower
            Write-Debug "[Add-RelatedObject] Caching $($RelatedObject.Url) as $RelationKey"
            $InputObject.AnsibleTower.Cache.Add($RelationKey, $RelatedObject, $Script:CachePolicy) > $null
        }
        if(!$InputObject."$RelationProperty") {
            $InputObject."$RelationProperty" = $RelatedObject
        } else {
            $InputObject."$RelationProperty".Add($RelatedObject)
        }
    }
    if($PassThru) {
        $InputObject
    }
}