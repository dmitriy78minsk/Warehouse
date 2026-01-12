unit uDBUtils;

interface


uses
  System.UITypes, FMX.DialogService, FireDAC.Comp.DataSet, FireDAC.Stan.Error,
  Data.DB, FireDAC.Stan.Intf, udmMain;

type
  TDBUtils = class
  public
    class procedure safeDelete(DataSet: TDataSet; const Question: string; const ErrorMsg: string);
  end;

implementation

class procedure TDBUtils.safeDelete(DataSet: TDataSet; const Question: string; const ErrorMsg: string);
begin
  if (DataSet = nil) or DataSet.IsEmpty then Exit;

  TDialogService.MessageDialog(Question, TMsgDlgType.mtConfirmation,
    [TMsgDlgBtn.mbYes, TMsgDlgBtn.mbNo], TMsgDlgBtn.mbNo, 0,
    procedure(const AResult: TModalResult)
    begin
      if AResult = mrYes then
      try
        DataSet.Delete;
      except
        on E: EFDDBEngineException do
        begin
          if (E.ErrorCount > 0) and (E.Errors[0].ErrorCode = 547) then
            TDialogService.ShowMessage(ErrorMsg)
          else
            TDialogService.ShowMessage('Ошибка БД: ' + E.Message);
        end;
      end;
    end);
end;

end.
