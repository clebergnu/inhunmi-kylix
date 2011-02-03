unit InhReportPortaConsumo;

interface

uses  SysUtils, Types, Classes, Variants, DBXpress, Provider, SqlExpr,
      DB, DBClient, DBLocal, DBLocalS, InhMainDM, InhBiblio, InhConfig,
      InhReport, InhReportViewer;

// Relatorios Disponiveis
procedure InhReportPortaConsumoFechamento (PortaConsumos : array of integer);
procedure InhReportPortaConsumoPendente (PortaConsumos : array of integer; Cliente : String);

// Funcoes Exportadas
function InhReportPortaConsumoGetConsumos (PortaConsumo : integer; var TotalDosConsumos : Currency) : string;

implementation

var
   TotalPortaConsumoAtual : Currency;

function InhReportPortaConsumoGetDescription (PortaConsumoDSet : TDataSet) : String;
var
   Tipo : String;
   Numero : Integer;
   Codigo : Integer;
begin
   Result := '';

   Tipo := PortaConsumoDSet.FieldByName('tipo').AsString;
   Numero := PortaConsumoDSet.FieldByName('numero').AsInteger;
   Codigo := PortaConsumoDSet.FieldByName('id').AsInteger;

   if (Tipo = 'Cartão') or (Tipo = 'Mesa') then
      Result := Format ('%s %d  (código: %d)', [Tipo, Numero, Codigo])
   else
      Result := Format ('%s (código %d)', [Tipo, Codigo]);
end;


//function InhReportPortaConsumoGetConsumos (PortaConsumo : integer) : string;
function InhReportPortaConsumoGetConsumos (PortaConsumo : integer; var TotalDosConsumos : Currency) : string;
var
   Query : TSQLDataSet;
   SinalSaldo : string[1];
begin
   Result := '';
   TotalPortaConsumoAtual := 0;
   Query := TSQLDataSet.Create(MainDM.MainConnection);
   Query.SQLConnection := MainDM.MainConnection;
   Query.CommandText := 'SELECT consumo.produto_quantidade as quantidade, ' +
                        'produto.descricao as produto, consumo.valor FROM consumo, ' +
                        'produto WHERE consumo.produto = produto.id AND dono = ' +
                         IntToStr(PortaConsumo) + ' ORDER BY consumo.datahora_inicial';
   Query.Open;

   while not (Query.Eof) do
      begin
         Result := Result + Format ('%s %s %s' + InhLineFeed,
                                    [
                                     Format ('%4.4s', [Query.FieldValues['quantidade']]),
                                     Format('%-33.33s ', [Query.FieldValues['produto']]),
                                     Format ('%8.2f', [Query.FieldByName('valor').AsFloat])
                                    ]);
         TotalPortaConsumoAtual := TotalPortaConsumoAtual + Query.FieldByName('valor').AsFloat;
         Query.Next;
      end;
   Result := Result + InhLine48SubTotal + InhLineFeed;
   if (TotalPortaConsumoAtual < 0) then
      SinalSaldo := '-' else SinalSaldo := '+';
   Result := Result + Format ('%48.2f', [TotalPortaConsumoAtual]);
   Result := Result + InhLineFeed;

   TotalDosConsumos := TotalPortaConsumoAtual;

   Query.Close;
   Query.Free;
end;

function  InhGetPortaConsumoPagamentoResumo (PortaConsumos : array of integer) : string;
var
   PagamentoDSet : TSQLDataSet;
   FormaPagamento : String;
   Valor : Real;
begin
   Result := '';

   PagamentoDSet := TSQLDataSet.Create(MainDM.MainConnection);
   PagamentoDSet.SQLConnection := MainDM.MainConnection;

   // Pagamentos
   Result := Result + 'Recebimentos:' + InhLineFeed;
   PagamentoDSet.CommandText := 'SELECT forma_pagamento.descricao as forma_pagamento, SUM(porta_consumo_pagamento.valor) ' +
                                'as valor FROM forma_pagamento, porta_consumo_pagamento WHERE ' +
                                'porta_consumo_pagamento.forma_pagamento = forma_pagamento.id AND porta_consumo_pagamento.valor > 0 AND ' +
                                'dono IN (' + InhArrayOfIntToStrList (PortaConsumos, ', ') + ') GROUP BY descricao';
   PagamentoDSet.Open;
   PagamentoDSet.First;
   while (not PagamentoDSet.Eof) do
      begin
         FormaPagamento := PagamentoDSet.FieldValues['forma_pagamento'];
         Valor := PagamentoDSet.FieldValues['valor'];
         Result := Result + Format ('%-39s %8.2f' + InhLineFeed, [FormaPagamento, Valor]);
         PagamentoDSet.Next;
      end;

   PagamentoDSet.Close;
   Result := Result + InhLineFeed; 

   // Trocos
   Result := Result + 'Trocos:' + InhLineFeed;
   PagamentoDSet.CommandText := 'SELECT forma_pagamento.descricao as forma_pagamento, SUM(porta_consumo_pagamento.valor) ' +
                                'as valor FROM forma_pagamento, porta_consumo_pagamento WHERE ' +
                                'porta_consumo_pagamento.forma_pagamento = forma_pagamento.id AND porta_consumo_pagamento.valor < 0 AND ' +
                                'dono IN (' + InhArrayOfIntToStrList (PortaConsumos, ', ') + ') GROUP BY descricao';
   PagamentoDSet.Open;
   PagamentoDSet.First;
   while (not PagamentoDSet.Eof) do
      begin
         FormaPagamento := PagamentoDSet.FieldValues['forma_pagamento'];
         Valor := PagamentoDSet.FieldValues['valor'];
         Result := Result + Format ('%-39s %8.2f' + InhLineFeed, [FormaPagamento, Abs(Valor)]);
         PagamentoDSet.Next;
      end;
   PagamentoDSet.Free;
end;

procedure InhReportPortaConsumoFechamento (PortaConsumos : array of integer);
var
   TF : TextFile;
   PCQ : TSQLDataSet;
   FileName : String;

   TotalDeConsumos : Currency;
   TotalDePortaConsumos : Currency;   
begin
   if (Length (PortaConsumos) = 0) then exit;

   FileName := InhReportGetTmpFileName();
   AssignFile(TF, FileName);
   Rewrite(TF);

   PCQ := TSQLDataSet.Create(MainDM.MainConnection);
   PCQ.SQLConnection := MainDM.MainConnection;

   // Inicio de cabecalho
   Writeln(TF, InhReportGetBoxedCabecalho());
   Writeln(TF, 'C o m p r o v a n t e   d e  F e c h a m e n t o');
   Writeln(TF, InhLine48);
   WriteLn(TF, 'Data/Hora De Emissão: ' + FormatDateTime('dd/mm/yyyy hh:nn:ss', Now()));
   Writeln(TF, InhLine48);
   // Fim de cabecalho

   PCQ.CommandText := 'SELECT * FROM porta_consumo WHERE id IN (' +
                      InhArrayOfIntToStrList (PortaConsumos, ', ') + ')';
   PCQ.Open;

   TotalDePortaConsumos := 0;

   while not (PCQ.Eof) do
      begin
         WriteLn(TF, InhReportPortaConsumoGetDescription (PCQ));
         Writeln(TF, ' Qtd Produto                               Valor');
         Writeln(TF, InhReportPortaConsumoGetConsumos (PCQ.FieldValues['id'], TotalDeConsumos));
         TotalDePortaConsumos := TotalDePortaConsumos + TotalDeConsumos;
         PCQ.Next;
      end;

   WriteLn(TF, InhLine48SubTotal + InhLineFeed +
               Format('Total Geral:%36.2f', [TotaldePortaConsumos]) + InhLineFeed +
               InhLine48SubTotal + InhLineFeed);

   PCQ.Free;

   // Resumo de pagamento
   Writeln(TF, '===== R e c e b i m e n t o s / T r o c o ======' + InhLineFeed);
   WriteLn(TF, InhGetPortaConsumoPagamentoResumo (PortaConsumos));
   Writeln(TF, InhLine48 + InhLineFeed);
   CloseFile(TF);

   InhReportViewerOrPrint (FileName, 'CaixaComprovanteFechamento');
end;

procedure InhReportPortaConsumoPendente (PortaConsumos : array of integer; Cliente : String);
var
   TF : TextFile;
   PCQ : TSQLDataSet;
   FileName : String;

   TotalDeConsumos : Currency;
   TotalDePortaConsumos : Currency;
begin
   if (Length (PortaConsumos) = 0) then exit;

   FileName := InhReportGetTmpFileName();
   AssignFile(TF, FileName);
   Rewrite(TF);

   PCQ := TSQLDataSet.Create(MainDM.MainConnection);
   PCQ.SQLConnection := MainDM.MainConnection;

   // Inicio de cabecalho
   WriteLn(TF, InhReportGetBoxedCabecalho());
   Writeln(TF, '      Comprovante  de  Pagamento  Pendente      ');
   Writeln(TF, InhLine48);
   // Fim de cabecalho

   // Parametros
   WriteLn(TF, 'Emitido Por Usuário: ' + InhAccess.Id);
   WriteLn(TF, 'Data/Hora De Emissão: ' + FormatDateTime('dd/mm/yyyy hh:nn:ss', Now()));
   WriteLn(TF, InhLine48);
   Writeln(TF, '');
   Writeln(TF, '');

   PCQ.CommandText := 'SELECT * FROM porta_consumo WHERE id IN (' +
                      InhArrayOfIntToStrList (PortaConsumos, ', ') + ')';
   PCQ.Open;

   TotalDePortaConsumos := 0;

   while not (PCQ.Eof) do
      begin
         WriteLn(TF, InhReportPortaConsumoGetDescription (PCQ));
         Writeln(TF, ' Qtd Produto                               Valor');
         Writeln(TF, InhReportPortaConsumoGetConsumos (PCQ.FieldValues['id'], TotalDeConsumos));
         TotalDePortaConsumos := TotalDePortaConsumos + TotalDeConsumos;
         PCQ.Next;
      end;

   WriteLn(TF, InhLine48SubTotal + InhLineFeed +
               Format('Total Geral:%36.2f', [TotaldePortaConsumos]) + InhLineFeed +
               InhLine48SubTotal + InhLineFeed);

   PCQ.Free;

   Writeln(TF, 'Eu,');
   Writeln(TF, Cliente);
   Writeln(TF, 'Reconheço e assumo o pagamentos dos ' + InhlineFeed +
               'consumos acima descritos.');
   Writeln(TF, '');
   Writeln(TF, '');
   Writeln(TF, '');
   Writeln(TF, '    ----------------------------------------    ');
   Writeln(TF, '            Assinatura Do Responsável           ');
   CloseFile(TF);

   InhReportViewerOrPrint (FileName, 'CaixaComprovantePendente');
end;


end.
