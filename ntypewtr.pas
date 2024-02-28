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

NTYPEWTR.PAS
DESCRIPTION
  Typewriter device unit.
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

UNIT NTypewtr;
INTERFACE
USES
  Nlibrary, Crt;
CONST
  ON=1;
  OFF=0;
TYPE
  TWord=Integer;
  TTypeWriter=OBJECT
    State: OFF..ON;
    CaretPos: 1..61;
    Buffer: String[60];
    PROCEDURE PrintWord(Value: TWord);
    FUNCTION ReadWord: Tword;
  END;
IMPLEMENTATION
PROCEDURE TTypeWriter.PrintWord(Value: TWord);
  VAR Idx: Integer;
  BEGIN
    Str(Value, Buffer);
    IF Value >=0 THEN FOR Idx:=1 TO 6-Length(Buffer) DO Buffer:='0'+Buffer
      ELSE BEGIN
        Delete(Buffer,1,1);
        FOR Idx:=1 TO 6-Length(Buffer) DO Buffer:='0'+Buffer;
      END;
      IF Value >= 0 THEN Buffer:='+'+Buffer ELSE Buffer:='-'+Buffer;
      Buffer:=Buffer+' ';
      FOR Idx:=1 TO Length(Buffer) DO BEGIN
        Write(Buffer[Idx]);
        Delay(20);
        Inc(CaretPos);
        IF CaretPos=61 THEN BEGIN
          WriteLn;
          CaretPos:=1;
        END;
      END;
  END { TTypeWriter.PrintWord };
FUNCTION TTypeWriter.ReadWord: TWord;
  VAR
    Convert: TWord;
    Error: Integer;
  BEGIN
    ReadLn(Buffer);
    Val(Buffer, Convert, Error);
    ReadWord:=Convert;
  END { TTypeWriter.ReadWord };
END { SysTW }.

