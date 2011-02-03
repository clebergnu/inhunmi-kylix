{InhAcessoDM.pas - Inhunmi Acesso DataModule

 Copyright (C) 2002, Cleber Rodrigues <cleberrrjr@bol.com.br>

 This program is free software; you can redistribute it and/or modify
 it under the terms of the GNU General Public License as published by
 the Free Software Foundation; either version 2 of the License, or
 (at your option) any later version.

 This program is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 GNU General Public License for more details.

 You should have received a copy of the GNU General Public License
 along with this program; if not, write to the Free Software
 Foundation, Inc., 59 Temple Place, Suite 330, 
 Boston, MA 02111-1307, USA.
}

unit InhAcessoDM;

interface

uses
  SysUtils, Classes, Provider, SqlExpr, DB, DBClient, DBLocal, DBLocalS,
  InhMainDM, InhBiblio, QControls;

function  InhAcessoDMOpen () : boolean;
procedure InhAcessoDMClose ();

type
  TAcessoDM = class(TDataModule)
    AcessoDSet: TSQLClientDataSet;
    AcessoDSource: TDataSource;
    AcessoDSetid: TIntegerField;
    AcessoDSetusuario: TStringField;
    AcessoDSettabela_pessoa: TStringField;
    AcessoDSettabela_instituicao: TStringField;
    AcessoDSettabela_departamento: TStringField;
    AcessoDSettabela_produto: TStringField;
    AcessoDSettabela_produto_grupo: TStringField;
    AcessoDSettabela_encomenda: TStringField;
    AcessoDSettabela_consumo: TStringField;
    AcessoDSettabela_forma_pagamento: TStringField;
    AcessoDSettabela_compromisso: TStringField;
    AcessoDSetatendimento: TStringField;
    AcessoDSetcaixa: TStringField;
    AcessoDSetacesso: TStringField;
    AcessoDSetconfiguracao: TStringField;
    procedure AcessoDSetBeforePost(DataSet: TDataSet);
    procedure AcessoDSetAfterPost(DataSet: TDataSet);
    procedure AcessoDSetBeforeDelete(DataSet: TDataSet);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  AcessoDM: TAcessoDM;

implementation

uses InhAcesso, InhConfig, InhDlgUtils;

{$R *.xfm}

// Master & Detail DataSet Opening
function  InhAcessoDMOpen () : boolean;
begin
   Result := InhDataSetOpenMaster(AcessoDM.AcessoDSet);
end;

// Master & Detail DataSet Closing
procedure InhAcessoDMClose ();
begin
   AcessoDM.AcessoDSet.Close;
end;

// Fills default values of MasterDataSet before posting
procedure TAcessoDM.AcessoDSetBeforePost(DataSet: TDataSet);
begin
   if TSQLClientDataSet(DataSet).State = dsInsert then
      DataSet.Tag := 111;
end;

// Master's AfterPost event handler
procedure TAcessoDM.AcessoDSetAfterPost(DataSet: TDataSet);
begin
   InhDataSetMasterAfterPost (DataSet);
end;

// Confirmation of Master/Detail records deletion
procedure TAcessoDM.AcessoDSetBeforeDelete(DataSet: TDataSet);
begin

end;

// After scrolling, update Detail's DataSets

// Detail's BeforePost event handler

// Detail's AfterPost (and AfterDelete) event handler


end.
