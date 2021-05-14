$header = @"
# TIL

> Today I Learned

A collection of concise write-ups on small things I learn day to day across a
variety of languages and technologies.
"@

$footer = @"
## About

I shamelessly stole this idea from
[thoughtbot/til](https://github.com/thoughtbot/til).

## Other TIL Collections

* [Today I Learned by Hashrocket](https://til.hashrocket.com)
* [jwworth/til](https://github.com/jwworth/til)
* [thoughtbot/til](https://github.com/thoughtbot/til)
"@

function Get-Categories{
    $dirs = Get-ChildItem -Path . -Directory -Exclude 'Media'
    return $dirs.Name
}

function Get-Title($tilFile){
    $file = Get-content $tilFile
    foreach($line in $file){
        if($line.startsWith('#')){
            return $line.trim("#").Trim()
        }
    }
}

function Get-Tils($category){
    $tilFiles = Get-ChildItem -Path .\$category
    $titles = @()
    foreach($filename in $tilFiles){
        if($filename.Extension -eq '.md'){
            $title = Get-Title $filename.FullName
            $titles += [PSCustomObject]@{
                title = $title
                filename = "$($filename.Directory.Name)/$($filename.Name)"
            }
        }
    }
    return $titles
}

function Get-CategoryHash($categoryNames){
    $categories = @{}
    $count = 0
    foreach($category in $categoryNames){
        $titles = Get-Tils $category
        $categories[$category] = $titles
        $count += $titles.title.count
    }
    return [PSCustomObject]@{
        count = $count
        categories = $categories
    }
}

function Print-File($categoryNames, $count, $categories){
    $output = $header
    $output += "`n`n"
    $output += "_$count TILs and counting..._"
    $output += "`n`n"
    $output += @"
---

### Categories

"@

    foreach($category in ($categoryNames | Sort-Object)){
        $output += "* [$((Get-Culture).TextInfo.ToTitleCase($category))](#$category)`n"
    }
    $output += @"
---

"@

    foreach($category in ($categoryNames | Sort-Object)){
        $output += "### $((Get-Culture).TextInfo.ToTitleCase($category))`n`n"
        $tils = $categories[$category]
        Foreach($i in ($tils | Sort-Object -Property title)){
            $output += "- [$($i.title)]($($i.filename))`n"
        }
        $output += "`n"
    }

    $output += $footer
    $output | Out-File 'README.md'
}

function Create-Readme(){
    $categoryNames = Get-Categories
    $categories = Get-CategoryHash $categoryNames
    Print-File $categoryNames $categories.Count $categories.categories
}

Create-Readme