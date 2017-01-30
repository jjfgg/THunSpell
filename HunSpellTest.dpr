program HunSpellTest;

uses
  Forms,
  fMain in 'fMain.pas' {FormMain},
  uHunSpellLib in 'uHunSpellLib.pas',
  jjfHunSpell in 'jjfHunSpell.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TFormMain, FormMain);
  Application.Run;
end.
