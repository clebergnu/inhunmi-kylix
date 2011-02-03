unit InhEncomendaTeleMarketingPessoaCadastro;

interface

uses
  SysUtils, Types, Classes, Variants, QTypes, QGraphics, QControls, QForms, 
  QDialogs, QStdCtrls, InhOkCancelDlg, QMask, QDBCtrls, QExtCtrls, QButtons,
  Provider, SqlExpr, DB, DBClient, DBLocal, DBLocalS;

type
  TInhEncomendaTeleMarketingPessoaCadastroForm = class(TInhOkCancelDlgForm)
    NomeLabel: TLabel;
    NomeDbEdit: TDBEdit;
    TelefonesGroupBox: TGroupBox;
    TelefoneResidencialLabel: TLabel;
    TelefoneResidencialDDDDbEdit: TDBEdit;
    TelefoneResidencialNumeroDbEdit: TDBEdit;
    TelefoneComercialLabel: TLabel;
    TelefoneComercialDDDDbEdit: TDBEdit;
    TelefoneComercialNumeroDbEdit: TDBEdit;
    TelefoneCelularLabel: TLabel;
    TelefoneOutroLabel: TLabel;
    TelefoneCelularDDDDbEdit: TDBEdit;
    TelefoneCelularNumeroDbEdit: TDBEdit;
    TelefoneOutroDDDDbEdit: TDBEdit;
    TelefoneOutroNumeroDbEdit: TDBEdit;
    GroupBox1: TGroupBox;
    Label5: TLabel;
    DBEdit1: TDBEdit;
    DBEdit8: TDBEdit;
    Label6: TLabel;
    Label7: TLabel;
    DBEdit9: TDBEdit;
    Label8: TLabel;
    DBEdit10: TDBEdit;
    Label9: TLabel;
    DBEdit11: TDBEdit;
    Label10: TLabel;
    DBEdit12: TDBEdit;
    PessoaInstituicaoDSet: TSQLClientDataSet;
    PessoaInstituicaoDSource: TDataSource;
    DBEdit2: TDBEdit;
    PessoaInstituicaoDSetid: TIntegerField;
    PessoaInstituicaoDSetnome: TStringField;
    PessoaInstituicaoDSettipo: TStringField;
    procedure OkSpeedButtonClick(Sender: TObject);
  private
//    PessoaInstituicaoID : integer;
  public
    { Public declarations }
  end;

  function InhEncomendaTeleMarketingPessoaCadastroRun (AOWner : TComponent; Telefone : String) : boolean;

implementation

{$R *.xfm}

uses InhBiblio;

function InhEncomendaTeleMarketingPessoaCadastroRun (AOWner : TComponent; Telefone : String) : boolean;
var
   MyForm : TInhEncomendaTeleMarketingPessoaCadastroForm;
begin
   MyForm := TInhEncomendaTeleMarketingPessoaCadastroForm.Create(AOwner);

   MyForm.PessoaInstituicaoDSet.Open;
   MyForm.PessoaInstituicaoDSet.Append;

   MyForm.TelefoneResidencialDDDDbEdit.Text := '085';
   MyForm.TelefoneResidencialNumeroDbEdit.Text := Telefone;

   MyForm.ShowModal;
   MyForm.Release;

   Result := True;
end;


procedure TInhEncomendaTeleMarketingPessoaCadastroForm.OkSpeedButtonClick(
  Sender: TObject);
begin
//  if InhRunQuery (Format ('SELECT id, nome FROM pessoa_instituicao WHERE tipo = "Pessoa" AND nome = "%s"',
//                          [TelefoneEdit.Text])) > 0 then


  // Attempt to add this Person
//  InhRunQuery ('INSERTO INTO pessoa_instituicao (nome, tipo) VALUES ("%s", "Pessoa")');




end;

end.
