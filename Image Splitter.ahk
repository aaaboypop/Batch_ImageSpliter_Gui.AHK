SetWorkingDir, %A_ScriptDir%
#Include, Log_System_class.ahk
#Include, Class_LV_InCellEdit.ahk

 
cnf = 
(
[Profiles1]
_LogLimit=19
_WriteFile=False
_AddGUI=True
_AddProgress=Progress
User=1
)

log := new LogSystem("Setting.ini", 1, cnf)

Gui, Add, Edit, w400 vPath, FolderPath
Gui, Add, Edit, w400 vPrefix, Image Input Prefix
Gui, Add, ListView, -Readonly w400 Grid r12 hwndHwndLV1 AltSubmit vLV1 , width|height|x|y
LV1obj := New LV_InCellEdit(HwndLV1)

Gui, Add, Button, x10 y+10 w80 h40 gAddR, ADD ROW
Gui, Add, Button, x+10 y+-40 w80 h40 gDelR, Remove ROW

LV_ModifyCol(1, 100)
LV_ModifyCol(2, 100)
LV_ModifyCol(3, 100)
LV_ModifyCol(4, 100)

Gui, Add, Button, x+10 y+-40 w80 h40 gStart, Start
Gui, Show, w420, Image Spliter
Return

AddR:
LV_Add(, "w", "h", "x", "y")
Return

DelR:
LV_Delete(LV_GetCount())
Return

Start:
Gui, Submit, NoHide
log.LogAdd("User", [1], "Starting..")

Path := Path "\" Prefix
Loop, Files, %Path%*.png
{
    file_count := A_Index
}

Loop, Files, %Path%*.png
{
    loop % LV_GetCount()
    {
        LV_GetText(v1, A_Index , 1)
        LV_GetText(v2, A_Index , 2)
        LV_GetText(v3, A_Index , 3)
        LV_GetText(v4, A_Index , 4)
    }
    img1 := A_LoopFileName
    SplitPath, A_LoopFileFullPath, ,OutDir , , OutNameNoExt
    new_name := "s_" OutNameNoExt
    command := ""
    command .= "cd /d """ OutDir """ && magick "
    command .= """" img1 """ -write mpr:pipe1 +delete "

    loop % LV_GetCount()
    {
        LV_GetText(v1, A_Index , 1)
        LV_GetText(v2, A_Index , 2)
        LV_GetText(v3, A_Index , 3)
        LV_GetText(v4, A_Index , 4)
        
        i := Format("{:02}", A_Index)
        command .= "( mpr:pipe1 -crop " v1 "x" v2 "+" v3 "+" v4 " +write """ new_name "_" i ".png"" ) "
    }
    command .= "null:"
    ;log.LogAdd("User", [1], command)
    log.LogAdd("User", [1], img1)
    RunWait, %ComSpec% /c %command%,,hide
    percent := (A_Index/file_count)*100
    log.LogPG("Progress" ,percent)
}
log.LogAdd("User", [1], "Task Done!")
Return


