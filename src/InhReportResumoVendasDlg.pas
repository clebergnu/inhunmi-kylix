unit InhReportResumoVendasDlg;

interface

uses
  SysUtils, Types, Classes, Variants, QGraphics, QControls, QForms, QDialogs,
  InhOkCancelDlg, QExtCtrls, QButtons, QStdCtrls, QMask, DateUtils, InhReportVendas;

  procedure InhReportResumoVendasDlgRun ();

type
  TInhReportResumoVendasDlgForm = class(TInhOkCancelDlgForm)
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
  InhReportResumoVendasDlgForm: TInhReportResumoVendasDlgForm;

implementation

{$R *.xfm}

procedure InhReportResumoVendasDlgRun ();
begin
   if (InhReportResumoVendasDlgForm = nil) then
      InhReportResumoVendasDlgForm := TInhReportResumoVendasDlgForm.Create(Application);

   with InhReportResumoVendasDlgForm do
      begin
         DataHoraInicialMaskEdit.Text := DateTimeToStr(Date()) + ' 00:00:00';  // Should be StartOfTheDay(Today())
         DataHoraFinalMaskEdit.Text   := DateTimeToStr(EndOfTheDay(Today()));  // but it its buggy
         ShowModal;
      end;
end;

procedure TInhReportResumoVendasDlgForm.OkSpeedButtonClick(
  Sender: TObject);
begin
   inherited;
   InhReportResumoVendas (StrToDateTime(DataHoraInicialMaskEdit.Text),
                          StrToDateTime(DataHoraFinalMaskEdit.Text));
end;

end.
