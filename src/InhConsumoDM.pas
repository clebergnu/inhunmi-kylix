unit InhConsumoDM;

interface

uses
  SysUtils, Classes, Provider, SqlExpr, DB, DBClient, DBLocal, DBLocalS,
  InhFiltroPadrao, InhBiblio, QControls;

function  InhConsumoDMOpen () : boolean;
procedure InhConsumoDMClose ();

type
  TConsumoDM = class(TDataModule)
    ConsumoDSet: TSQLClientDataSet;
    ConsumoDSource: TDataSource;
    ProdutoDSet: TSQLClientDataSet;
    ProdutoDSource: TDataSource;
    ConsumoDSetid: TIntegerField;
    ConsumoDSetdatahora: TSQLTimeStampField;
    ConsumoDSetproduto: TIntegerField;
    ConsumoDSetproduto_quantidade: TIntegerField;
    ConsumoDSetvalor: TFloatField;
    ConsumoDSetdono: TIntegerField;
    procedure ConsumoDSetAfterPost(DataSet: TDataSet);
    procedure ConsumoDSetBeforePost(DataSet: TDataSet);
    procedure ConsumoDSetBeforeDelete(DataSet: TDataSet);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  ConsumoDM: TConsumoDM;

implementation

{$R *.xfm}

// Master & Detail DataSet Opening
function  InhConsumoDMOpen () : boolean;
begin
   Result := InhDataSetOpenMaster(ConsumoDM.ConsumoDSet);
end;

// Master & Detail DataSet Closing
procedure InhConsumoDMClose ();
begin
   ConsumoDM.ConsumoDSet.Close;
end;

// Fills default values of MasterDataSet before posting
procedure TConsumoDM.ConsumoDSetBeforePost(DataSet: TDataSet);
begin
   if TSQLClientDataSet(DataSet).State = dsInsert then
      begin
         DataSet.FieldValues['id'] := '0';
         DataSet.Tag := 111;
      end;
end;

// Master's AfterPost event handler
procedure TConsumoDM.ConsumoDSetAfterPost(DataSet: TDataSet);
begin
   InhDataSetMasterAfterPost (DataSet);
end;

// Confirmation of Master/Detail records deletion
procedure TConsumoDM.ConsumoDSetBeforeDelete(DataSet: TDataSet);
begin
   if InhDlgConfirmDelete() <> True then
      Abort
end;

// After scrolling, update Detail's DataSets



// Detail's BeforePost event handler
{Nothing for now...}

// Detail's AfterPost (and AfterDelete) event handler
{Nothing for now...}

end.
