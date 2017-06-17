
configuration tester
{
    Import-DscResource -ModuleName FileWatcher
    node 'localhost'
    {

        WebSiteFileWatcher webWatch
        {
            WebsiteName =  'TestSite'
            Path = "C:\temp\myFile.txt"
        }

        ServiceFileWatcher serviceWatch
        {
            ServiceName = 'Spooler'
            Path = 'C:\temp\myfile.txt'
        }

        ProcessFileWatcher procWatch
        {
            ProcessName = 'notepad.exe'
            ProcessPath = 'notepad.exe'
            ProcessStartArgs =  'C:\temp\myfile.txt'
            Path = 'c:\temp\myFile.txt'
        }
    }

}

Mkdir C:\ps -ErrorAction 0
pushd c:\ps

tester


Start-DscConfiguration -Path .\tester -Verbose -Force -Wait