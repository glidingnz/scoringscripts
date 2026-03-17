program seeyou_runner;

{$mode objfpc}{$H+}

// SeeYou Pascal Script runner (FreePascal + Pascal Script)
// JSON in via stdin, JSON out via stdout.

uses
  SysUtils, Classes, fpjson, jsonparser,
  uPSCompiler, uPSRuntime, uPSUtils;

type

  TPilot = record
    CompID: string;
    isHC: boolean;
    Hcap: double;
    Penalty: double;
    takeoff: double;
    start: double;
    finish: double;
    dis: double;
    speed: double;
    sfinish: double;
    // outputs
    Points: integer;
    sstart: double;
    sdis: double;
    sspeed: double;
    Warning: string;
    td1: double; // temp
  end;

  TTask = record
    TotalDis: double;
    TaskTime: double;
    NoStartBeforeTime: LongInt;
    ClassID: string;
  end;

const
  TASK_TOTALDIS = 0;
  TASK_TASKTIME = 1;
  TASK_NOSTARTBEFORE = 2;
  TASK_CLASSID = 3;

  PILOT_COMPID = 0;
  PILOT_ISHC = 1;
  PILOT_HCAP = 2;
  PILOT_PENALTY = 3;
  PILOT_TAKEOFF = 4;
  PILOT_START = 5;
  PILOT_FINISH = 6;
  PILOT_DIS = 7;
  PILOT_SPEED = 8;
  PILOT_SFINISH = 9;
  PILOT_POINTS = 10;
  PILOT_SSTART = 11;
  PILOT_SDIS = 12;
  PILOT_SSPEED = 13;
  PILOT_WARNING = 14;
  PILOT_TD1 = 15;

var
  Task: TTask;
  Pilots: array of TPilot;
  DayTag: string;
  Info1, Info2, Info3: string;
  GUsesRegistered: boolean;
  GLastScriptText: string;

function ReadAllStdin: string;
var
  S: TStringList;
  Line: string;
begin
  S := TStringList.Create;
  try
    while not EOF(Input) do
    begin
      ReadLn(Input, Line);
      S.Add(Line);
    end;
    Result := S.Text;
  finally
    S.Free;
  end;
end;

procedure LoadInputJson(const JsonText: string);
var
  Root: TJSONObject;
  Arr: TJSONArray;
  I: integer;
  P: TJSONObject;
  TaskObj: TJSONObject;
begin
  Root := GetJSON(JsonText) as TJSONObject;
  try
    DayTag := Root.Get('day_tag', '');
    TaskObj := Root.Objects['task'];
    Task.TotalDis := TaskObj.Get('total_dis_m', 0.0);
    Task.TaskTime := TaskObj.Get('task_time_s', 0.0);
    Task.NoStartBeforeTime := TaskObj.Get('no_start_before_s', 0);
    Task.ClassID := Root.Get('class_id', 'unknown');

    Arr := Root.Arrays['pilots'];
    SetLength(Pilots, Arr.Count);
    for I := 0 to Arr.Count - 1 do
    begin
      P := Arr.Objects[I];
      Pilots[I].CompID := P.Get('comp_id', '');
      Pilots[I].isHC := P.Get('is_hc', false);
      Pilots[I].Hcap := P.Get('hcap', 1.0);
      Pilots[I].Penalty := P.Get('penalty', 0.0);
      Pilots[I].takeoff := P.Get('takeoff_s', -1.0);
      Pilots[I].start := P.Get('start_s', 0.0);
      Pilots[I].finish := P.Get('finish_s', 0.0);
      Pilots[I].dis := P.Get('dis_m', 0.0);
      Pilots[I].speed := P.Get('speed_ms', 0.0);
      Pilots[I].sfinish := P.Get('sfinish_s', 0.0);
    end;
  finally
    Root.Free;
  end;
end;

function BuildOutputJson: string;
var
  Root: TJSONObject;
  Arr: TJSONArray;
  P: TJSONObject;
  I: integer;
begin
  Root := TJSONObject.Create;
  try
    Root.Add('info1', Info1);
    Root.Add('info2', Info2);
    Root.Add('info3', Info3);

    Arr := TJSONArray.Create;
    for I := 0 to High(Pilots) do
    begin
      P := TJSONObject.Create;
      P.Add('comp_id', Pilots[I].CompID);
      P.Add('points', Pilots[I].Points);
      P.Add('sstart_s', Pilots[I].sstart);
      P.Add('sfinish_s', Pilots[I].sfinish);
      P.Add('sdis_m', Pilots[I].sdis);
      P.Add('sspeed_ms', Pilots[I].sspeed);
      P.Add('warning', Pilots[I].Warning);
      Arr.Add(P);
    end;
    Root.Add('pilots', Arr);

    Result := Root.AsJSON;
  finally
    Root.Free;
  end;
end;

function FixStrToIntTwoArg(const S: string): string;
const
  Name = 'StrToInt';
var
  i, j, depth, nameLen: integer;
  hasComma: boolean;
begin
  Result := '';
  nameLen := Length(Name);
  i := 1;
  while i <= Length(S) do
  begin
    if (i + nameLen <= Length(S)) and (Copy(S, i, nameLen) = Name) and
       (i + nameLen <= Length(S)) and (S[i + nameLen] = '(') then
    begin
      j := i + nameLen;
      depth := 0;
      hasComma := false;
      while j <= Length(S) do
      begin
        if S[j] = '(' then
          Inc(depth)
        else if S[j] = ')' then
        begin
          Dec(depth);
          if depth = 0 then
          begin
            Inc(j);
            break;
          end;
        end
        else if (S[j] = ',') and (depth = 1) then
          hasComma := true;
        Inc(j);
      end;

      if hasComma then
        Result := Result + 'StrToIntDef' + Copy(S, i + nameLen, j - (i + nameLen))
      else
        Result := Result + Name + Copy(S, i + nameLen, j - (i + nameLen));
      i := j;
    end
    else
    begin
      Result := Result + S[i];
      Inc(i);
    end;
  end;
end;

procedure RegisterTypes(Comp: TPSPascalCompiler);
var
  Rec: TPSRecordType;
  Arr: TPSArrayType;
  TDouble, TString, TBool, TInt: TPSType;
begin
  TDouble := Comp.FindType('Double');
  TString := Comp.FindType('string');
  TBool := Comp.FindType('Boolean');
  TInt := Comp.FindType('LongInt');

  Rec := TPSRecordType(Comp.AddType('TTask', btRecord));
  with Rec.AddRecVal do begin FieldOrgName := 'TotalDis'; aType := TDouble; end;
  with Rec.AddRecVal do begin FieldOrgName := 'TaskTime'; aType := TDouble; end;
  with Rec.AddRecVal do begin FieldOrgName := 'NoStartBeforeTime'; aType := TInt; end;
  with Rec.AddRecVal do begin FieldOrgName := 'ClassID'; aType := TString; end;

  Rec := TPSRecordType(Comp.AddType('TPilot', btRecord));
  with Rec.AddRecVal do begin FieldOrgName := 'CompID'; aType := TString; end;
  with Rec.AddRecVal do begin FieldOrgName := 'isHC'; aType := TBool; end;
  with Rec.AddRecVal do begin FieldOrgName := 'Hcap'; aType := TDouble; end;
  with Rec.AddRecVal do begin FieldOrgName := 'Penalty'; aType := TDouble; end;
  with Rec.AddRecVal do begin FieldOrgName := 'takeoff'; aType := TDouble; end;
  with Rec.AddRecVal do begin FieldOrgName := 'start'; aType := TDouble; end;
  with Rec.AddRecVal do begin FieldOrgName := 'finish'; aType := TDouble; end;
  with Rec.AddRecVal do begin FieldOrgName := 'dis'; aType := TDouble; end;
  with Rec.AddRecVal do begin FieldOrgName := 'speed'; aType := TDouble; end;
  with Rec.AddRecVal do begin FieldOrgName := 'sfinish'; aType := TDouble; end;
  with Rec.AddRecVal do begin FieldOrgName := 'Points'; aType := TInt; end;
  with Rec.AddRecVal do begin FieldOrgName := 'sstart'; aType := TDouble; end;
  with Rec.AddRecVal do begin FieldOrgName := 'sdis'; aType := TDouble; end;
  with Rec.AddRecVal do begin FieldOrgName := 'sspeed'; aType := TDouble; end;
  with Rec.AddRecVal do begin FieldOrgName := 'Warning'; aType := TString; end;
  with Rec.AddRecVal do begin FieldOrgName := 'td1'; aType := TDouble; end;

  Arr := TPSArrayType(Comp.AddType('TPilotArray', btArray));
  Arr.ArrayTypeNo := Comp.FindType('TPilot');
end;

procedure RegisterVariables(Comp: TPSPascalCompiler);
begin
  Comp.AddUsedVariableN('DayTag', 'string');
  Comp.AddUsedVariableN('Task', 'TTask');
  Comp.AddUsedVariableN('Pilots', 'TPilotArray');
  Comp.AddUsedVariableN('Info1', 'string');
  Comp.AddUsedVariableN('Info2', 'string');
  Comp.AddUsedVariableN('Info3', 'string');
end;

function BuildCompileError(Comp: TPSPascalCompiler): string;
var
  I: integer;
  Err: TPSPascalCompilerError;
  Line: string;
  LineText: string;
  Lines: TStringList;
begin
  Result := '';
  Lines := TStringList.Create;
  try
    Lines.Text := GLastScriptText;
    if (Lines.Count > 0) and (Lines[Lines.Count-1] = '') then
      Lines.Delete(Lines.Count-1);
  except
    Lines.Clear;
  end;
  for I := 0 to Comp.MsgCount - 1 do
  begin
    if Comp.Msg[I] is TPSPascalCompilerError then
    begin
      Err := TPSPascalCompilerError(Comp.Msg[I]);
      if (Err.Row > 0) and (Err.Row <= Lines.Count) then
        LineText := Lines[Err.Row-1]
      else
        LineText := '';
      Line := Format('(%d,%d) %s %s', [Err.Row, Err.Col, string(Err.ShortMessageToString), LineText]);
      Result := Result + Line + LineEnding;
    end;
  end;
  if Result = '' then
    Result := 'Unknown compile error';
  Lines.Free;
end;

function FixFunctionResultAssignments(const S: string): string;
var
  Names: TStringList;
  Lines: TStringList;
  I, J: integer;
  Line, Trimmed, Name: string;
  function ReplaceFuncAssign(const Text, FuncName: string): string;
  var
    i, nlen, j: integer;
    chPrev: char;
  begin
    Result := '';
    nlen := Length(FuncName);
    i := 1;
    while i <= Length(Text) do
    begin
      if (i + nlen - 1 <= Length(Text)) and
         (AnsiCompareText(Copy(Text, i, nlen), FuncName) = 0) then
      begin
        chPrev := #0;
        if i > 1 then chPrev := Text[i-1];
        if (i = 1) or not (chPrev in ['A'..'Z','a'..'z','0'..'9','_']) then
        begin
          j := i + nlen;
          if (j > Length(Text)) or not (Text[j] in ['A'..'Z','a'..'z','0'..'9','_']) then
          begin
            while (j <= Length(Text)) and (Text[j] in [' ', #9]) do
              Inc(j);
            if (j <= Length(Text) - 1) and (Text[j] = ':') and (Text[j+1] = '=') then
            begin
              Result := Result + 'Result';
              Result := Result + Copy(Text, i + nlen, j - (i + nlen));
              Result := Result + ':=';
              i := j + 2;
              Continue;
            end;
          end;
        end;
      end;
      Result := Result + Text[i];
      Inc(i);
    end;
  end;
begin
  Names := TStringList.Create;
  Lines := TStringList.Create;
  try
    Lines.Text := S;
    for I := 0 to Lines.Count - 1 do
    begin
      Line := Lines[I];
      Trimmed := TrimLeft(Line);
      if (Length(Trimmed) >= 8) and (AnsiCompareText(Copy(Trimmed, 1, 8), 'function') = 0) then
      begin
        J := 9;
        while (J <= Length(Trimmed)) and (Trimmed[J] = ' ') do Inc(J);
        Name := '';
        while (J <= Length(Trimmed)) and (Trimmed[J] in ['A'..'Z','a'..'z','0'..'9','_']) do
        begin
          Name := Name + Trimmed[J];
          Inc(J);
        end;
        if Name <> '' then
          Names.Add(Name);
      end;
    end;
    Result := S;
    for I := 0 to Names.Count - 1 do
      Result := ReplaceFuncAssign(Result, Names[I]);
  finally
    Names.Free;
    Lines.Free;
  end;
end;

function FixEndSemicolons(const S: string): string;
var
  Lines: TStringList;
  I, J: integer;
  Line, Trimmed, NextTrimmed: string;
begin
  Lines := TStringList.Create;
  try
    Lines.Text := S;
    for I := 0 to Lines.Count - 1 do
    begin
      Line := Lines[I];
      Trimmed := Trim(Line);
      if (AnsiCompareText(Trimmed, 'end') = 0) then
      begin
        J := I + 1;
        NextTrimmed := '';
        while (J < Lines.Count) and (NextTrimmed = '') do
        begin
          NextTrimmed := Trim(Lines[J]);
          Inc(J);
        end;
        if (NextTrimmed <> '') and (AnsiCompareText(Copy(NextTrimmed, 1, 4), 'else') = 0) then
          Continue;
        Lines[I] := Line + ';';
      end;
    end;
    Result := Lines.Text;
  finally
    Lines.Free;
  end;
end;

function OnUsesHandler(Sender: TPSPascalCompiler; const Name: tbtString): Boolean;
begin
  if not GUsesRegistered then
  begin
    RegisterTypes(Sender);
    RegisterVariables(Sender);
    Sender.AddDelphiFunction('function FormatFloat(const Format: string; Value: Extended): string;');
    GUsesRegistered := true;
  end;
  Result := true;
end;

function CompileScript(const ScriptPath: string; out Compiled: tbtString; out Error: string): boolean;
var
  Comp: TPSPascalCompiler;
  ScriptText: string;
  Script: TStringList;
begin
  Result := false;
  Error := '';
  Comp := TPSPascalCompiler.Create;
  Script := TStringList.Create;
  try
    GUsesRegistered := false;
    Comp.OnUses := @OnUsesHandler;

    Script.LoadFromFile(ScriptPath);
    ScriptText := FixStrToIntTwoArg(Script.Text);
    ScriptText := FixFunctionResultAssignments(ScriptText);
    ScriptText := FixEndSemicolons(ScriptText);
    GLastScriptText := ScriptText;

    if not Comp.Compile(ScriptText) then
    begin
      Error := BuildCompileError(Comp);
      Exit;
    end;

    if not Comp.GetOutput(Compiled) then
    begin
      Error := 'Failed to get compiled output';
      Exit;
    end;

    Result := true;
  finally
    Script.Free;
    Comp.Free;
  end;
end;

function RecField(const Rec: TPSVariantIFC; FieldNo: integer): TPSVariantIFC;
var
  Offs: Cardinal;
  RType: TPSTypeRec_Record;
begin
  Result := Rec;
  if (Result.aType = nil) or (Result.aType.BaseType <> btRecord) then
  begin
    Result.aType := nil;
    Result.Dta := nil;
    exit;
  end;
  RType := TPSTypeRec_Record(Result.aType);
  if (FieldNo < 0) or (FieldNo >= RType.FieldTypes.Count) then
  begin
    Result.aType := nil;
    Result.Dta := nil;
    exit;
  end;
  Offs := Cardinal(RType.RealFieldOffsets[FieldNo]);
  Result.Dta := Pointer(PtrUInt(Result.Dta) + Offs);
  Result.aType := TPSTypeRec(RType.FieldTypes[FieldNo]);
end;

procedure SetTaskRecord(const Rec: TPSVariantIFC; const T: TTask);
begin
  VNSetReal(RecField(Rec, TASK_TOTALDIS), T.TotalDis);
  VNSetReal(RecField(Rec, TASK_TASKTIME), T.TaskTime);
  VNSetInt(RecField(Rec, TASK_NOSTARTBEFORE), T.NoStartBeforeTime);
  VNSetString(RecField(Rec, TASK_CLASSID), T.ClassID);
end;

procedure SetPilotRecord(const Rec: TPSVariantIFC; const P: TPilot);
begin
  VNSetString(RecField(Rec, PILOT_COMPID), P.CompID);
  VNSetInt(RecField(Rec, PILOT_ISHC), Ord(P.isHC));
  VNSetReal(RecField(Rec, PILOT_HCAP), P.Hcap);
  VNSetReal(RecField(Rec, PILOT_PENALTY), P.Penalty);
  VNSetReal(RecField(Rec, PILOT_TAKEOFF), P.takeoff);
  VNSetReal(RecField(Rec, PILOT_START), P.start);
  VNSetReal(RecField(Rec, PILOT_FINISH), P.finish);
  VNSetReal(RecField(Rec, PILOT_DIS), P.dis);
  VNSetReal(RecField(Rec, PILOT_SPEED), P.speed);
  VNSetReal(RecField(Rec, PILOT_SFINISH), P.sfinish);
  VNSetInt(RecField(Rec, PILOT_POINTS), P.Points);
  VNSetReal(RecField(Rec, PILOT_SSTART), P.sstart);
  VNSetReal(RecField(Rec, PILOT_SDIS), P.sdis);
  VNSetReal(RecField(Rec, PILOT_SSPEED), P.sspeed);
  VNSetString(RecField(Rec, PILOT_WARNING), P.Warning);
  VNSetReal(RecField(Rec, PILOT_TD1), P.td1);
end;

procedure GetPilotRecord(const Rec: TPSVariantIFC; var P: TPilot);
begin
  P.Points := VNGetInt(RecField(Rec, PILOT_POINTS));
  P.sstart := VNGetReal(RecField(Rec, PILOT_SSTART));
  P.sfinish := VNGetReal(RecField(Rec, PILOT_SFINISH));
  P.sdis := VNGetReal(RecField(Rec, PILOT_SDIS));
  P.sspeed := VNGetReal(RecField(Rec, PILOT_SSPEED));
  P.Warning := VNGetString(RecField(Rec, PILOT_WARNING));
end;

procedure ExecuteScript(const ScriptPath: string);
var
  Compiled: tbtString;
  Err: string;
  Exec: TPSExec;
  V: PIFVariant;
  ArrIfc, RecIfc: TPSVariantIFC;
  I: integer;
begin
  if not CompileScript(ScriptPath, Compiled, Err) then
    raise Exception.Create('Compile error: ' + Err);

  Exec := TPSExec.Create;
  try
    Exec.RegisterDelphiFunction(@FormatFloat, 'FormatFloat', cdRegister);

    if not Exec.LoadData(Compiled) then
      raise Exception.Create('Failed to load compiled script');

    V := Exec.GetVar2('DayTag');
    if V <> nil then
      VSetString(V, DayTag);

    V := Exec.GetVar2('Task');
    if V <> nil then
    begin
      RecIfc := NewTPSVariantIFC(V, true);
      SetTaskRecord(RecIfc, Task);
    end;

    V := Exec.GetVar2('Pilots');
    if V <> nil then
    begin
      SetPSArrayLength(V, Length(Pilots));
      ArrIfc := NewTPSVariantIFC(V, true);
      for I := 0 to High(Pilots) do
      begin
        RecIfc := PSGetArrayField(ArrIfc, I);
        SetPilotRecord(RecIfc, Pilots[I]);
      end;
    end;

    if not Exec.RunScript then
      raise Exception.Create('Script error: ' + string(Exec.ExceptionString));

    V := Exec.GetVar2('Info1');
    if V <> nil then Info1 := VGetString(V);
    V := Exec.GetVar2('Info2');
    if V <> nil then Info2 := VGetString(V);
    V := Exec.GetVar2('Info3');
    if V <> nil then Info3 := VGetString(V);

    V := Exec.GetVar2('Pilots');
    if V <> nil then
    begin
      ArrIfc := NewTPSVariantIFC(V, false);
      for I := 0 to High(Pilots) do
      begin
        RecIfc := PSGetArrayField(ArrIfc, I);
        GetPilotRecord(RecIfc, Pilots[I]);
      end;
    end;
  finally
    Exec.Free;
  end;
end;

var
  InputText: string;
  ScriptPath: string;
  Root: TJSONObject;

begin
  try
    InputText := ReadAllStdin;
    LoadInputJson(InputText);

    Root := GetJSON(InputText) as TJSONObject;
    try
      ScriptPath := Root.Get('script_path', '');
    finally
      Root.Free;
    end;

    ExecuteScript(ScriptPath);
    WriteLn(BuildOutputJson);
  except
    on E: Exception do
    begin
      WriteLn(StdErr, E.Message);
      Halt(1);
    end;
  end;
end.
