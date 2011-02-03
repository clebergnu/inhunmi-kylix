{InhProdutoGrupoDM.pas - Grupos de Produtos DataModule

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

unit InhProdutoGrupoDM;

interface

uses
  SysUtils, Classes, Provider, SqlExpr, DB, DBClient, DBLocal, DBLocalS,
  QControls, InhBiblio, InhDbForm;

type
  TProdutoGrupoDM = class(TDataModule)
    ProdutoGrupoDSet: TSQLClientDataSet;
    ProdutoGrupoDSource: TDataSource;
    ProdutoGrupoDSetid: TIntegerField;
    ProdutoGrupoDSetdescricao: TStringField;
    procedure ProdutoGrupoDSetAfterPost(DataSet: TDataSet);
    procedure ProdutoGrupoDSetBeforeDelete(DataSet: TDataSet);
  private
    { Private declarations }
  public
    DbForm : TInhDbForm;
    function  DMOpen() : boolean;
  end;

var
  ProdutoGrupoDM: TProdutoGrupoDM;

implementation

uses InhProdutoGrupo, InhDlgUtils;

{$R *.xfm}

// Master & Detail DataSet Opening
function  TProdutoGrupoDM.DMOpen () : boolean;
begin
   Result := InhDataSetOpenMaster (ProdutoGrupoDSet);
end;

// Master's AfterPost event handler
procedure TProdutoGrupoDM.ProdutoGrupoDSetAfterPost(DataSet: TDataSet);
begin
   InhDataSetMasterAfterPost (DataSet);
end;

// Confirmation of Master/Detail records deletion
procedure TProdutoGrupoDM.ProdutoGrupoDSetBeforeDelete(DataSet: TDataSet);
begin
   if InhDlgRecordMasterDeleteConfirmation('Grupo de Produto') <> True then
      Abort;
end;


end.

