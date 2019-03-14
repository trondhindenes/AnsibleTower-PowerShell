function Add-RelatedObject {
    param(
        $InputObject,
        $ItemType,
        $RelatedType,
        $RelationProperty,
        $RelationCommand,
        [Hashtable]$Cache = @{},
        [Switch]$PassThru
    )
    $Relations = Invoke-GetAnsibleInternalJsonResult -ItemType $ItemType -Id $InputObject.Id -ItemSubItem $RelatedType -AnsibleTower $InputObject.AnsibleTower
    foreach($Relation in $Relations) {
        Write-Debug "Adding $RelatedType $($Relation.Id) to $ItemType $($InputObject.Id)"
        $RelationKey = "$RelatedType/$($Relation.Id)"
        $RelatedObject = $InputObject.AnsibleTower.Cache.Get($RelationKey)
        if(!$RelatedObject) {
            $RelatedObject = &$RelationCommand -Id $Relation.Id -AnsibleTower $InputObject.AnsibleTower
            $InputObject.AnsibleTower.Cache.Add($RelationKey, $RelatedObject, $Script:CachePolicy)
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