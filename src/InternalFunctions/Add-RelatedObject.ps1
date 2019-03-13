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
        if(!$Cache.ContainsKey($Relation.Id)) {
            $Cache[$Relation.Id] = &$RelationCommand -Id $Relation.Id -AnsibleTower $InputObject.AnsibleTower
        }
        $RelatedObject = $Cache[$Relation.Id]
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