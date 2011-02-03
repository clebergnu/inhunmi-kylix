unit InhPessoaInstituicaoLookupDlg;

interface

uses
  SysUtils, Types, Classes, Variants, QGraphics, QControls, QForms, QDialogs,
  InhOkCancelDlg, QExtCtrls, QButtons, QGrids, QDBGrids, QStdCtrls, DB,
  InhBiblio;

function
InhPessoaInstituicaoLookupFromDataSource (PessoaDataSource : TDataSource;
                                          InstituicaoDSource : TDataSource;
                                          Campo : String) : TModalResult;

type
  TInhPessoaInstituicaoLookupDlgForm = class(TInhOkCancelDlgForm)
    Label1: TLabel;
    TipoComboBox: TComboBox;
    TextoEdit: TEdit;
    Label2: TLabel;
    ResultadosDbGrid: TDBGrid;
    procedure TipoComboBoxChange(Sender: TObject);
    procedure TextoEditChange(Sender: TObject);
    procedure OkSpeedButtonClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    PessoaDataSource : TDataSource;
    InstituicaoDataSource : TDataSource;
    Campo : String;
  end;

var
  InhPessoaInstituicaoLookupDlgForm: TInhPessoaInstituicaoLookupDlgForm;

implementation

{$R *.xfm}

function
InhPessoaInstituicaoLookupFromDataSource (PessoaDataSource : TDataSource;
                                          InstituicaoDSource : TDataSource;
                                          Campo : String) : TModalResult;
var
   Form : TInhPessoaInstituicaoLookupDlgForm;
begin
   Form := TInhPessoaInstituicaoLookupDlgForm.Create(Application);
   Form.ResultadosDbGrid.DataSource := PessoaDataSource;
   Form.PessoaDataSource := PessoaDataSource;
   Form.InstituicaoDataSource := InstituicaoDSource;
   Form.Campo := Campo;
   Result := Form.ShowModal;
   Form.Free;
end;

procedure TInhPessoaInstituicaoLookupDlgForm.TipoComboBoxChange(
  Sender: TObject);
begin
  inherited;
   case (Self.TipoComboBox.ItemIndex) of
      0 : Self.ResultadosDbGrid.DataSource := Self.PessoaDataSource;
      1 : Self.ResultadosDbGrid.DataSource := Self.InstituicaoDataSource;
   end;
end;

procedure TInhPessoaInstituicaoLookupDlgForm.TextoEditChange(
  Sender: TObject);
begin
  inherited;
   InhFilterExecute (Self.ResultadosDbGrid.DataSource.Dataset,
                     Self.Campo, TextoEdit.Text, ifoTexto);
end;

procedure TInhPessoaInstituicaoLookupDlgForm.OkSpeedButtonClick(
  Sender: TObject);
begin
   case (Self.TipoComboBox.ItemIndex) of
   0 :
      begin
         PessoaDataSource.Tag := 1;
         InstituicaoDataSource.Tag := 0;
      end;
   1 :
      begin
         InstituicaoDataSource.Tag := 1;
         PessoaDataSource.Tag := 0;
      end;
   end;
   ModalResult := mrOk;
end;

end.
