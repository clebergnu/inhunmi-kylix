unit InhReportEncomendaProducaoResumoDlg;

interface

uses
  SysUtils, Types, Classes, Variants, QTypes, QGraphics, QControls, QForms, 
  QDialogs, QStdCtrls, InhOkCancelDlg, QExtCtrls, QButtons, QMask, DateUtils;

type
  TInhReportEncomendaProducaoResumoDlgForm = class(TInhOkCancelDlgForm)
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

  procedure InhReportEncomendaProducaoResumoDlgRun (AOWner : TComponent);

implementation

{$R *.xfm}

uses InhReportEncomendaProducao;

procedure InhReportEncomendaProducaoResumoDlgRun (AOWner : TComponent);
var
   MyForm : TInhReportEncomendaProducaoResumoDlgForm;

   DataInicial, DataFinal : TDateTime;
begin
   MyForm := TInhReportEncomendaProducaoResumoDlgForm.Create(AOwner);

   DataInicial := Date();
   DataFinal := IncDay (Date());

   MyForm.DataHoraInicialMaskEdit.Text := DateTimeToStr(DataInicial) + ' 00:00:00';
   MyForm.DataHoraFinalMaskEdit.Text := DateTimeToStr(DataFinal) + ' 00:00:00';

   MyForm.ShowModal;
   MyForm.Release;
end;

procedure TInhReportEncomendaProducaoResumoDlgForm.OkSpeedButtonClick(
  Sender: TObject);
begin
  inherited;
   InhReportEncomendaProducaoResumo (StrToDateTime(DataHoraInicialMaskEdit.Text),
                                     StrToDateTime(DataHoraFinalMaskEdit.Text));
end;

end.
