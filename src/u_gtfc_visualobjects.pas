unit u_gtfc_visualobjects;

//************************************************************
//
//    Модуль компонента Graphic Task Flow Control
//    Copyright (c) 2013  Pichugin M.
//    rev. 0.37
//    Разработчик: Pichugin M. (e-mail: pichugin-swd@mail.ru)
//
//************************************************************

interface

uses
{$IFNDEF FPC}
  Windows,
{$ELSE}
  LCLIntf, LCLType,
{$ENDIF}
  Classes, SysUtils, ComCtrls, Controls, Graphics, DateUtils,
  u_gtfc_objecttree,
  u_gtfc_logicaldraw, u_gtfc_const, u_gtfc_geometry;

type

  { Forward Declarartions }

  TGTFDrawDocumentCustom = class;

  TEntity      = class;
  TWorkSpace   = class;

  { Data types }

  TEntityID = ShortString;

  TBGTaskStyle = (bgtsStandard,bgtsCross,bgtsDiagonal);

  TEntityState = set of (esNone,esCreating,esEditing,esMoving,esSelected);
  TEntityDrawStyle = set of (edsNone,edsNormal,edsSelected,edsEditing,edsMoving,edsCreating);
  TEntityType = (etNone,etAll,etBasicObject,etTask,etFrameLine,etConnectionLine,etLandmark);
  TEntityTypes = set of TEntityType;

  TGetDocumentEvent = function :TGTFDrawDocumentCustom of object;

  { Record Declarartions }

  // Логические координаты
  PGTFPoint = ^TGTFPoint;
  TGTFPoint = record
    X, Y, Z :Integer;
  end;

  PTFloatRect = ^TFloatRect;
  TFloatRect = record
    TopX, TopY, TopZ           :Integer;
    BottomX, BottomY, BottomZ  :Integer;
  end;

  TModifyVertex = record
    Item        : TEntity;
    VertexIndex : Integer;
    VertexPos   : TGTFPoint;
  end;

  // Массив точек
  TPointsArray                = array of TGTFPoint;
  TModifyVertexArray          = array of TModifyVertex;

  { TGTFPointList }

  TGTFPointList = class
  private
         FList   : TList;
         function GetCount: Integer;
         function GetPoint(Index: Integer): TGTFPoint;
         procedure SetPoint(Index: Integer; const Value: TGTFPoint);
         function  NewPoint(X, Y, Z: Integer): PGTFPoint;
  public
         constructor Create; virtual;
         destructor Destroy; override;
         procedure Add(X, Y, Z: Integer);
         procedure Insert(Index: Integer; X, Y, Z: Integer);
         procedure Delete(Index: Integer);
         function  Extract(Index: Integer): PGTFPoint;
         property  Count: Integer read GetCount;
         property  Items[Index: Integer]: TGTFPoint read GetPoint write SetPoint;
  end;

  { TGTFDrawDocumentCustom }

  TGTFDrawDocumentCustom = class
  private
    FModelSpace     :TWorkSpace;
    FRows           :TGTFCOutsetRowTree;
    FCols           :TGTFCOutsetColTree;

    function GetRowsAutoSort: Boolean;
    procedure SetRowsAutoSort(AValue: Boolean);
  protected
    FGridLineWidth  :Integer;
    FNodePaddingTopBottom :Integer;
    FNodePaddingLeftRight :Integer;
    FFontSize             : Integer;
    FFontName             : AnsiString;
    FExtColumns           : TGTFCListColumns;
  public
    property  ModelSpace  :TWorkSpace read FModelSpace
                                      write FModelSpace;
    property  Rows        :TGTFCOutsetRowTree read FRows
                                      write FRows;
    property  Cols        :TGTFCOutsetColTree read FCols
                                      write FCols;

    property  ExtColumns  :TGTFCListColumns read FExtColumns
                                      write FExtColumns;

    property  RowsAutoSort  :Boolean read GetRowsAutoSort
                                      write SetRowsAutoSort;

    //Установить заголовок первого столбца строк
    procedure SetFirstColumn(AData: String);
    //Установить заголовко дополнительных столбцов строк
    procedure SetExtendedColumns(AData:TStringArray);

    //Получить допуск по координатам
    function GetDeltaVertex:Integer; virtual; abstract;
    function GetRowUnderCursor:Integer; virtual; abstract;
    function GetColUnderCursor:Integer; virtual; abstract;
    procedure DeselectAll; virtual; abstract;
  end;

   { TEntityList }

   // Эллементы чертежа
   TEntityList      = class
   private
        FList               : TList;
        FID                 : TEntityID;
        FModelSpace         : TWorkSpace;
        procedure SetEntityLinkVar(AEntity:TEntity);
        procedure ChangeCordVertex(const AVertCord:TGTFPoint);
        function GetCount: Integer;
        function GetItem(Index: Integer): TEntity;
        procedure SetItem(Index: Integer; const Value: TEntity);
   protected

   public
       constructor Create; virtual;
       destructor Destroy; override;
       // Cобытия
       procedure Add(AEntity: TEntity); overload;
       function  Add(AParentID:TEntityID): TEntity; overload;
       procedure Insert(Index: Integer; AEntity: TEntity);
       procedure Delete(Index: Integer);
       procedure Repaint(Xshift,Yshift,AScaleX,AScaleY,AScaleZ:Integer; LogicalDrawing: TLogicalDraw; AStyle:TEntityDrawStyle);
       procedure RepaintVertex(LogicalDrawing: TLogicalDraw);
       function  GetEntityByID(AID:TEntityID): TEntity;
       property  ID: TEntityID read FID write FID;

       property  Count: Integer read GetCount;
       property  Items[Index: Integer]: TEntity read GetItem write SetItem;

       procedure Clear;
   end;

   { TWorkSpaceCustom }

      TWorkSpaceCustom      = class
      private
           FTopLeft            : TGTFPoint;
           FBottomRight        : TGTFPoint;
           FSelectedEntityList : TList;
           FEntityList         : TEntityList;
           FEntityListFilteredDraw: TList;
           FOnGetDocumentEvent : TGetDocumentEvent;
           function GetDocument: TGTFDrawDocumentCustom;
      protected

      public
          constructor Create; virtual; overload;
          destructor Destroy; override;
          // Cобытия

          procedure Repaint(Xshift,Yshift,AScaleX,AScaleY,AScaleZ:Integer;
                     LogicalDrawing: TLogicalDraw; AStyle:TEntityDrawStyle);
          procedure RepaintVertex(LogicalDrawing: TLogicalDraw);
          procedure DeselectAll;
          function  GetColor(AColor:TgaColor):TgaColor;
          function  GetLineWeight(LineWeight:TgaLineWeight):TgaLineWeight;
          procedure GetRectVertex(var ATopLeft, ABottomRight: TGTFPoint);
          //Действия
          //Перемещение группы объектов
          procedure MoveEntityGroup(AOwnerGroup: TEntityID; APoint: TGTFPoint);

          property  ThisDocument : TGTFDrawDocumentCustom read GetDocument;
          property  OnGetDocument: TGetDocumentEvent read FOnGetDocumentEvent
                                                     write FOnGetDocumentEvent;
          property  SelectedEntityList: TList read FSelectedEntityList
                                              write FSelectedEntityList;
          property  Objects: TEntityList read FEntityList write FEntityList;
          property  ObjectsFiltered: TList read FEntityListFilteredDraw write FEntityListFilteredDraw;
      end;

  { TWorkSpace }

   TWorkSpace      = class(TWorkSpaceCustom);

   { TEntityBasic }

   TEntityBasic = class // Базовый класс
   private
       FBlocked     : Boolean;
       FParentList  : TEntityList;   // Основной список эллементов чертежа
       FBlockList   : TEntityList;   // Список составных частей блока
       FOnGetDocumentEvent : TGetDocumentEvent;

   protected
       FID           : TEntityID;    // Уникальный идентификатор эллемента чертежа
       FState        : TEntityState;
       FVertex       : TGTFPointList;
       FLineWeight   : TgaLineWeight;     // Толщина линий
       FColor        : TgaColor;          // Цвет объекта
       FLayerName    : ShortString;       // Слой объекта
       FData         : Pointer;
       FDBRecordID     : Variant;
       FDBRecordGroup  : Variant;
       FTag            : integer;
       FGroupOwner     : TEntityID;

       function  GetVertexCount: Integer; virtual; abstract;
       function  GetVertex(Index: Integer): TGTFPoint; virtual; abstract;
       procedure SetVertex(Index: Integer; const Value: TGTFPoint); virtual; abstract;
   public
       constructor Create; virtual;
       destructor Destroy; override;
       procedure Created;
       procedure Repaint(Xshift,Yshift,AScaleX,AScaleY,AScaleZ:Integer; LogicalDrawing: TLogicalDraw; AStyle:TEntityDrawStyle); overload; virtual; abstract;
       procedure Repaint(LogicalDrawing: TLogicalDraw; AStyle:TEntityDrawStyle);  overload;virtual; abstract;
       procedure RepaintVertex(LogicalDrawing: TLogicalDraw); virtual; abstract;
       function GetSelect(TopLeft, BottomRight: TGTFPoint; AllVertexInRect: Boolean):Integer; overload;virtual; abstract;
       function GetSelect(TopLeft, BottomRight: TGTFPoint; AllVertexInRect: Boolean; var MVertx:TModifyVertex):Integer; overload;virtual; abstract;
       function GetColor(AColor:TgaColor):TgaColor; overload;
       function GetLineWeight(ALineWeight:TgaLineWeight):TgaLineWeight; overload;
       function GetColor:TgaColor; overload;
       function GetLineWeight:TgaLineWeight; overload;
       // Методы блокировки/разблокировки
       procedure BeginUpdate;
       procedure EndUpdate;
       // Свойства/события
       procedure AddVertex(X, Y, Z: Integer); virtual; abstract;
       procedure InsertVertex(Index: Integer; X, Y, Z: Integer);  virtual; abstract;
       procedure DeleteVertex(Index: Integer); virtual; abstract;

       property  VertexCount: Integer read GetVertexCount;
       property  Vertex[Index: Integer]: TGTFPoint read GetVertex write SetVertex;
       property  State: TEntityState read FState write FState;
       property  ID: TEntityID read FID write FID;

       property  OnGetDocument: TGetDocumentEvent read FOnGetDocumentEvent
                                                  write FOnGetDocumentEvent;
   end;

   TEntity      = class(TEntityBasic)  // Общий предок класс
   private
       function GetDocument: TGTFDrawDocumentCustom;
       procedure SetColor(AValue: TgaColor);
   protected
       FActionVertexIndex: integer;
       FActionVertexDelta: TGTFPoint;
       function GetVertexCount: Integer; override;
       function GetVertex(Index: Integer): TGTFPoint; override;
       procedure SetVertex(Index: Integer; const Value: TGTFPoint); override;

       function GetVertexAxleX(Index: Integer): Integer;
       function GetVertexAxleY(Index: Integer): Integer;
       function GetVertexAxleZ(Index: Integer): Integer;
       procedure SetVertexAxleX(Index: Integer; const Value: Integer);virtual;
       procedure SetVertexAxleY(Index: Integer; const Value: Integer);virtual;
       procedure SetVertexAxleZ(Index: Integer; const Value: Integer);virtual;

       function GetInteractiveVertex(AVertex:TGTFPoint):TGTFPoint;

       property  VertexCount: Integer read GetVertexCount;
       property  Vertex[Index: Integer]: TGTFPoint read GetVertex write SetVertex;
       property  VertexAxleX[Index: Integer]: Integer read GetVertexAxleX write SetVertexAxleX;
       property  VertexAxleY[Index: Integer]: Integer read GetVertexAxleY write SetVertexAxleY;
       property  VertexAxleZ[Index: Integer]: Integer read GetVertexAxleZ write SetVertexAxleZ;
   published
       property  LineWeight: TgaLineWeight read FLineWeight write FLineWeight;
       property  Color: TgaColor read FColor write SetColor;
       property  LayerName :ShortString read FLayerName write FLayerName;
       property  Tag  : integer read FTag write FTag;
   public
       constructor Create; override;
       destructor Destroy; override;

       procedure AddVertex(X, Y, Z: Integer); override;
       procedure InsertVertex(Index: Integer; X, Y, Z: Integer); override;
       procedure DeleteVertex(Index: Integer); override;

       function GetSelect(TopLeft, BottomRight: TGTFPoint; AllVertexInRect: Boolean):Integer;overload;virtual;
       function GetSelect(TopLeft, BottomRight: TGTFPoint; AllVertexInRect: Boolean; var MVertx:TModifyVertex):Integer; overload;virtual;
       procedure Repaint(LogicalDrawing: TLogicalDraw; Style:TEntityDrawStyle); override;

       procedure GetRectVertex(var ATopLeft,ABottomRight:TGTFPoint);virtual;

       // Свойства/события
       property  ThisDocument : TGTFDrawDocumentCustom read GetDocument;
       property  Data         : Pointer read FData write FData;
       property DBRecordID    : Variant read FDBRecordID write FDBRecordID;
       property DBRecordGroup : Variant read FDBRecordGroup write FDBRecordGroup;
       property  GroupOwner   : TEntityID read FGroupOwner write FGroupOwner;

       //Временное свойство. Устанавливается во время перемещения мышкой
       property ActionVertexDelta :TGTFPoint read FActionVertexDelta write FActionVertexDelta;
       //Временное свойство. Устанавливается во время перемещения мышкой
       property ActionVertexIndex :integer read FActionVertexIndex write FActionVertexIndex;

       procedure MoveVertex(Index:integer; NewVertex:TGTFPoint);virtual;

       property  ParentList: TEntityList read FParentList write FParentList;
       property  BlockList: TEntityList read FBlockList write FBlockList;
   end;

   TEntityLineBasic      = class(TEntity)
   protected
   public
       property  Vertex[Index: Integer]: TGTFPoint read GetVertex write SetVertex;
       procedure RepaintVertex(LogicalDrawing: TLogicalDraw); override;
       function GetSelect(TopLeft, BottomRight: TGTFPoint; AllVertexInRect: Boolean):Integer; overload; override;
       function GetSelect(TopLeft, BottomRight: TGTFPoint; AllVertexInRect: Boolean; var MVertx:TModifyVertex):Integer; overload; override;
   end;

   { TEntityEllipseBasic }

   TEntityEllipseBasic      = class(TEntity)
   private
        FAxleY: Integer;
        FAxleX: Integer;
        function GetRadius: Integer; virtual; abstract;
        procedure SetRadius(const Value: Integer); virtual;  abstract;
        function GetDiameter: Integer; virtual; abstract;
        procedure SetDiameter(const Value: Integer); virtual; abstract;
        function GetBasePoint: TGTFPoint; virtual;
        procedure SetBasePoint(const Value: TGTFPoint); virtual;
   protected
        function GetAxleX: Integer; virtual; abstract;
        function GetAxleY: Integer; virtual; abstract;
        procedure SetAxleX(const Value: Integer); virtual; abstract;
        procedure SetAxleY(const Value: Integer); virtual; abstract;
   public
        property  AxleY: Integer read GetAxleY write SetAxleY;
        property  AxleX: Integer read GetAxleX write SetAxleX;
        property  Radius: Integer read GetRadius write SetRadius;
        property  Diameter: Integer read GetDiameter write SetDiameter;
        property  BasePoint: TGTFPoint read GetBasePoint write SetBasePoint;
        procedure GetRectVertex(var ATopLeft,ABottomRight:TGTFPoint);override;
        function GetSelect(TopLeft, BottomRight: TGTFPoint; AllVertexInRect: Boolean):Integer;override;
        function GetSelect(TopLeft, BottomRight: TGTFPoint; AllVertexInRect: Boolean; var MVertx:TModifyVertex):Integer; overload; override;
        procedure MoveVertex(Index:integer; NewVertex:TGTFPoint);override;
   end;

  { TEntityTextBasic }

  TEntityTextBasic      = class(TEntity)
  private
      FRotate       : integer;
      function GetBasePoint: TGTFPoint; virtual;
      procedure SetBasePoint(const Value: TGTFPoint); virtual;
   public
      constructor Create; override;
      property  BasePoint: TGTFPoint read GetBasePoint write SetBasePoint;
      procedure Repaint(Xshift,Yshift,AScaleX,AScaleY,AScaleZ:Integer; LogicalDrawing: TLogicalDraw; AStyle:TEntityDrawStyle); override;
      procedure RepaintVertex(LogicalDrawing: TLogicalDraw); override;
      function GetSelect(TopLeft, BottomRight: TGTFPoint; AllVertexInRect: Boolean):Integer;  overload;override;
      function GetSelect(TopLeft, BottomRight: TGTFPoint; AllVertexInRect: Boolean; var MVertx:TModifyVertex):Integer; overload;override;

  end;

   { TGraphicPolyline }

   TGraphicPolyline            = class(TEntityLineBasic)
   protected
      FClosed:Boolean;
   private
      function GetClosed: Boolean;virtual;
      procedure SetClosed(AValue: Boolean); virtual;
   public
      property  Closed: Boolean read GetClosed write SetClosed;
      procedure Draw(APoints:TPointsArray;AClosed: Boolean);overload;
      procedure Repaint(Xshift,Yshift,AScaleX,AScaleY,AScaleZ:Integer; LogicalDrawing: TLogicalDraw; AStyle:TEntityDrawStyle); override;
      procedure RepaintVertex(LogicalDrawing: TLogicalDraw); override;
   end;

   TGraphicConnectionline     = class(TEntityLineBasic)
   private
     FBeginEntityID      : TEntityID;
     FBeginEntityIndex   : Integer;
     FEndEntityID        : TEntityID;
     FEndEntityIndex     : Integer;
     function GetBeginVertex: TGTFPoint;
     function GetEndVertex: TGTFPoint;
   public
      property  BeginEntityID    : TEntityID read FBeginEntityID write FBeginEntityID;
      property  BeginEntityIndex : Integer read FBeginEntityIndex  write FBeginEntityIndex;
      property  BeginVertex      : TGTFPoint read GetBeginVertex;

      property  EndEntityID      : TEntityID read FEndEntityID write FEndEntityID;
      property  EndEntityIndex   : Integer read FEndEntityIndex  write FEndEntityIndex;
      property  EndVertex        : TGTFPoint read GetEndVertex;

      procedure Draw(APoints:TPointsArray;AClosed: Boolean);overload;
      procedure Repaint(Xshift,Yshift,AScaleX,AScaleY,AScaleZ:Integer; LogicalDrawing: TLogicalDraw; AStyle:TEntityDrawStyle); override;
      procedure RepaintVertex(LogicalDrawing: TLogicalDraw); override;

      function GetSelect(TopLeft, BottomRight: TGTFPoint; AllVertexInRect: Boolean; var MVertx:TModifyVertex):Integer; overload;override;

      procedure GetLinePointsVertex(var APoints:TPointsArray);

      constructor Create; override;
   end;

   { TBasicGridEntity }

   TBasicGridEntity   = class(TEntity)
   private
       FSortRangIndex                 : byte;   //only for subclass sorting
       FAntiLayeringIndex             : integer;
       FGridRow                       : TGTFCOutsetTreeRowItem;
       FText                          : ShortString;
       FTextSecondLine                : ShortString;
       FHint                          : String;
       FTimeBegin                     : TDateTime;
       FTimeEnd                       : TDateTime;
       function GetTimeBegin: TDateTime; virtual;
       function GetTimeEnd: TDateTime; virtual;
       procedure SetTimeBegin(AValue: TDateTime); virtual;
       procedure SetTimeEnd(AValue: TDateTime); virtual;
   public
        property  TimeBegin : TDateTime read GetTimeBegin write SetTimeBegin;
        property  TimeEnd   : TDateTime read GetTimeEnd write SetTimeEnd;
        property  Text      : ShortString read FText write FText;
        property  TextSecondLine : ShortString read FTextSecondLine write FTextSecondLine;
        property  Hint      : String read FHint write FHint;
        property  GridRow    :TGTFCOutsetTreeRowItem read FGridRow write FGridRow;
        property  AntiLayeringIndex :integer read FAntiLayeringIndex write FAntiLayeringIndex;
        property  SortRangIndex :byte read FSortRangIndex;

        function GetBeginPoint:TGTFPoint;
        function GetEndPoint:TGTFPoint;
        function GetRowPoint:TGTFCOutsetTreeRowItem;

        constructor Create; override;
   end;

   { TGraphicTask }

   TGraphicTask   = class(TBasicGridEntity)
   private
       FBGTaskStyle        : TBGTaskStyle;
       FMarkerBegin        : Boolean;
       FMarkerBeginColor   : TgaColor;
       FMarkerEnd          : Boolean;
       FMarkerEndColor     : TgaColor;
   public
        property  BGTaskStyle :TBGTaskStyle read FBGTaskStyle write FBGTaskStyle;

        property  MarkerBegin      : Boolean read FMarkerBegin write FMarkerBegin;
        property  MarkerEnd        : Boolean read FMarkerEnd write FMarkerEnd;
        property  MarkerBeginColor : TgaColor read FMarkerBeginColor write FMarkerBeginColor;
        property  MarkerEndColor   : TgaColor read FMarkerEndColor write FMarkerEndColor;

        procedure Repaint(Xshift,Yshift,AScaleX,AScaleY,AScaleZ:Integer; LogicalDrawing: TLogicalDraw; AStyle:TEntityDrawStyle); override;
        procedure RepaintVertex(LogicalDrawing: TLogicalDraw); override;
        function GetSelect(TopLeft, BottomRight: TGTFPoint; AllVertexInRect: Boolean):Integer; overload; override;
        function GetSelect(TopLeft, BottomRight: TGTFPoint; AllVertexInRect: Boolean; var MVertx:TModifyVertex):Integer; overload; override;
        constructor Create; override;
   end;

   { TGraphicFrameLine }

   TGraphicFrameLine   = class(TBasicGridEntity)
   private
     FTriangleBegin    : Boolean;
     FTriangleEnd      : Boolean;
   public
        property  TriangleBegin : Boolean read FTriangleBegin write FTriangleBegin;
        property  TriangleEnd   : Boolean read FTriangleEnd write FTriangleEnd;

        procedure Repaint(Xshift,Yshift,AScaleX,AScaleY,AScaleZ:Integer; LogicalDrawing: TLogicalDraw; AStyle:TEntityDrawStyle); override;
        procedure RepaintVertex(LogicalDrawing: TLogicalDraw); override;
        function GetSelect(TopLeft, BottomRight: TGTFPoint; AllVertexInRect: Boolean):Integer; overload; override;
        function GetSelect(TopLeft, BottomRight: TGTFPoint; AllVertexInRect: Boolean; var MVertx:TModifyVertex):Integer; overload; override;
        constructor Create; override;
   end;

   { TGraphicLandmark }

   TGraphicLandmark   = class(TBasicGridEntity)
   private
       procedure SetTimeBegin(AValue: TDateTime); override;
       procedure SetTimeEnd(AValue: TDateTime); override;
   public
        procedure Repaint(Xshift,Yshift,AScaleX,AScaleY,AScaleZ:Integer; LogicalDrawing: TLogicalDraw; AStyle:TEntityDrawStyle); override;
        procedure RepaintVertex(LogicalDrawing: TLogicalDraw); override;
        function GetSelect(TopLeft, BottomRight: TGTFPoint; AllVertexInRect: Boolean):Integer; overload; override;
        function GetSelect(TopLeft, BottomRight: TGTFPoint; AllVertexInRect: Boolean; var MVertx:TModifyVertex):Integer; overload; override;
        constructor Create; override;
   end;

   { TGraphicText }

   // Текс
   TGraphicText                = class(TEntityTextBasic)
   private
      FStyleName: AnsiString;
      FWidth: Integer;
      FHeight: Integer;
      FAlign: TgaAttachmentPoint;
      FText: String;

      FFontSize: Integer;
      FFontStyle: TFontStyles;
      FFontName: AnsiString;
      function GetHeight: Integer;
      function GetWidth: Integer;
      procedure SetHeight(const Value: Integer);
      procedure SetWidth(const Value: Integer);
   public
       constructor Create; override;
       destructor Destroy; override;
       //Лучше не задавать, чтобы было 0. Иначе отражается на выравнивании и обрезается зона надписи
       property  Width: Integer read GetWidth write SetWidth;
       property  Height: Integer read GetHeight write SetHeight;
       property  Rotate: integer read FRotate write FRotate;

       property  Text: String read FText write FText;
       property  Align: TgaAttachmentPoint read FAlign write FAlign;

       property  FontSize: Integer read FFontSize write FFontSize;
       property  FontStyle: TFontStyles read FFontStyle write FFontStyle;
       property  FontName: AnsiString read FFontName write FFontName;
       property  StyleName: AnsiString read FStyleName write FStyleName;

       procedure Draw(ABasePoint:TGTFPoint; AText: String; AAlign: TgaAttachmentPoint; ARotate:integer);overload;
       procedure Draw(ABasePoint:TGTFPoint; AText: String; AAlign: TgaAttachmentPoint; AWidth,AHeight,ARotate:integer);overload;

       procedure Repaint(Xshift,Yshift,AScaleX,AScaleY,AScaleZ:Integer; LogicalDrawing: TLogicalDraw; AStyle:TEntityDrawStyle); override;
       procedure RepaintVertex(LogicalDrawing: TLogicalDraw); override;
       function  GetSelect(TopLeft, BottomRight: TGTFPoint; AllVertexInRect: Boolean):Integer; override;
       function  GetSelect(TopLeft, BottomRight: TGTFPoint; AllVertexInRect: Boolean; var MVertx:TModifyVertex):Integer; overload; override;
       procedure MoveVertex(Index:integer; NewVertex:TGTFPoint);override;
       procedure GetRectVertex(var ATopLeft,ABottomRight:TGTFPoint);override;
   end;


const

  DELTASELECTVERTEX            = 10;

  //the affected area
  AFFA_OUTSIDE                 =-1; //Вне периметра
  AFFA_BASEPOINT               =0; //Базовая точка
  AFFA_VERTEX                  =1; //Вершина
  AFFA_INSIDE                  =2; //В периметре
  AFFA_BORDER                  =3; //Граница

  VERTEXMARKER_BASEPOINT_SEL   =-2; //Базовая точка
  VERTEXMARKER_VERTEX_SEL      =-3; //Вершина

  VERTEXMARKER_OUTSIDE         =-1; //Вне периметра
  VERTEXMARKER_BASEPOINT       =0; //Базовая точка
  VERTEXMARKER_VERTEX          =1; //Вершина
  VERTEXMARKER_INSIDE          =2; //В периметре
  VERTEXMARKER_BORDER          =3; //Граница
  VERTEXMARKER_CENTER          =4; //Центр

  LINETYPE_SOLID               ='LT_SOLID';
  LINETYPE_SELECTED            ='LT_SELECTED';
  LINETYPE_DIAGONAL            ='LT_DIAGONAL';
  LINETYPE_CROSS               ='LT_CROSS';

function SetNullToFloatPoint:TGTFPoint;
function GTFPoint(X,Y,Z:Integer):TGTFPoint;
function FloatPoint(X,Y,Z:Integer):TGTFPoint;
procedure SetDeltaToRectPoint(var TopLeft, BottomRight:TGTFPoint; DeltaVertex:Integer);
function PointIn2DRect(Point, RectTopLeft, RectBottomRight: TGTFPoint): Boolean;
function CordEqualIn2D(APoint,BPoint: TGTFPoint):boolean;
function CordEqualIn3D(APoint,BPoint: TGTFPoint):boolean;
procedure GetRectCord(const Align:TgaAttachmentPoint; X0,Y0,AWidth,AHeight:Integer; var TopLeftPointWCS,BottomRightPointWCS: TGTFPoint);
procedure GetEntityListRectVertex(AEntityList:TEntityList; var ATopLeft, ABottomRight: TGTFPoint);

implementation

function ColorDarker(Color: TColor; Percent: Byte): TColor;
var
  r, g, b: Byte;
begin
  Color := ColorToRGB(Color);
  r := GetRValue(Color);
  g := GetGValue(Color);
  b := GetBValue(Color);
  r := r - muldiv(r, Percent, 100);
  //процент% уменьшения яркости

  g := g - muldiv(g, Percent, 100);
  b := b - muldiv(b, Percent, 100);
  result := RGB(r, g, b);

end;

function SetNullToFloatPoint:TGTFPoint;
var
  APoint:TGTFPoint;
begin
  APoint.X:=0;
  APoint.Y:=0;
  APoint.Z:=0;
  Result:=APoint;
end;

function GTFPoint(X,Y,Z:Integer):TGTFPoint;
var
  APoint:TGTFPoint;
begin
  APoint.X:=X;
  APoint.Y:=Y;
  APoint.Z:=Z;
  Result:=APoint;
end;

function FloatPoint(X,Y,Z:Integer):TGTFPoint;
var
  APoint:TGTFPoint;
begin
  APoint.X:=X;
  APoint.Y:=Y;
  APoint.Z:=Z;
  Result:=APoint;
end;

procedure SetDeltaToRectPoint(var TopLeft, BottomRight:TGTFPoint; DeltaVertex:Integer);
begin
      TopLeft.X:=TopLeft.X-DeltaVertex;
      TopLeft.Y:=TopLeft.Y+DeltaVertex;
      BottomRight.X:=BottomRight.X+DeltaVertex;
      BottomRight.Y:=BottomRight.Y-DeltaVertex;
end;

function PointIn2DRect(Point, RectTopLeft, RectBottomRight: TGTFPoint): Boolean;
begin
  Result:=PointInRect2D(Point.X,Point.Y,RectTopLeft.X,RectTopLeft.Y,RectBottomRight.X,RectBottomRight.Y);
end;

function CordEqualIn2D(APoint,BPoint: TGTFPoint):boolean;
begin
  if (APoint.X=BPoint.X)and(APoint.Y=BPoint.Y) then
      Result:=true
  else
      Result:=false;
end;

function CordEqualIn3D(APoint,BPoint: TGTFPoint):boolean;
begin
  if (APoint.X=BPoint.X)and(APoint.Y=BPoint.Y)and(APoint.Z=BPoint.Z) then
      Result:=true
  else
      Result:=false;
end;

procedure GetRectCord(const Align:TgaAttachmentPoint; X0,Y0,AWidth,AHeight:Integer; var TopLeftPointWCS,BottomRightPointWCS: TGTFPoint);
begin
      case Align of
      gaAttachmentPointTopLeft:
      begin
          TopLeftPointWCS.X:=X0;
          TopLeftPointWCS.Y:=Y0;
          BottomRightPointWCS.X:=X0+AWidth;
          BottomRightPointWCS.Y:=Y0+AHeight;
      end;
      gaAttachmentPointTopCenter:
      begin
          TopLeftPointWCS.X:=X0-AWidth div 2;
          TopLeftPointWCS.Y:=Y0;
          BottomRightPointWCS.X:=X0+AWidth div 2;
          BottomRightPointWCS.Y:=Y0+AHeight;
      end;
      gaAttachmentPointTopRight:
      begin
          TopLeftPointWCS.X:=X0-AWidth;
          TopLeftPointWCS.Y:=Y0;
          BottomRightPointWCS.X:=X0;
          BottomRightPointWCS.Y:=Y0+AHeight;
      end;
      gaAttachmentPointMiddleLeft:
      begin
          TopLeftPointWCS.X:=X0;
          TopLeftPointWCS.Y:=Y0-AHeight div 2;
          BottomRightPointWCS.X:=X0+AWidth;
          BottomRightPointWCS.Y:=Y0+AHeight div 2;
      end;
      gaAttachmentPointMiddleCenter:
      begin
          TopLeftPointWCS.X:=X0-AWidth div 2;
          TopLeftPointWCS.Y:=Y0-AHeight div 2;
          BottomRightPointWCS.X:=X0+AWidth div 2;
          BottomRightPointWCS.Y:=Y0+AHeight div 2;
      end;
      gaAttachmentPointMiddleRight:
      begin
          TopLeftPointWCS.X:=X0-AWidth;
          TopLeftPointWCS.Y:=Y0-(AHeight div 2);
          BottomRightPointWCS.X:=X0;
          BottomRightPointWCS.Y:=Y0+AHeight div 2;
      end;
      gaAttachmentPointBottomLeft:
      begin
          TopLeftPointWCS.X:=X0;
          TopLeftPointWCS.Y:=Y0-AHeight;
          BottomRightPointWCS.X:=X0+AWidth;
          BottomRightPointWCS.Y:=Y0;
      end;
      gaAttachmentPointBottomCenter:
      begin
          TopLeftPointWCS.X:=X0-AWidth div 2;
          TopLeftPointWCS.Y:=Y0-AHeight;
          BottomRightPointWCS.X:=X0+AWidth div 2;
          BottomRightPointWCS.Y:=Y0;
      end;
      gaAttachmentPointBottomRight:
      begin
          TopLeftPointWCS.X:=X0-AWidth;
          TopLeftPointWCS.Y:=Y0-AHeight;
          BottomRightPointWCS.X:=X0;
          BottomRightPointWCS.Y:=Y0;
      end;
      end;
end;

procedure GetEntityListRectVertex(AEntityList:TEntityList; var ATopLeft, ABottomRight: TGTFPoint);
var
   x1TopLeft,x1BottomRight: TGTFPoint;
   x2TopLeft,x2BottomRight: TGTFPoint;
   i,iSX,iSY:integer;
begin
  x1TopLeft:=SetNullToFloatPoint;
  x2TopLeft:=SetNullToFloatPoint;
  x1BottomRight:=SetNullToFloatPoint;
  x2BottomRight:=SetNullToFloatPoint;

  if AEntityList.Count>0 then
  begin
       AEntityList.Items[0].GetRectVertex(x1TopLeft,x1BottomRight);
       x2TopLeft.X:=x1TopLeft.X;
       x2TopLeft.Y:=x1TopLeft.Y;
       x2BottomRight.X:=x1BottomRight.X;
       x2BottomRight.Y:=x1BottomRight.Y;
  end;

  for i:=1 to AEntityList.Count-1 do
  begin
           iSX:=1;
           iSY:=1;

           AEntityList.Items[i].GetRectVertex(x1TopLeft,x1BottomRight);
           if (x1TopLeft.X*iSX)<x2TopLeft.X then x2TopLeft.X:=(x1TopLeft.X*iSX);
           if (x1TopLeft.Y*iSY)>x2TopLeft.Y then x2TopLeft.Y:=(x1TopLeft.Y*iSY);

           if (x1BottomRight.X*iSX)>x2BottomRight.x then x2BottomRight.X:=(x1BottomRight.X*iSX);
           if (x1BottomRight.Y*iSY)<x2BottomRight.Y then x2BottomRight.Y:=(x1BottomRight.Y*iSY);
  end;

  ATopLeft:=x2TopLeft;
  ABottomRight:=x2BottomRight;
end;

{ TGTFDrawDocumentCustom }

procedure TGTFDrawDocumentCustom.SetExtendedColumns(AData: TStringArray);
var
   i:integer;
   Item:TGTFCListColumnItem;
begin
  FExtColumns.BeginUpdate;

  if Length(AData)>0 then
  begin
      if FExtColumns.Count=0 then
      begin
         Item:=FExtColumns.Add;
         Item.Caption:='';
      end;

      for i:=0 to high(AData) do
      begin
         if ((i+1)<FExtColumns.Count) then
         begin
            Item:=FExtColumns.Items[i+1];
            Item.Caption:=AData[i];
         end
         else begin
            Item:=FExtColumns.Add;
            Item.Caption:=AData[i];
         end;
      end;

      for i:=FExtColumns.Count-1 downto high(AData)+2 do
      begin
         FExtColumns.Delete(i);
      end;
  end
  else begin
      for i:=FExtColumns.Count-1 downto 1 do
      begin
         FExtColumns.Delete(i);
      end;
  end;

  FExtColumns.EndUpdate;
end;

function TGTFDrawDocumentCustom.GetRowsAutoSort: Boolean;
begin
   Result:=Rows.AutoSort;
end;

procedure TGTFDrawDocumentCustom.SetRowsAutoSort(AValue: Boolean);
begin
   Rows.AutoSort:=AValue;
end;

procedure TGTFDrawDocumentCustom.SetFirstColumn(AData: String);
var
   Item:TGTFCListColumnItem;
begin
  FExtColumns.BeginUpdate;

  if Length(AData)>0 then
  begin
      if FExtColumns.Count=0 then
      begin
         Item:=FExtColumns.Add;
         Item.Caption:=AData;
      end
      else begin
         Item:=FExtColumns.Items[0];
         Item.Caption:=AData;
      end;
  end
  else begin
      if FExtColumns.Count>1 then
      begin
         Item:=FExtColumns.Items[0];
         Item.Caption:='';
      end
      else if FExtColumns.Count=1 then
      begin
         FExtColumns.Delete(0);
      end;
  end;

  FExtColumns.EndUpdate;
end;

{ TBasicGridEntity }

procedure TBasicGridEntity.SetTimeBegin(AValue: TDateTime);
begin
  if FTimeBegin=AValue then Exit;
  FTimeBegin:=AValue;
end;

function TBasicGridEntity.GetTimeBegin: TDateTime;
begin
   Result:=FTimeBegin;
end;

function TBasicGridEntity.GetTimeEnd: TDateTime;
begin
   Result:=FTimeEnd;
end;

procedure TBasicGridEntity.SetTimeEnd(AValue: TDateTime);
begin
  if FTimeEnd=AValue then Exit;
  FTimeEnd:=AValue;
end;

function TBasicGridEntity.GetBeginPoint: TGTFPoint;
var
   Doc:TGTFDrawDocumentCustom;
   ColItem:TGTFCOutsetTreeColItem;
   i,x,iDownLevel:integer;
begin
  Result.X:=0;
  Result.Y:=0;
  Result.Z:=0;

  Doc:=GetDocument;
  iDownLevel:=Doc.Cols.LevelCount-1;
  for i:=0 to Doc.Cols.Count-1 do
  begin
    ColItem:=TGTFCOutsetTreeColItem(Doc.Cols.Items[i]);
    if ColItem.Level=iDownLevel then
    begin
       if ((CompareDateTime(TimeBegin,ColItem.BeginDate)>=0)and(CompareDateTime(TimeBegin,ColItem.EndDate)<=0)) then
       begin
          if (CompareDateTime(TimeEnd,ColItem.BeginDate)>=0)and(CompareDateTime(TimeEnd,ColItem.EndDate)<=0) then
          begin
             Result.X:=ColItem.BeginX+Doc.FNodePaddingLeftRight;
             break;
          end
          else begin
             x:=(ColItem.EndX-ColItem.BeginX) div 2;
             Result.X:=ColItem.BeginX+x;
             break;
          end;
       end;
    end;
  end;
end;

function TBasicGridEntity.GetEndPoint: TGTFPoint;
var
   Doc:TGTFDrawDocumentCustom;
   ColItem:TGTFCOutsetTreeColItem;
   i,x,iDownLevel,LastX:integer;
   bFinded:Boolean;
begin
  Result.X:=0;
  Result.Y:=0;
  Result.Z:=0;
  LastX:=0;
  bFinded:=False;
  Doc:=GetDocument;
  iDownLevel:=Doc.Cols.LevelCount-1;
  for i:=0 to Doc.Cols.Count-1 do
  begin
    ColItem:=TGTFCOutsetTreeColItem(Doc.Cols.Items[i]);
    if ColItem.Level=iDownLevel then
    begin
       if LastX<ColItem.EndX then
          LastX:=ColItem.EndX;
       if (CompareDateTime(TimeEnd,ColItem.BeginDate)>=0)and(CompareDateTime(TimeEnd,ColItem.EndDate)<=0)then
       begin
          if ((CompareDateTime(TimeBegin,ColItem.BeginDate)>=0)and(CompareDateTime(TimeBegin,ColItem.EndDate)<=0)) then
          begin
              Result.X:=ColItem.EndX-Doc.FNodePaddingLeftRight;
              bFinded:=True;
              break;
          end
          else begin
              x:=(ColItem.EndX-ColItem.BeginX) div 2;
              Result.X:=ColItem.EndX-x;
              bFinded:=True;
              break;
          end;
       end;
    end;
  end;

  if not bFinded then
  begin
     Result.X:=LastX;
  end;
end;

function TBasicGridEntity.GetRowPoint: TGTFCOutsetTreeRowItem;
begin
  if Assigned(GridRow) then
     Result:=GridRow
  else
     Result:=nil;
end;

constructor TBasicGridEntity.Create;
begin
    inherited Create;
    FText           :='';
    FTextSecondLine :='';
    FHint           :='';
    FColor            :=gaDefaultTaskColor;
    GridRow           :=nil;
    AntiLayeringIndex :=1;
    FSortRangIndex    :=0;
end;

{ TGraphicTask }

procedure TGraphicTask.Repaint(Xshift, Yshift, AScaleX, AScaleY,
  AScaleZ: Integer; LogicalDrawing: TLogicalDraw; AStyle: TEntityDrawStyle);
var
  TmpVertex0: TGTFPoint;
  TmpVertex1: TGTFPoint;
  TmpVertex2: TGTFPoint;
  TmpVertex3: TGTFPoint;
  TextSizeScale,
  FTextWidth,FTextHeight :integer;
  Doc                    :TGTFDrawDocumentCustom;
  RowItem                :TGTFCOutsetTreeRowItem;
  iGridScale,
  X1,Y1,Y4,RY1,RY2       :Integer;
  drFask,
  drX1,drY1,drX2,drY2    :Integer;
begin
  Doc:=GetDocument;
  if VertexCount=4 then
  begin
        iGridScale:=100;
        LogicalDrawing.GetGridScale(iGridScale);

        if BGTaskStyle=bgtsDiagonal then
           LogicalDrawing.SetStyleDraw(LINETYPE_DIAGONAL,GetLineWeight(FLineWeight),GetColor(FColor))
        else if BGTaskStyle=bgtsCross then
           LogicalDrawing.SetStyleDraw(LINETYPE_CROSS,GetLineWeight(FLineWeight),GetColor(FColor))
        else
           LogicalDrawing.SetStyleDraw(LINETYPE_SOLID,GetLineWeight(FLineWeight),GetColor(FColor));

      if edsSelected in AStyle then
      begin
         if BGTaskStyle=bgtsDiagonal then
           LogicalDrawing.SetStyleDraw(LINETYPE_DIAGONAL,GetLineWeight(FLineWeight),GetColor(gaHighLight))
        else if BGTaskStyle=bgtsCross then
           LogicalDrawing.SetStyleDraw(LINETYPE_CROSS,GetLineWeight(FLineWeight),GetColor(gaHighLight))
        else
           LogicalDrawing.SetStyleDraw(LINETYPE_SOLID,GetLineWeight(FLineWeight),GetColor(gaHighLight));
      end
      else begin
        if BGTaskStyle=bgtsDiagonal then
           LogicalDrawing.SetStyleDraw(LINETYPE_DIAGONAL,GetLineWeight(FLineWeight),GetColor(FColor))
        else if BGTaskStyle=bgtsCross then
           LogicalDrawing.SetStyleDraw(LINETYPE_CROSS,GetLineWeight(FLineWeight),GetColor(FColor))
        else
           LogicalDrawing.SetStyleDraw(LINETYPE_SOLID,GetLineWeight(FLineWeight),GetColor(FColor));
      end;

        TmpVertex0:=Vertex[0];
        TmpVertex1:=Vertex[1];
        TmpVertex2:=Vertex[2];
        TmpVertex3:=Vertex[3];

        TmpVertex0.X:=GetBeginPoint.X+1;
        TmpVertex3.X:=TmpVertex0.X;

        TmpVertex1.X:=GetEndPoint.X-1;
        TmpVertex2.X:=TmpVertex1.X;

        RowItem:=GetRowPoint;

        if RowItem=nil then
        begin
          Abort;
        end;

        RY1:=RowItem.EntityHeight*(AntiLayeringIndex-1);
        RY2:=RowItem.EntityHeight;

        TmpVertex0.Y:=RowItem.BeginY+RY1+2;
        TmpVertex3.Y:=TmpVertex0.Y+RY2-5;

        TmpVertex1.Y:=TmpVertex0.Y;
        TmpVertex2.Y:=TmpVertex3.Y;

        Vertex[0]:=TmpVertex0;
        Vertex[1]:=TmpVertex1;
        Vertex[2]:=TmpVertex2;
        Vertex[3]:=TmpVertex3;

        //Конвертирование координаты при перемещении курсора
        //or(esEditing in State))
        if (esMoving in State) then
        begin
            TmpVertex0:=GetInteractiveVertex(TmpVertex0);
            TmpVertex1:=GetInteractiveVertex(TmpVertex1);
            TmpVertex2:=GetInteractiveVertex(TmpVertex2);
            TmpVertex3:=GetInteractiveVertex(TmpVertex3);
        end;

        drX1:=(TmpVertex3.X*AScaleX)+Xshift;
        drY1:=(TmpVertex3.Y*AScaleY)+Yshift;
        drX2:=(TmpVertex1.X*AScaleX)+Xshift;
        drY2:=(TmpVertex1.Y*AScaleY)+Yshift;
        drFask:=1;

        LogicalDrawing.PolygonDraw([Point(drX1,drY1-drFask),Point(drX1+drFask,drY1),Point(drX2-drFask,drY1),Point(drX2,drY1-drFask),Point(drX2,drY2+drFask),Point(drX2-drFask,drY2),Point(drX1+drFask,drY2),Point(drX1,drY2+drFask),Point(drX1,drY1-drFask)]);

      if edsSelected in AStyle then
        LogicalDrawing.SetStyleDraw(LINETYPE_SELECTED,GetLineWeight(FLineWeight),GetColor(gaHighLightText))
      else
        LogicalDrawing.SetStyleDraw(LINETYPE_SOLID,GetLineWeight(FLineWeight),GetColor(gaDefault));

      TextSizeScale:=AScaleY;
      if TextSizeScale<0 then
         TextSizeScale:=TextSizeScale*-1;

      LogicalDrawing.SetFontStyleDraw(Doc.FFontName, Doc.FFontSize*TextSizeScale, []);

      FTextWidth  :=ABS(TmpVertex1.X-TmpVertex0.X)-3;
      FTextHeight :=ABS(TmpVertex3.Y-TmpVertex0.Y);
      X1          :=TmpVertex0.X;

        case iGridScale of
            120:
            begin
                  {
                Y4          :=FTextHeight div 6;
                Y1          :=TmpVertex0.Y+Y4*3;
                LogicalDrawing.TextDraw((X1*AScaleX)+Xshift+5,(Y1*AScaleY)+Yshift{+5}, FTextWidth*AscaleX, FTextHeight*AscaleY, 0, FText, gaAttachmentPointMiddleLeft);
                Y1          :=Y1+Y4*3;
                LogicalDrawing.TextDraw((X1*AScaleX)+Xshift+5,(Y1*AScaleY)+Yshift{+5}, FTextWidth*AscaleX, FTextHeight*AscaleY, 0, FTextSecondLine, gaAttachmentPointMiddleLeft);
                }
                Y4          :=FTextHeight div 2;
                Y1          :=TmpVertex0.Y+Y4-1;
                LogicalDrawing.TextDraw((X1*AScaleX)+Xshift+5,(Y1*AScaleY)+Yshift{+5}, FTextWidth*AscaleX, FTextHeight*AscaleY, 0, FText, gaAttachmentPointMiddleLeft);
                Y1          :=Y1+Y4-1;
                LogicalDrawing.TextDraw((X1*AScaleX)+Xshift+5,(Y1*AScaleY)+Yshift{+5}, FTextWidth*AscaleX, FTextHeight*AscaleY, 0, FTextSecondLine, gaAttachmentPointMiddleLeft);

            end;
            130:
            begin  {
                Y4          :=FTextHeight div 6;
                Y1          :=TmpVertex0.Y+Y4*3-2;
                LogicalDrawing.TextDraw((X1*AScaleX)+Xshift+5,(Y1*AScaleY)+Yshift{+5}, FTextWidth*AscaleX, FTextHeight*AscaleY, 0, FText, gaAttachmentPointMiddleLeft);
                Y1          :=Y1+Y4*3;
                LogicalDrawing.TextDraw((X1*AScaleX)+Xshift+5,(Y1*AScaleY)+Yshift{+5}, FTextWidth*AscaleX, FTextHeight*AscaleY, 0, FTextSecondLine, gaAttachmentPointMiddleLeft);
                }
                 Y4          :=FTextHeight div 2;
                Y1          :=TmpVertex0.Y+Y4-1;
                LogicalDrawing.TextDraw((X1*AScaleX)+Xshift+5,(Y1*AScaleY)+Yshift{+5}, FTextWidth*AscaleX, FTextHeight*AscaleY, 0, FText, gaAttachmentPointMiddleLeft);
                Y1          :=Y1+Y4-1;
                LogicalDrawing.TextDraw((X1*AScaleX)+Xshift+5,(Y1*AScaleY)+Yshift{+5}, FTextWidth*AscaleX, FTextHeight*AscaleY, 0, FTextSecondLine, gaAttachmentPointMiddleLeft);

            end;
            140:
            begin   {
                Y4          :=FTextHeight div 6;
                Y1          :=TmpVertex0.Y+Y4*3-4;
                LogicalDrawing.TextDraw((X1*AScaleX)+Xshift+5,(Y1*AScaleY)+Yshift{+5}, FTextWidth*AscaleX, FTextHeight*AscaleY, 0, FText, gaAttachmentPointMiddleLeft);
                Y1          :=Y1+Y4*3;
                LogicalDrawing.TextDraw((X1*AScaleX)+Xshift+5,(Y1*AScaleY)+Yshift{+5}, FTextWidth*AscaleX, FTextHeight*AscaleY, 0, FTextSecondLine, gaAttachmentPointMiddleLeft);
                }
                Y4          :=FTextHeight div 2+1;
                Y1          :=TmpVertex0.Y+Y4-1;
                LogicalDrawing.TextDraw((X1*AScaleX)+Xshift+5,(Y1*AScaleY)+Yshift{+5}, FTextWidth*AscaleX, FTextHeight*AscaleY, 0, FText, gaAttachmentPointMiddleLeft);
                Y1          :=Y1+Y4-1;
                LogicalDrawing.TextDraw((X1*AScaleX)+Xshift+5,(Y1*AScaleY)+Yshift{+5}, FTextWidth*AscaleX, FTextHeight*AscaleY, 0, FTextSecondLine, gaAttachmentPointMiddleLeft);

            end;
            150:
            begin  {
                Y4          :=FTextHeight div 6;
                Y1          :=TmpVertex0.Y+Y4*3;
                LogicalDrawing.TextDraw((X1*AScaleX)+Xshift+5,(Y1*AScaleY)+Yshift{+5}, FTextWidth*AscaleX, FTextHeight*AscaleY, 0, FText, gaAttachmentPointMiddleLeft);
                Y1          :=Y1+Y4*3;
                LogicalDrawing.TextDraw((X1*AScaleX)+Xshift+5,(Y1*AScaleY)+Yshift{+5}, FTextWidth*AscaleX, FTextHeight*AscaleY, 0, FTextSecondLine, gaAttachmentPointMiddleLeft);
                }
                Y4          :=FTextHeight div 2+1;
                Y1          :=TmpVertex0.Y+Y4-1;
                LogicalDrawing.TextDraw((X1*AScaleX)+Xshift+5,(Y1*AScaleY)+Yshift{+5}, FTextWidth*AscaleX, FTextHeight*AscaleY, 0, FText, gaAttachmentPointMiddleLeft);
                Y1          :=Y1+Y4-1;
                LogicalDrawing.TextDraw((X1*AScaleX)+Xshift+5,(Y1*AScaleY)+Yshift{+5}, FTextWidth*AscaleX, FTextHeight*AscaleY, 0, FTextSecondLine, gaAttachmentPointMiddleLeft);

            end;
            else begin
               Y1          :=TmpVertex0.Y+FTextHeight div 2;

               //if iGridScale<100 then
               //   Y1:=Y1-2;

               if Length(FTextSecondLine)>0 then
                 LogicalDrawing.TextDraw((X1*AScaleX)+Xshift+5,(Y1*AScaleY)+Yshift{+5}, FTextWidth*AscaleX, FTextHeight*AscaleY, 0, FText+' ● '+FTextSecondLine, gaAttachmentPointMiddleLeft)
               else
                 LogicalDrawing.TextDraw((X1*AScaleX)+Xshift+5,(Y1*AScaleY)+Yshift{+5}, FTextWidth*AscaleX, FTextHeight*AscaleY, 0, FText, gaAttachmentPointMiddleLeft);
            end;
        end;

        if edsMoving in AStyle then
          LogicalDrawing.SetStyleDraw(LINETYPE_SELECTED,GetLineWeight(gaLnWtDefault),GetColor(gaBlack))
        else if edsSelected in AStyle then
          LogicalDrawing.SetStyleDraw(LINETYPE_SOLID,GetLineWeight(gaLnWtDefault),GetColor(gaBlack))
        else
          LogicalDrawing.SetStyleDraw(LINETYPE_SOLID,GetLineWeight(gaLnWtDefault),GetColor(gaGray));

        LogicalDrawing.PolylineDraw([Point(drX1,drY1-drFask),Point(drX1+drFask,drY1),Point(drX2-drFask,drY1),Point(drX2,drY1-drFask),Point(drX2,drY2+drFask),Point(drX2-drFask,drY2),Point(drX1+drFask,drY2),Point(drX1,drY2+drFask),Point(drX1,drY1-drFask)]);
        LogicalDrawing.LineDraw(drX1+1,drY1,drX1+1,drY2);

        if FMarkerBegin then
        begin
          LogicalDrawing.SetStyleDraw(LINETYPE_SOLID,GetLineWeight(gaLnWtDefault),GetColor(FMarkerBeginColor));
          LogicalDrawing.PolygonDraw([Point(drX1+1,drY1),Point(drX1+3,drY1),Point(drX1+3,drY2),Point(drX1+1,drY2)]);
        end;
        if FMarkerEnd then
        begin
          LogicalDrawing.SetStyleDraw(LINETYPE_SOLID,GetLineWeight(gaLnWtDefault),GetColor(FMarkerEndColor));
          LogicalDrawing.PolygonDraw([Point(drX2-3,drY1),Point(drX2-1,drY1),Point(drX2-1,drY2),Point(drX2-3,drY2)]);
        end;

  end;
end;

procedure TGraphicTask.RepaintVertex(LogicalDrawing: TLogicalDraw);
begin
  //inherited RepaintVertex(LogicalDrawing);
end;

function TGraphicTask.GetSelect(TopLeft, BottomRight: TGTFPoint;
  AllVertexInRect: Boolean): Integer;
var
  MVertx: TModifyVertex;
begin
  Result:=GetSelect(TopLeft, BottomRight,AllVertexInRect,MVertx);
end;

function TGraphicTask.GetSelect(TopLeft, BottomRight: TGTFPoint;
  AllVertexInRect: Boolean; var MVertx: TModifyVertex): Integer;
var
  i,CountVertexInRect:integer;
  TmpTopLeft, TmpBottomRight: TGTFPoint;
  APoint: TGTFPoint;
begin

    Result:=AFFA_OUTSIDE; //Вне периметра

    // Проверка попадают ли вершины в зону выбора
    CountVertexInRect:=0;

    //SetDeltaToRectPoint(TopLeft, BottomRight, ThisDocument.GetDeltaVertex);

    // Проверка попадает ли базовая точка в зону выбора
    if (VertexCount>0) then
    begin
        if PointIn2DRect(Vertex[0], TopLeft, BottomRight) then
        begin
          CountVertexInRect  :=CountVertexInRect+1;
          MVertx.Item        :=self;
          MVertx.VertexIndex :=0;
          MVertx.VertexPos   :=Vertex[MVertx.VertexIndex];
        end;
        if (not AllVertexInRect)and(CountVertexInRect>0) then
        begin
          Result:=AFFA_BASEPOINT;
        end;
    end;

    // Проверка попадают ли вершины в зону выбора
    for I := 1 to VertexCount - 1 do
    begin
        if PointIn2DRect(Vertex[i],TopLeft, BottomRight) then
        begin
          CountVertexInRect  :=CountVertexInRect+1;
          MVertx.Item        :=self;
          MVertx.VertexIndex :=i;
          MVertx.VertexPos   :=Vertex[MVertx.VertexIndex];
        end;
    end;

    if (AllVertexInRect)and(CountVertexInRect=VertexCount)and(VertexCount>0)and(Result=AFFA_OUTSIDE) then
    begin
      Result:=AFFA_VERTEX;
    end
    else if (not AllVertexInRect)and(CountVertexInRect>0)and(Result=AFFA_OUTSIDE) then
    begin
      Result:=AFFA_VERTEX;
    end;

    // Проверка попадают ли промежуточные точки в зону выбора

      if (not AllVertexInRect)and(VertexCount>=1)and(Result<>AFFA_VERTEX)and(Result<>AFFA_BASEPOINT) then
      begin

          APoint:=Vertex[0];
          for I := 1 to VertexCount - 1 do
          begin
            //AC
            if isLinesHasIntersection(APoint.X,APoint.Y,Vertex[i].X,Vertex[i].Y,TopLeft.X,TopLeft.Y,BottomRight.X,BottomRight.Y) then
            begin
              Result:=AFFA_BORDER;
              break;
            end;
            //BD
            if isLinesHasIntersection(APoint.X,APoint.Y,Vertex[i].X,Vertex[i].Y,BottomRight.X,TopLeft.Y,TopLeft.X,BottomRight.Y) then
            begin
              Result:=AFFA_BORDER;
              break;
            end;
            //AB
            if isLinesHasIntersection(APoint.X,APoint.Y,Vertex[i].X,Vertex[i].Y,TopLeft.X,TopLeft.Y,BottomRight.X,TopLeft.Y) then
            begin
              Result:=AFFA_BORDER;
              break;
            end;
            //BC
            if isLinesHasIntersection(APoint.X,APoint.Y,Vertex[i].X,Vertex[i].Y,BottomRight.X,TopLeft.Y,BottomRight.X,BottomRight.Y) then
            begin
              Result:=AFFA_BORDER;
              break;
            end;
            //CD
            if isLinesHasIntersection(APoint.X,APoint.Y,Vertex[i].X,Vertex[i].Y,BottomRight.X,BottomRight.Y,TopLeft.X,BottomRight.Y) then
            begin
              Result:=AFFA_BORDER;
              break;
            end;
            //DA
            if isLinesHasIntersection(APoint.X,APoint.Y,Vertex[i].X,Vertex[i].Y,TopLeft.X,BottomRight.Y,TopLeft.X,TopLeft.Y) then
            begin
              Result:=AFFA_BORDER;
              break;
            end;
            APoint:=Vertex[i];
          end; //for

          //SetDeltaToRectPoint(TopLeft, BottomRight, ThisDocument.GetDeltaVertex*-1);

          // Проверка попадает ли зона выбора в периметр объекта
          if (Result=AFFA_OUTSIDE)and(not AllVertexInRect) then
          begin
              if (VertexCount=4) then
              begin
                TmpTopLeft     :=Vertex[0];
                TmpBottomRight :=Vertex[2];
                if PointIn2DRect(TopLeft,TmpTopLeft,TmpBottomRight) then
                  Result:=AFFA_INSIDE
                else if (Result=AFFA_OUTSIDE)and(PointIn2DRect(BottomRight,Vertex[0], Vertex[2])) then
                  Result:=AFFA_INSIDE;

                if Result=AFFA_INSIDE then
                begin
                   MVertx.Item        :=self;
                   MVertx.VertexIndex :=0;
                   MVertx.VertexPos   :=Vertex[0];
                end;
              end;
          end;
      end;
end;

constructor TGraphicTask.Create;
begin
  inherited Create;
  BGTaskStyle       :=bgtsStandard;
  AddVertex(0,0,0);
  AddVertex(0,0,0);
  AddVertex(0,0,0);
  AddVertex(0,0,0);
  FSortRangIndex    :=3;

  FMarkerBegin        :=False;
  FMarkerBeginColor   :=gaRed;
  FMarkerEnd          :=False;
  FMarkerEndColor     :=gaRed;
end;

{ TGraphicFrameLine }

procedure TGraphicFrameLine.Repaint(Xshift, Yshift, AScaleX, AScaleY,
  AScaleZ: Integer; LogicalDrawing: TLogicalDraw; AStyle: TEntityDrawStyle);
var
  TmpVertex0: TGTFPoint;
  TmpVertex1: TGTFPoint;
  TmpVertex2: TGTFPoint;
  TmpVertex3: TGTFPoint;

  TmpVertexBegin : TGTFPoint;
  TmpVertexEnd   : TGTFPoint;

  TextSizeScale,
  FTextWidth,FTextHeight :integer;
  Doc                    :TGTFDrawDocumentCustom;
  RowItem                :TGTFCOutsetTreeRowItem;
  iGridScale,
  iQuadHeight,
  iLineHeight,
  X1,Y1,RY1,RY2          :Integer;
  sText                        :String;
  rGridScale                   :real;
begin
  Doc:=GetDocument;
  if VertexCount=4 then
  begin
        iGridScale:=100;
        LogicalDrawing.GetGridScale(iGridScale);

        rGridScale:=1;
        if iGridScale<100 then
        begin
             rGridScale:=iGridScale / 100;
        end;

        if edsSelected in AStyle then
          LogicalDrawing.SetStyleDraw(LINETYPE_SELECTED,GetLineWeight(gaLnWtDefault),GetColor(gaHighLight))
        else
          LogicalDrawing.SetStyleDraw(LINETYPE_SOLID,GetLineWeight(gaLnWtDefault),GetColor(FColor));

        TmpVertex0:=Vertex[0];
        TmpVertex1:=Vertex[1];
        TmpVertex2:=Vertex[2];
        TmpVertex3:=Vertex[3];

        TmpVertex0.X:=GetBeginPoint.X+1;
        TmpVertex3.X:=TmpVertex0.X;

        TmpVertex1.X:=GetEndPoint.X-1;
        TmpVertex2.X:=TmpVertex1.X;

        RowItem:=GetRowPoint;

        if RowItem=nil then
        begin
          Abort;
        end;

        RY1:=RowItem.EntityHeight*(AntiLayeringIndex-1);
        RY2:=RowItem.EntityHeight;
        iQuadHeight:=Trunc(rGridScale*(((RowItem.EntityHeight div 4)*AScaleY)+Yshift));

        iLineHeight:=iQuadHeight div 2;
        if iLineHeight<3 then
           iLineHeight:=3;

        TmpVertex0.Y:=RowItem.BeginY+RY1+8;
        TmpVertex3.Y:=TmpVertex0.Y+RY2-5;

        TmpVertex1.Y:=TmpVertex0.Y;
        TmpVertex2.Y:=TmpVertex3.Y;

        Vertex[0]:=TmpVertex0;
        Vertex[1]:=TmpVertex1;
        Vertex[2]:=TmpVertex2;
        Vertex[3]:=TmpVertex3;

        //Конвертирование координаты при перемещении курсора
        //or(esEditing in State))
        if (esMoving in State) then
        begin
            TmpVertex0:=GetInteractiveVertex(TmpVertex0);
            TmpVertex1:=GetInteractiveVertex(TmpVertex1);
            TmpVertex2:=GetInteractiveVertex(TmpVertex2);
            TmpVertex3:=GetInteractiveVertex(TmpVertex3);
        end;

        FTextWidth  :=ABS(TmpVertex1.X-TmpVertex0.X);
        FTextHeight :=ABS(TmpVertex3.Y-TmpVertex0.Y);

        TmpVertexBegin   := TmpVertex0;
        TmpVertexEnd     := TmpVertex1;
        TmpVertexBegin.Y := TmpVertex0.Y+1;
        TmpVertexEnd.Y   := TmpVertex1.Y+1;

        LogicalDrawing.FillDraw((TmpVertex0.X*AScaleX)+Xshift,(TmpVertex0.Y*AScaleY)+Yshift,(TmpVertex2.X*AScaleX)+Xshift,((TmpVertex0.Y+(iLineHeight))*AScaleY)+Yshift);

        TextSizeScale:=AScaleY;
        if TextSizeScale<0 then
           TextSizeScale:=TextSizeScale*-1;

        LogicalDrawing.SetFontStyleDraw(Doc.FFontName, 12*TextSizeScale, []);

        if FTriangleBegin then
        LogicalDrawing.PolygonDraw(((TmpVertexBegin.X)*AScaleX)+Xshift,((TmpVertexBegin.Y+1)*AScaleY)+Yshift,[Point(0,0),Point(0,(iQuadHeight)*2),Point((iQuadHeight*2),0)]);

        if FTriangleEnd then
        LogicalDrawing.PolygonDraw(((TmpVertexEnd.X-1)*AScaleX)+Xshift,((TmpVertexEnd.Y+1)*AScaleY)+Yshift,[Point((iQuadHeight)*-2,0),Point(0,0),Point(0,(iQuadHeight*2))]);
        //LogicalDrawing.TextDraw(((TmpVertexBegin.X+3)*AScaleX)+Xshift,((TmpVertexBegin.Y-2)*AScaleY)+Yshift, 20*AscaleX, 20*AscaleY, 0, '▼', gaAttachmentPointTopCenter);
        //LogicalDrawing.TextDraw(((TmpVertexEnd.X+3)*AScaleX)+Xshift,((TmpVertexEnd.Y-2)*AScaleY)+Yshift, 20*AscaleX, 20*AscaleY, 0, '▼', gaAttachmentPointTopCenter);

        //Текст
        LogicalDrawing.SetStyleDraw(LINETYPE_SOLID,GetLineWeight(gaLnWtDefault),GetColor(gaDefault)); //
        LogicalDrawing.SetFontStyleDraw(Doc.FFontName, Doc.FFontSize*TextSizeScale, []);

        sText:=FText+' '+FTextSecondLine;
        LogicalDrawing.GetTextHeight(sText,FTextHeight);
        LogicalDrawing.GetTextWidth(sText,FTextWidth);

        X1          :=TmpVertex1.X+FTextHeight; //отступ на высоту буквы

        Y1          :=TmpVertex1.Y+2;
        LogicalDrawing.TextDraw((X1*AScaleX)+Xshift+5,(Y1*AScaleY)+Yshift, FTextWidth*AscaleX, FTextHeight*AscaleY, 0, FText, gaAttachmentPointMiddleLeft);

        if iGridScale>=120 then
        begin
          Y1          :=TmpVertex1.Y+FTextHeight+2;
          LogicalDrawing.TextDraw((X1*AScaleX)+Xshift+5,(Y1*AScaleY)+Yshift, FTextWidth*AscaleX, FTextHeight*AscaleY, 0, FTextSecondLine, gaAttachmentPointMiddleLeft);
        end;
  end;
end;

procedure TGraphicFrameLine.RepaintVertex(LogicalDrawing: TLogicalDraw);
begin
  //inherited RepaintVertex(LogicalDrawing);
end;

function TGraphicFrameLine.GetSelect(TopLeft, BottomRight: TGTFPoint;
  AllVertexInRect: Boolean): Integer;
var
  MVertx: TModifyVertex;
begin
  Result:=GetSelect(TopLeft, BottomRight,AllVertexInRect,MVertx);
end;

function TGraphicFrameLine.GetSelect(TopLeft, BottomRight: TGTFPoint;
  AllVertexInRect: Boolean; var MVertx: TModifyVertex): Integer;
var
  i,CountVertexInRect:integer;
  TmpTopLeft, TmpBottomRight: TGTFPoint;
  APoint: TGTFPoint;
begin

    Result:=AFFA_OUTSIDE; //Вне периметра

    // Проверка попадают ли вершины в зону выбора
    CountVertexInRect:=0;

    //SetDeltaToRectPoint(TopLeft, BottomRight, ThisDocument.GetDeltaVertex);

    // Проверка попадает ли базовая точка в зону выбора
    if (VertexCount>0) then
    begin
        if PointIn2DRect(Vertex[0], TopLeft, BottomRight) then
        begin
          CountVertexInRect  :=CountVertexInRect+1;
          MVertx.Item        :=self;
          MVertx.VertexIndex :=0;
          MVertx.VertexPos   :=Vertex[MVertx.VertexIndex];
        end;
        if (not AllVertexInRect)and(CountVertexInRect>0) then
        begin
          Result:=AFFA_BASEPOINT;
        end;
    end;

    // Проверка попадают ли вершины в зону выбора
    for I := 1 to VertexCount - 1 do
    begin
        if PointIn2DRect(Vertex[i],TopLeft, BottomRight) then
        begin
          CountVertexInRect  :=CountVertexInRect+1;
          MVertx.Item        :=self;
          MVertx.VertexIndex :=i;
          MVertx.VertexPos   :=Vertex[MVertx.VertexIndex];
        end;
    end;

    if (AllVertexInRect)and(CountVertexInRect=VertexCount)and(VertexCount>0)and(Result=AFFA_OUTSIDE) then
    begin
      Result:=AFFA_VERTEX;
    end
    else if (not AllVertexInRect)and(CountVertexInRect>0)and(Result=AFFA_OUTSIDE) then
    begin
      Result:=AFFA_VERTEX;
    end;

    // Проверка попадают ли промежуточные точки в зону выбора

      if (not AllVertexInRect)and(VertexCount>=1)and(Result<>AFFA_VERTEX)and(Result<>AFFA_BASEPOINT) then
      begin

          APoint:=Vertex[0];
          for I := 1 to VertexCount - 1 do
          begin
            //AC
            if isLinesHasIntersection(APoint.X,APoint.Y,Vertex[i].X,Vertex[i].Y,TopLeft.X,TopLeft.Y,BottomRight.X,BottomRight.Y) then
            begin
              Result:=AFFA_BORDER;
              break;
            end;
            //BD
            if isLinesHasIntersection(APoint.X,APoint.Y,Vertex[i].X,Vertex[i].Y,BottomRight.X,TopLeft.Y,TopLeft.X,BottomRight.Y) then
            begin
              Result:=AFFA_BORDER;
              break;
            end;
            //AB
            if isLinesHasIntersection(APoint.X,APoint.Y,Vertex[i].X,Vertex[i].Y,TopLeft.X,TopLeft.Y,BottomRight.X,TopLeft.Y) then
            begin
              Result:=AFFA_BORDER;
              break;
            end;
            //BC
            if isLinesHasIntersection(APoint.X,APoint.Y,Vertex[i].X,Vertex[i].Y,BottomRight.X,TopLeft.Y,BottomRight.X,BottomRight.Y) then
            begin
              Result:=AFFA_BORDER;
              break;
            end;
            //CD
            if isLinesHasIntersection(APoint.X,APoint.Y,Vertex[i].X,Vertex[i].Y,BottomRight.X,BottomRight.Y,TopLeft.X,BottomRight.Y) then
            begin
              Result:=AFFA_BORDER;
              break;
            end;
            //DA
            if isLinesHasIntersection(APoint.X,APoint.Y,Vertex[i].X,Vertex[i].Y,TopLeft.X,BottomRight.Y,TopLeft.X,TopLeft.Y) then
            begin
              Result:=AFFA_BORDER;
              break;
            end;
            APoint:=Vertex[i];
          end; //for

          //SetDeltaToRectPoint(TopLeft, BottomRight, ThisDocument.GetDeltaVertex*-1);

          // Проверка попадает ли зона выбора в периметр объекта
          if (Result=AFFA_OUTSIDE)and(not AllVertexInRect) then
          begin
              if (VertexCount=4) then
              begin
                TmpTopLeft     :=Vertex[0];
                TmpBottomRight :=Vertex[2];
                if PointIn2DRect(TopLeft,TmpTopLeft,TmpBottomRight) then
                  Result:=AFFA_INSIDE
                else if (Result=AFFA_OUTSIDE)and(PointIn2DRect(BottomRight,Vertex[0], Vertex[2])) then
                  Result:=AFFA_INSIDE;

                if Result=AFFA_INSIDE then
                begin
                   MVertx.Item        :=self;
                   MVertx.VertexIndex :=0;
                   MVertx.VertexPos   :=Vertex[0];
                end;
              end;
          end;
      end;
end;

constructor TGraphicFrameLine.Create;
begin
  inherited Create;
  FLineWeight       :=gaLnWtTriple; //gaLnWtDefault  gaLnWtDouble
  AddVertex(0,0,0);
  AddVertex(0,0,0);
  AddVertex(0,0,0);
  AddVertex(0,0,0);
  FSortRangIndex    :=2;
  FTriangleBegin    :=True;
  FTriangleEnd      :=True;
end;

{ TGraphicLandmark }

procedure TGraphicLandmark.SetTimeBegin(AValue: TDateTime);
begin
  if FTimeBegin<>AValue then
     FTimeBegin:=AValue;
  if FTimeEnd<>AValue then
     FTimeEnd:=AValue;
end;

procedure TGraphicLandmark.SetTimeEnd(AValue: TDateTime);
begin
  if FTimeBegin<>AValue then
     FTimeBegin:=AValue;
  if FTimeEnd<>AValue then
     FTimeEnd:=AValue;
end;

procedure TGraphicLandmark.Repaint(Xshift, Yshift, AScaleX, AScaleY,
  AScaleZ: Integer; LogicalDrawing: TLogicalDraw; AStyle: TEntityDrawStyle);
var
  TmpVertex0: TGTFPoint;
  TmpVertex1: TGTFPoint;
  TmpVertex2: TGTFPoint;
  TmpVertex3: TGTFPoint;

  TmpVertexBegin : TGTFPoint;

  TextSizeScale,
  FTextWidth,
  FTextHeight            :integer;
  Doc                    :TGTFDrawDocumentCustom;
  RowItem                :TGTFCOutsetTreeRowItem;
  iGridScale,
  iHalfHeight,
  iQuadHeight,
  X1,Y1,RY2,RY1          :Integer;
  sText                  :String;
begin
  Doc:=GetDocument;
  if VertexCount=4 then
  begin
        FTextWidth:=0;
        FTextHeight:=0;
        iGridScale:=100;
        LogicalDrawing.GetGridScale(iGridScale);

        if edsSelected in AStyle then
          LogicalDrawing.SetStyleDraw(LINETYPE_SELECTED,GetLineWeight(gaLnWtDefault),GetColor(gaHighLight))
        else
          LogicalDrawing.SetStyleDraw(LINETYPE_SOLID,GetLineWeight(gaLnWtDefault),GetColor(FColor));

        TextSizeScale:=AScaleY;
        if TextSizeScale<0 then
           TextSizeScale:=TextSizeScale*-1;

        LogicalDrawing.SetFontStyleDraw(Doc.FFontName, 22*TextSizeScale, []);

        RowItem:=GetRowPoint;

        if RowItem=nil then
        begin
          Abort;
        end;

        RY1:=RowItem.EntityHeight*(AntiLayeringIndex-1);
        RY2:=RowItem.EntityHeight;
        iHalfHeight:=RY2 div 2;
        iQuadHeight:=RY2 div 4;

        TmpVertex0:=Vertex[0];
        TmpVertex1:=Vertex[1];
        TmpVertex2:=Vertex[2];
        TmpVertex3:=Vertex[3];

        TmpVertex0.X  :=GetBeginPoint.X;
        TmpVertex3.X  :=TmpVertex0.X;

        TmpVertex1.X  :=GetEndPoint.X;
        TmpVertex2.X  :=TmpVertex1.X;

        TmpVertex0.Y  :=RowItem.BeginY;
        TmpVertex3.Y  :=TmpVertex0.Y;

        TmpVertex1.Y  :=TmpVertex0.Y+RY2;
        TmpVertex2.Y  :=TmpVertex1.Y;

        //TmpVertex0.Y:=RowItem.BeginY-1+RY2 div 2;

        Vertex[0]:=TmpVertex0;
        Vertex[1]:=TmpVertex1;
        Vertex[2]:=TmpVertex2;
        Vertex[3]:=TmpVertex3;

        //Конвертирование координаты при перемещении курсора
        //or(esEditing in State))
        if (esMoving in State) then
        begin
          TmpVertex0:=GetInteractiveVertex(TmpVertex0);
          TmpVertex1:=GetInteractiveVertex(TmpVertex1);
          TmpVertex2:=GetInteractiveVertex(TmpVertex2);
          TmpVertex3:=GetInteractiveVertex(TmpVertex3);
        end;

        //Вариант 1
        sText:='♦'; //Веха
        LogicalDrawing.GetTextHeight(sText,FTextHeight);
        LogicalDrawing.GetTextWidth(sText,FTextWidth);
        LogicalDrawing.TextDraw(((TmpVertex0.X+(ABS(TmpVertex1.X-TmpVertex0.X)) div 2)*AScaleX)+Xshift,((TmpVertex0.Y+iHalfHeight)*AScaleY)+Yshift, FTextWidth*AscaleX, FTextHeight*AscaleY, 0, sText, gaAttachmentPointMiddleCenter);

        {
        //Вариант 2
        TmpVertexBegin   := TmpVertex0;
        TmpVertexBegin.X := TmpVertex0.X+(ABS(TmpVertex1.X-TmpVertex0.X)) div 2;
        TmpVertexBegin.Y := TmpVertex0.Y+iHalfHeight;

        LogicalDrawing.PolygonDraw(((TmpVertexBegin.X)*AScaleX)+Xshift,((TmpVertexBegin.Y)*AScaleY)+Yshift,[Point(0,((iHalfHeight-3)*-1)),Point(iQuadHeight,0),Point(0,iHalfHeight-3),Point(iQuadHeight*-1,0)]);
        }

        //Текст
        LogicalDrawing.SetStyleDraw(LINETYPE_SOLID,GetLineWeight(gaLnWtDefault),GetColor(gaDefault)); //
        LogicalDrawing.SetFontStyleDraw(Doc.FFontName, Doc.FFontSize*TextSizeScale, []);

        sText:=FText+' '+FTextSecondLine;
        LogicalDrawing.GetTextHeight(sText,FTextHeight);
        LogicalDrawing.GetTextWidth(sText,FTextWidth);

        X1          :=TmpVertex0.X+FTextHeight div 2; //отступ на высоту буквы

        Y1          :=TmpVertex0.Y-2;
        LogicalDrawing.TextDraw((X1*AScaleX)+Xshift+5,(Y1*AScaleY)+Yshift, FTextWidth*AscaleX, (FTextHeight+1)*AscaleY, 0, FText, gaAttachmentPointMiddleLeft);

        if iGridScale>=120 then
        begin
          Y1          :=TmpVertex0.Y+FTextHeight+2;
          LogicalDrawing.TextDraw((X1*AScaleX)+Xshift+5,(Y1*AScaleY)+Yshift, FTextWidth*AscaleX, (FTextHeight+1)*AscaleY, 0, FTextSecondLine, gaAttachmentPointMiddleLeft);
        end;
  end;
end;

procedure TGraphicLandmark.RepaintVertex(LogicalDrawing: TLogicalDraw);
begin
  //inherited RepaintVertex(LogicalDrawing);
end;

function TGraphicLandmark.GetSelect(TopLeft, BottomRight: TGTFPoint;
  AllVertexInRect: Boolean): Integer;
var
  MVertx: TModifyVertex;
begin
  Result:=GetSelect(TopLeft, BottomRight,AllVertexInRect,MVertx);
end;

function TGraphicLandmark.GetSelect(TopLeft, BottomRight: TGTFPoint;
  AllVertexInRect: Boolean; var MVertx: TModifyVertex): Integer;
var
  i,CountVertexInRect:integer;
  TmpTopLeft, TmpBottomRight: TGTFPoint;
  APoint: TGTFPoint;
begin

    Result:=AFFA_OUTSIDE; //Вне периметра

    // Проверка попадают ли вершины в зону выбора
    CountVertexInRect:=0;

    //SetDeltaToRectPoint(TopLeft, BottomRight, ThisDocument.GetDeltaVertex);

    // Проверка попадает ли базовая точка в зону выбора
    if (VertexCount>0) then
    begin
        if PointIn2DRect(Vertex[0], TopLeft, BottomRight) then
        begin
          CountVertexInRect  :=CountVertexInRect+1;
          MVertx.Item        :=self;
          MVertx.VertexIndex :=0;
          MVertx.VertexPos   :=Vertex[MVertx.VertexIndex];
        end;
        if (not AllVertexInRect)and(CountVertexInRect>0) then
        begin
          Result:=AFFA_BASEPOINT;
        end;
    end;

    // Проверка попадают ли вершины в зону выбора
    for I := 1 to VertexCount - 1 do
    begin
        if PointIn2DRect(Vertex[i],TopLeft, BottomRight) then
        begin
          CountVertexInRect  :=CountVertexInRect+1;
          MVertx.Item        :=self;
          MVertx.VertexIndex :=i;
          MVertx.VertexPos   :=Vertex[MVertx.VertexIndex];
        end;
    end;

    if (AllVertexInRect)and(CountVertexInRect=VertexCount)and(VertexCount>0)and(Result=AFFA_OUTSIDE) then
    begin
      Result:=AFFA_VERTEX;
    end
    else if (not AllVertexInRect)and(CountVertexInRect>0)and(Result=AFFA_OUTSIDE) then
    begin
      Result:=AFFA_VERTEX;
    end;

    // Проверка попадают ли промежуточные точки в зону выбора

      if (not AllVertexInRect)and(VertexCount>=1)and(Result<>AFFA_VERTEX)and(Result<>AFFA_BASEPOINT) then
      begin

          APoint:=Vertex[0];
          for I := 1 to VertexCount - 1 do
          begin
            //AC
            if isLinesHasIntersection(APoint.X,APoint.Y,Vertex[i].X,Vertex[i].Y,TopLeft.X,TopLeft.Y,BottomRight.X,BottomRight.Y) then
            begin
              Result:=AFFA_BORDER;
              break;
            end;
            //BD
            if isLinesHasIntersection(APoint.X,APoint.Y,Vertex[i].X,Vertex[i].Y,BottomRight.X,TopLeft.Y,TopLeft.X,BottomRight.Y) then
            begin
              Result:=AFFA_BORDER;
              break;
            end;
            //AB
            if isLinesHasIntersection(APoint.X,APoint.Y,Vertex[i].X,Vertex[i].Y,TopLeft.X,TopLeft.Y,BottomRight.X,TopLeft.Y) then
            begin
              Result:=AFFA_BORDER;
              break;
            end;
            //BC
            if isLinesHasIntersection(APoint.X,APoint.Y,Vertex[i].X,Vertex[i].Y,BottomRight.X,TopLeft.Y,BottomRight.X,BottomRight.Y) then
            begin
              Result:=AFFA_BORDER;
              break;
            end;
            //CD
            if isLinesHasIntersection(APoint.X,APoint.Y,Vertex[i].X,Vertex[i].Y,BottomRight.X,BottomRight.Y,TopLeft.X,BottomRight.Y) then
            begin
              Result:=AFFA_BORDER;
              break;
            end;
            //DA
            if isLinesHasIntersection(APoint.X,APoint.Y,Vertex[i].X,Vertex[i].Y,TopLeft.X,BottomRight.Y,TopLeft.X,TopLeft.Y) then
            begin
              Result:=AFFA_BORDER;
              break;
            end;
            APoint:=Vertex[i];
          end; //for

          //SetDeltaToRectPoint(TopLeft, BottomRight, ThisDocument.GetDeltaVertex*-1);

          // Проверка попадает ли зона выбора в периметр объекта
          if (Result=AFFA_OUTSIDE)and(not AllVertexInRect) then
          begin
              if (VertexCount=4) then
              begin
                TmpTopLeft     :=Vertex[0];
                TmpBottomRight :=Vertex[2];
                if PointIn2DRect(TopLeft,TmpTopLeft,TmpBottomRight) then
                  Result:=AFFA_INSIDE
                else if (Result=AFFA_OUTSIDE)and(PointIn2DRect(BottomRight,Vertex[0], Vertex[2])) then
                  Result:=AFFA_INSIDE;

                if Result=AFFA_INSIDE then
                begin
                   MVertx.Item        :=self;
                   MVertx.VertexIndex :=0;
                   MVertx.VertexPos   :=Vertex[0];
                end;
              end;
          end;
      end;
end;

constructor TGraphicLandmark.Create;
begin
  inherited Create;
  FLineWeight       :=gaLnWtTriple; //gaLnWtDefault  gaLnWtDouble
  AddVertex(0,0,0);
  AddVertex(0,0,0);
  AddVertex(0,0,0);
  AddVertex(0,0,0);
  FSortRangIndex    :=1;
end;

{ TWorkSpaceCustom }

function TWorkSpaceCustom.GetDocument: TGTFDrawDocumentCustom;
begin
  if Assigned(FOnGetDocumentEvent) then
      Result:=FOnGetDocumentEvent()
  else
      Result:=nil;
end;

constructor TWorkSpaceCustom.Create;
begin
    inherited Create;
    FOnGetDocumentEvent       :=nil;
    FSelectedEntityList       :=nil;
    FEntityList               :=TEntityList.Create;
    FEntityList.ID            :=ENTITYLIST_ID;
    FEntityList.FModelSpace   :=TWorkSpace(Self);

    FEntityListFilteredDraw   :=TList.Create;

    FBottomRight              :=SetNullToFloatPoint;
    FTopLeft                  :=SetNullToFloatPoint;
end;

destructor TWorkSpaceCustom.Destroy;
begin
     FSelectedEntityList:=nil;
     FEntityListFilteredDraw.Free;
     FEntityList.Free;
     inherited Destroy;
end;

procedure TWorkSpaceCustom.Repaint(Xshift,Yshift,AScaleX,AScaleY,AScaleZ:Integer; LogicalDrawing: TLogicalDraw; AStyle:TEntityDrawStyle);
begin
     FEntityList.Repaint(Xshift,Yshift,AScaleX,AScaleY,AScaleZ,LogicalDrawing,AStyle);
end;

procedure TWorkSpaceCustom.RepaintVertex(LogicalDrawing: TLogicalDraw);
begin
     FEntityList.RepaintVertex(LogicalDrawing);
end;

procedure TWorkSpaceCustom.DeselectAll;
begin
  if Assigned(ThisDocument) then
     ThisDocument.DeselectAll;
end;

function TWorkSpaceCustom.GetColor(AColor: TgaColor): TgaColor;
begin
   Result:=AColor;
end;

function TWorkSpaceCustom.GetLineWeight(LineWeight: TgaLineWeight): TgaLineWeight;
begin
      Result:=LineWeight;
end;

procedure TWorkSpaceCustom.GetRectVertex(var ATopLeft, ABottomRight: TGTFPoint);
begin
  GetEntityListRectVertex(FEntityList,ATopLeft,ABottomRight);
end;

procedure TWorkSpaceCustom.MoveEntityGroup(AOwnerGroup: TEntityID; APoint: TGTFPoint);
var
   i,c:integer;
   dX,dY,dZ:Integer;
   NewVertex: TGTFPoint;
begin
   dX:=0;
   dY:=0;
   dZ:=0;
   c:=0;
   for i:=0 to Objects.Count-1 do
   begin
      if Objects.Items[i].ID=AOwnerGroup then
      begin
         dX:=APoint.X-Objects.Items[i].VertexAxleX[0];
         dY:=APoint.Y-Objects.Items[i].VertexAxleY[0];
         dZ:=APoint.Z-Objects.Items[i].VertexAxleZ[0];
         Objects.Items[i].MoveVertex(0,APoint);
         inc(c);
         break;
      end;
   end;
   if c>0 then
   begin
   for i:=0 to Objects.Count-1 do
   begin
      if Objects.Items[i].GroupOwner=AOwnerGroup then
      begin
         NewVertex.X:=Objects.Items[i].VertexAxleX[0]+dX;
         NewVertex.Y:=Objects.Items[i].VertexAxleY[0]+dY;
         NewVertex.Z:=Objects.Items[i].VertexAxleZ[0]+dZ;
         Objects.Items[i].MoveVertex(0,NewVertex);
      end;
   end;
   end;
end;

{ TGTFPointList }

function TGTFPointList.GetCount: Integer;
begin
     Result:=Flist.Count;
end;

function TGTFPointList.GetPoint(Index: Integer): TGTFPoint;
begin
try
     Result:=TGTFPoint(PGTFPoint(FList.Items[Index])^);
except
     abort;
end;
end;

function TGTFPointList.NewPoint(X, Y, Z: Integer): PGTFPoint;
var
  NPoint: PGTFPoint;
begin
  // Выделяем память под новую точку
  New(NPoint);
  NPoint^.X := X;
  NPoint^.Y := Y;
  NPoint^.Z := Z;
  Result    := NPoint;
end;

procedure TGTFPointList.SetPoint(Index: Integer; const Value: TGTFPoint);
begin
try
  PGTFPoint(FList.Items[Index])^:=Value;
except

end;
end;

constructor TGTFPointList.Create;
begin
  inherited Create;
  FList:=TList.Create;
end;

destructor TGTFPointList.Destroy;
var
  i: Integer;
begin
  // Перед уничтожением списка, освобождаем память
  for i := Count - 1 downto 0  do Delete(i);
  FList.Free;
  inherited Destroy;
end;

procedure TGTFPointList.Add(X, Y, Z: Integer);
begin
     FList.Add(NewPoint(X,Y,Z));
end;

procedure TGTFPointList.Insert(Index: Integer; X, Y, Z: Integer);
begin
  FList.Insert(Index,NewPoint(X,Y,Z));
end;

procedure TGTFPointList.Delete(Index: Integer);
begin
  Dispose(PGTFPoint(FList.items[index]));
  FList.Delete(Index);
end;

function TGTFPointList.Extract(Index: Integer): PGTFPoint;
var
  APoint: PGTFPoint;
begin
  APoint:=PGTFPoint(FList.items[index]);
  FList.Delete(Index);
  Result:=APoint;
end;


{ TEntityBasic }

constructor TEntityBasic.Create;
begin
     inherited Create;
     FID                 :='';
     FOnGetDocumentEvent :=nil;
     FState              :=[esCreating];
     FBlocked            :=false;
     FLineWeight         :=gaLnWtDefault;
     FColor              :=gaDefault;
     FLayerName          :='0';
     FTag                :=0;
     FData               :=nil;
     FDBRecordID         :=0;
     FDBRecordGroup      :='';
end;

procedure TEntityBasic.Created;
begin
  if ID='' then
     raise Exception.Create('Не задан ID')
  else
     FState:=[esNone];
end;

destructor TEntityBasic.Destroy;
begin
    inherited Destroy;
end;

procedure TEntityBasic.BeginUpdate;
begin
     FBlocked:=true;
end;

procedure TEntityBasic.EndUpdate;
begin
     FBlocked:=false;
end;

function TEntityBasic.GetColor(AColor: TgaColor): TgaColor;
begin
try
    Result:=AColor;
except

end;
end;

function TEntityBasic.GetLineWeight(ALineWeight: TgaLineWeight): TgaLineWeight;
begin
try
    if (ALineWeight=gaLnWtDefault)then
    begin
      Result:=FParentList.FModelSpace.GetLineWeight(ALineWeight);
    end
    else begin
      Result:=ALineWeight;
    end;
except

end;
end;

function TEntityBasic.GetColor: TgaColor;
begin
  Result:=FColor;
end;

function TEntityBasic.GetLineWeight: TgaLineWeight;
begin
  Result:=FLineWeight;
end;

{ TEntity }

procedure TEntity.AddVertex(X, Y, Z: Integer);
begin
  FVertex.Add(x,y,z);
  if assigned(FParentList) then
  FParentList.ChangeCordVertex(FloatPoint(x,y,z));
end;

constructor TEntity.Create;
begin
     inherited Create;
     FVertex   :=TGTFPointList.Create;
     FActionVertexDelta.X:=0;
     FActionVertexDelta.Y:=0;
     FActionVertexDelta.Z:=0;
     FActionVertexIndex:=-1;
end;

procedure TEntity.DeleteVertex(Index: Integer);
begin
  FVertex.Delete(Index);
end;

destructor TEntity.Destroy;
begin
  FVertex.Free;
  inherited Destroy;
end;

procedure TEntity.GetRectVertex(var ATopLeft, ABottomRight: TGTFPoint);
var
  i:integer;
  tmpTopLeft,
  tmpBottomRight: TGTFPoint;
begin
  tmpTopLeft:=SetNullToFloatPoint;
  tmpBottomRight:=SetNullToFloatPoint;

  for i:=0 to VertexCount-1 do
  begin
       if (Vertex[i].X)<tmpTopLeft.X then tmpTopLeft.X:=(Vertex[i].X);
       if (Vertex[i].Y)>tmpTopLeft.Y then tmpTopLeft.Y:=(Vertex[i].Y);
       if (Vertex[i].X)>tmpBottomRight.X then tmpBottomRight.X:=(Vertex[i].X);
       if (Vertex[i].Y)<tmpBottomRight.Y then tmpBottomRight.Y:=(Vertex[i].Y);
  end;
  ATopLeft:=tmpTopLeft;
  ABottomRight:=tmpBottomRight;
end;

function TEntity.GetSelect(TopLeft, BottomRight: TGTFPoint;
  AllVertexInRect: Boolean; var MVertx: TModifyVertex): Integer;
var
  i,CountVertexInRect:integer;
begin
  SetDeltaToRectPoint(TopLeft, BottomRight, ThisDocument.GetDeltaVertex);

  Result:=AFFA_OUTSIDE; //Вне периметра
  CountVertexInRect:=0;
  for I := 0 to VertexCount - 1 do
  begin
      if PointIn2DRect(Vertex[i],TopLeft, BottomRight) then
      begin
        CountVertexInRect:=CountVertexInRect+1;
        MVertx.Item:=self;
        MVertx.VertexIndex:=i;
        MVertx.VertexPos:=Vertex[MVertx.VertexIndex];
      end;
  end;

  if (AllVertexInRect)and(CountVertexInRect=VertexCount)and(VertexCount>0) then
    Result:=AFFA_VERTEX
  else if (not AllVertexInRect)and(CountVertexInRect>0) then
    Result:=AFFA_VERTEX;
end;

function TEntity.GetSelect(TopLeft, BottomRight: TGTFPoint;
  AllVertexInRect: Boolean): Integer;
var
  MVertx: TModifyVertex;
begin
  Result:=GetSelect(TopLeft, BottomRight,AllVertexInRect,MVertx);
end;

function TEntity.GetVertex(Index: Integer): TGTFPoint;
begin
  Result:=FVertex.Items[index];
end;

function TEntity.GetVertexAxleX(Index: Integer): Integer;
begin
  Result:=Vertex[Index].X;
end;

function TEntity.GetVertexAxleY(Index: Integer): Integer;
begin
  Result:=Vertex[Index].Y;
end;

function TEntity.GetVertexAxleZ(Index: Integer): Integer;
begin
  Result:=Vertex[Index].Z;
end;

function TEntity.GetDocument: TGTFDrawDocumentCustom;
begin
  if Assigned(FOnGetDocumentEvent) then
      Result:=FOnGetDocumentEvent()
  else
      Result:=nil;
end;

procedure TEntity.SetColor(AValue: TgaColor);
begin
  if FColor=AValue then Exit;
  //AValue:=(AValue-gaMaxColors*(AValue div gaMaxColors));
  FColor:=AValue;
end;

function TEntity.GetVertexCount: Integer;
begin
  Result:=FVertex.Count;
end;

procedure TEntity.InsertVertex(Index: Integer; X, Y, Z: Integer);
begin
  FVertex.Insert(Index,X,Y,Z);
  if assigned(FParentList) then
  FParentList.ChangeCordVertex(FloatPoint(x,y,z));
end;

procedure TEntity.MoveVertex(Index:integer; NewVertex: TGTFPoint);
begin
  if Index>-1 then
  begin
        VertexAxleX[Index]:=NewVertex.X;
        VertexAxleY[Index]:=NewVertex.Y;
        VertexAxleZ[Index]:=NewVertex.Z;
  end;
end;

procedure TEntity.Repaint(LogicalDrawing: TLogicalDraw;
  Style: TEntityDrawStyle);
begin
  Repaint(0,0,1,1,1,LogicalDrawing,Style);
end;

procedure TEntity.SetVertex(Index: Integer; const Value: TGTFPoint);
begin
  FVertex.Items[Index]:=Value;
  if assigned(FParentList) then
  FParentList.ChangeCordVertex(FVertex.Items[Index]);
end;

procedure TEntity.SetVertexAxleX(Index: Integer; const Value: Integer);
var
  A:TGTFPoint;
begin
  A:=FVertex.Items[Index];
  A.X:=Value;
  FVertex.Items[Index]:=A;
end;

procedure TEntity.SetVertexAxleY(Index: Integer; const Value: Integer);
var
  A:TGTFPoint;
begin
  A:=FVertex.Items[Index];
  A.Y:=Value;
  FVertex.Items[Index]:=A;
end;

procedure TEntity.SetVertexAxleZ(Index: Integer; const Value: Integer);
var
  A:TGTFPoint;
begin
  A:=FVertex.Items[Index];
  A.Z:=Value;
  FVertex.Items[Index]:=A;
end;

function TEntity.GetInteractiveVertex(AVertex:TGTFPoint): TGTFPoint;
var
  x:Integer;
  CurCord,
  NewCord :TGTFPoint;
begin
      x:=ActionVertexDelta.X;
      x:=x+ActionVertexDelta.Y;
      x:=x+ActionVertexDelta.Z;
      if (x<>0) then
      begin
          CurCord    :=AVertex;
          NewCord.Y  :=CurCord.Y+ActionVertexDelta.Y;
          NewCord.X  :=CurCord.X+ActionVertexDelta.X;
          NewCord.Z  :=CurCord.Z+ActionVertexDelta.Z;
          Result:=NewCord;
      end
      else begin
          Result:=AVertex;
      end;
end;

{ TGraphicPolyline }

function TGraphicPolyline.GetClosed: Boolean;
begin
  Result:=FClosed;
end;

procedure TGraphicPolyline.SetClosed(AValue: Boolean);
begin
  if FClosed<> AValue then
     FClosed:=AValue;
end;

procedure TGraphicPolyline.Draw(APoints: TPointsArray; AClosed: Boolean);
var
  i:integer;
begin
    for i:=0 to Length(APoints)-1 do
    begin
      AddVertex(APoints[i].X,APoints[i].Y,APoints[i].Z);
    end;

    if (AClosed)and(Length(APoints)>3)then
      FClosed:=true
    else
      FClosed:=false;
end;

procedure TGraphicPolyline.Repaint(Xshift,Yshift,AScaleX,AScaleY,AScaleZ:Integer; LogicalDrawing: TLogicalDraw; AStyle:TEntityDrawStyle);
var
  i:integer;
  TmpVertex,
  fpoint:TGTFPoint;
begin
  if VertexCount>1 then
  begin
      if edsSelected in AStyle then
        LogicalDrawing.SetStyleDraw(LINETYPE_SELECTED,GetLineWeight(FLineWeight),GetColor(FColor))
      else
        LogicalDrawing.SetStyleDraw(LINETYPE_SOLID,GetLineWeight(FLineWeight),GetColor(FColor));

    if ((esMoving in State)or(esEditing in State))and(ActionVertexIndex=0) then
      fpoint:=GetInteractiveVertex(Vertex[0]) //Конвертирование координаты при перемещении курсора
    else
      fpoint:=Vertex[0];

    for i:=1 to VertexCount-1 do
    begin
      if ((esMoving in State)or(esEditing in State))and(ActionVertexIndex=i) then
        TmpVertex:=GetInteractiveVertex(Vertex[i]) //Конвертирование координаты при перемещении курсора
      else
        TmpVertex:=Vertex[i];

      LogicalDrawing.LineDraw((fpoint.X*AScaleX)+Xshift,(fpoint.Y*AScaleY)+Yshift,(TmpVertex.X*AScaleX)+Xshift,(TmpVertex.Y*AScaleY)+Yshift);

        fpoint:=TmpVertex;
    end;


    if (FClosed)and (VertexCount>2) then
    begin
      if ((esMoving in State)or(esEditing in State))and(ActionVertexIndex=0) then
        TmpVertex:=GetInteractiveVertex(Vertex[0]) //Конвертирование координаты при перемещении курсора
      else
        TmpVertex:=Vertex[0];

      LogicalDrawing.LineDraw((fpoint.X*AScaleX)+Xshift,(fpoint.Y*AScaleY)+Yshift,(TmpVertex.X*AScaleX)+Xshift,(TmpVertex.Y*AScaleY)+Yshift);
    end;
  end;
end;

procedure TGraphicPolyline.RepaintVertex(LogicalDrawing: TLogicalDraw);
var
  i:integer;
  TmpVertex:TGTFPoint;
begin
  if (VertexCount>0) then
  begin
    for i:=0 to VertexCount-1 do
    begin
      if ((esMoving in State)or(esEditing in State))and(ActionVertexIndex=i) then
        TmpVertex:=GetInteractiveVertex(Vertex[i]) //Конвертирование координаты при перемещении курсора
      else
        TmpVertex:=Vertex[i];

      LogicalDrawing.VertexDraw(TmpVertex.X,TmpVertex.Y,VERTEXMARKER_VERTEX);
    end;
  end;
end;

{ TGraphicConnectionline }

function TGraphicConnectionline.GetBeginVertex: TGTFPoint;
var
  ItemA     :TEntity;
  tmpVertex :TGTFPoint;
  x         :integer;
begin
  Result.X:=0;
  Result.Y:=0;
  Result.Z:=0;

  ItemA:=ThisDocument.FModelSpace.Objects.GetEntityByID(FBeginEntityID);
  if Assigned(ItemA)and(ItemA.VertexCount=4) then
  begin
      tmpVertex :=ItemA.Vertex[1];

      //Result.Y  :=tmpVertex.Y+((ItemA.Vertex[2].Y-tmpVertex.Y)div 2); //середина
      x           :=((ItemA.Vertex[2].Y-tmpVertex.Y)div 6);
      Result.Y  :=tmpVertex.Y+x*2;
      Result.X  :=tmpVertex.X-x*2;
      Result.Z  :=0;

      if esMoving in ItemA.State then
        Result:=ItemA.GetInteractiveVertex(Result);
  end
  else if (not Assigned(ItemA)) then
  begin
     Result.X:=0;
     Result.Y:=0;
     Result.Z:=0;
  end;
end;

function TGraphicConnectionline.GetEndVertex: TGTFPoint;
var
  ItemA     :TEntity;
  tmpVertex :TGTFPoint;
  x         :integer;
begin
  Result.X:=0;
  Result.Y:=0;
  Result.Z:=0;

  ItemA:=ThisDocument.FModelSpace.Objects.GetEntityByID(FEndEntityID);
  if Assigned(ItemA)and(ItemA.VertexCount>0) then
  begin

      tmpVertex :=ItemA.Vertex[0];
      //Result.Y  :=tmpVertex.Y+((ItemA.Vertex[3].Y-tmpVertex.Y)div 2); //середина
      x         :=((ItemA.Vertex[3].Y-tmpVertex.Y)div 6);
      Result.Y  :=ItemA.Vertex[3].Y-x*2;
      Result.X  :=tmpVertex.X+x*2;
      Result.Z  :=0;

      if esMoving in ItemA.State then
        Result:=ItemA.GetInteractiveVertex(Result);
  end
  else if (not Assigned(ItemA)) then
  begin
     Result.X:=0;
     Result.Y:=0;
     Result.Z:=0;
  end;
end;

procedure TGraphicConnectionline.Draw(APoints: TPointsArray; AClosed: Boolean);
var
  i:integer;
begin
    for i:=0 to Length(APoints)-1 do
    begin
      AddVertex(APoints[i].X,APoints[i].Y,APoints[i].Z);
    end;
end;

procedure TGraphicConnectionline.Repaint(Xshift, Yshift, AScaleX, AScaleY,
  AScaleZ: Integer; LogicalDrawing: TLogicalDraw; AStyle: TEntityDrawStyle);
var
  i        :integer;
  Points   :TPointsArray;
  fpoint   :TGTFPoint;
begin

    if edsSelected in AStyle then
       LogicalDrawing.SetStyleDraw(LINETYPE_SELECTED,GetLineWeight(gaLnWtDefault),GetColor(FColor))
    else
       LogicalDrawing.SetStyleDraw(LINETYPE_SOLID,GetLineWeight(gaLnWtDefault),GetColor(FColor));

    GetLinePointsVertex(Points);
    if Length(Points)>1 then
    begin
      {
      fpoint:=Points[0];
      for i:=0 to high(Points) do
      begin
          LogicalDrawing.LineDraw((fpoint.X*AScaleX)+Xshift,(fpoint.Y*AScaleY)+Yshift,(Points[i].X*AScaleX)+Xshift,(Points[i].Y*AScaleY)+Yshift);
          fpoint:=Points[i];
      end;
      }
      LogicalDrawing.LineSDraw(Points[0].X,Points[0].Y,Points[1].X,Points[1].Y,Points[2].X,Points[2].Y,Points[3].X,Points[3].Y);

      LogicalDrawing.SetStyleDraw(LINETYPE_SOLID,GetLineWeight(gaLnWtTriple),GetColor(FColor));

      fpoint:=Points[0];
      LogicalDrawing.CircleDraw((fpoint.X*AScaleX)+Xshift,(fpoint.Y*AScaleY)+Yshift,2);

      i:=high(Points);
      fpoint:=Points[i];
      LogicalDrawing.CircleDraw((fpoint.X*AScaleX)+Xshift,(fpoint.Y*AScaleY)+Yshift,2);

    end;

end;

procedure TGraphicConnectionline.RepaintVertex(LogicalDrawing: TLogicalDraw);
var
  i:integer;
begin
  if VertexCount>0 then
  begin
    for i:=0 to VertexCount-1 do
    begin
      LogicalDrawing.VertexDraw(Vertex[i].X,Vertex[i].Y,VERTEXMARKER_VERTEX);
    end;
  end;
end;

function TGraphicConnectionline.GetSelect(TopLeft, BottomRight: TGTFPoint;
  AllVertexInRect: Boolean; var MVertx: TModifyVertex): Integer;
var
  APoint,BPoint:TGTFPoint;
  i,PointsCount,CountVertexInRect:integer;
  Points :TPointsArray;
  bOnePointRect:boolean;
begin
  //Объект нельзя выбрать за первую и последную точку

  SetDeltaToRectPoint(TopLeft, BottomRight, ThisDocument.GetDeltaVertex);
  bOnePointRect:=False;
  Result:=AFFA_OUTSIDE; //Вне периметра

  if (TopLeft.X=BottomRight.X)and
  ((TopLeft.Y=BottomRight.Y))and
  ((TopLeft.Z=BottomRight.Z)) then
  begin
     bOnePointRect:=True;
  end;

  GetLinePointsVertex(Points);

  CountVertexInRect:=0;
  PointsCount:=high(Points);
  for I := 1 to PointsCount-1 do
  begin
      if (i>0)and(bOnePointRect)then
      begin
         //Проверка на линии
         //ThisDocument.GetDeltaVertex
      end;
      if PointIn2DRect(Points[i],TopLeft, BottomRight) then
      begin
        CountVertexInRect:=CountVertexInRect+1;
        {
        if not((i=0)or(i=c)) then
        begin
          MVertx.Item:=self;
          MVertx.VertexIndex:=-1;
          MVertx.VertexPos:=Points[i];
        end;
        }
      end;
  end;

  if (AllVertexInRect)and(CountVertexInRect=VertexCount)and(VertexCount>0)and(Result=AFFA_OUTSIDE) then
  begin
    Result:=AFFA_VERTEX;
  end
  else if (not AllVertexInRect)and(CountVertexInRect>0)and(Result=AFFA_OUTSIDE) then
  begin
    Result:=AFFA_VERTEX;
  end;

  // Проверка попадают ли промежуточные точки в зону выбора
    //ABCD
    if (not AllVertexInRect)and(PointsCount>1)and(Result<>AFFA_VERTEX) then
    begin
    APoint:=Points[0];
    for I := 1 to PointsCount do
    begin
      BPoint:=Points[i];
      //AC
      if isLinesHasIntersection(APoint.X,APoint.Y,BPoint.X,BPoint.Y,TopLeft.X,TopLeft.Y,BottomRight.X,BottomRight.Y) then
      begin
        Result:=AFFA_BORDER;
        break;
      end;
      //BD
      if isLinesHasIntersection(APoint.X,APoint.Y,BPoint.X,BPoint.Y,BottomRight.X,TopLeft.Y,TopLeft.X,BottomRight.Y) then
      begin
        Result:=AFFA_BORDER;
        break;
      end;
      //AB
      if isLinesHasIntersection(APoint.X,APoint.Y,BPoint.X,BPoint.Y,TopLeft.X,TopLeft.Y,BottomRight.X,TopLeft.Y) then
      begin
        Result:=AFFA_BORDER;
        break;
      end;
      //BC
      if isLinesHasIntersection(APoint.X,APoint.Y,BPoint.X,BPoint.Y,BottomRight.X,TopLeft.Y,BottomRight.X,BottomRight.Y) then
      begin
        Result:=AFFA_BORDER;
        break;
      end;
      //CD
      if isLinesHasIntersection(APoint.X,APoint.Y,BPoint.X,BPoint.Y,BottomRight.X,BottomRight.Y,TopLeft.X,BottomRight.Y) then
      begin
        Result:=AFFA_BORDER;
        break;
      end;
      //DA
      if isLinesHasIntersection(APoint.X,APoint.Y,BPoint.X,BPoint.Y,TopLeft.X,BottomRight.Y,TopLeft.X,TopLeft.Y) then
      begin
        Result:=AFFA_BORDER;
        break;
      end;
      APoint:=BPoint;
    end;

   end;
end;

procedure TGraphicConnectionline.GetLinePointsVertex(var APoints: TPointsArray);
var
  iStyle,
  i,c,n    :integer;
  spoint,
  fpoint   :TGTFPoint;
begin
 iStyle:=3;

 {
  0- прямая линия
  1- горизонтальная
  2- вертикальная
  3- автовыбор горизонтальной и вертикальной
 }

 if iStyle=3 then
 begin
    fpoint:=GetBeginVertex;
    spoint:=GetEndVertex;

    if abs(spoint.X-fpoint.X)>abs(spoint.Y-fpoint.Y) then
    begin
       iStyle:=1;
    end
    else begin
       iStyle:=2;
    end;
 end;

 if iStyle=0 then
 begin
    c:=Length(APoints);
    n:=c+1;
    SetLength(APoints,n);
    APoints[c]:=GetBeginVertex;


    for i:=0 to VertexCount-1 do
    begin
        c:=Length(APoints);
        n:=c+1;
        SetLength(APoints,n);
        APoints[c]:=Vertex[i];
    end;

    c:=Length(APoints);
    n:=c+1;
    SetLength(APoints,n);
    APoints[c]:=GetEndVertex;

 end
 else if iStyle=1 then  //горизонтально
 begin

   c:=Length(APoints);
   n:=c+1;
   SetLength(APoints,n);
   APoints[c]:=GetBeginVertex;
   fpoint:=APoints[c];

   for i:=0 to VertexCount-1 do
   begin
       c:=Length(APoints);
       n:=c+1;
       SetLength(APoints,n);
       APoints[c]:=Vertex[i];
       fpoint:=APoints[c];
   end;

   spoint:=GetEndVertex;

   if ((fpoint.X<>spoint.X)And(fpoint.Y<>spoint.Y)) then
   begin
       c:=Length(APoints);
       n:=c+1;
       SetLength(APoints,n);
       APoints[c].X:=fpoint.X+((spoint.X-fpoint.X) div 2);
       APoints[c].Y:=fpoint.Y;
       APoints[c].Z:=0;

       c:=Length(APoints);
       n:=c+1;
       SetLength(APoints,n);
       APoints[c].X:=fpoint.X+((spoint.X-fpoint.X) div 2);
       APoints[c].Y:=spoint.Y;
       APoints[c].Z:=0;
   end;

   c:=Length(APoints);
   n:=c+1;
   SetLength(APoints,n);
   APoints[c]:=spoint;
 end
 else if iStyle=2 then  //вертикально
 begin

   c:=Length(APoints);
   n:=c+1;
   SetLength(APoints,n);
   APoints[c]:=GetBeginVertex;
   fpoint:=APoints[c];

   for i:=0 to VertexCount-1 do
   begin
       c:=Length(APoints);
       n:=c+1;
       SetLength(APoints,n);
       APoints[c]:=Vertex[i];
       fpoint:=APoints[c];
   end;

   spoint:=GetEndVertex;

   if ((fpoint.X<>spoint.X)And(fpoint.Y<>spoint.Y)) then
   begin
             c:=Length(APoints);
             n:=c+1;
             SetLength(APoints,n);
             APoints[c].X:=fpoint.X;
             APoints[c].Y:=fpoint.Y+((spoint.y-fpoint.y) div 2);
             APoints[c].Z:=0;

             c:=Length(APoints);
             n:=c+1;
             SetLength(APoints,n);
             APoints[c].X:=spoint.X;
             APoints[c].Y:=fpoint.Y+((spoint.y-fpoint.y) div 2);
             APoints[c].Z:=0;
   end;

   c:=Length(APoints);
   n:=c+1;
   SetLength(APoints,n);
   APoints[c]:=spoint;
 end;
end;

constructor TGraphicConnectionline.Create;
begin
  inherited Create;
end;

{ TEntityList }

procedure TEntityList.SetEntityLinkVar(AEntity: TEntity);
begin
  AEntity.ParentList:=Self;
  AEntity.FOnGetDocumentEvent:=FModelSpace.FOnGetDocumentEvent;
end;

function TEntityList.Add(AParentID: TEntityID): TEntity;
var
  AEntity:TEntity;
begin
  AEntity:=TEntity.Create;
  FList.Add(AEntity);
  SetEntityLinkVar(AEntity);
  Result:=AEntity;
end;

procedure TEntityList.Add(AEntity: TEntity);
begin
  FList.Add(AEntity);
  SetEntityLinkVar(AEntity);
end;

constructor TEntityList.Create;
begin
  inherited Create;
  FList:=TList.Create;
end;

procedure TEntityList.Delete(Index: Integer);
var
  i:integer;
begin
  if Index<Count then
  begin
      Items[Index].Free;
      FList.Delete(Index);
  end
  else
     Abort;
end;

destructor TEntityList.Destroy;
begin
  Clear;
  FList.Free;
  inherited Destroy;
end;

function TEntityList.GetCount: Integer;
begin
  Result:= FList.Count;
end;

function TEntityList.GetItem(Index: Integer): TEntity;
begin
  Result:=TEntity(FList.Items[Index]);
end;

procedure TEntityList.ChangeCordVertex(const AVertCord:TGTFPoint);
begin
      //Реализуется в потомках
      {
      if FModelSpace.FTopLeft.X>AVertCord.X then FModelSpace.FTopLeft.X:=AVertCord.X;
      if Data.Ymin>APoint.Y then Data.Ymin:=APoint.Y;
      if Data.Zmin>APoint.Z then Data.Zmin:=APoint.Z;

      if Data.Xmax<APoint.X then Data.Xmax:=APoint.X;
      if Data.Ymax<APoint.Y then Data.Ymax:=APoint.Y;
      if Data.Zmax<APoint.Z then Data.Zmax:=APoint.Z;
      }
end;

procedure TEntityList.Insert(Index: Integer; AEntity: TEntity);
begin
   FList.Insert(Index,AEntity);
   SetEntityLinkVar(AEntity);
end;

procedure TEntityList.Repaint(Xshift,Yshift,AScaleX,AScaleY,AScaleZ:Integer; LogicalDrawing: TLogicalDraw; AStyle:TEntityDrawStyle);
var
  i,index:integer;
  Item:TEntity;
begin
  for I := 0 to Count - 1 do
  begin
     Item         :=Items[i];

      if Assigned(FModelSpace.FSelectedEntityList) then
      begin
        index:=FModelSpace.FSelectedEntityList.IndexOf(Item);
        if index>-1 then
         Item.Repaint(Xshift,Yshift,AScaleX,AScaleY,AScaleZ,LogicalDrawing,[edsSelected])
        else
          Item.Repaint(Xshift,Yshift,AScaleX,AScaleY,AScaleZ,LogicalDrawing,[edsNormal]);
      end
      else
        Item.Repaint(Xshift,Yshift,AScaleX,AScaleY,AScaleZ,LogicalDrawing,[edsNormal]);
  end;
end;

procedure TEntityList.RepaintVertex(LogicalDrawing: TLogicalDraw);
var
  i:integer;
  Item:TEntity;
begin
  for I := 0 to Count - 1 do
  begin
          if Assigned(FModelSpace.FSelectedEntityList) then
          begin
            Item:=Items[i];
            if FModelSpace.FSelectedEntityList.IndexOf(Item)>-1 then
              Item.RepaintVertex(LogicalDrawing);
          end;
  end;
end;

function TEntityList.GetEntityByID(AID: TEntityID): TEntity;
var
  i:integer;
  Item:TEntity;
begin
  Result:=nil;
  for I := 0 to Count - 1 do
  begin
       Item:=Items[i];
       if Item.ID=AID then
       begin
           Result:=Item;
           break;
       end;
  end;
end;

procedure TEntityList.Clear;
var
  i:integer;
begin
  for I := Count - 1 downto 0 do
  begin
      Delete(i);
  end;
end;

procedure TEntityList.SetItem(Index: Integer; const Value: TEntity);
begin
   FList.Items[Index]:=Value;
   Value.ParentList:=Self;
end;

{ TEntityEllipseBasic }

function TEntityEllipseBasic.GetSelect(TopLeft, BottomRight: TGTFPoint;
  AllVertexInRect: Boolean): Integer;
var
  MVertx: TModifyVertex;
begin
  Result:=GetSelect(TopLeft, BottomRight,AllVertexInRect,MVertx);
end;


function TEntityEllipseBasic.GetSelect(TopLeft, BottomRight: TGTFPoint;
  AllVertexInRect: Boolean; var MVertx: TModifyVertex): Integer;
var
  i,CountVertexInRect :integer;
  APoint1,APoint2     :TGTFPoint;
  xq,yq,a             :Integer;
begin

  Result:=AFFA_OUTSIDE; //Вне периметра

  // Проверка попадают ли вершины в зону выбора
  CountVertexInRect:=0;

  SetDeltaToRectPoint(TopLeft, BottomRight, ThisDocument.GetDeltaVertex);

  // Проверка попадает ли базовая точка в зону выбора
  if (VertexCount>0) then
  begin
      if PointIn2DRect(Vertex[0],TopLeft, BottomRight) then
      begin
        CountVertexInRect:=CountVertexInRect+1;
        MVertx.Item:=self;
        MVertx.VertexIndex:=0;
        MVertx.VertexPos:=Vertex[MVertx.VertexIndex];
      end;
      if (not AllVertexInRect)and(CountVertexInRect>0) then
      begin
        Result:=AFFA_BASEPOINT;
      end;
  end;

  // Проверка попадают ли вершины в зону выбора
  for I := 1 to VertexCount - 1 do
  begin
      if PointIn2DRect(Vertex[i],TopLeft, BottomRight) then
      begin
        CountVertexInRect:=CountVertexInRect+1;
        MVertx.Item:=self;
        MVertx.VertexIndex:=i;
        MVertx.VertexPos:=Vertex[MVertx.VertexIndex];
      end;
  end;

  if (AllVertexInRect)and(CountVertexInRect=VertexCount)and(VertexCount>0)and(Result=AFFA_OUTSIDE) then
  begin
    Result:=AFFA_VERTEX;
  end
  else if (not AllVertexInRect)and(CountVertexInRect>0)and(Result=AFFA_OUTSIDE) then
  begin
    Result:=AFFA_VERTEX;
  end;

  // Проверка попадают ли промежуточные точки в зону выбора

    if (not AllVertexInRect)and(VertexCount>=1)and(Result<>AFFA_VERTEX)and(Result<>AFFA_BASEPOINT) then
    begin
      for I := 0 to 180 do
      begin
        a:=i;
        APoint2:=APoint1;
        // уравнение эллипса с поворотом
        //xq := FAxleX*(0 - Vertex[0].x)*cos(a) - (0 - Vertex[0].y)*sin(a);
        //yq := FAxleY*(0 - Vertex[0].x)*sin(a) + (0 - Vertex[0].y)*cos(a);
        // уравнение эллипса
         xq:= trunc(Vertex[0].x+FAxleX*cos(a));
         yq:= trunc(Vertex[0].y+FAxleY*sin(a));
         APoint1.X:=xq;
         APoint1.Y:=yq;
        if PointInRect2D(xq,yq,TopLeft.X,TopLeft.Y,BottomRight.X,BottomRight.Y)then
        begin
            Result:=AFFA_BORDER;
            break;
        end;

        if i>0 then
        begin
          if isLinesHasIntersection(APoint1.X,APoint1.Y,APoint2.X,APoint2.Y,TopLeft.X,TopLeft.Y,BottomRight.X,BottomRight.Y) then
          begin
            Result:=AFFA_BORDER;
            break;
          end;
          if isLinesHasIntersection(APoint1.X,APoint1.Y,APoint2.X,APoint2.Y,BottomRight.X,TopLeft.Y,TopLeft.X,BottomRight.Y) then
          begin
            Result:=AFFA_BORDER;
            break;
          end;
        end;

      end; //for

      SetDeltaToRectPoint(TopLeft, BottomRight, ThisDocument.GetDeltaVertex*-1);

      // Проверка попадает ли зона выбора в периметр объекта
      if (Result=AFFA_OUTSIDE)and(not AllVertexInRect) then
      begin
          if (VertexCount>0) then
          begin
            APoint1.X:=Vertex[0].X-FAxleX;
            APoint1.Y:=Vertex[0].Y+FAxleY;
            APoint2.X:=Vertex[0].X+FAxleX;
            APoint2.Y:=Vertex[0].Y-FAxleY;
            if PointIn2DRect(TopLeft,APoint1, APoint2) then
              Result:=AFFA_INSIDE;
          end;
      end;

    end;
end;

procedure TEntityEllipseBasic.MoveVertex(Index:integer;  NewVertex: TGTFPoint);
var
  dX,dY,dZ:Integer;
begin
        dX:=NewVertex.X-Vertex[Index].X;
        dY:=NewVertex.Y-Vertex[Index].Y;
        dZ:=NewVertex.Z-Vertex[Index].Z;

        if Index=0 then
        begin
            VertexAxleX[Index]:=NewVertex.X;
            VertexAxleY[Index]:=NewVertex.Y;
            VertexAxleZ[Index]:=NewVertex.Z;

            VertexAxleX[1]:=VertexAxleX[1]+dX;
            VertexAxleY[1]:=VertexAxleY[1]+dY;
            VertexAxleZ[1]:=VertexAxleZ[1]+dZ;
            
            VertexAxleX[2]:=VertexAxleX[2]+dX;
            VertexAxleY[2]:=VertexAxleY[2]+dY;
            VertexAxleZ[2]:=VertexAxleZ[2]+dZ;

            VertexAxleX[3]:=VertexAxleX[3]+dX;
            VertexAxleY[3]:=VertexAxleY[3]+dY;
            VertexAxleZ[3]:=VertexAxleZ[3]+dZ;

            VertexAxleX[4]:=VertexAxleX[4]+dX;
            VertexAxleY[4]:=VertexAxleY[4]+dY;
            VertexAxleZ[4]:=VertexAxleZ[4]+dZ;
        end
        else if (Index=1) then
        begin
            AxleX:=AxleX+dX;
        end
        else if (Index=2) then
        begin
            AxleX:=AxleX+dX*-1;
        end
        else if (Index=3) then
        begin
            AxleY:=AxleY+dY;
        end
        else if (Index=4) then
        begin
            AxleY:=AxleY+dY*-1;
        end;
end;

procedure TEntityEllipseBasic.SetBasePoint(const Value: TGTFPoint);
begin
  if VertexCount>0 then
  begin
    Vertex[0]:=Value;
  end
  else begin
    AddVertex(Value.X,Value.Y,Value.Z);
  end;
end;

procedure TEntityEllipseBasic.GetRectVertex(var ATopLeft,
  ABottomRight: TGTFPoint);
begin

  ATopLeft.X:=BasePoint.X-FAxleX;
  ATopLeft.Y:=BasePoint.Y+FAxleY;

  ABottomRight.X:=BasePoint.X+FAxleX;
  ABottomRight.Y:=BasePoint.Y-FAxleY;
end;

function TEntityEllipseBasic.GetBasePoint: TGTFPoint;
begin
  if VertexCount>0 then
  begin
    Result:=Vertex[0];
  end;
end;

{ TEntityTextBasic }

function TEntityTextBasic.GetBasePoint: TGTFPoint;
begin
  if VertexCount>1 then
  begin
    Result:=Vertex[0];
  end;
end;

procedure TEntityTextBasic.SetBasePoint(const Value: TGTFPoint);
begin
  if VertexCount>1 then
  begin
    Vertex[0]:=Value;
  end
  else begin
    AddVertex(Value.X,Value.Y,Value.Z);
  end;
end;

constructor TEntityTextBasic.Create;
begin
  inherited Create;
  FRotate:=0;
end;

function TEntityTextBasic.GetSelect(TopLeft, BottomRight: TGTFPoint;
  AllVertexInRect: Boolean): Integer;
var
  MVertx: TModifyVertex;
begin
  Result:=GetSelect(TopLeft, BottomRight,AllVertexInRect,MVertx);
end;

function TEntityTextBasic.GetSelect(TopLeft, BottomRight: TGTFPoint;
  AllVertexInRect: Boolean; var MVertx: TModifyVertex): Integer;
var
  CountVertexInRect :integer;
begin
  Result:=AFFA_OUTSIDE; //Вне периметра
  CountVertexInRect:=0;

  SetDeltaToRectPoint(TopLeft, BottomRight, ThisDocument.GetDeltaVertex);

      if PointIn2DRect(Vertex[0],TopLeft, BottomRight) then
      begin
        CountVertexInRect:=CountVertexInRect+1;
        MVertx.Item:=self;
        MVertx.VertexIndex:=0;
        MVertx.VertexPos:=Vertex[MVertx.VertexIndex];
      end;

  if (AllVertexInRect)and(CountVertexInRect=VertexCount)and(VertexCount>0) then
    Result:=AFFA_BASEPOINT
  else if (not AllVertexInRect)and(CountVertexInRect>0) then
    Result:=AFFA_BASEPOINT;
end;

procedure TEntityTextBasic.Repaint(Xshift,Yshift,AScaleX,AScaleY,AScaleZ:Integer; LogicalDrawing: TLogicalDraw; AStyle: TEntityDrawStyle);
begin
  if VertexCount>0 then
  begin
      if edsSelected in AStyle then
        LogicalDrawing.SetStyleDraw(LINETYPE_SELECTED,GetLineWeight(FLineWeight),GetColor(FColor))
      else
        LogicalDrawing.SetStyleDraw(LINETYPE_SOLID,GetLineWeight(FLineWeight),GetColor(FColor));
      LogicalDrawing.PointDraw((Vertex[0].X*AScaleX)+Xshift,(Vertex[0].Y*AScaleY)+Yshift);
  end;
end;

procedure TEntityTextBasic.RepaintVertex(LogicalDrawing: TLogicalDraw);
begin
  if VertexCount>0 then
  begin
      LogicalDrawing.VertexDraw(Vertex[0].X,Vertex[0].Y,VERTEXMARKER_BASEPOINT);
  end;
end;

{ TGraphicText }

constructor TGraphicText.Create;
begin
  inherited Create;
  FStyleName:='STANDARD'
end;

destructor TGraphicText.Destroy;
begin
  inherited Destroy;
end;

procedure TGraphicText.Draw(ABasePoint: TGTFPoint; AText: String;
  AAlign: TgaAttachmentPoint; ARotate: integer);
begin
  if VertexCount=0 then
  AddVertex(ABasePoint.X,ABasePoint.Y,ABasePoint.Z);
  Align         :=AAlign;
  FontSize      :=9;
  FontStyle     :=[];
  FontName      :='Arial';
  Width         :=0;
  Height        :=0;
  Rotate        :=ARotate;
  Text          :=AText;
end;

procedure TGraphicText.Draw(ABasePoint: TGTFPoint; AText: String;
  AAlign: TgaAttachmentPoint; AWidth, AHeight, ARotate: integer);
begin
  if VertexCount=0 then
  AddVertex(ABasePoint.X,ABasePoint.Y,ABasePoint.Z);
  Align         :=AAlign;
  FontSize      :=3;
  FontStyle     :=[];
  FontName      :='Arial';
  Width         :=AWidth;
  Height        :=AHeight;
  Rotate        :=ARotate;
  Text          :=AText;
end;

function TGraphicText.GetHeight: Integer;
begin
  Result:=FHeight;
end;

function TGraphicText.GetWidth: Integer;
begin
  Result:=FWidth;
end;

procedure TGraphicText.MoveVertex(Index: integer; NewVertex: TGTFPoint);
var
  dX,dY,dZ:Integer;
begin
        dX:=NewVertex.X-Vertex[Index].X;
        dY:=NewVertex.Y-Vertex[Index].Y;
        dZ:=NewVertex.Z-Vertex[Index].Z;

        if CordEqualIn2D(Vertex[0],Vertex[Index]) then index:=0;

        if Index=0 then
        begin
            VertexAxleX[Index]:=NewVertex.X;
            VertexAxleY[Index]:=NewVertex.Y;
            VertexAxleZ[Index]:=NewVertex.Z;

            if VertexCount>=4 then
            begin
            VertexAxleX[1]:=VertexAxleX[1]+dX;
            VertexAxleY[1]:=VertexAxleY[1]+dY;
            VertexAxleZ[1]:=VertexAxleZ[1]+dZ;

            VertexAxleX[2]:=VertexAxleX[2]+dX;
            VertexAxleY[2]:=VertexAxleY[2]+dY;
            VertexAxleZ[2]:=VertexAxleZ[2]+dZ;

            VertexAxleX[3]:=VertexAxleX[3]+dX;
            VertexAxleY[3]:=VertexAxleY[3]+dY;
            VertexAxleZ[3]:=VertexAxleZ[3]+dZ;

            VertexAxleX[4]:=VertexAxleX[4]+dX;
            VertexAxleY[4]:=VertexAxleY[4]+dY;
            VertexAxleZ[4]:=VertexAxleZ[4]+dZ;
            end;
        end;
end;

procedure TGraphicText.GetRectVertex(var ATopLeft, ABottomRight: TGTFPoint);
var
   X0, Y0: Integer;
begin
   X0:=BasePoint.X;
   Y0:=BasePoint.Y;
   if (FWidth<=0)and(FHeight<=0) then
   begin

   end
   else begin
      case FAlign of
      gaAttachmentPointTopLeft:
      begin
          ATopLeft.X:=X0;
          ATopLeft.Y:=Y0;
          ABottomRight.X:=X0+FWidth;
          ABottomRight.Y:=Y0-FHeight;
      end;
      gaAttachmentPointTopCenter:
      begin
          ATopLeft.X:=X0-FWidth div 2;
          ATopLeft.Y:=Y0;
          ABottomRight.X:=X0+FWidth div 2;
          ABottomRight.Y:=Y0-FHeight;
      end;
      gaAttachmentPointTopRight:
      begin
          ATopLeft.X:=X0-FWidth;
          ATopLeft.Y:=Y0;
          ABottomRight.X:=X0;
          ABottomRight.Y:=Y0-FHeight;
      end;
      gaAttachmentPointMiddleLeft:
      begin
          ATopLeft.X:=X0;
          ATopLeft.Y:=Y0+FHeight div 2;
          ABottomRight.X:=X0+FWidth;
          ABottomRight.Y:=Y0-FHeight div 2;
      end;
      gaAttachmentPointMiddleCenter:
      begin
          ATopLeft.X:=X0-FWidth div 2;
          ATopLeft.Y:=Y0+FHeight div 2;
          ABottomRight.X:=X0+FWidth div 2;
          ABottomRight.Y:=Y0-FHeight div 2;
      end;
      gaAttachmentPointMiddleRight:
      begin
          ATopLeft.X:=X0-FWidth;
          ATopLeft.Y:=Y0+FHeight div 2;
          ABottomRight.X:=X0;
          ABottomRight.Y:=Y0-FHeight div 2;
      end;
      gaAttachmentPointBottomLeft:
      begin
          ATopLeft.X:=X0;
          ATopLeft.Y:=Y0+FHeight;
          ABottomRight.X:=X0+FWidth;
          ABottomRight.Y:=Y0;
      end;
      gaAttachmentPointBottomCenter:
      begin
          ATopLeft.X:=X0-FWidth div 2;
          ATopLeft.Y:=Y0+FHeight;
          ABottomRight.X:=X0+FWidth div 2;
          ABottomRight.Y:=Y0;
      end;
      gaAttachmentPointBottomRight:
      begin
          ATopLeft.X:=X0-FWidth;
          ATopLeft.Y:=Y0+FHeight;
          ABottomRight.X:=X0;
          ABottomRight.Y:=Y0;
      end;
      end;

   end;
end;

procedure TGraphicText.SetHeight(const Value: Integer);
var
  TopLeftTextRect,BottomRightTextRect: TGTFPoint;
begin
  FHeight:=Value;
  if VertexCount=1 then
  begin
      GetRectCord(FAlign,Vertex[0].X,Vertex[0].Y,FWidth,FHeight,TopLeftTextRect,BottomRightTextRect);
      AddVertex(TopLeftTextRect.X,TopLeftTextRect.Y,0);
      AddVertex(BottomRightTextRect.X,TopLeftTextRect.Y,0);
      AddVertex(BottomRightTextRect.X,BottomRightTextRect.Y,0);
      AddVertex(TopLeftTextRect.X,BottomRightTextRect.Y,0);
  end
  else begin
      GetRectCord(FAlign,Vertex[0].X,Vertex[0].Y,FWidth,FHeight,TopLeftTextRect,BottomRightTextRect);
      VertexAxleX[1]:=TopLeftTextRect.X;
      VertexAxleY[1]:=TopLeftTextRect.Y;
      VertexAxleX[2]:=BottomRightTextRect.X;
      VertexAxleY[2]:=TopLeftTextRect.Y;
      VertexAxleX[3]:=BottomRightTextRect.X;
      VertexAxleY[3]:=BottomRightTextRect.Y;
      VertexAxleX[4]:=TopLeftTextRect.X;
      VertexAxleY[4]:=BottomRightTextRect.Y;
  end;
end;

procedure TGraphicText.SetWidth(const Value: Integer);
var
  TopLeftTextRect,BottomRightTextRect: TGTFPoint;
begin
  TopLeftTextRect:=SetNullToFloatPoint;
  BottomRightTextRect:=SetNullToFloatPoint;
  FWidth:=Value;
  if VertexCount=1 then
  begin
      GetRectCord(FAlign,Vertex[0].X,Vertex[0].Y,FWidth,FHeight,TopLeftTextRect,BottomRightTextRect);
      AddVertex(TopLeftTextRect.X,TopLeftTextRect.Y,0);
      AddVertex(BottomRightTextRect.X,TopLeftTextRect.Y,0);
      AddVertex(BottomRightTextRect.X,BottomRightTextRect.Y,0);
      AddVertex(TopLeftTextRect.X,BottomRightTextRect.Y,0);
  end
  else begin
      GetRectCord(FAlign,Vertex[0].X,Vertex[0].Y,FWidth,FHeight,TopLeftTextRect,BottomRightTextRect);
      VertexAxleX[1]:=TopLeftTextRect.X;
      VertexAxleY[1]:=TopLeftTextRect.Y;
      VertexAxleX[2]:=BottomRightTextRect.X;
      VertexAxleY[2]:=TopLeftTextRect.Y;
      VertexAxleX[3]:=BottomRightTextRect.X;
      VertexAxleY[3]:=BottomRightTextRect.Y;
      VertexAxleX[4]:=TopLeftTextRect.X;
      VertexAxleY[4]:=BottomRightTextRect.Y;
  end;
end;

function TGraphicText.GetSelect(TopLeft, BottomRight: TGTFPoint;
  AllVertexInRect: Boolean): Integer;
var
  MVertx: TModifyVertex;
begin
  Result:=GetSelect(TopLeft, BottomRight, AllVertexInRect, MVertx);
end;

function TGraphicText.GetSelect(TopLeft, BottomRight: TGTFPoint;
  AllVertexInRect: Boolean; var MVertx: TModifyVertex): Integer;
var
  i,CountVertexInRect:integer;
  APoint,TopLeftTextRect,BottomRightTextRect: TGTFPoint;
begin

  Result:=AFFA_OUTSIDE; //Вне периметра

  // Проверка попадают ли вершины в зону выбора
  CountVertexInRect:=0;

  SetDeltaToRectPoint(TopLeft, BottomRight, ThisDocument.GetDeltaVertex);

  // Проверка попадает ли базовая точка в зону выбора
  if (VertexCount>0) then
  begin
      if PointIn2DRect(Vertex[0],TopLeft, BottomRight) then
      begin
        CountVertexInRect:=CountVertexInRect+1;
        MVertx.Item:=self;
        MVertx.VertexIndex:=0;
        MVertx.VertexPos:=Vertex[MVertx.VertexIndex];
      end;
      if (not AllVertexInRect)and(CountVertexInRect>0) then
      begin
        Result:=AFFA_BASEPOINT;
      end;
  end;

  // Проверка попадают ли вершины в зону выбора
  for I := 1 to VertexCount - 1 do
  begin
      if PointIn2DRect(Vertex[i],TopLeft, BottomRight) then
      begin
        CountVertexInRect:=CountVertexInRect+1;
        MVertx.Item:=self;
        MVertx.VertexIndex:=i;
        MVertx.VertexPos:=Vertex[MVertx.VertexIndex];
      end;
  end;

  if (AllVertexInRect)and(CountVertexInRect=VertexCount)and(VertexCount>0)and(Result=AFFA_OUTSIDE) then
  begin
    Result:=AFFA_VERTEX;
  end
  else if (not AllVertexInRect)and(CountVertexInRect>0)and(Result=AFFA_OUTSIDE) then
  begin
    Result:=AFFA_VERTEX;
  end;

  // Проверка попадают ли промежуточные точки в зону выбора

    if (not AllVertexInRect)and(VertexCount>=1)and(Result<>AFFA_VERTEX)and(Result<>AFFA_BASEPOINT) then
    begin

    APoint:=Vertex[0];
    for I := 1 to VertexCount - 1 do
    begin
      //AC
      if isLinesHasIntersection(APoint.X,APoint.Y,Vertex[i].X,Vertex[i].Y,TopLeft.X,TopLeft.Y,BottomRight.X,BottomRight.Y) then
      begin
        Result:=AFFA_BORDER;
        break;
      end;
      //BD
      if isLinesHasIntersection(APoint.X,APoint.Y,Vertex[i].X,Vertex[i].Y,BottomRight.X,TopLeft.Y,TopLeft.X,BottomRight.Y) then
      begin
        Result:=AFFA_BORDER;
        break;
      end;
      //AB
      if isLinesHasIntersection(APoint.X,APoint.Y,Vertex[i].X,Vertex[i].Y,TopLeft.X,TopLeft.Y,BottomRight.X,TopLeft.Y) then
      begin
        Result:=AFFA_BORDER;
        break;
      end;
      //BC
      if isLinesHasIntersection(APoint.X,APoint.Y,Vertex[i].X,Vertex[i].Y,BottomRight.X,TopLeft.Y,BottomRight.X,BottomRight.Y) then
      begin
        Result:=AFFA_BORDER;
        break;
      end;
      //CD
      if isLinesHasIntersection(APoint.X,APoint.Y,Vertex[i].X,Vertex[i].Y,BottomRight.X,BottomRight.Y,TopLeft.X,BottomRight.Y) then
      begin
        Result:=AFFA_BORDER;
        break;
      end;
      //DA
      if isLinesHasIntersection(APoint.X,APoint.Y,Vertex[i].X,Vertex[i].Y,TopLeft.X,BottomRight.Y,TopLeft.X,TopLeft.Y) then
      begin
        Result:=AFFA_BORDER;
        break;
      end;
      APoint:=Vertex[i];
    end; //for

      SetDeltaToRectPoint(TopLeft, BottomRight, ThisDocument.GetDeltaVertex*-1);

      // Проверка попадает ли зона выбора в периметр объекта
      if (Result=AFFA_OUTSIDE)and(not AllVertexInRect) then
      begin
          if (FWidth>0)and(FHeight>0)and(VertexCount>0) then
          begin
            GetRectCord(FAlign,Vertex[0].X,Vertex[0].Y,FWidth,FHeight,TopLeftTextRect,BottomRightTextRect);
            if PointIn2DRect(TopLeft,TopLeftTextRect, BottomRightTextRect) then
              Result:=AFFA_INSIDE;
          end;
      end;

    end;
end;

procedure TGraphicText.Repaint(Xshift,Yshift,AScaleX,AScaleY,AScaleZ:Integer;
  LogicalDrawing: TLogicalDraw; AStyle:TEntityDrawStyle);
var
  TextSizeScale:Integer;
   TmpVertex :TGTFPoint;
begin
  if VertexCount>=1 then
  begin

    if esMoving in State then
      TmpVertex:=GetInteractiveVertex(Vertex[0]) //Конвертирование координаты при перемещении курсора
    else
      TmpVertex:=Vertex[0];

      if edsSelected in AStyle then
        LogicalDrawing.SetStyleDraw(LINETYPE_SELECTED,GetLineWeight(FLineWeight),GetColor(FColor))
      else
        LogicalDrawing.SetStyleDraw(LINETYPE_SOLID,GetLineWeight(FLineWeight),GetColor(FColor));
    TextSizeScale:=AScaleY;
    if TextSizeScale<0 then
       TextSizeScale:=TextSizeScale*-1;
    LogicalDrawing.SetFontStyleDraw(FFontName, FFontSize*TextSizeScale, FFontStyle);
    LogicalDrawing.TextDraw((TmpVertex.X*AScaleX)+Xshift,(TmpVertex.Y*AScaleY)+Yshift, FWidth*AscaleX, FHeight*AscaleY, FRotate, FText, FAlign);
    {
    if edsSelected in AStyle then
    begin
      if (FWidth>0)and(FHeight>0) then
      begin
        //draw text on selected todo
      end
      else begin
        //LogicalDrawing.GetTextWidth(FText); //todo:
        //LogicalDrawing.GetTextHeight(FText); //todo:
      end;
      //LogicalDrawing.LineDraw(TopLeftPointWCS.X,TopLeftPointWCS.Y,BottomRightPointWCS.X,TopLeftPointWCS.Y);
      //LogicalDrawing.LineDraw(TopLeftPointWCS.X,TopLeftPointWCS.Y,TopLeftPointWCS.X,BottomRightPointWCS.Y);
      //LogicalDrawing.LineDraw(TopLeftPointWCS.X,BottomRightPointWCS.Y,BottomRightPointWCS.X,BottomRightPointWCS.Y);
      //LogicalDrawing.LineDraw(BottomRightPointWCS.X,TopLeftPointWCS.Y,BottomRightPointWCS.X,BottomRightPointWCS.Y);
    end;
    }
  end;
end;


procedure TGraphicText.RepaintVertex(LogicalDrawing: TLogicalDraw);
var
  i:integer;
  TmpVertex  :TGTFPoint;
begin
    if esMoving in State then
      TmpVertex:=GetInteractiveVertex(Vertex[0])
    else
      TmpVertex:=Vertex[0];

    LogicalDrawing.VertexDraw(TmpVertex.X,TmpVertex.Y,VERTEXMARKER_BASEPOINT);
    for i:=1 to VertexCount-1 do
    begin
      if esMoving in State then
        TmpVertex:=GetInteractiveVertex(Vertex[i])
      else
        TmpVertex:=Vertex[i];
      LogicalDrawing.VertexDraw(TmpVertex.X,TmpVertex.Y,VERTEXMARKER_VERTEX);
    end;
end;

{ TEntityLineBasic }

function TEntityLineBasic.GetSelect(TopLeft, BottomRight: TGTFPoint;
  AllVertexInRect: Boolean; var MVertx: TModifyVertex): Integer;
var
  i,CountVertexInRect:integer;
  APoint: TGTFPoint;
begin

  Result:=AFFA_OUTSIDE; //Вне периметра

  SetDeltaToRectPoint(TopLeft, BottomRight, ThisDocument.GetDeltaVertex);

  // Проверка попадают ли вершины в зону выбора
  CountVertexInRect:=0;
  for I := 0 to VertexCount - 1 do
  begin
      if PointIn2DRect(Vertex[i],TopLeft, BottomRight) then
      begin
        CountVertexInRect:=CountVertexInRect+1;
        MVertx.Item:=self;
        MVertx.VertexIndex:=i;
        MVertx.VertexPos:=Vertex[MVertx.VertexIndex];
      end;
  end;

  if (AllVertexInRect)and(CountVertexInRect=VertexCount)and(VertexCount>0) then
  begin
    Result:=AFFA_VERTEX;
  end
  else if (not AllVertexInRect)and(CountVertexInRect>0) then
  begin
    Result:=AFFA_VERTEX;
  end;

  // Проверка попадают ли промежуточные точки в зону выбора
    //ABCD
    if (not AllVertexInRect)and(VertexCount>1)and(Result<>AFFA_VERTEX) then
    begin
    APoint:=Vertex[0];
    for I := 1 to VertexCount - 1 do
    begin
      //AC
      if isLinesHasIntersection(APoint.X,APoint.Y,Vertex[i].X,Vertex[i].Y,TopLeft.X,TopLeft.Y,BottomRight.X,BottomRight.Y) then
      begin
        Result:=AFFA_BORDER;
        break;
      end;
      //BD
      if isLinesHasIntersection(APoint.X,APoint.Y,Vertex[i].X,Vertex[i].Y,BottomRight.X,TopLeft.Y,TopLeft.X,BottomRight.Y) then
      begin
        Result:=AFFA_BORDER;
        break;
      end;
      //AB
      if isLinesHasIntersection(APoint.X,APoint.Y,Vertex[i].X,Vertex[i].Y,TopLeft.X,TopLeft.Y,BottomRight.X,TopLeft.Y) then
      begin
        Result:=AFFA_BORDER;
        break;
      end;
      //BC
      if isLinesHasIntersection(APoint.X,APoint.Y,Vertex[i].X,Vertex[i].Y,BottomRight.X,TopLeft.Y,BottomRight.X,BottomRight.Y) then
      begin
        Result:=AFFA_BORDER;
        break;
      end;
      //CD
      if isLinesHasIntersection(APoint.X,APoint.Y,Vertex[i].X,Vertex[i].Y,BottomRight.X,BottomRight.Y,TopLeft.X,BottomRight.Y) then
      begin
        Result:=AFFA_BORDER;
        break;
      end;
      //DA
      if isLinesHasIntersection(APoint.X,APoint.Y,Vertex[i].X,Vertex[i].Y,TopLeft.X,BottomRight.Y,TopLeft.X,TopLeft.Y) then
      begin
        Result:=AFFA_BORDER;
        break;
      end;
      APoint:=Vertex[i];
    end;

    end;

end;

function TEntityLineBasic.GetSelect(TopLeft, BottomRight: TGTFPoint;
  AllVertexInRect: Boolean): Integer;
var
  MVertx: TModifyVertex;
begin
  Result:=GetSelect(TopLeft, BottomRight,AllVertexInRect,MVertx);
end;

procedure TEntityLineBasic.RepaintVertex(LogicalDrawing: TLogicalDraw);
var
  i:integer;
begin
  if VertexCount>0 then
  begin
    for i:=0 to VertexCount-1 do
    begin
      LogicalDrawing.VertexDraw(Vertex[i].X,Vertex[i].Y,VERTEXMARKER_VERTEX);
    end;
  end;
end;

end.
