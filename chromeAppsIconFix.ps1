Move-Item 'C:\Program Files (x86)\Google\Chrome Beta\Application\chrome.VisualElementsManifest.xml' 'C:\Program Files (x86)\Google\Chrome Beta\Application\chrome.VisualElementsManifest.xml.bak'
foreach ($file in (Get-ChildItem 'C:\Users\'$env:username'\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Chrome Beta Apps\')) {
    $file.LastWriteTime = get-date
}
