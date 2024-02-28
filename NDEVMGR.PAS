(*{$DEFINE DEBUG}*)
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

NDEVMGR.PAS
DESCRIPTION
  Device manager unit.
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

UNIT NDevMgr;
INTERFACE
USES Crt, NPrinter, NTypeWtr;
CONST
  ON=1;
  OFF=0;
  TapeLength: Word=20000;
TYPE
  TWord=Integer;
  TTape=OBJECT
    State: OFF..ON;
    Length: Word;
    Position: Word;
    Media: String;
  END;
  TDASD=OBJECT
    State: OFF..ON;
    Track: Word;
    Sector: Word;
    Media: String;
  END;
  TReader=OBJECT
    State: OFF..ON;
    Position: Word;
    Media: String;
  END;
  TPuncher=OBJECT
    State: OFF..ON;
    Media: String;
  END;
  TDevice=OBJECT
    PUBLIC
    Tape: ARRAY[1..4] OF TTape;
    DASD: ARRAY[1..4] OF TDASD;
    Reader: TReader;
    Puncher: TPuncher;
    Printer: TPrinter;
    TypeWriter: TTypeWriter;
    LoadDevice: Integer;
    IOErr: Byte;
    PROCEDURE Initiate;
    PROCEDURE Input(Device: Byte; Qty: Byte; Addr: Byte);
    PROCEDURE Output(Device: Byte; Qty: Byte; Addr: Byte);
  END;
VAR
  Dev: TDevice;
IMPLEMENTATION
USES NProcess, NLibrary;
PROCEDURE TDevice.Initiate;
  VAR
    IniFile: Text;
    Buffer: String;
    Idx, IdxFrom, IdxTo: Integer;
  BEGIN
    IOErr:=0;
    Buffer:='';
    GetDir(0, Buffer);
    {$IFDEF DEBUG}
    Buffer:='C:\BP\NDP1600';
    {$I-}
    ChDir(Buffer);
    {$ENDIF}
    Assign(IniFile,'NDP1600.CFG');
    Reset(IniFile); Tape[1].State:=OFF;
    WHILE NOT Eof(IniFile) DO BEGIN
      ReadLn(IniFile, Buffer);
      IF Pos('DEVICE.TAPE1=ON', Buffer)<>0 THEN Tape[1].State:=ON;
    END;
    Reset(IniFile); Tape[2].State:=OFF;
    WHILE NOT Eof(IniFile) DO BEGIN
      ReadLn(IniFile, Buffer);
      IF Pos('DEVICE.TAPE2=ON', Buffer)<>0 THEN Tape[2].State:=ON;
    END;
    Reset(IniFile); Tape[3].State:=OFF;
    WHILE NOT Eof(IniFile) DO BEGIN
      ReadLn(IniFile, Buffer);
      IF Pos('DEVICE.TAPE3=ON', Buffer)<>0 THEN Tape[3].State:=ON;
    END;
    Reset(IniFile); Tape[4].State:=OFF;
    WHILE NOT Eof(IniFile) DO BEGIN
      ReadLn(IniFile, Buffer);
      IF Pos('DEVICE.TAPE4=ON', Buffer)<>0 THEN Tape[4].State:=ON;
    END;
    Reset(IniFile); DASD[1].State:=OFF;
    WHILE NOT Eof(IniFile) DO BEGIN
      ReadLn(IniFile, Buffer);
      IF Pos('DEVICE.DASD1=ON', Buffer)<>0 THEN DASD[1].State:=ON;
    END;
    Reset(IniFile); DASD[2].State:=OFF;
    WHILE NOT Eof(IniFile) DO BEGIN
      ReadLn(IniFile, Buffer);
      IF Pos('DEVICE.DASD2=ON', Buffer)<>0 THEN DASD[2].State:=ON;
    END;
    Reset(IniFile); DASD[3].State:=OFF;
    WHILE NOT Eof(IniFile) DO BEGIN
      ReadLn(IniFile, Buffer);
      IF Pos('DEVICE.DASD3=ON', Buffer)<>0 THEN DASD[3].State:=ON;
    END;
    Reset(IniFile); DASD[4].State:=OFF;
    WHILE NOT Eof(IniFile) DO BEGIN
      ReadLn(IniFile, Buffer);
      IF Pos('DEVICE.DASD4=ON', Buffer)<>0 THEN DASD[4].State:=ON;
    END;
    Reset(IniFile); Reader.State:=OFF;
    WHILE NOT Eof(IniFile) DO BEGIN
      ReadLn(IniFile, Buffer);
      IF Pos('DEVICE.READER=ON', Buffer)<>0 THEN Reader.State:=ON;
    END;
    Reset(IniFile); Puncher.State:=OFF;
    WHILE NOT Eof(IniFile) DO BEGIN
      ReadLn(IniFile, Buffer);
      IF Pos('DEVICE.PUNCHER=ON', Buffer)<>0 THEN Puncher.State:=ON;
    END;
    Reset(IniFile); Printer.State:=OFF;
    WHILE NOT Eof(IniFile) DO BEGIN
      ReadLn(IniFile, Buffer);
      IF Pos('DEVICE.PRINTER=ON', Buffer)<>0 THEN Printer.State:=ON;
    END;
    Reset(IniFile); TypeWriter.State:=OFF;
    WHILE NOT Eof(IniFile) DO BEGIN
      ReadLn(IniFile, Buffer);
      IF Pos('DEVICE.TYPEWRITER=ON', Buffer)<>0 THEN TypeWriter.State:=ON;
    END;
    Reset(IniFile);
    WHILE NOT Eof(IniFile) DO BEGIN
      ReadLn(IniFile, Buffer);
      IF Pos('MEDIA.TAPE1=', Buffer)<>0 THEN Tape[1].Media:='TAPE1.BIN';
      IF Pos('MEDIA.TAPE1=<', Buffer)<>0 THEN BEGIN
        Tape[1].Media:=''; IdxFrom:=0; IdxTo:=0;
        IdxFrom:=Pos('<', Buffer); IdxTo:=Pos('>', Buffer);
        Tape[1].Media:=Copy(Buffer, IdxFrom+1, IdxTo-IdxFrom-1);
      END;
    END;
    Reset(IniFile);
    WHILE NOT Eof(IniFile) DO BEGIN
      ReadLn(IniFile, Buffer);
      IF Pos('MEDIA.TAPE2=', Buffer)<>0 THEN Tape[2].Media:='TAPE2.BIN';
      IF Pos('MEDIA.TAPE2=<', Buffer)<>0 THEN BEGIN
        Tape[2].Media:=''; IdxFrom:=0; IdxTo:=0;
        IdxFrom:=Pos('<', Buffer); IdxTo:=Pos('>', Buffer);
        Tape[2].Media:=Copy(Buffer, IdxFrom+1, IdxTo-IdxFrom-1);
      END;
    END;
    Reset(IniFile);
    WHILE NOT Eof(IniFile) DO BEGIN
      ReadLn(IniFile, Buffer);
      IF Pos('MEDIA.TAPE3=', Buffer)<>0 THEN Tape[3].Media:='TAPE3.BIN';
      IF Pos('MEDIA.TAPE3=<', Buffer)<>0 THEN BEGIN
        Tape[3].Media:=''; IdxFrom:=0; IdxTo:=0;
        IdxFrom:=Pos('<', Buffer); IdxTo:=Pos('>', Buffer);
        Tape[3].Media:=Copy(Buffer, IdxFrom+1, IdxTo-IdxFrom-1);
      END;
    END;
    Reset(IniFile);
    WHILE NOT Eof(IniFile) DO BEGIN
      ReadLn(IniFile, Buffer);
      IF Pos('MEDIA.TAPE4=', Buffer)<>0 THEN Tape[4].Media:='TAPE4.BIN';
      IF Pos('MEDIA.TAPE4=<', Buffer)<>0 THEN BEGIN
        Tape[4].Media:=''; IdxFrom:=0; IdxTo:=0;
        IdxFrom:=Pos('<', Buffer); IdxTo:=Pos('>', Buffer);
        Tape[4].Media:=Copy(Buffer, IdxFrom+1, IdxTo-IdxFrom-1);
      END;
    END;
    Reset(IniFile);
    WHILE NOT Eof(IniFile) DO BEGIN
      ReadLn(IniFile, Buffer);
      IF Pos('MEDIA.DASD1=', Buffer)<>0 THEN DASD[1].Media:='DASD1.BIN';
      IF Pos('MEDIA.DASD1=<', Buffer)<>0 THEN BEGIN
        Tape[1].Media:=''; IdxFrom:=0; IdxTo:=0;
        IdxFrom:=Pos('<', Buffer); IdxTo:=Pos('>', Buffer);
        DASD[1].Media:=Copy(Buffer, IdxFrom+1, IdxTo-IdxFrom-1);
      END;
    END;
    Reset(IniFile);
    WHILE NOT Eof(IniFile) DO BEGIN
      ReadLn(IniFile, Buffer);
      IF Pos('MEDIA.DASD2=', Buffer)<>0 THEN DASD[2].Media:='DASD2.BIN';
      IF Pos('MEDIA.DASD2=<', Buffer)<>0 THEN BEGIN
        DASD[2].Media:=''; IdxFrom:=0; IdxTo:=0;
        IdxFrom:=Pos('<', Buffer); IdxTo:=Pos('>', Buffer);
        DASD[2].Media:=Copy(Buffer, IdxFrom+1, IdxTo-IdxFrom-1);
      END;
    END;
    Reset(IniFile);
    WHILE NOT Eof(IniFile) DO BEGIN
      ReadLn(IniFile, Buffer);
      IF Pos('MEDIA.DASD3=', Buffer)<>0 THEN DASD[3].Media:='DASD3.BIN';
      IF Pos('MEDIA.DASD3=<', Buffer)<>0 THEN BEGIN
        DASD[3].Media:=''; IdxFrom:=0; IdxTo:=0;
        IdxFrom:=Pos('<', Buffer); IdxTo:=Pos('>', Buffer);
        DASD[3].Media:=Copy(Buffer, IdxFrom+1, IdxTo-IdxFrom-1);
      END;
    END;
    Reset(IniFile);
    WHILE NOT Eof(IniFile) DO BEGIN
      ReadLn(IniFile, Buffer);
      IF Pos('MEDIA.DASD4=', Buffer)<>0 THEN DASD[4].Media:='DASD4.BIN';
      IF Pos('MEDIA.DASD4=<', Buffer)<>0 THEN BEGIN
        DASD[4].Media:=''; IdxFrom:=0; IdxTo:=0;
        IdxFrom:=Pos('<', Buffer); IdxTo:=Pos('>', Buffer);
        DASD[4].Media:=Copy(Buffer, IdxFrom+1, IdxTo-IdxFrom-1);
      END;
    END;
    Reset(IniFile);
    WHILE NOT Eof(IniFile) DO BEGIN
      ReadLn(IniFile, Buffer);
      IF Pos('MEDIA.READER=', Buffer)<>0 THEN Reader.Media:='READER.DCK';
      IF Pos('MEDIA.READER=<', Buffer)<>0 THEN BEGIN
        Reader.Media:=''; IdxFrom:=0; IdxTo:=0;
        IdxFrom:=Pos('<', Buffer); IdxTo:=Pos('>', Buffer);
        Reader.Media:=Copy(Buffer, IdxFrom+1, IdxTo-IdxFrom-1);
      END;
    END;
    Reset(IniFile);
    WHILE NOT Eof(IniFile) DO BEGIN
      ReadLn(IniFile, Buffer);
      IF Pos('MEDIA.PUNCHER=', Buffer)<>0 THEN Puncher.Media:='PUNCHER.DCK';
      IF Pos('MEDIA.PUNCHER=<', Buffer)<>0 THEN BEGIN
        Puncher.Media:=''; IdxFrom:=0; IdxTo:=0;
        IdxFrom:=Pos('<', Buffer); IdxTo:=Pos('>', Buffer);
        Puncher.Media:=Copy(Buffer, IdxFrom+1, IdxTo-IdxFrom-1);
      END;
    END;
    Reset(IniFile);
    WHILE NOT Eof(IniFile) DO BEGIN
      ReadLn(IniFile, Buffer);
      IF Pos('MEDIA.PRINTER=', Buffer)<>0 THEN Printer.Media:='PRINTER.LST';
      IF Pos('MEDIA.PRINTER=<', Buffer)<>0 THEN BEGIN
        Printer.Media:=''; IdxFrom:=0; IdxTo:=0;
        IdxFrom:=Pos('<', Buffer); IdxTo:=Pos('>', Buffer);
        Printer.Media:=Copy(Buffer, IdxFrom+1, IdxTo-IdxFrom-1);
      END;
    END;
    Reset(IniFile);
    WHILE NOT Eof(IniFile) DO BEGIN
      ReadLn(IniFile, Buffer);
      IF Pos('LOAD=<',Buffer)<>0 THEN BEGIN
        LoadDevice:=$0C; {Reader}IdxFrom:=Pos('<', Buffer); IdxTo:=Pos('>', Buffer);
        Buffer:=Copy(Buffer, IdxFrom+1, IdxTo-IdxFrom-1);
        IF      Buffer='TAPE1'  THEN LoadDevice:=$4
        ELSE IF Buffer='TAPE2'  THEN LoadDevice:=$5
        ELSE IF Buffer='TAPE3'  THEN LoadDevice:=$6
        ELSE IF Buffer='TAPE4'  THEN LoadDevice:=$7
        ELSE IF Buffer='DASD1'  THEN LoadDevice:=$8
        ELSE IF Buffer='DASD2'  THEN LoadDevice:=$9
        ELSE IF Buffer='DASD3'  THEN LoadDevice:=$A
        ELSE IF Buffer='DASD4'  THEN LoadDevice:=$B
        ELSE IF Buffer='READER' THEN LoadDevice:=$C;
      END;
    END;
    Close(IniFile);
    {$I+}
    FOR Idx:=1 TO 4 DO BEGIN
      Tape[Idx].Length:=TapeLength;
      Tape[Idx].Position:=0;
      DASD[Idx].Track:=0;
      DASD[Idx].Sector:=0;
    END;
    Reader.Position:=0;
    Printer.CaretPos:=1;
    Printer.Buffer:='';
    TypeWriter.CaretPos:=1;
    TypeWriter.Buffer:='';
  END { TDevice.Initiate };
PROCEDURE TDevice.Input(Device: Byte; Qty: Byte; Addr: Byte);
  BEGIN
    CASE Device OF
    $00: IOErr:=7;
    $01: IOErr:=7;
    $02: IOErr:=7;
    $03: IOErr:=7;
    $04: IF Tape[1].State=OFF THEN IOErr:=7
         ELSE BEGIN

         END;
    $05: IF Tape[2].State=OFF THEN IOErr:=7
         ELSE BEGIN

         END;
    $06: IF Tape[3].State=OFF THEN IOErr:=7
         ELSE BEGIN

         END;
    $07: IF Tape[4].State=OFF THEN IOErr:=7
         ELSE BEGIN

         END;
    $08: IF DASD[1].State=OFF THEN IOErr:=7
         ELSE BEGIN

         END;
    $09: IF DASD[2].State=OFF THEN IOErr:=7
         ELSE BEGIN

         END;
    $0A: IF DASD[3].State=OFF THEN IOErr:=7
         ELSE BEGIN

         END;
    $0B: IF DASD[4].State=OFF THEN IOErr:=7
         ELSE BEGIN

         END;
    $0C: IF Reader.State=OFF THEN IOErr:=7
         ELSE BEGIN

         END;
    $0D: IF Puncher.State=OFF THEN IOErr:=7
         ELSE BEGIN

         END;
    $0E: IF Printer.State=OFF THEN IOErr:=7 ELSE IOErr:=9;
    $0F: IF TypeWriter.State=OFF THEN IOErr:=7
         ELSE BEGIN
           Proc.Mem[Addr]:=TypeWriter.ReadWord;
         END;
    END;
  END { TDevice.Input };
PROCEDURE TDevice.Output(Device: Byte; Qty: Byte; Addr: Byte);
  VAR MediaFile: File;
  BEGIN
    CASE Device OF
    $00: IOErr:=7;
    $01: IOErr:=7;
    $02: IOErr:=7;
    $03: IOErr:=7;
    $04: IF Tape[1].State=OFF THEN IOErr:=7
         ELSE BEGIN

         END;
    $05: IF Tape[2].State=OFF THEN IOErr:=7
         ELSE BEGIN

         END;
    $06: IF Tape[3].State=OFF THEN IOErr:=7
         ELSE BEGIN

         END;
    $07: IF Tape[4].State=OFF THEN IOErr:=7
         ELSE BEGIN

         END;
    $08: IF DASD[1].State=OFF THEN IOErr:=7
         ELSE BEGIN

         END;
    $09: IF DASD[2].State=OFF THEN IOErr:=7
         ELSE BEGIN

         END;
    $0A: IF DASD[3].State=OFF THEN IOErr:=7
         ELSE BEGIN

         END;
    $0B: IF DASD[4].State=OFF THEN IOErr:=7
         ELSE BEGIN

         END;
    $0C: IF Reader.State=OFF THEN IOErr:=7
         ELSE BEGIN

         END;
    $0D: IF Puncher.State=OFF THEN IOErr:=7
         ELSE BEGIN

         END;
    $0E: IF Printer.State=OFF THEN IOErr:=7
         ELSE BEGIN
           Assign(MediaFile, Printer.Media);
           {$I-}Reset(MediaFile);{$I+}
           IF IOResult<>1 THEN IOErr:=8
           ELSE IF IOResult=0 THEN BEGIN
             Printer.PrintWord(Proc.Mem[Addr], Qty);
           END;
         END;
    $0F: IF TypeWriter.State=OFF THEN IOErr:=7 ELSE
           IF Addr=0 THEN WriteLn ELSE TypeWriter.PrintWord(Proc.Mem[Addr])
    END;
  END { TDevice.Output };
END { SysDev }.
