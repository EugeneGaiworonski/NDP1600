{$DEFINE FP}
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

NPRINTER.PAS
DESCRIPTION
  Printer device unit.
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

UNIT NPrinter;
INTERFACE
USES NLibrary;
CONST
  ON=1;
  OFF=0;
TYPE
  TWord=Integer;
  TPrinter=OBJECT
    State: OFF..ON;
    Media: String;
    CaretPos: 1..81;
    Buffer: String[80];
    PROCEDURE PrintWord(Value: TWord; Mode: Byte);
  END;
IMPLEMENTATION
PROCEDURE TPrinter.PrintWord(Value: TWord; Mode: Byte);
  VAR
    Idx: Integer;
    LptFile: Text;
  BEGIN
  CASE Mode OF
  0: BEGIN
       {open file}
       {$I-}
       Assign(LptFile, Media);
       Append(LptFile);
       {$I+}
       Str(Value, Buffer);
       IF Value >=0 THEN FOR Idx:=1 TO 6-Length(Buffer) DO Buffer:='0'+Buffer
         ELSE BEGIN
           Delete(Buffer,1,1);
           FOR Idx:=1 TO 6-Length(Buffer) DO Buffer:='0'+Buffer;
         END;
         IF Value >= 0 THEN Buffer:='+'+Buffer ELSE Buffer:='-'+Buffer;
         Buffer:=Buffer+' ';
         FOR Idx:=1 TO Length(Buffer) DO BEGIN
           Write(LptFile, Buffer[Idx]);
           Inc(CaretPos);
           IF CaretPos=81 THEN BEGIN
             WriteLn(LptFile);
             CaretPos:=1;
           END;
         END;
         Close(LptFile);
       {close file}
     END;
  1: BEGIN
       {$I-}
       Assign(LptFile, Media);
       Append(LptFile);
       {$I+}
       Buffer:=WordToHex(Value);
       FOR Idx:=1 TO 6-Length(Buffer) DO Buffer:='0'+Buffer;
       FOR Idx:=1 TO Length(Buffer) DO BEGIN
           Write(LptFile, Buffer[Idx]);
           Inc(CaretPos);
           IF CaretPos=81 THEN BEGIN
             WriteLn(LptFile);
             CaretPos:=1;
           END;
         END;
       Close(LptFile);
     END;
  END;
  END { TPrinter.PrintWord };
END { SysPrint }.
