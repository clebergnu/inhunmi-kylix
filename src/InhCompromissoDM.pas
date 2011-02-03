unit InhCompromissoDM;

interface

uses
  SysUtils, Classes, Provider, SqlExpr, DB, DBClient, DBLocal, DBLocalS,
  InhBiblio, QControls, QTypes, QMenus, FMTBcd, InhDbForm;

type
  TCompromissoDM = class(TDataModule)
    CompromissoDSet: TSQLClientDataSet;
    CompromissoDSource: TDataSource;
    CompromissoCompraDSet: TSQLClientDataSet;
    CompromissoDespesaDSet: TSQLClientDataSet;
    CompromissoParcelaDSet: TSQLClientDataSet;
    CompromissoCompraDSource: TDataSource;
    CompromissoDespesaDSource: TDataSource;
    CompromissoParcelaDSource: TDataSource;
    CompromissoCompraDSetid: TIntegerField;
    CompromissoCompraDSetdono: TIntegerField;
    CompromissoCompraDSetproduto: TIntegerField;
    CompromissoCompraDSetquantidade: TIntegerField;
    CompromissoCompraDSetvalor: TFloatField;
    CompromissoCompraDSettotal: TAggregateField;
    CompromissoDespesaDSetid: TIntegerField;
    CompromissoDespesaDSetdono: TIntegerField;
    CompromissoDespesaDSetdescricao: TStringField;
    CompromissoDespesaDSetvalor: TFloatField;
    CompromissoDespesaDSettotal: TAggregateField;
    CompromissoParcelaDSetid: TIntegerField;
    CompromissoParcelaDSetdono: TIntegerField;
    CompromissoParcelaDSetsituacao: TStringField;
    CompromissoParcelaDSetforma_pagamento: TIntegerField;
    CompromissoParcelaDSetvalor: TFloatField;
    ProdutoDSet: TSQLClientDataSet;
    ProdutoDSource: TDataSource;
    CompromissoCompraDSetproduto_descricao: TStringField;
    FormaPagamentoDSet: TSQLClientDataSet;
    FormaPagamentoDSource: TDataSource;
    CompromissoParcelaDSetforma_pagamento_descricao: TStringField;
    CompromissoParcelaDSetdata: TDateField;
    CompromissoParcelaDSettotal: TAggregateField;
    PessoaDSet: TSQLClientDataSet;
    PessoaDSource: TDataSource;
    CompromissoCompraDSetdepartamento_estoque: TIntegerField;
    DepartamentoDSet: TSQLClientDataSet;
    DepartamentoDSource: TDataSource;
    CompromissoCompraDSetdepartamento_estoque_nome: TStringField;
  private
  public
    DbForm : TInhDbForm;
    function DMOpen() : boolean;
  end;

var
  CompromissoDM: TCompromissoDM;

implementation

{$R *.xfm}

// Master & Detail DataSet Opening
function  TCompromissoDM.DMOpen () : boolean;
begin
   if (InhDataSetOpenMaster(CompromissoDM.CompromissoDSet) = False) then
      begin
         Result := False;
         exit;
      end;
   if (InhDataSetOpenDetail (CompromissoDM.CompromissoCompraDSet, CompromissoDM.CompromissoDSet) = False) then
      begin
         Result := False;
         exit;
      end;
   if (InhDataSetOpenDetail (CompromissoDM.CompromissoDespesaDSet, CompromissoDM.CompromissoDSet) = False) then
      begin
         Result := False;
         exit;
      end;
   if (InhDataSetOpenDetail (CompromissoDM.CompromissoParcelaDSet, CompromissoDM.CompromissoDSet) = False) then
      begin
         Result := False;
         exit;
      end;
   if (InhDataSetOpenMaster(CompromissoDM.ProdutoDSet) = False) then
      begin
         Result := False;
         exit;
      end;
   if (InhDataSetOpenMaster(CompromissoDM.FormaPagamentoDSet) = False) then
      begin
         Result := False;
         exit;
      end;
   if (InhDataSetOpenMaster(CompromissoDM.PessoaDSet) = False) then
      begin
         Result := False;
         exit;
      end;
   Result := True;
end;


end.
