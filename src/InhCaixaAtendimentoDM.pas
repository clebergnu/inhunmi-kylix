{InhunmiCaixaAtendimentoDM.pas - Inhunmi "Teller" Data Module

 Copyright (C) 2002, Cleber Rodrigues <cleberrrjr@bol.com.br>

 This program is free software; you can redistribute it and/or modify
 it under the terms of the GNU General Public License as published by
 the Free Software Foundation; either version 2 of the License, or
 (at your option) any later version.

 This program is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 GNU General Public License for more details.

 You should have received a copy of the GNU General Public License
 along with this program; if not, write to the Free Software
 Foundation, Inc., 59 Temple Place, Suite 330,
 Boston, MA 02111-1307, USA.
}

unit InhCaixaAtendimentoDM;

interface

uses
  SysUtils, Classes, Provider, SqlExpr, DB, DBClient, DBLocal, DBLocalS,
  FMTBcd, InhBiblio, InhConfig, Variants;

//utility functions
function  InhCaixaAtendimentoUpdate (DataSet : TDataSet) : integer;
//function  InhCaixaAtendimentoLookUp (DataSet : TSQLClientDataSet; Key : String) : boolean;

type
  TCaixaAtendimentoDM = class(TDataModule)
    PortaConsumoDSet: TSQLClientDataSet;
    PortaConsumoDSource: TDataSource;
    ConsumoDSet: TSQLClientDataSet;
    ConsumoDSource: TDataSource;
    ConsumoDSetid: TIntegerField;
    ConsumoDSetproduto_quantidade: TIntegerField;
    ConsumoDSetvalor: TFloatField;
    ConsumoDSetdatahora: TSQLTimeStampField;
    ConsumoDSettotal: TAggregateField;
    ConsumoDSetproduto: TIntegerField;
    PessoaInstituicaoDset: TSQLDataSet;
    PessoaInstituicaoDsource: TDataSource;
    PagamentoDSet: TSQLClientDataSet;
    PagamentoDSource: TDataSource;
    PagamentoDSetid: TIntegerField;
    PagamentoDSetdono: TIntegerField;
    PagamentoDSetforma_pagamento: TIntegerField;
    PagamentoDSetvalor: TFloatField;
    PagamentoDSetdatahora: TSQLTimeStampField;
    PagamentoDSettotal: TAggregateField;
    PessoaInstituicaoDsetnome: TStringField;
    ConsumoDSetproduto_descricao: TStringField;
    procedure PortaConsumoDSetAfterScroll(DataSet: TDataSet);
    procedure PortaConsumoDSetBeforeClose(DataSet: TDataSet);
    procedure PortaConsumoDSetAfterOpen(DataSet: TDataSet);
    procedure ConsumoDSetAfterOpen(DataSet: TDataSet);
    procedure ConsumoDSetBeforeClose(DataSet: TDataSet);
  private
    PortaConsumoAnterior : Integer;
    PortaConsumoBookMark : TBookMark;
    ConsumoBookMark : TBookMark;
  public
    function  DMOpen () : boolean;
    procedure DMClose ();

    function  PortaConsumoGoto (PortaConsumoId : String) : boolean;
    procedure PortaConsumoUpdateCommandText (Tipo : String; Status : String);

    procedure PortaConsumoUpdateAll ();
    procedure PortaConsumoUpdatePagamento ();
    procedure PortaConsumoUpdatePessoaInstituicao ();
    procedure PortaConsumoUpdateAPagar ();

    procedure PortaConsumoUpdateConsumo ();

    function  ConsumoGoto (ConsumoId : String) : boolean;
  end;

function InhCaixaAtendimentoDMNew (AOwner : TComponent) : TCaixaAtendimentoDM;

implementation

uses InhMain, InhCaixaAtendimento;

{$R *.xfm}

function InhCaixaAtendimentoDMNew (AOwner : TComponent) : TCaixaAtendimentoDM;
var
   MyDM : TCaixaAtendimentoDM;
begin
   MyDM := TCaixaAtendimentoDM.Create(AOwner);

   Result := MyDM;
end;

function TCaixaAtendimentoDM.DMOpen () : boolean;
begin
   PortaConsumoUpdateCommandText(GlobalConfig.ReadString('Atendimento', 'TipoPadrao', 'Todos'),
                                 GlobalConfig.ReadString('Atendimento', 'StatusPadrao', 'Aberto'));
   Result := True;
end;

procedure TCaixaAtendimentoDM.DMClose ();
begin
   PortaConsumoDSet.Close;
   ConsumoDSet.Close;
   PagamentoDSet.Close;
   PessoaInstituicaoDset.Close;
end;

function GetStatusWhereSQL (Status : String) : string;
begin
   if (Status = 'Todos') then
      Result := ''
   else
      Result := '(status = "' + Status + '")  AND ';
end;

procedure TCaixaAtendimentoDM.PortaConsumoUpdateCommandText (Tipo : String; Status : String);
var
   DiasPassados : String;
   DiasFuturos : String;

   SelectPadrao : String;
   WhereDataPadrao  : String;
   OrderPadrao : String;
   SelectEncomenda :String;
begin
   if PortaConsumoDSet.Active = true then
      PortaConsumoDSet.Close;

   DiasPassados := GlobalConfig.ReadString('Atendimento', 'DiasPassados', '3');
   DiasFuturos  := GlobalConfig.ReadString('Atendimento', 'DiasFuturos', '3');

   SelectPadrao := 'SELECT porta_consumo.*, "Não Disponível" as datahora_entrega FROM porta_consumo WHERE ';

   WhereDataPadrao :=  '( ' +
                       '  (datahora_inicial BETWEEN (NOW() - INTERVAL ' + DiasPassados + ' DAY) AND (NOW() + INTERVAL ' + DiasFuturos + ' DAY)) ' +
                       '  OR ' +
                       '  (datahora_final BETWEEN (NOW() - INTERVAL ' + DiasPassados + ' DAY) AND (NOW() + INTERVAL ' + DiasFuturos + ' DAY)) ' +
                       ')';

   OrderPadrao := ' ORDER BY porta_consumo.numero, porta_consumo.datahora_inicial';

   if (Tipo = 'Encomenda') then
      SelectEncomenda := 'SELECT porta_consumo.*, encomenda.datahora_entrega FROM porta_consumo, encomenda WHERE ' +
                         '( ' +
                         ' (encomenda.dono = porta_consumo.id) AND '  +
                         ' (tipo = "Encomenda") AND ' +
                         GetStatusWhereSQL (Status) +
//                         ' (status = "Aberto")  AND ' +
                         ' ( ' +
                         '  (datahora_entrega BETWEEN (NOW() - INTERVAL ' + DiasPassados + ' DAY) AND (NOW() + INTERVAL ' + DiasFuturos + ' DAY)) ' +
                         '  OR ' +
                         '  (datahora_inicial BETWEEN (NOW() - INTERVAL ' + DiasPassados + ' DAY) AND (NOW() + INTERVAL ' + DiasFuturos + ' DAY)) ' +
                         '  OR ' +
                         '  (datahora_final   BETWEEN (NOW() - INTERVAL ' + DiasPassados + ' DAY) AND (NOW() + INTERVAL ' + DiasFuturos + ' DAY)) ' +
                         ' ) ' +
                         ') ORDER BY datahora_entrega';

   // Decide which query to use
   // Needs some debugging
   if (Tipo = 'Todos') and (Status = 'Todos') then
      PortaConsumoDSet.CommandText := SelectPadrao + WhereDataPadrao

   else if (Tipo = 'Encomenda') then
      PortaConsumoDSet.CommandText := SelectEncomenda

   else if (Status <> 'Todos') and (Tipo = 'Todos') then
      PortaConsumoDSet.CommandText := SelectPadrao + 'status = "' + Status + '" AND ' + WhereDataPadrao + OrderPadrao

   else if (Tipo <> 'Todos') and (Status = 'Todos') then
      PortaConsumoDSet.CommandText := SelectPadrao + 'tipo = "' + Tipo + '" AND ' + WhereDataPadrao + OrderPadrao

   else
      PortaConsumoDSet.CommandText := SelectPadrao + 'tipo = "' + Tipo + '" AND status = "' + Status + '" AND ' + WhereDataPadrao + OrderPadrao;

   PortaConsumoDSet.Open;
   PortaConsumoUpdateAll ();
end;

// Esta função atualiza a lista de porta_consumos,
// e tenta posicionar o cursor sobre o devido registro.
// Depois disso, atualiza TODOS os outros dados relacionados
// a este porta_consumo
function TCaixaAtendimentoDM.PortaConsumoGoto (PortaConsumoId : String) : boolean;
begin
   if (PortaConsumoDSet.Active) and
      (PortaConsumoDSet.RecordCount > 0) then
      PortaConsumoId := PortaConsumoDSet.FieldByName('id').AsString
   else
      PortaConsumoId := '';

   // primeiro passo, atualiza a lista de porta_consumos
   // se não tivermos nenhum registro, não prosseguir
   if InhCaixaAtendimentoUpdate(PortaConsumoDSet) <= 0 then
      begin
         Result := False;
         exit;
      end;

   // procura por registro com id = 'PortaConsumoId'
   Result := PortaConsumoDSet.Locate('id', VarArrayOf([PortaConsumoId]), []);

   // atualiza todos outros dados, ou do registro que foi encontrado
   // (porque existia) ou do registro atual (posicionado automaticamente)
   PortaConsumoUpdateAll ();
end;

procedure TCaixaAtendimentoDM.PortaConsumoUpdateAll ();
begin
   PortaConsumoUpdateConsumo ();
   PortaConsumoUpdatePagamento ();
   PortaConsumoUpdateAPagar ();
   PortaConsumoUpdatePessoaInstituicao ();
end;

procedure TCaixaAtendimentoDM.PortaConsumoUpdateConsumo ();
begin
   if ((PortaConsumoDSet.Active) and (PortaConsumoDSet.RecordCount > 0)) then
      with ConsumoDSet do
         begin
            if Active = true then
               Close;
            Params[0].Value := PortaConsumoDSet.FieldByName('id').AsString;
            Open;
         end
   else
      begin
         ConsumoDSet.Close;
         exit;
      end;
end;

function TCaixaAtendimentoDM.ConsumoGoto (ConsumoId : String) : boolean;
begin
   if (PortaConsumoDSet.Active = False) or (PortaConsumoDSet.RecordCount = 0) then
      begin
         Result := False;
         exit;
      end;
   with ConsumoDSet do
      begin
         if Active = true then
            Close;
          Params[0].Value := PortaConsumoDSet.FieldByName('id').AsString;
          Open;
          if RecordCount <= 0 then
             begin
                 Result := False;
                 exit;
             end;
      end;
   Result := ConsumoDSet.Locate('id', VarArrayOf([ConsumoId]), []);
end;

procedure TCaixaAtendimentoDM.PortaConsumoUpdatePagamento ();
begin
   if (PortaConsumoDSet.Active = False) or (PortaConsumoDSet.RecordCount = 0) then
      begin
         PagamentoDSet.Close;
         exit;
      end;
   with PagamentoDSet do
      begin
         if Active = True then
            Close;
         Params[0].Value := PortaConsumoDSet.FieldByName('id').AsString;
         Open;
      end
end;

procedure TCaixaAtendimentoDM.PortaConsumoUpdateAPagar ();
var
   Total  : Currency;
   Pago   : Currency;
   APagar : Currency;
   Texto  : String;
   AtendimentoForm : TInhCaixaAtendimentoForm;
begin
   AtendimentoForm := InhMainForm.GetAtendimentoForm;

   assert (assigned(AtendimentoForm));
   assert (AtendimentoForm is TInhCaixaAtendimentoForm);

   // --- BLOCO Total --- //
   Total := 0;
   if (ConsumoDSet.Active) then
      if (ConsumoDSet.RecordCount > 0) then
         Total := ConsumoDSet.FieldByName('total').Value;
   // --- BLOCO Total --- //


   // --- BLOCO Pago --- //
   Pago := 0;
   if (PagamentoDSet.Active) then
      if (PagamentoDSet.RecordCount > 0) then
      Pago  := PagamentoDSet.FieldByName('total').Value;
   // --- BLOCO Pago --- //

   APagar := Total - Pago;
   Texto := Format ('R$ %.2f', [APagar]);

   if (PortaConsumoDSet.Active = False) or (PortaConsumoDSet.RecordCount = 0) then
      AtendimentoForm.APagarLabel.Caption := '';

   AtendimentoForm.APagarLabel.Caption := Texto;
end;

procedure TCaixaAtendimentoDM.PortaConsumoUpdatePessoaInstituicao ();
begin
   if (PortaConsumoDSet.Active = False) or (PortaConsumoDSet.RecordCount = 0) then
      exit;
   if (not PortaConsumoDSet.FieldByName('dono').IsNull) then
      begin
         with PessoaInstituicaoDSet do
            begin
               if Active = true then
                  Close;
               Params[0].Value := PortaConsumoDSet.FieldByName('dono').AsString;
               Open;
            end;
         end
   else
      PessoaInstituicaoDSet.Close;
end;

procedure TCaixaAtendimentoDM.PortaConsumoDSetAfterScroll(DataSet: TDataSet);
begin
   if (PortaConsumoDSet.RecordCount > 0) then
      PortaConsumoUpdateConsumo ()
   else
      ConsumoDSet.Close;
   PortaConsumoUpdateAll ();
end;


// retorna numero de registros depois da atualizacao
function InhCaixaAtendimentoUpdate (DataSet : TDataSet) : integer;
begin
   with DataSet do
      begin
         if Active then Close;
            Open;
         Result := RecordCount;
      end;
end;

procedure TCaixaAtendimentoDM.PortaConsumoDSetBeforeClose(
  DataSet: TDataSet);
begin
   if Assigned(DataSet) then
      if (DataSet.RecordCount > 0) then
         begin
            PortaConsumoAnterior := DataSet.FieldByName('id').AsInteger;
            PortaConsumoBookMark := DataSet.GetBookmark;
         end;
end;

procedure TCaixaAtendimentoDM.PortaConsumoDSetAfterOpen(DataSet: TDataSet);
begin
   if Assigned(DataSet) and Assigned(PortaConsumoBookMark) then
      if (DataSet.RecordCount > 0) then
         begin
            try DataSet.GotoBookmark(PortaConsumoBookMark)
            except on EDataBaseError do ;
            end;
            DataSet.FreeBookmark(PortaConsumoBookMark);
         end;
end;

procedure TCaixaAtendimentoDM.ConsumoDSetAfterOpen(DataSet: TDataSet);
begin
   if (DataSet <> nil) and (ConsumoBookMark <> nil) then
      if (DataSet.RecordCount > 0) then
         if (PortaConsumoAnterior = PortaConsumoDSet.FieldByName('id').AsInteger) then
            begin
               DataSet.GotoBookmark(ConsumoBookMark);
               DataSet.FreeBookmark(ConsumoBookMark);
            end;
end;

procedure TCaixaAtendimentoDM.ConsumoDSetBeforeClose(DataSet: TDataSet);
begin
   if (DataSet <> nil) then
      if (DataSet.RecordCount > 0) then
         ConsumoBookMark := DataSet.GetBookmark;
end;

end.
