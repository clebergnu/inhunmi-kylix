unit InhReportStatusCaixaDlg;

interface

uses
  SysUtils, Types, Classes, Variants, QGraphics, QControls, QForms, QDialogs,
  InhOkCancelDlg, Provider, SqlExpr, QDBCtrls, QStdCtrls, DB, DBClient,
  DBLocal, DBLocalS, QExtCtrls, QButtons, InhReportCaixa, QComCtrls, QMask,
  DateUtils;

procedure InhReportStatusCaixaDlgRun ();

type
  TInhReportStatusCaixaDlgForm = class(TInhOkCancelDlgForm)
    UsuarioDSet: TSQLClientDataSet;
    UsuarioDSource: TDataSource;
    CaixaLabel: TLabel;
    UsuarioDbComboBox: TDBLookupComboBox;
    GroupBox1: TGroupBox;
    DataHoraInicialLabel: TLabel;
    DataHoraFinalLabel: TLabel;
    DataHoraInicialMaskEdit: TMaskEdit;
    DataHoraFinalMaskEdit: TMaskEdit;
    procedure OkSpeedButtonClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  InhReportStatusCaixaDlgForm: TInhReportStatusCaixaDlgForm;

implementation

uses InhMainDM;

{$R *.xfm}

procedure InhReportStatusCaixaDlgRun ();
var
   DataInicial : TDateTime;
   DataFinal : TDateTime;
begin
   if (InhReportStatusCaixaDlgForm = nil) then
      InhReportStatusCaixaDlgForm := TInhReportStatusCaixaDlgForm.Create(Application);
   if (InhReportStatusCaixaDlgForm.UsuarioDset.Active = False) then InhReportStatusCaixaDlgForm.UsuarioDset.Open;

   DataInicial := Date();
   DataFinal := IncDay (Date());

   InhReportStatusCaixaDlgForm.DataHoraInicialMaskEdit.Text := DateTimeToStr(DataInicial) + ' 00:00:00';
   InhReportStatusCaixaDlgForm.DataHoraFinalMaskEdit.Text := DateTimeToStr(DataFinal) + ' 00:00:00';
   InhReportStatusCaixaDlgForm.UsuarioDSet.First;
   InhReportStatusCaixaDlgForm.UsuarioDbComboBox.KeyValue := InhReportStatusCaixaDlgForm.UsuarioDSet.FieldValues['id'];
   InhReportStatusCaixaDlgForm.ShowModal;
end;

procedure TInhReportStatusCaixaDlgForm.OkSpeedButtonClick(Sender: TObject);
begin
  inherited;
      InhReportCaixaStatus (StrToDateTime(DataHoraInicialMaskEdit.Text),
                            StrToDateTime(DataHoraFinalMaskEdit.Text),
                            UsuarioDbComboBox.KeyValue);
end;

end.
