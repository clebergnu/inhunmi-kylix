{InhPessoaDM.pas - Inhunmi Pessoa DataModule

 Copyright (C) 2002 Cleber Rodrigues <cleberrrjr@bol.com.br>

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

unit InhPessoaDM;

interface

uses
  SysUtils, Classes, Provider, SqlExpr, FMTBcd, DB, DBClient, DBLocal,
  DBLocalS, QControls, InhMainDM, InhBiblio, InhDbForm, InhStringResources;

type
  TPessoaDM = class(TDataModule)
    PessoaDSet: TSQLClientDataSet;
    PessoaDSource: TDataSource;
    FoneDSource: TDataSource;
    FoneDSet: TSQLClientDataSet;
    EMailDSet: TSQLClientDataSet;
    EMailDSource: TDataSource;
    EnderecoDSet: TSQLClientDataSet;
    EnderecoDSource: TDataSource;
    ContatoParentescoDSet: TSQLClientDataSet;
    ContatoParentescoDSource: TDataSource;
    ContatoParentescoNomeDSet: TSQLClientDataSet;
    ContatoParentescoNomeDSetid: TIntegerField;
    ContatoParentescoNomeDSetnome: TStringField;
    ContatoParentescoNomeDSource: TDataSource;
    ContatoParentescoDSetid: TIntegerField;
    ContatoParentescoDSetdono: TIntegerField;
    ContatoParentescoDSetcontato_parente: TIntegerField;
    ContatoParentescoDSettipo: TStringField;
    FoneDSetid: TIntegerField;
    FoneDSetdono: TIntegerField;
    FoneDSettipo: TStringField;
    FoneDSetddd: TBCDField;
    FoneDSetnumero: TBCDField;
    ContatoParentescoDSetcontato_parente_nome: TStringField;
    PessoaInstituicaoDSource: TDataSource;
    PessoaDSetdono: TIntegerField;
    PessoaDSettratamento: TStringField;
    PessoaDSetnome_favorito: TStringField;
    PessoaDSetdata_nascimento: TDateField;
    PessoaDSetrg: TStringField;
    PessoaDSetcpf: TStringField;
    PessoaInstituicaoDSet: TSQLClientDataSet;
    PessoaInstituicaoDSetid: TIntegerField;
    PessoaInstituicaoDSetnome: TStringField;
    PessoaInstituicaoDSettipo: TStringField;
    EnderecoDSetid: TIntegerField;
    EnderecoDSetdono: TIntegerField;
    EnderecoDSetendereco_logradouro: TStringField;
    EnderecoDSetendereco_numero: TStringField;
    EnderecoDSetendereco_apartamento: TStringField;
    EnderecoDSetendereco_complemento: TStringField;
    EnderecoDSetendereco_cep: TStringField;
    EnderecoDSetendereco_bairro: TStringField;
    EnderecoDSetendereco_referencia: TStringField;
    EMailDSetid: TIntegerField;
    EMailDSetdono: TIntegerField;
    EMailDSetemail: TStringField;
    EMailDSettipo: TStringField;
    EMailDSetfavorito: TStringField;
    PessoaInstituicaoDSettipo_cliente: TStringField;
    PessoaInstituicaoDSettipo_cliente_vip: TStringField;
    PessoaInstituicaoDSettipo_cliente_pendente: TStringField;
    PessoaInstituicaoDSettipo_funcionario: TStringField;
    PessoaInstituicaoDSettipo_fornecedor: TStringField;
    procedure PessoaInstituicaoDSetAfterPost(DataSet: TDataSet);
    procedure PessoaInstituicaoDSetBeforeDelete(DataSet: TDataSet);
    procedure DetailBeforePost(DataSet: TDataSet);
    procedure DetailAfterPost(DataSet: TDataSet);
    procedure PessoaDSetBeforeEdit(DataSet: TDataSet);
  private
    { Private declarations }
  public
     DbForm : TInhDbForm;
     function  DMOpen () : boolean;
  end;

var
  PessoaDM: TPessoaDM;

implementation

uses InhPessoa, InhPessoaInstituicaoDM, InhPessoaUtils, InhDlgUtils;

{$R *.xfm}

// Master & Detail DataSet Opening
function TPessoaDM.DMOpen () : boolean;
begin
   // DataSets that should always be opened
   if (InhDataSetOpenMaster(PessoaInstituicaoDSet) = False) then
      begin
         Result := False;
         exit;
      end;
   if (InhDataSetOpenJoint(PessoaDSet, PessoaInstituicaoDSet) = False) then
      begin
         Result := False;
         exit;
      end;
   // If Form has not been created, open only first detail DataSet
   if (DbForm = nil) then
      begin
         if (InhDataSetOpenDetail(FoneDSet, PessoaInstituicaoDSet) = False) then
            begin
               Result := False;
               exit;
            end;
      end;
   Result := True;
end;

// Master's AfterPost event handler
procedure TPessoaDM.PessoaInstituicaoDSetAfterPost(DataSet: TDataSet);
var
   DoAfterInsertPost : boolean;
begin
   DoAfterInsertPost := (DataSet.Tag = 111);
   InhDataSetMasterAfterPost (DataSet);
   if PessoaDSet.RecordCount = 0 then
      begin
         PessoaDSet.Append;
         PessoaDSet.FieldValues['dono'] := DataSet.FieldValues['id'];
         PessoaDSet.ApplyUpdates(-1);
         PessoaDSet.Refresh;
      end
   else if (PessoaDSet.State in [dsEdit]) then
      PessoaDSet.Post;

   if DoAfterInsertPost then
      DbForm.MasterDataSetAfterInsertPost(DataSet)
   else
      DbForm.StatusBar.SimpleText := Format (InhStrRecordSaved, [TSQLClientDataSet(DataSet).FieldValues['id']]);
end;

// Confirmation of Master/Detail records deletion
procedure TPessoaDM.PessoaInstituicaoDSetBeforeDelete(DataSet: TDataSet);
begin
   if InhDlgRecordMasterDeleteConfirmation('Pessoa') = True then
      begin
         if InhPessoaDelete (DataSet.FieldByName('id').AsInteger) then
            begin
               DbForm.StatusBar.SimpleText := Format ('Registro código %u (%s) excluído.',
                                                      [DataSet.FieldByName('id').AsInteger,
                                                       DataSet.FieldByName('nome').AsString]);
               DataSet.Refresh;
            end;
      end;
   Abort;
end;

// Detail's BeforePost event handler
procedure TPessoaDM.DetailBeforePost(DataSet: TDataSet);
begin
   DataSet.FieldValues['dono'] := PessoaDM.PessoaInstituicaoDSet.FieldValues['id'];
end;

// Detail's AfterPost (and AfterDelete) event handler
procedure TPessoaDM.DetailAfterPost(DataSet: TDataSet);
begin
   InhDataSetDetailAfterPost (DataSet);
end;

procedure TPessoaDM.PessoaDSetBeforeEdit(DataSet: TDataSet);
begin
   PessoaInstituicaoDSet.Edit;
end;

end.
