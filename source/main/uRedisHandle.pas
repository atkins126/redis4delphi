{
  redis for delphi
}

unit uRedisHandle;

interface

uses
  Classes, IdTCPClient, SysUtils, StrUtils, IdException, uRedisCommand,
  uRedisCommon;


type

  //redis handle exception
  ERedisException = class(Exception);
  //redisӦ�������Ϣ
  ERedisErrorReply = class(Exception);

  //��redisӦ�����ʱ���ص��˺�������isHandled����true������ʾ�ɹ��������쳣
  TOnGetRedisError = procedure(aRedisCommand: TRedisCommand;
      var aResponseList: TStringList; aErr: string; var isHandled: Boolean) of object;

  //
  TRedisHandle = class
  private
    FPassword: string;
    FDb: Integer;
    FPort: Integer;
    FIp: string;
    FReadTimeout: Integer;
    FOnGetRedisError: TOnGetRedisError;
    procedure SetPassword(const Value: string);
    procedure SetDb(const Value: Integer);
    procedure SetIp(const Value: string);
    procedure SetPort(const Value: Integer);
    procedure SetReadTimeout(const Value: Integer);
    procedure SetOnGetRedisError(const Value: TOnGetRedisError);
  protected
    //������
    FRedisCommand: TRedisCommand;
    FResponseList: TStringList;
    //tcp
    FTcpClient: TIdTCPClient;

    function GetConnection: Boolean;
    procedure SetConnection(const Value: Boolean);
    //tcp
    procedure NewTcpClient;

    //�쳣
    procedure RaiseErr(aErr: string);

    //��װ���������� �����ݷ���
    procedure SendCommandWithNoResponse(aRedisCommand: TRedisCommand);
    //��ȡStringӦ���޷��ؿ�
    function SendCommandWithStrResponse(aRedisCommand: TRedisCommand): string;
    //��ȡIntegerӦ���޷���0
    function SendCommandWithIntResponse(aRedisCommand: TRedisCommand): Integer;



    //��װ����������
    procedure SendCommand(aRedisCommand: TRedisCommand);
    //��ȡӦ�𲢽���
    procedure ReadAndParseResponse(var aResponseList: TStringList);

  public
    constructor Create(); virtual;
    destructor Destroy; override;

    //����
    property Connection: Boolean read GetConnection write SetConnection;
    //Ӧ��
    property ResponseList: TStringList read FResponseList;

    //�����������Ӧ��
    procedure SendCommandAndGetResponse(aRedisCommand: TRedisCommand;
      var aResponseList: TStringList);

    ////////////////////////////////////////////////////////////////////////////
    ///                     ����
    //ʹ��Password��֤
    procedure RedisAuth();
    //ѡ��Db���ݿ⣬Ĭ��ʹ��0�����ݿ�
    procedure RedisSelect();

    ////////////////////////////////////////////////////////////////////////////
    ///                     Key
    //Redis DEL ��������ɾ���Ѵ��ڵļ��������ڵ� key �ᱻ���ԡ�
    procedure KeyDelete(aKey: String);
    //Redis EXISTS �������ڼ����� key �Ƿ���ڡ�
    function KeyExist(aKey: String): Boolean;
    //Redis Expire ������������ key �Ĺ���ʱ�䣬key ���ں󽫲��ٿ��á���λ����ơ�
    procedure KeySetExpire(aKey: String; aExpireSec: Integer);
    ////////////////////////////////////////////////////////////////////////////


    ////////////////////////////////////////////////////////////////////////////
    ///                     String
    //Redis Get �������ڻ�ȡָ�� key ��ֵ����� key �����ڣ����� nil �����key �����ֵ�����ַ������ͣ�����һ������
    function StringGet(aKey: string): string;
    //Redis SET �����������ø��� key ��ֵ����� key �Ѿ��洢����ֵ�� SET �͸�д��ֵ�����������͡�
    procedure StringSet(aKey, aValue: String); overload;
    //Redis Getset ������������ָ�� key ��ֵ�������� key �ľ�ֵ��
    function StringGetSet(aKey, aValue: String): String;

    //set ����ʱ���룩
    procedure StringSet(aKey, aValue: String; aExpireSec: Int64); overload;
    ////////////////////////////////////////////////////////////////////////////


    ////////////////////////////////////////////////////////////////////////////
    ///                     List
    //list��β����ֵ�������µ�list����
    //Redis Rpush �������ڽ�һ������ֵ���뵽�б��β��(���ұ�)��
    //����б�����,һ�����б�ᱻ������ִ��RPUSH ���������б���ڵ������б�����ʱ����һ������
    //Insert all the specified values at the tail of the list stored at key.
    //If key does not exist, it is created as empty list before performing the push operation.
    //When key holds a value that is not a list, an error is returned.
    function ListRPush(aKey, aValue: string): Integer; overload;
    function ListRPush(aKey: string; aValues: array of string): Integer; overload;

    //Redis Lpush ���һ������ֵ���뵽�б�ͷ���� ��� key �����ڣ�
    //һ�����б�ᱻ������ִ�� LPUSH ������ �� key ���ڵ������б�����ʱ������һ������
    function ListLPush(aKey, aValue: string): Integer; overload;
    function ListLPush(aKey: string; aValues: array of string): Integer; overload;

    //Redis Rpop ���������Ƴ��б�����һ��Ԫ�أ�����ֵΪ�Ƴ���Ԫ�أ������ݷ��ؿա�
    function ListRPop(aKey: string): string;
    //Redis Lpop ���������Ƴ��������б�ĵ�һ��Ԫ�أ������ݷ��ؿա�
    function ListLPop(aKey: string): string;

    //��ȡlist��С
    function ListLen(aKey: string): Integer;
    //��ȡlist��Χ����,��ȡ�����ݲ����ᱻɾ��
    function ListRange(aKey: string; aBegin, aEnd: Integer; var aRetValues: TStringList): Integer;

    //Redis Lrem ���ݲ��� COUNT ��ֵ���Ƴ��б�������� VALUE ��ȵ�Ԫ��,�����Ƴ����ݸ���
    //COUNT ��ֵ���������¼��֣�
    //count > 0 : �ӱ�ͷ��ʼ���β�������Ƴ��� VALUE ��ȵ�Ԫ�أ�����Ϊ COUNT ��
    //count < 0 : �ӱ�β��ʼ���ͷ�������Ƴ��� VALUE ��ȵ�Ԫ�أ�����Ϊ COUNT �ľ���ֵ��
    //count = 0 : �Ƴ����������� VALUE ��ȵ�ֵ��
    //Removes the first count occurrences of elements equal to element from the list stored at key
    //The count argument influences the operation in the following ways:
    //count > 0: Remove elements equal to element moving from head to tail.
    //count < 0: Remove elements equal to element moving from tail to head.
    //count = 0: Remove all elements equal to element.
    function ListRemove(aKey, aValue: string; aCount: Integer): Integer;
    ////////////////////////////////////////////////////////////////////////////


    ////////////////////////////////////////////////////////////////////////////
    //redis ip
    property Ip: string read FIp write SetIp;
    //redis port
    property Port: Integer read FPort write SetPort;
    //redis ����ʱ
    property ReadTimeout: Integer read FReadTimeout write SetReadTimeout;

    //redis ����
    property Password: string read FPassword write SetPassword;
    //redis ���ݿ�
    property Db: Integer read FDb write SetDb;
    //��redisӦ�����ʱ���ص��˺�������isHandled����true������ʾ�ɹ��������쳣
    property OnGetRedisError: TOnGetRedisError read FOnGetRedisError write SetOnGetRedisError;
  end;


implementation

{ TRedisHandle }

constructor TRedisHandle.Create();
begin
  FIp := Redis_Default_Ip;
  FPort := Redis_Default_Port;
  FPassword := '';
  FDb := 0;

  FRedisCommand := TRedisCommand.Create;
  FResponseList := TStringList.Create;

  NewTcpClient;
end;

destructor TRedisHandle.Destroy;
begin
  FTcpClient.Free;
  FRedisCommand.Free;
  FResponseList.Free;

  inherited;
end;


procedure TRedisHandle.RaiseErr(aErr: string);
begin
  raise ERedisException.Create(aErr);
end;


procedure TRedisHandle.ReadAndParseResponse(var aResponseList: TStringList);
var
  aRetType: string;
  aLen: Integer;
  aBuff: TBytes;
  i, aBegin: Integer;
begin

//  aRetType := FTcpClient.IOHandler.ReadByte;
//
//  if aRetType = $2B then
//  begin
//    //״̬�ظ���status reply���ĵ�һ���ֽ��� "+"
//  end
//  else if aRetType = $3A then
//  begin
//    //�����ظ���integer reply���ĵ�һ���ֽ��� ":"
//  end
//  else if aRetType = $24 then
//  begin
//    //�����ظ���bulk reply���ĵ�һ���ֽ��� "$"
//  end
//  else if aRetType = $2A then
//  begin
//    //���������ظ���multi bulk reply���ĵ�һ���ֽ��� "*"
//  end;


  FTcpClient.IOHandler.ReadBytes(aBuff, -1, False);

  aLen := Length(aBuff);
  if aLen = 0 then RaiseErr('��Ӧ��');


  if aLen <= 2 then
  begin
    Sleep(100);
    FTcpClient.IOHandler.ReadBytes(aBuff, -1, True);

    aLen := Length(aBuff);
  end;

  if aLen <= 2 then
    RaiseErr('δ֪Ӧ��:' + TEncoding.UTF8.GetString(aBuff));


  //��������
  aRetType := TEncoding.UTF8.GetString(aBuff, 0, 1);

  if aRetType = '-' then
  begin
    //����ظ���error reply���ĵ�һ���ֽ��� "-"
    raise ERedisErrorReply.Create(TEncoding.UTF8.GetString(aBuff, 1, aLen - 2));
  end;

  aResponseList.Clear;
  aResponseList.Add(aRetType);
  //Ӧ������
  aBegin := 1;
  for i := 2 to aLen - 2 do
  begin
    if (aBuff[i] = $0D) and (aBuff[i + 1] = $0A) then
    begin
      aResponseList.Add(TEncoding.UTF8.GetString(aBuff, aBegin, i - aBegin));
      aBegin := i + 2;
    end;
  end;

  if aResponseList.Count < 2 then RaiseErr('Ӧ������ȱʧ');


end;

procedure TRedisHandle.RedisAuth;
var
  aCommand: TRedisCommand;
begin

  aCommand := TRedisCommand.Create;
  try
    //AUTH <password>
    aCommand.Clear.Add('AUTH').Add(FPassword);
    //����,��ȡӦ�𲢽���
    SendCommandWithNoResponse(aCommand);
  finally
    aCommand.Free;
  end;

end;


function TRedisHandle.StringGet(aKey: string): string;
begin
  FRedisCommand.Clear.Add('GET').Add(aKey);
  //����,��ȡӦ�𲢽���
  Result := SendCommandWithStrResponse(FRedisCommand);
end;


function TRedisHandle.StringGetSet(aKey, aValue: String): String;
begin
  FRedisCommand.Clear.Add('GETSET').Add(aKey).Add(aValue);
  //����,��ȡӦ�𲢽���
  Result := SendCommandWithStrResponse(FRedisCommand);
end;


procedure TRedisHandle.StringSet(aKey, aValue: String);
begin
  StringSet(aKey, aValue, -1);
end;

procedure TRedisHandle.StringSet(aKey, aValue: String; aExpireSec: Int64);
begin
  FRedisCommand.Clear.Add('SET').Add(aKey).Add(aValue);
  if aExpireSec > 0 then
  begin
    FRedisCommand.Add('EX').Add(IntToStr(aExpireSec));
  end;

  //����,��ȡӦ�𲢽���
  SendCommandWithNoResponse(FRedisCommand);

end;


procedure TRedisHandle.RedisSelect();
var
  aCommand: TRedisCommand;
begin
  aCommand := TRedisCommand.Create;
  try
    //SELECT index
    aCommand.Clear.Add('SELECT').Add(IntToStr(FDb));
    //����,��ȡӦ�𲢽���
    SendCommandWithNoResponse(aCommand);
  finally
    aCommand.Free;
  end;
end;


function TRedisHandle.GetConnection: Boolean;
begin
  Result := Assigned(FTcpClient) and FTcpClient.Connected;
end;


procedure TRedisHandle.KeyDelete(aKey: String);
begin
  FRedisCommand.Clear.Add('DEL').Add(aKey);
  //����,��ȡӦ�𲢽���
  SendCommandWithNoResponse(FRedisCommand);
end;

function TRedisHandle.KeyExist(aKey: String): Boolean;
begin
  FRedisCommand.Clear.Add('EXISTS').Add(aKey);
  //����,��ȡӦ�𲢽���
  Result := SendCommandWithIntResponse(FRedisCommand) <> 0;
end;

procedure TRedisHandle.KeySetExpire(aKey: String; aExpireSec: Integer);
begin
  FRedisCommand.Clear.Add('EXPIRE').Add(aKey).Add(IntToStr(aExpireSec));
  //����,��ȡӦ�𲢽���
  SendCommandWithNoResponse(FRedisCommand);
end;

function TRedisHandle.ListRange(aKey: string; aBegin, aEnd: Integer;
  var aRetValues: TStringList): Integer;
var
  i: Integer;
begin
  FRedisCommand.Clear.Add('LRANGE').Add(aKey)
    .Add(IntToStr(aBegin)).Add(IntToStr(aEnd));

  //����
  SendCommandAndGetResponse(FRedisCommand, FResponseList);

  Result := StrToInt(FResponseList.Strings[1]);

  aRetValues.Clear;

  if Result <= 0 then Exit;

  for i := 0 to Result - 1 do
  begin
    aRetValues.Add(FResponseList.Strings[3 + i * 2]);
  end;

end;

function TRedisHandle.ListRemove(aKey, aValue: string; aCount: Integer): Integer;
begin
  FRedisCommand.Clear.Add('LREM').Add(aKey).Add(IntToStr(aCount)).Add(aValue);
  //����
  Result := SendCommandWithIntResponse(FRedisCommand);
end;


function TRedisHandle.ListLen(aKey: string): Integer;
begin
  FRedisCommand.Clear.Add('LLEN').Add(aKey);
  //����
  Result := SendCommandWithIntResponse(FRedisCommand);
end;


function TRedisHandle.ListLPop(aKey: string): string;
begin
  FRedisCommand.Clear.Add('LPOP').Add(aKey);
  //����
  Result := SendCommandWithStrResponse(FRedisCommand);

end;

function TRedisHandle.ListLPush(aKey, aValue: string): Integer;
begin
  Result := ListLPush(aKey, [aValue]);
end;

function TRedisHandle.ListLPush(aKey: string;
  aValues: array of string): Integer;
var
  i: Integer;
begin
  if Length(aValues) <= 0 then RaiseErr('������');

  FRedisCommand.Clear.Add('LPUSH').Add(aKey);
  for i := 0 to Length(aValues) - 1 do
    FRedisCommand.Add(aValues[i]);

  //����
  Result := SendCommandWithIntResponse(FRedisCommand);

end;

function TRedisHandle.ListRPop(aKey: string): string;
begin
  FRedisCommand.Clear.Add('RPOP').Add(aKey);
  //����
  Result := SendCommandWithStrResponse(FRedisCommand);
end;



function TRedisHandle.ListRPush(aKey, aValue: string): Integer;
begin
  Result := ListRPush(aKey, [aValue]);
end;


function TRedisHandle.ListRPush(aKey: string;
  aValues: array of string): Integer;
var
  i: Integer;
begin
  if Length(aValues) <= 0 then RaiseErr('������');

  FRedisCommand.Clear.Add('RPUSH').Add(aKey);
  for i := 0 to Length(aValues) - 1 do
    FRedisCommand.Add(aValues[i]);

  //����
  Result := SendCommandWithIntResponse(FRedisCommand);

end;


procedure TRedisHandle.NewTcpClient;
begin
  if Assigned(FTcpClient) then
  begin
    try
      FreeAndNil(FTcpClient);
    except
      on E: Exception do
      begin
      end;
    end;
  end;

  FTcpClient := TIdTCPClient.Create(nil);
end;

function TRedisHandle.SendCommandWithIntResponse(
  aRedisCommand: TRedisCommand): Integer;
begin
  SendCommandAndGetResponse(aRedisCommand, FResponseList);

  Result := StrToInt(FResponseList.Strings[1]);
end;

procedure TRedisHandle.SendCommandWithNoResponse(aRedisCommand: TRedisCommand);
begin
  SendCommandAndGetResponse(aRedisCommand, FResponseList);
end;

function TRedisHandle.SendCommandWithStrResponse(
  aRedisCommand: TRedisCommand): string;
begin
  SendCommandAndGetResponse(aRedisCommand, FResponseList);

  if StrToInt(FResponseList.Strings[1]) <= 0 then Exit('');

  Result := FResponseList.Strings[2];
end;



procedure TRedisHandle.SendCommand(aRedisCommand: TRedisCommand);
var
  aBuff: TBytes;
begin
  aBuff := aRedisCommand.ToRedisCommand;

  try
    FTcpClient.IOHandler.Write(aBuff);
  except
    on E: EIdException do
    begin
      NewTcpClient;
      raise e;
    end;
  end;

end;

procedure TRedisHandle.SendCommandAndGetResponse(aRedisCommand: TRedisCommand;
  var aResponseList: TStringList);
var
  isHandled: Boolean;
begin
  Connection := True;

  SendCommand(aRedisCommand);
  try
    ReadAndParseResponse(aResponseList);
  except
    on E: ERedisErrorReply do
    begin
      if Assigned(FOnGetRedisError) then
      begin
        FOnGetRedisError(aRedisCommand, aResponseList, e.Message, isHandled);
        if isHandled then Exit;
      end;

      raise e;

    end;
  end;

end;




procedure TRedisHandle.SetConnection(const Value: Boolean);
begin
  if Value = GetConnection then Exit;

  try
    if Value then
    begin
      if FIp = '' then FIp := Redis_Default_Ip;
      if FPort <= 0 then FPort := Redis_Default_Port;
      if FReadTimeout <= 0 then FReadTimeout := Redis_default_ReadTimeout;

      FTcpClient.Host := FIp;
      FTcpClient.Port := FPort;
      FTcpClient.ReadTimeout := FReadTimeout;
      FTcpClient.Connect;

      if Password <> '' then RedisAuth;
      if Db <> 0 then RedisSelect;

    end
    else
    begin
      FTcpClient.Disconnect;
    end;

  except
    on E: EIdException do
    begin
      NewTcpClient;
      raise e;
    end;
  end;


end;

procedure TRedisHandle.SetDb(const Value: Integer);
begin
  FDb := Value;
end;


procedure TRedisHandle.SetIp(const Value: string);
begin
  FIp := Value;
end;

procedure TRedisHandle.SetOnGetRedisError(const Value: TOnGetRedisError);
begin
  FOnGetRedisError := Value;
end;

procedure TRedisHandle.SetPassword(const Value: string);
begin
  FPassword := Value;
end;



procedure TRedisHandle.SetPort(const Value: Integer);
begin
  FPort := Value;
end;

procedure TRedisHandle.SetReadTimeout(const Value: Integer);
begin
  FReadTimeout := Value;
end;

end.
