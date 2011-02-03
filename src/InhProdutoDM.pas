{InhProdutoDM.pas - Description pending

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

unit InhProdutoDM;

interface

uses
  SysUtils, Classes, Provider, SqlExpr, DB, DBClient, DBLocal, DBLocalS,
  QControls, InhBiblio, InhDbForm, InhStringResources;

type
  TProdutoDM = class(TDataModule)
    ProdutoDSet: TSQLClientDataSet;
    ProdutoDSource: TDataSource;
    ProdutoDSetid: TIntegerField;
    ProdutoDSettipo_comprado: TStringField;
    ProdutoDSettipo_vendido: TStringField;
    ProdutoDSettipo_produzido: TStringField;
    ProdutoDSettipo_meta_grupo: TStringField;
    ProdutoDSettipo_generalizado: TStringField;
    ProdutoDSetdescricao: TStringField;
    ProdutoDSetunidade: TStringField;
    ProdutoDSetdepartamento_compra: TSmallintField;
    ProdutoDSetdepartamento_venda: TSmallintField;
    ProdutoDSetdepartamento_producao: TSmallintField;
    ProdutoDSetpreco_venda: TFloatField;
    DepartamentoDSet: TSQLClientDataSet;
    DepartamentoDSource: TDataSource;
    ProdutoGrupoDSet: TSQLClientDataSet;
    ProdutoGrupoDSource: TDataSource;
    ProdutoDSetgrupo: TIntegerField;
    ProdutoDSetestoque_minimo: TIntegerField;
    ProdutoDSetdepartamento_estoque: TIntegerField;
    ProdutoDSetquantidade_composicao: TIntegerField;
    procedure ProdutoDSetBeforeDelete(DataSet: TDataSet);
    procedure InhProdutoMasterAfterPost(DataSet: TDataSet);
  private
    { Private declarations }
  public
    DbForm : TInhDbForm;
    function DMOpen() : boolean;
  end;

var
  ProdutoDM: TProdutoDM;

implementation

uses InhProduto, InhProdutoUtils, InhDlgUtils;

{$R *.xfm}

// Master & Detail DataSet Opening
function  TProdutoDM.DMOpen() : boolean;
begin
   if (InhDataSetOpenMaster(ProdutoDSet) = False) then
      begin
         Result := False;
         exit;
      end;
   if (InhDataSetOpenMaster(DepartamentoDSet) = False) then
      begin
         Result := False;
         exit;
      end;
   if (InhDataSetOpenMaster(ProdutoGrupoDSet) = False) then
      begin
         Result := False;
         exit;
      end;

   Result := True;
end;

// Master's AfterPost event handler
procedure TProdutoDM.InhProdutoMasterAfterPost(DataSet: TDataSet);
var
   DoAfterInsertPost : boolean;
begin
   DoAfterInsertPost := (DataSet.Tag = 111);
   InhDataSetMasterAfterPost (DataSet);
   if DoAfterInsertPost then
      DbForm.MasterDataSetAfterInsertPost(DataSet)
   else
      DbForm.StatusBar.SimpleText := Format (InhStrRecordSaved, [TSQLClientDataSet(DataSet).FieldValues['id']]);
end;

// Confirmation of Master/Detail records deletion
procedure TProdutoDM.ProdutoDSetBeforeDelete(DataSet: TDataSet);
begin
   if InhDlgYesNo('A exclusão de produtos pode trazer inconsistência ao seu banco de dados, logo não é uma operação recomendada. ' +
                  'A ação recomendável é a desmarcação de atributos, como por exemplo "Vendido", para não ter mais o produto atual disponível para venda. ' + #10 + #10 +
                  'Estando ciente das conseqüencias, deseja prosseguir com a exclusão deste produto?') = True then
      begin
         if InhProdutoDelete (DataSet.FieldByName('id').AsInteger) then
            begin
               DbForm.StatusBar.SimpleText := Format ('Registro código %u (%s) excluído.',
                                                      [DataSet.FieldByName('id').AsInteger,
                                                       DataSet.FieldByName('descricao').AsString]);
               DataSet.Refresh;
            end;
      end;
   Abort;
end;

end.
