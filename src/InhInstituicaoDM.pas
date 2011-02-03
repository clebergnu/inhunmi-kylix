{InhPessoaDM.pas - Inhunmi Instituicao DataModule

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

unit InhInstituicaoDM;

interface

uses
  SysUtils, Classes, Provider, SqlExpr, DB, DBClient, DBLocal, DBLocalS,
  QControls, InhBiblio, FMTBcd, InhDbForm, InhStringResources, InhInstituicaoUtils;

type
  TInstituicaoDM = class(TDataModule)
    InstituicaoDSet: TSQLClientDataSet;
    InstituicaoDSource: TDataSource;
    FoneDSet: TSQLClientDataSet;
    EnderecoDSet: TSQLClientDataSet;
    EMailDSet: TSQLClientDataSet;
    FoneDSource: TDataSource;
    EnderecoDSource: TDataSource;
    EMailDSource: TDataSource;
    ContatoDSet: TSQLClientDataSet;
    ContatoDSource: TDataSource;
    ContatoNomeDSet: TSQLClientDataSet;
    ContatoNomeDSource: TDataSource;
    ContatoNomeDSetid: TIntegerField;
    ContatoNomeDSetnome: TStringField;
    ContatoDSetid: TIntegerField;
    ContatoDSetdono: TIntegerField;
    ContatoDSetcontato_parente: TIntegerField;
    ContatoDSetcontato_parente_nome: TStringField;
    PessoaInstituicaoDSet: TSQLClientDataSet;
    PessoaInstituicaoDSource: TDataSource;
    PessoaInstituicaoDSetid: TIntegerField;
    PessoaInstituicaoDSetnome: TStringField;
    PessoaInstituicaoDSettipo: TStringField;
    InstituicaoDSetdono: TIntegerField;
    InstituicaoDSettipo: TStringField;
    InstituicaoDSetcgc: TStringField;
    FoneDSetid: TIntegerField;
    FoneDSetdono: TIntegerField;
    FoneDSettipo: TStringField;
    FoneDSetddd: TBCDField;
    FoneDSetnumero: TBCDField;
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
    ContatoDSettipo: TStringField;
    PessoaInstituicaoDSettipo_cliente: TStringField;
    PessoaInstituicaoDSettipo_cliente_vip: TStringField;
    PessoaInstituicaoDSettipo_cliente_pendente: TStringField;
    PessoaInstituicaoDSettipo_funcionario: TStringField;
    PessoaInstituicaoDSettipo_fornecedor: TStringField;
    procedure PessoaInstituicaoDSetAfterPost(DataSet: TDataSet);
    procedure PessoaInstituicaoDSetBeforeDelete(DataSet: TDataSet);
    procedure DetailAfterPost(DataSet: TDataSet);
    procedure DetailBeforePost(DataSet: TDataSet);
  private
    { Private declarations }
  public
    DbForm : TInhDbForm;
    function  DMOpen () : boolean;
  end;

var
  InstituicaoDM: TInstituicaoDM;

implementation

uses InhInstituicao, InhDlgUtils;

{$R *.xfm}

// Master & Detail DataSet Opening
function TInstituicaoDM.DMOpen () : boolean;
begin
   if (InhDataSetOpenMaster(PessoaInstituicaoDSet) = False) then
      begin
         Result := False;
         exit;
      end;
   if (InhDataSetOpenJoint(InstituicaoDSet, PessoaInstituicaoDSet) = False) then
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
procedure TInstituicaoDM.PessoaInstituicaoDSetAfterPost(DataSet: TDataSet);
var
   DoAfterInsertPost : boolean;
begin
   DoAfterInsertPost := (DataSet.Tag = 111);
   InhDataSetMasterAfterPost (DataSet);
   if InstituicaoDSet.RecordCount = 0 then
      begin
         InstituicaoDSet.Append;
         InstituicaoDSet.FieldValues['dono'] := DataSet.FieldValues['id'];
         InstituicaoDSet.ApplyUpdates(-1);
         InstituicaoDSet.Refresh;
      end
   else if (InstituicaoDSet.State in [dsEdit]) then
      InstituicaoDSet.Post;
      
   if DoAfterInsertPost then
      DbForm.MasterDataSetAfterInsertPost(DataSet)
   else
      DbForm.StatusBar.SimpleText := Format (InhStrRecordSaved, [TSQLClientDataSet(DataSet).FieldValues['id']]);
end;

// Confirmation of Master/Detail records deletion
procedure TInstituicaoDM.PessoaInstituicaoDSetBeforeDelete(
  DataSet: TDataSet);
begin
   if InhDlgRecordMasterDeleteConfirmation('Instituição') = True then
      begin
         if InhInstituicaoDelete (DataSet.FieldByName('id').AsInteger) then
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
procedure TInstituicaoDM.DetailBeforePost(DataSet: TDataSet);
begin
   DataSet.FieldValues['dono'] := InstituicaoDM.PessoaInstituicaoDSet.FieldValues['id'];
end;

// Detail's AfterPost (and AfterDelete) event handler
procedure TInstituicaoDM.DetailAfterPost(DataSet: TDataSet);
begin
   InhDataSetDetailAfterPost (DataSet);
end;

end.
