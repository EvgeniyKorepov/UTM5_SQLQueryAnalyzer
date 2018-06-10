unit Unit1;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  System.IOUtils,
  System.Generics.Collections,
  System.Generics.Defaults,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.StdCtrls,
  FMX.Controls.Presentation, FMX.ScrollBox, FMX.Memo, FMX.Layouts;


type
  TQuery = record
    Count : Integer;
    AverageTime : Double;
    QueryType : String;
    QueryTables : String;
    QueryWhere : String;
  end;
  TQueryDictionary = TDictionary<String, TQuery>;

  TFormMain = class(TForm)
    Memo: TMemo;
    procedure ButtonStartClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
    FQueryDictionary : TQueryDictionary;
    FLines : Integer;
    FAppPath : String;
  public
    { Public declarations }
    procedure ExtractSQLQuery;
    function IsSQL(const Value : String) : Boolean;
    function IsSQLQuery(const Value : String) : Boolean;
    function IsSQLQueryTakes(const Value : String) : Boolean;
    function RemoveTimeStamp(const Value : String) : String;
    function CompareLine(const Value1, Value2 : String) : boolean;
    function ExtractTime(const Value : String) : String;
    function ProcessingSQLQuery(Var Value : String) : boolean;
    function ProcessingSQLQueryUPDATE(Var Value : String) : boolean;
    function ProcessingSQLQuerySELECT(Var Value : String) : boolean;
    function ProcessingSQLQueryDELETE(Var Value : String) : boolean;
    function ProcessingSQLQueryWHERE(Var Value : String) : boolean;
    procedure ToDicitonary(const Value : String);
    procedure DicitonaryToFile;
  end;

var
  FormMain: TFormMain;

implementation

{$R *.fmx}

procedure TFormMain.FormCreate(Sender: TObject);
begin
//  FAppPath:=TPath.GetDirectoryName(ParamStr(0));
  FAppPath:='D:\UTM5\#provodov_net.ru\Билинг\Оптимизация базы\';
end;

procedure TFormMain.FormShow(Sender: TObject);
begin
  ExtractSQLQuery;
end;

procedure TFormMain.ButtonStartClick(Sender: TObject);
begin
  ExtractSQLQuery;
end;

function TFormMain.ProcessingSQLQueryWHERE(Var Value : String) : boolean;
Var Index1, Index2 : Integer;
    MainString, WHEREString, S : String;
    I : Integer;
    WHEREArray : TArray<String>;
    ADict : TDictionary<String,String>;

begin
  Index1:=Value.IndexOf(' WHERE');
  MainString:=Value.Substring(0, Index1);

  WHEREString:=Value.Remove(0, Index1);
  WHEREString:=WHEREString.Replace('ORDER BY', ' ', [rfReplaceAll]);
  WHEREString:=WHEREString.Replace('DESC', '', [rfReplaceAll]);
  WHEREString:=WHEREString.Replace('WHERE ', '', [rfReplaceAll]);
  WHEREString:=WHEREString.Replace('(', '', [rfReplaceAll]);
  WHEREString:=WHEREString.Replace(')', '', [rfReplaceAll]);
  WHEREString:=WHEREString.Replace('AND', '', [rfReplaceAll]);
  WHEREString:=WHEREString.Replace('OR', '', [rfReplaceAll]);
  WHEREString:=WHEREString.Replace('<>', '', [rfReplaceAll]);
  WHEREString:=WHEREString.Replace('>', '', [rfReplaceAll]);
  WHEREString:=WHEREString.Replace('<', '', [rfReplaceAll]);
  WHEREString:=WHEREString.Replace('''', '', [rfReplaceAll]);
  WHEREString:=WHEREString.Replace('"', '', [rfReplaceAll]);
  WHEREString:=WHEREString.Replace('=', ' ', [rfReplaceAll]);
  WHEREString:=WHEREString.Replace('&', ' ', [rfReplaceAll]);
  WHEREString:=WHEREString.Replace('-', '', [rfReplaceAll]);
  for I := 0 to 9 do
    WHEREString:=WHEREString.Replace(I.ToString, '');
  WHEREString:=WHEREString.Replace('  ', ' ', [rfReplaceAll]);
  WHEREString:=WHEREString.Replace('  ', ' ', [rfReplaceAll]);
  WHEREString:=WHEREString.Replace('  ', ' ', [rfReplaceAll]);

  WHEREString:=WHEREString.Trim;
  WHEREArray:=WHEREString.Split([' ']);
  if Length(WHEREArray) > 1 then
  begin
    ADict:=TDictionary<String,String>.Create;
    for I := Low(WHEREArray) to High(WHEREArray) do
      ADict.AddOrSetValue(WHEREArray[I], WHEREArray[I]);
    WHEREString:='';
    for S in ADict.Keys do
    begin
      WHEREString:=WHEREString + S + ', ';
    end;
    WHEREString:=WHEREString.TrimRight([' ', ',']);
    ADict.Free;
  end;
  Value:=MainString + '|' + WHEREString;
end;


function TFormMain.ProcessingSQLQueryDELETE(Var Value : String) : boolean;
Var Index1, Index2 : Integer;
    ID1, ID2 : String;
begin
  Result:=False;
  if Not Value.Contains(' DELETE ') then
    exit;

  Index1:=Value.IndexOf('DELETE ');
  Value:=Value.Remove(0, Index1);

  Value:=Value.Replace('FROM ', '');
  Value:=Value.Replace('DELETE ', 'DELETE|');
  Result:=True;
end;

function TFormMain.ProcessingSQLQuerySELECT(Var Value : String) : boolean;
Var Index1, Index2 : Integer;
    ID1, ID2 : String;
begin
  Result:=False;
  if Not Value.Contains(' SELECT ') then
    exit;

  Index1:=Value.IndexOf(': SELECT');
  Value:=Value.Remove(0, Index1 + 2);

  Index1:=Value.IndexOf('SELECT');
  Index1:=Index1 + 6;
  Index2:=Value.IndexOf('FROM');
  Index2:=Index2 + 4;
  Value:=Value.Remove(Index1, Index2 - Index1);
  Value:=Value.Replace('SELECT ', 'SELECT|');
  Result:=True;
end;

function TFormMain.ProcessingSQLQueryUPDATE(Var Value : String) : boolean;
Var Index1, Index2 : Integer;
    ID1, ID2 : String;
begin
  Result:=False;
  if Not Value.Contains(' UPDATE ') then
    exit;
  Index1:=Value.IndexOf('UPDATE ');
  Value:=Value.Remove(0, Index1);
  Index1:=Value.IndexOf(' SET ');
  Index1:=Index1;
  Index2:=Value.IndexOf(' WHERE ');
  Value:=Value.Remove(Index1, Index2 - Index1);
  Value:=Value.Replace('UPDATE ', 'UPDATE|');
  Result:=True;
end;

function TFormMain.ProcessingSQLQuery(Var Value : String) : boolean;
Var Index : Integer;
    ID1, ID2 : String;
begin
  Result:=False;
  if Not Value.Contains('WHERE') then
    exit;
  ProcessingSQLQueryUPDATE(Value);
  ProcessingSQLQueryDELETE(Value);
  ProcessingSQLQuerySELECT(Value);
  ProcessingSQLQueryWHERE(Value);
  Result:=True;
end;

function TFormMain.ExtractTime(const Value : String) : String;
Var Index : Integer;
    ID1, ID2 : String;
begin
  Result:='';
  Index:=Value.IndexOf('takes');
  if Index = -1 then
    Index:=Value.IndexOf('ws in ');
  Result:=Value.Substring(Index + 6, Value.Length);
  Index:=Result.IndexOf(' sec');
  if Index = -1 then
    exit;
  Result:=Result.Substring(0, Index);
end;

function TFormMain.CompareLine(const Value1, Value2 : String) : boolean;
Var Index : Integer;
    ID1, ID2 : String;
begin
  Result:=False;
  if Value2.IsEmpty then
    exit;
  Index:=Value1.IndexOf('>');
  if Index = -1 then
    exit;
  ID1:=Value1.Substring(0, Index);
  Index:=Value2.IndexOf('>');
  if Index = -1 then
    exit;
  ID2:=Value2.Substring(0, Index);
  if ID1.Equals(ID2) then
    Result:=True;
end;

function TFormMain.RemoveTimeStamp(const Value : String) : String;
Var Index : Integer;
begin
  Index:=Value.IndexOf('<');
  Result:=Value.Substring(Index, Value.Length);
end;

function TFormMain.IsSQLQueryTakes(const Value : String) : Boolean;
begin
  Result:=True;
  if Value.Contains('SQL query takes') then
    exit;
  if Value.Contains('SQL SELECT query') AND Value.Contains('rows in') then
    exit;
  Result:=False;
end;

function TFormMain.IsSQLQuery(const Value : String) : Boolean;
begin
  Result:=True;
  if Value.Contains('SQL query:') then
    exit;
  if Value.Contains('SQL SELECT query: SELECT') then
    exit;
  Result:=False;
end;

function TFormMain.IsSQL(const Value : String) : Boolean;
begin
  Result:=True;
  if Value.Contains('> SQL') then
    exit;
  Result:=False;
end;

procedure TFormMain.ToDicitonary(const Value : String);
Var ValueArray : TArray<String>;
    Key : String;
    QueryRecord : TQuery;
    ATime, AAverageTime : Double;
begin
  ValueArray:=Value.Split(['|']);
  Key:=ValueArray[1] + ValueArray[2] + ValueArray[3];
  ValueArray[0]:=ValueArray[0].Replace('.', ',');
  ATime:=ValueArray[0].ToDouble();
  if FQueryDictionary.ContainsKey(Key) then
  begin
    QueryRecord:=FQueryDictionary.Items[Key];
    AAverageTime:=QueryRecord.AverageTime;
    AAverageTime:=AAverageTime * QueryRecord.Count + ATime;
    Inc(QueryRecord.Count);
    QueryRecord.AverageTime:=AAverageTime / QueryRecord.Count;
  end
  else
  begin
    QueryRecord.Count:=1;
    QueryRecord.AverageTime:=ATime;
    QueryRecord.QueryType:=ValueArray[1];
    QueryRecord.QueryTables:=ValueArray[2];
    QueryRecord.QueryWhere:=ValueArray[3];
  end;
  FQueryDictionary.AddOrSetValue(Key, QueryRecord);
end;

procedure TFormMain.DicitonaryToFile;
Var ValueArray : TArray<String>;
    Key, FileResultName, S : String;
    QueryRecord : TQuery;
    AAverageTime, ACount : String;
    AList : TList<TQuery>;
    I : Integer;
    Comparer: IComparer<TQuery>;
begin
  FileResultName:=TPath.Combine(FAppPath, 'SQLQueriesResult.txt');
  if TFile.Exists(FileResultName) then
    TFile.Delete(FileResultName);
  Comparer := TDelegatedComparer<TQuery>.Create(
    function(const Left, Right: TQuery): Integer
    begin
      Result := Right.Count - Left.Count;
    end);
  AList:=TList<TQuery>.Create(Comparer);
  for Key in FQueryDictionary.Keys do
  begin
    QueryRecord:=FQueryDictionary.Items[Key];
    AList.Add(QueryRecord);
  end;
  AList.Sort;
  for I := 0 to AList.Count - 1 do
  begin
    QueryRecord:=AList.Items[I];
    AAverageTime:=FloatToStrF(QueryRecord.AverageTime, TFloatFormat.ffFixed, 3, 5);
    ACount:=QueryRecord.Count.ToString;
    S:=QueryRecord.Count.ToString.PadLeft(8) +
      #9 + AAverageTime + #9 + QueryRecord.QueryType + ' | ' + QueryRecord.QueryTables.PadRight(92) + '|' + QueryRecord.QueryWhere + #13#10;
    TFile.AppendAllText(FileResultName, S, TEncoding.UTF8);
  end;
  TFile.AppendAllText(FileResultName, #13#10, TEncoding.UTF8);
  S:='Количество запросов, среднее время, тип запроса, таблицы запроса, поля в WHERE и ORDER BY' + #13#10;
  TFile.AppendAllText(FileResultName, S, TEncoding.UTF8);

  S:='Проанализировано ' + FLines.ToString + ' строк логов UTM5' + #13#10;
  TFile.AppendAllText(FileResultName, S, TEncoding.UTF8);
end;


procedure TFormMain.ExtractSQLQuery;
Var LogPath : String;
//    FileResultName,
    Line, Line1, Line2 : String;
    J,I : Integer;
    FilesArray, Lines, AllLines : TStringDynArray;
//    StreamWriter : TStreamWriter;
begin
  FLines:=0;
  LogPath:=TPath.Combine(FAppPath, 'Logs');
//  LogPath:='D:\UTM5\#provodov_net.ru\Билинг\Оптимизация базы\Logs';
//  FileResultName:=TPath.Combine(FAppPath,
//  FileResultName:='D:\UTM5\#provodov_net.ru\Билинг\Оптимизация базы\SQLQueries.txt';
//  if TFile.Exists(FileResultName) then
//    TFile.Delete(FileResultName);
  if Not TDirectory.Exists(LogPath) then
  begin
    Memo.Lines.Add('Путь не найден ' + LogPath);
    exit;
  end;

  FilesArray:=TDirectory.GetFiles(LogPath);

//  StreamWriter:=TFile.AppendText(FileResultName);
//  StreamWriter:=TFile.AppendText(FileResultName);
//  StreamWriter:=TStreamWriter.Create(
//    TFileStream.Create(FileResultName, fmCreate),
//    TEncoding.ASCII,
//    50000
//  );
//  StreamWriter.AutoFlush:=False;
//  StreamWriter.Encoding:=TEncoding.ASCII;
//  StreamWriter.NewLine:=#10;
  FQueryDictionary:=TQueryDictionary.Create;
  for I := Low(FilesArray) to High(FilesArray) do
  begin
    Memo.Lines.Add(FilesArray[I]);
    Application.ProcessMessages;
    Lines:=TFile.ReadAllLines(FilesArray[I]);
    Line1:='';
    Line2:='';
    for J := Low(Lines) to High(Lines) do
    begin
      Inc(FLines);
      if IsSQL(Lines[J]) then
      begin
        Line:=RemoveTimeStamp(Lines[J]);
        if IsSQLQuery(Line) then
          Line1:=Line;
        if IsSQLQueryTakes(Line) then
          Line2:=Line;
        if CompareLine(Line1, Line2) then
        begin
          if ProcessingSQLQuery(Line1) then
          begin
            Line:=ExtractTime(Line2) + '|' + Line1;
//            StreamWriter.WriteLine(Line);
            ToDicitonary(Line);
          end;
          Line1:='';
          Line2:='';
        end;
//        SetLength(AllLines, Length(AllLines) + 1);
//        AllLines[High(AllLines)]:=Lines[J];
      end;
    end;
    SetLength(Lines, 0);
//    StreamWriter.Flush;
//    break;
  end;
//  StreamWriter.BaseStream.Free;
//  StreamWriter.Free;
  DicitonaryToFile;
  Memo.Lines.Add('Stop');
  Application.Terminate;
end;

end.
