{InhDepartamentoDM.pas - Inhunmi Departamento DataModule

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

unit InhDepartamentoDM;

interface

uses
  SysUtils, Classes, Provider, SqlExpr, DB, DBClient, DBLocal, DBLocalS,
  QControls, InhBiblio, InhDbForm, InhStringResources;

type
  TDepartamentoDM = class(TDataModule)
    DepartamentoDSet: TSQLClientDataSet;
    DepartamentoDSource: TDataSource;
    DepartamentoDSetid: TIntegerField;
    DepartamentoDSetnome: TStringField;
    procedure InhDepartamentoMasterAfterPost(DataSet: TDataSet);
    procedure DepartamentoDSetBeforeDelete(DataSet: TDataSet);
  private
    { Private declarations }
  public
    DbForm : TInhDbForm;
    function  DMOpen() : boolean;
  end;

var
  DepartamentoDM: TDepartamentoDM;

implementation

uses InhDepartamento, InhDlgUtils;

{$R *.xfm}

// Master & Detail DataSet Opening
function  TDepartamentoDM.DMOpen() : boolean;
begin
   Result := InhDataSetOpenMaster(DepartamentoDSet);
end;

// Master's AfterPost event handler
procedure TDepartamentoDM.InhDepartamentoMasterAfterPost(DataSet: TDataSet);
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
procedure TDepartamentoDM.DepartamentoDSetBeforeDelete(DataSet: TDataSet);
begin
   if InhDlgRecordMasterDeleteConfirmation('Departamento') <> True then
      Abort;
end;

end.
