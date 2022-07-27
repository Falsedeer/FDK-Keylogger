# FalseDeer's Keylogger(FDK)
A Keylogger for WIndows Coded in MASM Assembly

# Usage:
Please execute FDK as system admin, or the CreateFileA will probably fail.  
After execution, This program will run in background and create a file named "FDK" in current directory,  
holding the data logged by this program.  
<img src="https://raw.githubusercontent.com/Falsedeer/FDK-Keylogger/main/pic/run%20as%20admin.png">
The only way to terminate this keylogger is to hit Ctrl-Alt-Del to bring up task manager,  
and terminate the executing process of FDK manually.
<img src="https://raw.githubusercontent.com/Falsedeer/FDK-Keylogger/main/pic/run%20in%20background.png">
The recorded data saved in the log file, is presented in the format as [key](timestamp)
<img src="https://raw.githubusercontent.com/Falsedeer/FDK-Keylogger/main/pic/result.png">

# Compile:
./ml.exe /c /coff logger.asm  
./link.exe /subsystem:console logger.obj  

# Credits:
- [Fa;sedeer024](https://home.gamer.com.tw/homeindex.php?owner=maxchen024)
