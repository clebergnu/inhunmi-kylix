unit InhReportEncomendaListagemHoraDlg;

interface

uses
  SysUtils, Types, Classes, Variants, QTypes, QGraphics, QControls, QForms, 
  QDialogs, QStdCtrls, InhOkCancelDlg, QExtCtrls, QButtons, QMask, DateUtils;

type
  TInhReportEncomendaListagemHoraDlgForm = class(TInhOkCancelDlgForm)
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

  procedure InhReportEncomendaProducaoListagemHoraDlgRun (AOWner : TComponent);

implementation

{$R *.xfm}

uses InhReportEncomendaListagem;

procedure InhReportEncomendaProducaoListagemHoraDlgRun (AOWner : TComponent);
var
   MyForm : TInhReportEncomendaListagemHoraDlgForm;

   DataInicial, DataFinal : TDateTime;
begin
   MyForm := TInhReportEncomendaListagemHoraDlgForm.Create(AOwner);

   DataInicial := Date();
   DataFinal := IncDay (Date());

   MyForm.DataHoraInicialMaskEdit.Text := DateTimeToStr(DataInicial) + ' 00:00:00';
   MyForm.DataHoraFinalMaskEdit.Text := DateTimeToStr(DataFinal) + ' 00:00:00';

   MyForm.ShowModal;
   MyForm.Release;
end;


procedure TInhReportEncomendaListagemHoraDlgForm.OkSpeedButtonClick(
  Sender: TObject);
begin
  inherited;
   InhReportEncomendaListagemHora (StrToDateTime(DataHoraInicialMaskEdit.Text),
                                   StrToDateTime(DataHoraFinalMaskEdit.Text));
end;

end.
