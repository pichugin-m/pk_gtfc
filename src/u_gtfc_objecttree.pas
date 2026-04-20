unit u_gtfc_objecttree;

{$mode objfpc}{$H+}

//************************************************************
//
//    Модуль компонента Graphic Task Flow Control
//    Copyright (c) 2013  Pichugin M.
//    rev. 16
//    Разработчик: Pichugin M. (e-mail: pichugin-swd@mail.ru)
//
//************************************************************

interface

uses
  Contnrs, Classes, Dialogs, SysUtils, Variants, TypInfo,
  u_gtfc_geometry, ComCtrls, ImgList, LCLType;

type

  { Forward Declarartions }

  TGTFCOutsetBasicTree = class;
  TGTFCOutsetTreeBasicItem = class;
  TGTFCListColumns = class;
  TGTFCListColumnItem = class;

  { Data types }

  TGTFCOutsetTreeClickResult = (tcrNone,tcrBody,tcrButton);
  //todo
  //TGTFCOutsetTreeState = set of (ttsNone,ttsCreating,ttsEditing,ttsMoving,ttsSelected);
  //TGTFCOutsetTreeDrawStyle = set of (tdsNone,tdsNormal,tdsSelected,tdsEditing,tdsMoving,tdsCreating);

  { TGTFCListColumnItem class }

  TGTFCListColumnItem = class
  private
    FAlignment: TAlignment;
    FAutoSize: Boolean;
    FCaption: TTranslateString;
    FColor: integer;
    FImageIndex: TImageIndex;
    FMaxWidth: TWidth;
    FMinWidth: TWidth;
    FWidth: TWidth;
    FSortIndicator: TSortIndicator;
    FTag: PtrInt;
    FVisible: Boolean;
    function GetWidth: TWidth;
    procedure SetAlignment(AValue: TAlignment);
    procedure SetAutoSize(AValue: Boolean);
    procedure SetCaption(AValue: TTranslateString);
    procedure SetColor(AValue: integer);
    procedure SetImageIndex(AValue: TImageIndex);
    procedure SetMaxWidth(AValue: TWidth);
    procedure SetMinWidth(AValue: TWidth);
    procedure SetSortIndicator(AValue: TSortIndicator);
    procedure SetVisible(AValue: Boolean);
    procedure SetWidth(AValue: TWidth);

  public
    property Alignment: TAlignment read FAlignment write SetAlignment;
    property AutoSize: Boolean read FAutoSize write SetAutoSize;
    property Caption: TTranslateString read FCaption write SetCaption;
    property ImageIndex: TImageIndex read FImageIndex write SetImageIndex;
    property Color : integer read FColor write SetColor;
    property MaxWidth: TWidth read FMaxWidth write SetMaxWidth;
    property MinWidth: TWidth read FMinWidth write SetMinWidth;
    property Tag: PtrInt read FTag write FTag;
    property Visible: Boolean read FVisible write SetVisible;
    property Width: TWidth read GetWidth write SetWidth;
    property SortIndicator: TSortIndicator read FSortIndicator write SetSortIndicator;

    constructor Create;
    destructor Destroy; override;
  end;

  { TGTFCListColumns class }

  TGTFCListColumns = class(TObjectList)
  private
    FUpdateCount              : Integer;
  protected
    function GetItem(Index: Integer): TGTFCListColumnItem;
    procedure SetItem(Index: Integer; const Value: TGTFCListColumnItem);
  public
    property Items[Index: Integer]: TGTFCListColumnItem read GetItem
                                                         write SetItem; default;
    procedure Insert(Index: Integer; Item: TGTFCListColumnItem);
    function Add(Item: TGTFCListColumnItem): Integer; overload;
    function Add: TGTFCListColumnItem; overload;
    procedure Move(CurIndex, NewIndex: Integer);
    procedure Clear; override;

    procedure BeginUpdate; virtual;
    procedure EndUpdate; virtual;
    function GetUpdateStatus: Boolean;

    constructor Create;
    destructor Destroy; override;
  end;

  { TGTFCOutsetTreeBasicItem class }

  TGTFCOutsetTreeBasicItem = class
  private
    FDBRecordID    : Variant;
    FDBTableNameIndex : integer;
    FGridIndex     : Integer;
    FSeparator     : Boolean;
    FParentItem    : Boolean;
    FChildCount    : Integer;
    FColor         : Integer;
    FData          : Pointer;
    FParent        : TGTFCOutsetTreeBasicItem;
    FTag           : Integer;
    FLevel         : Integer;
    FText          : ShortString;
    FDrawRectBody  : TRect;
    function GetDBTableName: ShortString;
    function GetParent: TGTFCOutsetTreeBasicItem;
    procedure SetColor(AValue: integer);
    procedure SetDBTableName(AValue: ShortString);
    procedure SetParent(AValue: TGTFCOutsetTreeBasicItem);
  public
    property GridIndex : integer read FGridIndex write FGridIndex;
    property Text : ShortString read FText write FText;
    property Data : Pointer read FData write FData;
    property DBRecordID : Variant read FDBRecordID write FDBRecordID;
    property DBTableName: ShortString read GetDBTableName write SetDBTableName;
    property Tag : integer read FTag write FTag;
    property Level : integer read FLevel write FLevel;
    property ChildCount : integer read FChildCount write FChildCount;
    property Color : integer read FColor write SetColor;
    property Parent : TGTFCOutsetTreeBasicItem read GetParent write SetParent;
    //Объект-заглушка для выравнивания строк
    property Separator  : Boolean read FSeparator write FSeparator;
    property ParentItem : Boolean read FParentItem;
    procedure SetParentItemTrue;
    procedure SetParentItemFalse;
    procedure SetDrawRectBody(TopLeft, BottomRight: TPoint);
    function GetClickResult(TopLeft, BottomRight: TPoint):TGTFCOutsetTreeClickResult;virtual;
    constructor Create;
    destructor Destroy; override;
  end;

  { TGTFCOutsetTreeRowItem }

  TGTFCOutsetTreeRowItem = class(TGTFCOutsetTreeBasicItem)
  private
    FRowEnabled          : Boolean;
    FRowFiltered         : Boolean;
    FHeight              : integer;
    FEntityHeight        : integer;
    FLayerCount          : integer;
    FBeginY              : integer;
    FEndY                : integer;
    FExtColData          : TStringArray;
    FDrawRectButton      : TRect;
    function GetRowEnabled: Boolean;
    function GetRowFiltered: Boolean;
    function GetRowParentFiltered: Boolean;
    procedure SetRowEnabled(AValue: Boolean);
    procedure SetRowFiltered(AValue: Boolean);
  public
    //Визуальное выделение строки как неактивной
    property RowEnabled  : Boolean read GetRowEnabled write SetRowEnabled;
    property RowFiltered : Boolean read GetRowFiltered write SetRowFiltered;
    property RowParentFiltered : Boolean read GetRowParentFiltered;
    property BeginY : integer read FBeginY write FBeginY;
    property EndY   : integer read FEndY write FEndY;
    property Height : integer read FHeight write FHeight;
    property EntityHeight :integer read FEntityHeight write FEntityHeight;
    property LayerCount :integer read FLayerCount write FLayerCount;
    procedure SetExtendedData(AData:TStringArray);
    function GetExtendedData:TStringArray;
    procedure SetDrawRectButton(TopLeft, BottomRight: TPoint);
    function GetClickResult(TopLeft, BottomRight: TPoint):TGTFCOutsetTreeClickResult;override;
    constructor Create;
    destructor Destroy; override;
  end;

  { TGTFCOutsetTreeColItem }

  TGTFCOutsetTreeColItem = class(TGTFCOutsetTreeBasicItem)
  private
    FBeginX: integer;
    FDrawEnabledValue: Boolean;
    FDrawEnabledCashed: Boolean;
    FEndX: integer;
    FBeginDate: TDateTime;
    FEndDate: TDateTime;
  public
    property BeginDate : TDateTime read FBeginDate write FBeginDate;
    property EndDate : TDateTime read FEndDate write FEndDate;
    property BeginX : integer read FBeginX write FBeginX;
    property EndX : integer read FEndX write FEndX;

    function GetDrawEnabledValue:Boolean;
    function GetDrawEnabledCashe:Boolean;
    procedure SetDrawEnabledValue(AValue:Boolean);
    procedure ClearDrawEnabledCash;

    constructor Create;
  end;

  { TGTFCOutsetBasicTree class }

  TGTFCOutsetBasicTree = class(TObjectList)
  private
    FEndItemCount             : integer;
    FLevelCount               : integer;
    FUpdateCount              : Integer;
    function GetUpdateStatus: Boolean;
    function GetLevelCount(AUpLevel: Integer; AParent: TGTFCOutsetTreeBasicItem
      ): integer;
    function InitSeparatorLevel(AList: TGTFCOutsetBasicTree;
      AMaxLevel: Integer; AParent: TGTFCOutsetTreeBasicItem): boolean;
    procedure UpdateLevelCount;
  protected
    function GetItem(Index: Integer): TGTFCOutsetTreeBasicItem;
    procedure SetItem(Index: Integer; const Value: TGTFCOutsetTreeBasicItem);
  public
    property Items[Index: Integer]: TGTFCOutsetTreeBasicItem read GetItem
                                                         write SetItem; default;
    property LevelCount : integer read FLevelCount;
    property EndItemCount : integer read FEndItemCount;
    procedure Insert(Index: Integer; Item: TGTFCOutsetTreeBasicItem);
    function Add(Item: TGTFCOutsetTreeBasicItem): Integer;
    function IndexOfData(AData: Pointer): Integer;
    procedure Move(CurIndex, NewIndex: Integer);
    procedure Clear; override;

    procedure BeginUpdate; virtual;
    procedure EndUpdate; virtual;

    constructor Create;
    destructor Destroy; override;
  end;

  { TGTFCOutsetRowTree class }

  TGTFCOutsetRowTree = class(TGTFCOutsetBasicTree)
  private
    FAutoSort:Boolean;
  public
    property AutoSort   :Boolean read FAutoSort
                                  write FAutoSort;
    procedure EndUpdate; override;
    constructor Create;
  end;

  { TGTFCOutsetColTree class }

  TGTFCOutsetColTree = class(TGTFCOutsetBasicTree)
  public
  end;

var
  GTFCTableNameCollection : TStringList;

implementation

uses u_gtfc_const;

{ Sort }

procedure SortRecordsByTextField(AList:TList);
var
  tmpItemA,
  tmpItemB  :TGTFCOutsetTreeBasicItem;
  icompare,
  ir,ir2    :integer;
begin
     ir         :=0;
     while ir<AList.Count-1 do
     begin
        tmpItemA :=TGTFCOutsetTreeBasicItem(AList.Items[ir]);
        ir2      :=ir+1;
        tmpItemB :=TGTFCOutsetTreeBasicItem(AList.Items[ir2]);

        icompare :=ShortCompareText(tmpItemB.Text, tmpItemA.Text);

        if icompare>0 then //+1 второй больше первого
        begin
           inc(ir);
        end
        else if icompare<0 then //-1 второй меньше первого
        begin
           //меняем местами и делаем шаг назад
           AList.Move(ir2, ir);
           dec(ir,2);
           if ir<0 then ir:=0;
        end
        else begin //0
           inc(ir);
        end;
     end;
end;

procedure GetTreeRecords(AList:TGTFCOutsetBasicTree;AOutList:TList;AOwner:TGTFCOutsetTreeBasicItem;var ASubItems:Integer);
var
  tmpItemA  :TGTFCOutsetTreeBasicItem;
  i,k       :integer;
  TmpList   :TList;
begin
  TmpList:=TList.Create;
  try

      TmpList.Clear;
      i:=0;
      while i<AList.Count do
      begin
         tmpItemA :=AList.Items[i];
         if tmpItemA.Parent=AOwner then
         begin
            TmpList.Add(tmpItemA);
            AList.Extract(tmpItemA);
            inc(ASubItems);
            i:=0;
         end
         else begin
           inc(i);
         end;
      end;

      //Сортировка TmpList
      SortRecordsByTextField(TmpList);

      for i:=0 to TmpList.Count-1 do
      begin
         k:=0;
         tmpItemA :=TGTFCOutsetTreeBasicItem(TmpList.Items[i]);
         AOutList.Add(tmpItemA);
         GetTreeRecords(AList,AOutList,tmpItemA,k);
         ASubItems:=ASubItems+k;
      end;

  finally
     TmpList.Free;
  end;
end;

procedure TreeRecordSort(AList:TGTFCOutsetBasicTree);
var
  iCount1,iCount2,iCount3,
  i,j      :integer;
  TmpOutList :TList;
begin
     j:=0;
     TmpOutList:=TList.Create;
     try
         iCount1:=AList.Count;

         GetTreeRecords(AList,TmpOutList,nil,j);

         iCount3:=TmpOutList.Count;
         iCount2:=AList.Count;

         if (iCount1<>iCount3)or(iCount2>0) then
         begin
            //Ошибка
         end;

         for i:=0 to TmpOutList.Count-1 do
         begin
             AList.Add(TGTFCOutsetTreeBasicItem(TmpOutList.Items[i]));
         end;

     finally
       TmpOutList.Free;
     end;
end;

{ TGTFCListColumns }

function TGTFCListColumns.GetUpdateStatus: Boolean;
begin
  Result :=(FUpdateCount>0);
end;

function TGTFCListColumns.GetItem(Index: Integer): TGTFCListColumnItem;
begin
  Result := TGTFCListColumnItem(inherited GetItem(Index));
end;

procedure TGTFCListColumns.SetItem(Index: Integer;
  const Value: TGTFCListColumnItem);
begin
  inherited SetItem(Index, Value);
end;

procedure TGTFCListColumns.Insert(Index:Integer; Item:TGTFCListColumnItem);
begin
  inherited Insert(Index, Item);
end;

function TGTFCListColumns.Add(Item: TGTFCListColumnItem): Integer;
begin
  Result := inherited Add(Item);
end;

function TGTFCListColumns.Add: TGTFCListColumnItem;
begin
   Result:=TGTFCListColumnItem.Create;
   Add(Result);
end;

procedure TGTFCListColumns.Move(CurIndex, NewIndex: Integer);
begin
  inherited Move(CurIndex, NewIndex);
end;

procedure TGTFCListColumns.Clear;
begin
  inherited Clear;
  FUpdateCount   := 0;
end;

procedure TGTFCListColumns.BeginUpdate;
begin
  FUpdateCount := FUpdateCount + 1;
end;

procedure TGTFCListColumns.EndUpdate;
begin
  if FUpdateCount > 0 then
  begin
    FUpdateCount := FUpdateCount - 1;
  end;

  if FUpdateCount =0 then
  begin

  end;

  if FUpdateCount<0 then
  begin
    FUpdateCount := 0;
  end;
end;

constructor TGTFCListColumns.Create;
begin
  inherited Create;
  FUpdateCount   := 0;
end;

destructor TGTFCListColumns.Destroy;
begin
  inherited Destroy;
end;

{ TGTFCListColumnItem }

procedure TGTFCListColumnItem.SetColor(AValue: integer);
begin
  if FColor=AValue then Exit;
  FColor:=AValue;
end;

function TGTFCListColumnItem.GetWidth: TWidth;
begin
  Result:=FWidth;
end;

procedure TGTFCListColumnItem.SetAlignment(AValue: TAlignment);
begin
  if FAlignment=AValue then Exit;
  FAlignment:=AValue;
end;

procedure TGTFCListColumnItem.SetAutoSize(AValue: Boolean);
begin
  if FAutoSize=AValue then Exit;
  FAutoSize:=AValue;
end;

procedure TGTFCListColumnItem.SetCaption(AValue: TTranslateString);
begin
  if FCaption=AValue then Exit;
  FCaption:=AValue;
end;

procedure TGTFCListColumnItem.SetImageIndex(AValue: TImageIndex);
begin
  if FImageIndex=AValue then Exit;
  FImageIndex:=AValue;
end;

procedure TGTFCListColumnItem.SetMaxWidth(AValue: TWidth);
begin
  if FMaxWidth=AValue then Exit;
  FMaxWidth:=AValue;
end;

procedure TGTFCListColumnItem.SetMinWidth(AValue: TWidth);
begin
  if FMinWidth=AValue then Exit;
  FMinWidth:=AValue;
end;

procedure TGTFCListColumnItem.SetSortIndicator(AValue: TSortIndicator);
begin
  if FSortIndicator=AValue then Exit;
  FSortIndicator:=AValue;
end;

procedure TGTFCListColumnItem.SetVisible(AValue: Boolean);
begin
  if FVisible=AValue then Exit;
  FVisible:=AValue;
end;

procedure TGTFCListColumnItem.SetWidth(AValue: TWidth);
begin
   if FWidth=AValue then Exit;
  FWidth:=AValue;
end;

constructor TGTFCListColumnItem.Create;
begin
  inherited Create;
  FCaption     :='';
  FAlignment   :=taLeftJustify;
  FAutoSize    :=True;
  FColor       :=0;
  FImageIndex  :=-1;
  FMaxWidth    :=250;
  FMinWidth    :=50;
  FWidth       :=50;
  FSortIndicator :=siNone;
  FTag           :=0;
  FVisible       :=True;
end;

destructor TGTFCListColumnItem.Destroy;
begin
  inherited Destroy;
end;

{ TGTFCOutsetRowTree }

procedure TGTFCOutsetRowTree.EndUpdate;
begin
  if FUpdateCount > 0 then
  begin
    FUpdateCount := FUpdateCount - 1;
  end;

  if FUpdateCount =0 then
  begin
    UpdateLevelCount;
    InitSeparatorLevel(Self, FLevelCount, nil);
    if FAutoSort then
    TreeRecordSort(Self);
    UpdateLevelCount;
  end;

  if FUpdateCount<0 then
  begin
    FUpdateCount := 0;
  end;
end;

constructor TGTFCOutsetRowTree.Create;
begin
  inherited Create;
  FAutoSort:=True;
end;

{ TGTFCOutsetTreeRowItem }

function TGTFCOutsetTreeRowItem.GetRowEnabled: Boolean;
begin
  if Assigned(Parent) then
  begin
      Result:=TGTFCOutsetTreeRowItem(Parent).RowEnabled;
      if Result then
         Result:=FRowEnabled;
  end
  else begin
    Result:=FRowEnabled;
  end;
end;

function TGTFCOutsetTreeRowItem.GetRowFiltered: Boolean;
begin
  if Assigned(Parent) then
  begin
      Result:=TGTFCOutsetTreeRowItem(Parent).RowFiltered;
      if not Result then
      begin
         Result:=FRowFiltered;
      end;
  end
  else begin
    Result:=FRowFiltered;
  end;
end;

function TGTFCOutsetTreeRowItem.GetRowParentFiltered: Boolean;
begin
  if Assigned(Parent) then
  begin
    Result:=TGTFCOutsetTreeRowItem(Parent).RowFiltered;
  end
  else begin
    Result:=False;
  end;
end;

procedure TGTFCOutsetTreeRowItem.SetRowEnabled(AValue: Boolean);
begin
  if FRowEnabled=AValue then exit;
  FRowEnabled:=AValue;
end;

procedure TGTFCOutsetTreeRowItem.SetRowFiltered(AValue: Boolean);
begin
   if FRowFiltered=AValue then exit;
   FRowFiltered:=AValue;
end;

procedure TGTFCOutsetTreeRowItem.SetExtendedData(AData: TStringArray);
begin
  FExtColData:=AData;
end;

function TGTFCOutsetTreeRowItem.GetExtendedData: TStringArray;
begin
  Result:=FExtColData;
end;

procedure TGTFCOutsetTreeRowItem.SetDrawRectButton(TopLeft, BottomRight: TPoint
  );
begin
  FDrawRectButton:=Rect(TopLeft.X,TopLeft.Y,BottomRight.X,BottomRight.Y);
end;

function TGTFCOutsetTreeRowItem.GetClickResult(TopLeft, BottomRight: TPoint
  ): TGTFCOutsetTreeClickResult;
var
  r:TRect;
begin
  r:=FDrawRectButton;
  Result:=inherited GetClickResult(TopLeft, BottomRight);
    if PointInRect2D(TopLeft.X,TopLeft.Y,r.Left,r.Top,r.Right,r.Bottom) then
    begin
       Result:=tcrButton;
    end
    else if PointInRect2D(BottomRight.X,BottomRight.Y,r.Left,r.Top,r.Right,r.Bottom) then
    begin
       Result:=tcrButton;
    end;
end;

constructor TGTFCOutsetTreeRowItem.Create;
begin
  FBeginY       :=0;
  FEndY         :=0;
  FHeight       :=0;
  FEntityHeight :=0;
  FLayerCount   :=1;
  SetLength(FExtColData,0);
  FRowEnabled   :=True;
  FRowFiltered  :=False;

  FDrawRectButton:=Rect(0,0,0,0);
end;

destructor TGTFCOutsetTreeRowItem.Destroy;
begin
  SetLength(FExtColData,0);
  inherited Destroy;
end;

{ TGTFCOutsetTreeColItem }

function TGTFCOutsetTreeColItem.GetDrawEnabledValue: Boolean;
begin
  Result:=FDrawEnabledValue;
end;

function TGTFCOutsetTreeColItem.GetDrawEnabledCashe: Boolean;
begin
   Result:=FDrawEnabledCashed;
end;

procedure TGTFCOutsetTreeColItem.SetDrawEnabledValue(AValue: Boolean);
begin
  FDrawEnabledValue  :=AValue;
  FDrawEnabledCashed :=True;
end;

procedure TGTFCOutsetTreeColItem.ClearDrawEnabledCash;
begin
  FDrawEnabledValue  :=False;
  FDrawEnabledCashed :=False;
end;

constructor TGTFCOutsetTreeColItem.Create;
begin
  inherited Create;
  FBeginX    :=-1;
  FEndX      :=-1;
  FBeginDate :=0;
  FEndDate   :=0;

  FDrawEnabledValue  :=False;
  FDrawEnabledCashed :=False;
end;

{ TGTFCOutsetBasicTree }

function TGTFCOutsetBasicTree.GetUpdateStatus: Boolean;
begin
  Result :=(FUpdateCount>0);
end;

function TGTFCOutsetBasicTree.GetLevelCount(AUpLevel:Integer;
  AParent:TGTFCOutsetTreeBasicItem):integer;
var
  i,l:integer;
begin
  Result:=AUpLevel;
  if Assigned(AParent) then
     AParent.SetParentItemFalse;

  for i:=0 to count-1 do
  begin
    if Items[i].Parent=AParent then
    begin
       if Assigned(AParent) then
          AParent.SetParentItemTrue;

       Items[i].Level:=AUpLevel;
       l:=GetLevelCount(Items[i].Level+1, Items[i]);
       if Result<l then
       begin
          Result:=l;
       end;
    end;
  end;
end;

procedure TGTFCOutsetBasicTree.UpdateLevelCount;
var
  i:integer;
begin
  FLevelCount:=GetLevelCount(0, nil);
  FEndItemCount:=0;
  for i:=0 to count-1 do
  begin
    if Items[i].Level=FLevelCount-1 then
    begin
       Items[i].GridIndex:=FEndItemCount;
       inc(FEndItemCount);
       //для визуального тестирования порядка строк
       //Items[i].Text:=inttostr(Items[i].GridIndex);
    end
    else begin
       Items[i].GridIndex:=-1;
    end;
  end;
end;

function TGTFCOutsetBasicTree.GetItem(Index: Integer): TGTFCOutsetTreeBasicItem;
begin
  Result := TGTFCOutsetTreeBasicItem(inherited GetItem(Index));
end;

procedure TGTFCOutsetBasicTree.SetItem(Index: Integer;
  const Value: TGTFCOutsetTreeBasicItem);
begin
  inherited SetItem(Index, Value);
end;

procedure TGTFCOutsetBasicTree.Insert(Index:Integer; Item:TGTFCOutsetTreeBasicItem);
begin
  inherited Insert(Index, Item);
end;

function TGTFCOutsetBasicTree.Add(Item: TGTFCOutsetTreeBasicItem): Integer;
begin
  Result := inherited Add(Item);
end;

function TGTFCOutsetBasicTree.IndexOfData(AData: Pointer): Integer;
var
  i:integer;
  Item: TGTFCOutsetTreeBasicItem;
begin
  Result:=-1;
  for i:=0 to Count-1 do
  begin
     Item:=TGTFCOutsetTreeBasicItem(Items[i]);
     if Item.Data=AData then
     begin
        Result:=i;
        break;
     end;
  end;
end;

procedure TGTFCOutsetBasicTree.Move(CurIndex, NewIndex: Integer);
begin
  inherited Move(CurIndex, NewIndex);
end;

procedure TGTFCOutsetBasicTree.Clear;
begin
  inherited Clear;
  FUpdateCount   := 0;
  FEndItemCount  := 0;
  FLevelCount    := 0;
end;

procedure TGTFCOutsetBasicTree.BeginUpdate;
begin
  FUpdateCount := FUpdateCount + 1;
end;

procedure TGTFCOutsetBasicTree.EndUpdate;
begin
  if FUpdateCount > 0 then
  begin
    FUpdateCount := FUpdateCount - 1;
  end;

  if FUpdateCount =0 then
  begin
    UpdateLevelCount;
    InitSeparatorLevel(Self, FLevelCount, nil);
    UpdateLevelCount;
  end;

  if FUpdateCount<0 then
  begin
    FUpdateCount := 0;
  end;
end;

//Выравнивание кол-ва элементов в строках
function TGTFCOutsetBasicTree.InitSeparatorLevel(AList:TGTFCOutsetBasicTree; AMaxLevel:Integer; AParent:TGTFCOutsetTreeBasicItem):boolean;
var
  iCount,
  i:integer;
  LastItem,
  NewItem :TGTFCOutsetTreeBasicItem;
begin
  Result:=False;
  iCount:=0;
  for i:=AList.count-1 downto 0  do
  begin
    if AList.Items[i].Parent=AParent then
    begin
       Result:=InitSeparatorLevel(AList, AMaxLevel, AList.Items[i]);
       inc(iCount);
    end;
  end;
  if Assigned(AParent)and(iCount=0)and(AParent.Level<AMaxLevel-1) then
  begin
     //Последний элемент
     LastItem:=AParent.Parent;
     for i:=AParent.Level to AMaxLevel-2 do
     begin
            NewItem        :=TGTFCOutsetTreeRowItem.Create;
            NewItem.Parent :=LastItem;
            NewItem.Level  :=0;//i;
            NewItem.Data   :=nil;
            NewItem.Text   :='-';
            NewItem.Separator  :=True;
            AList.Add(NewItem);
            LastItem       :=NewItem;
            Result         :=True;
     end;
     AParent.Parent :=LastItem;
     AParent.Level  :=0;
  end;
end;

constructor TGTFCOutsetBasicTree.Create;
begin
  inherited Create;
  FUpdateCount   := 0;
  FEndItemCount  := 0;
  FLevelCount    := 0;
end;

destructor TGTFCOutsetBasicTree.Destroy;
begin
  inherited Destroy;
end;

{ TGTFCOutsetTreeBasicItem }

procedure TGTFCOutsetTreeBasicItem.SetColor(AValue: integer);
begin
  if FColor=AValue then Exit;

  FColor:=AValue;
end;

function TGTFCOutsetTreeBasicItem.GetParent: TGTFCOutsetTreeBasicItem;
begin
  Result:=FParent;
end;

procedure TGTFCOutsetTreeBasicItem.SetDBTableName(AValue: ShortString);
var
  i:integer;
begin
  i:=GTFCTableNameCollection.IndexOf(AValue);
  if i=-1 then
     i:=GTFCTableNameCollection.Add(AValue);
  if FDBTableNameIndex=i then exit;
     FDBTableNameIndex:=i;
end;

function TGTFCOutsetTreeBasicItem.GetDBTableName: ShortString;
begin
  Result:='';
  if (FDBTableNameIndex>-1)and(FDBTableNameIndex<GTFCTableNameCollection.Count) then
     Result:=GTFCTableNameCollection.Strings[FDBTableNameIndex];
end;

procedure TGTFCOutsetTreeBasicItem.SetParent(AValue: TGTFCOutsetTreeBasicItem);
begin
 if FParent=AValue then exit;
 if Assigned(FParent) then
 begin
    FParent.FChildCount:=FParent.FChildCount-1;
    FParent:=AValue;
    FParent.FChildCount:=FParent.FChildCount+1;
 end
 else begin
    FParent:=AValue;
    FParent.FChildCount:=FParent.FChildCount+1;
 end;
end;

procedure TGTFCOutsetTreeBasicItem.SetParentItemTrue;
begin
  FParentItem:=True;
end;

procedure TGTFCOutsetTreeBasicItem.SetParentItemFalse;
begin
  FParentItem:=False;
end;

procedure TGTFCOutsetTreeBasicItem.SetDrawRectBody(TopLeft, BottomRight: TPoint
  );
begin
  FDrawRectBody:=Rect(TopLeft.X,TopLeft.Y,BottomRight.X,BottomRight.Y);
end;

function TGTFCOutsetTreeBasicItem.GetClickResult(TopLeft, BottomRight: TPoint
  ): TGTFCOutsetTreeClickResult;
var
  r:TRect;
begin
  r:=FDrawRectBody;
  Result:=tcrNone;
  if PointInRect2D(TopLeft.X,TopLeft.Y,r.Left,r.Top,r.Right,r.Bottom) then
  begin
     Result:=tcrBody;
  end;
end;

constructor TGTFCOutsetTreeBasicItem.Create;
begin
  inherited Create;
  FColor:=0;
  FData:=nil;
  FDBRecordID:=0;
  FDBTableNameIndex:=-1;
  FParent:=nil;
  FChildCount:=0;
  FTag:=0;
  FLevel:=0;
  FText:='';
  FSeparator :=False;
  FParentItem:=False;
  FGridIndex :=0;

  FDrawRectBody:=Rect(0,0,0,0);
end;

destructor TGTFCOutsetTreeBasicItem.Destroy;
begin
  inherited Destroy;
end;

Initialization
  GTFCTableNameCollection :=TStringList.Create;
  GTFCTableNameCollection.CaseSensitive:=False;

finalization
  GTFCTableNameCollection.Free;

end.
