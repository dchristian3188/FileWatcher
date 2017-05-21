. C:\Users\bigba\Desktop\Git\FileWatcher\Examples\OrginalDesign.ps1

$VerbosePreference = 'Continue'
$serviceWatcher = [SmartSeviceRestart]::New()
$serviceWatcher.ServiceName = 'Spooler'
$serviceWatcher.Path = 'C:\temp\test.txt'
$serviceWatcher.Set()
$serviceWatcher.Test()
$serviceWatcher.Get()