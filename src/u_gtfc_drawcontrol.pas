unit u_gtfc_drawcontrol;

//************************************************************
//
//    Graphic Task Flow Control
//    Copyright (c) 2023-2026  Pichugin M.
//    ver. 0.57
//    Разработчик: Pichugin Maksim (e-mail: pichugin-swd@mail.ru)
//
//************************************************************

{WISHLIST}

 //todo:resize headers left outset;
 //todo:sort by headers left outset;
 //todo:stars;
 //todo:keyboard control;

{$mode objfpc}{$H+}

interface

uses
{$IFNDEF FPC}

{$ELSE}
  Windows,
{$ENDIF}
  Messages, SysUtils, ComCtrls, Classes, Graphics, Controls, Forms, Math,
  Dialogs, Menus, ExtCtrls, DateUtils, StdCtrls, Variants,
  u_gtfc_logicaldraw, u_gtfc_const,
  u_gtfc_visualobjects, u_gtfc_objecttree;

type

  { Data types }

  TEntitySelectEvent         = procedure(Sender: TObject; AEntity:TEntity;
                               var CanSelect:Boolean) of object;
  TEntityBeforeDrawEvent     = procedure(Sender: TObject; AEntity:TEntity;
                               var CanDraw:Boolean) of object;
  TEntityActionEvent         = procedure(Sender: TObject;
                               AEntity:TEntity) of object;
  TEntityFilterEvent         = procedure(Sender: TObject;
                               AEntity:TEntity; var AActive:Boolean) of object;
  TOutsetTreeItemActionEvent = procedure(Sender: TObject;
                               ATreeItem:TGTFCOutsetTreeBasicItem) of object;
  TOutsetTreeItemFilterEvent = procedure(Sender: TObject;
                              ATreeItem:TGTFCOutsetTreeBasicItem; var AActive:Boolean) of object;
  TOutsetTreeItemClickEvent  = procedure(Sender: TObject;
                               ATreeItem:TGTFCOutsetTreeBasicItem; ATarget:TGTFCOutsetTreeClickResult) of object;
  TEntityAfterDrawEvent      = procedure(Sender: TObject;
                               AEntity:TEntity) of object;
  TExtHintBeforeDrawEvent    = procedure(Sender: TObject;
                               var AWidth, AHeight:integer;
                               ACanvas:TCanvas) of object;
  TEntityBeforeEditEvent     = procedure(Sender: TObject; AEntity:TEntity;
                               var CanEdit:Boolean) of object;
  TEntityAfterEditEvent      = procedure(Sender: TObject;
                               AEntity:TEntity) of object;
  TEntityEditEvent           = procedure(Sender: TObject;
                               AEntity:TEntity; AColIndex,
                               ARowIndex: integer) of object;
  TDoActionEvent             = procedure(Sender: TObject;
                               ADataArray:TModifyVertexArray) of object;
  TColBackgroundBeforeDrawEvent = procedure(Sender: TObject;
                               AColItem:TGTFCOutsetTreeColItem;
                               var AEnabled:Boolean) of object;

  // Determines the look of a tree's buttons.
  TGraphTreeButtonStyle = (
    gtbsNot,
    gtbsRectangle,        // traditional Windows look (plus/minus buttons)
    gtbsTriangle,
    gtbsDot               // Dot
  );

  //Кратность графика
  TGraphMultiplicity = (gmHour, gmDay, gmWeek, qmMonth, gmQuarter);

  TGTFMouseButton = (gmbNone, gmbLeft, gmbRight, gmbMiddle);

  //Режим работы с компонентом
  TEntityEditMode            = (
    eemCanAll,  //Любые действия
    eemReadOnly, //Только просмотр
    eemSelectOnly //Разрешон выбор элементов
  );

  TCursorStyle            = (
    csOSAuto, //Курсоры ОС по усмотрению компонента
    csOwner //Курсоры определяются программой
  );

  TgaControlAction           = set of (caNone,caZoomToFit,caMoveSpace,
                                   caSelectObject,caClickLeft,
                                   caClickRight,caMoveVertex);
  TAffectedAreaSelectOptions = set of (aasoOUTSIDE,aasoBASEPOINT,
                                   aasoVERTEX,aasoINSIDE,aasoBORDER);
  TSelectListStyle           = set of (slsClearOnNullClick,slsSumSelection);

  { Forward Declarartions }

  TGTFControl = class;

  // Закладка положения диаграммы
  PTGTFViewBookmark = ^TGTFViewBookmark;
  TGTFViewBookmark = record
    VBookmark      : Boolean;
    HBookmark      : Boolean;
    VBookmarkValue : Variant;
    HBookmarkValue : TDateTime;
  end;

  { TGTFDrawDocument }

  TGTFDrawDocument = class(TGTFDrawDocumentCustom)
  private
    FDrawControl        :TGTFControl;
    FOnChange           :TNotifyEvent;
    FOnSelectListChange :TNotifyEvent;

    EntityIDCountIndexA :integer;
    EntityIDCountIndexB :integer;
    EntityIDCountIndexC :integer;
    EntityIDCountIndexD :integer;
    FEditMode           :TEntityEditMode;
    FSelectList         :TList;
    FMVertArray         :TModifyVertexArray;
    FViewBookmark       :TGTFViewBookmark;
    FViewPos            :TGTFPoint;

    function GetDocument:TGTFDrawDocumentCustom;
  published
    property  EditMode:TEntityEditMode read FEditMode write FEditMode;
  public
    constructor Create(AOwner: TComponent);  virtual;
    destructor Destroy; override;

    property  ViewPos: TGTFPoint read FViewPos
                                   write FViewPos;
    property  ViewBookmark: TGTFViewBookmark read FViewBookmark
                                   write FViewBookmark;

    property  OnChange: TNotifyEvent read FOnChange
                                     write FOnChange;
    property  OnSelectListChange:TNotifyEvent read FOnSelectListChange
                                              write FOnSelectListChange;
    property  SelectList :TList read FSelectList
                                write FSelectList;
    property  DrawControl :TGTFControl read FDrawControl
                                            write FDrawControl;

    function CreateTask :TGraphicTask;
    function CreateConnectionline :TGraphicConnectionline;

    function GetEntityID:ShortString;
    function GetDeltaVertex:Integer; override;
    function GetRowUnderCursor:Integer; override;
    function GetColUnderCursor:Integer; override;
    function GetColUnderPoint(APoint: TGTFPoint): Integer;
    function GetRowUnderPoint(APoint: TGTFPoint): Integer;
    function GetColByDateTime(AValue: TDateTime): Integer;

    procedure BookmarkToNow;

    procedure MVertArray(Value:TModifyVertex);
    procedure DeselectAll; override;
    procedure Clear;
  end;

  { TGTFControl }

  TGTFControl = class(TPaintBox)
  private
    FOnSelectListChange              :TNotifyEvent;
    FOnBeforeDrawEvent               :TNotifyEvent;
    FOnAfterDrawEvent                :TNotifyEvent;
    FOnEditingDone                   :TNotifyEvent;
    FOnExtHintBeforeDrawEvent        :TExtHintBeforeDrawEvent;
    FOnEntitySelectEvent             :TEntitySelectEvent;
    FOnEntityBeforeDrawEvent         :TEntityBeforeDrawEvent;
    FOnEntityAfterDrawEvent          :TEntityAfterDrawEvent;
    FOnEntityFilterEvent             :TEntityFilterEvent;
    FOnEntityAfterEditEvent          :TEntityAfterEditEvent;
    FOnEntityBeforeEditEvent         :TEntityBeforeEditEvent;
    FOnEntityEditEvent               :TEntityEditEvent;

    FOnFirstShowEvent                :TNotifyEvent;
    FOnColBGBeforeDrawEvent          :TColBackgroundBeforeDrawEvent;
    FOnOutsetTreeRowEvent            :TOutsetTreeItemClickEvent;
    FOnOutsetTreeItemFilterEvent     :TOutsetTreeItemFilterEvent;
    FMessagesLast                    :String;
    FMessagesList                    :TStringList;
    FTimerMessage                    :TTimer;
    // Настройки
    FDevelop                         :Boolean; //Режим отладки
    // Размер захвата курсора. Размер зоны поиск
    FCursorDeltaSize                 :Integer;
    FDeltaCord                       :Integer; //Размеры вершин
    FVertexBasePointColor            :TColor;
    FVertexCustomColor               :TColor;
    FVertexSelectColor               :TColor;
    FCursorColor                     :TColor;
    FBackgroundColor                 :TColor;
    FDrawCursorStyle                 :TCursorStyle; //Отображать свой курсор
    FRuleStepA                       :Integer;
    FRuleStepB                       :Integer;
    FGrid                            :Boolean;
    FWayLine                         :Boolean;
    FTodayWayLine                    :Boolean;
    FAntiLayering                    :Boolean;
    FShowGroupHorizontal             :Boolean;
    FGridColor                       :TColor;
    FSelectLeftColor                 :TColor;
    FSelectRightColor                :TColor;
    FDefaultFont                     :TFont;
    FSelectStyle                     :TAffectedAreaSelectOptions;
    FSelectListStyle                 :TSelectListStyle;
    FSelectObjectFilter              :TEntityTypes;
    FTreeButtonStyle                 :TGraphTreeButtonStyle;
    // Хранилище
    FDocument                        :TGTFDrawDocument;
    // Переменные состоянния
    FUpdateCount                     :Integer;
    FDoSecondDraw                    :Boolean;
    FFirstPaint                      :Boolean;
    FDrawFont                        :Boolean;
    FMouseButtonPressed              :Boolean;
    FMouseButtonUpPos                :TPoint;  //Запоминаем положение при отпускании кнопки
    FMouseButtonUp                   :TGTFMouseButton;
    FMouseButtonDownPos              :TPoint; //Запоминаем положение при нажатии кнопки
    FMouseButtonDown                 :TGTFMouseButton;
    FMousePosMoveVertexLast          :TPoint; //Запоминаем положение при перемещении объектов
    FMousePosMoveVertexDelta         :TGTFPoint; //Запоминаем положение при перемещении объектов
    FMouseButtonUpShift              :TShiftState;
    FMouseButtonDownShift            :TShiftState;
    FClickCount                      :SmallInt;
    FtmpViewPos                      :TGTFPoint;
    FControlAction                   :TgaControlAction;
    FKStep                           :Integer;
    FCurSec                          :Integer;
    FMouseMoveVertexEnable           :Boolean;
    FDrawRowCounter                  :integer;

    FViewAreaMousePoint,
    FViewAreaAPoint,
    FViewAreaBPoint,
    FViewAreaCPoint,
    FViewAreaDPoint                  :TGTFPoint;

    FCursorPos                       :TPoint;
    vbmHeight, vbpWidth              :Integer;

    FColWSizeSum,
    FRowHSizeSum                     :Integer;
    // Виртуальные области кеширования
    FFormWindowProc                  :TWndMethod;
    FLogicalDraw                     :TLogicalDraw;
    //Слои рисования диаграммы
    FDrawLayerMain                   :TBitMap;
    FDrawLayerOutsetBorder           :TBitMap;
    //
    //
    FDrawLayerMainCanvas             :TCanvas;
    FDrawLayerOutsetBorderCanvas     :TCanvas;

    FDataBitMap                      :TBitMap;
    FDataBitMapEnabled               :Boolean;
    FDataBitMapTmpX                  :Integer;
    FDataBitMapTmpY                  :Integer;

    FEntityFirstDrawBitMap           :TBitMap;
    FHintDrawBitMap                  :TBitMap;

    // paint support and images
    FArrowDownBM,
    FFlagBM,
    FPlusBM,
    FMinusBM,
    FHotPlusBM,
    FHotMinusBM                      :TBitMap;

    FSelfOnClick                     :TNotifyEvent;
    FPopupGridArea                   :TPopupmenu;
    FPopupLeftOutsetArea             :TPopupmenu;
    FSelfOnDblClick                  :TNotifyEvent;
    FSelfOnMouseDown                 :TMouseEvent;
    FSelfOnMouseMove                 :TMouseMoveEvent;
    FSelfOnMouseUp                   :TMouseEvent;
    FSelfOnMouseWheel                :TMouseWheelEvent;
    FSelfOnMouseWheelDown            :TMouseWheelUpDownEvent;
    FSelfOnMouseWheelUp              :TMouseWheelUpDownEvent;
    FSelfOnPaint                     :TNotifyEvent;
    FOnChangeGridScale               :TNotifyEvent;

    FFrameViewModeText               :String;
    FFrameViewModeColor              :TColor;

    FColWidth                        : Integer;
    FColExtWidth                     : Integer;
    FRowHeight                       : Integer;
    //50..100..150
    FGridScale                       : Integer;
    //Ширина левого боковика целиком, фактическая
    FLeftOutsetBorderWidth           : Integer;
    //Ширина боковика без дополнительных столбцов
    FLeftOutsetBorderBaseWidth       : Integer;
    //Ширина столбца номера строки
    FLeftOutsetBorderRowNumWidth     : Integer;
    //Ширина групповой вертикальной надписи
    FLeftOutsetBorderVCapWidth        : Integer;
    //Высота линейки с датами
    FTopOutsetBorderHeight           : Integer;

    FGraphDateTimeBegin              : TDateTime;
    FGraphDateTimeEnd                : TDateTime;
    FGraphMultiplicity               : TGraphMultiplicity;
    FGraphDrawDatePrecision          : Boolean;
    FScrollBarVerticalUpdate         : Boolean;
    FScrollBarHorizontalUpdate       : Boolean;
    FScrollBarVertical               : TScrollBar;
    FScrollBarHorizontal             : TScrollBar;
    procedure LineSDraw(APoints: array of TPoint);
  private
    procedure DrawGridLine(ACanvas: TCanvas; AX1, AY1, AX2, AY2: Integer);
    procedure DrawHighLightFrame(ACanvas: TCanvas; AX1, AY1, AX2, AY2: Integer);
    procedure DrawOutsetRowItemHoriz(ACanvas: TCanvas; AItem: TGTFCOutsetTreeRowItem; AX1, AY1, AX2, AY2: Integer; ADrawGroupHoriz: Boolean);
    procedure DrawOutsetRowItemVert(ACanvas: TCanvas; AItem: TGTFCOutsetTreeRowItem; AX1, AY1, AX2, AY2: Integer; ADrawGroupHoriz: Boolean);
    function GetGraphMultiplicityDrawPrecision: TGraphMultiplicity;
    function GetRowHeight: Integer;
    //Ширина столбцов
    function GetColWidth: Integer;
    //Кол-во дополнительных столбцов
    function GetLeftOutsetExtColCount: Integer;
    //Кол-во видимых дополнитлеьных столбцов
    function GetLeftOutsetExtColVisibleCount: Integer;
    procedure SetTreeButtonStyle(AValue: TGraphTreeButtonStyle);

    // Рисование интерфейса
    procedure SupportImageCreate(Sender: TObject);
    procedure DrawOutsetCol(ACanvas:TCanvas);
    function DrawOutsetRow(ACanvas:TCanvas;AParent: TGTFCOutsetTreeRowItem; ALevel, AY1, AX1,
      AX2: Integer; var AEndY2: integer): boolean;
    function GetRowItemHeight(ARowItem: TGTFCOutsetTreeRowItem): integer;
    procedure GetOutsetBorderSizes(Sender: TObject);
    function GetDrawRowCount: integer;
    procedure GetViewingArea(Sender: TObject);

    procedure OnHorizontalScroll(Sender: TObject; ScrollCode: TScrollCode;
      var ScrollPos: Integer);
    procedure OnVerticalScroll(Sender: TObject; ScrollCode: TScrollCode;
      var ScrollPos: Integer);
    procedure SetGridScale(AValue: Integer);
    procedure SetRowHeight(AValue: Integer);

    procedure SuperPaint(Sender: TObject);
    procedure MainControlPaint(Sender: TObject);
    procedure SLOutsetGridBGPaint(Sender: TObject);
    procedure SLOutsetGridPaint(Sender: TObject);
    procedure SLOutsetBorderHeaderPaint(Sender: TObject);
    procedure SLCursorPaint(Sender: TObject);
    procedure SLDevelopInfoPaint(Sender: TObject);
    procedure SLExtHintPaint(Sender: TObject);
    procedure SLMessagesPaint(Sender: TObject);
    procedure SLFrameViewModePaint(Sender: TObject);
    procedure SLVirtualPaintBegin(Sender: TObject);
    procedure SLVirtualPaintEnd(Sender: TObject);
    // Исправление наслоения
    procedure AntiLayeringRowResize(Sender: TObject);

    procedure ZeroPointCSPaint;
    procedure VertexPaint(X,Y: Integer); overload;
    procedure SelectRectDoPaint(Sender: TObject);
    procedure SelectRectPaint(X1, Y1, X2, Y2: Integer);
    // Рисование ручек
    procedure VertexDraw(X, Y: Integer; ATypeVertex: Integer);

    // Рисование примитивов
    procedure RefreshFilterEntity;
    procedure RefreshFilterTree;
    procedure RepaintEntity;
    procedure RepaintVertex;

    procedure SetFontStyleDraw(FontName: AnsiString;FontSize: Integer;FontStyle: TFontStyles);
    procedure SetStyleDraw(LineType:String; LineWidth:TgaLineWeight; AColor:TgaColor);
    procedure LineDraw(X1, Y1, X2, Y2: Integer);
    procedure PolylineDraw(APoints:Array of TPoint);
    procedure PolygonDraw(APoints:Array of TPoint);
    procedure RectangelDraw(TopLeftX, TopLeftY, BottomRightX, BottomRightY: Integer);
    procedure FillDraw(TopLeftX, TopLeftY, BottomRightX, BottomRightY: Integer);
    procedure CircleDraw(X, Y, Radius: Integer);
    procedure ArcDraw(X0, Y0, X1, Y1, X2, Y2, Radius: Integer);
    procedure PointDraw(X, Y: Integer);
    procedure EllipseDraw(X0, Y0, AxleX, AxleY: Integer);
    procedure TextOutTransperent(X,Y:Integer;AText:String);
    procedure TextDraw(X0, Y0, AWidth, AHeight: Integer; Rotate:integer; AText:String; AAlign:TgaAttachmentPoint);
    procedure GetGridScale(var Value: Integer);
    procedure GetTextHeight(AText: AnsiString; var AHeight: Integer);
    procedure GetTextWidth(AText: AnsiString; var AWidth: Integer);

    // Отклики
    procedure EndSelecting(Sender: TObject);
    procedure SuperClick(Sender: TObject);
    procedure SuperDblClick(Sender: TObject);
    procedure SuperLeftButtonClick(Sender: TObject);
    procedure SuperEditingDone(Sender: TObject);
    procedure SuperMiddleButtonDblClick(Sender: TObject);
    procedure SuperBeforeEntityEdit(AEntity:TEntity; var ACanEdit:Boolean);
    procedure SuperAfterEntityEdit(AEntity:TEntity);
    procedure SuperEntityEdit(AEntity:TEntity; AColIndex,ARowIndex:integer);

    //procedure SuperMouseEnter(Sender: TObject);
    //procedure SuperMouseLeave(Sender: TObject);
    procedure SuperMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
    procedure SuperMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure SuperMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure SuperMouseWheel(Sender: TObject; Shift: TShiftState;WheelDelta: Integer; MousePos: TPoint; var Handled: Boolean);
    procedure SuperMouseWheelUp(Sender: TObject; Shift: TShiftState;MousePos: TPoint; var Handled: Boolean);
    procedure SuperMouseWheelDown(Sender: TObject; Shift: TShiftState;MousePos: TPoint; var Handled: Boolean);
    procedure gaMouseAction(Sender: TObject);
    procedure BeginMoveVertex(Sender: TObject);
    procedure EndMoveVertex(Sender: TObject);
    procedure ClearMoveVertex;
    procedure SuperWndProc(var Message: TMessage);
    // Изменение координат всех выбранных точек
    procedure gaMoveVertexAction(Sender: TObject);
    procedure RefreshEntityDraw;
    procedure TimerMessageOnTimer(Sender: TObject);
    procedure RefreshColls;
  published
    property DevelopMode        :Boolean read FDevelop write FDevelop;

    property RowHeight          :Integer read GetRowHeight write SetRowHeight;
    property ColWidth           :Integer read GetColWidth write FColWidth;
    property ColExtWidth        :Integer read FColExtWidth write FColExtWidth;

    property GridScale          :Integer read FGridScale write SetGridScale;

    property TreeButtonStyle    :TGraphTreeButtonStyle read FTreeButtonStyle write SetTreeButtonStyle;

    //Дополнительные колонки слева
    property LeftExtColCount    :Integer read GetLeftOutsetExtColCount;

    property RuleStepA          :Integer read FRuleStepA write FRuleStepA;
    property RuleStepB          :Integer read FRuleStepB write FRuleStepB;
    property ShowGrid           :Boolean read FGrid write FGrid;
    property ShowWayLine        :Boolean read FWayLine write FWayLine;
    property ShowTodayWayLine   :Boolean read FTodayWayLine write FTodayWayLine;
    property AntiLayering       :Boolean read FAntiLayering write FAntiLayering;
    property ShowGroupHorizontal:Boolean read FShowGroupHorizontal write FShowGroupHorizontal;
    property GridColor          :TColor read FGridColor write FGridColor;

    // Кратность графика
    property GraphMultiplicity     :TGraphMultiplicity read FGraphMultiplicity write FGraphMultiplicity;
    property GraphMultiplicityDraw :TGraphMultiplicity read GetGraphMultiplicityDrawPrecision;
    property GraphDateTimeBegin    :TDateTime read FGraphDateTimeBegin write FGraphDateTimeBegin;
    property GraphDateTimeEnd      :TDateTime read FGraphDateTimeEnd write FGraphDateTimeEnd;
    property GraphDrawDatePrecision :Boolean read FGraphDrawDatePrecision write FGraphDrawDatePrecision;

    property BackgroundColor      :TColor read FBackgroundColor write FBackgroundColor;

    property VertexBasePointColor :TColor read FVertexBasePointColor write FVertexBasePointColor;
    property VertexCustomColor    :TColor read FVertexCustomColor write FVertexCustomColor;
    property VertexSelectColor    :TColor read FVertexSelectColor write FVertexSelectColor;
    property SelectLeftColor      :TColor read FSelectLeftColor write FSelectLeftColor;
    property SelectRightColor     :TColor read FSelectRightColor write FSelectRightColor;

    property DefaultFont          :TFont read FDefaultFont write FDefaultFont;

    property PopupMenuGridArea        : TPopupmenu read FPopupGridArea write FPopupGridArea;
    property PopupMenuLeftOutsetArea  : TPopupmenu read FPopupLeftOutsetArea write FPopupLeftOutsetArea;

    // Переопределяемые свойства
    property OnEditingDone               : TNotifyEvent read FOnEditingDone write FOnEditingDone;

    property OnClick                     : TNotifyEvent read FSelfOnClick write FSelfOnClick;
    property OnDblClick                  : TNotifyEvent read FSelfOnDblClick write FSelfOnDblClick;
    property OnMouseDown                 : TMouseEvent read FSelfOnMouseDown write FSelfOnMouseDown;
    property OnMouseMove                 : TMouseMoveEvent read FSelfOnMouseMove write FSelfOnMouseMove;
    property OnMouseUp                   : TMouseEvent read FSelfOnMouseUp write FSelfOnMouseUp;
    property OnMouseWheel                : TMouseWheelEvent read FSelfOnMouseWheel write FSelfOnMouseWheel;
    property OnMouseWheelDown            : TMouseWheelUpDownEvent read FSelfOnMouseWheelDown write FSelfOnMouseWheelDown;
    property OnMouseWheelUp              : TMouseWheelUpDownEvent read FSelfOnMouseWheelUp write FSelfOnMouseWheelUp;
    property OnChangeGridScale           : TNotifyEvent read FOnChangeGridScale write FOnChangeGridScale;

    property OnFirstShow                 : TNotifyEvent read FOnFirstShowEvent write FOnFirstShowEvent;

    property OnOutsetTreeItemFilterEvent :TOutsetTreeItemFilterEvent read FOnOutsetTreeItemFilterEvent write FOnOutsetTreeItemFilterEvent;
    property OnOutsetTreeRowEvent        :TOutsetTreeItemClickEvent read FOnOutsetTreeRowEvent write FOnOutsetTreeRowEvent;

    property OnColBGBeforeDrawEvent      :TColBackgroundBeforeDrawEvent read FOnColBGBeforeDrawEvent write FOnColBGBeforeDrawEvent;

    property OnBeforeDrawEvent           :TNotifyEvent read FOnBeforeDrawEvent write FOnBeforeDrawEvent;
    property OnAfterDrawEvent            :TNotifyEvent read FOnAfterDrawEvent write FOnAfterDrawEvent;

    property OnEntityBeforeDrawEvent     :TEntityBeforeDrawEvent read FOnEntityBeforeDrawEvent write FOnEntityBeforeDrawEvent;
    property OnEntityAfterDrawEvent      :TEntityAfterDrawEvent read FOnEntityAfterDrawEvent write FOnEntityAfterDrawEvent;

    property OnEntityFilterEvent         :TEntityFilterEvent read FOnEntityFilterEvent write FOnEntityFilterEvent;

    property OnEntityBeforeEditEvent     :TEntityBeforeEditEvent read FOnEntityBeforeEditEvent write FOnEntityBeforeEditEvent;
    property OnEntityAfterEditEvent      :TEntityAfterEditEvent read FOnEntityAfterEditEvent write FOnEntityAfterEditEvent;
    property OnEntityEditEvent           :TEntityEditEvent read FOnEntityEditEvent write FOnEntityEditEvent;

    property OnExtHintBeforeDrawEvent    :TExtHintBeforeDrawEvent read FOnExtHintBeforeDrawEvent write FOnExtHintBeforeDrawEvent;

    property OnEntitySelectEvent         :TEntitySelectEvent read FOnEntitySelectEvent write FOnEntitySelectEvent;
    property OnSelectListChange          :TNotifyEvent read FOnSelectListChange write FOnSelectListChange;

  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure Show;

    property ActiveDocument:TGTFDrawDocument read FDocument
                                            write FDocument;
    // Какие части объекта позволяют его выбирать
    property SelectStyle:TAffectedAreaSelectOptions read FSelectStyle
                                            write FSelectStyle;
    // Поведение списка выбора при изменении
    property SelectListStyle:TSelectListStyle read FSelectListStyle
                                            write FSelectListStyle;
    // Какие объекты допустимо добавлять в выбор
    property SelectObjectFilter:TEntityTypes read FSelectObjectFilter
                                            write FSelectObjectFilter;

    property DataBitMap :TBitMap read FDataBitMap;
    property DataBitMapEnabled :Boolean read FDataBitMapEnabled
                                            write FDataBitMapEnabled;

    procedure SetDefaultSettings;

    procedure Repaint; override;

    procedure BeginUpdate;
    procedure EndUpdate;

    procedure ScrollToBegin;
    procedure ScrollToBookmark;
    procedure ScrollToNow;
    procedure RefreshGraphMultiplicity;

    procedure SelectObjectRect(TopLeft, BottomRight: TGTFPoint; AllVertexInRect: Boolean);
    function GetObjectUnderRect(TopLeft, BottomRight: TGTFPoint; AFilterType:TEntityTypes=[etAll]): TEntity;

    procedure TreeObjectClickLeft(TopLeft, BottomRight: TGTFPoint);

    procedure SaveToFileAsJPEG(AFileName:String);

    function GetCursorPoint:TGTFPoint;
    procedure SetViewZeroPoint(AX,AY: Integer);

    procedure MsgMouseWheel(var Msg: TWMMouseWheel);
    //Пересчет идет с учетом размера полотна и смещения его в сторону.
    //Для боковика и шапки не использовать
    function PointSCSToPointWCS(X,Y:Integer):TGTFPoint;
    //Пересчет идет с учетом размера полотна и смещения его в сторону.
    //Для боковика и шапки не использовать
    function PointWCSToPointSCS(X, Y: Integer): TPoint;
    function ValWCSToValSCS(X:Double):Integer;
    //gaLnWtDefault, gaLnWtDouble, gaLnWtTriple
    function ValLineWeightToValPixel(X:TgaLineWeight):Integer;
    //Max 49
    function ValgaColorToValColor(X:TgaColor):TColor;
    function GetIndexRGBColor(X:Integer):TgaColor;

    procedure AddMessageToUser(AText:String);
    procedure SetMessageToUser(AText:String);

    procedure FrameViewModeSet(AText: String; AColor:TColor);
    procedure FrameViewModeClear;

  end;

const
  GridLineWidth = 1;
  NodePaddingTopBottom = 2;
  NodePaddingLeftRight = 2;

  function EntityFilter(AItem:TEntity; AFilterType:TEntityTypes):boolean;
  function FitCoord(AInput:TGTFPoint; AStepX,AStepY:Integer):TGTFPoint;
  function ColorLighter(Color: TColor; Percent: Byte): TColor;
  function ColorDarker(Color: TColor; Percent: Byte): TColor;

implementation

procedure BeginScreenUpdate(hwnd: THandle);
begin
  try
     SendMessage(hwnd, WM_SETREDRAW, 0, 0);
  finally

  end;
end;

procedure EndScreenUpdate(hwnd: THandle; erase: Boolean);
begin
  try
    SendMessage(hwnd, WM_SETREDRAW, 1, 0);
    {RedrawWindow(hwnd, nil, 0, DW_FRAME + RDW_INVALIDATE +
      RDW_ALLCHILDREN + RDW_NOINTERNALPAINT);
    if (erase) then
      Windows.InvalidateRect(hwnd, nil, True); }
  finally

  end;
end;

function ValueSCSToValueWCS(AControl:TGTFControl; X:Integer):Double;
begin
   if Assigned(AControl.ActiveDocument) then
   begin
     result:=X;
   end;
end;

function ValueWCSToValueSCS(AControl:TGTFControl; X:Double):Integer;
begin
   Result:=0;
   if Assigned(AControl.ActiveDocument) then
   begin
     Result:=Trunc(X);
   end;
end;

function EntityFilter(AItem:TEntity; AFilterType:TEntityTypes):boolean;
begin
  if etNone in AFilterType then
  begin
     Result:=False;
  end
  else if etAll in AFilterType then
  begin
     Result:=True;
  end
  else if (etBasicObject in AFilterType)and(AItem is TBasicGridEntity) then
  begin
    Result:=True;
  end
  else if (etTask in AFilterType)and(AItem is TGraphicTask) then
  begin
    Result:=True;
  end
  else if (etFrameLine in AFilterType)and(AItem is TGraphicFrameLine) then
  begin
    Result:=True;
  end
  else if (etConnectionLine in AFilterType)and(AItem is TGraphicConnectionline) then
  begin
    Result:=True;
  end
  else if (etLandmark in AFilterType)and(AItem is TGraphicLandmark) then
  begin
    Result:=True;
  end
  else
  begin
     Result:=False;
  end;
end;

function FitCoord(AInput:TGTFPoint; AStepX,AStepY:Integer):TGTFPoint;
var
   TmpXMin, TmpYMin,
   TmpXMax, TmpYMax,
   TmpX, TmpY, TmpZ :Integer;
begin
  Result.X:=0;
  Result.Y:=0;
  Result.Z:=0;

  TmpX:=AInput.X;
  TmpY:=AInput.Y;
  TmpZ:=AInput.Z;

  TmpXMin:=(Trunc(TmpX) div AStepX)*AStepX;
  TmpYMin:=(Trunc(TmpY) div AStepY)*AStepY;

  if TmpXMin<0 then
  begin
     TmpXMax:=TmpXMin;
     TmpXMin:=TmpXMin-AStepX;

     if abs(TmpX-TmpXMin)<abs(TmpXMax-TmpX) then
         TmpX:=TmpXMin
     else
         TmpX:=TmpXMax;
  end
  else begin
     TmpXMax:=TmpXMin+AStepX;

     if abs(TmpX-TmpXMin)<abs(TmpXMax-TmpX) then
         TmpX:=TmpXMin
     else
         TmpX:=TmpXMax;
  end;

  if TmpYMin<0 then
  begin
     TmpYMax:=TmpYMin;
     TmpYMin:=TmpYMin-AStepY;

     if abs(TmpY-TmpYMin)<abs(TmpYMax-TmpY) then
         TmpY:=TmpYMin
     else
         TmpY:=TmpYMax;
  end
  else begin
     TmpYMax:=TmpYMin+AStepY;

     if abs(TmpY-TmpYMin)<abs(TmpYMax-TmpY) then
         TmpY:=TmpYMin
     else
         TmpY:=TmpYMax;
  end;

  Result.Z:=TmpZ;
  Result.Y:=TmpY;
  Result.X:=TmpX;
end;

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

function ColorLighter(Color: TColor; Percent: Byte): TColor;
var
  r, g, b: Byte;
begin

  Color := ColorToRGB(Color);
  r := GetRValue(Color);
  g := GetGValue(Color);
  b := GetBValue(Color);
  r := r + muldiv(255 - r, Percent, 100);

  //процент% увеличения яркости

  g := g + muldiv(255 - g, Percent, 100);
  b := b + muldiv(255 - b, Percent, 100);
  result := RGB(r, g, b);

end;

Function CompareDateTimeRange(ABegin, AEnd, BBegin, BEnd: TDateTime; ADateScale:TGraphMultiplicity): integer; overload;
begin
   if (CompareDateTime(AEnd,BBegin)<0) then
   begin
       Result:=-1;
   end
   else if (CompareDateTime(ABegin,BEnd)>0) then
   begin
       Result:=1;
   end
   else
   begin
       Result:=0;

       case ADateScale of
          qmMonth,
          gmQuarter:
          begin
               if ((CompareDate(AEnd,BBegin)=0))and(MonthOf(AEnd)=MonthOf(BBegin)) then
               begin
                   Result:=-1;
               end
               else if ((CompareDate(ABegin,BEnd)=0))and(MonthOf(ABegin)=MonthOf(BEnd)) then
               begin
                   Result:=1;
               end
               else
               begin
                  Result:=0;
               end;
          end;
          gmDay,
          gmWeek:
          begin
               if ((CompareDate(AEnd,BBegin)=0)) then
               begin
                   Result:=-1;
               end
               else if ((CompareDate(ABegin,BEnd)=0)) then
               begin
                   Result:=1;
               end
               else
               begin
                  Result:=0;
               end;
          end;
          else
          begin
              Result:=0;
          end;
       end;

   end;
end;

Function CompareDateTimeRange(ABegin, AEnd, BBegin, BEnd: TDateTime): integer; overload;
begin
   if (CompareDateTime(AEnd,BBegin)<0) then
   begin
       Result:=-1;
   end
   else if (CompareDateTime(ABegin,BEnd)>0) then
   begin
       Result:=1;
   end
   else
   begin
      Result:=0;
   end;
end;

{ TGTFControl }

procedure TGTFControl.BeginUpdate;
begin
   inc(FUpdateCount);
   if FUpdateCount=1 then
   begin
     BeginScreenUpdate(Parent.Handle);
     ActiveDocument.Rows.BeginUpdate;
     ActiveDocument.Cols.BeginUpdate;
   end;
end;

procedure TGTFControl.EndUpdate;
begin
   dec(FUpdateCount);
   if FUpdateCount=0 then
   begin
     FDoSecondDraw:=True;
     ActiveDocument.Rows.EndUpdate;
     ActiveDocument.Cols.EndUpdate;

     EndScreenUpdate(Parent.Handle,false);
     Invalidate;
     //Refresh;
     Application.ProcessMessages;
     ScrollToBookmark;
   end;
   if FUpdateCount<0 then
      FUpdateCount:=0;
end;

procedure TGTFControl.ScrollToBegin;
begin
  GetOutsetBorderSizes(Self);
  SetViewZeroPoint(FLeftOutsetBorderWidth,FTopOutsetBorderHeight);
end;

procedure TGTFControl.ScrollToBookmark;
var
  iDX,iDY,i,y1,y2:integer;
  ColItem:TGTFCOutsetTreeColItem;
  RowItem:TGTFCOutsetTreeRowItem;
  bHorizontal,bVertical:Boolean;

  bScrollBarVerticalUpdate    : Boolean;
  bScrollBarHorizontalUpdate  : Boolean;
begin
  GetOutsetBorderSizes(Self);

  bScrollBarVerticalUpdate    :=FScrollBarVerticalUpdate;
  bScrollBarHorizontalUpdate  :=FScrollBarHorizontalUpdate;
  FScrollBarVerticalUpdate   := True;
  FScrollBarHorizontalUpdate := True;

  bHorizontal :=False;
  bVertical   :=False;

  iDX:=ActiveDocument.ViewPos.X;
  iDY:=ActiveDocument.ViewPos.Y;

  if ActiveDocument.ViewBookmark.HBookmark then
  begin
    i:=ActiveDocument.GetColByDateTime(ActiveDocument.ViewBookmark.HBookmarkValue);
    if i>-1 then
    begin
        ColItem:=TGTFCOutsetTreeColItem(ActiveDocument.Cols.Items[i]);
        iDX:=ColItem.BeginX;
        bHorizontal :=True;
    end;

  end;

  if ActiveDocument.ViewBookmark.VBookmark and not(varisnull(ActiveDocument.ViewBookmark.VBookmarkValue)) then
  begin

  end;

  for i:=0 to ActiveDocument.Rows.count-1 do
  begin
    if ActiveDocument.Rows.Items[i].GridIndex=ActiveDocument.Rows.EndItemCount-1 then
    begin
       RowItem :=TGTFCOutsetTreeRowItem(ActiveDocument.Rows.Items[i]);
       y1      :=ActiveDocument.ViewPos.Y;
       y2      :=RowItem.EndY;
       if y1<0-y2 then
       begin
          iDY:=FTopOutsetBorderHeight;
       end;

       break;
    end;
  end;

  if bHorizontal then
  begin
    FScrollBarHorizontal.Min         :=0;
    FScrollBarHorizontal.Max         :=FColWSizeSum;
    FScrollBarHorizontal.Position    :=ABS(iDX);
    FScrollBarHorizontal.PageSize    :=vbpWidth-FLeftOutsetBorderWidth;
    FScrollBarHorizontal.SmallChange :=ColWidth;
    FScrollBarHorizontal.LargeChange :=vbpWidth-ColWidth;
    iDX:=-1*ABS(iDX)+FLeftOutsetBorderWidth;
  end;

  if bVertical then
  begin
    FScrollBarVertical.Min         :=0;
    FScrollBarVertical.Max         :=FRowHSizeSum;
    FScrollBarVertical.Position    :=ABS(iDY);//-FTopOutsetBorderHeight
    FScrollBarVertical.PageSize    :=vbmHeight-FTopOutsetBorderHeight;
    FScrollBarVertical.SmallChange :=RowHeight;
    FScrollBarVertical.LargeChange :=vbmHeight-RowHeight;
    iDY:=-1*ABS(iDY)+FTopOutsetBorderHeight;
  end;

  SetViewZeroPoint(iDX,iDY);

  FScrollBarVerticalUpdate   := bScrollBarVerticalUpdate;
  FScrollBarHorizontalUpdate := bScrollBarHorizontalUpdate;
end;

procedure TGTFControl.ScrollToNow;
begin
  ScrollToBegin;
  ActiveDocument.BookmarkToNow;
  ScrollToBookmark;
end;

procedure TGTFControl.RefreshGraphMultiplicity;
begin
  BeginUpdate;
  RefreshColls;
  EndUpdate;
end;

constructor TGTFControl.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FDocument                          :=nil;
  FFirstPaint                        :=True;
  FDevelop                           :=False;//информация для разработчика
  FDrawRowCounter                    :=0;
  FUpdateCount                       :=0;
  FRowHSizeSum                       :=0;
  FColWSizeSum                       :=0;
  FDeltaCord                         :=6; //Размеры вершин при отрисовке
  FCursorDeltaSize                   :=0; //Дельта пикселей при кликах по полю
  GridScale                          :=100;
  RowHeight                          :=26; //Высота строки
  ColWidth                           :=20; //Ширина столбца
  FLeftOutsetBorderRowNumWidth       :=0;
  FColExtWidth                       :=100;
  FLeftOutsetBorderWidth             :=100;
  FLeftOutsetBorderVCapWidth         :=24;
  FTopOutsetBorderHeight             :=50;
  FSelectStyle                       :=[aasoINSIDE]; //[aasoBASEPOINT]+[aasoVERTEX]+[aasoBORDER]+
  FSelectListStyle                   :=[];
  FSelectObjectFilter                :=[etAll];
  FDefaultFont                       :=TFont.Create;

  FMessagesList                      :=TStringList.Create;
  FTimerMessage                      :=TTimer.Create(AOwner);
  FTimerMessage.Name                 :=Name+'TimerMessage';
  FTimerMessage.Enabled              :=False;
  FTimerMessage.OnTimer              :=@TimerMessageOnTimer;

  FScrollBarHorizontal                :=TScrollBar.Create(Parent);
  FScrollBarHorizontal.Name           :=Name+'ScrollBarHorizontal';
  FScrollBarHorizontal.Height         :=17;
  FScrollBarHorizontal.Kind           :=sbHorizontal;
  FScrollBarHorizontal.Align          :=alBottom;
  FScrollBarHorizontal.OnScroll       :=@OnHorizontalScroll;
  FScrollBarHorizontalUpdate          :=False;

  FScrollBarVertical                :=TScrollBar.Create(Parent);
  FScrollBarVertical.Name           :=Name+'ScrollBarVertical';
  FScrollBarVertical.Height         :=17;
  FScrollBarVertical.Kind           :=sbVertical;
  FScrollBarVertical.Align          :=alRight;
  FScrollBarVertical.OnScroll       :=@OnVerticalScroll;
  FScrollBarVerticalUpdate          :=False;

  FFrameViewModeText                 :='';
  FFrameViewModeColor                :=clGreen;

  FCursorPos.X                       :=0;
  FCursorPos.Y                       :=0;

  FMouseButtonUp                     :=gmbNone;
  FMouseButtonDown                   :=gmbNone;

  FDrawFont                          :=True;
  FMouseButtonPressed                :=False;
  FMouseButtonUpPos.X                :=0;
  FMouseButtonUpPos.Y                :=0;
  FMouseButtonDownPos.X              :=0;
  FMouseButtonDownPos.Y              :=0;

  FMousePosMoveVertexLast.X          :=0;
  FMousePosMoveVertexLast.Y          :=0;

  FMousePosMoveVertexDelta.X         :=0;
  FMousePosMoveVertexDelta.Y         :=0;

  FMouseMoveVertexEnable             :=False;

  FClickCount                        :=0;
  FControlAction                     :=[caNone];

  FKStep                             :=1;
  FCurSec                            :=0;

  FRuleStepA                         :=100;
  FRuleStepB                         :=50;

  FAntiLayering                      :=False;
  FShowGroupHorizontal               :=False;

  FTodayWayLine                      :=True;
  FWayLine                           :=False;
  FGrid                              :=True;
  FGridColor                         :=clActiveBorder;

  FLogicalDraw                      :=TLogicalDraw.create;
  FDrawLayerMain                    :=TBitMap.Create;
  FDrawLayerMainCanvas              :=FDrawLayerMain.Canvas;

  FDrawLayerOutsetBorder            :=TBitMap.Create;
  FDrawLayerOutsetBorderCanvas      :=FDrawLayerOutsetBorder.Canvas;

  FDrawLayerOutsetBorder.Transparent:=False;
  //FDrawLayerOutsetBorder.TransparentMode:=tmFixed;
  //FDrawLayerOutsetBorder.TransparentColor:=clFuchsia;

  FDrawLayerMain.Transparent:=False;
  //FDrawLayerMain.TransparentMode:=tmFixed;
  //FDrawLayerMain.TransparentColor:=clFuchsia;

  { При включенной прозрачности лагает отрисовка, появляются артефакты}

  FDataBitMap                       :=TBitMap.Create;
  FDataBitMapEnabled                :=False;
  FDataBitMapTmpX                   :=0;
  FDataBitMapTmpY                   :=0;

  FHintDrawBitMap                   :=TBitMap.Create;
  FHintDrawBitMap.Transparent       :=False;

  FEntityFirstDrawBitMap            :=TBitMap.Create;
  FEntityFirstDrawBitMap.Transparent:=False;

  FPlusBM                           :=TBitMap.Create;
  FPlusBM.Transparent               :=False;

  FMinusBM                          :=TBitMap.Create;
  FMinusBM.Transparent              :=False;

  FHotPlusBM                        :=TBitMap.Create;
  FHotPlusBM.Transparent            :=False;

  FHotMinusBM                       :=TBitMap.Create;
  FHotMinusBM.Transparent           :=False;

  FFlagBM                           :=TBitMap.Create;
  FFlagBM.Transparent               :=False;

  FArrowDownBM                      :=TBitMap.Create;
  FArrowDownBM.Transparent          :=False;

  FFormWindowProc                   :=TCustomForm(AOwner).WindowProc;
  TCustomForm(AOwner).WindowProc    :=@SuperWndProc;//WindowProc

    FSelfOnClick                     :=nil;
    FPopupGridArea                   :=nil;
    FPopupLeftOutsetArea             :=nil;
    FSelfOnDblClick                  :=nil;
    FSelfOnMouseDown                 :=nil;
    //FSelfOnMouseEnter                :=nil;
    //FSelfOnMouseLeave                :=nil;
    FSelfOnMouseMove                 :=nil;
    FSelfOnMouseUp                   :=nil;
    FSelfOnMouseWheel                :=nil;
    FSelfOnMouseWheelDown            :=nil;
    FSelfOnMouseWheelUp              :=nil;
    FSelfOnPaint                     :=nil;
    FOnChangeGridScale               :=nil;

   //Блокируем штатную обработку свойств, чтобы обрабатывать самостоятельно
   inherited OnClick                 :=nil;//См.SuperClick;
   inherited OnDblClick              :=nil;//См.SuperDblClick;
   inherited OnMouseDown             :=@SuperMouseDown;
   //inherited OnMouseEnter          :=@SuperMouseEnter;
   //inherited OnMouseLeave          :=@SuperMouseLeave;
   inherited OnMouseMove             :=@SuperMouseMove;
   inherited OnMouseUp               :=@SuperMouseUp;
   inherited OnMouseWheel            :=@SuperMouseWheel;
   inherited OnMouseWheelDown        :=@SuperMouseWheelDown;
   inherited OnMouseWheelUp          :=@SuperMouseWheelUp;
   inherited OnPaint                 :=@SuperPaint;

   FLogicalDraw.OnSetStyle           :=@SetStyleDraw;
   FLogicalDraw.OnSetFontStyle       :=@SetFontStyleDraw;
   FLogicalDraw.OnLineDraw           :=@LineDraw;
   FLogicalDraw.OnPolylineDraw       :=@PolylineDraw;
   FLogicalDraw.OnLineSDraw          :=@LineSDraw;
   FLogicalDraw.OnCircleDraw         :=@CircleDraw;
   FLogicalDraw.OnArcDraw            :=@ArcDraw;
   FLogicalDraw.OnPointDraw          :=@PointDraw;
   FLogicalDraw.OnEllipseDraw        :=@EllipseDraw;
   FLogicalDraw.OnTextDraw           :=@TextDraw;
   FLogicalDraw.OnVertexDraw         :=@VertexDraw;
   FLogicalDraw.OnPolygonDraw        :=@PolygonDraw;
   FLogicalDraw.OnRectangelDraw      :=@RectangelDraw;
   FLogicalDraw.OnFillDraw           :=@FillDraw;
   FLogicalDraw.OnGetGridScale       :=@GetGridScale;
   FLogicalDraw.OnGetTextWidth       :=@GetTextWidth;
   FLogicalDraw.OnGetTextHeight      :=@GetTextHeight;

   FOnSelectListChange               :=nil;

   FOnOutsetTreeItemFilterEvent      :=nil;
   FOnOutsetTreeRowEvent             :=nil;

   FOnEntitySelectEvent              :=nil;
   FOnEntityBeforeDrawEvent          :=nil;
   FOnEntityAfterDrawEvent           :=nil;
   FOnEntityFilterEvent              :=nil;
   FOnEntityEditEvent                :=nil;
   FOnEntityBeforeEditEvent          :=nil;
   FOnEntityAfterEditEvent           :=nil;
   FOnBeforeDrawEvent                :=nil;
   FOnAfterDrawEvent                 :=nil;

   FOnColBGBeforeDrawEvent           :=nil;

   SupportImageCreate(Self);
   SetDefaultSettings;

    ActiveDocument                     :=TGTFDrawDocument.Create(self);
    if Assigned(ActiveDocument)then
    begin
         ActiveDocument.OnChange       :=@MainControlPaint;
    end;

    ActiveDocument.FGridLineWidth        :=GridLineWidth;
    ActiveDocument.FNodePaddingTopBottom :=NodePaddingTopBottom;
    ActiveDocument.FNodePaddingLeftRight :=NodePaddingLeftRight;

    ScrollToBegin;
end;

destructor TGTFControl.Destroy;
begin
  if Assigned(Owner) then
  begin
       TCustomForm(Owner).WindowProc :=FFormWindowProc;
  end;
  FFormWindowProc :=nil;

  if Assigned(FDocument) then
  begin
     FDocument.Free;
     FDocument:=nil;
  end;

  FScrollBarVertical.Free;
  FScrollBarHorizontal.Free;

  FMessagesList.Free;
  FLogicalDraw.Free;
  FDrawLayerMain.Free;

  FDrawLayerOutsetBorder.Free;
  FEntityFirstDrawBitMap.Free;
  FHintDrawBitMap.Free;

  FPlusBM.Free;
  FMinusBM.Free;
  FHotPlusBM.Free;
  FHotMinusBM.Free;
  FArrowDownBM.Free;
  FFlagBM.Free;

  FDefaultFont.Free;
  FDataBitMap.Free;
  inherited Destroy;
end;

procedure TGTFControl.Show;
begin
  inherited Show;

  FScrollBarHorizontal.Parent       :=Parent;
  FScrollBarHorizontal.Enabled      :=True;
  FScrollBarHorizontal.Visible      :=True;

  FScrollBarVertical.Parent         :=Parent;
  FScrollBarVertical.Enabled        :=True;
  FScrollBarVertical.Visible        :=True;

end;

procedure TGTFControl.ZeroPointCSPaint;
var
  rsize,lsize:integer;
  ZeroPointCS:TPoint;
begin
  if FDevelop then
  begin
   ZeroPointCS                              :=PointWCSToPointSCS(0,0);

   rsize                                    :=5;
   lsize                                    :=30;
   // Рисуем нулевую точку координатной системы
   FDrawLayerMainCanvas.Font.Assign(FDefaultFont);
   FDrawLayerMainCanvas.Brush.Color               :=clRed;
   FDrawLayerMainCanvas.Brush.Style               :=bsClear;
   FDrawLayerMainCanvas.Pen.Style                 :=psSolid;
   FDrawLayerMainCanvas.Pen.Color                 :=clRed;
   FDrawLayerMainCanvas.Pen.Mode                  :=pmNot;

   FDrawLayerMainCanvas.Pen.Width                 :=1;
   FDrawLayerMainCanvas.MoveTo (ZeroPointCS.X,ZeroPointCS.Y);
   FDrawLayerMainCanvas.LineTo (ZeroPointCS.X+lsize,ZeroPointCS.Y);

   FDrawLayerMainCanvas.MoveTo (ZeroPointCS.X,ZeroPointCS.Y);
   FDrawLayerMainCanvas.LineTo (ZeroPointCS.X,ZeroPointCS.Y-lsize);


   FDrawLayerMainCanvas.MoveTo (ZeroPointCS.X-rsize,ZeroPointCS.Y-rsize);
   FDrawLayerMainCanvas.LineTo (ZeroPointCS.X+rsize,ZeroPointCS.Y-rsize);
   FDrawLayerMainCanvas.LineTo (ZeroPointCS.X+rsize,ZeroPointCS.Y+rsize);
   FDrawLayerMainCanvas.LineTo (ZeroPointCS.X-rsize,ZeroPointCS.Y+rsize);
   FDrawLayerMainCanvas.LineTo (ZeroPointCS.X-rsize,ZeroPointCS.Y-rsize);

   FDrawLayerMainCanvas.Brush.Color               :=FBackgroundColor;
   FDrawLayerMainCanvas.Brush.Style               :=bsclear;
   FDrawLayerMainCanvas.Pen.Color                 :=FBackgroundColor;
   FDrawLayerMainCanvas.Font.Color                :=clWhite;
   FDrawLayerMainCanvas.TextOut(ZeroPointCS.X+lsize,ZeroPointCS.Y-5,'X');
   FDrawLayerMainCanvas.TextOut(ZeroPointCS.X,ZeroPointCS.Y-lsize-15,'Y');
  end;
end;

procedure TGTFControl.SelectRectPaint(X1, Y1, X2, Y2: Integer);
var
    ARect:TRect;
begin

  if X1<=X2 then
  begin
    FDrawLayerMainCanvas.Pen.Color:=FSelectRightColor;
    FDrawLayerMainCanvas.Pen.Style:=psSolid;
    if Y1<=Y2 then
    begin
      ARect:=Rect(X1,Y1,X2,Y2);
    end
    else begin
      ARect:=Rect(X1,Y2,X2,Y1);
    end;
  end
  else begin
    FDrawLayerMainCanvas.Pen.Color:=FSelectLeftColor;
    FDrawLayerMainCanvas.Pen.Style:=psDot;
    if Y1<=Y2 then
    begin
      ARect:=Rect(X2,Y1,X1,Y2);
    end
    else begin
      ARect:=Rect(X2,Y2,X1,Y1);
    end;
  end;

   FDrawLayerMainCanvas.Brush.Color := clblack;
   FDrawLayerMainCanvas.Pen.Mode:=pmCopy;
   FDrawLayerMainCanvas.Pen.Width:=1;

   FDrawLayerMainCanvas.MoveTo (ARect.TopLeft.X,ARect.TopLeft.Y);
   FDrawLayerMainCanvas.LineTo (ARect.BottomRight.X,ARect.TopLeft.Y);
   FDrawLayerMainCanvas.LineTo (ARect.BottomRight.X,ARect.BottomRight.Y);
   FDrawLayerMainCanvas.LineTo (ARect.TopLeft.X,ARect.BottomRight.Y);
   FDrawLayerMainCanvas.LineTo (ARect.TopLeft.X,ARect.TopLeft.Y);

end;

procedure TGTFControl.SetDefaultSettings;
begin
    FSelectLeftColor                          :=clLime;
    FSelectRightColor                         :=clBlue;
    FVertexSelectColor                        :=clHighLight;
    FVertexBasePointColor                     :=clBlue;
    FVertexCustomColor                        :=clNavy;
    FBackgroundColor                          :=clWindow;
    FCursorColor                              :=clHighLight;
    FDrawCursorStyle                          :=csOSAuto;
    FDefaultFont.Assign(Screen.SystemFont);
    FDefaultFont.Color                        :=not FBackgroundColor;
    FDefaultFont.Size                         :=8;
    FDefaultFont.Style                        :=[];
    FLogicalDraw.Develop                      :=FDevelop;
    FSelectObjectFilter                       :=[etAll];

    FTreeButtonStyle                          :=gtbsTriangle;//gtbsDot,gtbsRectangle,gtbsNot

    FGraphMultiplicity                        :=gmDay;
    FGraphDrawDatePrecision                   :=True;
    FGraphDateTimeBegin                       :=DateUtils.IncDay(Now,-65);
    FGraphDateTimeEnd                         :=DateUtils.RecodeDate(Now,YearOf(Now)+1,MonthOf(Now),1);
end;

procedure TGTFControl.Repaint;
begin
  inherited Repaint;
end;

function TGTFControl.GetObjectUnderRect(TopLeft, BottomRight: TGTFPoint;
  AFilterType: TEntityTypes): TEntity;
var
  i, Answer  :integer;
  Item       :TEntity;
  MVertx     :TModifyVertex;
begin
  MVertx.Item        :=nil;
  MVertx.VertexIndex :=-100;
  MVertx.VertexPos.X :=0;
  MVertx.VertexPos.Y :=0;
  MVertx.VertexPos.Z :=0;
  Result             :=nil;

  i:=ActiveDocument.FViewPos.X;
  i:=TopLeft.X+i;
  if (i<FLeftOutsetBorderWidth)then
  begin
    Result  :=nil;
  end
  else begin
    for I := 0 to ActiveDocument.ModelSpace.Objects.Count - 1 do
    begin
        Item:=ActiveDocument.ModelSpace.Objects.Items[i];
        if (not (esCreating in Item.State))and(EntityFilter(Item, AFilterType)) then
        begin
            Answer:=Item.GetSelect(TopLeft, BottomRight, False, MVertx);
            if Answer<>AFFA_OUTSIDE then
            begin
                  if (((Answer=AFFA_VERTEX)and(aasoVERTEX in FSelectStyle))
                  or((Answer=AFFA_BASEPOINT)and(aasoBASEPOINT in FSelectStyle))
                  or((Answer=AFFA_INSIDE)and(aasoINSIDE in FSelectStyle))
                  or((Answer=AFFA_BORDER)and(aasoBORDER in FSelectStyle))) then
                  begin
                       Result:=Item;
                       break;
                  end;
            end;
        end;
    end;
  end;
end;

procedure TGTFControl.TreeObjectClickLeft(TopLeft, BottomRight: TGTFPoint);
var
  i                :integer;
  Answer           :TGTFCOutsetTreeClickResult;
  Item             :TGTFCOutsetTreeBasicItem;
begin
  for I := 0 to ActiveDocument.Rows.Count - 1 do
  begin
        Item:=ActiveDocument.Rows.Items[i];
        Answer:=Item.GetClickResult(Point(TopLeft.X,TopLeft.Y),Point(BottomRight.X,BottomRight.Y));
        if Answer<>tcrNone then
        begin
          if Assigned(FOnOutsetTreeRowEvent) then
             FOnOutsetTreeRowEvent(Self,Item,Answer);
             break;
        end;
  end;
end;

procedure TGTFControl.SelectObjectRect(TopLeft, BottomRight: TGTFPoint;
  AllVertexInRect: Boolean);
var
  i,k,index,
  Answer,iCountSelected   :integer;
  Item2,
  Item             :TEntity;
  MVertx           :TModifyVertex;
  CanSelect,
  CallOnSelectListChange:Boolean;
begin

  iCountSelected:=0;
  CallOnSelectListChange:=False;
  for I := 0 to ActiveDocument.ModelSpace.Objects.Count - 1 do
  begin
      Item:=ActiveDocument.ModelSpace.Objects.Items[i];
      if (not (esCreating in Item.State))and(EntityFilter(Item, FSelectObjectFilter)) then
      begin
          MVertx.Item       :=nil;
          MVertx.VertexIndex:=-100;
          MVertx.VertexPos.X:=0;
          MVertx.VertexPos.Y:=0;
          MVertx.VertexPos.Z:=0;

          Item.State:=Item.State-[esSelected];
          Answer:=Item.GetSelect(TopLeft, BottomRight, AllVertexInRect,MVertx);
          if Answer<>AFFA_OUTSIDE then
          begin
              CanSelect:=True;
              if Assigned(ActiveDocument.FSelectList) then
              begin
                  inc(iCountSelected);
                  index:=ActiveDocument.FSelectList.IndexOf(Item);
                  if index>-1 then
                  begin
                     if ssShift in FMouseButtonUpShift then
                     begin
                        ActiveDocument.FSelectList.Remove(Item);
                     end
                     else if (((Answer=AFFA_VERTEX)and(aasoVERTEX in FSelectStyle))
                          or((Answer=AFFA_BASEPOINT)and(aasoBASEPOINT in FSelectStyle))or((Answer=AFFA_INSIDE)and(aasoINSIDE in FSelectStyle)))and(not AllVertexInRect) then
                     begin
                        if ((Answer=AFFA_VERTEX))then
                        begin
                           if not (ssShift in FMouseButtonUpShift) then
                              ClearMoveVertex;
                            if MVertx.Item<>nil then
                            begin
                               MVertx.Item.State:=MVertx.Item.State+[esEditing];
                               ActiveDocument.MVertArray(MVertx);
                            end;
                        end
                        else if ((Answer=AFFA_BASEPOINT)) then
                        begin
                            if not (ssShift in FMouseButtonUpShift) then
                              ClearMoveVertex;
                            if MVertx.Item<>nil then
                            begin
                               MVertx.Item.State:=MVertx.Item.State+[esMoving];
                               ActiveDocument.MVertArray(MVertx);
                            end;
                        end
                        else if ((Answer=AFFA_INSIDE)) then
                        begin
                            if not (ssShift in FMouseButtonUpShift) then
                              ClearMoveVertex;
                            if MVertx.Item<>nil then
                            begin
                               MVertx.Item.State:=MVertx.Item.State+[esMoving];
                               ActiveDocument.MVertArray(MVertx);
                            end;
                        end;
                     end;
                  end
                  else if (((Answer=AFFA_VERTEX)and(aasoVERTEX in FSelectStyle))
                  or((Answer=AFFA_BASEPOINT)and(aasoBASEPOINT in FSelectStyle))
                  or((Answer=AFFA_INSIDE)and(aasoINSIDE in FSelectStyle))
                  or((Answer=AFFA_BORDER)and(aasoBORDER in FSelectStyle))) then
                  begin
                    if Assigned(FOnEntitySelectEvent) then
                       FOnEntitySelectEvent(Self,Item,CanSelect);
                    if CanSelect then
                    begin
                       if (slsSumSelection in FSelectListStyle)or(ssCtrl in FMouseButtonDownShift)
                         or(AllVertexInRect and not(ssCtrl in FMouseButtonDownShift) and not(slsSumSelection in FSelectListStyle)) then
                       begin
                         ActiveDocument.FSelectList.Add(Item);
                         Item.State:=Item.State+[esSelected];
                       end
                       else begin
                         for k:=0 to ActiveDocument.FSelectList.Count-1 do
                         begin
                             item2:=TEntity(ActiveDocument.FSelectList.Items[k]);
                             Item2.State:=Item2.State-[esSelected];
                         end;
                         ActiveDocument.FSelectList.Clear;
                         ActiveDocument.FSelectList.Add(Item);
                         Item.State:=Item.State+[esSelected];
                       end;
                    end;
                  end;
                  CallOnSelectListChange:=True;
              end;
          end;
      end;
  end;

  if (iCountSelected=0)and(slsClearOnNullClick in FSelectListStyle) then
  begin
     for k:=0 to ActiveDocument.FSelectList.Count-1 do
     begin
         item2:=TEntity(ActiveDocument.FSelectList.Items[k]);
         Item2.State:=Item2.State-[esSelected];
     end;
     ActiveDocument.FSelectList.Clear;
  end;

  if Assigned(OnSelectListChange)and CallOnSelectListChange then
     OnSelectListChange(self);
end;

{ Super section}

procedure TGTFControl.SuperClick(Sender: TObject);
begin
    if Assigned(FSelfOnClick) then
    FSelfOnClick(Sender);
end;

procedure TGTFControl.SuperDblClick(Sender: TObject);
begin
    if Assigned(FSelfOnDblClick) then
    FSelfOnDblClick(Sender);
end;

procedure TGTFControl.BeginMoveVertex(Sender: TObject);
//var
//  i,count :integer;
//  Item    :TEntity;
begin
  {
  if caMoveVertex in FControlAction then
  begin
      Count:=Length(ActiveDocument.FMVertArray);

      for I := 0 to count - 1 do
      begin
          Item       :=ActiveDocument.FMVertArray[i].Item;
          if Assigned(Item) then
          begin
             Item.State:=Item.State+[esMoving];
          end;
      end;
  end;
  }
end;

procedure TGTFControl.EndMoveVertex(Sender: TObject);
var
  i,count :integer;
  Item    :TEntity;
begin
  if caMoveVertex in FControlAction then
  begin
      Count:=Length(ActiveDocument.FMVertArray);

      for I := 0 to count - 1 do
      begin
          Item  :=ActiveDocument.FMVertArray[i].Item;
          if Assigned(Item) then
          begin
             Item.State:=Item.State-[esMoving,esEditing];
          end;
      end;

      SetLength(ActiveDocument.FMVertArray,0);
  end;
end;

procedure TGTFControl.ClearMoveVertex;
var
  i,count :integer;
  Item    :TEntity;
begin
      Count:=Length(ActiveDocument.FMVertArray);

      for I := 0 to count - 1 do
      begin
          Item       :=ActiveDocument.FMVertArray[i].Item;
          if Assigned(Item) then
          begin
             Item.State:=Item.State-[esMoving,esEditing];
          end;
      end;

      SetLength(ActiveDocument.FMVertArray,0);
end;

procedure TGTFControl.EndSelecting(Sender: TObject);
var
  tmpWCSPoint1,tmpWCSPoint2:TGTFPoint;
  ARect:TRect;
  X1,X2,Y1,Y2:integer;
  AllVertexInRect:boolean;
begin

  if (FControlAction=[caSelectObject]) then
  begin
      AllVertexInRect:=false;
      X1:=FMouseButtonDownPos.X;
      Y1:=FMouseButtonDownPos.Y;
      X2:=FMouseButtonUpPos.X;
      Y2:=FMouseButtonUpPos.Y;
      if X1<=X2 then
      begin
        AllVertexInRect:=true;
        if Y1<=Y2 then
        begin
          ARect:=Rect(X1,Y1,X2,Y2);
        end
        else begin
          ARect:=Rect(X1,Y2,X2,Y1);
        end;
      end
      else begin
        AllVertexInRect:=false;
        if Y1<=Y2 then
        begin
          ARect:=Rect(X2,Y1,X1,Y2);
        end
        else begin
          ARect:=Rect(X2,Y2,X1,Y1);
        end;
      end;
      tmpWCSPoint1:=PointSCSToPointWCS(ARect.TopLeft.X,ARect.TopLeft.Y);
      tmpWCSPoint2:=PointSCSToPointWCS(ARect.BottomRight.X,ARect.BottomRight.Y);
      SelectObjectRect(tmpWCSPoint1,tmpWCSPoint2,AllVertexInRect);
  end;
end;

procedure TGTFControl.SuperLeftButtonClick(Sender: TObject);
var
  tmpWCSPoint1,tmpWCSPoint2:TGTFPoint;
  h:integer;
begin
  if (FControlAction=[caClickLeft]) then
  begin
      h:=FCursorDeltaSize;
      tmpWCSPoint1:=PointSCSToPointWCS(FCursorPos.X-h,FCursorPos.Y-h);
      tmpWCSPoint2:=PointSCSToPointWCS(FCursorPos.X+h,FCursorPos.Y+h);
      SelectObjectRect(tmpWCSPoint1,tmpWCSPoint2,false);

      tmpWCSPoint1:=GTFPoint(FCursorPos.X,FCursorPos.Y,0);
      tmpWCSPoint2:=GTFPoint(FCursorPos.X,FCursorPos.Y,0);
      TreeObjectClickLeft(tmpWCSPoint1,tmpWCSPoint2);
  end;
end;

procedure TGTFControl.SuperEditingDone(Sender: TObject);
begin
  if Assigned(FOnEditingDone) then
  FOnEditingDone(Sender);
end;

procedure TGTFControl.SuperMiddleButtonDblClick(Sender: TObject);
begin
  //Do somebody
end;

procedure TGTFControl.SuperBeforeEntityEdit(AEntity: TEntity;
  var ACanEdit: Boolean);
begin
  if Assigned(FOnEntityBeforeEditEvent) then
     FOnEntityBeforeEditEvent(self, AEntity, ACanEdit);
end;

procedure TGTFControl.SuperAfterEntityEdit(AEntity: TEntity);
begin
  if Assigned(FOnEntityAfterEditEvent) then
     FOnEntityAfterEditEvent(self, AEntity);
end;

procedure TGTFControl.SuperEntityEdit(AEntity: TEntity; AColIndex,
  ARowIndex: integer);
begin
  if Assigned(FOnEntityEditEvent) then
     FOnEntityEditEvent(Self, AEntity,AColIndex, ARowIndex);
end;

procedure TGTFControl.gaMoveVertexAction(Sender: TObject);
var
  i,count,ir,ic :integer;
  Item    :TEntity;
  CurCord,
  NewCord :TGTFPoint;
  CanEdit :Boolean;
begin
  if caMoveVertex in FControlAction then
  begin
      Count:=Length(ActiveDocument.FMVertArray);
      for I := 0 to count - 1 do
      begin
          Item    :=ActiveDocument.FMVertArray[i].Item;
          CanEdit :=True;
          SuperBeforeEntityEdit(Item, CanEdit);
          if CanEdit then
          begin
            CurCord    :=ActiveDocument.FMVertArray[i].VertexPos;
            NewCord.Y  :=CurCord.Y+FMousePosMoveVertexDelta.Y+FDeltaCord;
            NewCord.X  :=CurCord.X+FMousePosMoveVertexDelta.X;
            NewCord.Z  :=CurCord.Z;

            ic         :=ActiveDocument.GetColUnderPoint(NewCord);
            ir         :=ActiveDocument.GetRowUnderPoint(NewCord);
            SuperEntityEdit(Item,ic,ir);
            //Item.MoveVertex(ActiveDocument.FMVertArray[i].VertexIndex, NewCord);
            ActiveDocument.FMVertArray[i].VertexPos:=NewCord;
            SuperAfterEntityEdit(Item);
          end;
      end;
  end;
end;

procedure TGTFControl.gaMouseAction(Sender: TObject);
var
  bSelectedEntity:Boolean;
begin
    bSelectedEntity:=False;
    if Assigned(ActiveDocument) then
    begin
        bSelectedEntity:=(ActiveDocument.SelectList.Count>0);
        if (FMouseButtonUp=gmbMiddle)and(FMouseButtonDown=gmbMiddle)and(not FMouseButtonPressed)then //mbMiddle
        begin
            {
            if FControlAction=[caMoveSpace] then
            begin
                FControlAction:=[caNone];
            end
            else if FControlAction=[caNone] then
            begin
                FControlAction:=[caMoveSpace];
                //Procedure(self);
            end;
            }
            if FClickCount=0 then
            begin

            end
            else if FClickCount=2 then
            begin
                {
                if FControlAction=[caNone] then
                begin
                  FControlAction:=[caZoomToFit];
                  SuperMiddleButtonDblClick(self);
                  FControlAction:=[caNone];
                end;
                }
            end;
        end
        else if (FMouseButtonDown=gmbMiddle)and(FMouseButtonPressed)then //mbMiddle
        begin
            {
            if FControlAction=[caNone] then
            begin
                FControlAction:=[caMoveSpace];
                //Procedure(self);
                FControlAction:=[caNone];
            end;
            }
        end
        else if (FMouseButtonUp=gmbLeft)and(FMouseButtonDown=gmbLeft)and(not FMouseButtonPressed)then //Левая отпущена
        begin

            if (ActiveDocument.EditMode in [eemReadOnly])and(FControlAction=[caMoveSpace]) then
            begin
                FControlAction:=[caNone];
                //обображение курсора
                if FDrawCursorStyle=csOSAuto then
                begin
                   Cursor:=crArrow;
                end;
            end
            else if (ActiveDocument.EditMode in [eemSelectOnly])and(FControlAction=[caMoveSpace]) then
            begin
                FControlAction:=[caNone];
                //обображение курсора
                if FDrawCursorStyle=csOSAuto then
                begin
                   Cursor:=crArrow;
                end;
            end;

            if (FControlAction=[caSelectObject])or(FControlAction=[caNone]) then
            begin
                if (FMouseButtonDownPos.X=FMouseButtonUpPos.X)and(FMouseButtonDownPos.Y=FMouseButtonUpPos.Y) then
                begin
                  FControlAction:=[caClickLeft];
                  SuperLeftButtonClick(self); //Быстрый клик
                  FControlAction:=[caNone];
                end
                else begin
                  EndSelecting(self);
                  FControlAction:=[caNone];
                end;
            end;

            if  FControlAction=[caMoveVertex] then
            begin
               if FMouseMoveVertexEnable then  //Если было перемещение объектов
               begin
                  gaMoveVertexAction(self); //Перемещение объектов
                  FMouseMoveVertexEnable      :=False;
               end;
               EndMoveVertex(self);
               FControlAction:=[caNone];
               SuperEditingDone(self);
            end;
        end
        else if (FMouseButtonDown=gmbLeft)and(FMouseButtonPressed)then //Левая зажата
        begin
              if (FControlAction=[caNone])and not(ActiveDocument.EditMode in [eemReadOnly,eemSelectOnly]) then //(not ActiveDocument.ReadOnlyMode)
              begin
                if Length(ActiveDocument.FMVertArray)=0 then
                begin

                    {if (ActiveDocument.EditMode = eemReadOnly) then
                    begin
                       FControlAction:=[caMoveSpace];
                        //обображение курсора
                        if FDrawCursorStyle=csOSAuto then
                        begin
                           Cursor:=crSize;
                        end;
                    end;}

                end
                else if (not(eemSelectOnly = ActiveDocument.EditMode)) then
                  FControlAction:=[caMoveVertex]
                else
                  FControlAction:=[caMoveSpace];
                  // FControlAction:=[caSelectObject];
                  // Обработка перемещения в MouseMove
              end
              else if (FControlAction=[caNone])and (ActiveDocument.EditMode in [eemReadOnly]) then
              begin
                        FControlAction:=[caMoveSpace];
                        //обображение курсора
                        if (FDrawCursorStyle=csOSAuto) and bSelectedEntity then
                        begin
                           Cursor:=crSize;
                        end;
              end
              else if (FControlAction=[caNone])and (ActiveDocument.EditMode in [eemSelectOnly]) then
              begin
                        FControlAction:=[caMoveSpace];
                        //обображение курсора
                        if (FDrawCursorStyle=csOSAuto) and bSelectedEntity then
                        begin
                           Cursor:=crSize;
                        end;
              end
              else if FControlAction=[caNone] then
              begin
                  FControlAction:=[caMoveSpace];
                  //Procedure(self);
                  FControlAction:=[caNone];
              end;
        end
        else if (FMouseButtonUp=gmbRight)and(FMouseButtonDown=gmbRight)then //Правая отпущена
        begin
            if FControlAction = [caNone] then
            begin
                FControlAction:=[caClickRight];
                //SuperRightButtonClick(self);
                FControlAction:=[caNone];
            end;
        end
        else if (FMouseButtonDown=gmbRight)and(FMouseButtonPressed)then //Правая зажата
        begin
              if FControlAction=[caNone] then
              begin

              end;
        end;
    end;
end;

procedure TGTFControl.SuperMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
    FMouseMoveVertexEnable        :=False;
    FMousePosMoveVertexLast.X     :=X;
    FMousePosMoveVertexLast.Y     :=Y;
    FMousePosMoveVertexDelta.X    :=0;
    FMousePosMoveVertexDelta.Y    :=0;

    FMouseButtonDownPos.X   :=X;
    FMouseButtonDownPos.Y   :=Y;

    case Button of
       mbLeft   :FMouseButtonDown:=gmbLeft;
       mbRight  :FMouseButtonDown:=gmbRight;
       mbMiddle :FMouseButtonDown:=gmbMiddle;
       else
          FMouseButtonDown:=gmbNone;
    end;

    FMouseButtonUp:=gmbNone;

    FMouseButtonPressed     :=true;
    FMouseButtonDownShift   :=Shift;
    if Assigned(ActiveDocument) then
       FtmpViewPos:=ActiveDocument.FViewPos;
    gaMouseAction(self);

    if Assigned(FSelfOnMouseDown) then
       FSelfOnMouseDown(Sender,Button,Shift,X,Y);
end;

procedure TGTFControl.SuperMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
var
  WCSMBUpPos,WCSMBDownPos  :TGTFPoint;
  bTmp:boolean;
begin
    FMousePosMoveVertexLast.X     :=0;
    FMousePosMoveVertexLast.Y     :=0;

    FMousePosMoveVertexDelta.X    :=0;
    FMousePosMoveVertexDelta.Y    :=0;

    FMouseButtonUpPos.X     :=X;
    FMouseButtonUpPos.Y     :=Y;

    case Button of
       mbLeft:FMouseButtonUp:=gmbLeft;
       mbRight:FMouseButtonUp:=gmbRight;
       mbMiddle:FMouseButtonUp:=gmbMiddle;
       else
          FMouseButtonUp:=gmbNone;
    end;

    FMouseButtonPressed     :=false;
    FMouseButtonUpShift     :=Shift;

    if (FMouseButtonUp=FMouseButtonDown)
       and(FMouseButtonUpPos.X=FMouseButtonDownPos.X)
       and(FMouseButtonUpPos.Y=FMouseButtonDownPos.Y) then
    begin
          FClickCount:=FClickCount+1;
    end
    else
          FClickCount:=0;

    if FMouseMoveVertexEnable then  //Если было перемещение объектов
    begin
       WCSMBUpPos   :=PointSCSToPointWCS(FMouseButtonUpPos.X,FMouseButtonUpPos.Y);
       WCSMBDownPos :=PointSCSToPointWCS(FMouseButtonDownPos.X,FMouseButtonDownPos.Y);
       FMousePosMoveVertexDelta.X  :=WCSMBUpPos.X-WCSMBDownPos.X;
       FMousePosMoveVertexDelta.Y  :=WCSMBUpPos.Y-WCSMBDownPos.Y;
    end;

    gaMouseAction(self);
    MainControlPaint(self);

    if FClickCount>0 then
    begin

       if (FMouseButtonUp=gmbRight)and(FMouseButtonUpPos.X>FLeftOutsetBorderWidth) then
       begin
          if Assigned(FPopupGridArea) then
             FPopupGridArea.PopUp;

       end
       else if (FMouseButtonUp=gmbRight)and(FMouseButtonUpPos.X<FLeftOutsetBorderWidth) then
       begin
          if Assigned(FPopupLeftOutsetArea) then
             FPopupLeftOutsetArea.PopUp;
       end
       else begin
          SuperClick(Self);
       end;

    end;
    if FClickCount>1 then
    begin
       SuperDblClick(Self);
    end;

    FMouseButtonDown:=gmbNone;
    FMouseButtonUp:=gmbNone;

    if Assigned(FSelfOnMouseUp) then
       FSelfOnMouseUp(Sender,Button,Shift,X,Y);
end;

procedure TGTFControl.SuperMouseMove(Sender: TObject;
  Shift: TShiftState;
  X, Y: Integer);
var
  i,j                       :integer;
  tX,
  tY                      :Integer;
  //WCSMousePosMoveVertexLast,
  WCSMouseButtonDownPos,
  DatePos,
  WCSCursorPos            :TGTFPoint;
  ItemUnderCur            :TEntity;

  RowItem                 :TGTFCOutsetTreeRowItem;
  ColItem                 :TGTFCOutsetTreeColItem;
  vbPos                   :TGTFViewBookmark;
begin
  FClickCount  :=0;
  FCursorPos.X :=x;  //ScreenToClient(mouse.CursorPos).X
  FCursorPos.Y :=y;
  WCSCursorPos :=PointSCSToPointWCS(FCursorPos.X,FCursorPos.Y);
  //вычисление смещения
    //if (FMouseButtonDown=mbMiddle)then //mbLeft, mbRight, mbMiddle
    //begin
        if caMoveSpace in FControlAction{(FClickCount=0)and(FMouseButtonPressed)} then
        begin
            WCSMouseButtonDownPos :=PointSCSToPointWCS(FMouseButtonDownPos.X,FMouseButtonDownPos.Y);

            tX:=WCSCursorPos.X-WCSMouseButtonDownPos.X;
            tY:=WCSCursorPos.Y-WCSMouseButtonDownPos.Y;

            ActiveDocument.FViewPos.X:=FtmpViewPos.X+tX;
            ActiveDocument.FViewPos.y:=FtmpViewPos.y+tY;

            if ActiveDocument.FViewPos.X>FLeftOutsetBorderWidth then
            begin
               ActiveDocument.FViewPos.X:=FLeftOutsetBorderWidth;
            end;

            if ActiveDocument.FViewPos.Y>FTopOutsetBorderHeight then
            begin
               ActiveDocument.FViewPos.Y:=FTopOutsetBorderHeight;
            end;

            //Вычисление горизонтальной закладки
            DatePos:=PointSCSToPointWCS(FLeftOutsetBorderWidth,FTopOutsetBorderHeight);
            j:=ActiveDocument.GetColUnderPoint(DatePos);
            if j>0 then
            begin
              ColItem:=TGTFCOutsetTreeColItem(ActiveDocument.Cols.Items[j]);
              //SetMessageToUser(DateTimeToStr(ColItem.BeginDate));
              vbPos:=ActiveDocument.ViewBookmark;
              vbPos.HBookmark        :=True;
              vbPos.HBookmarkValue   :=ColItem.BeginDate;
              ActiveDocument.ViewBookmark := vbPos;
            end;

            //Вычисление вертикальной закладки
            j:=ActiveDocument.GetRowUnderPoint(DatePos);
            if j>0 then
            begin
              RowItem:=TGTFCOutsetTreeRowItem(ActiveDocument.Rows.Items[j]);
              //SetMessageToUser(RowItem.Text);
              vbPos:=ActiveDocument.ViewBookmark;
              vbPos.VBookmark        :=True;
              vbPos.VBookmarkValue   :=RowItem.DBRecordID;
              ActiveDocument.ViewBookmark := vbPos;
            end;

        end
        else if caMoveVertex in FControlAction then
        begin
            //Пересчитываем разницу смещения точек и отправляем значение на запись
            WCSMouseButtonDownPos       :=PointSCSToPointWCS(FMouseButtonDownPos.X,FMouseButtonDownPos.Y);
            //WCSMousePosMoveVertexLast   :=PointSCSToPointWCS(FMousePosMoveVertexLast.X,FMousePosMoveVertexLast.Y);
            FMousePosMoveVertexDelta.X  :=WCSCursorPos.X-WCSMouseButtonDownPos.X;
            FMousePosMoveVertexDelta.Y  :=WCSCursorPos.Y-WCSMouseButtonDownPos.Y;

            if not FMouseMoveVertexEnable then
            begin
              FMouseMoveVertexEnable:=True;
              BeginMoveVertex(Self);
            end;

            FMousePosMoveVertexLast.X  :=FCursorPos.X;
            FMousePosMoveVertexLast.Y  :=FCursorPos.Y;

        end;
    //end;

  //отображение курсора
  if FDrawCursorStyle=csOSAuto then
  begin
      if caMoveSpace in FControlAction then
      begin
          Cursor :=crSize;
      end
      else begin
          ItemUnderCur:=GetObjectUnderRect(WCSCursorPos,WCSCursorPos);
          if ItemUnderCur<>nil then
          begin
             if ActiveDocument.SelectList.IndexOf(ItemUnderCur)>-1 then
             begin

               if ActiveDocument.EditMode=eemCanAll then  //Если можно перемещать
               begin
                 for i:=0 to high(ActiveDocument.FMVertArray) do
                 begin
                    if ActiveDocument.FMVertArray[i].Item=ItemUnderCur then
                    begin
                      Cursor       :=crSize;
                      ItemUnderCur :=nil;
                      break;
                    end;
                 end;
               end;

               if ItemUnderCur<>nil then
                  Cursor :=crHandPoint
             end
             else
               Cursor :=crHandPoint;
          end
          else if caMoveVertex in FControlAction then
          begin
              Cursor :=crSize;
          end
          else begin
             Cursor :=crArrow;
          end;
      end;
  end;
  {
    Если тут использовать Repaint; вместо MainControlPaint(self);, то
    при работе через Удаленный рабочий стол Windows будет мерцание
    и большая задержка между отрисовками компонента
  }
  MainControlPaint(self);

  if Assigned(FSelfOnMouseMove) then
     FSelfOnMouseMove(Sender,Shift,X,Y);

end;

procedure TGTFControl.SuperMouseWheel(Sender: TObject; Shift: TShiftState;
  WheelDelta: Integer; MousePos: TPoint; var Handled: Boolean);
var
   t:TSystemTime;
   j:Integer;
begin
  if not (ssCtrl in Shift) then
  begin
      if Assigned(ActiveDocument) then
      begin
          getLocaltime(t);
          if t.second = FCurSec then
          begin
             inc(FKStep);
          end
          else begin
             FCurSec:=t.second;
             FKStep:=1;
          end;
          if WheelDelta<0 then
          begin
                //вниз
                j:=ActiveDocument.ViewPos.Y-(FScrollBarVertical.SmallChange);
                if ABS(j)+Height<FScrollBarVertical.Max then
                begin
                  SetViewZeroPoint(ActiveDocument.ViewPos.X,j);
                  MainControlPaint(Sender);
                end;
          end
          else begin
              //вверх
              j:=ActiveDocument.ViewPos.Y+(FScrollBarVertical.SmallChange);
              if j+FTopOutsetBorderHeight>FScrollBarVertical.Min then
                   j:=FTopOutsetBorderHeight;
              SetViewZeroPoint(ActiveDocument.ViewPos.X,j);
              MainControlPaint(Sender);
          end;

          FClickCount:=0;
      end;

      if Assigned(FSelfOnMouseWheel) then
      FSelfOnMouseWheel(Sender,Shift,WheelDelta,MousePos,Handled);
  end;
end;

procedure TGTFControl.SuperMouseWheelDown(Sender: TObject;
  Shift: TShiftState; MousePos: TPoint; var Handled: Boolean);
begin
  if ssCtrl in Shift then
  begin
    if GridScale>50 then
    begin
       GridScale:=GridScale-10;
       MainControlPaint(Sender);
    end;
  end
  else begin
    if Assigned(FSelfOnMouseWheelDown) then
      FSelfOnMouseWheelDown(Sender,Shift,MousePos,Handled);
  end;
end;

procedure TGTFControl.SuperMouseWheelUp(Sender: TObject;
  Shift: TShiftState; MousePos: TPoint; var Handled: Boolean);
begin
  if ssCtrl in Shift then
  begin
    if GridScale<150 then
    begin
       GridScale:=GridScale+10;
       MainControlPaint(Sender);
    end;
  end
  else begin
       if Assigned(FSelfOnMouseWheelUp) then
       FSelfOnMouseWheelUp(Sender,Shift,MousePos,Handled);
  end;
end;

procedure TGTFControl.SuperPaint(Sender: TObject);
begin

  if FFirstPaint then
  begin
    RefreshColls;
  end;

  MainControlPaint(self);

  if FFirstPaint then
  begin
    FFirstPaint:=False;
    if Assigned(FOnFirstShowEvent) then
       FOnFirstShowEvent(Self);

     ScrollToBegin;
  end
  else begin
     //ScrollToBookmark;
  end;

  if Assigned(FSelfOnPaint) then
    FSelfOnPaint(Sender);
end;

procedure TGTFControl.SLMessagesPaint(Sender: TObject);
var
  PosX, PosY:integer;
begin
   if FMessagesLast='' then exit;
   // Рисуем сообщение
   FDrawLayerMainCanvas.Pen.Style      :=psSolid;
   FDrawLayerMainCanvas.Pen.Color      :=clWindowText;
   FDrawLayerMainCanvas.Pen.Mode       :=pmNot;
   FDrawLayerMainCanvas.Brush.Color    :=FBackgroundColor;
   FDrawLayerMainCanvas.Brush.Style    :=bsDiagCross;//bsClear
   FDrawLayerMainCanvas.Font.Assign(FDefaultFont);
   FDrawLayerMainCanvas.Font.Size      :=10; // от 10 до 16
   FDrawLayerMainCanvas.Font.Color     :=clWindowText;

   PosX:=Width div 2;
   PosY:=Height-50;

   FDrawLayerMainCanvas.TextOut(PosX,PosY,FMessagesLast);
end;

procedure TGTFControl.SLFrameViewModePaint(Sender: TObject);
var
  PosX, PosY,
  PenWidth,
  TextWidth  :integer;
begin
   if FFrameViewModeText='' then exit;

   FDrawLayerMainCanvas.Pen.Style     :=psSolid;
   FDrawLayerMainCanvas.Pen.Color     :=FFrameViewModeColor;
   FDrawLayerMainCanvas.Pen.Mode      :=pmCopy;
   PenWidth                     :=FDrawLayerMainCanvas.Pen.Width;
   FDrawLayerMainCanvas.Pen.Width     :=5;

   FDrawLayerMainCanvas.Brush.Color   :=FFrameViewModeColor;
   FDrawLayerMainCanvas.Brush.Style   :=bsSolid;

   FDrawLayerMainCanvas.Font.Assign(FDefaultFont);
   FDrawLayerMainCanvas.Font.Size     :=10; // от 10 до 16
   FDrawLayerMainCanvas.Font.Bold     :=True;
   FDrawLayerMainCanvas.Font.Color    :=FBackgroundColor;

   FDrawLayerMainCanvas.Frame(0,0,Width,Height);
   PosX:=10;
   PosY:=5;
   TextWidth:=FDrawLayerMainCanvas.GetTextWidth(FFrameViewModeText)+25;
   FDrawLayerMainCanvas.FillRect(0,0,TextWidth,25);
   FDrawLayerMainCanvas.TextOut(PosX,PosY,FFrameViewModeText);
   FDrawLayerMainCanvas.Pen.Width     :=PenWidth;
end;

procedure TGTFControl.GetOutsetBorderSizes(Sender: TObject);
var
  i,j,
  iRowNCount,
  iLevelCount,
  TextHeight,
  TextWidth  :integer;
  sText      :string;
begin

   //Левый
   FLeftOutsetBorderWidth    :=100;
   FLeftOutsetBorderVCapWidth :=24;
   TextWidth                 :=100;
   TextHeight                :=0;
   iRowNCount                :=0;

   iLevelCount:=ActiveDocument.Rows.LevelCount;
   for i:=0 to ActiveDocument.Rows.Count-1 do
   begin
       if ActiveDocument.Rows.Items[i].Level=iLevelCount-1 then
       begin
           sText      :=ActiveDocument.Rows.Items[i].Text;
           j          :=FDrawLayerMainCanvas.GetTextWidth(sText);
           TextHeight :=FDrawLayerMainCanvas.GetTextHeight(sText);
           if j>TextWidth then
              TextWidth:=j;

           if TextHeight>FLeftOutsetBorderVCapWidth then
              FLeftOutsetBorderVCapWidth:=TextHeight+10;

           inc(iRowNCount);
       end;
   end;
   //Счетчик строк, максимальная ширина текса номера строки
   FLeftOutsetBorderRowNumWidth  :=FDrawLayerMainCanvas.GetTextWidth(inttostr(iRowNCount))+GridLineWidth;
   if FLeftOutsetBorderRowNumWidth<FLeftOutsetBorderVCapWidth then
      FLeftOutsetBorderRowNumWidth:=FLeftOutsetBorderVCapWidth;
   //Ширина боковика
   FLeftOutsetBorderWidth:=GridLineWidth+(iLevelCount*(FLeftOutsetBorderVCapWidth+GridLineWidth+1))+TextWidth+GridLineWidth;

   //Ширина боковика без дополнительных столбцов
   FLeftOutsetBorderBaseWidth:=FLeftOutsetBorderWidth;
   FLeftOutsetBorderWidth:=FLeftOutsetBorderWidth+(GetLeftOutsetExtColVisibleCount*(FColExtWidth+GridLineWidth))+FLeftOutsetBorderRowNumWidth+GridLineWidth;
   //Верхний
   iLevelCount:=ActiveDocument.Cols.LevelCount;
   FTopOutsetBorderHeight :=(iLevelCount)*24;
end;

procedure TGTFControl.SLOutsetGridBGPaint(Sender: TObject);
var
  i,k,j,
  iColWidth,
  PosX, PosY,
  PosX1, PosY1,
  PosX2, PosY2,
  PenWidth:integer;
  RowItem:TGTFCOutsetTreeRowItem;
  ColItem:TGTFCOutsetTreeColItem;
  bFill:Boolean;
  bColEnabled:Boolean;
  TmpColorDayOff,
  TmpColorToDay,
  TmpColorRowDisabled,
  TmpColorHL:TColor;
  CurH,CurV:TRect;
begin

   PenWidth                     :=FDrawLayerMainCanvas.Pen.Width;

   TmpColorHL                   :=ColorLighter(clHighLight,95);
   TmpColorDayOff               :=ColorDarker(BackgroundColor,6);
   TmpColorToDay                :=ColorLighter(clGreen,95);
   TmpColorRowDisabled          :=ColorDarker(BackgroundColor,10);

   FDrawLayerMainCanvas.Brush.Color   :=TmpColorHL;
   FDrawLayerMainCanvas.Brush.Style   :=bsSolid;

   //Разлиновка
   FDrawLayerMainCanvas.Pen.Style     :=psSolid;
   FDrawLayerMainCanvas.Pen.Color     :=clHighLight;
   //FDrawLayerMainCanvas.Pen.Mode      :=pmCopy;
   FDrawLayerMainCanvas.Pen.Width     :=1;

   FDrawLayerMainCanvas.Brush.Style   :=bsSolid;

   iColWidth                    :=ColWidth;

   PosX                         :=ActiveDocument.FViewPos.X;
   PosY                         :=ActiveDocument.FViewPos.Y;

   CurV.Empty;
   CurH.Empty;

   //Draw Disable background
    for i:=0 to ActiveDocument.Rows.Count-1 do
    begin
         RowItem:=TGTFCOutsetTreeRowItem(ActiveDocument.Rows.Items[i]);

         if ((not RowItem.RowFiltered)
            or((RowItem.RowFiltered)and(not RowItem.RowParentFiltered)))
            and (not RowItem.Separator) then
         begin
             bFill:=False;

             if (not RowItem.RowEnabled) then
             begin
                FDrawLayerMainCanvas.Brush.Color   :=TmpColorRowDisabled;

                PosY1   :=RowItem.BeginY+PosY;
                PosY2   :=RowItem.EndY+PosY;

                FDrawLayerMainCanvas.FillRect(0,PosY1,vbpWidth,PosY2);
             end;
         end;
     end;

   //Draw select background
   if (not DataBitMapEnabled)and(FWayLine)then
   begin
      k:=ActiveDocument.GetRowUnderCursor;
      if (k>-1) then
      begin
        RowItem :=TGTFCOutsetTreeRowItem(ActiveDocument.Rows.Items[k]);
        bFill   :=False;

        PosY1   :=RowItem.BeginY+PosY;
        PosY2   :=RowItem.EndY+PosY;

        if (FWayLine)and
           (RowItem.RowEnabled) then
        begin
          CurH.Right    :=vbpWidth;
          CurH.Bottom   :=PosY2;
          CurH.Left     :=0;
          CurH.Top      :=PosY1;
        end;

        //аналог SLCursorPaint
        //DrawHighLightFrame(FDrawLayerMainCanvas,0,PosY1,vbpWidth,PosY2);

        FDrawLayerMainCanvas.Brush.Color   :=TmpColorHL;
         if (not CurH.IsEmpty) then
         begin
           FDrawLayerMainCanvas.FillRect(CurH);
         end;

      end;
   end;

   k:=ActiveDocument.GetColUnderCursor;
   for i:=0 to ActiveDocument.Cols.Count-1 do
   begin
       if (ActiveDocument.Cols.Items[i].Level=1) then
       begin
         PosX1:=PosX;
         PosX2:=PosX+iColWidth+GridLineWidth;

         ColItem:=TGTFCOutsetTreeColItem(ActiveDocument.Cols.Items[i]);

         bFill:=False;
         bColEnabled:=True;

         if Assigned(FOnColBGBeforeDrawEvent) then
         begin
             if ColItem.GetDrawEnabledCashe then
             begin
                 bColEnabled:=ColItem.GetDrawEnabledValue;
             end
             else begin
                 FOnColBGBeforeDrawEvent(Self,ColItem,bColEnabled);
                 ColItem.SetDrawEnabledValue(bColEnabled);
             end;
         end
         else begin
            if ColItem.GetDrawEnabledCashe then
            begin
                 bColEnabled:=ColItem.GetDrawEnabledValue;
            end
            else begin
                 if GraphMultiplicity in [gmHour,gmDay] then
                 begin
                    if DateUtils.DayOfTheWeek(ColItem.BeginDate) in [6,7] then
                    begin
                       bColEnabled:=false;
                    end;
                 end;
                 ColItem.SetDrawEnabledValue(bColEnabled);
            end;
         end;

         if not bColEnabled then
         begin
            bFill:=True;
            FDrawLayerMainCanvas.Brush.Color :=TmpColorDayOff;
         end;

         if (bColEnabled)and(GraphMultiplicity in [gmHour]) then
         begin
            if DateUtils.CompareDate(ColItem.BeginDate,Today)=0 then
            begin
               FDrawLayerMainCanvas.Brush.Color   :=TmpColorToDay;
               bFill:=True;
            end;
         end;

         if (FWayLine)and(i=k) then
         begin
            CurV.Right:=PosX2;
            CurV.Bottom:=vbmHeight;
            CurV.Left:=PosX1;
            CurV.Top:=0;
         end;

         if bFill then
         begin
           if (CompareDateTime(Now,ColItem.BeginDate)>=0)and(CompareDateTime(Now,ColItem.EndDate)<=0) then
           begin
              FDrawLayerMainCanvas.Pen.Width     :=2;
           end
           else begin
              FDrawLayerMainCanvas.Pen.Width     :=1;
           end;
           FDrawLayerMainCanvas.FillRect(PosX1,0,PosX2,vbmHeight);
         end;

         PosX:=PosX2;
       end;
   end;

   //j:=ActiveDocument.Rows.LevelCount-1;

   //Draw select background
   if (not DataBitMapEnabled)and(FWayLine)then
   begin
      k:=ActiveDocument.GetRowUnderCursor;
      if (k>-1) then
      begin
        RowItem :=TGTFCOutsetTreeRowItem(ActiveDocument.Rows.Items[k]);
        bFill   :=False;

        PosY1   :=RowItem.BeginY+PosY;
        PosY2   :=RowItem.EndY+PosY;

        if (FWayLine)and
           (RowItem.RowEnabled)and
           (RowItem.RowEnabled) then
        begin
          CurH.Right    :=vbpWidth;
          CurH.Bottom   :=PosY2;
          CurH.Left     :=0;
          CurH.Top      :=PosY1;
        end;

        //аналог SLCursorPaint
        //DrawHighLightFrame(FDrawLayerMainCanvas,0,PosY1,vbpWidth,PosY2);

      end;
   end;

   FDrawLayerMainCanvas.Pen.Width     :=PenWidth;
end;

procedure TGTFControl.SLOutsetGridPaint(Sender: TObject);
var
  i,
  iColWidth,
  PosX, PosY,
  PosX1, PosY1,
  PosX2, PosY2,
  PenWidth:integer;
  RowItem:TGTFCOutsetTreeRowItem;
begin

   if not FGrid then exit;

   PenWidth                     :=FDrawLayerMainCanvas.Pen.Width;

   FDrawLayerMainCanvas.Brush.Color   :=FBackgroundColor;
   FDrawLayerMainCanvas.Brush.Style   :=bsSolid;

   //Разлиновка
   FDrawLayerMainCanvas.Pen.Style     :=psSolid;
   FDrawLayerMainCanvas.Pen.Color     :=FGridColor;
   FDrawLayerMainCanvas.Pen.Mode      :=pmCopy;
   FDrawLayerMainCanvas.Pen.Width     :=GridLineWidth;

   FDrawLayerMainCanvas.Brush.Style   :=bsClear;//Прозрачный текст
   iColWidth                    :=ColWidth;
   PosX                         :=ActiveDocument.FViewPos.X;

   for i:=0 to ActiveDocument.Cols.Count-1 do
   begin
       if ActiveDocument.Cols.Items[i].Level=1 then
       begin
         PosX1:=PosX-GridLineWidth;
         PosX2:=PosX+iColWidth+GridLineWidth;

         FDrawLayerMainCanvas.Pen.Width     :=GridLineWidth;

         FDrawLayerMainCanvas.Rectangle(PosX1,0,PosX2,vbmHeight);

         PosX:=PosX2;//;
       end;
   end;

   //iRowHeight                   :=RowHeight;
   PosY                         :=ActiveDocument.FViewPos.Y;
   //j                            :=ActiveDocument.Rows.LevelCount-1;
   for i:=0 to ActiveDocument.Rows.Count-1 do
   begin
       RowItem:=TGTFCOutsetTreeRowItem(ActiveDocument.Rows.Items[i]);
       //if (RowItem.Level=j)or((not RowItem.Separator)and(FShowGroupHorizontal))  then
       //begin
         if ((RowItem.BeginY<>RowItem.EndY)and
            ((not RowItem.RowFiltered)or
            ((RowItem.RowFiltered)and(not RowItem.RowParentFiltered))))
            and(not RowItem.Separator) then
         begin
           PosY1        :=RowItem.BeginY+PosY-GridLineWidth;
           PosY2        :=RowItem.EndY+PosY+GridLineWidth;
           FDrawLayerMainCanvas.Rectangle(0,PosY1,vbpWidth,PosY2);
         end;
       //end;
   end;

   FDrawLayerMainCanvas.Pen.Width     :=PenWidth;
end;

procedure TGTFControl.GetGridScale(var Value: Integer);
begin
  Value:=GridScale;
end;

procedure TGTFControl.DrawGridLine(ACanvas:TCanvas;AX1,AY1,AX2,AY2:Integer);
var
  clTemp                  :TColor;
  psTemp                  :TPenStyle;
  w                       :integer;
begin
  clTemp:=ACanvas.Pen.Color;
  psTemp:=ACanvas.Pen.Style;
  w:=ACanvas.Pen.Width;

  ACanvas.Pen.Width := 1;
  ACanvas.Pen.Color   :=ColorDarker(clActiveBorder,15);;
  ACanvas.Pen.Style   :=psSolid;
  ACanvas.Line(AX1,AY1,AX2,AY2);

  ACanvas.Pen.Width := w;
  ACanvas.Pen.Color := clTemp;
  ACanvas.Pen.Style := psTemp;
end;

procedure TGTFControl.DrawHighLightFrame(ACanvas:TCanvas;AX1,AY1,AX2,AY2:Integer);
var
  clTemp                  :TColor;
  psTemp                  :TPenStyle;
  w                       :integer;
begin
  clTemp:=ACanvas.Pen.Color;
  psTemp:=ACanvas.Pen.Style;
  w:=ACanvas.Pen.Width;

  ACanvas.Pen.Width := 1;
  ACanvas.Pen.Color   :=clHighLight;
  ACanvas.Pen.Style   :=psSolid;
  ACanvas.Frame(AX1,AY1,AX2,AY2);

  ACanvas.Pen.Width := w;
  ACanvas.Pen.Color := clTemp;
  ACanvas.Pen.Style := psTemp;
end;

procedure TGTFControl.DrawOutsetRowItemHoriz(ACanvas:TCanvas;AItem:TGTFCOutsetTreeRowItem; AX1,AY1,AX2,AY2:Integer; ADrawGroupHoriz:Boolean);
var
  //RowItemCur,
  RowItem1                :TGTFCOutsetTreeRowItem;
  RowItem1ExtData         :TStringArray;
  bDoWayLine              :Boolean;
  TextHeight,
  j,arLength,
  iRowHeight,
  //iRowUnderCursor,
  PosX3, PosX4,
  PosX1b,
  PosX1, PosY1,
  PosX2, PosY2            :Integer;
  sText2,
  sText                   :ShortString;
  clTemp                  :TColor;
  bsTemp                  :TBrushStyle;
begin
            {
            iRowUnderCursor :=ActiveDocument.GetRowUnderCursor;
            if iRowUnderCursor>-1 then
            RowItemCur      :=TGTFCOutsetTreeRowItem(ActiveDocument.Rows.Items[iRowUnderCursor])
            else
            RowItemCur      :=nil;
            }
            RowItem1 :=AItem;
            PosX1    :=AX1;
            PosY1    :=AY1+GridLineWidth;
            PosX2    :=AX2;
            PosY2    :=AY2;

            PosX1b   :=PosX1;

            iRowHeight    :=RowItem1.Height;
            //PosY2       :=PosY1+iRowHeight2;

            //bDrawGroupHoriz:=ADrawGroupHoriz;

            sText          :=RowItem1.Text;
            //sText2         :=IntToStr(RowItem1.GridIndex+1);
            //TextWidth      :=ACanvas.GetTextWidth(sText);
            TextHeight     :=ACanvas.GetTextHeight(sText);

            //Запоминается только размер ячейки, без границ
            RowItem1.BeginY :=PosY1-ActiveDocument.FViewPos.Y;
            RowItem1.EndY   :=PosY2-ActiveDocument.FViewPos.Y;

             if (RowItem1.Color>0) then
             begin
               clTemp:=ACanvas.Brush.Color;
               bsTemp:=ACanvas.Brush.Style;

               ACanvas.Brush.Color   :=ValgaColorToValColor(RowItem1.Color);
               ACanvas.Brush.Style   :=bsSolid;
               ACanvas.FillRect(PosX1,PosY1,FLeftOutsetBorderWidth,PosY2);

               ACanvas.Brush.Color   :=clTemp;
               ACanvas.Brush.Style   :=bsTemp;
             end
             else
             begin
                 if RowItem1.ChildCount>0 then
                 begin
                  clTemp:=ACanvas.Brush.Color;
                  bsTemp:=ACanvas.Brush.Style;

                  ACanvas.Brush.Color   :=ColorDarker(ACanvas.Brush.Color,2);
                  ACanvas.Brush.Style   :=bsSolid;

                  ACanvas.FillRect(PosX1,PosY1,FLeftOutsetBorderWidth,PosY2);

                  ACanvas.Brush.Color   :=clTemp;
                  ACanvas.Brush.Style   :=bsTemp;
                 end;
             end;

             RowItem1.SetDrawRectBody(Point(PosX1,PosY1),Point(PosX2,PosY2));
             //Подсветка строки
             bDoWayLine := (FWayLine and (FCursorPos.Y>=PosY1)and(FCursorPos.Y<=PosY2));
             //RowItem1.GetClickResult(FCursorPos,FCursorPos)=tcrBody
             if bDoWayLine then
             begin
                 DrawHighLightFrame(ACanvas,PosX1,PosY1,PosX2,PosY2);
             end;

             //Текст строки
             if not RowItem1.Separator then
             begin
                ACanvas.TextRect(Rect(PosX1b,PosY1,PosX2,PosY2),PosX1b+5,PosY1+(iRowHeight div 2)-(TextHeight div 2),sText);
             end;

             PosX3 := PosX2;
             PosX4 := PosX2;
             {
             DrawGridLine(ACanvas,PosX3,PosY1,PosX3,PosY2);

             PosX3 := PosX3+GridLineWidth+1;
             PosX4 := PosX4+GridLineWidth+1;
             }
             RowItem1ExtData :=RowItem1.GetExtendedData;
             arLength        :=Length(RowItem1ExtData)-1;

             //Доп столбцы
             //У строк размер массива на один столбец меньше чем кол-во столбцов.
             //Первый столбец основной
             for j:=1 to ActiveDocument.ExtColumns.Count-1 do
             begin
                 if ActiveDocument.ExtColumns.Items[j].Visible then
                 begin
                     if ((j-1)<=arLength) then
                     begin
                        sText          :=RowItem1ExtData[j-1];
                     end
                     else begin
                        sText          :='';
                     end;
                     //TextWidth      :=ACanvas.GetTextWidth(sText);

                     PosX3 := PosX4;
                     PosX4 := PosX3;

                     DrawGridLine(ACanvas,PosX3,PosY1,PosX3,PosY2);

                     PosX3 := PosX3 + GridLineWidth;
                     PosX4 := PosX4 + GridLineWidth + FColExtWidth;

                     //ACanvas.FillRect(PosX3,PosY1,PosX4,PosY2);
                     ACanvas.TextRect(Rect(PosX3,PosY1,PosX4,PosY2),PosX3+5,PosY1+(iRowHeight div 2)-(TextHeight div 2),sText);
                     //RowItem1.GetClickResult(FCursorPos,FCursorPos)=tcrBody
                     if bDoWayLine then
                     begin
                         DrawHighLightFrame(ACanvas,PosX3,PosY1,PosX4,PosY2);
                     end;
                 end;
             end;

             SetLength(RowItem1ExtData,0);

             PosX3 := PosX4;
             PosX4 := FLeftOutsetBorderWidth;

             DrawGridLine(ACanvas,PosX3,PosY1,PosX3,PosY2);

             PosX3 := PosX3+GridLineWidth;
             PosX4 := PosX4-GridLineWidth;

             //Нумерация строки
             FDrawRowCounter:= FDrawRowCounter+1;
             sText2         := IntToStr(FDrawRowCounter);
             ACanvas.TextRect(Rect(PosX3,PosY1,PosX4,PosY2),PosX3+3,PosY1+(iRowHeight div 2)-(TextHeight div 2),sText2);
             if bDoWayLine then
             begin
                 DrawHighLightFrame(ACanvas,PosX3,PosY1,PosX4,PosY2);
             end;

             PosX4:=PosX4;
             DrawGridLine(ACanvas,PosX4,PosY1,PosX4,PosY2);

end;

procedure TGTFControl.DrawOutsetRowItemVert(ACanvas:TCanvas;AItem:TGTFCOutsetTreeRowItem; AX1,AY1,AX2,AY2:Integer; ADrawGroupHoriz:Boolean);
var
  RowItem1                :TGTFCOutsetTreeRowItem;
  TextWidth,
  TextHeight,
  PosX1, PosY1,
  PosX2, PosY2            :Integer;
  sText                   :ShortString;
  clTemp                  :TColor;
  bsTemp                  :TBrushStyle;
begin
             RowItem1 :=AItem;
             PosX1    :=AX1;
             PosY1    :=AY1;
             PosX2    :=AX2;
             PosY2    :=AY2;

             //bDrawGroupHoriz:=ADrawGroupHoriz;

             sText          :=RowItem1.Text;
             //sText2         :=IntToStr(RowItem1.GridIndex+1);  //'|'+
             TextWidth      :=ACanvas.GetTextWidth(sText);
             TextHeight     :=ACanvas.GetTextHeight(sText);

             if FShowGroupHorizontal then
             begin
                RowItem1.BeginY :=PosY1-ActiveDocument.FViewPos.Y;
                RowItem1.EndY   :=PosY1-ActiveDocument.FViewPos.Y+RowItem1.Height;
             end
             else begin
                RowItem1.BeginY :=PosY1-ActiveDocument.FViewPos.Y;
                RowItem1.EndY   :=PosY2-ActiveDocument.FViewPos.Y-GridLineWidth;
             end;

             if (RowItem1.Color>0) then
             begin
               clTemp:=ACanvas.Brush.Color;
               bsTemp:=ACanvas.Brush.Style;

               ACanvas.Brush.Color   :=ValgaColorToValColor(RowItem1.Color);
               ACanvas.Brush.Style   :=bsSolid;
               ACanvas.FillRect(PosX1,PosY1,PosX2,PosY2);
               ACanvas.Brush.Color   :=clTemp;
               ACanvas.Brush.Style   :=bsTemp;
             end
             else
             begin
               if not RowItem1.Separator then
               begin
                  //Затемнение фона вертикального отделителя группы
                  clTemp:=ACanvas.Brush.Color;
                  bsTemp:=ACanvas.Brush.Style;

                  ACanvas.Brush.Color   :=ColorDarker(ACanvas.Brush.Color,2);
                  ACanvas.Brush.Style   :=bsSolid;

                  ACanvas.FillRect(PosX1,PosY1,PosX2,PosY2);

                  ACanvas.Brush.Color   :=clTemp;
                  ACanvas.Brush.Style   :=bsTemp;

                  //Линии
                  //ACanvas.Line(PosX1,PosY1,PosX1,PosY2); //левый

                  //if bDrawGroupHoriz then
                  //   ACanvas.Line(PosX2,PosY1+RowItem1.Height,PosX2,PosY2) //правый
                  //else
                  //   ACanvas.Line(PosX2,PosY1,PosX2,PosY2);

                  //ACanvas.Line(PosX1,PosY2,PosX2-1,PosY2-1);  //нижний
               end
               else begin
                  //ACanvas.Line(PosX1,PosY2,PosX2,PosY2);
               end;
             end;

             if not RowItem1.Separator then
             begin

              ACanvas.Font.Orientation:=0;

               if FTreeButtonStyle in [gtbsDot] then
               begin
                 ACanvas.TextRect(Rect(PosX1,PosY1,PosX2,PosY1+RowItem1.Height),PosX1+4+(TextHeight div 2),PosY1+(TextHeight div 2),'●');
               end
               else if FTreeButtonStyle in [gtbsRectangle,gtbsTriangle] then
               begin

                 RowItem1.SetDrawRectButton(Point(PosX1+1+(TextHeight div 2),PosY1+(TextHeight div 2)+1),Point(PosX1+2+(TextHeight div 2)+FPlusBM.Width,PosY1+(TextHeight div 2)+3+FPlusBM.Height));

                 //Plus/Minus
                 if RowItem1.GetClickResult(FCursorPos,FCursorPos)=tcrButton then
                 begin
                     if RowItem1.RowFiltered then
                        ACanvas.Draw(PosX1+1+(TextHeight div 2),PosY1+(TextHeight div 2)+1,FHotPlusBM)
                     else
                        ACanvas.Draw(PosX1+1+(TextHeight div 2),PosY1+(TextHeight div 2)+1,FHotMinusBM);
                 end
                 else begin
                     if RowItem1.RowFiltered then
                        ACanvas.Draw(PosX1+1+(TextHeight div 2),PosY1+(TextHeight div 2)+1,FPlusBM)
                     else
                        ACanvas.Draw(PosX1+1+(TextHeight div 2),PosY1+(TextHeight div 2)+1,FMinusBM);
                 end;

               end;

             end;

             if not RowItem1.RowFiltered then
             begin
               if (TextWidth+RowItem1.Height)>(PosY2-PosY1) then
               begin
                   //Если не помещается по высоте
                   ACanvas.Font.Orientation:=900;
                   if not RowItem1.Separator then
                   ACanvas.TextRect(Rect(PosX1,PosY1+2+RowItem1.Height,PosX2,PosY2),PosX1+(TextHeight div 2),PosY2-5,sText);
                   ACanvas.Font.Orientation:=0;
               end
               else begin
                   ACanvas.Font.Orientation:=900;
                   if not RowItem1.Separator then
                   ACanvas.TextRect(Rect(PosX1,PosY1+RowItem1.Height,PosX2,PosY2+RowItem1.Height),PosX1+(TextHeight div 2),PosY1+(TextWidth)+RowItem1.Height+5,sText);
                   ACanvas.Font.Orientation:=0;
               end;
             end;
end;

function TGTFControl.DrawOutsetRow(ACanvas:TCanvas;AParent:TGTFCOutsetTreeRowItem; ALevel,AY1,AX1,AX2:Integer; var AEndY2:integer):boolean;
var
  RowItem1                :TGTFCOutsetTreeRowItem;
  bDrawGroupHoriz,
  bSubItemExists          :Boolean;
  i,
  iRowHeight,

  iOutEndY2,
  PosX1, PosY1,
  PosX2Vert,
  PosY1Vert,
  PosY2            :Integer;
begin
   Result     :=False;

   AEndY2     :=0;
   iRowHeight :=RowHeight;
   PosX1      :=AX1;
   //PosX2      :=AX2;
   PosY1      :=AY1;
   PosY2      :=AY1;

   bSubItemExists :=false;

   //iRowUnderCursor :=ActiveDocument.GetRowUnderCursor;

   for i:=0 to ActiveDocument.Rows.Count-1 do
   begin
       RowItem1:=TGTFCOutsetTreeRowItem(ActiveDocument.Rows.Items[i]);
       //Обработка всех строк с указанным владельцем
       if (RowItem1.Parent=AParent) then
       begin
          RowItem1.BeginY :=0;
          RowItem1.EndY   :=0;

          //CurPos:=GetCursorPoint;
          //RowItem1.SetDrawRectBody(Point(0,0),Point(0,0));
          //RowItem1.SetDrawRectButton(Point(0,0),Point(0,0));

          iOutEndY2      :=0;

          {drawgroup}

          if FShowGroupHorizontal then  {создание горизонтальной строки группы}
          begin
             if RowItem1.Separator then
                bDrawGroupHoriz:=False
             else
                bDrawGroupHoriz:=True;
          end
          else begin
             bDrawGroupHoriz:=False;
          end;

          {end drawgroup}

          bSubItemExists :=False;

          iRowHeight :=RowItem1.Height;
          if RowItem1.ChildCount>0 then
          begin

              PosY1Vert   :=PosY1+GridLineWidth;

              if bDrawGroupHoriz or ((not bDrawGroupHoriz) and (RowItem1.RowFiltered)) then
              begin
                 PosY1    :=PosY1;
                 PosY2    :=PosY1+iRowHeight+GridLineWidth;

                 DrawOutsetRowItemHoriz(ACanvas,RowItem1,PosX1+1+FLeftOutsetBorderVCapWidth+GridLineWidth,PosY1,AX2,PosY2,bDrawGroupHoriz);
                 DrawGridLine(ACanvas,PosX1+1+FLeftOutsetBorderVCapWidth+GridLineWidth,PosY2,FLeftOutsetBorderWidth,PosY2);

                 if (not RowItem1.RowFiltered) then
                 begin
                   PosY1:=PosY2;
                   PosY2:=PosY1+iRowHeight+GridLineWidth;
                 end;
              end;

              //Отрисовка потомков
              if (not RowItem1.RowFiltered) then
              begin
                bSubItemExists :=DrawOutsetRow(ACanvas,RowItem1,ALevel+1,PosY1,PosX1+FLeftOutsetBorderVCapWidth+GridLineWidth,AX2,iOutEndY2);
                PosY2          :=iOutEndY2;
              end
              else begin
                //
              end;
              //Вертикально. Отрисовка боковика смещения, если были нарисованы дети.

               PosX2Vert :=PosX1+1+FLeftOutsetBorderVCapWidth+GridLineWidth;

               DrawOutsetRowItemVert(ACanvas,RowItem1,PosX1,PosY1Vert,PosX2Vert,PosY2,bDrawGroupHoriz);
               DrawGridLine(ACanvas,PosX2Vert-1,PosY1,PosX2Vert-1,PosY2);
               DrawGridLine(ACanvas,PosX1,PosY2,FLeftOutsetBorderWidth,PosY2);

               PosY1:=PosY2;
               PosY2:=PosY1;

               AEndY2:=PosY2;
               Result:=bSubItemExists;
          end
          else begin
               //Горизонтально. Отрисовка строки, если нет детей

               PosY1    :=PosY1;
               PosY2    :=PosY1+iRowHeight+GridLineWidth;

               DrawOutsetRowItemHoriz(ACanvas,RowItem1,PosX1+1,PosY1,AX2,PosY2,bDrawGroupHoriz);
               DrawGridLine(ACanvas,PosX1,PosY2,FLeftOutsetBorderWidth,PosY2);

               PosY1:=PosY2;
               PosY2:=PosY1;//+iRowHeight+GridLineWidth;

               AEndY2:=PosY2;
               Result:=True;
          end;
       end; //rowitem
   end;
end;

procedure TGTFControl.DrawOutsetCol(ACanvas: TCanvas);
var
  //iColUnderCursor,
  i1,i2,iLevelCount,
  iColWidth,
  iColHeight,
  PosX,
  GroupPosX1,GroupPosX2,
  PosX1, PosY1,
  PosX2, PosY2,
  TextHeight,
  TextWidth    :integer;

  sText                  :string;
  ColItem1,ColItem2      :TGTFCOutsetTreeBasicItem;
  bItem2Exists           :Boolean;

  TmpCanvas              :TCanvas;
  //bWayLine               :boolean;
begin
   ///Сверху
   TmpCanvas       :=ACanvas;
   iLevelCount     :=ActiveDocument.Cols.LevelCount;
   //iColUnderCursor :=ActiveDocument.GetColUnderCursor;
   if iLevelCount>0 then
   begin

   TmpCanvas.Brush.Style        :=bsClear;//Прозрачный текст
   iColWidth                    :=ColWidth;
   iColHeight                   :=FTopOutsetBorderHeight div (iLevelCount);
   PosX                         :=ActiveDocument.FViewPos.X;
   PosY1                        :=0;
   PosY2                        :=PosY1+iColHeight+GridLineWidth;

   for i1:=0 to ActiveDocument.Cols.Count-1 do
   begin
       ColItem1:=ActiveDocument.Cols.Items[i1];
       if ColItem1.Level=0 then
       begin
         bItem2Exists:=False;
         for i2:=0 to ActiveDocument.Cols.Count-1 do
         begin
           ColItem2:=ActiveDocument.Cols.Items[i2];
           if ColItem2.Parent=ColItem1 then
           begin
               sText:=ColItem2.Text;
               TextWidth :=TmpCanvas.GetTextWidth(sText);
               TextHeight :=TmpCanvas.GetTextHeight(sText);

              //Чертим эл-ты группы
               PosX1:=PosX-GridLineWidth;
               PosX2:=PosX+iColWidth+GridLineWidth;

               TGTFCOutsetTreeColItem(ColItem2).BeginX :=PosX1+GridLineWidth-ActiveDocument.FViewPos.X;
               TGTFCOutsetTreeColItem(ColItem2).EndX   :=PosX2-GridLineWidth-ActiveDocument.FViewPos.X;

               if (CompareDateTime(Now,TGTFCOutsetTreeColItem(ColItem2).BeginDate)>=0)and(CompareDateTime(Now,TGTFCOutsetTreeColItem(ColItem2).EndDate)<=0) then
               begin
                  TmpCanvas.Font.Bold   :=True;
               end
               else begin
                  TmpCanvas.Font.Bold   :=False;
               end;

               if not bItem2Exists then
               begin
                  GroupPosX1:=PosX1;
                  bItem2Exists:=True;
               end;
               GroupPosX2:=PosX2;
               TextHeight :=TmpCanvas.GetTextHeight(sText);
               TmpCanvas.Rectangle(PosX1,PosY2-1,PosX2,FTopOutsetBorderHeight+1);
               TmpCanvas.TextRect(Rect(PosX1,PosY2,PosX2,FTopOutsetBorderHeight),PosX1+(iColWidth div 2)-(TextWidth div 2),PosY2+(iColHeight div 2)-(TextHeight div 2),sText);

               {
               //Подсветка столба
               bWayLine := (FWayLine and (iColUnderCursor=i2));

               if bWayLine then
               begin
                   //аналог SLCursorPaint
                   //DrawHighLightFrame(TmpCanvas,PosX1+1,PosY2,PosX2-1,FTopOutsetBorderHeight-1);
               end;
               }
               PosX:=PosX2;
           end;
         end;
         //Чертим заголовок группы
         if bItem2Exists then
         begin
            TGTFCOutsetTreeColItem(ColItem1).BeginX :=GroupPosX1+GridLineWidth-ActiveDocument.FViewPos.X;
            TGTFCOutsetTreeColItem(ColItem1).EndX   :=GroupPosX2-GridLineWidth-ActiveDocument.FViewPos.X;

            sText:=ColItem1.Text;
            TextWidth :=TmpCanvas.GetTextWidth(sText);
            TextHeight :=TmpCanvas.GetTextHeight(sText);

            TmpCanvas.Rectangle(GroupPosX1,PosY1,GroupPosX2,PosY2);
            TmpCanvas.TextRect(Rect(GroupPosX1,PosY1,GroupPosX2,PosY2),GroupPosX1+((GroupPosX2-GroupPosX1)div 2)-(TextWidth div 2),PosY1+(iColHeight div 2)-(TextHeight div 2),sText);

         end;
       end;
   end;

   TmpCanvas.Brush.Color   :=clForm;
   TmpCanvas.Brush.Style   :=bsSolid;
   TmpCanvas.FillRect(0,0,FLeftOutsetBorderWidth,FTopOutsetBorderHeight);
   end;
end;

function TGTFControl.GetColWidth: Integer;
var
  x:real;
begin
  x:=FGridScale / 100;
  Result:=Trunc(FColWidth*x);
end;

function TGTFControl.GetLeftOutsetExtColCount: Integer;
begin
  Result:=ActiveDocument.ExtColumns.Count;
end;

function TGTFControl.GetLeftOutsetExtColVisibleCount: Integer;
var
  i:integer;
begin
  Result:=0;
  for i:=1 to ActiveDocument.ExtColumns.Count-1 do
  begin
     if ActiveDocument.ExtColumns.Items[i].Visible then
        Inc(Result);
  end;
end;

procedure TGTFControl.SetTreeButtonStyle(AValue: TGraphTreeButtonStyle);
begin
  if FTreeButtonStyle=AValue then Exit;
  FTreeButtonStyle:=AValue;
  SupportImageCreate(self);
end;

procedure TGTFControl.SupportImageCreate(Sender: TObject);

  procedure FillBitmap (ABitmap: TBitmap);
  begin
    with ABitmap, Canvas do
    begin
      ABitmap.SetSize(11, 11);
      Brush.Color := clFuchsia;
      MaskHandle  := 0;
      Transparent := True;
      TransparentColor := Brush.Color;
      FillRect(Rect(0, 0, ABitmap.Width, ABitmap.Height));
    end;
  end;

begin
    with FPlusBM, Canvas do
    begin
      FillBitmap(FPlusBM);
      FillBitmap(FHotPlusBM);

      case FTreeButtonStyle of
      gtbsDot:
      begin
        Brush.Color := clWindowText;
        Pen.Color   := clWindowText;
        Font.Color  := clWindowText;
        Font.Size   := 8;
        TextRect(Rect(0,0,11,11),2,-2,'●');
        FHotPlusBM.Canvas.Draw(0, 0, FPlusBM);
      end;
      gtbsTriangle:
      begin
        Brush.Color := clWindowText;
        Pen.Color := clWindowText;
        Polygon([Point(2, 0), Point(6, 4), Point(2, 8)]);
        FHotPlusBM.Canvas.Draw(0, 0, FPlusBM);
      end;
      gtbsRectangle:
      begin
        Brush.Color := clBtnHighlight;
        Pen.Color := clHighlight;
        Rectangle(0, 0, Width, Height);
        Pen.Color := clHighlight;

        MoveTo(2, Width div 2);
        LineTo(Width - 2, Width div 2);
        MoveTo(Width div 2, 2);
        LineTo(Width div 2, Width - 2);
        //FPlusBM.LoadFromResourceName(0, '_BUTTONPLUS');
        FHotPlusBM.Canvas.Draw(0, 0, FPlusBM);

        Brush.Color := clBtnFace;
        Pen.Color := clBtnText;
        Rectangle(0, 0, Width, Height);
        Pen.Color := clBtnText;

        MoveTo(2, Width div 2);
        LineTo(Width - 2, Width div 2);
        MoveTo(Width div 2, 2);
        LineTo(Width div 2, Width - 2);
      end;
      else begin

      end;
      end;
    end;

    with FMinusBM, Canvas do
    begin
      FillBitmap(FMinusBM);
      FillBitmap(FHotMinusBM);

      case FTreeButtonStyle of
      gtbsDot:
      begin
        Brush.Color := clWindowText;
        Pen.Color   := clWindowText;
        Font.Color  := clWindowText;
        Font.Size   := 8;
        TextRect(Rect(0,0,11,11),2,-2,'●');
        FHotMinusBM.Canvas.Draw(0, 0, FMinusBM);
      end;
      gtbsTriangle:
      begin
        Brush.Color := clWindowText;
        Pen.Color := clWindowText;

        if BiDiMode = bdLeftToRight then
          Polygon([Point(2, 0), Point(6, 4), Point(2, 8)])
        else
          Polygon([Point(6, 0), Point(2, 4), Point(6, 8)]);
        FHotMinusBM.Canvas.Draw(0, 0, FMinusBM);
      end;
      gtbsRectangle:
      begin
        Brush.Color := clBtnHighlight;
        Pen.Color := clHighlight;
        Rectangle(0, 0, Width, Height);
        Pen.Color := clHighlight;

        MoveTo(2, Width div 2);
        LineTo(Width - 2, Width div 2);
        //FMinusBM.LoadFromResourceName(0, '_BUTTONPLUS');
        FHotMinusBM.Canvas.Draw(0, 0, FMinusBM);

        Brush.Color := clBtnFace;
        Pen.Color := clBtnText;
        Rectangle(0, 0, Width, Height);
        Pen.Color := clBtnText;

        MoveTo(2, Width div 2);
        LineTo(Width - 2, Width div 2);
      end;
      else begin

      end;
      end;
    end;

    with FArrowDownBM, Canvas do
    begin
      FillBitmap(FArrowDownBM);

      Brush.Color := clWindowText;
      Pen.Color := clWindowText;

      Polygon([Point(1, 10), Point(6, 1), Point(10, 10)]);
    end;

    with FFlagBM, Canvas do
    begin
      FillBitmap(FFlagBM);

      Brush.Color := clWindowText;
      Pen.Color := clWindowText;

      Polygon([Point(6, 0), Point(6, 11), Point(11, 6), Point(6, 0)]);
    end;
end;

procedure TGTFControl.SLOutsetBorderHeaderPaint(Sender: TObject);
var
  i1,
  iLevelCount,
  i,j,
  iColHeight,
  //PosX,
  PosY,
  GroupPosX1,GroupPosX2,
  PosY1,
  PosY2,
  TextHeight,
  PenWidth, TextWidth:integer;

  sText:string;

  TmpCanvas:TCanvas;
begin
   TmpCanvas:=FDrawLayerOutsetBorder.Canvas;

   TmpCanvas.Pen.Style     :=psSolid;
   TmpCanvas.Pen.Color     :=clBlack;
   TmpCanvas.Pen.Mode      :=pmCopy;
   PenWidth                :=TmpCanvas.Pen.Width;
   TmpCanvas.Pen.Width     :=1;

   TmpCanvas.Brush.Color   :=clBlack;
   TmpCanvas.Brush.Style   :=bsSolid;

   TmpCanvas.Font.Assign(Self.FDefaultFont);
   TmpCanvas.Font.Color    :=clWindowText;

   TmpCanvas.Brush.Color   :=Self.FBackgroundColor;
   TmpCanvas.Brush.Style   :=bsSolid;

   TextWidth:=100;
   TextHeight:=0;
   for i:=0 to ActiveDocument.Rows.Count-1 do
   begin
       sText      :=ActiveDocument.Rows.Items[i].Text;
       j          :=TmpCanvas.GetTextWidth(sText);
       TextHeight :=TmpCanvas.GetTextHeight(sText);
       if j>TextWidth then
          TextWidth:=j;
   end;

   //Разлиновка
   TmpCanvas.Pen.Style     :=psSolid;
   TmpCanvas.Pen.Color     :=clActiveBorder;
   TmpCanvas.Pen.Mode      :=pmCopy;
   TmpCanvas.Pen.Width     :=1;

   ///Слева
   iLevelCount:=ActiveDocument.Rows.LevelCount;

   if DataBitMapEnabled then
   TmpCanvas.Brush.Color   :=clWindow
   else
   TmpCanvas.Brush.Color   :=clForm;

   TmpCanvas.Brush.Style   :=bsSolid;
   TmpCanvas.FillRect(0,0,FLeftOutsetBorderWidth,vbmHeight);

   FDrawRowCounter              :=0;
   PosY                         :=0;
   PosY2                        :=0;
   PosY                         :=PosY+ActiveDocument.FViewPos.Y;
   //Отрисовка ячеек боковика
   DrawOutsetRow(TmpCanvas,nil,0,PosY,0,FLeftOutsetBorderBaseWidth,PosY2);

   iLevelCount:=ActiveDocument.Cols.LevelCount;

   if iLevelCount>0 then
   begin

     TmpCanvas.Brush.Color   :=clForm;
     TmpCanvas.Brush.Style   :=bsSolid;
     TmpCanvas.FillRect(0,0,vbpWidth,FTopOutsetBorderHeight);

     ///Отрисовка ячеек сверху(календарь)
     DrawOutsetCol(TmpCanvas);

     TmpCanvas.Brush.Style        :=bsClear;//Прозрачный текст
     iColHeight                   :=FTopOutsetBorderHeight div (iLevelCount);

     TmpCanvas.Brush.Color   :=clForm;
     TmpCanvas.Brush.Style   :=bsSolid;
     TmpCanvas.FillRect(0,0,FLeftOutsetBorderWidth,FTopOutsetBorderHeight);
   end;

   //TmpCanvas.Pen.Color     :=ColorDarker(clred,25);
   //TmpCanvas.Line(0,FTopOutsetBorderHeight-GridLineWidth,Width,FTopOutsetBorderHeight-GridLineWidth);
   //TmpCanvas.Pen.Color     :=clActiveBorder;

   //Заголовок строк
   GroupPosX1 :=0;
   GroupPosX2 :=FLeftOutsetBorderBaseWidth+GridLineWidth;
   PosY1      :=FTopOutsetBorderHeight-iColHeight;
   PosY2      :=FTopOutsetBorderHeight+GridLineWidth;

   //Первый заголовок
   if ActiveDocument.ExtColumns.Count>0 then
   begin
     sText      :=ActiveDocument.ExtColumns.Items[0].Caption;
     TextWidth  :=TmpCanvas.GetTextWidth(sText);
     TextHeight :=TmpCanvas.GetTextHeight(sText);

     TmpCanvas.Rectangle(GroupPosX1,PosY1,GroupPosX2,PosY2);
     TmpCanvas.TextRect(Rect(GroupPosX1,PosY1,GroupPosX2,PosY2),GroupPosX1+((GroupPosX2-GroupPosX1)div 2)-(TextWidth div 2),PosY1+(iColHeight div 2)-(TextHeight div 2),sText);
   end;
   //Остальные заголовки
   GroupPosX1:=GroupPosX2-GridLineWidth;
   for i1:=1 to ActiveDocument.ExtColumns.Count-1 do
   begin
       if ActiveDocument.ExtColumns.Items[i1].Visible then
       begin
         sText      :=ActiveDocument.ExtColumns.Items[i1].Caption;
         TextWidth  :=TmpCanvas.GetTextWidth(sText);
         TextHeight :=TmpCanvas.GetTextHeight(sText);

         GroupPosX2 :=GroupPosX1+1+ColExtWidth+GridLineWidth;

         TmpCanvas.Rectangle(GroupPosX1,PosY1,GroupPosX2,PosY2);
         TmpCanvas.TextRect(Rect(GroupPosX1,PosY1,GroupPosX2,PosY2),GroupPosX1+((GroupPosX2-GroupPosX1)div 2)-(TextWidth div 2),PosY1+(iColHeight div 2)-(TextHeight div 2),sText);

         GroupPosX1:=GroupPosX2-GridLineWidth;
       end;
   end;
   //Счет
   if ActiveDocument.ExtColumns.Count>0 then
   begin
     GroupPosX1:=GroupPosX2-GridLineWidth;

     sText      :=' № ';
     TextWidth  :=FLeftOutsetBorderRowNumWidth;
     TextHeight :=TmpCanvas.GetTextHeight(sText);

     GroupPosX2:=GroupPosX1+1+TextWidth+GridLineWidth;

     TmpCanvas.Rectangle(GroupPosX1,PosY1,GroupPosX2,PosY2);
     TmpCanvas.TextRect(Rect(GroupPosX1,PosY1,GroupPosX2,PosY2),GroupPosX1+((GroupPosX2-GroupPosX1)div 2)-(TextWidth div 2),PosY1+(iColHeight div 2)-(TextHeight div 2),sText);

     GroupPosX1:=GroupPosX2-GridLineWidth;
   end;

   //Линии отделения
   TmpCanvas.Pen.Color     :=ColorDarker(clActiveBorder,15);
   TmpCanvas.Line(0,FTopOutsetBorderHeight-GridLineWidth,vbpWidth,FTopOutsetBorderHeight-GridLineWidth);
   TmpCanvas.Line(FLeftOutsetBorderWidth-GridLineWidth,0,FLeftOutsetBorderWidth-GridLineWidth,vbmHeight);

   TmpCanvas.Pen.Width     :=PenWidth;
end;

//World Coordinate System (WCS), Screen Coordinate System (SCS)
function TGTFControl.PointSCSToPointWCS(X,Y:Integer):TGTFPoint;
var
  r:TGTFPoint;
  X2,Y2:Integer;
begin
   r.X:=0;
   r.Y:=0;
   r.Z:=0;
   if Assigned(ActiveDocument) then
   begin
     X2:=X;
     Y2:=Y;
     r.Z:=0;
     r.X:=X2-ActiveDocument.FViewPos.X;
     r.Y:=Y2-ActiveDocument.FViewPos.Y;
   end;
   Result:=r;
end;

//World Coordinate System (WCS), Screen Coordinate System (SCS)
function TGTFControl.PointWCSToPointSCS(X,Y:Integer):TPoint;
var
  r:TPoint;
  X2,Y2:Integer;
begin
   r.X:=0;
   r.Y:=0;
   if Assigned(ActiveDocument) then
   begin
     X2:=X+ActiveDocument.FViewPos.X;
     Y2:=Y+ActiveDocument.FViewPos.Y;
     r.X:=X2;
     r.Y:=Y2;
   end;
   Result:=r;
end;

procedure TGTFControl.RefreshEntityDraw;
begin
  RepaintEntity;
  if Assigned(ActiveDocument) then
  begin
       if not(eemReadOnly = ActiveDocument.EditMode) then
       RepaintVertex;
  end;
end;

procedure TGTFControl.TimerMessageOnTimer(Sender: TObject);
begin
  if FMessagesList.Count>0 then
  begin
     if FMessagesList.Count=1 then
     begin
        FTimerMessage.Interval:=1500;
     end
     else begin
        FTimerMessage.Interval:=1000;
     end;
     FMessagesLast:=FMessagesList.Strings[0];
     FMessagesList.Delete(0);
  end
  else begin
     FMessagesLast:='';
     FTimerMessage.Enabled:=False;
  end;
  Refresh;
end;

procedure TGTFControl.RefreshColls;
var
  i:integer;
  BeginDate,
  LastDate,
  CurDate,
  EndDate:TDateTime;
  Item1,Item2:TGTFCOutsetTreeColItem;
begin

  BeginDate := GraphDateTimeBegin;
  EndDate   := GraphDateTimeEnd;

  try
      ActiveDocument.Cols.BeginUpdate;
      ActiveDocument.Cols.Clear;

      case GraphMultiplicity of
        gmHour:
        begin
          CurDate := BeginDate;
          while (CompareDate(BeginDate,CurDate)<=0)and(CompareDate(EndDate,CurDate)>=0) do
          begin
              Item1       :=TGTFCOutsetTreeColItem.Create;
              Item1.Level :=0;
              Item1.Text  :=FormatDateTime('dd mmmm yyyy',CurDate);
              ActiveDocument.Cols.Add(Item1);
              For i:=0 to 23 do
              begin
                 Item2           :=TGTFCOutsetTreeColItem.Create;
                 Item2.BeginDate :=DateUtils.RecodeTime(CurDate,i,0,0,0);
                 Item2.EndDate   :=DateUtils.RecodeTime(CurDate,i,59,59,0);
                 Item2.Parent    :=Item1;
                 Item2.Level     :=1;
                 Item2.Text      :=IntToStr(i);//час
                 ActiveDocument.Cols.Add(Item2);
              end;
              CurDate := IncDay(CurDate);
          end;
        end;
        gmDay:
        begin
          CurDate := BeginDate;
          Item1   := nil;
          LastDate:=0;
          while (CompareDate(BeginDate,CurDate)<=0)and(CompareDate(EndDate,CurDate)>=0) do
          begin
              if (Item1=nil)or(MonthOf(CurDate)<>MonthOf(LastDate)) then
              begin
                 Item1       :=TGTFCOutsetTreeColItem.Create;
                 Item1.Level :=0;
                 Item1.Text  :=FormatDateTime('mmmm yyyy',CurDate);
                 ActiveDocument.Cols.Add(Item1);
              end;

              Item2         :=TGTFCOutsetTreeColItem.Create;
              Item2.BeginDate :=DateUtils.RecodeTime(CurDate,0,0,0,0);
              Item2.EndDate   :=DateUtils.RecodeTime(CurDate,23,59,59,0);
              Item2.Level   :=1;
              Item2.Parent  :=Item1;
              Item2.Text    :=IntToStr(DayOf(CurDate));//день
              ActiveDocument.Cols.Add(Item2);

              LastDate := CurDate;
              CurDate  := IncDay(CurDate);
          end;
        end;
        gmWeek:
        begin
          CurDate := BeginDate;
          Item1   := nil;
          LastDate:=0;
          while (CompareDate(BeginDate,CurDate)<=0)and(CompareDate(EndDate,CurDate)>=0) do
          begin
              if (Item1=nil)or(MonthOf(CurDate)<>MonthOf(LastDate)) then
              begin
                 Item1:=TGTFCOutsetTreeColItem.Create;
                 Item1.Level:=0;
                 Item1.Text:=FormatDateTime('mmmm yyyy',CurDate);
                 ActiveDocument.Cols.Add(Item1);
              end;
              Item2         :=TGTFCOutsetTreeColItem.Create;
              Item2.BeginDate :=StartOfTheWeek(CurDate);
              Item2.EndDate   :=EndOfTheWeek(CurDate);
              Item2.Parent    :=Item1;
              Item2.Level     :=1;
              Item2.Text      :=IntToStr(WeekOf(CurDate)); //неделя
              ActiveDocument.Cols.Add(Item2);

              LastDate := CurDate;
              CurDate  := IncWeek(CurDate);
          end;
        end;
        qmMonth:
        begin
          CurDate := BeginDate;
          Item1   := nil;
          LastDate:=0;
          while (CompareDate(BeginDate,CurDate)<=0)and(CompareDate(EndDate,CurDate)>=0) do
          begin
              if (Item1=nil)or(YearOf(CurDate)<>YearOf(LastDate)) then
              begin
                 Item1:=TGTFCOutsetTreeColItem.Create;
                 Item1.Level:=0;
                 Item1.Text:=FormatDateTime('yyyy',CurDate);
                 ActiveDocument.Cols.Add(Item1);
              end;

              Item2         :=TGTFCOutsetTreeColItem.Create;
              Item2.BeginDate :=DateUtils.StartOfTheMonth(CurDate);
              Item2.EndDate   :=DateUtils.EndOfTheMonth(CurDate);
              Item2.Parent  :=Item1;
              Item2.Level   :=1;
              Item2.Text    :=IntToStr(MonthOf(CurDate));//месяц
              ActiveDocument.Cols.Add(Item2);

              LastDate := CurDate;
              CurDate  := IncMonth(CurDate);
          end;
        end;
        gmQuarter:
        begin
          CurDate := BeginDate;
          Item1   := nil;
          LastDate:=0;
          while (CompareDate(BeginDate,CurDate)<=0)and(CompareDate(EndDate,CurDate)>=0) do
          begin
              if (Item1=nil)or(YearOf(CurDate)<>YearOf(LastDate)) then
              begin
                 Item1:=TGTFCOutsetTreeColItem.Create;
                 Item1.Level:=0;
                 Item1.Text:=FormatDateTime('yyyy',CurDate);
                 ActiveDocument.Cols.Add(Item1);
              end;

              Item2           :=TGTFCOutsetTreeColItem.Create;
              Item2.BeginDate :=DateUtils.StartOfTheMonth(CurDate);
              Item2.EndDate   :=DateUtils.EndOfTheMonth(IncMonth(CurDate,3));
              Item2.Parent  :=Item1;
              Item2.Level   :=1;
              Item2.Text    :=IntToStr(Ceil(MonthOf(CurDate)/3)); //квартал
              ActiveDocument.Cols.Add(Item2);

              LastDate := CurDate;
              CurDate  := IncMonth(CurDate,3);
          end;
        end;
      end;

  finally
   ActiveDocument.Cols.EndUpdate;
  end;

end;

procedure TGTFControl.RefreshFilterEntity;
var
  i,j        :integer;
  Item       :TEntity;
  ItemTask   :TBasicGridEntity;
  ItemLine   :TGraphicConnectionline;
  Doc        :TGTFDrawDocument;
  DrawObject :Boolean;
begin
  Doc:=ActiveDocument;
  if Assigned(Doc) then
  begin
    Doc.ModelSpace.ObjectsFiltered.Clear;
    for I := 0 to Doc.ModelSpace.Objects.Count - 1 do
    begin
            DrawObject :=true;
            Item       :=Doc.ModelSpace.Objects.Items[i];

            if Item is TBasicGridEntity then
            begin
               ItemTask :=TBasicGridEntity(Item);

               if ItemTask.GridRow=nil then
               begin
                  DrawObject :=False;
               end
               else begin
                   if ItemTask.GridRow.RowFiltered then
                   begin
                      DrawObject :=False;
                   end
                   else
                   begin
                       if CompareDateTimeRange(ItemTask.TimeBegin,ItemTask.TimeEnd,GraphDateTimeBegin,GraphDateTimeEnd)<>0 then
                       begin
                          DrawObject :=False;
                       end;
                   end;
               end;
            end
            else begin
                DrawObject :=False;
            end;

            if (DrawObject)and Assigned(FOnEntityFilterEvent) then
               FOnEntityFilterEvent(Self,Item,DrawObject);

            if DrawObject then
            begin
              Doc.ModelSpace.ObjectsFiltered.Add(Item);
            end;
    end;
    //
    for I := 0 to Doc.ModelSpace.Objects.Count - 1 do
    begin
            DrawObject :=False;
            Item       :=Doc.ModelSpace.Objects.Items[i];

            if Item is TGraphicConnectionline then
            begin
               ItemLine :=TGraphicConnectionline(Item);

               for j:=0 to Doc.ModelSpace.ObjectsFiltered.Count-1 do
               begin
                   ItemTask :=TBasicGridEntity(Doc.ModelSpace.ObjectsFiltered.Items[j]);
                   if ItemLine.BeginEntityID=ItemTask.ID then
                   begin
                      DrawObject :=True;
                      break;
                   end;
               end;

               if DrawObject then
               begin
                 DrawObject :=False;
                 for j:=0 to Doc.ModelSpace.ObjectsFiltered.Count-1 do
                 begin
                     ItemTask :=TBasicGridEntity(Doc.ModelSpace.ObjectsFiltered.Items[j]);
                     if ItemLine.EndEntityID=ItemTask.ID then
                     begin
                        DrawObject :=True;
                        break;
                     end;
                 end;
               end;

            end;

            if (DrawObject)and Assigned(FOnEntityFilterEvent) then
               FOnEntityFilterEvent(Self,Item,DrawObject);

            if DrawObject then
            begin
              Doc.ModelSpace.ObjectsFiltered.Add(Item);
            end;
    end;

  end;
end;

procedure TGTFControl.RefreshFilterTree;
var
  RowItem1                :TGTFCOutsetTreeRowItem;
  bDrawRow                :Boolean;
  i                       :Integer;
begin
   for i:=0 to ActiveDocument.Rows.Count-1 do
   begin
       RowItem1:=TGTFCOutsetTreeRowItem(ActiveDocument.Rows.Items[i]);
       if Assigned(FOnOutsetTreeItemFilterEvent) then
       begin
          bDrawRow:=not RowItem1.RowFiltered;
          FOnOutsetTreeItemFilterEvent(Self,RowItem1,bDrawRow);
          RowItem1.RowFiltered:=not bDrawRow;
       end;
   end;
end;

procedure TGTFControl.RepaintEntity;
var
  i,k,FMVertArrayCount,
  index      :integer;
  MVertItem,
  Item       :TEntity;
  Doc        :TGTFDrawDocument;
  DrawObject :Boolean;
  DeltaVertex :TGTFPoint;
begin

  Doc:=ActiveDocument;
  if Assigned(Doc) then
  begin
    for I := 0 to Doc.ModelSpace.ObjectsFiltered.Count - 1 do
    begin
            DrawObject :=true;
            Item       :=TEntity(Doc.ModelSpace.ObjectsFiltered.Items[i]);

            if DrawObject and Assigned(FOnEntityBeforeDrawEvent) then
               FOnEntityBeforeDrawEvent(Self, Item, DrawObject);

            if DrawObject then
            begin

              if (esMoving in Item.State)or(esEditing in Item.State) then
              begin
              FMVertArrayCount:=Length(Doc.FMVertArray);
              for k := 0 to FMVertArrayCount - 1 do
              begin
                  MVertItem:=ActiveDocument.FMVertArray[k].Item;
                  if MVertItem=Item then
                  begin
                    DeltaVertex.X:=FMousePosMoveVertexDelta.X;
                    DeltaVertex.Y:=FMousePosMoveVertexDelta.Y;
                    DeltaVertex.Z:=FMousePosMoveVertexDelta.Z;
                    Item.ActionVertexDelta:=DeltaVertex;
                    Item.ActionVertexIndex:=ActiveDocument.FMVertArray[k].VertexIndex;
                    break;
                  end;
              end;
              end;

              if Assigned(Doc.FSelectList) then
              begin
                index:=Doc.FSelectList.IndexOf(Item);
                if index>-1 then
                begin
                 if (esMoving in Item.State)or(esEditing in Item.State) then
                   Item.Repaint(FLogicalDraw,[edsSelected,edsMoving])
                 else
                   Item.Repaint(FLogicalDraw,[edsSelected]);
                end
                else
                  Item.Repaint(FLogicalDraw,[edsNormal]);
              end
              else
                Item.Repaint(FLogicalDraw,[edsNormal]);

              if (esMoving in Item.State)or(esEditing in Item.State) then
              begin
                    DeltaVertex.X:=0;
                    DeltaVertex.Y:=0;
                    DeltaVertex.Z:=0;
                    Item.ActionVertexDelta:=DeltaVertex;
              end;

              if Assigned(FOnEntityAfterDrawEvent) then
               FOnEntityAfterDrawEvent(Self, Item);
            end;
    end;
  end;
end;

procedure TGTFControl.RepaintVertex;
var
  i,count:integer;
  Item:TEntity;
  Doc:TGTFDrawDocument;
  DeltaVertex:TGTFPoint;
begin
  Doc:=ActiveDocument;
  for I := 0 to Doc.ModelSpace.Objects.Count - 1 do
  begin
          if Assigned(Doc.FSelectList) then
          begin
            Item:=Doc.ModelSpace.Objects.Items[i];
            if Doc.FSelectList.IndexOf(Item)>-1 then
            begin
              if (esMoving in Item.State)or(esEditing in Item.State) then
              begin
                 DeltaVertex.X:=FMousePosMoveVertexDelta.X;
                 DeltaVertex.Y:=FMousePosMoveVertexDelta.Y;
                 DeltaVertex.Z:=FMousePosMoveVertexDelta.Z;
                 Item.ActionVertexDelta:=DeltaVertex;
                 Item.RepaintVertex(FLogicalDraw);
              end
              else begin
                 Item.RepaintVertex(FLogicalDraw);
              end;
            end;
          end;
  end;

  Count:=Length(Doc.FMVertArray);
  if not(eemSelectOnly = ActiveDocument.EditMode) then
  for I := 0 to Count - 1 do
  begin
       if Assigned(Doc.FMVertArray[i].Item) then
       begin
           if (esMoving in Doc.FMVertArray[i].Item.State)or(esEditing in Doc.FMVertArray[i].Item.State) then
           begin
              DeltaVertex:=Doc.FMVertArray[i].VertexPos;
              DeltaVertex.X:=DeltaVertex.X+FMousePosMoveVertexDelta.X;
              DeltaVertex.Y:=DeltaVertex.Y+FMousePosMoveVertexDelta.Y;
              DeltaVertex.Z:=DeltaVertex.Z+FMousePosMoveVertexDelta.Z;
              VertexDraw(DeltaVertex.X,DeltaVertex.Y,VERTEXMARKER_VERTEX_SEL);
           end
           else begin
              VertexDraw(Doc.FMVertArray[i].VertexPos.X,Doc.FMVertArray[i].VertexPos.Y,VERTEXMARKER_VERTEX_SEL);
           end;
       end
       else begin
          VertexDraw(Doc.FMVertArray[i].VertexPos.X,Doc.FMVertArray[i].VertexPos.Y,VERTEXMARKER_VERTEX_SEL);
       end;
  end;
end;

//World Coordinate System (WCS), Screen Coordinate System (SCS)
function TGTFControl.ValWCSToValSCS(X:Double):Integer;
begin
   result:=Trunc(X);
end;

function TGTFControl.ValLineWeightToValPixel(X:TgaLineWeight):Integer;
begin
  if x<0 then x:=gaLnWtDefault;
  case x of
    gaLnWtDefault: Result:=1;
    gaLnWtDouble:  Result:=2;
    gaLnWtTriple:  Result:=3;
  else begin
    Result:=x;
  end;
  end;
end;

function TGTFControl.GetIndexRGBColor(X:Integer):TgaColor;
var
  k:Integer;
begin
  X:=X+1;
  k:=(gaMaxColors-gaNonRGBMaxColors);
  X:=X-((X div k)*k)+gaNonRGBMaxColors;
  Result:=X;
end;

//Max 49
function TGTFControl.ValgaColorToValColor(X:TgaColor):TColor;
begin
  case x of
    0  : Result:=clWindowText; //clWindowText
    1  : Result:=clWindow; //clWindow
    2  : Result:=clBtnFace; //clBtnFace
    3  : Result:=clHighlight; //clHiglight
    4  : Result:=clHighlightText; //HighlightText
    5  : Result:=RGB(0,0,0); //Резерв
    6  : Result:=RGB(0,0,0); //Резерв
    7  : Result:=RGB(0,0,0); //Резерв
    8  : Result:=RGB(0,0,0); //Резерв
    9  : Result:=RGB(0,0,0); //Фиксированный Черный
    10  : Result:=RGB(132,132,132); //Фиксированный
    11  : Result:=RGB(173,173,173); //Фиксированный
    12  : Result:=RGB(214,214,214); //Фиксированный
    13  : Result:=RGB(240,240,240); //Фиксированный
    14  : Result:=RGB(255,255,255); //Фиксированный Белый
    15  : Result:=RGB(229,63,44); //Приоритет: Важно+Срочно
    16  : Result:=RGB(254,172,49); //Приоритет: Важно
    17  : Result:=RGB(255,112,67); //Приоритет: Срочно
    18  : Result:=RGB(39,202,55); //Приоритет: Нет, Нет
    19  : Result:=RGB(146,194,154); //Статус: Завершено
    20  : Result:=RGB(118,230,44); //Статус: Выполнено
    21  : Result:=RGB(0,255,43); //Статус: В работе
    22  : Result:=RGB(254,172,49); //Статус: Приостановлено
    23  : Result:=RGB(127,191,255); //Статус: Новая задача
    24  : Result:=RGB(0,0,0); //Резерв
    25  : Result:=RGB(138,125,179); //Резерв
    26  : Result:=RGB(0,0,0); //Резерв
    27  : Result:=RGB(0,0,0); //Резерв
    28  : Result:=RGB(0,0,0); //Резерв
    29  : Result:=RGB(0,0,0); //Резерв
    30  : Result:=RGB(229,126,115); //Фиксированный
    31  : Result:=RGB(254,127,178); //Фиксированный
    32  : Result:=RGB(254,127,242); //Фиксированный
    33  : Result:=RGB(204,128,254); //Фиксированный
    34  : Result:=RGB(76,147,254); //Фиксированный
    35  : Result:=RGB(114,185,227); //Фиксированный
    36  : Result:=RGB(49,233,254); //Фиксированный
    37  : Result:=RGB(49,254,172); //Фиксированный
    38  : Result:=RGB(39,202,55); //Фиксированный
    39  : Result:=RGB(118,219,163); //Фиксированный
    40  : Result:=RGB(118,230,44); //Фиксированный
    41  : Result:=RGB(255,235,59); //Фиксированный
    42  : Result:=RGB(254,172,49); //Фиксированный
    43  : Result:=RGB(255,112,67); //Фиксированный
       else begin
     Result  := RGB(127,191,255);
  end;
  end;
end;

procedure TGTFControl.SetMessageToUser(AText: String);
begin
  if Assigned(FMessagesList) then
  begin
    FMessagesList.Clear;
    FMessagesLast:=AText;
    FTimerMessage.Interval:=1000;
    FTimerMessage.Enabled:=True;
    Refresh;
  end;
end;

procedure TGTFControl.FrameViewModeSet(AText: String; AColor: TColor);
begin
  FFrameViewModeText                 :=AText;
  FFrameViewModeColor                :=AColor;
end;

procedure TGTFControl.FrameViewModeClear;
begin
  FFrameViewModeText                 :='';
  FFrameViewModeColor                :=clGreen;
end;

procedure TGTFControl.AddMessageToUser(AText: String);
begin
if Assigned(FMessagesList) then
begin
  FMessagesList.Add(AText);
  FMessagesLast:=AText;
  if FTimerMessage.Enabled=False then
  begin
    FTimerMessage.Interval:=100;
    FTimerMessage.Enabled:=True;
  end;
  Refresh;
end;
end;

procedure TGTFControl.SLVirtualPaintBegin(Sender: TObject);
var
  h:integer;
begin

  if FDataBitMapEnabled then
  begin
    vbmHeight :=Height;
    vbpWidth  :=FLeftOutsetBorderWidth+FColWSizeSum;
    h:=FTopOutsetBorderHeight+FRowHSizeSum;
    if vbmHeight<h then vbmHeight:=h;
    FDrawLayerMain.SetSize(vbpWidth, vbmHeight);
    FDrawLayerOutsetBorder.SetSize(vbpWidth, vbmHeight);
  end
  else begin
    vbmHeight :=Height;
    vbpWidth  :=Width;
    FDrawLayerMain.SetSize(vbpWidth, vbmHeight);
    FDrawLayerOutsetBorder.SetSize(vbpWidth, vbmHeight);
  end;

  if Assigned(FOnBeforeDrawEvent) then
     FOnBeforeDrawEvent(Self);
  //Рисуем чистый фон
  FDrawLayerMainCanvas.Pen.Color    := FBackgroundColor;
  FDrawLayerMainCanvas.Brush.Style  := bsSolid;
  if Assigned(ActiveDocument) then
    FDrawLayerMainCanvas.Brush.Color  := FBackgroundColor
  else
    FDrawLayerMainCanvas.Brush.Color  := clSilver;
  FDrawLayerMainCanvas.FillRect(rect(0,0,vbpWidth,vbmHeight));

  { При включенной прозрачности лагает отрисовка, появляются артефакты}
  //FDrawLayerOutsetBorderCanvas.Brush.Color   :=clFuchsia;
  //FDrawLayerOutsetBorderCanvas.FillRect(0,0,vbpWidth,vbmHeight);

  if Sender<>FScrollBarVertical then
  begin
    FScrollBarVertical.Min         :=0;
    FScrollBarVertical.Max         :=FRowHSizeSum;
    FScrollBarVertical.Position    :=ABS(ActiveDocument.ViewPos.Y-FTopOutsetBorderHeight);
    FScrollBarVertical.PageSize    :=vbmHeight-FTopOutsetBorderHeight;
    FScrollBarVertical.SmallChange :=RowHeight;
    FScrollBarVertical.LargeChange :=vbmHeight-RowHeight;
  end;

  if Sender<>FScrollBarHorizontal then
  begin
    FScrollBarHorizontal.Min         :=0;
    FScrollBarHorizontal.Max         :=FColWSizeSum;
    FScrollBarHorizontal.Position    :=ABS(ActiveDocument.ViewPos.X-FLeftOutsetBorderWidth);
    FScrollBarHorizontal.PageSize    :=vbpWidth-FLeftOutsetBorderWidth;
    FScrollBarHorizontal.SmallChange :=ColWidth;
    FScrollBarHorizontal.LargeChange :=vbpWidth-ColWidth;
  end;

end;

procedure TGTFControl.AntiLayeringRowResize(Sender: TObject);
var
  RowItem1  :TGTFCOutsetTreeRowItem;
  ColItem1  :TGTFCOutsetTreeColItem;
  i,j,cw    :Integer;
begin
   FRowHSizeSum :=0;
   j            :=ActiveDocument.Rows.LevelCount-1;
   for i:=0 to ActiveDocument.Rows.Count-1 do
   begin
      RowItem1:=TGTFCOutsetTreeRowItem(ActiveDocument.Rows.Items[i]);
      RowItem1.EntityHeight:=RowHeight;
      if AntiLayering then
         RowItem1.Height:=GetRowItemHeight(RowItem1)
      else
         RowItem1.Height:=RowHeight;

      if (RowItem1.Level=j)or((FShowGroupHorizontal)and(not RowItem1.Separator)) then
      begin
         FRowHSizeSum:=FRowHSizeSum+RowItem1.Height+GridLineWidth;
      end;
   end;
   FRowHSizeSum :=FRowHSizeSum+RowHeight;

   FColWSizeSum :=0;
   cw           :=ColWidth+GridLineWidth;
   j            :=ActiveDocument.Cols.LevelCount-1;
   for i:=0 to ActiveDocument.Cols.Count-1 do
   begin
      ColItem1:=TGTFCOutsetTreeColItem(ActiveDocument.Cols.Items[i]);
      if (ColItem1.Level=j)then
         FColWSizeSum:=FColWSizeSum+cw;
   end;
   FColWSizeSum:=FColWSizeSum+cw;
end;

Function QuarterOf(const AValue: TDateTime): integer;
begin
  Result:=Ceil(MonthOf(AValue)/3); //квартал
end;

procedure SortListGridEntityByDate(AList:TList);
var
  tmpItemA,
  tmpItemB  :TBasicGridEntity;
  icompare,
  ir,ir2    :integer;
begin
     ir         :=0;
     while ir<AList.Count-1 do
     begin
        tmpItemA :=TBasicGridEntity(AList.Items[ir]);
        ir2      :=ir+1;
        tmpItemB :=TBasicGridEntity(AList.Items[ir2]);
        icompare :=CompareDateTime(tmpItemB.TimeBegin,tmpItemA.TimeBegin);

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

procedure SortListByLayeringIndex(AList:TList;ADateScale:TGraphMultiplicity);
var
  tmpItemA,
  tmpItemB  :TBasicGridEntity;
  icompare,
  ir,ir2,ir3  :integer;
begin
     ir       :=0;
     ir2      :=1;
     while (ir<AList.Count-1) do
     begin
        if ir=ir2 then
        begin
           inc(ir2);
        end
        else begin
          tmpItemA :=TBasicGridEntity(AList.Items[ir]);
          tmpItemB :=TBasicGridEntity(AList.Items[ir2]);
          icompare :=CompareDateTimeRange(tmpItemB.TimeBegin,tmpItemB.TimeEnd,tmpItemA.TimeBegin,tmpItemA.TimeEnd,ADateScale);
          if icompare=0 then
          begin
            //Определяем приоритеты
            //.. if (tmpItemA.SortRangIndex<tmpItemB.SortRangIndex) then //+1
            //Расставляем равных
            if tmpItemB.AntiLayeringIndex=tmpItemA.AntiLayeringIndex then //на одной строке
            begin
               //отодвигаем всех от tmpItemA
               tmpItemB.AntiLayeringIndex:=tmpItemB.AntiLayeringIndex+1;
               ir:=0;
               ir2:=1;
            end
            else begin
               inc(ir2);
            end;
          end
          else begin
            inc(ir);
            ir2:=ir+1;
          end;
        end;

        if ir2=AList.Count then
        begin
             inc(ir);
             ir2:=ir;
        end;
     end;
end;

function TGTFControl.GetRowItemHeight(ARowItem:TGTFCOutsetTreeRowItem):integer;
var
  iResultCount,
  iCutLayerCount,
  iPlus,
  i1,
  //i2,
  BaseHeight,
  iNewRowHeight :integer;
  Item          :TEntity;
  //Item2,
  Item1         :TBasicGridEntity;
  LayList,
  TaskLayList,
  LandmarkLayList,
  FrameLineLayList :TList;
  //bLayExists    :Boolean;
begin
  Result        :=RowHeight;

    BaseHeight       :=RowHeight;
    LayList          :=TList.Create;
    LandmarkLayList  :=TList.Create;
    FrameLineLayList :=TList.Create;
    TaskLayList      :=TList.Create;

    ARowItem.LayerCount:=1;

    //0.48
   LayList.Clear;

    //Собираем объекты строки
    for i1 := 0 to ActiveDocument.ModelSpace.ObjectsFiltered.Count - 1 do
    begin
        Item:=TEntity(ActiveDocument.ModelSpace.ObjectsFiltered.Items[i1]);
        if (Item is TBasicGridEntity)then
        begin
          Item1:=TBasicGridEntity(Item);
          if (Item1.GridRow=ARowItem) then
          begin
              Item1.AntiLayeringIndex:=1;

              if Item1 is TGraphicLandmark then
               LandmarkLayList.Add(Item1)
              else if Item1 is TGraphicFrameLine then
               FrameLineLayList.Add(Item1)
              else if Item1 is TGraphicTask then
               TaskLayList.Add(Item1);
          end;
        end;
    end;

    iPlus:=0;
    if LandmarkLayList.Count>0 then
    begin
      SortListGridEntityByDate(LandmarkLayList);
      SortListByLayeringIndex(LandmarkLayList,GraphMultiplicityDraw);

      for i1:=0 to LandmarkLayList.Count-1 do
      begin
         LayList.Add(LandmarkLayList.Items[i1]);
      end;

      inc(iPlus);
    end;

    if FrameLineLayList.Count>0 then
    begin
       SortListGridEntityByDate(FrameLineLayList);
       SortListByLayeringIndex(FrameLineLayList,GraphMultiplicityDraw);

       for i1:=0 to FrameLineLayList.Count-1 do
       begin
           LayList.Add(FrameLineLayList.Items[i1]);
       end;

       if iPlus>0 then
       begin
         for i1:=0 to FrameLineLayList.Count-1 do
         begin
             Item1:=TBasicGridEntity(FrameLineLayList.Items[i1]);
             Item1.AntiLayeringIndex:=Item1.AntiLayeringIndex+iPlus;
         end;
       end;

       inc(iPlus);
    end;

    if TaskLayList.Count>0 then
    begin
       SortListGridEntityByDate(TaskLayList);
       SortListByLayeringIndex(TaskLayList,GraphMultiplicityDraw);

       for i1:=0 to TaskLayList.Count-1 do
       begin
           LayList.Add(TaskLayList.Items[i1]);
       end;

       if iPlus>0 then
       begin
         for i1:=0 to TaskLayList.Count-1 do
         begin
             Item1:=TBasicGridEntity(TaskLayList.Items[i1]);
             Item1.AntiLayeringIndex:=Item1.AntiLayeringIndex+iPlus;
         end;
       end;

       inc(iPlus);
    end;
    {
      Из-за неопределенной продолжительности задач рекурсивные функции
      приводят к наложению задач друг на друга. Использован ниспадающий вариант
      с полным проходом списка.
    }

    iCutLayerCount:=1;
    for i1 := 0 to LayList.Count - 1 do
    begin
        iResultCount:=TGraphicTask(LayList.items[i1]).AntiLayeringIndex;
        if iCutLayerCount<iResultCount then
           iCutLayerCount:=iResultCount;
    end;

    //Обрабатываем результат для группы
    ARowItem.LayerCount :=iCutLayerCount;
    iNewRowHeight       :=ARowItem.LayerCount*BaseHeight;
    Result              :=iNewRowHeight;

    LandmarkLayList.Free;
    FrameLineLayList.Free;
    TaskLayList.Free;
    LayList.Free;
end;

function TGTFControl.GetDrawRowCount: integer;
var
  RowItem1               :TGTFCOutsetTreeRowItem;
  i,j                    :Integer;
begin
   Result:=0;
   j:=ActiveDocument.Rows.LevelCount-1;
   for i:=0 to ActiveDocument.Rows.Count-1 do
   begin
      RowItem1:=TGTFCOutsetTreeRowItem(ActiveDocument.Rows.Items[i]);
      if (RowItem1.Level=j)or((FShowGroupHorizontal)and(not RowItem1.Separator)) then
         inc(Result);
   end;
end;

procedure TGTFControl.GetTextWidth(AText: AnsiString; var AWidth: Integer);
begin
   AWidth:=FDrawLayerMainCanvas.GetTextWidth(AText);
end;

procedure TGTFControl.GetTextHeight(AText: AnsiString; var AHeight: Integer);
begin
   AHeight:=FDrawLayerMainCanvas.GetTextHeight(AText);
end;

function TGTFControl.GetGraphMultiplicityDrawPrecision: TGraphMultiplicity;
begin
  if FGraphDrawDatePrecision then
     Result:=gmHour
  else
     Result:=GraphMultiplicity;
end;

function TGTFControl.GetRowHeight: Integer;
var
  x:real;
begin
  x:=FGridScale / 100;
  Result:=Trunc(FRowHeight*x);
end;

procedure TGTFControl.SLVirtualPaintEnd(Sender: TObject);
var
  PicRect:trect;
begin
  //Рисуем объекты
  RefreshEntityDraw;

  PicRect := Rect(0, 0, FDrawLayerMain.Width, FTopOutsetBorderHeight);
  FDrawLayerMainCanvas.CopyRect(PicRect,FDrawLayerOutsetBorder.Canvas,PicRect); //Вывод на канву
  PicRect := Rect(0, 0, FLeftOutsetBorderWidth, FDrawLayerMain.Height);
  FDrawLayerMainCanvas.CopyRect(PicRect,FDrawLayerOutsetBorder.Canvas,PicRect); //Вывод на канву

  if Assigned(FOnAfterDrawEvent) then
     FOnAfterDrawEvent(Self);
end;

procedure TGTFControl.SuperWndProc(var Message: TMessage);
var
  Pos: TPoint;
  KeyState: TKeyboardState;
  WheelMsg: TCMMouseWheel;
  Handler: Boolean;
begin
    case Message.Msg of
      WM_MOUSEWHEEL:
      begin
            GetKeyboardState(KeyState);
            WheelMsg.Msg := TWMMouseWheel(Message).Msg;
            {$IFNDEF FPC}
            WheelMsg.ShiftState := KeyboardStateToShiftState(KeyState);
            WheelMsg.WheelDelta := TWMMouseWheel(Message).WheelDelta;
            {$ELSE}
            WheelMsg.ShiftState := GetKeyShiftState;
            WheelMsg.WheelDelta := TWMMouseWheel(Message).WheelDelta;
            {$ENDIF}
            WheelMsg.Pos.x := TWMMouseWheel(Message).Pos.x;
            WheelMsg.Pos.y := TWMMouseWheel(Message).Pos.y;
            pos.X          := mouse.CursorPos.x;
            pos.Y          := mouse.CursorPos.Y;
            {$IFNDEF FPC}
            SuperMouseWheel(Self,WheelMsg.ShiftState,WheelMsg.WheelDelta,pos,Handler);
            {$ELSE}
            SuperMouseWheel(Self,WheelMsg.ShiftState,WheelMsg.WheelDelta,pos,Handler);
            {$ENDIF}
      end;
      WM_MBUTTONDBLCLK:
      begin

      end;
    end;

  //inherited WindowProc(Message);
  //Dispatch(Message);
  if Assigned(FFormWindowProc) then
     FFormWindowProc(Message);
end;

//Все рисование начинается здесь
procedure TGTFControl.MainControlPaint(Sender: TObject);
begin
  if FUpdateCount>0 then
     exit;

  if FDataBitMapEnabled then
  begin
     FDataBitMapTmpX := ActiveDocument.FViewPos.X;
     FDataBitMapTmpY := ActiveDocument.FViewPos.Y;
     SetViewZeroPoint(FLeftOutsetBorderWidth,FTopOutsetBorderHeight);
  end
  else begin

  end;

  FDrawLayerMainCanvas.AntialiasingMode:=amOn; //не для Win
  FDrawLayerOutsetBorderCanvas.AntialiasingMode:=amOn; //не для Win

  FDrawLayerMainCanvas.Font.Assign(FDefaultFont);
  FDrawLayerMainCanvas.Pen.Mode   :=pmCopy;
  FDrawLayerMainCanvas.Pen.Width  :=1;

  FDrawLayerOutsetBorderCanvas.Font.Assign(FDefaultFont);
  FDrawLayerOutsetBorderCanvas.Pen.Mode   :=pmCopy;
  FDrawLayerOutsetBorderCanvas.Pen.Width  :=1;

  FLogicalDraw.Develop      :=FDevelop;

  {Подготовка}
  RefreshFilterTree;
  RefreshFilterEntity;

  {Расчеты}

  vbmHeight :=Height;
  vbpWidth  :=Width;

  AntiLayeringRowResize(Sender); //Просчет высоты строк
  GetOutsetBorderSizes(Sender); //Определение размеров боковиков
  GetViewingArea(Sender);  //Получение зоны обзора камеры

  {Отрисовка}

  SLVirtualPaintBegin(Sender);
  SLOutsetBorderHeaderPaint(Sender); //Боковик
  SLOutsetGridBGPaint(Sender);

  SLOutsetGridPaint(Sender);  //Сетка

  SLVirtualPaintEnd(Sender); //Отрисовка Объектов чертежа

  ZeroPointCSPaint;  // Отрисовка нулевой точки
  SelectRectDoPaint(Sender);//Отрисовка рамки выбора

  if not DataBitMapEnabled then						   
  SLCursorPaint(Sender); //Отрисовка курсора

  if FDataBitMapEnabled then
  begin
     FDataBitMap.Assign(FDrawLayerMain);
     ActiveDocument.FViewPos.X:=FDataBitMapTmpX;
     ActiveDocument.FViewPos.Y:=FDataBitMapTmpY;
  end
  else begin
     FDataBitMap.Clear;
  end;

     SLDevelopInfoPaint(Sender);
     SLExtHintPaint(Sender);

  if (not FDataBitMapEnabled)and(not FFirstPaint) then
  begin
     SLMessagesPaint(Sender); //Сообщения
     SLFrameViewModePaint(Sender); //Рамка режима
     Canvas.Draw(0,0,FDrawLayerMain); //Вывод на канву
  end
  else if FFirstPaint then
  begin
    Repaint;
  end;

end;

procedure TGTFControl.SelectRectDoPaint(Sender: TObject);
begin
  if (FControlAction=[caSelectObject])and not(eemReadOnly = ActiveDocument.EditMode) then
  begin
      SelectRectPaint(FMouseButtonDownPos.X, FMouseButtonDownPos.Y, FCursorPos.X, FCursorPos.Y);
  end;
end;

procedure TGTFControl.GetViewingArea(Sender: TObject);
begin

   FViewAreaMousePoint  :=PointSCStoPointWCS(FCursorPos.X,FCursorPos.Y);
   FViewAreaAPoint      :=PointSCStoPointWCS(0,0);
   FViewAreaBPoint      :=PointSCStoPointWCS(vbpWidth,0);
   FViewAreaCPoint      :=PointSCStoPointWCS(vbpWidth,vbmHeight);
   FViewAreaDPoint      :=PointSCStoPointWCS(0,vbmHeight);

end;

procedure TGTFControl.OnVerticalScroll(Sender: TObject;
  ScrollCode: TScrollCode; var ScrollPos: Integer);
var
  k:integer;
begin
  if not FScrollBarVerticalUpdate then
  begin
    k:=-1*(FScrollBarVertical.Position)+FTopOutsetBorderHeight;
    SetViewZeroPoint(ActiveDocument.ViewPos.X,k);
    MainControlPaint(FScrollBarVertical);
  end;
end;

procedure TGTFControl.OnHorizontalScroll(Sender: TObject;
  ScrollCode: TScrollCode; var ScrollPos: Integer);
var
  k:integer;
begin
  if not FScrollBarHorizontalUpdate then
  begin
    k:=-1*(FScrollBarHorizontal.Position)+FLeftOutsetBorderWidth;
    SetViewZeroPoint(k,ActiveDocument.ViewPos.Y);
    MainControlPaint(FScrollBarHorizontal);
  end;
end;

procedure TGTFControl.SetGridScale(AValue: Integer);
begin
  if FGridScale=AValue then Exit;
  FGridScale:=AValue;
  if FGridScale<50 then FGridScale:=50;
  if FGridScale>150 then FGridScale:=150;

  if Assigned(FOnChangeGridScale) then
     FOnChangeGridScale(Self);

  SetMessageToUser(IntToStr(FGridScale)+'%');
end;

procedure TGTFControl.SetRowHeight(AValue: Integer);
begin
  if FRowHeight=AValue then Exit;
  FRowHeight:=AValue;
end;

procedure TGTFControl.SLCursorPaint(Sender: TObject);
var
  ColItem :TGTFCOutsetTreeColItem;
  RowItem :TGTFCOutsetTreeRowItem;
  i,e,
  PosY1,PosY2,
  PosY,
  PosX1,PosX2,
  PosX    :integer;
begin
   if (FTodayWayLine) then
   begin
       //Столбцы. Отрисовка подсветки текущего дня(today)
       e:=3;
       for i:=0 to ActiveDocument.Cols.Count-1 do
       begin
           if ActiveDocument.Cols.Items[i].Level=1 then
           begin
             ColItem:=TGTFCOutsetTreeColItem(ActiveDocument.Cols.Items[i]);
             if (CompareDateTime(Now,ColItem.BeginDate)>=0)and(CompareDateTime(Now,ColItem.EndDate)<=0) then
             begin
                 PosX:=ColItem.BeginX+(ColItem.EndX-ColItem.BeginX) div 2;
                 PosX:=PosX+ActiveDocument.FViewPos.X;

                 if PosX<=FLeftOutsetBorderWidth then
                 begin
                    PosX:=FLeftOutsetBorderWidth;
                 end;
                     FDrawLayerMainCanvas.Font.Assign(FDefaultFont);
                     FDrawLayerMainCanvas.Brush.Color :=FCursorColor;
                     FDrawLayerMainCanvas.Brush.Style :=bsSolid;
                     //
                     FDrawLayerMainCanvas.Pen.Style   :=psSolid;
                     FDrawLayerMainCanvas.Pen.Color   :=FCursorColor;
                     FDrawLayerMainCanvas.Pen.Mode    :=pmCopy;

		     FDrawLayerMainCanvas.Pen.Width   :=2;
                     FDrawLayerMainCanvas.Line(PosX,FTopOutsetBorderHeight,PosX,vbmHeight);
                     FDrawLayerMainCanvas.Pen.Width   :=3;
                     FDrawLayerMainCanvas.Ellipse(PosX-e,FTopOutsetBorderHeight-e,PosX+e,FTopOutsetBorderHeight+e);

                 break;
             end;
           end;
       end;
   end;

   if (FWayLine) then
   begin
       //Рамка вокруг даты под курсором
       e:=2;
       FDrawLayerMainCanvas.Brush.Color :=ColorLighter(clHighLight,1);
       FDrawLayerMainCanvas.Pen.Color   :=FDrawLayerMainCanvas.Brush.Color;

       i:=ActiveDocument.GetColUnderCursor;
       if (i>-1)and(i<ActiveDocument.Cols.Count) then
       begin
         ColItem :=TGTFCOutsetTreeColItem(ActiveDocument.Cols.Items[i]);

         PosX1:=ColItem.BeginX+ActiveDocument.FViewPos.X;
         PosX2:=ColItem.EndX+ActiveDocument.FViewPos.X;
         PosX    :=PosX1+(ColWidth) div 2;

         if PosX1<FLeftOutsetBorderWidth then
         begin
           PosX1:=FLeftOutsetBorderWidth;
         end;

         if PosX>FLeftOutsetBorderWidth then
         begin
              FDrawLayerMainCanvas.Ellipse(PosX-e,FTopOutsetBorderHeight-e,PosX+e,FTopOutsetBorderHeight+e);
              DrawHighLightFrame(FDrawLayerMainCanvas,PosX1,(FTopOutsetBorderHeight div 2)+1,PosX2,FTopOutsetBorderHeight-1);
         end;
       end;

       //Строки
       i:=ActiveDocument.GetRowUnderCursor;
       if (i>-1)and(i<ActiveDocument.Rows.Count) then
       begin
          RowItem :=TGTFCOutsetTreeRowItem(ActiveDocument.Rows.Items[i]);
          //h       :=RowItem.Height;
          PosY1   :=RowItem.BeginY+ActiveDocument.FViewPos.Y;
          PosY2   :=RowItem.EndY+ActiveDocument.FViewPos.Y;

          if FTopOutsetBorderHeight>PosY1 then
          begin
             PosY1:=FTopOutsetBorderHeight;
          end;

          PosY    :=PosY1+((PosY2-PosY1) div 2);

          if FTopOutsetBorderHeight<PosY2 then
          begin
            FDrawLayerMainCanvas.Ellipse(FLeftOutsetBorderWidth-e,PosY-e,FLeftOutsetBorderWidth+e,PosY+e);
            DrawHighLightFrame(FDrawLayerMainCanvas,FLeftOutsetBorderWidth,PosY1,vbpWidth,PosY2);
          end;
       end;
   end;

end;

procedure TGTFControl.SLDevelopInfoPaint(Sender: TObject);
var
  xpoint:TGTFPoint;
  DevString:string;
begin
   if FDevelop then
   begin
       FDrawLayerMainCanvas.Font.Assign(FDefaultFont);

       FDrawLayerMainCanvas.Brush.Color := FCursorColor;
       FDrawLayerMainCanvas.Brush.Style := bsSolid;
       FDrawLayerMainCanvas.Font.Assign(FDefaultFont);
       FDrawLayerMainCanvas.Font.Size  := 10; // от 10 до 16
       FDrawLayerMainCanvas.Font.Color := FBackgroundColor;
       xpoint:=PointSCStoPointWCS(FCursorPos.X,FCursorPos.Y);


      DevString:='  Pos X:'+FloatToStr(xpoint.X)+' Y:'+floattostr(xpoint.Y)+'/X:'+IntToStr(FCursorPos.X)+' Y:'+Inttostr(FCursorPos.Y);
      if Assigned(ActiveDocument) then
      begin
      //DevString:=DevString+'  Scale:'+floattostr(ActiveDocument.FViewScale);
      //DevString:=DevString+'  ScaleK:'+inttostr(ActiveDocument.FViewScaleK);
      DevString:=DevString+'  ViewPos+ X:'+floattostr(ActiveDocument.FViewPos.X)+' Y:'+floattostr(ActiveDocument.FViewPos.Y);

      DevString:=DevString+'  IndexCellPos+ C:'+inttostr(ActiveDocument.GetColUnderCursor)+' R:'+inttostr(ActiveDocument.GetRowUnderCursor);

      end;
      DevString:=DevString+'  FControlAction:';

         if FControlAction=[caNone] then
         begin
         DevString:=DevString+'caNone';
         end;
         if FControlAction=[caZoomToFit] then
         begin
         DevString:=DevString+'caZoomToFit';
         end;
         if FControlAction=[caMoveSpace] then
         begin
         DevString:=DevString+'caMoveSpace';
         end;
         if FControlAction=[caMoveVertex] then
         begin
         DevString:=DevString+'caMoveVertex';
         end;
         if FControlAction=[caSelectObject]then
         begin
         DevString:=DevString+'caSelectObject';
         end;
         if FControlAction=[caClickLeft]  then
         begin
         DevString:=DevString+'caClickLeft';
         end;
         if FControlAction=[caClickRight] then
         begin
         DevString:=DevString+'caClickRight';
         end;

         if Assigned(ActiveDocument) then
         begin
           DevString:=DevString+'  TreeRowCount:'+inttostr(ActiveDocument.Rows.Count);
           DevString:=DevString+'  EntityCount:'+inttostr(ActiveDocument.ModelSpace.Objects.Count);
           DevString:=DevString+'  SelectList.Count:'+inttostr(ActiveDocument.SelectList.Count);
           DevString:=DevString+'  SelectedEntity.Count:'+inttostr(ActiveDocument.ModelSpace.SelectedEntityList.Count);
         end;
         FDrawLayerMainCanvas.TextOut(0,0,DevString);
   end;
end;

procedure TGTFControl.SLExtHintPaint(Sender: TObject);
const
  HINT_PADDING_TOP = 16;
  HINT_PADDING_LEFT = 16;
var
  CanvasWidth, CanvasHeight:integer;
begin
  if Assigned(FOnExtHintBeforeDrawEvent) then
  begin
       CanvasHeight:=FHintDrawBitMap.Height;
       CanvasWidth :=FHintDrawBitMap.Width;
       FOnExtHintBeforeDrawEvent(Self, CanvasWidth, CanvasHeight,
                               FHintDrawBitMap.Canvas);
       if (CanvasWidth>0)and(CanvasHeight>0) then
       begin
       FHintDrawBitMap.SetSize(CanvasWidth, CanvasHeight);
       FDrawLayerMainCanvas.Draw(FCursorPos.X+HINT_PADDING_LEFT,
                               FCursorPos.Y+HINT_PADDING_TOP, FHintDrawBitMap);
       end;
  end;
end;

{LogicalCanvasDrawing}

procedure TGTFControl.TextOutTransperent(X, Y: Integer; AText: String);
var
  Pic:TBitmap;
  OldBkMode:integer;
  PicRect,TarRect:trect;
begin
      Pic := TBitmap.Create;
      Pic.Canvas.Font := FDrawLayerMainCanvas.Font;
      Pic.Canvas.Font.Color := clgreen;
      Pic.Canvas.Pen := FDrawLayerMainCanvas.Pen;
      Pic.Width := FDrawLayerMainCanvas.TextWidth(AText);
      Pic.Height := FDrawLayerMainCanvas.TextWidth(AText)+3;
      //PicRect := Rect(0, 0, Pic.Width, Pic.Height);
      //TarRect := Rect(X, Y, X + Pic.Width, Y + Pic.Height);
      //pic.Canvas.CopyRect(PicRect, FDrawLayerMainCanvas, TarRect);
      //pic.Canvas.FillRect(PicRect);
      //Pic.Transparent:=true;
      //Pic.TransparentColor:=Pic.Canvas.Pixels[1,1];
      //Pic.TransparentMode:=tmFixed;
      //SetBkMode(Pic.Canvas.Handle, Transparent);
      //Pic.Canvas.TextOut(0, 0, Text);
      //Pic.TransparentColor:=Pic.Canvas.Pixels[1,1];

      Pic.Canvas.Brush.Color := clRed;
      PicRect := Rect(0, 0, Pic.Width, Pic.Height);
      TarRect := Rect(X, Y, X + Pic.Width, Y + Pic.Height);
      pic.Canvas.CopyRect(PicRect, FDrawLayerMainCanvas, TarRect);
      //pic.Canvas.FillRect(PicRect);
      Pic.Canvas.Brush.Color := clnone;
      Pic.Canvas.Brush.Style := bsclear;
      Pic.Canvas.TextOut(0, 0, AText);
      OldBkMode := SetBkMode(Pic.Handle, TRANSPARENT);
      Pic.Canvas.TextOut(0, 0, AText);
      SetBkMode(Pic.Handle, OldBkMode);

      FDrawLayerMainCanvas.Draw(X, Y,Pic);
      Pic.Free;
end;

//Рисование ручек
procedure TGTFControl.VertexDraw(X, Y: Integer; ATypeVertex: Integer);
var
   PointSCS,
   PointSCS1,
   PointSCS2:TPoint;
   Delta:integer;
begin
  Delta:=5;//FDeltaCord;
  if ATypeVertex=-1 then //all
  begin
      PointSCS:=PointWCSToPointSCS(X,Y);
      VertexPaint(PointSCS.X,PointSCS.Y);
  end
  else if ATypeVertex=VERTEXMARKER_BASEPOINT then //base
  begin
      PointSCS1:=PointWCSToPointSCS(X,Y);
      PointSCS1.X:=PointSCS1.X-Delta;
      PointSCS1.Y:=PointSCS1.Y-Delta;
      PointSCS2:=PointWCSToPointSCS(X,Y);
      PointSCS2.X:=PointSCS2.X+Delta;
      PointSCS2.Y:=PointSCS2.Y+Delta;

      FDrawLayerMainCanvas.Pen.Color    :=FVertexBasePointColor;
      FDrawLayerMainCanvas.Pen.Mode     :=pmCopy;
      FDrawLayerMainCanvas.Pen.Width    :=2;
      FDrawLayerMainCanvas.Brush.Color  :=FVertexBasePointColor;
      FDrawLayerMainCanvas.Brush.Style  :=bsSolid;
      FDrawLayerMainCanvas.Ellipse(rect(PointSCS1.x,PointSCS1.y,PointSCS2.x,PointSCS2.y));
  end
  else if ATypeVertex=VERTEXMARKER_VERTEX then  //vertex
  begin
      PointSCS:=PointWCSToPointSCS(X,Y);
      VertexPaint(PointSCS.X,PointSCS.Y);
  end
  else if ATypeVertex=VERTEXMARKER_CENTER then //center
  begin
      PointSCS1   :=PointWCSToPointSCS(X,Y);
      PointSCS1.X :=PointSCS1.X-Delta;
      PointSCS1.Y :=PointSCS1.Y-Delta;
      PointSCS2   :=PointWCSToPointSCS(X,Y);
      PointSCS2.X :=PointSCS2.X+Delta;
      PointSCS2.Y :=PointSCS2.Y+Delta;

      FDrawLayerMainCanvas.Brush.Color :=FVertexCustomColor;
      FDrawLayerMainCanvas.Brush.Style :=bsClear;
      FDrawLayerMainCanvas.Pen.Color   :=FVertexCustomColor;
      FDrawLayerMainCanvas.Pen.Mode    :=pmCopy;
      FDrawLayerMainCanvas.Pen.Width   :=2;
      FDrawLayerMainCanvas.Ellipse(PointSCS1.X,PointSCS1.Y,PointSCS2.X,PointSCS2.Y);
  end
  else if ATypeVertex=VERTEXMARKER_VERTEX_SEL then //selected
  begin
      PointSCS1:=PointWCSToPointSCS(X,Y);
      PointSCS1.X:=PointSCS1.X-Delta;
      PointSCS1.Y:=PointSCS1.Y-Delta;
      PointSCS2:=PointWCSToPointSCS(X,Y);
      PointSCS2.X:=PointSCS2.X+Delta;
      PointSCS2.Y:=PointSCS2.Y+Delta;

      FDrawLayerMainCanvas.Brush.Color :=FVertexSelectColor;
      FDrawLayerMainCanvas.Pen.Color   :=FVertexSelectColor;
      FDrawLayerMainCanvas.Pen.Mode    :=pmCopy;
      FDrawLayerMainCanvas.Pen.Width   :=1;
      FDrawLayerMainCanvas.Pen.Cosmetic:=False;
      FDrawLayerMainCanvas.Pen.Style   :=psinsideFrame;

      FDrawLayerMainCanvas.Brush.Style := bsSolid;
      FDrawLayerMainCanvas.Ellipse(rect(PointSCS1.x,PointSCS1.y,PointSCS2.x,PointSCS2.y));
  end;
end;

procedure TGTFControl.VertexPaint(X, Y: Integer);
begin

   FDrawLayerMainCanvas.Font.Assign(FDefaultFont);
   FDrawLayerMainCanvas.Brush.Style := bsclear;
   FDrawLayerMainCanvas.Brush.Color := FVertexCustomColor;
   FDrawLayerMainCanvas.Pen.Color:=FVertexCustomColor;
   FDrawLayerMainCanvas.Pen.Mode:=pmCopy;
   FDrawLayerMainCanvas.Pen.Width:=1;

   FDrawLayerMainCanvas.MoveTo(X-FDeltaCord,Y-FDeltaCord);
   FDrawLayerMainCanvas.LineTo (X+FDeltaCord,Y-FDeltaCord);
   FDrawLayerMainCanvas.LineTo (X+FDeltaCord,Y+FDeltaCord);
   FDrawLayerMainCanvas.LineTo (X-FDeltaCord,Y+FDeltaCord);
   FDrawLayerMainCanvas.LineTo (X-FDeltaCord,Y-FDeltaCord);
end;

procedure TGTFControl.SetStyleDraw(LineType:String; LineWidth:TgaLineWeight; AColor:TgaColor);
begin

   if LineType=LINETYPE_DIAGONAL then
   begin
      FDrawLayerMainCanvas.Brush.Color := ValgaColorToValColor(AColor);
      FDrawLayerMainCanvas.Brush.Style := bsBDiagonal;
   end
   else if LineType=LINETYPE_CROSS then
   begin
      FDrawLayerMainCanvas.Brush.Color := ValgaColorToValColor(AColor);
      FDrawLayerMainCanvas.Brush.Style := bsDiagCross;
   end
   else begin
      FDrawLayerMainCanvas.Brush.Color := ValgaColorToValColor(AColor);
      FDrawLayerMainCanvas.Brush.Style := bsSolid;
   end;

   //FDrawLayerMainCanvas.Pen.Cosmetic:=True;
   FDrawLayerMainCanvas.Pen.Mode  := pmCopy;
   FDrawLayerMainCanvas.Pen.Color := ValgaColorToValColor(AColor);
   FDrawLayerMainCanvas.Pen.Width := ValLineWeightToValPixel(LineWidth);
   if LineType<>LINETYPE_SELECTED then
   begin
        FDrawLayerMainCanvas.Pen.Style:=psSolid
   end
   else begin
        FDrawLayerMainCanvas.Pen.Style:=psSolid;
        FDrawLayerMainCanvas.Font.Assign(FDefaultFont);
   end;   

end;

procedure TGTFControl.SetFontStyleDraw(FontName: AnsiString;
  FontSize: Integer; FontStyle: TFontStyles);
var
  i:integer;
  x:real;
begin

    if FGridScale<100 then
    begin
         x:=FGridScale / 100;
         FontSize:=Trunc(FontSize*x);
    end;

    i:=ValWCSToValSCS(FontSize);
    if i>0 then
    begin
      FDrawFont                   :=True;
      FDrawLayerMainCanvas.Font.Size    :=i;
      FDrawLayerMainCanvas.Font.Style   :=FontStyle;
      FDrawLayerMainCanvas.Font.Name    :=FontName;
      FDrawLayerMainCanvas.Font.Color   :=FDrawLayerMainCanvas.Pen.Color;
    end
    else begin
      FDrawFont                   :=False;
    end;
end;

procedure TGTFControl.PointDraw(X, Y: Integer);
var
  PointSCS:TPoint;
begin
   PointSCS:=PointWCSToPointSCS(X,Y);
   FDrawLayerMainCanvas.Pixels[PointSCS.X,PointSCS.Y]:=FDrawLayerMainCanvas.Pen.Color;
end;

procedure TGTFControl.LineDraw(X1, Y1, X2, Y2: Integer);
var
  PointSCS:TPoint;
  PointWCS:TGTFPoint;
begin
   PointWCS.X:=X1;
   PointWCS.Y:=Y1;
   PointSCS:=PointWCSToPointSCS(PointWCS.X,PointWCS.Y);
   FDrawLayerMainCanvas.MoveTo(PointSCS.X,PointSCS.Y);
   PointWCS.X:=X2;
   PointWCS.Y:=Y2;
   PointSCS:=PointWCSToPointSCS(PointWCS.X,PointWCS.Y);
   FDrawLayerMainCanvas.LineTo (PointSCS.X,PointSCS.Y);
end;

procedure TGTFControl.PolylineDraw(APoints: array of TPoint);
var
  i:integer;
  arPoints:Array of TPoint;
begin
   arPoints:=[];
   i:=Length(APoints);
   SetLength(arPoints,i);
   for i:=0 to high(APoints) do
   begin
      arPoints[i]:=PointWCSToPointSCS(APoints[i].X,APoints[i].Y);
   end;
   FDrawLayerMainCanvas.Polyline(arPoints);
end;

{

type
  TPointArr = array of TPoint;

// Вспомогательная функция: вычисление базисной функции B-сплайна
function Basis(i, k: Integer; t: Double; const Knots: array of Double): Double;
var
  denom1, denom2: Double;
begin
  if k = 1 then
  begin
    if (Knots[i] <= t) and (t < Knots[i + 1]) then
      Result := 1
    else
      Result := 0;
    Exit;
  end;

  denom1 := Knots[i + k - 1] - Knots[i];
  denom2 := Knots[i + k] - Knots[i + 1];

  Result := 0;
  if denom1 > 0 then
    Result := Result + (t - Knots[i]) / denom1 * Basis(i, k - 1, t, Knots);
  if denom2 > 0 then
    Result := Result + (Knots[i + k] - t) / denom2 * Basis(i + 1, k - 1, t, Knots);
end;

// Основная процедура рисования B-сплайна
procedure DrawBSpline(Points: TPointArr; Canvas: TCanvas; StepsPerSegment: Integer = 20);
var
  i, j, n, k: Integer;
  t, step: Double;
  x, y: Double;
  Knots: array of Double;
begin
  n := Length(Points);
  if n < 4 then Exit; // Минимум 4 точки для кубического B-сплайна

  k := 3; // Степень сплайна (кубический)

  // Генерация узлового вектора (равномерный, однородный B-сплайн)
  SetLength(Knots, n + k + 2);
  for i := 0 to High(Knots) do
    Knots[i] := i;

  // Рисуем кривую
  for i := k to n do
  begin
    step := (Knots[i + 1] - Knots[i]) / StepsPerSegment;
    t := Knots[i];
    while t < Knots[i + 1] do
    begin
      x := 0;
      y := 0;
      for j := Low(Points) to High(Points) do
      begin
        x := x + Points[j].X * Basis(j, k + 1, t, Knots);
        y := y + Points[j].Y * Basis(j, k + 1, t, Knots);
      end;
      if t = Knots[i] then
        Canvas.MoveTo(Round(x), Round(y))
      else
        Canvas.LineTo(Round(x), Round(y));
      t := t + step;
    end;
  end;
end;

}

procedure DrawSpline(AX1, AY1, AX2, AY2, AX3, AY3, AX4, AY4: Integer; ACanvas: TCanvas);
var
  t: Double;
  x, y: Integer;
  i: Integer;
const
  Steps = 36; // Чем больше, тем плавнее линия
begin
  ACanvas.MoveTo(AX1, AY1);
  for i := 1 to Steps do
  begin
    t := i / Steps;
    // Формула кубического Безье
    x := Round(
      (1 - t) * (1 - t) * (1 - t) * AX1 +
      3 * (1 - t) * (1 - t) * t * AX2 +
      3 * (1 - t) * t * t * AX3 +
      t * t * t * AX4
    );
    y := Round(
      (1 - t) * (1 - t) * (1 - t) * AY1 +
      3 * (1 - t) * (1 - t) * t * AY2 +
      3 * (1 - t) * t * t * AY3 +
      t * t * t * AY4
    );
    ACanvas.LineTo(x, y);
  end;
end;

procedure TGTFControl.LineSDraw(APoints: array of TPoint);
var
  i:integer;
  arPoints:Array of TPoint;
begin
  arPoints:=[];
  i:=Length(APoints);
  SetLength(arPoints,i);
  for i:=0 to high(APoints) do
  begin
      arPoints[i]:=PointWCSToPointSCS(APoints[i].X,APoints[i].Y);
  end;
  DrawSpline(arPoints[0].X,arPoints[0].Y,arPoints[1].X,
  arPoints[1].Y,arPoints[2].X,arPoints[2].Y,
  arPoints[3].X,arPoints[3].Y,FDrawLayerMainCanvas);
end;

procedure TGTFControl.PolygonDraw(APoints: array of TPoint);
var
  i:integer;
  arPoints:Array of TPoint;
begin
   arPoints:=[];
   i:=Length(APoints);
   SetLength(arPoints,i);
   for i:=0 to high(APoints) do
   begin
      arPoints[i]:=PointWCSToPointSCS(APoints[i].X,APoints[i].Y);
   end;
   FDrawLayerMainCanvas.Polygon(arPoints);
end;

procedure TGTFControl.RectangelDraw(TopLeftX, TopLeftY, BottomRightX,
  BottomRightY: Integer);
var
  PointSCS:TPoint;
begin
   PointSCS:=PointWCSToPointSCS(TopLeftX,TopLeftY);
   FDrawLayerMainCanvas.MoveTo(PointSCS.X,PointSCS.Y);
   PointSCS:=PointWCSToPointSCS(BottomRightX,TopLeftY);
   FDrawLayerMainCanvas.LineTo (PointSCS.X,PointSCS.Y);
   PointSCS:=PointWCSToPointSCS(BottomRightX,BottomRightY);
   FDrawLayerMainCanvas.LineTo (PointSCS.X,PointSCS.Y);
   PointSCS:=PointWCSToPointSCS(TopLeftX,BottomRightY);
   FDrawLayerMainCanvas.LineTo (PointSCS.X,PointSCS.Y);
   PointSCS:=PointWCSToPointSCS(TopLeftX,TopLeftY);
   FDrawLayerMainCanvas.LineTo (PointSCS.X,PointSCS.Y);
end;

procedure TGTFControl.FillDraw(TopLeftX, TopLeftY, BottomRightX,
  BottomRightY: Integer);
var
  PointSCS1:TPoint;
  PointSCS2:TPoint;
begin
   PointSCS1:=PointWCSToPointSCS(TopLeftX,TopLeftY);
   PointSCS2:=PointWCSToPointSCS(BottomRightX,BottomRightY);

   if FDrawLayerMainCanvas.Brush.Style = bsBDiagonal then
   begin
      FDrawLayerMainCanvas.Rectangle(PointSCS1.X,PointSCS1.Y,PointSCS2.X,PointSCS2.Y);
   end
   else if FDrawLayerMainCanvas.Brush.Style = bsDiagCross then
   begin
      FDrawLayerMainCanvas.Rectangle(PointSCS1.X,PointSCS1.Y,PointSCS2.X,PointSCS2.Y);
   end
   else
      FDrawLayerMainCanvas.FillRect(PointSCS1.X,PointSCS1.Y,PointSCS2.X,PointSCS2.Y);

end;

procedure TGTFControl.EllipseDraw(X0, Y0, AxleX, AxleY: Integer);
var
  PointSCS1,PointSCS2:TPoint;
begin
   FDrawLayerMainCanvas.Brush.Style:=bsClear;

   PointSCS1:=PointWCSToPointSCS(X0-AxleX,Y0-AxleY);
   PointSCS2:=PointWCSToPointSCS(X0+AxleX,Y0+AxleY);
   FDrawLayerMainCanvas.Ellipse(PointSCS1.X,PointSCS1.Y,PointSCS2.X,PointSCS2.Y);
end;

procedure TGTFControl.CircleDraw(X, Y, Radius: Integer);
var
  PointSCS1,PointSCS2:TPoint;
begin
   FDrawLayerMainCanvas.Brush.Style:=bsClear;

   PointSCS1:=PointWCSToPointSCS(X-Radius,Y-Radius);
   PointSCS2:=PointWCSToPointSCS(X+Radius,Y+Radius);
   FDrawLayerMainCanvas.Ellipse(PointSCS1.X,PointSCS1.Y,PointSCS2.X,PointSCS2.Y);
end;

procedure TGTFControl.ArcDraw(X0, Y0, X1, Y1, X2, Y2, Radius: Integer);
var
  PointSCS1,PointSCS2,PointSCS3,PointSCS4:TPoint;
  BasePointWCS:TGTFPoint;
begin
{
  Рисует дугу.
  Параметры x1, y1, x2 и y2 задают эллипс, частью которого является дуга, параметры
  x3, y3, x4 и y4 ― начальную и конечную точку дуги. Цвет дуги определяет свойство Pen.Color.
}
   FDrawLayerMainCanvas.Brush.Style:=bsClear;

   BasePointWCS.X:=X0;
   BasePointWCS.Y:=Y0;
   //определяем габарит элипса
   PointSCS1:=PointWCSToPointSCS(BasePointWCS.X-Radius,BasePointWCS.Y-Radius);
   PointSCS2:=PointWCSToPointSCS(BasePointWCS.X+Radius,BasePointWCS.Y+Radius);
   //определяем точки концов дуги
   PointSCS3:=PointWCSToPointSCS(X1,Y1);
   PointSCS4:=PointWCSToPointSCS(X2,Y2);

   FDrawLayerMainCanvas.Arc(PointSCS1.X,PointSCS1.Y,PointSCS2.X,PointSCS2.Y,PointSCS3.X,PointSCS3.Y,PointSCS4.X,PointSCS4.Y);
end;

procedure TGTFControl.TextDraw(X0, Y0, AWidth, AHeight: Integer;
  Rotate: integer; AText: String; AAlign: TgaAttachmentPoint);
var
  PointSCS1,
  fpcPoint1,
  fpcPoint2:TPoint;
  TopLeftPointWCS,
  BottomRightPointWCS:TGTFPoint;
  ARect:TRect;
  W,H:Integer;
begin
   if FDrawFont then
   begin
   if (AWidth<=0)or(AHeight<=0) then
   begin
      W:=FDrawLayerMainCanvas.TextWidth(AText);
      H:=FDrawLayerMainCanvas.TextHeight(AText);

      case AAlign of
      gaAttachmentPointTopLeft:
      begin
          PointSCS1:=PointWCSToPointSCS(X0,Y0);
      end;
      gaAttachmentPointTopCenter:
      begin
          PointSCS1:=PointWCSToPointSCS(X0,Y0);
          PointSCS1.X:=PointSCS1.X-W div 2;
      end;
      gaAttachmentPointTopRight:
      begin
          PointSCS1:=PointWCSToPointSCS(X0,Y0);
          PointSCS1.X:=PointSCS1.X-W;
      end;
      gaAttachmentPointMiddleLeft:
      begin
          PointSCS1:=PointWCSToPointSCS(X0,Y0);
          PointSCS1.Y:=PointSCS1.Y-H div 2;
      end;
      gaAttachmentPointMiddleCenter:
      begin
          PointSCS1:=PointWCSToPointSCS(X0,Y0);
          PointSCS1.X:=PointSCS1.X-W div 2;
          PointSCS1.Y:=PointSCS1.Y-H div 2;
      end;
      gaAttachmentPointMiddleRight:
      begin
          PointSCS1:=PointWCSToPointSCS(X0,Y0);
          PointSCS1.X:=PointSCS1.X-W;
          PointSCS1.Y:=PointSCS1.Y-H div 2;
      end;
      gaAttachmentPointBottomLeft:
      begin
          PointSCS1:=PointWCSToPointSCS(X0,Y0);
          PointSCS1.X:=PointSCS1.X;
          PointSCS1.Y:=PointSCS1.Y-H;
      end;
      gaAttachmentPointBottomCenter:
      begin
          PointSCS1:=PointWCSToPointSCS(X0,Y0);
          PointSCS1.X:=PointSCS1.X-W div 2;
          PointSCS1.Y:=PointSCS1.Y-H;
      end;
      gaAttachmentPointBottomRight:
      begin
          PointSCS1:=PointWCSToPointSCS(X0,Y0);
          PointSCS1.X:=PointSCS1.X-W;
          PointSCS1.Y:=PointSCS1.Y-H;
      end;
      end;

      FDrawLayerMainCanvas.Brush.Style:=bsClear;//Прозрачный текст
      FDrawLayerMainCanvas.TextOut(PointSCS1.X,PointSCS1.Y,AText);
   end
   else begin

      case AAlign of
      gaAttachmentPointTopLeft:
      begin
          TopLeftPointWCS.X:=X0;
          TopLeftPointWCS.Y:=Y0;
          BottomRightPointWCS.X:=X0+AWidth;
          BottomRightPointWCS.Y:=Y0+AHeight;
          PointSCS1:=PointWCSToPointSCS(X0,Y0);
      end;
      gaAttachmentPointTopCenter:
      begin
          TopLeftPointWCS.X:=X0-Width div 2;
          TopLeftPointWCS.Y:=Y0;
          BottomRightPointWCS.X:=X0+AWidth div 2;
          BottomRightPointWCS.Y:=Y0+AHeight;
          PointSCS1:=PointWCSToPointSCS(X0-AWidth div 2,Y0);
      end;
      gaAttachmentPointTopRight:
      begin
          TopLeftPointWCS.X:=X0-AWidth;
          TopLeftPointWCS.Y:=Y0;
          BottomRightPointWCS.X:=X0;
          BottomRightPointWCS.Y:=Y0+AHeight;
          PointSCS1:=PointWCSToPointSCS(X0-AWidth,Y0);
      end;
      gaAttachmentPointMiddleLeft:
      begin //
          TopLeftPointWCS.X:=X0;
          TopLeftPointWCS.Y:=Y0+AHeight div 2;
          BottomRightPointWCS.X:=X0+AWidth;
          BottomRightPointWCS.Y:=Y0-AHeight div 2;
          PointSCS1:=PointWCSToPointSCS(X0,Y0-AHeight div 2);
      end;
      gaAttachmentPointMiddleCenter:
      begin
          TopLeftPointWCS.X:=X0-AWidth div 2;
          TopLeftPointWCS.Y:=Y0-AHeight div 2;
          BottomRightPointWCS.X:=X0+AWidth div 2;
          BottomRightPointWCS.Y:=Y0+AHeight div 2;
          PointSCS1:=PointWCSToPointSCS(X0-AWidth div 2,Y0-AHeight div 2);
      end;
      gaAttachmentPointMiddleRight:
      begin
          TopLeftPointWCS.X:=X0-AWidth;
          TopLeftPointWCS.Y:=Y0-AHeight div 2;
          BottomRightPointWCS.X:=X0;
          BottomRightPointWCS.Y:=Y0+AHeight div 2;
          PointSCS1:=PointWCSToPointSCS(X0-AWidth,Y0-AHeight div 2);
      end;
      gaAttachmentPointBottomLeft:
      begin
          TopLeftPointWCS.X:=X0;
          TopLeftPointWCS.Y:=Y0-AHeight;
          BottomRightPointWCS.X:=X0+AWidth;
          BottomRightPointWCS.Y:=Y0;
          PointSCS1:=PointWCSToPointSCS(X0,Y0-AHeight);
      end;
      gaAttachmentPointBottomCenter:
      begin
          TopLeftPointWCS.X:=X0-AWidth div 2;
          TopLeftPointWCS.Y:=Y0-AHeight;
          BottomRightPointWCS.X:=X0+AWidth div 2;
          BottomRightPointWCS.Y:=Y0;
          PointSCS1:=PointWCSToPointSCS(X0-AWidth div 2,Y0-AHeight);
      end;
      gaAttachmentPointBottomRight:
      begin
          TopLeftPointWCS.X     :=X0-AWidth;
          TopLeftPointWCS.Y     :=Y0-AHeight;
          BottomRightPointWCS.X :=X0;
          BottomRightPointWCS.Y :=Y0;
          PointSCS1             :=PointWCSToPointSCS(X0-AWidth,Y0-AHeight);
      end;
      end;
      fpcPoint1 :=PointWCSToPointSCS(TopLeftPointWCS.X,TopLeftPointWCS.Y);
      fpcPoint2 :=PointWCSToPointSCS(BottomRightPointWCS.X,BottomRightPointWCS.Y);
      ARect     :=Rect(fpcPoint1.x,fpcPoint1.y,fpcPoint2.x,fpcPoint2.y);

      FDrawLayerMainCanvas.Brush.Style:=bsClear;//Прозрачный текст -ValWCSToValSCS(2.15)
      FDrawLayerMainCanvas.TextRect(ARect,PointSCS1.X,PointSCS1.Y,AText);

      if FDevelop then
      begin
          FDrawLayerMainCanvas.Pen.Mode:=pmcopy;
          FDrawLayerMainCanvas.Brush.Color:=clSilver;
          FDrawLayerMainCanvas.FrameRect(ARect);//прямоугольник  вокруг текста
      end;

   end;
   end;//FDrawFont
end;

procedure TGTFControl.MsgMouseWheel(var Msg: TWMMouseWheel);
begin

end;

{Load/Save}

procedure TGTFControl.SaveToFileAsJPEG(AFileName: String);
var
  jpeg:Graphics.TJPEGImage;
begin
  jpeg :=Graphics.TJPEGImage.Create;
  try
      DataBitMapEnabled:=True;
      Repaint;
      jpeg.Assign(DataBitMap);
      jpeg.CompressionQuality:=100;
      jpeg.SaveToFile(AFileName);
  finally
      jpeg.Free;
      DataBitMapEnabled:=False;
      Application.ProcessMessages;
      Repaint;
  end;
end;

function TGTFControl.GetCursorPoint: TGTFPoint;
begin
  Result:=FViewAreaMousePoint;
end;

procedure TGTFControl.SetViewZeroPoint(AX, AY: Integer);
begin
  ActiveDocument.FViewPos.X:=AX;
  ActiveDocument.FViewPos.Y:=AY;
end;

{ TGTFDrawDocument }

function TGTFDrawDocument.GetDeltaVertex: Integer;
var
  X2:Double;
begin
     X2:=DELTASELECTVERTEX;
     Result:=Trunc(X2);
end;

function TGTFDrawDocument.GetRowUnderPoint(APoint: TGTFPoint): Integer;
var
  i,l:integer;
  Item:TGTFCOutsetTreeRowItem;
begin
  Result :=-1;
  l      :=Rows.LevelCount-1;
  for i:=0 to Rows.Count-1 do
  begin
     Item:=TGTFCOutsetTreeRowItem(Rows.Items[i]);
     if (not DrawControl.ShowGroupHorizontal)and(Item.Level=l) then
     begin
        if (((Item.BeginY<=APoint.Y)and(Item.EndY>=APoint.Y))and
            ((not Item.RowFiltered)or
            ((Item.RowFiltered)and(not Item.RowParentFiltered))))
            and(not Item.Separator) then
        begin
              Result:=i;
              break;
        end;
     end
     else if (DrawControl.ShowGroupHorizontal)  then
     begin
        if (((Item.BeginY<=APoint.Y)and(Item.EndY>=APoint.Y))and
            ((not Item.RowFiltered)or
            ((Item.RowFiltered)and(not Item.RowParentFiltered))))
            and(not Item.Separator) then
        begin
              Result:=i;
              break;
        end;
      end;
  end;
end;

function TGTFDrawDocument.GetColUnderPoint(APoint: TGTFPoint): Integer;
var
  i,l:integer;
  PosX1,PosX2:integer;
  Item:TGTFCOutsetTreeColItem;
begin
  Result :=-1;
  l      :=Cols.LevelCount-1;
  for i:=0 to Cols.Count-1 do
  begin
      Item:=TGTFCOutsetTreeColItem(Cols.Items[i]);
      if Item.Level=l then
      begin
        PosX1        :=Item.BeginX;
        PosX2        :=Item.EndX;
        if (PosX1<=APoint.X)and(PosX2>=APoint.X) then
        begin
            Result:=i;
            break;
        end;
      end;
  end;
end;

function TGTFDrawDocument.GetColByDateTime(AValue: TDateTime): Integer;
var
  i,l:integer;
  Item:TGTFCOutsetTreeColItem;
begin
  Result :=-1;
  l      :=Cols.LevelCount-1;
  for i:=0 to Cols.Count-1 do
  begin
      Item:=TGTFCOutsetTreeColItem(Cols.Items[i]);
      if Item.Level=l then
      begin
      if DateTimeInRange(AValue,Item.BeginDate,Item.EndDate) then
      begin
          Result:=i;
          break;
      end;
      end;
  end;
end;

function TGTFDrawDocument.GetRowUnderCursor: Integer;
var
  CurPos: TGTFPoint;
begin
  CurPos:=DrawControl.GetCursorPoint;
  Result:=GetRowUnderPoint(CurPos);
end;

function TGTFDrawDocument.GetColUnderCursor: Integer;
var
  CurPos: TGTFPoint;
begin
  CurPos:=DrawControl.GetCursorPoint;
  Result:=GetColUnderPoint(CurPos);
end;

function TGTFDrawDocument.GetDocument: TGTFDrawDocumentCustom;
begin
  Result:=Self;
end;

constructor TGTFDrawDocument.Create(AOwner: TComponent);
begin
  inherited Create;
  FEditMode                 :=eemCanAll;
  ModelSpace               :=TWorkSpace.Create; //Создание рабочего пространства
  ModelSpace.OnGetDocument :=@GetDocument;

  FSelectList                    :=TList.Create;
  ModelSpace.SelectedEntityList  :=FSelectList;
  FDrawControl                   :=TGTFControl(AOwner);
  Rows                           :=TGTFCOutsetRowTree.Create;
  Cols                           :=TGTFCOutsetColTree.Create;
  FExtColumns                    :=TGTFCListColumns.Create;
  //Предустановки параметров GetFontData(Application.MainForm.Handle)
  FFontSize                       :=8;
  FFontName                       :=Screen.SystemFont.Name;

  FViewPos.X                     :=10;
  FViewPos.Y                     :=10;
  FViewPos.Z                     :=10;

  {
  FViewBookmark.HBookmark        :=True;
  FViewBookmark.VBookmark        :=False;
  FViewBookmark.HBookmarkValue   :=DateUtils.IncDay(Now,-2);
  FViewBookmark.VBookmarkValue   :=Null;
  }

  BookmarkToNow;

  EntityIDCountIndexA:=0;
  EntityIDCountIndexB:=0;
  EntityIDCountIndexC:=0;
  EntityIDCountIndexD:=0;
end;

procedure TGTFDrawDocument.BookmarkToNow;
begin
  FViewBookmark.HBookmark        :=True;
  FViewBookmark.VBookmark        :=False;
  case FDrawControl.GraphMultiplicity of
    gmHour:
    begin
       FViewBookmark.HBookmarkValue   :=DateUtils.IncHour(Now,-2);
    end;
    gmDay:
    begin
       FViewBookmark.HBookmarkValue   :=DateUtils.IncDay(Now,-2);
    end;
    else
    begin
       FViewBookmark.HBookmarkValue   :=DateUtils.IncDay(Now,-2);
    end;
  end;
  FViewBookmark.VBookmarkValue   :=Null;
end;

procedure TGTFDrawDocument.DeselectAll;
begin
  FSelectList.Clear;
  FDrawControl.EndMoveVertex(self);
  FDrawControl.FControlAction:=[caNone];
  if Assigned(FDrawControl.OnSelectListChange) then
     FDrawControl.OnSelectListChange(FDrawControl);
  DrawControl.Refresh;
end;

procedure TGTFDrawDocument.Clear;
begin
  DeselectAll;
  EntityIDCountIndexA:=0;
  EntityIDCountIndexB:=0;
  EntityIDCountIndexC:=0;
  EntityIDCountIndexD:=0;
  SetLength(FMVertArray,0);
  FSelectList.Clear;
  ModelSpace.Objects.Clear;
  Rows.Clear;
  Cols.Clear;
end;

destructor TGTFDrawDocument.Destroy;
begin
  FDrawControl:=nil;
  SetLength(FMVertArray,0);
  ModelSpace.Free;
  FSelectList.Free;
  Rows.Free;
  Cols.Free;
  FExtColumns.Free;
  inherited Destroy;
end;

function TGTFDrawDocument.CreateTask: TGraphicTask;
begin
  Result:=TGraphicTask.Create;
  Result.ID:=GetEntityID;
end;

function TGTFDrawDocument.CreateConnectionline: TGraphicConnectionline;
begin
  Result:=TGraphicConnectionline.Create;
  Result.ID:=GetEntityID;
end;

function TGTFDrawDocument.GetEntityID: ShortString;
begin
  inc(EntityIDCountIndexA);
  if EntityIDCountIndexA>255 then
  begin
    EntityIDCountIndexA:=0;
    inc(EntityIDCountIndexB);
  end;
  if EntityIDCountIndexB>255 then
  begin
    EntityIDCountIndexB:=0;
    inc(EntityIDCountIndexC);
  end;
  if EntityIDCountIndexC>255 then
  begin
    EntityIDCountIndexC:=0;
    inc(EntityIDCountIndexD);
  end;
  if (EntityIDCountIndexD>255) then
  begin
    raise Exception.Create('Превышен лимит объектов.');
  end;
  Result :='GAC$'+IntToHex(EntityIDCountIndexA,2)+IntToHex(EntityIDCountIndexB,2)
              +IntToHex(EntityIDCountIndexC,2)+IntToHex(EntityIDCountIndexD,2);
end;

procedure TGTFDrawDocument.MVertArray(Value: TModifyVertex);
var
  Counter,Count,i:Integer;
  TrueCopy:boolean;
  Temp:TModifyVertexArray;
begin
  Count:=Length(FMVertArray);
  TrueCopy:=false;
  Counter:=0;
  SetLength(Temp,Counter);
  for I := 0 to Count-1 do
  begin
    if (FMVertArray[i].Item<>Value.Item)
    and(FMVertArray[i].VertexPos.X<>Value.VertexPos.X)
    and(FMVertArray[i].VertexPos.Y<>Value.VertexPos.Y)
    and(FMVertArray[i].VertexPos.Z<>Value.VertexPos.Z) then
    begin
       Counter:=Counter+1;
       SetLength(Temp,Counter);
       Temp[Counter-1]:=FMVertArray[i];
    end
    else TrueCopy:=true;
  end;

  if not TrueCopy then
  begin
    Counter:=Counter+1;
    SetLength(Temp,Counter);
    Temp[Counter-1].Item:=Value.Item;
    Temp[Counter-1].VertexPos:=Value.VertexPos;
    Temp[Counter-1].VertexIndex:=Value.VertexIndex;
  end;

  SetLength(FMVertArray,Counter);
  for I := 0 to Counter-1 do
  begin
    FMVertArray[i]:=Temp[i];
  end;

end;

end.
