{
  redis command
}
unit uRedisCommand;

interface

uses
  Classes, SysUtils;

type
  TRedisCommand = class
  private
    FCommandList: TStrings;
  public
    constructor Create(); virtual;
    destructor Destroy; override;

    function Clear(): TRedisCommand;

    function Add(aValue: String): TRedisCommand; overload;
    function Add(aValue: Integer): TRedisCommand; overload;

    function ToRedisCommand: TBytes;
  end;

implementation

const
  //�س�����
  C_CRLF = #$0D#$0A;


{ TRedisCommand }

function TRedisCommand.Add(aValue: String): TRedisCommand;
begin
  FCommandList.Add(aValue);
  Result := Self;
end;

function TRedisCommand.Add(aValue: Integer): TRedisCommand;
begin
  FCommandList.Add(IntToStr(aValue));
  Result := Self;
end;

function TRedisCommand.Clear: TRedisCommand;
begin
  FCommandList.Clear;
  Result := Self;
end;

constructor TRedisCommand.Create;
begin
  inherited;
  FCommandList := TStringList.Create;
end;

destructor TRedisCommand.Destroy;
begin
  FCommandList.Free;
  inherited;
end;


{
�������
  *<��������> CR LF
  $<���� 1 ���ֽ�����> CR LF
  <���� 1 ������> CR LF
  ...
  $<���� N ���ֽ�����> CR LF
  <���� N ������> CR LF
}
function TRedisCommand.ToRedisCommand: TBytes;
var
  aCmd: string;
  i, aLen: Integer;
begin

  //��������
  aCmd := '*' + IntToStr(FCommandList.Count) + C_CRLF;

  //params
  for i := 0 to FCommandList.Count - 1 do
  begin
    //string len
    aLen := TEncoding.UTF8.GetByteCount(FCommandList.Strings[i]);

    aCmd := aCmd + '$' + IntToStr(aLen) + C_CRLF
      + FCommandList.Strings[i] + C_CRLF;

  end;

  Result := TEncoding.UTF8.GetBytes(aCmd);

end;

end.
