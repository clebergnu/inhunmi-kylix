{InhPessoa.pas - Inhunmi Pessoa Data Editing Form

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

unit InhPessoa;

interface

uses
  SysUtils, Types, Classes, Variants, QGraphics, QControls, QForms, QDialogs,
  QStdCtrls, QMask, QDBCtrls, QComCtrls, QExtCtrls, QButtons,
  QGrids, QDBGrids, QTypes, QMenus, InhBiblio, InhPessoaDM, DB,  SqlExpr,
  Qt, InhAjuda, QActnList, InhDbForm;

type
  TInhPessoaForm = class(TInhDbForm)
    NomeDbEdit: TDBEdit;
    IdDbEdit: TDBEdit;
    IdLabel: TLabel;
    NomeCompletoLabel: TLabel;
    GroupBox: TGroupBox;
    TratamentoDbComboBox: TDBComboBox;
    NomeFavoritoDbEdit: TDBEdit;
    NomeFavoritoLabel: TLabel;
    DataNascimentoDbEdit: TDBEdit;
    DataNascimentoLabel: TLabel;
    RGDbEdit: TDBEdit;
    RGLabel: TLabel;
    CPFDbEdit: TDBEdit;
    CPFLabel: TLabel;
    DetailsPageControl: TPageControl;
    TelefoneTabSheet: TTabSheet;
    TelefoneDBGrid: TDBGrid;
    EnderecoTabSheet: TTabSheet;
    EnderecoDBGrid: TDBGrid;
    EMailTabSheet: TTabSheet;
    EMailDBGrid: TDBGrid;
    ContatoTabSheet: TTabSheet;
    ContatoDBGrid: TDBGrid;
    ClienteGroupBox: TGroupBox;
    ClienteDBCheckBox: TDBCheckBox;
    ClienteVipDBCheckBox: TDBCheckBox;
    ClientePendenteDBCheckBox: TDBCheckBox;
    ColaboradorGroupBox: TGroupBox;
    FuncionarioDBCheckBox: TDBCheckBox;
    FornecedorDBCheckBox: TDBCheckBox;
    AgendaTelefones: TAction;
    AgendaDeTelefones1: TMenuItem;
    procedure DBGridDetailConfirmDelete(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure AgendaTelefonesExecute(Sender: TObject);
    procedure MasterDataSetAfterScroll(DataSet : TDataSet);
    procedure DetailsPageControlPageChanging(Sender: TObject; NewPage: TTabSheet; var AllowChange: Boolean);
    procedure FormShow(Sender: TObject);
  private
    { Private declarations }
  public
  end;

  function  PessoaFormNew () : TInhPessoaForm;

implementation

uses  InhMainDM, InhReportPessoaInstituicao, InhDbGridUtils;

{$R *.xfm}

function PessoaFormNew () : TInhPessoaForm;
var
   MyForm : TInhPessoaForm;
begin
   MyForm := TInhPessoaForm.Create(Application);

   if (PessoaDM = nil) then
      PessoaDM := TPessoaDM.Create(Application);

   MyForm.DataModule := PessoaDM;
   PessoaDM.DbForm := MyForm;

   MyForm.MasterDataSource := PessoaDM.PessoaInstituicaoDSource;
   MyForm.MasterDataSource.DataSet.AfterScroll := MyForm.MasterDataSetAfterScroll;
   MyForm.JointDataSource := PessoaDM.PessoaDSource;

   MyForm.FirstControl := MyForm.NomeDbEdit;
   MyForm.DetailsBox := MyForm.GroupBox;

   MyForm.HelpTopic := 'capitulo_cadastro_pessoas';

   Result := MyForm;
end;

procedure TInhPessoaForm.DBGridDetailConfirmDelete(Sender: TObject;
  var Key: Word; Shift: TShiftState);
begin
  inherited;
   InhDbGridEaseNavigation (TDBGrid(Sender), Key, Shift);
   InhDbGridConfirmDelete (TDBGrid(Sender), Key, Shift);
end;

procedure TInhPessoaForm.AgendaTelefonesExecute(Sender: TObject);
begin
  inherited;
   InhReportPITelefones (0, 9999, 'Pessoa');
end;

procedure TInhPessoaForm.MasterDataSetAfterScroll(DataSet: TDataSet);
var
   AllowPageChange : boolean;
begin
   TPessoaDM(DataModule).DMOpen;
   DetailsPageControlPageChanging(Self, DetailsPageControl.ActivePage, AllowPageChange);
end;

procedure TInhPessoaForm.DetailsPageControlPageChanging(Sender: TObject;
  NewPage: TTabSheet; var AllowChange: Boolean);
begin
  inherited;
    case NewPage.PageIndex of
      0 :
         InhDataSetOpenDetail(TPessoaDM(DataModule).FoneDSet, TPessoaDM(DataModule).PessoaInstituicaoDSet);
      1 :
         InhDataSetOpenDetail(TPessoaDM(DataModule).EnderecoDSet, TPessoaDM(DataModule).PessoaInstituicaoDSet);
      2 :
         InhDataSetOpenDetail(TPessoaDM(DataModule).EMailDSet, TPessoaDM(DataModule).PessoaInstituicaoDSet);
      3 :
         InhDataSetOpenDetail(TPessoaDM(DataModule).ContatoParentescoDSet, TPessoaDM(DataModule).PessoaInstituicaoDSet);
   end;
end;

procedure TInhPessoaForm.FormShow(Sender: TObject);
begin
  inherited;
   MasterDataSetAfterScroll(MasterDataSource.DataSet);
end;

end.
