function Calc-CRC8([Byte] $InputObject, [Byte] $Polynomial = 0xd5) {
<#
.Synopsis
CRC8 を計算する。
.Description
CRC8 を計算する。
左送り専用。InitialMack, FinalMask なし。
.Example
[System.IO.File]::ReadAllBytes("$env:SystemRoot\System32\calc.exe") | Calc-CRC8
calc.exe の CRC8 を計算する。
.Example
#テキストの行ごとの CRC8 を計算する。
$crclist = New-Object System.Collections.Generic.List[Byte]
Get-Content "C:\Users\desktop.ini" |% {[System.Text.Encoding]::UTF8.GetBytes($_) | Calc-CRC8} |% {$crclist.Add($_)}
$linedigit = '0'*([Math]::Max(2, [Math]::Floor([Math]::Log10($crclist.Count))+1))
$formatstring = "{0:$linedigit} : 0x{1:x2}"
$linecount = 1
$crclist |% {$formatstring -f $linecount, $_; ++$linecount}
#>
    Begin {
        $table = New-Object Byte[] 256
        for($i = 0; $i -lt 256; ++$i) {
            $temp = $i
                for($j = 0; $j -lt 8; ++$j) {
                if(($temp -band 0x80) -ne 0) {
                    $temp = ($temp -shl 1) -bxor $Polynomial
                } else {
                    $temp = $temp -shl 1
                }
            }
            $table[$i] = [byte] ($temp -band 0xff)
        }
        [Byte] $crc = 0
    }
    Process {
        $crc = $table[$crc -bxor $_]
    }
    End {
        $crc
    }
}
