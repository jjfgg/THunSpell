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
unit fMain;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  jjfHunSpell,
  Dialogs, uHunSpellLib, StdCtrls, Vcl.ExtCtrls, Vcl.ComCtrls;

type
  TFormMain = class(TForm)
    eWord: TEdit;
    bCheck: TButton;
    mSuggestions: TMemo;
    Label1: TLabel;
    StatusBar: TStatusBar;
    Bevel1: TBevel;
    bCheckAuto: TButton;
    mTest: TMemo;
    cbDiccionarios: TComboBox;
    Label2: TLabel;
    Label3: TLabel;
    procedure bCheckClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure cbDiccionariosChange(Sender: TObject);
  private
    { Private declarations }
    spell: Pointer;
    procedure HunSpellChange(Sender: THunSpell);
  public
    { Public declarations }
    HunSpell: THunSpell;
  end;

var
  FormMain: TFormMain;

implementation

{$R *.dfm}

procedure TFormMain.bCheckClick(Sender: TObject);

begin
  if HunSpell.Spell(eWord.Text) then
    mSuggestions.Lines.Text := 'Correct :)'
  else
    mSuggestions.Lines.Text := 'Incorrect word!!';

  HunSpell.Suggest(eWord.Text, TComponent(Sender).Tag = 1);
  mSuggestions.Lines.AddStrings(HunSpell.Suggestions);

  eWord.SelectAll;
end;

procedure TFormMain.cbDiccionariosChange(Sender: TObject);
begin
  HunSpell.SetDict(cbDiccionarios.Text);
end;

procedure TFormMain.FormCreate(Sender: TObject);
var
  p: string;
  I: Integer;

begin
  p := ExtractFilePath(Application.ExeName) + 'dict\';

  HunSpell := THunSpell.Create(p+'es_MX.dic');
  if HunSpell.Initialized then
  begin
    HunSpell.OnDictionaryChange := HunSpellChange;
    StatusBar.SimpleText := HunSpell.GetDicEncodign;
    cbDiccionarios.Items.Assign(HunSpell.Dictionaries);

    for I := 0 to cbDiccionarios.Items.Count - 1 do
      if cbDiccionarios.Items[I] = HunSpell.ShortDictionary then
      begin
        cbDiccionarios.ItemIndex := I;
        Break
      end;
  end;

  eWord.SelectAll;
end;

procedure TFormMain.FormDestroy(Sender: TObject);
begin
  if Assigned(HunSpell) then
    FreeAndNil(HunSpell);
end;

procedure TFormMain.HunSpellChange(Sender: THunSpell);
begin
  StatusBar.SimpleText := Sender.GetDicEncodign;
end;

end.
