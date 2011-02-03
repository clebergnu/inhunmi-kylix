unit InhEncomendaTeleMarketingImpressaoDlg;

interface

uses
  SysUtils, Types, Classes, Variants, QTypes, QGraphics, QControls, QForms, 
  QDialogs, QStdCtrls, InhOkCancelDlg, QExtCtrls, QButtons,

  InhReportEncomenda;

type
  TInhEncomendaTeleMarketingImpressaoDlgForm = class(TInhOkCancelDlgForm)
    RadioGroup: TRadioGroup;
    procedure OkSpeedButtonClick(Sender: TObject);
  private
    EncomendaID : integer;
  public
    { Public declarations }
  end;

procedure InhEncomendaTeleMarketingImpressaoDlgRun (AOWner : TComponent; EncomendaID : integer);

implementation

{$R *.xfm}

procedure InhEncomendaTeleMarketingImpressaoDlgRun (AOWner : TComponent; EncomendaID : integer);
var
   MyForm : TInhEncomendaTeleMarketingImpressaoDlgForm;
begin
   MyForm := TInhEncomendaTeleMarketingImpressaoDlgForm.Create(AOwner);

   MyForm.EncomendaID := EncomendaID;

   MyForm.ShowModal;
   MyForm.Release;
end;

procedure TInhEncomendaTeleMarketingImpressaoDlgForm.OkSpeedButtonClick(
  Sender: TObject);
begin
  inherited;
   InhReportEncomendaByReportID (RadioGroup.ItemIndex, EncomendaID);
end;

end.
