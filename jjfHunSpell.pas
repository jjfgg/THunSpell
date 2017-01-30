(* ***** BEGIN LICENSE BLOCK *****
 * Version: MPL 2.0/GPL 2.0/LGPL 2.1
 *
 * The contents of this file are subject to the Mozilla Public License Version
 * 2.0 (the "License"); you may not use this file except in compliance with
 * the License. You may obtain a copy of the License at
 * http://www.mozilla.org/MPL/
 *
 * Software distributed under the License is distributed on an "AS IS" basis,
 * WITHOUT WARRANTY OF ANY KIND, either express or implied. See the License
 * for the specific language governing rights and limitations under the
 * License.
 *
 * Copyright (C) 2017
 * Juan José Grajeda
 * All Rights Reserved.
 *
 * Contributor(s):
 *
 *
 * Alternatively, the contents of this file may be used under the terms of
 * either the GNU General Public License Version 2.0 or later (the "GPL"), or
 * the GNU Lesser General Public License Version 2.1 or later (the "LGPL"),
 * in which case the provisions of the GPL or the LGPL are applicable instead
 * of those above. If you wish to allow use of your version of this file only
 * under the terms of either the GPL or the LGPL, and not to allow others to
 * use your version of this file under the terms of the MPL, indicate your
 * decision by deleting the provisions above and replace them with the notice
 * and other provisions required by the GPL or the LGPL. If you do not delete
 * the provisions above, a recipient may use your version of this file under
 * the terms of any one of the MPL, the GPL or the LGPL.
 *
 * ***** END LICENSE BLOCK ***** **)

 unit jjfHunSpell;

interface

uses
  Windows, System.SysUtils, System.Classes, AnsiStrings;

type
  THunSpell = Class;

  THunSpellNotifyEvent = procedure(Sender: THunSpell) of object;
  THunSpellListNotifyEvent = procedure(Sender: THunSpell; List: TStrings) of object;

  THunSpell = Class
    var
      FSpell: Pointer;
  private
    FSuggestions: TStrings;
    FDictionaries: TStrings;
    FDictionaryDir: string;
    FDictionary: string;
    FEncoding: TMBCSEncoding;
    FOnDictionaryChange: THunspellNotifyEvent;
    FOnSuggestionsChange: THunspellListNotifyEvent;
    FOnDirectoryChange: THunspellListNotifyEvent;
    function GetInitialized: Boolean;
    function GetAndCheckSpell: Pointer;
    procedure FillSuggestions(Len: integer; const Wrds: PPAnsiChar);
    procedure Unassign;
    procedure SetDictionaryDir(const Value: string);
    procedure LoadDictionaryNames;
    function Encode(AWord: string): ShortString;
    function Decode(pWord: PAnsiChar): string;
    procedure SetDictionary(const Value: string);
    procedure SetOnDictionaryChange(const Value: THunspellNotifyEvent);
    procedure SetOnDirectoryChange(const Value: THunspellListNotifyEvent);
    procedure SetOnSuggestionsChange(const Value: THunspellListNotifyEvent);
    function GetShortDictionary: string;
  public
    constructor Create(ADic: string); overload;
    constructor Create(ADir, ADic: string); overload;
    destructor Destroy;
    function SetDict(ADic: string): Boolean;
    function Spell(AWord: string): Boolean;
    procedure Suggest(AWord: string; Auto: Boolean = False);
    function GetDicEncodign: string;
    function PutWord(AWord: string): Integer;
    property Initialized: Boolean read GetInitialized;
    property Suggestions: TStrings read FSuggestions;
    property DictionaryDir: string read FDictionaryDir write SetDictionaryDir;
    property Dictionaries: TStrings read FDictionaries;
    property Dictionary: string read FDictionary write SetDictionary;
    property ShortDictionary: string read GetShortDictionary;
    property OnDirectoryChange: THunspellListNotifyEvent read FOnDirectoryChange write SetOnDirectoryChange;
    property OnDictionaryChange: THunspellNotifyEvent read FOnDictionaryChange write SetOnDictionaryChange;
    property OnSuggestionsChange: THunspellListNotifyEvent read FOnSuggestionsChange write SetOnSuggestionsChange;

  End;


implementation

uses
  System.IOUtils;
  
function hunspell_initialize(aff_file: PAnsiChar; dict_file: PAnsiChar): Pointer; cdecl;
  external 'hunspelldll.dll' name 'hunspell_initialize';
procedure hunspell_uninitialize(spell: Pointer); cdecl;
  external 'hunspelldll.dll' name 'hunspell_uninitialize';
function hunspell_spell(spell: Pointer; word: PAnsiChar): Boolean; cdecl;
  external 'hunspelldll.dll' name 'hunspell_spell';
function hunspell_suggest(spell: Pointer; word: PAnsiChar; var suggestions: PPAnsiChar): Integer; cdecl;
  external 'hunspelldll.dll' name 'hunspell_suggest';
function hunspell_suggest_auto(spell: Pointer; word: PAnsiChar; var suggestions: PPAnsiChar): Integer; cdecl;
  external 'hunspelldll.dll' name 'hunspell_suggest_auto';
procedure hunspell_suggest_free(spell: Pointer; suggestions: PPAnsiChar; suggestLen: Integer); cdecl;
  external 'hunspelldll.dll' name 'hunspell_suggest_free';
function hunspell_get_dic_encoding (spell: Pointer): PAnsiChar; cdecl;
  external 'hunspelldll.dll' name 'hunspell_get_dic_encoding';
function hunspell_put_word(spell: Pointer; word: PAnsiChar): Integer; cdecl;
  external 'hunspelldll.dll' name 'hunspell_put_word';

function CharSetNameToCodePage(const AName: string): Integer;
const
  NameCount = 35;
type
  TCharSetInfo = record
    Name: string;
    CodePage: Cardinal;
  end;
  TCharSetArray = array[0..NameCount-1] of TCharSetInfo;
const
  CSetNames: TCharSetArray = (
    (Name: 'Latin-US (DOS)'; CodePage: 437),
    (Name: 'Western (DOS Latin 1)'; CodePage: 850),
    (Name: 'Thai (Windows, DOS)'; CodePage: 874),
    (Name: 'Japanese (Windows, DOS)'; CodePage: 932),
    (Name: 'Simplified Chinese (Windows, DOS)'; CodePage: 936),
    (Name: 'Korean (Windows, DOS)'; CodePage: 949),
    (Name: 'Traditional Chinese (Windows, DOS)'; CodePage: 950),
    (Name: 'Unicode (UTF-16)'; CodePage: 1200),
    (Name: 'Unicode (UTF-16LE)'; CodePage: 1200),
    (Name: 'Unicode (UTF-16BE)'; CodePage: 1201),
    (Name: 'Central European (Windows Latin 2)'; CodePage: 1250),
    (Name: 'Cyrillic (Windows)'; CodePage: 1251),
    (Name: 'Western (Windows Latin 1)'; CodePage: 1252),
    (Name: 'Greek (Windows)'; CodePage: 1253),
    (Name: 'Turkish (Windows Latin 5)'; CodePage: 1254),
    (Name: 'Hebrew (Windows)'; CodePage: 1255),
    (Name: 'Arabic (Windows)'; CodePage: 1256),
    (Name: 'Baltic (Windows)'; CodePage: 1257),
    (Name: 'Vietnamese (Windows)'; CodePage: 1258),
    (Name: 'Western (ASCII)'; CodePage: 20127),
    (Name: 'Unicode (UTF-7)'; CodePage: CP_UTF7),
    (Name: 'Unicode (UTF-8)'; CodePage: CP_UTF8),
    // Windows code pages...
    (Name: 'Windows-1252'; CodePage: 1252),
    (Name: 'US-ASCII'; CodePage: 20127),
    (Name: 'UTF-7'; CodePage: CP_UTF7),
    (Name: 'UTF-8'; CodePage: CP_UTF8),
    (Name: 'UTF-16'; CodePage: 1200),
    (Name: 'UTF-16BE'; CodePage: 1201),
    (Name: 'UTF-16LE'; CodePage: 1200),
    (Name: 'SHIFT-JIS'; CodePage: 932),
    (Name: 'ISO-8859-1'; CodePage: 28591),
    (Name: 'iso-8859-1'; CodePage: 28591),
    (Name: 'MACCROATIAN'; CodePage: 10082),
    (Name: 'ASCII'; CodePage: 20127),
    (Name: ''; CodePage: 0)
  );

  function Normalize(Name:string):string;
  begin
    Result := Trim(UpperCase(Name));
    Result := ReplaceStr(Result,'-','');
  end;
  
var
  I: Integer;
begin
  Result := -1;
                                                                        
  for I := Low(CSetNames) to High(CSetNames) do
  begin
    if Normalize(CSetNames[I].Name) = Normalize(AName) then
    begin
      Result := CSetNames[I].CodePage;
      Exit
    end;
  end;
end;

  
{ THunSpell }

constructor THunSpell.Create(ADic: string);
begin
  Create(TPath.GetDirectoryName(ADic),TPath.GetFileName(ADic));
end;

constructor THunSpell.Create(ADir, ADic: string);
begin
  FSuggestions := TStringList.Create;
  DictionaryDir := ADir;
  SetDict(ADic);  
end;

function THunSpell.Decode(pWord: PAnsiChar): string;
var
  Temp: TBytes;
begin
  SetLength(Temp,Length(pWord)*SizeOf(AnsiChar));
  Move(pWord^,Temp[0],Length(Temp));
  
  Temp := FEncoding.Convert (FEncoding, FEncoding.Unicode, Temp);

  SetLength(Temp,Length(Temp)+1);
  Temp[Length(Temp)] := 0;

  Result := PChar(@Temp[0]);
end;

destructor THunSpell.Destroy;
begin
  if Assigned(FSuggestions) then
    FreeAndNil(FSuggestions);

  if Assigned(FDictionaries) then
    FreeAndNil(FDictionaries);
  Unassign;
  inherited;
end;

function THunSpell.Encode(AWord: string): ShortString;
var
  Temp: TBytes;
  P : ^Byte;
  I: Integer;
begin
  P := Pointer(PChar(AWord));
  SetLength(Temp,Length(AWord)*SizeOf(Char));
  Move(P^,(@Temp[0])^,Length(Temp));
  
  Temp := FEncoding.Convert (FEncoding.Unicode, FEncoding, Temp);
  SetLength(Temp,Length(Temp)+1);
  Temp[Length(Temp)] := 0;

  Byte(Result[0]) := Length(Temp);
  Move(Temp[0],Result[1],Length(Temp));
end;

procedure THunSpell.FillSuggestions(Len: integer; const Wrds: PPAnsiChar);
var
  i: Integer;
  iWrds: PPAnsiChar;

begin
  FSuggestions.Clear;

  iWrds := Wrds;
  for i := 1 to Len do
  begin

    FSuggestions.Add( Decode(iWrds^));
    iwrds :=  Pointer(Integer(iWrds) + sizeOf(Pointer));
  end;
  if Assigned(FOnSuggestionsChange) then
    FOnSuggestionsChange(Self, FSuggestions);
end;

function THunSpell.GetAndCheckSpell: Pointer;
begin
  if not Assigned(FSpell) then
    raise Exception.Create('El diccionario no fue inicializado');

  Result := FSpell;
end;

function THunSpell.GetDicEncodign: string;
begin
  if Assigned(FSpell) then
    Result := hunspell_get_dic_encoding(FSpell)
  else
    Result := 'El diccionario no está inicializado';
end;

function THunSpell.GetInitialized: Boolean;
begin
  Result := Assigned(FSpell);
end;

function THunSpell.GetShortDictionary: string;
begin
  Result := ExtractFileName(FDictionary);
end;

procedure THunSpell.LoadDictionaryNames;
var
  sr: TSearchRec;
  FileAttrs: Integer;
begin
  if not Assigned(FDictionaries) then
    FDictionaries := TStringList.Create
  else
    FDictionaries.Clear;
    
  FileAttrs := faNormal;
  if System.SysUtils.FindFirst(FDictionaryDir+'*.dic', FileAttrs, sr) = 0 then
  begin
    repeat
//        if (sr.Attr and FileAttrs) = sr.Attr then
      FDictionaries.Add(sr.Name);
    until FindNext(sr) <> 0;
    FindClose(sr);
  end;
end;

function THunSpell.PutWord(AWord: string): Integer;
var
  sWord: ShortString;
begin
  sWord := Encode(AWord);
  Result := hunspell_put_word(GetAndCheckSpell,@sWord[1]);
end;

function THunSpell.SetDict(ADic: string): Boolean;
var
  aff, dic: ShortString;
  CodePage: Cardinal;
  Dir : string;
begin
  Result := true;

  if TPath.IsDriveRooted(ADic) then
    Dir := ''
  else
    Dir := FDictionaryDir;

  // utiliza las extensiones default independientemente de la que traiga ADic
  aff := Dir + TPath.ChangeExtension(ADic,'.aff')+#0;
  dic := Dir + TPath.ChangeExtension(ADic,'.dic')+#0;

  Result := FileExists(aff) and FileExists(dic);

  if Result then
  begin
    Unassign;
    FSpell := hunspell_initialize(@aff[1], @dic[1]);
  end;

  Result := Initialized;

  if Result then
  begin
    Dec(dic[0]);
    FDictionary := dic;

    CodePage := CharSetNameToCodePage(GetDicEncodign);
    if CodePage > 0  then
    begin
      FEncoding := TMBCSEncoding.Create(CodePage);
    end;
  end
  else
    FDictionary := '';

  if Assigned(FOnDictionaryChange) then
    FOnDictionaryChange(Self);
end;

procedure THunSpell.SetDictionary(const Value: string);
begin
  SetDict(Value);
end;

procedure THunSpell.SetDictionaryDir(const Value: string);
var
  Temp: string;
begin
  Temp := Trim(Value);
  if FDictionaryDir = Temp then
    Exit;

  if RightStr(Temp,1) <> '\' then
    Temp := Temp + '\';
    
  if not DirectoryExists(Temp) then
    raise Exception.Create(Format('El directorio "%s" no existe.',[Temp]));
    
  FDictionaryDir := Temp;

  LoadDictionaryNames;

  if Assigned(FOnDirectoryChange) then
    FOnDirectoryChange(Self,FDictionaries);
end;

procedure THunSpell.SetOnDictionaryChange(const Value: THunspellNotifyEvent);
begin
  FOnDictionaryChange := Value;
end;

procedure THunSpell.SetOnDirectoryChange(const Value: THunspellListNotifyEvent);
begin
  FOnDirectoryChange := Value;
end;

procedure THunSpell.SetOnSuggestionsChange(
  const Value: THunspellListNotifyEvent);
begin
  FOnSuggestionsChange := Value;
end;

function THunSpell.Spell(AWord: string): Boolean;
var
  sWord : ShortString;
begin
  sWord := Encode(AWord);
  Result := hunspell_spell(GetAndCheckSpell,@sWord[1]);
end;

procedure THunSpell.Suggest(AWord: string; Auto: Boolean = False);
var
  sWord : ShortString;
  Len : Integer;
  wrds: PPAnsiChar;

begin
  sWord := Encode(AWord);

  if Auto then
    Len := hunspell_suggest_auto(GetAndCheckSpell,@sWord[1],wrds)
  else
    Len := hunspell_suggest(GetAndCheckSpell,@sWord[1],wrds);

  FillSuggestions(Len,wrds);

  hunspell_suggest_free(GetAndCheckSpell, wrds, Len);
end;

procedure THunSpell.Unassign;
begin
  if Assigned(FSpell) then
    hunspell_uninitialize(FSpell);
  if Assigned(FEncoding) then
    FreeAndNil(FEncoding);
end;

end.
