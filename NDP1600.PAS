(*{$UNDEFINE FP}*)
{$IFDEF FP}{$ASMMODE INTEL}{$MODE TP}{$CODEPAGE CP866}{$ENDIF}
{
                      --
                     / /
      --\  --   ----/ / /---\    N E U M A N N
     /  | / / / --\  / / --\ \
    / / |/ / / /  / / / /  / /   D A T A
   / /| / / / /  / / / /  / /
  / / |  /  \ \-- / /  \-/ /     P R O C E S S O R
  --  \--    \---/ / /----
                  / /
                  --

NDP1600.PAS
DESCRIPTION
  Main program file.
  NDP-1600 educational computer model.
  By Eugene Gaiworonski
  e.gaiworonski@sochi.com
  Nov 2023, Feb 2024
AUTHOR
  Eugene Gaiworonski
  e.gaiworonski@sochi.com
  https://github.com/EugeneGaiworonski
LICENSE
  Hereby Public Domain
  Use this code as you see fit. By using or compiling this code or derivative
  thereof, you are consenting to the hold the author, E. Gaiworonski, harmless
  for all effects or side-effects its use. This code works great for me,
  but you are using it at your own risk.
}

PROGRAM NDP1600;
USES WinDos, WinCrt, NProcess, NDevMgr, NLibrary;
LABEL Done;
CONST Input: String = '';
BEGIN
  ClrScr;
  Proc.Initiate;
  Dev.Initiate;
  WHILE True DO BEGIN
   REPEAT
    Proc.ExecuteInstruction;
    WriteLn('IP=', Proc.IPReg, ' ERR=', Proc.ERReg);
   UNTIL KeyPressed;
    IF KeyPressed THEN IF ReadKey=#27 {ESC} THEN Write('-->');ReadLn(Input);
    IF Input='e' THEN Proc.ERReg:=100;
    IF Proc.ERReg <> 0 THEN Goto Done;
  END;
Done:
  Write('SHUTDOWN ERR=', Proc.ERReg);
  ReadLn;
END { NDP1600 }.
