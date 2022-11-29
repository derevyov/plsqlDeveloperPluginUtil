unit main;


interface

uses
  PlugInIntf, System.SysUtils, System.RegularExpressions, Windows,
  System.Classes, Vcl.Graphics, System.AnsiStrings, System.Types;

function About: PAnsiChar; cdecl;

function IdentifyPlugIn(ID: Integer): PAnsiChar; cdecl;

function CreateMenuItem(Index: Integer): PAnsiChar; cdecl;

procedure OnMenuClick(Index: Integer); cdecl;

procedure OnActivate; cdecl;

implementation

var
  PlugInID: Integer;

const // Description of this Plug-In (as displayed in Plug-In configuration dialog)
  Desc = 'sqldev utils';
// Plug-In identification, a unique identifier is received and
// the description is returned
function IdentifyPlugIn(ID: Integer): PAnsiChar; cdecl;
begin
  PlugInID := ID;

  Result := Desc;
end;
// Creating menus
function CreateMenuItem(Index: Integer): PAnsiChar; cdecl;
begin
  Result := '';

  case Index of
    1:
      Result := 'Edit / Replace params to :';
    2:
      Result := 'Edit / Replace params to et &';
    3:
      Result := 'Edit / Replace params round ';

  end;

end;

procedure OnActivate; cdecl;
var
  img, img2, img3: TBitmap;
begin
  img := TBitMap.Create;
  img2 := TBitMap.Create;
  img3 := TBitMap.Create;
  try
    img.LoadFromResourceName(HInstance, 'etBmp');
    img2.LoadFromResourceName(HInstance, 'dotBmp');
    img3.LoadFromResourceName(HInstance, 'roundBmp');

    IDE_CreateToolButton(PlugInID, 1, 'Edit / Replace to :', nil, img.handle);
    IDE_CreateToolButton(PlugInID, 2, 'Edit / Replace to et', nil, img2.handle);
    IDE_CreateToolButton(PlugInID, 3, 'Edit / Replace round', nil, img3.handle);
  except
    on e: exception do
      messagebox(0, PChar(e.message), 'q', 0);
  end;

  img.free;
  img2.free;
  img3.free;
end;

procedure replacedText(vText: string; pattern: string; var resultStr: string);
var
  vMatches: TMatchCollection;
  vMatch: TMatch;
  strZerro: string;
  i: Integer;
begin
  vMatches := TRegEx.Matches(vText, pattern);
  resultStr := vText;
  for vMatch in vMatches do
  begin
    strZerro := '';
    begin
      for i := 1 to vMatch.Length do
      begin
        strZerro := strZerro + '*';
      end;
      resultStr := StringReplace(resultStr, vMatch.Value, strZerro, []);
    end;
  end;
end;

procedure ReplaceParams(symbol: Char; round: boolean = false);
var
  vBuffer: PAnsiChar;
  vText, pattern: string;
  vMatches: TMatchCollection;
  vMatch: TMatch;
  vPoint: TPoint;
  resultStr: string;
begin
  vPoint := Point(IDE_GetCursorX, IDE_GetCursorY);
  vBuffer := IDE_GetText;

  SetString(vText, vBuffer, System.AnsiStrings.StrLen(vBuffer));

  if vText = '' then
    Exit;

  resultStr := vText;

  pattern := '(\/\*)([\s\S]*?)(\*\/)';
  replacedText(resultStr, pattern, resultStr);

  pattern := '--.*';
  replacedText(resultStr, pattern, resultStr);

  pattern := '\''.*?\''';
  replacedText(resultStr, pattern, resultStr);

  vMatches := TRegEx.Matches(resultStr, '[&:]\w+');
  for vMatch in vMatches do
  begin
    if round then
    begin
      case vText[vMatch.Index] of
        '&':
          vText[vMatch.Index] := ':';
        ':':
          vText[vMatch.Index] := '&';
      end;
    end
    else
    begin
      vText[vMatch.Index] := symbol;
    end;

  end;

  IDE_SetText(PAnsiChar(AnsiString(vText)));
  IDE_SetCursor(vPoint.X, vPoint.Y);
end;
// One of our menus is selected
procedure OnMenuClick(Index: Integer); cdecl;
begin
  case Index of
    1:
      ReplaceParams(':');
    2:
      ReplaceParams('&');
    3:
      ReplaceParams('*', true);
  end;
end;
// This function allows you to display an about dialog. You can decide to display a
// dialog yourself (in which case you should return an empty text) or just return the
// about text.
function About: PAnsiChar; cdecl;
begin
  Result := 'sqldev Plug-In utils';
end;

end.


