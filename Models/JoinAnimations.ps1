#Add-Type -Path .\MathNet.Numerics.4.7.0\lib\net40\MathNet.Numerics.dll
#[psobject].Assembly.GetType("System.Management.Automation.TypeAccelerators")::Add('M','MathNet.Numerics.LinearAlgebra.Matrix[Double]')
#[psobject].Assembly.GetType("System.Management.Automation.TypeAccelerators")::Add('V','MathNet.Numerics.LinearAlgebra.Double.DenseVector')

$paramFile = $args[0]
$outputFile = $args[1]
$rootRotation = $args[2]

function Convert-XmlElementToString
{
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)]
        $xml
    )

    $sw = [System.IO.StringWriter]::new()
    $xmlSettings = [System.Xml.XmlWriterSettings]::new()
    $xmlSettings.ConformanceLevel = [System.Xml.ConformanceLevel]::Fragment
    $xmlSettings.Indent = $true
    $xw = [System.Xml.XmlWriter]::Create($sw, $xmlSettings)
    $xml.WriteTo($xw)
    $xw.Close()
    return $sw.ToString()
}

if(Test-Path $paramFile)
{
    $hipsName = ""
    $pathString = Split-Path -Path $paramFile;
    $workDir = (Get-ChildItem -Path $pathString);
    $mainFile = Split-Path $paramFile -leaf;

    $xml = [xml](Get-Content (Join-Path $pathString $mainFile) -Raw);
    $ns = New-Object System.Xml.XmlNamespaceManager($xml.NameTable)
    $ns.AddNamespace("ns", $xml.DocumentElement.NamespaceURI)
    $animationNode = $xml.SelectSingleNode("//ns:library_animations", $ns)

    $animClipsNode = $xml.CreateElement("library_animation_clips");

    foreach($file in $workDir)
    {
        if($file.Extension.ToUpper() -eq ".DAE")
        {
            $newClip = $xml.CreateElement("animation_clip");
            $newClip.SetAttribute("id", $file.BaseName);
            
            [float]$clipStartTime = 0.0;
            [float]$clipEndTime = 0.0;

            if( $file.name -ne $mainFile)
            {
                $newxml = [xml](Get-Content (Join-Path $pathString $file.name ) -Raw);
                $ns1 = New-Object System.Xml.XmlNamespaceManager($newxml.NameTable)
                $ns1.AddNamespace("ns", $newxml.DocumentElement.NamespaceURI)
                $newNode = $newxml.SelectSingleNode("//ns:library_animations", $ns1)
                $newNode.SetAttribute("id", $file.BaseName);

                
                $hips_animations = $newNode.SelectSingleNode("ns:animation[contains(@id,'Hips')]", $ns1);
                $hipsName = $hips_animations.GetAttribute("name")
                $root_doc_animation = $hips_animations.Clone();

                $transforms_node = $hips_animations.SelectSingleNode(".//ns:float_array[contains(@id,'output')]", $ns1);
                $transforms_node_root = $root_doc_animation.SelectSingleNode(".//ns:float_array[contains(@id,'output')]", $ns1);
                
                $num_keys = [int]$transforms_node.GetAttribute("count") / 16;
                $keys_hips = $transforms_node.innerText.Trim() -split '\s+|\r\n';
                $keys_root = $transforms_node_root.innerText.Trim() -split '\s+|\r\n';

                if($rootRotation -eq "root_rotation")
                {
                    $transforms_node.InnerText = "";
                    $transforms_node_root.InnerText = "";

                    for($keycount =0; $keycount -lt $num_keys; $keycount++)
                    {
                        [Double[]]$data = @($keys_hips[($keycount*16) + 0], $keys_hips[($keycount*16) + 4], $keys_hips[($keycount*16) + 8], $keys_hips[($keycount*16) + 12],
                        $keys_hips[($keycount*16) + 1], $keys_hips[($keycount*16) + 5], $keys_hips[($keycount*16) + 9], $keys_hips[($keycount*16) + 13],
                        $keys_hips[($keycount*16) + 2], $keys_hips[($keycount*16) + 6], $keys_hips[($keycount*16) + 10], $keys_hips[($keycount*16) + 14],
                        $keys_hips[($keycount*16) + 3], $keys_hips[($keycount*16) + 7], $keys_hips[($keycount*16) + 11], $keys_hips[($keycount*16) + 15]);
                        $mtx = [M]::Build.DenseOfColumnMajor(4,4, $data);
                        [Double[]]$arr_basis_z = @($mtx.At(0,2),$mtx.At(1,2),$mtx.At(2,2));
                        [Double[]]$arr_basis_z_origin = @(0,0,1);

                        $basisZ = [V]::Build.Dense($arr_basis_z);
                        $basisZorigin = [V]::Build.Dense($arr_basis_z_origin);

                        $rotationCos = $basisZorigin.DotProduct($basisZ);
                        [double]$rotY = 0.0;
                        if ($rotationCos -gt -1.0 -and $rotationCos -lt 1.0)
                        {
                            $rotY = [math]::Acos($rotationCos);
                        }
                        elseif ($rotationCos -lt 0.0)
                        {
                            $rotY = [math]::Pi;
                        }

                        #Write-Output $rotY;

                        [Double[]] $mtxTemp = @( [math]::Cos($rotY), 0, -[math]::Sin($rotY),
                                                    0,1,0,
                                                [math]::Sin($rotY), 0, [math]::Cos($rotY) );
                        $mtxRotY =[M]::Build.DenseOfColumnMajor(3,3,$mtxTemp);

                        $rotY = -$rotY

                        [Double[]] $mtxTemp = @( [math]::Cos($rotY), 0, -[math]::Sin($rotY),
                                                    0,1,0,
                                                [math]::Sin($rotY), 0, [math]::Cos($rotY) );
                        $mtxRotYCounter =[M]::Build.DenseOfColumnMajor(3,3,$mtxTemp);


                        [Double[]]$data = @($mtxRotY.At(0,0), $mtxRotY.At(1,0), $mtxRotY.At(2,0), 0,
                                            $mtxRotY.At(0,1), $mtxRotY.At(1,1), $mtxRotY.At(2,1), 0,
                                            $mtxRotY.At(0,2), $mtxRotY.At(1,2), $mtxRotY.At(2,2), 0,
                                            $mtx.At(0,3), 0, $mtx.At(2,3), 1);
                        $mtx_root_rotation = [M]::Build.DenseOfColumnMajor(4,4, $data);

                        #XZ rotation
                        $mtxRotY = $mtxRotYCounter * $mtx.SubMatrix(0,3,0,3);

                        [Double[]]$data = @($mtxRotY.At(0,0), $mtxRotY.At(1,0), $mtxRotY.At(2,0), 0,
                                            $mtxRotY.At(0,1), $mtxRotY.At(1,1), $mtxRotY.At(2,1), 0,
                                            $mtxRotY.At(0,2), $mtxRotY.At(1,2), $mtxRotY.At(2,2), 0,
                                            0, $mtx.At(1,3), 0, 1);
                        $mtx_hip_rotation = [M]::Build.DenseOfColumnMajor(4,4, $data);

                        $transforms_node.InnerText += "$mtx_hip_rotation".Replace("DenseMatrix 4x4-Double", "");
                        $transforms_node_root.InnerText += "$mtx_root_rotation".Replace("DenseMatrix 4x4-Double", "");
                        #Write-Output "$mtx_root_rotation";#[0,0];
                        #Write-Output "$mtx_hip_rotation";#[0,0];
                    }
                }
                else
                {
                    for($keycount =0; $keycount -lt $num_keys; $keycount++)
                    {
                        #Set identity matrix, except for XZ translation
                        $keys_root[($keycount*16) + 0] = "1.000000";
                        $keys_root[($keycount*16) + 1] = "0.000000";
                        $keys_root[($keycount*16) + 2] = "0.000000";
                        #$keys_root[($keycount*16) + 3] = "0.000000";

                        $keys_root[($keycount*16) + 4] = "0.000000";
                        $keys_root[($keycount*16) + 5] = "1.000000";
                        $keys_root[($keycount*16) + 6] = "0.000000";
                        $keys_root[($keycount*16) + 7] = "0.000000";

                        $keys_root[($keycount*16) + 8] = "0.000000";
                        $keys_root[($keycount*16) + 9] = "0.000000";
                        $keys_root[($keycount*16) + 10] = "1.000000";
                        #$keys_root[($keycount*16) + 11] = "0.000000";

                        $keys_root[($keycount*16) + 12] = "0.000000";
                        $keys_root[($keycount*16) + 13] = "0.000000";
                        $keys_root[($keycount*16) + 14] = "0.000000";
                        $keys_root[($keycount*16) + 15] = "1.000000";

                        #Clean XZ translation
                        $keys_hips[($keycount*16) + 3] = "0.000000";
                        $keys_hips[($keycount*16) + 11] = "0.000000";
                    }
                    $transforms_node.InnerText = "$keys_hips";
                    $transforms_node_root.InnerText = "$keys_root";
                }

                $parsed_node = Convert-XmlElementToString $root_doc_animation;
                $parsed_node = $parsed_node -replace $hipsName, "root_doc"
                $new_node = [xml]$parsed_node;
                $newNode.InsertBefore($newxml.ImportNode($new_node.animation,$true) , $hips_animations);

                $animationNodes = $newNode.SelectNodes("ns:animation", $ns1);
                foreach($aninNode in $animationNodes)
                {

                    $inputNode = $aninNode.SelectSingleNode("//ns:input[@semantic='INPUT']", $ns1)
                    if($inputNode)
                    {
                        $nameArray = $inputNode.GetAttribute("source").Substring(1);
                        $toFind = "//ns:source[@id='" + $nameArray + "']/ns:float_array";
                        $timeArray = $aninNode.SelectSingleNode($toFind, $ns1);
                        if($timeArray)
                        {
                            $times = $timeArray.innerText.Trim() -split '\s+|\r\n';
                            $newTime = [float]$times[-1];
                            if($newTime -gt $clipEndTime)
                            {
                                $clipEndTime = $newTime;
                            }
                        }

                    }
                    $aninNode.SetAttribute("id", $aninNode.GetAttribute("id") + "_" +  $file.BaseName);
                    #select all the source, float_array, Name_array and sampler nodes to change de ID
                    $sourceNodes = $aninNode.SelectNodes(".//ns:source | .//ns:float_array | .//ns:sampler | .//ns:Name_array", $ns1);
                    foreach($souceNode in $sourceNodes)
                    {
                        $souceNode.SetAttribute("id", $souceNode.GetAttribute("id") + "_" +  $file.BaseName);
                    }
                    #select all the accessor, channel and input nodes to change the source
                    $accesorNodes = $aninNode.SelectNodes(".//ns:accessor | .//ns:channel | .//ns:input", $ns1);
                    foreach($accNode in $accesorNodes)
                    {
                        $accNode.SetAttribute("source", $accNode.GetAttribute("source") + "_" +  $file.BaseName);
                    }
                    $intanceAnimation = $xml.CreateElement("instance_animation");
                    $intanceAnimation.SetAttribute("url", "#" + $aninNode.GetAttribute("id"));
                    $newClip.AppendChild($intanceAnimation);
                }
                $newClip.SetAttribute("start", $clipStartTime);
                $newClip.SetAttribute("end", $clipEndTime);
                $animClipsNode.AppendChild($newClip);
                $animationNode.ParentNode.InsertAfter($xml.ImportNode($newNode,$true), $animationNode);
            }
        }
    }
    $animationNode.ParentNode.InsertAfter($animClipsNode, $animationNode);

    #Validate the morphs
    $controllersNode = $xml.SelectSingleNode("//ns:library_controllers", $ns)
    foreach($controller in $controllersNode.ChildNodes)
    {
        $skinNode = $controller.SelectSingleNode("ns:skin",$ns);
        if($skinNode)
        {
            $morphName =  $skinNode.GetAttribute("source").Substring(1) + "-morph";
            $morphController = $controllersNode.SelectSingleNode("ns:controller[@id='" + $morphName + "']",$ns); 
            if($morphController)
            {
                $morphController.FirstChild.SetAttribute("method", "NORMALIZED");
                $skinNode.SetAttribute("source", "#" + $morphName);
            }
        }
    }
    #Add new root node
    $visualScene = $xml.SelectSingleNode("//ns:visual_scene", $ns)
    $hips = $visualScene.SelectSingleNode("ns:node[@id='" + $hipsName + "']",$ns);
    $hips_matrix = $hips.SelectSingleNode("ns:matrix",$ns);

    $matrix_values = $hips_matrix.innerText.Trim() -split '\s+|\r\n';
    
    $root_doc = $xml.CreateElement("node");
    $root_doc.SetAttribute("id", "root_doc");
    $root_doc.SetAttribute("name", "root_doc");
    $root_doc.SetAttribute("sid", "root_doc");
    $root_doc.SetAttribute("type", "JOINT");
    
    $root_matrix = $xml.CreateElement("matrix");
    $root_matrix.SetAttribute("sid", "matrix");
    $Xpos = $matrix_values[3];
    $Zpos = $matrix_values[11];
    $root_matrix.innerText = "1.000000 0.000000 0.000000 " + $Xpos + " 0.000000 1.000000 0.000000 0.000000 0.000000 0.000000 1.000000 " + $Zpos + " 0.000000 0.000000 0.000000 1.000000";
    $root_doc.AppendChild($root_matrix);
    $matrix_values[3] = "0.000000";
    $matrix_values[11] = "0.000000";

    $hips_matrix.InnerText = "$matrix_values";

    $visualScene.RemoveChild($hips);
    $root_doc.AppendChild($hips);
    $visualScene.AppendChild($root_doc);
    
    $skeleNodes = $visualScene.SelectNodes("//ns:skeleton", $ns);
    foreach($skeleNode in $skeleNodes)
    {
        $skeleNode.InnerText = "#root_doc";
    }

    #Modify binding matrices for skin controllers
    $skins =$xml.SelectNodes("//ns:skin", $ns);
    $countering = 0;
    foreach($skin in $skins)
    {
        $joints = $skin.SelectSingleNode("ns:source[contains(@id,'Joints')]", $ns);
        $matrices = $skin.SelectSingleNode("ns:source[contains(@id,'Matrices')]", $ns);
        
        $name_array = $joints.SelectSingleNode("ns:Name_array",$ns);
        $matrices_array = $matrices.SelectSingleNode("ns:float_array",$ns);

        $name_array.SetAttribute("count", [int]$name_array.GetAttribute("count") + 1);
        $name_array.innerText += " root_doc";
        $accessor = $joints.SelectSingleNode(".//ns:accessor", $ns1);
        $accessor.SetAttribute("count", [int]$accessor.GetAttribute("count") + 1);

        $matrices_array.SetAttribute("count", [int]$matrices_array.GetAttribute("count") + 16);
        $matrices_array.innerText += " 1.000000 0.000000 0.000000 0.000000 0.000000 1.000000 0.000000 0.000000 0.000000 0.000000 1.000000 0.000000 0.000000 0.000000 0.000000 1.000000";
        $accessor = $matrices.SelectSingleNode(".//ns:accessor", $ns1);
        $accessor.SetAttribute("count", [int]$accessor.GetAttribute("count") + 1);

        $countering++;


<#
        $names = $name_array.innerText.Trim() -split '\s+|\r\n';
        $hips_index = [array]::IndexOf($names, $hipsName);
        
         if($hips_index -gt -1)
        {
            $name_array.SetAttribute("count", [int]$name_array.GetAttribute("count") + 1);
            $name_array.innerText += " root_doc";

            $accessor = $joints.SelectSingleNode(".//ns:accessor", $ns1);
            $accessor.SetAttribute("count", [int]$accessor.GetAttribute("count") + 1);

            $matrices_array.SetAttribute("count", [int]$matrices_array.GetAttribute("count") + 16);

            $matrices_content = $matrices_array.innerText.Trim() -split '\s+|\r\n';

            $posX = $matrices_content[($hips_index*16) + 3];
            $posZ = $matrices_content[($hips_index*16) + 11];

            $matrices_content[($hips_index*16) + 3] = "0.000000";
            $matrices_content[($hips_index*16) + 11] = "0.000000";
            $matrices_array.innerText = "$matrices_content" + " 1.000000 0.000000 0.000000 " + $posX + " 0.000000 1.000000 0.000000 0.000000 0.000000 0.000000 1.000000 " + $posZ + " 0.000000 0.000000 0.000000 1.000000";

            $accessor = $matrices.SelectSingleNode(".//ns:accessor", $ns1);
            $accessor.SetAttribute("count", [int]$accessor.GetAttribute("count") + 1);
            $countering++;
        }
 #>    }
    $xml.Save($outputFile)
    Write-Output "SKINS: ", $countering;
    Write-Output "Done";
}
else 
{
    Write-Output "Invalid file name";
}
