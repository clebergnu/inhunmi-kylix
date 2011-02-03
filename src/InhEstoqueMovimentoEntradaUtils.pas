unit InhEstoqueMovimentoEntradaUtils;

interface

uses
      SysUtils, Types, Classes, Variants, DBXpress, Provider, SqlExpr,
      DB, DBClient, DBLocal, DBLocalS, InhMainDM, InhBiblio, InhConfig,
      InhDlgUtils, InhEstoqueUtils;

procedure InhEstoqueMovimentoEntradaCalcValorUnitario(DataSet: TDataSet);      

implementation

procedure InhEstoqueMovimentoEntradaCalcValorUnitario(DataSet: TDataSet);
begin
   if (DataSet.FieldByName('valor').AsFloat > 0) and
      (DataSet.FieldByName('quantidade').AsInteger > 0) then
      DataSet.FieldByName('valor_unitario').AsFloat := (DataSet.FieldByName('valor').AsFloat /
                                                        DataSet.FieldByName('quantidade').AsInteger)
   else
      DataSet.FieldByName('valor_unitario').AsFloat := 0;
end;

procedure InhEstoqueMovimentoEntradaCalcValorTotal(DataSet: TDataSet);
begin
//
end;

end.
