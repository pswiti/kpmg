function global:getKey($obj)
{
    $keys = $obj.Keys
    if($keys.Count -ne 1)
    {
        throw "Either multiple keys or empty dict found"
    }
    else
    {
        return $keys[0]
    }
}

function getNestedValue($obj,$key,$isfound=$false)
{
   $type = $obj.GetType()
   if(($type.Name -ne "Hashtable") -And (-not $isfound))
   {
    return $null
   }

   if($isfound -or $obj.ContainsKey($key))
   {
        if($obj[$key].GetType().Name -eq "Hashtable")
        {
            $temp_key = getKey $obj[$key]
            return getNestedValue $obj[$key] $temp_key $true
        }
        else
        {
            $temp_key = getKey $obj
            return $obj[$temp_key]
        }    
    }
    else
    {
        $nestedKey = getKey $obj
        return getNestedValue $obj[$nestedKey] $key $false
    }
}

$obj = @{ "a" = @{ "b" = @{"c" = "d"}}}

$value = getNestedValue $obj "c"
echo $value
