unit InhCaixaMovimentoDlg;

interface

uses
  SysUtils, Types, Classes, Variants, QGraphics, QControls, QForms, QDialogs,
  QStdCtrls, QDBCtrls, QExtCtrls, QButtons, Provider, SqlExpr, DB,
  DBClient, DBLocal, DBLocalS, InhOkCancelDlg, InhMainDM, InhBiblio, InhReportCaixa;

procedure InhCaixaMovimentoDlgRun ();

type
  TInhCaixaMovimentoDlgForm = class(TInhOkCancelDlgForm)
    TipoLabel: TLabel;
    TipoComboBox: TComboBox;
    LabelDescricao: TLabel;
    FormaPagamentoDbLookupComboBox: TDBLookupComboBox;
    DescricaoEdit: TEdit;
    ValorLabel: TLabel;
    ValorEdit: TEdit;
    FormaPagamentoDSet: TSQLClientDataSet;
    FormaPagamentoDSource: TDataSource;
    Label1: TLabel;
    procedure OkSpeedButtonClick(Sender: TObject);
    procedure CancelarSpeedButtonClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

implementation

uses InhDlgUtils;

{$R *.xfm}

procedure InhCaixaMovimentoDlgRun ();
var
   MyForm : TInhCaixaMovimentoDlgForm;
begin
   MyForm := TInhCaixaMovimentoDlgForm.Create(nil);

   MyForm.FormaPagamentoDSet.Open;
   MyForm.FormaPagamentoDbLookupComboBox.KeyValue := MyForm.FormaPagamentoDSet.FieldValues['id'];
   MyForm.TipoComboBox.SetFocus;
   MyForm.Show;
end;

procedure InhCaixaMovimentoAdiciona (Descricao : String;
                                     Tipo : String;
                                     Valor : Real;
                                     FormaPagamento : integer);
const
   QueryFormat = 'INSERT INTO caixa_movimento (usuario, descricao, tipo, valor, forma_pagamento) VALUES ' +
                 '(%s, "%s", "%s", "%f", %d)';
var
   Query : TSQLDataSet;
begin
   Query := TSQLDataSet.Create(MainDM.MainConnection);
   Query.SQLConnection := MainDM.MainConnection;

   Query.CommandText := Format (QueryFormat,
                                [InhAccess.Id, Descricao, Tipo, Valor, FormaPagamento]);
   Query.ExecSQL(True);
   Query.Free;
end;

procedure TInhCaixaMovimentoDlgForm.OkSpeedButtonClick(Sender: TObject);
var
   Valor : real;
begin
   if not (InhEditCheckForFloat (ValorEdit)) then
      begin
         ValorEdit.SetFocus;
         exit;
      end;
   Valor := StrToFloat (ValorEdit.Text);
   if (Valor < 0) then
      begin
         ValorEdit.Text := FloatToStr (Abs (Valor));
         InhDlg('Valor não pode ser negativo. Utilize débitos.');
         ValorEdit.SetFocus;
         exit;
      end;
   if (DescricaoEdit.Text = '') then
      begin
         InhDlg('Descrição do movimento deve ser informada.');
         DescricaoEdit.SetFocus;
         exit;
      end;
   InhCaixaMovimentoAdiciona (DescricaoEdit.Text, TipoComboBox.Text, Valor, FormaPagamentoDbLookupComboBox.KeyValue);
   InhReportCaixaMovimentoReceipt (DescricaoEdit.Text, TipoComboBox.Text, Valor, FormaPagamentoDbLookupComboBox.Text);
   Close;
end;

procedure TInhCaixaMovimentoDlgForm.CancelarSpeedButtonClick(
  Sender: TObject);
begin
   Close;
end;

procedure TInhCaixaMovimentoDlgForm.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
   Release;
end;

end.
