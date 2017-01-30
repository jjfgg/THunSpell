 unit uHunSpellLib;

interface

uses
  Windows, SysUtils, System.Classes;


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

implementation


end.
