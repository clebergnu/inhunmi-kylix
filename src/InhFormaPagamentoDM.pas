{InhFormaPagamentoDM.pas - Description pending

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

unit InhFormaPagamentoDM;

interface

uses
  SysUtils, Classes, InhMainDM, Provider, SqlExpr, DB, DBClient, DBLocal,
  DBLocalS, DBXPress, QControls, InhBiblio, InhDbForm, InhStringResources;

type
  TFormaPagamentoDM = class(TDataModule)
    FormaPagamentoDSet: TSQLClientDataSet;
    FormaPagamentoDSource: TDataSource;
    FormaPagamentoDSetid: TSmallintField;
    FormaPagamentoDSetdescricao: TStringField;
    FormaPagamentoDSettipo_troco: TStringField;
    FormaPagamentoDSettipo_contra_vale: TStringField;
    procedure FormaPagamentoDSetBeforeDelete(DataSet: TDataSet);
    procedure FormaPagamentoDSetAfterPost(DataSet: TDataSet);
  private
    { Private declarations }
  public
    DbForm : TInhDbForm;
    function  DMOpen() : boolean;
  end;

var
  FormaPagamentoDM: TFormaPagamentoDM;

implementation

uses InhFormaPagamento, InhDlgUtils;

{$R *.xfm}

// Master & Detail DataSet Opening
function TFormaPagamentoDM.DMOpen () : boolean;
begin
   Result := InhDataSetOpenMaster (FormaPagamentoDSet);
end;

// Master's AfterPost event handler
procedure TFormaPagamentoDM.FormaPagamentoDSetAfterPost(DataSet: TDataSet);
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
procedure TFormaPagamentoDM.FormaPagamentoDSetBeforeDelete(DataSet: TDataSet);
begin
   if InhDlgRecordMasterDeleteConfirmation('Forma de Pagamento') <> True then
      Abort;
end;

end.
