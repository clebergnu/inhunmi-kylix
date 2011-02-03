unit InhReportCaixa;

interface

uses  SysUtils, Types, Classes, Variants, DBXpress, Provider, SqlExpr,
      DB, DBClient, DBLocal, DBLocalS, InhMainDM, InhBiblio, InhConfig,
      InhReport, InhReportViewer;

type
   TInhFormaPagamentoStatus = record
   FormaPagamento : String[40];
   Valor : Real;
   end;

type TInhCaixaStatus = array of TInhFormaPagamentoStatus;


// Relatorios Disponiveis
procedure InhReportCaixaStatus (DataInicial : TDateTime; DataFinal : TDateTime; Usuario : integer);
procedure InhReportCaixaMovimentoReceipt (Descricao : String; Tipo : String; Valor : Real; FormaPagamento : String);
procedure InhReportContraVale (Valor : real);

var
   SaldoMovimentos : TSQLDataSet;
   ListagemMovimentos : TSQLDataSet;
   SaldoRecebimentos : TSQLDataSet;
   ContraVales : TSQLDataSet;
   Pendentes : TSQLDataSet;
   PendentesRecebidos : TSQLDataSet;
   CaixaStatusFinal : TInhCaixaStatus;

implementation

procedure InhCaixaStatusAdicionaFormaPagamentoStatus (FormaPagamento : String;
                                                      Valor : Real);
var
   Contador : integer;
   Encontrado : boolean;
begin
   Encontrado := False;
   // Attempt to find FormaPagamento
   for Contador := Low(CaixaStatusFinal) to High(CaixaStatusFinal) do
      if (CaixaStatusFinal[Contador].FormaPagamento = FormaPagamento) then
         begin
            Encontrado := True;
            break;
         end;
   if not Encontrado then
      // Creates new TInhFormaPagamentoStatus, put it on CaixaStatus
      begin
         SetLength (CaixaStatusFinal, Length(CaixaStatusFinal) + 1);
         Contador := High(CaixaStatusFinal);
         CaixaStatusFinal[Contador].FormaPagamento := FormaPagamento;
         CaixaStatusFinal[Contador].Valor := Valor;
      end
   else
      CaixaStatusFinal[Contador].Valor := CaixaStatusFinal[Contador].Valor + Valor;
end;

procedure UpdateSaldoMovimentos (DataInicial : TDateTime;
                                 DataFinal : TDateTime;
                                 Usuario : integer);
var
   DataInicialString : string;
   DataFinalString : string;
begin
   DataInicialString := DateTimeToSQLTimeStampString (DataInicial);
   DataFinalString := DateTimeToSQLTimeStampString (DataFinal);

   if (SaldoMovimentos = nil) then
      begin
         SaldoMovimentos := TSQLDataSet.Create(MainDM.MainConnection);
         SaldoMovimentos.SQLConnection := MainDM.MainConnection;
      end;

   if (SaldoMovimentos.Active) then SaldoMovimentos.Close;

   {Changed "valor - (2 * valor)" to "- valor"}
   SaldoMovimentos.CommandText := 'SELECT forma_pagamento.descricao as forma_pagamento, ' +
                                  'SUM(IF(STRCMP(tipo, "Crédito"), - valor, valor)) as valor ' +
                                  'FROM forma_pagamento, caixa_movimento WHERE forma_pagamento.id = caixa_movimento.forma_pagamento ' +
                                  'AND datahora BETWEEN ' + DataInicialString + ' AND ' + DataFinalString +
                                  ' AND usuario = ' + IntToStr(Usuario) + ' GROUP BY forma_pagamento';

   SaldoMovimentos.Open;
   SaldoMovimentos.First;
end;

procedure UpdateListagemMovimentos (DataInicial : TDateTime;
                                    DataFinal : TDateTime;
                                    Usuario : integer);
var
   DataInicialString : string;
   DataFinalString : string;
begin
   DataInicialString := DateTimeToSQLTimeStampString (DataInicial);
   DataFinalString := DateTimeToSQLTimeStampString (DataFinal);

   if (ListagemMovimentos = nil) then
      begin
         ListagemMovimentos := TSQLDataSet.Create(MainDM.MainConnection);
         ListagemMovimentos.SQLConnection := MainDM.MainConnection;
      end;

   if (ListagemMovimentos.Active) then ListagemMovimentos.Close;

   ListagemMovimentos.CommandText := 'SELECT datahora, forma_pagamento.descricao as forma_pagamento, ' +
                                     'IF(STRCMP(caixa_movimento.tipo, "Débito"), "+", "-") as tipo, caixa_movimento.valor, '+
                                     'caixa_movimento.descricao as descricao_movimento FROM caixa_movimento, ' +
                                     'forma_pagamento WHERE forma_pagamento.id = caixa_movimento.forma_pagamento ' +
                                     'AND datahora BETWEEN ' + DataInicialString + ' AND ' + DataFinalString +
                                     ' AND usuario = ' + IntToStr(Usuario) + ' ORDER BY tipo, forma_pagamento';

   ListagemMovimentos.Open;
   ListagemMovimentos.First;
end;

procedure UpdateSaldoRecebimentos (DataInicial : TDateTime;
                                   DataFinal : TDateTime;
                                   Usuario : integer);
var
   DataInicialString : string;
   DataFinalString : string;
begin
   DataInicialString := DateTimeToSQLTimeStampString (DataInicial);
   DataFinalString := DateTimeToSQLTimeStampString (DataFinal);

   if (SaldoRecebimentos = nil) then
      begin
         SaldoRecebimentos := TSQLDataSet.Create(MainDM.MainConnection);
         SaldoRecebimentos.SQLConnection := MainDM.MainConnection;
      end;

   if (SaldoRecebimentos.Active) then SaldoRecebimentos.Close;

   SaldoRecebimentos.CommandText := 'SELECT forma_pagamento.descricao as forma_pagamento, ' +
                                    'SUM(porta_consumo_pagamento.valor) as valor ' +
                                    'FROM forma_pagamento, porta_consumo_pagamento WHERE forma_pagamento.id = porta_consumo_pagamento.forma_pagamento ' +
                                    'AND datahora BETWEEN ' + DataInicialString + ' AND ' + DataFinalString +
                                    ' AND usuario = ' + IntToStr(Usuario) + ' GROUP BY forma_pagamento';
   SaldoRecebimentos.Open;
   SaldoRecebimentos.First;
end;

procedure UpdateContraVales (DataInicial : TDateTime;
                             DataFinal : TDateTime;
                             Usuario : integer);
var
   DataInicialString : string;
   DataFinalString : string;
begin
   DataInicialString := DateTimeToSQLTimeStampString (DataInicial);
   DataFinalString := DateTimeToSQLTimeStampString (DataFinal);

   if (ContraVales = nil) then
      begin
         ContraVales := TSQLDataSet.Create(MainDM.MainConnection);
         ContraVales.SQLConnection := MainDM.MainConnection;
      end;

   if (ContraVales.Active) then ContraVales.Close;
   ContraVales.CommandText := 'SELECT forma_pagamento.descricao AS forma_pagamento, SUM(valor) as valor ' +
                              'FROM forma_pagamento, porta_consumo_pagamento WHERE forma_pagamento.id = porta_consumo_pagamento.forma_pagamento ' +
                              'AND forma_pagamento.tipo_contra_vale = "Sim" ' +
                              'AND datahora BETWEEN ' + DataInicialString + ' AND ' + DataFinalString +
                             ' AND usuario = ' + IntToStr(Usuario) + ' GROUP BY forma_pagamento, valor < 0';

   ContraVales.Open;
   ContraVales.First;
end;

procedure UpdatePendentes (DataInicial : TDateTime;
                           DataFinal : TDateTime;
                           Usuario : integer);
var
   DataInicialString : string;
   DataFinalString : string;
begin
   DataInicialString := DateTimeToSQLTimeStampString (DataInicial);
   DataFinalString := DateTimeToSQLTimeStampString (DataFinal);

   if (Pendentes = nil) then
      begin
         Pendentes := TSQLDataSet.Create(MainDM.MainConnection);
         Pendentes.SQLConnection := MainDM.MainConnection;
      end;



   if (Pendentes.Active) then Pendentes.Close;
   Pendentes.CommandText := 'SELECT porta_consumo.id, pessoa_instituicao.nome, SUM(consumo.valor) as valor ' +
                            'FROM porta_consumo JOIN pessoa_instituicao ON (porta_consumo.dono = pessoa_instituicao.id) ' +
                            'JOIN consumo ON (consumo.dono = porta_consumo.id) ' +
                            'WHERE (porta_consumo.status = "Pendente") AND ' +
                            '(porta_consumo.datahora BETWEEN ' + DataInicialString + ' AND ' + DataFinalString + ') ' +
                            'AND porta_consumo.usuario = ' + IntToStr(Usuario) +
                            ' GROUP BY porta_consumo.id ORDER BY pessoa_instituicao.nome, porta_consumo.datahora_final';
   Pendentes.Open;
   Pendentes.First;
end;

procedure UpdatePendentesRecebidos (DataInicial : TDateTime;
                                    DataFinal : TDateTime;
                                    Usuario : integer);
var
   DataInicialString : string;
   DataFinalString : string;
begin
   DataInicialString := DateTimeToSQLTimeStampString (DataInicial);
   DataFinalString := DateTimeToSQLTimeStampString (DataFinal);

   if (PendentesRecebidos = nil) then
      begin
         PendentesRecebidos := TSQLDataSet.Create(MainDM.MainConnection);
         PendentesRecebidos.SQLConnection := MainDM.MainConnection;
      end;


   if (PendentesRecebidos.Active) then PendentesRecebidos.Close;
   PendentesRecebidos.CommandText := 'SELECT porta_consumo.id, pessoa_instituicao.nome, SUM(consumo.valor) as valor ' +
                                     'FROM porta_consumo JOIN pessoa_instituicao ON (porta_consumo.dono = pessoa_instituicao.id) ' +
                                     'JOIN consumo ON (consumo.dono = porta_consumo.id) ' +
                                     'WHERE (porta_consumo.status_anterior = "Pendente") ' +
                                     'AND (porta_consumo.status = "Fechado") AND ' +
                                     '(porta_consumo.datahora BETWEEN ' + DataInicialString + ' AND ' + DataFinalString + ') ' +
                                     'AND (porta_consumo.usuario = ' + IntToStr(Usuario) +
                                     ') GROUP BY porta_consumo.id ORDER BY pessoa_instituicao.nome, porta_consumo.datahora';

   PendentesRecebidos.Open;
   PendentesRecebidos.First;
end;

function InhReportCaixaGetRecebimentos (DataInicial : TDateTime;
                                        DataFinal : TDateTime;
                                        Usuario : integer;
                                        Saldo : boolean;
                                        Listagem : boolean) : string;
var
   Sinal : string;
   SinalSaldo : string;
   ValorSaldo : real;
begin
   if not (Saldo or Listagem) then exit;
   ValorSaldo := 0;

   if (Saldo) then
      begin
         UpdateSaldoRecebimentos (DataInicial, DataFinal, Usuario);
         Result := Result + '======== Saldo de Recebimentos / Trocos ========' + InhLineFeed + InhLineFeed;
         while not (SaldoRecebimentos.Eof) do
            begin
               if (SaldoRecebimentos.FieldByName('valor').AsFloat < 0) then
                  Sinal := '-'
               else
                  Sinal := '+';
               Result := Result + Format ('%s (%s) %s' + InhLineFeed,
                                        [
                                         Format ('%-35.35s', [SaldoRecebimentos.FieldValues['forma_pagamento']]),
                                         Sinal,
                                         Format ('%8.2f',    [Abs(SaldoRecebimentos.FieldByName('valor').AsFloat)])
                                        ]);
               // EXPERIMENTAL START
               InhCaixaStatusAdicionaFormaPagamentoStatus (SaldoRecebimentos.FieldValues['forma_pagamento'],
                                                           SaldoRecebimentos.FieldByName('valor').AsFloat);

               // EXPERIMENTAL END
               ValorSaldo := ValorSaldo + SaldoRecebimentos.FieldByName('valor').AsFloat;
               SaldoRecebimentos.Next;
            end;
         Result := Result + InhLine48SubTotal + InhLineFeed;
         if (ValorSaldo < 0) then
            SinalSaldo := '-'
         else
            SinalSaldo := '+';
         Result := Result + Format ('                                    (%s) %8.2f', [SinalSaldo, Abs(ValorSaldo)]);
         Result := Result + InhLineFeed + InhLineFeed;
      end;

end;


function InhReportCaixaGetMovimentos (DataInicial : TDateTime;
                                      DataFinal : TDateTime;
                                      Usuario : integer;
                                      Saldo : boolean;
                                      Listagem : boolean) : string;
var
   Sinal : string;
   SinalSaldo : string;
   ValorSaldo : real;
begin
   if not (Saldo or Listagem) then exit;
   ValorSaldo := 0;

   if (Saldo) then
      begin
         UpdateSaldoMovimentos (DataInicial, DataFinal, Usuario);
         Result := Result + '========= Saldo de Movimentos de Caixa =========' + InhLineFeed + InhLineFeed;
         while not (SaldoMovimentos.Eof) do
            begin
               if (SaldoMovimentos.FieldByName('valor').AsFloat < 0) then
                  Sinal := '-' else Sinal := '+';
               Result := Result + Format ('%s (%s) %s' + InhLineFeed,
                                        [
                                         Format ('%-35.35s', [SaldoMovimentos.FieldValues['forma_pagamento']]),
                                         Sinal,
                                         Format ('%8.2f',    [Abs(SaldoMovimentos.FieldByName('valor').AsFloat)])
                                        ]);
               ValorSaldo := ValorSaldo + SaldoMovimentos.FieldByName('valor').AsFloat;
               // EXPERIMENTAL START
               InhCaixaStatusAdicionaFormaPagamentoStatus (SaldoMovimentos.FieldValues['forma_pagamento'],
                                                           SaldoMovimentos.FieldByName('valor').AsFloat);

               // EXPERIMENTAL END
               SaldoMovimentos.Next;
            end;
         Result := Result + InhLine48SubTotal + InhLineFeed;
         if (ValorSaldo < 0) then
            SinalSaldo := '-'
         else
            SinalSaldo := '+';
         Result := Result + Format ('                                    (%s) %8.2f', [SinalSaldo, Abs(ValorSaldo)]);
         Result := Result + InhLineFeed + InhLineFeed;;
      end;

   if (Listagem) then
      begin
         UpdateListagemMovimentos (DataInicial, DataFinal, Usuario);
         Result := Result + '======== Listagem de Movimentos de Caixa =======' + InhLineFeed + InhLineFeed;
         while not (ListagemMovimentos.Eof) do
            begin
               Result := Result + Format ('%s %s (%s) %s' + InhLineFeed,
                                 [
                                  Format ('%10.10s',  [ListagemMovimentos.FieldValues['datahora']]),
                                  Format ('%-24.24s', [ListagemMovimentos.FieldValues['forma_pagamento']]),
                                  Format ('%1.1s',    [ListagemMovimentos.FieldValues['tipo']]),
                                  Format ('%8.2f',    [ListagemMovimentos.FieldByName('valor').AsFloat])
                                 ]);
               Result := Result + Format ('Desc: %s' + InhLineFeed + InhLineFeed, [ListagemMovimentos.FieldValues['descricao_movimento']]);
               ListagemMovimentos.Next;
            end;
         Result := Result + InhLineFeed;
   end;

end;

function InhReportCaixaGetContraVales (DataInicial : TDateTime;
                                       DataFinal : TDateTime;
                                       Usuario : integer) : string;
var
   Sinal : string;
begin
  UpdateContraVales (DataInicial, DataFinal, Usuario);
  Result := Result + '==== Emissão / Recebimento de Contra-Vales =====' + InhLineFeed + InhLineFeed;
  while not (ContraVales.Eof) do
     begin
        if (ContraVales.FieldByName('valor').AsFloat < 0) then
           Sinal := '-' else Sinal := '+';
        Result := Result + Format ('%s (%s) %s' + InhLineFeed,
                                   [
                                    Format ('%-35.35s', [ContraVales.FieldValues['forma_pagamento']]),
                                    Sinal,
                                    Format ('%8.2f',    [Abs(ContraVales.FieldByName('valor').AsFloat)])
                                   ]);
        ContraVales.Next;
     end;
end;

function InhReportCaixaGetPendentes (DataInicial : TDateTime;
                                     DataFinal : TDateTime;
                                     Usuario : integer) : string;
begin
   UpdatePendentes (DataInicial, DataFinal, Usuario);
   Result := Result + '============ Fechamentos Pendentes =============' + InhLineFeed + InhLineFeed;
   while not (Pendentes.Eof) do
      begin
         Result := Result + Format ('%8u %-30s %8.2f' + InhLineFeed,
                                    [
                                     Pendentes.FieldByName('id').AsInteger,
                                     Pendentes.FieldByName('nome').AsString,
                                     Pendentes.FieldByName('valor').AsFloat
                                    ]);
         Pendentes.Next;
      end;
end;

function InhReportCaixaGetPendentesRecebidos (DataInicial : TDateTime;
                                              DataFinal : TDateTime;
                                              Usuario : integer) : string;
begin
   UpdatePendentesRecebidos (DataInicial, DataFinal, Usuario);
   Result := Result + '============= Pendentes Recebidos ==============' + InhLineFeed + InhLineFeed;
   while not (PendentesRecebidos.Eof) do
      begin
         Result := Result + Format ('%8u %-30s %8.2f' + InhLineFeed,
                                    [
                                     PendentesRecebidos.FieldByName('id').AsInteger,
                                     PendentesRecebidos.FieldByName('nome').AsString,
                                     PendentesRecebidos.FieldByName('valor').AsFloat
                                    ]);
         PendentesRecebidos.Next;
      end;
end;

function InhReportCaixaGetSaldoFinal (CaixaStatus : TInhCaixaStatus) : string;
var
   Contador : integer;
   Sinal : string;
   ValorSaldo : real;
   SinalSaldo : string;
begin
   ValorSaldo := 0;
   Result := '============= Saldo Final do Caixa =============' + InhLineFeed + InhLineFeed;
   for Contador := Low(CaixaStatus) to High(CaixaStatus) do
      begin
         if (CaixaStatus[Contador].Valor < 0) then
            Sinal := '-' else Sinal := '+';
         Result := Result + Format ('%s (%s) %s' + InhLineFeed,
                                    [
                                     Format ('%-35.35s', [CaixaStatus[Contador].FormaPagamento]),
                                     Sinal,
                                     Format ('%8.2f',    [Abs(CaixaStatus[Contador].Valor)])
                                    ]);
         ValorSaldo := ValorSaldo + CaixaStatus[Contador].Valor;
      end;

   Result := Result + InhLine48SubTotal + InhLineFeed;
   if (ValorSaldo < 0) then
      SinalSaldo := '-' else SinalSaldo := '+';
   Result := Result + Format ('                                    (%s) %8.2f', [SinalSaldo, Abs(ValorSaldo)]);
   Result := Result + InhLineFeed + InhLineFeed;
end;

procedure InhReportCaixaStatus (DataInicial : TDateTime; DataFinal : TDateTime; Usuario : integer);
var
   TF : TextFile;
   FileName : String;
begin
   FileName := InhReportGetTmpFileName();
   AssignFile(TF, FileName);
   Rewrite(TF);

   // Inicio de cabecalho
   Writeln(TF, InhLine48);
   Writeln(TF, '          S t a t u s   d e   C a i x a         ');
   Writeln(TF, InhLine48);
   // Fim de cabecalho

   // Parametros
   WriteLn(TF, 'Usuário: ' + IntToStr (Usuario));
   WriteLn(TF, 'Data/Hora Inicial: ' + FormatDateTime('dd/mm/yyyy hh:nn:ss', DataInicial));
   WriteLn(TF, 'Data/Hora Final:   ' + FormatDateTime('dd/mm/yyyy hh:nn:ss', DataFinal));
   WriteLn(TF, '');

   WriteLn(TF, InhReportCaixaGetRecebimentos (DataInicial, DataFinal, Usuario, True, True));

   WriteLn(TF, InhReportCaixaGetContraVales (DataInicial, DataFinal, Usuario));

   WriteLn(TF, InhReportCaixaGetMovimentos (DataInicial, DataFinal, Usuario, True, True));

   WriteLn(TF, InhReportCaixaGetPendentes (DataInicial, DataFinal, Usuario));
   WriteLn(TF, InhReportCaixaGetPendentesRecebidos (DataInicial, DataFinal, Usuario));

   WriteLn(TF, InhReportCaixaGetSaldoFinal (CaixaStatusFinal));

   SetLength (CaixaStatusFinal, 0);

   CloseFile(TF);
   InhReportViewerRun (FileName);
end;

procedure InhReportCaixaMovimentoReceipt (Descricao : String; Tipo : String; Valor : Real; FormaPagamento : String);
var
   TF : TextFile;
   FileName : String;
begin
   FileName := InhReportGetTmpFileName();
   AssignFile(TF, FileName);
   Rewrite(TF);

   // Inicio de cabecalho
   Writeln(TF, InhReportGetBoxedCabecalho());
   Writeln(TF, '       Comprovante de Movimento de Caixa        ');
   Writeln(TF, InhLine48);
   // Fim de cabecalho

   // Parametros
   WriteLn(TF, 'Emitido Por Usuário: ' + InhAccess.Id);
   WriteLn(TF, 'Data/Hora De Emissão: ' + FormatDateTime('dd/mm/yyyy hh:nn:ss', Now()));
   Writeln(TF, InhLine48);

   Writeln(TF, 'Tipo:  ' + Tipo + ' em ' + FormaPagamento);
   Writeln(TF, 'Valor: ' + Format ('%-8.2f', [Valor]));
   Writeln(TF, 'Desc:  ' + Descricao);

   Writeln(TF, '');
   Writeln(TF, '');
   Writeln(TF, '    ----------------------------------------    ');
   Writeln(TF, '            Assinatura Do Responsável           ');
   Writeln(TF, '');
   CloseFile(TF);
   InhReportViewerOrPrint (Filename, 'CaixaComprovanteMovimento');
end;

procedure InhReportContraVale (Valor : real);
var
   TF : TextFile;
   FileName : String;
begin
   FileName := InhReportGetTmpFileName();
   AssignFile(TF, FileName);
   Rewrite(TF);

   // Inicio de cabecalho
   WriteLn(TF, InhReportGetBoxedCabecalho());
   Writeln(TF, '   C   o   n   t   r   a   -   V   a   l   e    ');
   Writeln(TF, InhLine48);
   // Fim de cabecalho

   // Parametros
   WriteLn(TF, 'Emitido Por Usuário: ' + InhAccess.Id);
   WriteLn(TF, 'Data/Hora De Emissão: ' + FormatDateTime('dd/mm/yyyy hh:nn:ss', Now()));
   Writeln(TF, Format ('Valor: R$ %-8.2f', [Valor]));
   Writeln(TF, '');
   Writeln(TF, '');
   Writeln(TF, '');
   Writeln(TF, '    ----------------------------------------    ');
   Writeln(TF, '            Assinatura Do Responsável           ');
   Writeln(TF, '');
   CloseFile(TF);
   InhReportViewerOrPrint (Filename, 'CaixaContraVale');
end;

end.
