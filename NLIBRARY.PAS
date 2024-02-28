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


NLIBRARY.PAS
DESCRIPTION
  Support library.
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

UNIT NLibrary;
INTERFACE
USES Crt;
PROCEDURE Splash;
PROCEDURE SetByte(VAR SrcHiByte: Byte; SrcLoByte: Byte; VAR TrgtByte: Byte);
FUNCTION GetHi(SrcByte: Byte): Byte;
FUNCTION GetLo(SrcByte: Byte): Byte;
FUNCTION WordToHex(Wrd: Word): String;
FUNCTION HexToWord(HexStr: String): Integer;
IMPLEMENTATION
PROCEDURE Splash;
  VAR I: Word;
  Row, Col: Word;
  Sym: Byte;
  BEGIN
    (*ClrScr;*)
    TextMode(C80);
    Randomize;
    Sym:=0;
    FOR Row:=1 TO 25 DO
    FOR Col:=1 TO 80 DO
      BEGIN
        IF ((Row<>25) AND (Col<>80)) THEN BEGIN
          GotoXY(Col,Row);
          TextAttr:=Random(256);
          Write(Chr(Sym));
        END;
        Inc(Sym);
        IF Sym = $0A THEN Inc(Sym);
        IF Sym = $FF THEN Sym:=0;
      END;
  END { Splash };
FUNCTION GetHi(SrcByte: Byte): Byte;
{ Get hi nibble }
  BEGIN
    GetHi:=SrcByte AND $F0;
    GetHi:=SrcByte SHR 4;
  END {GetHi};
FUNCTION GetLo(SrcByte: Byte): Byte;
{ Get lo nibble }
  BEGIN
    GetLo:=SrcByte AND $0F;
  END {GetLo};
PROCEDURE SetByte(VAR SrcHiByte: Byte; SrcLoByte: Byte; VAR TrgtByte: Byte);
{ Assemble byte from two nibbles }
  BEGIN
    SrcHiByte:=SrcHiByte SHL 4;
    TrgtByte:= SrcLoByte OR SrcHiByte;
  END {SetByte};
FUNCTION WordToHex(Wrd: Word): String;
{ Return hex string for word }
  CONST
    Digits: ARRAY[0..$F] OF Char='0123456789ABCDEF';
  BEGIN
    WordToHex[0]:=#4;
    WordToHex[1]:=Digits[Hi(Wrd) SHR $4];
    WordToHex[2]:=Digits[Hi(Wrd) AND $F];
    WordToHex[3]:=Digits[Lo(Wrd) SHR $4];
    WordToHex[4]:=Digits[Lo(Wrd) AND $F];
  END { WordToHex };
FUNCTION HexToWord(HexStr: String): Integer;
{ Return integer for hex string}
  VAR
    Temp, Code: Integer;
  BEGIN
    IF Length(HexStr)=0 THEN HexToWord:=0
    ELSE BEGIN
      HexStr:='$'+HexStr;
      Val(HexStr, Temp, Code);
      IF Code=0 THEN HexToWord:=Temp
      ELSE HexToWord:=0;
    END;
  END { HexToWord };
END { SysLib }.
