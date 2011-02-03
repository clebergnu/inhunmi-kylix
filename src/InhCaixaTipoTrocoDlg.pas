unit InhCaixaTipoTrocoDlg;

interface

uses
  SysUtils, Types, Classes, Variants, QGraphics, QControls, QForms, QDialogs,
  InhOkCancelDlg, QStdCtrls, QDBCtrls, QExtCtrls, QButtons, Provider,
  SqlExpr, DB, DBClient, DBLocal, DBLocalS;

function InhCaixaTipoTrocoDlgRun () : integer;

type
  TInhCaixaTipoTrocoDlgForm = class(TInhOkCancelDlgForm)
    FormaPagamentoDBLookupComboBox: TDBLookupComboBox;
    FormaPagamentoLabel: TLabel;
    FormaPagamentoDSet: TSQLClientDataSet;
    FormaPagamentoDSource: TDataSource;
    procedure FormaPagamentoDBLookupComboBoxKeyPress(Sender: TObject;
      var Key: Char);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  InhCaixaTipoTrocoDlgForm: TInhCaixaTipoTrocoDlgForm;

implementation

{$R *.xfm}

function InhCaixaTipoTrocoDlgRun () : integer;
begin
   Result := 0;
   if (InhCaixaTipoTrocoDlgForm = nil) then
      InhCaixaTipoTrocoDlgForm := TInhCaixaTipoTrocoDlgForm.Create(Application);
   with InhCaixaTipoTrocoDlgForm do
      begin
         if (FormaPagamentoDSet.Active = False) then
             FormaPagamentoDSet.Open;
         ShowModal;
         if (ModalResult = mrOk) then Result := FormaPagamentoDSet.FieldValues['id'];
      end;
end;

procedure TInhCaixaTipoTrocoDlgForm.FormaPagamentoDBLookupComboBoxKeyPress(
  Sender: TObject; var Key: Char);
begin
  inherited;
   if Key = #13 then
      OkSpeedButton.Click;
end;

end.
