# FalseDeer's Keylogger(FDK)
A Keylogger for WIndows Coded in MASM Assembly

# Usage:
Please execute FDK as system admin, or the CreateFileA will probably fail.  
After execution, This program will Create a file named "FDK" at the current directory,  
holding the data logged by this program.  
<img src="https://raw.githubusercontent.com/Falsedeer/FDK-Keylogger/main/pic/run%20as%20admin.png">

# Compile:
./ml.exe /c /coff logger.asm  
./link.exe /subsystem:console logger.obj  

# Credits:
- [Fa;sedeer024](https://home.gamer.com.tw/homeindex.php?owner=maxchen024)
