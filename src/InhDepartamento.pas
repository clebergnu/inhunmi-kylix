unit InhDepartamento;

interface

uses
  SysUtils, Types, Classes, Variants, QGraphics, QControls, QForms, QDialogs,
  InhDepartamentoDM, QDBCtrls, QExtCtrls, QButtons, QStdCtrls,
  QMask, InhBiblio, InhAjuda, QComCtrls, InhDbForm, QActnList, QTypes,
  QMenus;

type
  TInhDepartamentoForm = class(TInhDbForm)
    IdDbEdit: TDBEdit;
    DescricaoDbEdit: TDBEdit;
    IdLabel: TLabel;
    DescricaoLabel: TLabel;
    procedure FormShow(Sender: TObject);
  private
  public
  end;

  function DepartamentoFormNew() : TInhDepartamentoForm;

implementation

{$R *.xfm}

function DepartamentoFormNew() : TInhDepartamentoForm;
var
   MyForm : TInhDepartamentoForm;
begin
   MyForm := TInhDepartamentoForm.Create(Application);

   if (DepartamentoDM = nil) then
      DepartamentoDM := TDepartamentoDM.Create(Application);

   MyForm.DataModule := DepartamentoDM;
   DepartamentoDM.DbForm := MyForm;

   MyForm.MasterDataSource := DepartamentoDM.DepartamentoDSource;

   MyForm.FirstControl := MyForm.DescricaoDbEdit;

   MyForm.HelpTopic := 'capitulo_cadastro_departamentos';

   Result := MyForm;
end;

procedure TInhDepartamentoForm.FormShow(Sender: TObject);
begin
  inherited;
   TDepartamentoDM(DataModule).DMOpen;
end;

end.
