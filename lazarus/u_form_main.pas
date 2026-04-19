unit u_form_main;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, ExtCtrls,
  StdCtrls, ComCtrls, EditBtn, ExtDlgs, Menus, u_gtfc_drawcontrol,
  u_gtfc_visualobjects, u_gtfc_objecttree, DateUtils, u_gtfc_const, ComObj;

type

  { TFgassicMain }

  TFgassicMain = class(TForm)
    btnAddFrame: TButton;
    btnClearFrame: TButton;
    btnDeselectAll: TButton;
    Button1: TButton;
    Button10: TButton;
    Button11: TButton;
    Button12: TButton;
    Button2: TButton;
    Button3: TButton;
    Button4: TButton;
    Button5: TButton;
    Button6: TButton;
    Button7: TButton;
    Button8: TButton;
    Button9: TButton;
    cbDevMode: TCheckBox;
    cbAAINSIDE: TCheckBox;
    cbAABASEPOINT: TCheckBox;
    cbAAVERTEX: TCheckBox;
    cbAABORDER: TCheckBox;
    cbGraphMultiplicity: TComboBox;
    cbWayLine: TCheckBox;
    CheckBox1: TCheckBox;
    CheckBox2: TCheckBox;
    CheckBox3: TCheckBox;
    DateEdit1: TDateEdit;
    DateEdit2: TDateEdit;
    Memo1: TMemo;
    MenuItem1: TMenuItem;
    MenuItem2: TMenuItem;
    MenuItem3: TMenuItem;
    MenuItem4: TMenuItem;
    MenuItem5: TMenuItem;
    MenuItem6: TMenuItem;
    PageControl1: TPageControl;
    pnlBox: TPanel;
    pnlRight: TPanel;
    pnlTop: TPanel;
    PopupMenu1: TPopupMenu;
    PopupMenu2: TPopupMenu;
    SavePictureDialog1: TSavePictureDialog;
    TabSheet1: TTabSheet;
    TabSheet2: TTabSheet;
    TabSheet3: TTabSheet;
    TabSheet5: TTabSheet;
    TabSheet6: TTabSheet;
    procedure btnAddFrameClick(Sender: TObject);
    procedure btnArcClick(Sender: TObject);
    procedure btnBlockCreate2Click(Sender: TObject);
    procedure btnBlockCreate3Click(Sender: TObject);
    procedure btnBlockCreateClick(Sender: TObject);
    procedure btnBlockInsert1Click(Sender: TObject);
    procedure btnBlockInsertClick(Sender: TObject);
    procedure btnCircleClick(Sender: TObject);
    procedure btnClearFrameClick(Sender: TObject);
    procedure btnConnLineClick(Sender: TObject);
    procedure btnDeselectAllClick(Sender: TObject);
    procedure btnEllipseClick(Sender: TObject);
    procedure btnLineClick(Sender: TObject);
    procedure btnPointClick(Sender: TObject);
    procedure btnPolyline1Click(Sender: TObject);
    procedure btnPolylineClick(Sender: TObject);
    procedure btnZoomToFitClick(Sender: TObject);
    procedure btnImportBlockClick(Sender: TObject);
    procedure btnTextClick(Sender: TObject);
    procedure btnBlockCreate1Click(Sender: TObject);
    procedure Button10Click(Sender: TObject);
    procedure Button11Click(Sender: TObject);
    procedure Button12Click(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure Button4Click(Sender: TObject);
    procedure Button5Click(Sender: TObject);
    procedure Button6Click(Sender: TObject);
    procedure Button7Click(Sender: TObject);
    procedure Button8Click(Sender: TObject);
    procedure Button9Click(Sender: TObject);
    procedure cbAABASEPOINTChange(Sender: TObject);
    procedure cbAABORDERChange(Sender: TObject);
    procedure cbAAINSIDEChange(Sender: TObject);
    procedure cbAAOUTSIDEChange(Sender: TObject);
    procedure cbAAVERTEXChange(Sender: TObject);
    procedure cbColorSelectChange(Sender: TObject);
    procedure cbGraphMultiplicityChange(Sender: TObject);
    procedure cbLineWeightChange(Sender: TObject);
    procedure cbDevModeChange(Sender: TObject);
    procedure cbAxesChange(Sender: TObject);
    procedure cbReadOnlyChange(Sender: TObject);
    procedure cbWayLineChange(Sender: TObject);
    procedure CheckBox1Change(Sender: TObject);
    procedure CheckBox2Change(Sender: TObject);
    procedure CheckBox3Change(Sender: TObject);
    procedure ComboBox1Change(Sender: TObject);
    procedure edtscaleKeyPress(Sender: TObject; var Key: char);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure ListView1ColumnClick(Sender: TObject; Column: TListColumn);
    procedure Memo2Change(Sender: TObject);
    procedure pnlBoxClick(Sender: TObject);
  private
    procedure AddTask(Sender: TObject);
    procedure BlockJoin(Sender: TObject);
    procedure ClickEvent(Sender: TObject);
    procedure EditingDoneEvent(Sender: TObject);
    procedure EntityAfterEditEvent(Sender: TObject; AEntity: TEntity);
    procedure EntityBeforeEditEvent(Sender: TObject; AEntity: TEntity;
      var CanEdit: Boolean);
    procedure EntityEditEvent(Sender: TObject; AEntity: TEntity; AColIndex,
      ARowIndex: integer);
    procedure EntitySelectEvent(Sender: TObject; AEntity: TEntity;
      var CanSelect: Boolean);
    procedure GenerateTask(ARowKey: integer; ACount: integer; AText: ShortString);
    procedure GenerateTask2(ARowKey: integer);
    procedure GenerateTask2Frame(ARowKey: integer; ACount: integer);
    procedure GTFControlMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure GTFControlOutsetTreeRowEvent(Sender: TObject;
      ATreeItem: TGTFCOutsetTreeBasicItem; ATarget: TGTFCOutsetTreeClickResult);
    { private declarations }
  public
    { public declarations }
    procedure ChangeSelectList(Sender: TObject);
    procedure EntityBeforeDrawEvent(Sender: TObject; AEntity:TEntity; var CanDraw:Boolean);
    procedure EntityAfterDrawEvent(Sender: TObject; AEntity:TEntity);
  end;

var
  FgassicMain: TFgassicMain;
  GTFControl:TGTFControl;

implementation

{$R *.lfm}

{ TFgassicMain }

procedure TFgassicMain.pnlBoxClick(Sender: TObject);
begin

end;

procedure TFgassicMain.EditingDoneEvent(Sender: TObject);
begin
   beep;
end;

procedure TFgassicMain.EntityAfterEditEvent(Sender: TObject; AEntity: TEntity);
begin

end;

procedure TFgassicMain.EntityBeforeEditEvent(Sender: TObject; AEntity: TEntity;
  var CanEdit: Boolean);
var
  TaskItem:TGraphicTask;
begin
  if AEntity is TGraphicTask then
  begin
     TaskItem:=TGraphicTask(AEntity);
     if TaskItem.BGTaskStyle in [bgtsCross, bgtsDiagonal] then
     begin
         CanEdit:=False;
     end;
  end;
end;

procedure TFgassicMain.EntityEditEvent(Sender: TObject; AEntity: TEntity;
  AColIndex, ARowIndex: integer);
var
  TaskItem:TGraphicTask;
  iDays:integer;
  dTime:Double;
  ColItem:TGTFCOutsetTreeColItem;
  RowItem:TGTFCOutsetTreeRowItem;
begin
  if AEntity is TGraphicTask then
  begin
     TaskItem :=TGraphicTask(AEntity);
     iDays    :=DateUtils.DaysBetween(TaskItem.TimeBegin,TaskItem.TimeEnd);
     dTime    :=TaskItem.TimeEnd-TaskItem.TimeBegin;
     if AColIndex>-1 then
     begin
          ColItem:=TGTFCOutsetTreeColItem(GTFControl.ActiveDocument.Cols.Items[AColIndex]);
          TaskItem.TimeBegin:=ColItem.BeginDate;
          TaskItem.TimeEnd:=ColItem.BeginDate+dTime;
     end;
     if ARowIndex>-1 then
     begin
          RowItem:=TGTFCOutsetTreeRowItem(GTFControl.ActiveDocument.Rows.Items[ARowIndex]);
          TaskItem.GridRow:=RowItem;
     end;
  end;
end;

procedure TFgassicMain.EntitySelectEvent(Sender: TObject; AEntity: TEntity;
  var CanSelect: Boolean);
var
  TaskItem  :TGraphicTask;
  glTmpItem :TGraphicLandmark;
begin
  //Можно или нельзя выбирать
  if AEntity is TGraphicTask then
  begin
     TaskItem:=TGraphicTask(AEntity);
     if TaskItem.BGTaskStyle in [bgtsDiagonal] then
     begin
         CanSelect:=False;
     end;
  end
  else if AEntity is TGraphicFrameLine then
  begin
     CanSelect:=True;
  end
  else if AEntity is TGraphicLandmark then
  begin
     CanSelect:=True;
  end;
end;

procedure TFgassicMain.ChangeSelectList(Sender: TObject);
var
  EntityItem:TEntity;
  i:integer;
begin
  Memo1.Lines.Clear;
  for I := 0 to GTFControl.ActiveDocument.SelectList.Count - 1 do
  begin
      EntityItem:=TEntity(GTFControl.ActiveDocument.SelectList.Items[i]);
      Memo1.Lines.Add(EntityItem.ClassName);
  end;
end;

procedure TFgassicMain.EntityBeforeDrawEvent(Sender: TObject; AEntity: TEntity;
  var CanDraw: Boolean);
begin
  //AEntity.Color:=0;
end;

procedure TFgassicMain.EntityAfterDrawEvent(Sender: TObject; AEntity: TEntity);
begin

end;

procedure TFgassicMain.FormCreate(Sender: TObject);
begin
  GTFControl        :=TGTFControl.Create(FgassicMain);
  GTFControl.Parent :=self.pnlBox;

  GTFControl.PopupMenuGridArea             :=PopupMenu2;
  GTFControl.PopupMenuLeftOutsetArea       :=PopupMenu1;

  {$IFNDEF FPC}
    AssiDrawControl.OnSelectListChange      :=ChangeSelectList;
  {$ELSE}
    GTFControl.OnSelectListChange      :=@ChangeSelectList;
    GTFControl.OnEntityAfterDrawEvent  :=@EntityAfterDrawEvent;
    GTFControl.OnEntityBeforeDrawEvent :=@EntityBeforeDrawEvent;
    GTFControl.OnEditingDone           :=@EditingDoneEvent;
    GTFControl.OnClick                 :=@ClickEvent;
    GTFControl.OnEntityBeforeEditEvent :=@EntityBeforeEditEvent;
    GTFControl.OnEntityAfterEditEvent  :=@EntityAfterEditEvent;
    GTFControl.OnEntityEditEvent       :=@EntityEditEvent;
    GTFControl.OnEntitySelectEvent     :=@EntitySelectEvent;
    GTFControl.OnMouseMove             :=@GTFControlMouseMove;

    //GTFControl.OnChangeGridScale                  :=;

    GTFControl.OnOutsetTreeRowEvent:=@GTFControlOutsetTreeRowEvent;
  {$ENDIF}
  GTFControl.Top       :=0;
  GTFControl.Left      :=0;
  GTFControl.Width     :=pnlBox.Width;
  GTFControl.Height    :=pnlBox.Height;
  GTFControl.Align     :=alClient;
  //GTFControl.FrameViewModeSet('DemoText',clBlue);

  GTFControl.ActiveDocument.EditMode:=eemReadOnly;
  GTFControl.AntiLayering :=true;

  GTFControl.TreeButtonStyle :=gtbsRectangle;  //gtbsNot    gtbsTriangle gtbsDot

  GTFControl.Show;
end;

procedure TFgassicMain.btnEllipseClick(Sender: TObject);
begin

end;

procedure TFgassicMain.btnLineClick(Sender: TObject);
begin

end;

procedure TFgassicMain.btnPointClick(Sender: TObject);
begin

end;

procedure TFgassicMain.btnPolyline1Click(Sender: TObject);
begin

end;

procedure TFgassicMain.btnPolylineClick(Sender: TObject);
begin

end;

procedure TFgassicMain.btnDeselectAllClick(Sender: TObject);
begin
  GTFControl.ActiveDocument.DeselectAll;
  GTFControl.AddMessageToUser('Выполнено');
end;

procedure TFgassicMain.btnCircleClick(Sender: TObject);
begin

end;

procedure TFgassicMain.btnClearFrameClick(Sender: TObject);
begin
  GTFControl.FrameViewModeClear;
end;

procedure TFgassicMain.BlockJoin(Sender: TObject);
begin

end;

procedure TFgassicMain.ClickEvent(Sender: TObject);
var
  Cur:TGTFPoint;
  Item:TEntity;
begin
  Cur:=GTFControl.GetCursorPoint;
  //ignore etConnectionLine
  Item:=GTFControl.GetObjectUnderRect(Cur,Cur,[etTask,etFrameLine,etLandmark]);
  if not Assigned(Item) then
  begin
     GTFControl.ActiveDocument.DeselectAll;
  end;
end;

procedure TFgassicMain.btnConnLineClick(Sender: TObject);
begin

end;

procedure TFgassicMain.btnBlockCreate2Click(Sender: TObject);
begin

end;

procedure TFgassicMain.btnBlockCreate3Click(Sender: TObject);
begin

end;

procedure TFgassicMain.btnAddFrameClick(Sender: TObject);
begin
  GTFControl.FrameViewModeSet('Sample frame mode',clBlue);
end;

procedure TFgassicMain.btnArcClick(Sender: TObject);
begin

end;

procedure TFgassicMain.btnBlockCreateClick(Sender: TObject);
begin

end;

procedure TFgassicMain.btnBlockInsert1Click(Sender: TObject);
begin

end;

procedure TFgassicMain.btnBlockInsertClick(Sender: TObject);
begin

end;

procedure TFgassicMain.btnZoomToFitClick(Sender: TObject);
begin

end;

procedure TFgassicMain.btnImportBlockClick(Sender: TObject);
begin

end;

procedure TFgassicMain.btnTextClick(Sender: TObject);
begin

end;

procedure TFgassicMain.btnBlockCreate1Click(Sender: TObject);
begin

end;

procedure TFgassicMain.Button10Click(Sender: TObject);
begin
 GTFControl.ActiveDocument.EditMode:=eemCanAll;
end;

procedure TFgassicMain.Button11Click(Sender: TObject);
begin
  GTFControl.ScrollToNow;
  GTFControl.Refresh;
end;

procedure TFgassicMain.Button12Click(Sender: TObject);
begin
  GTFControl.ScrollToBegin;
  GTFControl.Refresh;
end;

procedure TFgassicMain.AddTask(Sender: TObject);
var
  x:TGraphicTask;
begin
  x:=GTFControl.ActiveDocument.CreateTask;
  //x.Row:=nil;
  x.Data:=nil;
  x.Text:='Hello';
  x.TimeBegin:=0;
  x.TimeEnd:=0;
  x.Color:=Random(255);//GTFControl.ActiveDocument.DefaultColor;
  GTFControl.ActiveDocument.ModelSpace.Objects.Add(x);
  x.Created;
end;

procedure TFgassicMain.Button1Click(Sender: TObject);
var
  i1,i2,i3,Index:integer;

  Item1,Item2,Item3:TGTFCOutsetTreeRowItem;
begin
  Randomize;

  GTFControl.ActiveDocument.Rows.BeginUpdate;
  GTFControl.ActiveDocument.Rows.Clear;
  GTFControl.ActiveDocument.ModelSpace.Objects.Clear;
  GTFControl.ShowGroupHorizontal:=CheckBox2.Checked;

  GTFControl.ActiveDocument.SetFirstColumn('Договор');
  GTFControl.ActiveDocument.SetExtendedColumns(['Статус','Начало','Окончание']);

  for i1:=0 to 0 do
  begin
    Item1:=TGTFCOutsetTreeRowItem.Create;
    Item1.Text:='Заказчик'+inttostr(i1);
    Item1.DBRecordID:='ID^'+Item1.Text;
    Item1.Color:=Random(115);
    GTFControl.ActiveDocument.Rows.Add(Item1);
    for i2:=0 to 0 do
    begin
      Item2:=TGTFCOutsetTreeRowItem.Create;
      Item2.Parent:=Item1;
      Item2.Text:='Здание '+inttostr(i2);
      Item2.DBRecordID:='ID^'+Item2.Text;
      GTFControl.ActiveDocument.Rows.Add(Item2);
      for i3:=0 to 0 do
      begin
        Item3:=TGTFCOutsetTreeRowItem.Create;
        Item3.Parent:=Item2;
        Item3.Text:='Задание '+inttostr(i3);
        Item3.DBRecordID:='ID^'+Item3.Text;
        Item3.SetExtendedData(['В работе',Item3.Text,'2036']);
        //Item3.RowKey:=GTFControl.ActiveDocument.GetEntityID;
        Index:=GTFControl.ActiveDocument.Rows.Add(Item3);
        GenerateTask(Index,4,'Исполнитель');
      end;
    end;
  end;

  GTFControl.ActiveDocument.Rows.EndUpdate;
  GTFControl.ScrollToBegin;
  GTFControl.ScrollToBookmark;
  GTFControl.Refresh;

end;

procedure TFgassicMain.Button2Click(Sender: TObject);
begin
  Case cbGraphMultiplicity.ItemIndex of
    0:begin
        if DateUtils.DaysBetween(DateEdit1.Date,DateEdit2.Date)>365 then
        begin
          Application.MessageBox(PChar('Слишком большой охват дней'),PChar(Caption));
          exit;
        end;
    end;
    1:begin
        if DateUtils.DaysBetween(DateEdit1.Date,DateEdit2.Date)>3650 then
        begin
          Application.MessageBox(PChar('Слишком большой охват дней'),PChar(Caption));
          exit;
        end;
    end;
  end;

  Case cbGraphMultiplicity.ItemIndex of
    0:GTFControl.GraphMultiplicity:=gmHour;
    1:GTFControl.GraphMultiplicity:=gmDay;
    2:GTFControl.GraphMultiplicity:=gmWeek;
    3:GTFControl.GraphMultiplicity:=qmMonth;
    4:GTFControl.GraphMultiplicity:=gmQuarter;
  end;
  GTFControl.GraphDateTimeBegin:=DateEdit1.Date;
  GTFControl.GraphDateTimeEnd:=DateEdit2.Date;
  GTFControl.RefreshGraphMultiplicity;
end;

procedure TFgassicMain.GenerateTask(ARowKey: integer; ACount: integer; AText:ShortString);
var
  x:TGraphicTask;
  j1,j2,i,k:integer;
  D:TDateTime;
begin
  d:=GTFControl.GraphDateTimeBegin;
  for i:=1 to ACount do
  begin
  x:=TGraphicTask.Create;
  x.ID:=GTFControl.ActiveDocument.GetEntityID;
  x.GridRow:=TGTFCOutsetTreeRowItem(GTFControl.ActiveDocument.Rows.Items[ARowKey]);
  x.Color:=Random(255);
  j1:=Random(15);
  j2:=Random(30);
  d:=DateUtils.IncDay(d,j1);
  x.TimeBegin:=d;
  d:=DateUtils.IncDay(d,j2);
  x.TimeEnd:=d;

  k:=Random(10);
  case k of
    5: begin
      x.BGTaskStyle:=bgtsCross;
    end;
    8:begin
      x.BGTaskStyle:=bgtsDiagonal;
    end;
  end;

  x.Text:=formatdatetime('yy:mm:dd:hh:nn',now)+' - '+AText;
  x.TextSecondLine:='Договор 122-5252/5550-КК';
  x.Hint:='Подсказка'+#13+'Текст';
  GTFControl.ActiveDocument.ModelSpace.Objects.Add(x);
  x.Created;
  end;
end;

procedure TFgassicMain.GenerateTask2Frame(ARowKey: integer; ACount:integer);
var
  x:TBasicGridEntity;
  j1,j2,r:integer;
  D,d2:TDateTime;
begin
  r:=0;
  d:=GTFControl.GraphDateTimeBegin;
  //for i:=1 to ACount do
  //begin
    x:=TGraphicFrameLine.Create;
    x.ID:=GTFControl.ActiveDocument.GetEntityID;
    x.GridRow:=TGTFCOutsetTreeRowItem(GTFControl.ActiveDocument.Rows.Items[ARowKey]);
    x.Color:=Random(115);
    j1:=24;
    j2:=24;
    d:=DateUtils.IncDay(d,j1);
    x.TimeBegin:=d;
    d2:=DateUtils.IncDay(d,j2);
    x.TimeEnd:=d2;
    {
    k:=Random(10);
    case k of
      5: begin
        x.BGTaskStyle:=bgtsCross;
      end;
      8:begin
        x.BGTaskStyle:=bgtsDiagonal;
      end;
    end;
    }
    x.Text:=x.GridRow.Text+'- N'+inttostr(r); inc(r);
    x.Hint:='Подсказка'+#13+'Текст';
    GTFControl.ActiveDocument.ModelSpace.Objects.Add(x);
    x.Created;
    //2
    x:=TGraphicLandmark.Create;
    x.ID:=GTFControl.ActiveDocument.GetEntityID;
    x.GridRow:=TGTFCOutsetTreeRowItem(GTFControl.ActiveDocument.Rows.Items[ARowKey]);
    x.Color:=Random(115);
    x.TimeBegin:=d;

    {
    k:=Random(10);
    case k of
      5: begin
        x.BGTaskStyle:=bgtsCross;
      end;
      8:begin
        x.BGTaskStyle:=bgtsDiagonal;
      end;
    end;
    }
    x.Text:=x.GridRow.Text+'- N'+inttostr(r); inc(r);
    x.Hint:='Подсказка'+#13+'Текст';
    GTFControl.ActiveDocument.ModelSpace.Objects.Add(x);
    x.Created;
    //3
    x:=TGraphicLandmark.Create;
    x.ID:=GTFControl.ActiveDocument.GetEntityID;
    x.GridRow:=TGTFCOutsetTreeRowItem(GTFControl.ActiveDocument.Rows.Items[ARowKey]);
    x.Color:=Random(115);
    x.TimeBegin:=DateUtils.IncDay(d,-14);

    {
    k:=Random(10);
    case k of
      5: begin
        x.BGTaskStyle:=bgtsCross;
      end;
      8:begin
        x.BGTaskStyle:=bgtsDiagonal;
      end;
    end;
    }
    x.Text:=x.GridRow.Text+'- N'+inttostr(r); inc(r);
    x.Hint:='Подсказка'+#13+'Текст';
    GTFControl.ActiveDocument.ModelSpace.Objects.Add(x);
    x.Created;

end;

procedure TFgassicMain.GenerateTask2(ARowKey: integer);
var
  x     :TGraphicTask;
  xLine :TGraphicConnectionline;

  j1,j2,k,r :integer;
  D,d2      :TDateTime;
begin
  r:=0;
  d:=GTFControl.GraphDateTimeBegin;
  //for i:=1 to ACount do
  //begin
    x:=TGraphicTask.Create;
    x.ID:=GTFControl.ActiveDocument.GetEntityID;
    x.GridRow:=TGTFCOutsetTreeRowItem(GTFControl.ActiveDocument.Rows.Items[ARowKey]);
    x.Color:=Random(115);
    j1:=24;
    j2:=24;
    d:=DateUtils.IncDay(d,j1);
    x.TimeBegin:=d;
    d2:=DateUtils.IncDay(d,j2);
    x.TimeEnd:=d2;

    k:=Random(10);
    case k of
      5: begin
        x.BGTaskStyle:=bgtsCross;
      end;
      8:begin
        x.BGTaskStyle:=bgtsDiagonal;
      end;
    end;

    x.Text:=x.GridRow.Text+'- N'+inttostr(r); inc(r);
    x.Hint:='Подсказка'+#13+'Текст';
    GTFControl.ActiveDocument.ModelSpace.Objects.Add(x);
    x.Created;

    //2
    x:=TGraphicTask.Create;
    x.ID:=GTFControl.ActiveDocument.GetEntityID;
    x.GridRow:=TGTFCOutsetTreeRowItem(GTFControl.ActiveDocument.Rows.Items[ARowKey]);
    x.Color:=Random(115);
    x.TimeBegin:=d;
    x.TimeEnd:=d2;

    x.MarkerBegin:=True;

    k:=Random(10);
    case k of
      5: begin
        x.BGTaskStyle:=bgtsCross;
      end;
      8:begin
        x.BGTaskStyle:=bgtsDiagonal;
      end;
    end;
    x.Text:=x.GridRow.Text+'- N'+inttostr(r); inc(r);
    x.Hint:='Подсказка'+#13+'Текст';
    GTFControl.ActiveDocument.ModelSpace.Objects.Add(x);
    x.Created;

    //3
    x:=TGraphicTask.Create;
    x.ID:=GTFControl.ActiveDocument.GetEntityID;
    x.GridRow:=TGTFCOutsetTreeRowItem(GTFControl.ActiveDocument.Rows.Items[ARowKey]);
    x.Color:=Random(115);
    x.TimeBegin:=DateUtils.IncDay(d,-14);
    x.TimeEnd:=DateUtils.IncDay(d2,-14);

    x.MarkerEnd:=True;

    k:=Random(10);
    case k of
      5: begin
        x.BGTaskStyle:=bgtsCross;
      end;
      8:begin
        x.BGTaskStyle:=bgtsDiagonal;
      end;
    end;

    x.Text:=x.GridRow.Text+'- N'+inttostr(r); inc(r);
    x.Hint:='Подсказка'+#13+'Текст';
    GTFControl.ActiveDocument.ModelSpace.Objects.Add(x);
    x.Created;

    //4
    x:=TGraphicTask.Create;
    x.ID:=GTFControl.ActiveDocument.GetEntityID;
    x.GridRow:=TGTFCOutsetTreeRowItem(GTFControl.ActiveDocument.Rows.Items[ARowKey]);
    x.Color:=Random(115);
    x.TimeBegin:=DateUtils.IncDay(d,14);
    x.TimeEnd:=DateUtils.IncDay(d2,14);

    k:=Random(10);
    case k of
      5: begin
        x.BGTaskStyle:=bgtsCross;
      end;
      8:begin
        x.BGTaskStyle:=bgtsDiagonal;
      end;
    end;

    x.Text:=x.GridRow.Text+'- N'+inttostr(r); inc(r);
    x.Hint:='Подсказка'+#13+'Текст';
    GTFControl.ActiveDocument.ModelSpace.Objects.Add(x);
    x.Created;

    //5
    x:=TGraphicTask.Create;
    x.ID:=GTFControl.ActiveDocument.GetEntityID;
    x.GridRow:=TGTFCOutsetTreeRowItem(GTFControl.ActiveDocument.Rows.Items[ARowKey]);
    x.Color:=Random(115);
    j1:=24;
    j2:=24;
    d:=DateUtils.IncDay(d2,1);
    x.TimeBegin:=d;
    d2:=DateUtils.IncDay(d,j2);
    x.TimeEnd:=d2;

    x.MarkerEnd:=True;
    x.MarkerBegin:=True;
    x.MarkerBeginColor:=gaYellow;
    x.MarkerEndColor:=gaGreen;

    k:=Random(10);
    case k of
      5: begin
        x.BGTaskStyle:=bgtsCross;
      end;
      8:begin
        x.BGTaskStyle:=bgtsDiagonal;
      end;
    end;

    x.Text:=x.GridRow.Text+'- N'+inttostr(r); inc(r);
    x.Hint:='Подсказка'+#13+'Текст';
    GTFControl.ActiveDocument.ModelSpace.Objects.Add(x);
    x.Created;
    //6
    x:=TGraphicTask.Create;
    x.ID:=GTFControl.ActiveDocument.GetEntityID;
    x.GridRow:=TGTFCOutsetTreeRowItem(GTFControl.ActiveDocument.Rows.Items[ARowKey]);
    x.Color:=Random(115);
    j1:=24;
    j2:=24;
    d:=DateUtils.IncDay(d2,1);
    x.TimeBegin:=d;
    d2:=DateUtils.IncDay(d,3);
    x.TimeEnd:=d2;

    k:=Random(10);
    case k of
      5: begin
        x.BGTaskStyle:=bgtsCross;
      end;
      8:begin
        x.BGTaskStyle:=bgtsDiagonal;
      end;
    end;

    x.Text:=x.GridRow.Text+'- N'+inttostr(r); inc(r);
    x.Hint:='Подсказка'+#13+'Текст';
    GTFControl.ActiveDocument.ModelSpace.Objects.Add(x);
    x.Created;
    //7
    x:=TGraphicTask.Create;
    x.ID:=GTFControl.ActiveDocument.GetEntityID;
    x.GridRow:=TGTFCOutsetTreeRowItem(GTFControl.ActiveDocument.Rows.Items[ARowKey]);
    x.Color:=Random(115);
    j1:=24;
    j2:=24;
    d:=DateUtils.IncDay(d2,-1);
    x.TimeBegin:=d;
    d2:=DateUtils.IncDay(d,3);
    x.TimeEnd:=d2;

    k:=Random(10);
    case k of
      5: begin
        x.BGTaskStyle:=bgtsCross;
      end;
      8:begin
        x.BGTaskStyle:=bgtsDiagonal;
      end;
    end;

    x.Text:=x.GridRow.Text+'- N'+inttostr(r); inc(r);
    x.Hint:='Подсказка'+#13+'Текст';
    GTFControl.ActiveDocument.ModelSpace.Objects.Add(x);
    x.Created;
        //8
    x:=TGraphicTask.Create;
    x.ID:=GTFControl.ActiveDocument.GetEntityID;
    x.GridRow:=TGTFCOutsetTreeRowItem(GTFControl.ActiveDocument.Rows.Items[ARowKey]);
    x.Color:=Random(115);
    j1:=24;
    j2:=24;
    d:=DateUtils.IncDay(d2,-1);
    x.TimeBegin:=d;
    d2:=DateUtils.IncDay(d,3);
    x.TimeEnd:=d2;

    k:=Random(10);
    case k of
      5: begin
        x.BGTaskStyle:=bgtsCross;
      end;
      8:begin
        x.BGTaskStyle:=bgtsDiagonal;
      end;
    end;

    x.Text:=x.GridRow.Text+'- N'+inttostr(r); inc(r);
    x.Hint:='Подсказка'+#13+'Текст';
    GTFControl.ActiveDocument.ModelSpace.Objects.Add(x);
    x.Created;
        //9
    x:=TGraphicTask.Create;
    x.ID:=GTFControl.ActiveDocument.GetEntityID;
    x.GridRow:=TGTFCOutsetTreeRowItem(GTFControl.ActiveDocument.Rows.Items[ARowKey]);
    x.Color:=Random(115);
    j1:=24;
    j2:=24;
    d:=DateUtils.IncDay(d2,-1);
    x.TimeBegin:=d;
    d2:=DateUtils.IncDay(d,3);
    x.TimeEnd:=d2;

    k:=Random(10);
    case k of
      5: begin
        x.BGTaskStyle:=bgtsCross;
      end;
      8:begin
        x.BGTaskStyle:=bgtsDiagonal;
      end;
    end;

    x.Text:=x.GridRow.Text+'- N'+inttostr(r); inc(r);
    x.Hint:='Подсказка'+#13+'Текст';
    GTFControl.ActiveDocument.ModelSpace.Objects.Add(x);
    x.Created;
            //10
    x:=TGraphicTask.Create;
    x.ID:=GTFControl.ActiveDocument.GetEntityID;
    x.GridRow:=TGTFCOutsetTreeRowItem(GTFControl.ActiveDocument.Rows.Items[ARowKey]);
    x.Color:=Random(115);
    j1:=24;
    j2:=24;
    d:=DateUtils.IncDay(d2,-1);
    x.TimeBegin:=d;
    d2:=DateUtils.IncDay(d,3);
    x.TimeEnd:=d2;

    k:=Random(10);
    case k of
      5: begin
        x.BGTaskStyle:=bgtsCross;
      end;
      8:begin
        x.BGTaskStyle:=bgtsDiagonal;
      end;
    end;

    x.Text:=x.GridRow.Text+'- N'+inttostr(r); inc(r);
    x.Hint:='Подсказка'+#13+'Текст';
    GTFControl.ActiveDocument.ModelSpace.Objects.Add(x);
    x.Created;
            //11
    x:=TGraphicTask.Create;
    x.ID:=GTFControl.ActiveDocument.GetEntityID;
    x.GridRow:=TGTFCOutsetTreeRowItem(GTFControl.ActiveDocument.Rows.Items[ARowKey]);
    x.Color:=Random(115);
    j1:=24;
    j2:=24;
    d:=DateUtils.IncDay(d2,-1);
    x.TimeBegin:=d;
    d2:=DateUtils.IncDay(d,3);
    x.TimeEnd:=d2;

    k:=Random(10);
    case k of
      5: begin
        x.BGTaskStyle:=bgtsCross;
      end;
      8:begin
        x.BGTaskStyle:=bgtsDiagonal;
      end;
    end;

    x.Text:=x.GridRow.Text+'- N'+inttostr(r); inc(r);
    x.Hint:='Подсказка'+#13+'Текст';
    GTFControl.ActiveDocument.ModelSpace.Objects.Add(x);
    x.Created;
                //12
    x:=TGraphicTask.Create;
    x.ID:=GTFControl.ActiveDocument.GetEntityID;
    x.GridRow:=TGTFCOutsetTreeRowItem(GTFControl.ActiveDocument.Rows.Items[ARowKey]);
    x.Color:=Random(115);
    j1:=24;
    j2:=24;
    d:=DateUtils.IncDay(d2,-1);
    x.TimeBegin:=d;
    d2:=DateUtils.IncDay(d,3);
    x.TimeEnd:=d2;

    k:=Random(10);
    case k of
      5: begin
        x.BGTaskStyle:=bgtsCross;
      end;
      8:begin
        x.BGTaskStyle:=bgtsDiagonal;
      end;
    end;

    x.Text:=x.GridRow.Text+'- N'+inttostr(r); inc(r);
    x.Hint:='Подсказка'+#13+'Текст';
    GTFControl.ActiveDocument.ModelSpace.Objects.Add(x);
    x.Created;
                //13
    x:=TGraphicTask.Create;
    x.ID:=GTFControl.ActiveDocument.GetEntityID;
    x.GridRow:=TGTFCOutsetTreeRowItem(GTFControl.ActiveDocument.Rows.Items[ARowKey]);
    x.Color:=Random(115);
    j1:=24;
    j2:=24;
    d:=DateUtils.IncDay(d2,-1);
    x.TimeBegin:=d;
    d2:=DateUtils.IncDay(d,3);
    x.TimeEnd:=d2;

    k:=Random(10);
    case k of
      5: begin
        x.BGTaskStyle:=bgtsCross;
      end;
      8:begin
        x.BGTaskStyle:=bgtsDiagonal;
      end;
    end;

    x.Text:=x.GridRow.Text+'- N'+inttostr(r); inc(r);
    x.Hint:='Подсказка'+#13+'Текст';
    GTFControl.ActiveDocument.ModelSpace.Objects.Add(x);
    x.Created;
                //14
    x:=TGraphicTask.Create;
    x.ID:=GTFControl.ActiveDocument.GetEntityID;
    x.GridRow:=TGTFCOutsetTreeRowItem(GTFControl.ActiveDocument.Rows.Items[ARowKey]);
    x.Color:=Random(115);
    j1:=24;
    j2:=24;
    d:=DateUtils.IncDay(d2,-1);
    x.TimeBegin:=d;
    d2:=DateUtils.IncDay(d,3);
    x.TimeEnd:=d2;

    k:=Random(10);
    case k of
      5: begin
        x.BGTaskStyle:=bgtsCross;
      end;
      8:begin
        x.BGTaskStyle:=bgtsDiagonal;
      end;
    end;

    x.Text:=x.GridRow.Text+'- N'+inttostr(r); inc(r);
    x.Hint:='Подсказка'+#13+'Текст';
    GTFControl.ActiveDocument.ModelSpace.Objects.Add(x);
    x.Created;
    //15
    x:=TGraphicTask.Create;
    x.ID:=GTFControl.ActiveDocument.GetEntityID;
    x.GridRow:=TGTFCOutsetTreeRowItem(GTFControl.ActiveDocument.Rows.Items[ARowKey]);
    x.Color:=Random(115);
    j1:=24;
    j2:=24;
    d:=DateUtils.IncDay(d2,-7);
    x.TimeBegin:=d;
    d2:=DateUtils.IncDay(d,3);
    x.TimeEnd:=d2;

    k:=Random(10);
    case k of
      5: begin
        x.BGTaskStyle:=bgtsCross;
      end;
      8:begin
        x.BGTaskStyle:=bgtsDiagonal;
      end;
    end;

    x.Text:=x.GridRow.Text+'- N'+inttostr(r); inc(r);
    x.Hint:='Подсказка'+#13+'Текст';
    GTFControl.ActiveDocument.ModelSpace.Objects.Add(x);
    x.Created;
     //16
    x:=TGraphicTask.Create;
    x.ID:=GTFControl.ActiveDocument.GetEntityID;
    x.GridRow:=TGTFCOutsetTreeRowItem(GTFControl.ActiveDocument.Rows.Items[ARowKey]);
    x.Color:=Random(115);
    j1:=24;
    j2:=24;
    d:=DateUtils.IncDay(d2,-14);
    x.TimeBegin:=d;
    d2:=DateUtils.IncDay(d,24);
    x.TimeEnd:=d2;

    k:=Random(10);
    case k of
      5: begin
        x.BGTaskStyle:=bgtsCross;
      end;
      8:begin
        x.BGTaskStyle:=bgtsDiagonal;
      end;
    end;

    x.Text:=x.GridRow.Text+'- N'+inttostr(r); inc(r);
    x.Hint:='Подсказка'+#13+'Текст';
    GTFControl.ActiveDocument.ModelSpace.Objects.Add(x);
    x.Created;

    //17
    x:=TGraphicTask.Create;
    x.ID:=GTFControl.ActiveDocument.GetEntityID;
    x.GridRow:=TGTFCOutsetTreeRowItem(GTFControl.ActiveDocument.Rows.Items[ARowKey]);
    x.Color:=Random(115);
    j1:=24;
    j2:=24;
    d:=DateUtils.IncDay(d2,3);
    x.TimeBegin:=d;
    d2:=DateUtils.IncDay(d,2);
    x.TimeEnd:=d2;

    k:=Random(10);
    case k of
      5: begin
        x.BGTaskStyle:=bgtsCross;
      end;
      8:begin
        x.BGTaskStyle:=bgtsDiagonal;
      end;
    end;

    x.Text:=x.GridRow.Text+'- N'+inttostr(r); inc(r);
    x.Hint:='Подсказка'+#13+'Текст';
    GTFControl.ActiveDocument.ModelSpace.Objects.Add(x);
    x.Created;

    //18
    x:=TGraphicTask.Create;
    x.ID:=GTFControl.ActiveDocument.GetEntityID;
    x.GridRow:=TGTFCOutsetTreeRowItem(GTFControl.ActiveDocument.Rows.Items[ARowKey]);
    x.Color:=Random(115);
    j1:=24;
    j2:=24;
    d:=DateUtils.IncDay(d2,3);
    x.TimeBegin:=d;
    d2:=DateUtils.IncDay(d,2);
    x.TimeEnd:=d2;

    k:=Random(10);
    case k of
      5: begin
        x.BGTaskStyle:=bgtsCross;
      end;
      8:begin
        x.BGTaskStyle:=bgtsDiagonal;
      end;
    end;

    x.Text:=x.GridRow.Text+'- N'+inttostr(r); inc(r);
    x.Hint:='Подсказка'+#13+'Текст';
    GTFControl.ActiveDocument.ModelSpace.Objects.Add(x);
    x.Created;
    //**********************

    //19
    x:=TGraphicTask.Create;
    x.ID:=GTFControl.ActiveDocument.GetEntityID;
    x.GridRow:=TGTFCOutsetTreeRowItem(GTFControl.ActiveDocument.Rows.Items[ARowKey]);
    x.Color:=Random(115);
    j1:=24;
    j2:=24;
    d:=DateUtils.IncDay(d2,3);
    x.TimeBegin:=d;
    d2:=DateUtils.IncDay(d,60);
    x.TimeEnd:=d2;

    k:=Random(10);
    case k of
      5: begin
        x.BGTaskStyle:=bgtsCross;
      end;
      8:begin
        x.BGTaskStyle:=bgtsDiagonal;
      end;
    end;

    x.Text:=x.GridRow.Text+'- N'+inttostr(r); inc(r);
    x.Hint:='Подсказка'+#13+'Текст';
    GTFControl.ActiveDocument.ModelSpace.Objects.Add(x);
    x.Created;

    //19
    x:=TGraphicTask.Create;
    x.ID:=GTFControl.ActiveDocument.GetEntityID;
    x.GridRow:=TGTFCOutsetTreeRowItem(GTFControl.ActiveDocument.Rows.Items[ARowKey]);
    x.Color:=Random(115);
    j1:=24;
    j2:=24;
    d:=DateUtils.IncDay(d,9);
    x.TimeBegin:=d;
    d2:=DateUtils.IncDay(d,2);
    x.TimeEnd:=d2;

    k:=Random(10);
    case k of
      5: begin
        x.BGTaskStyle:=bgtsCross;
      end;
      8:begin
        x.BGTaskStyle:=bgtsDiagonal;
      end;
    end;

    x.Text:=x.GridRow.Text+'- N'+inttostr(r); inc(r);
    x.Hint:='Подсказка'+#13+'Текст';
    GTFControl.ActiveDocument.ModelSpace.Objects.Add(x);
    x.Created;

        //19
    x:=TGraphicTask.Create;
    x.ID:=GTFControl.ActiveDocument.GetEntityID;
    x.GridRow:=TGTFCOutsetTreeRowItem(GTFControl.ActiveDocument.Rows.Items[ARowKey]);
    x.Color:=Random(115);
    j1:=24;
    j2:=24;
    d:=DateUtils.IncDay(d2,3);
    x.TimeBegin:=d;
    d2:=DateUtils.IncDay(d,2);
    x.TimeEnd:=d2;

    k:=Random(10);
    case k of
      5: begin
        x.BGTaskStyle:=bgtsCross;
      end;
      8:begin
        x.BGTaskStyle:=bgtsDiagonal;
      end;
    end;

    x.Text:=x.GridRow.Text+'- N'+inttostr(r); inc(r);
    x.Hint:='Подсказка'+#13+'Текст';
    GTFControl.ActiveDocument.ModelSpace.Objects.Add(x);
    x.Created;

            //19
    x:=TGraphicTask.Create;
    x.ID:=GTFControl.ActiveDocument.GetEntityID;
    x.GridRow:=TGTFCOutsetTreeRowItem(GTFControl.ActiveDocument.Rows.Items[ARowKey]);
    x.Color:=Random(115);
    j1:=24;
    j2:=24;
    d:=DateUtils.IncDay(d2,3);
    x.TimeBegin:=d;
    d2:=DateUtils.IncDay(d,2);
    x.TimeEnd:=d2;

    k:=Random(10);
    case k of
      5: begin
        x.BGTaskStyle:=bgtsCross;
      end;
      8:begin
        x.BGTaskStyle:=bgtsDiagonal;
      end;
    end;

    x.Text:=x.GridRow.Text+'- N'+inttostr(r); inc(r);
    x.Hint:='Подсказка'+#13+'Текст';
    GTFControl.ActiveDocument.ModelSpace.Objects.Add(x);
    x.Created;

            //19
    x:=TGraphicTask.Create;
    x.ID:=GTFControl.ActiveDocument.GetEntityID;
    x.GridRow:=TGTFCOutsetTreeRowItem(GTFControl.ActiveDocument.Rows.Items[ARowKey]);
    x.Color:=Random(115);
    j1:=24;
    j2:=24;
    d:=DateUtils.IncDay(d2,3);
    x.TimeBegin:=d;
    d2:=DateUtils.IncDay(d,2);
    x.TimeEnd:=d2;

    k:=Random(10);
    case k of
      5: begin
        x.BGTaskStyle:=bgtsCross;
      end;
      8:begin
        x.BGTaskStyle:=bgtsDiagonal;
      end;
    end;

    x.Text:=x.GridRow.Text+'- N'+inttostr(r); inc(r);
    x.Hint:='Подсказка'+#13+'Текст';
    GTFControl.ActiveDocument.ModelSpace.Objects.Add(x);
    x.Created;

        //19
    x:=TGraphicTask.Create;
    x.ID:=GTFControl.ActiveDocument.GetEntityID;
    x.GridRow:=TGTFCOutsetTreeRowItem(GTFControl.ActiveDocument.Rows.Items[ARowKey]);
    x.Color:=Random(115);
    j1:=24;
    j2:=24;
    d:=DateUtils.IncDay(d2,-19);
    x.TimeBegin:=d;
    d2:=DateUtils.IncDay(d,50);
    x.TimeEnd:=d2;

    k:=Random(10);
    case k of
      5: begin
        x.BGTaskStyle:=bgtsCross;
      end;
      8:begin
        x.BGTaskStyle:=bgtsDiagonal;
      end;
    end;

    x.Text:=x.GridRow.Text+'- N'+inttostr(r); inc(r);
    x.Hint:='Подсказка'+#13+'Текст';
    GTFControl.ActiveDocument.ModelSpace.Objects.Add(x);
    x.Created;

            //19
    x:=TGraphicTask.Create;
    x.ID:=GTFControl.ActiveDocument.GetEntityID;
    x.GridRow:=TGTFCOutsetTreeRowItem(GTFControl.ActiveDocument.Rows.Items[ARowKey]);
    x.Color:=Random(115);
    j1:=24;
    j2:=24;
    d:=DateUtils.IncDay(d2,-19);
    x.TimeBegin:=d;
    d2:=DateUtils.IncDay(d,7);
    x.TimeEnd:=d2;

    k:=Random(10);
    case k of
      5: begin
        x.BGTaskStyle:=bgtsCross;
      end;
      8:begin
        x.BGTaskStyle:=bgtsDiagonal;
      end;
    end;

    x.Text:=x.GridRow.Text+'- N'+inttostr(r); inc(r);
    x.Hint:='Подсказка'+#13+'Текст';
    GTFControl.ActiveDocument.ModelSpace.Objects.Add(x);
    x.Created;

    //19
    x:=TGraphicTask.Create;
    x.ID:=GTFControl.ActiveDocument.GetEntityID;
    x.GridRow:=TGTFCOutsetTreeRowItem(GTFControl.ActiveDocument.Rows.Items[ARowKey]);
    x.Color:=Random(115);
    j1:=24;
    j2:=24;
    d:=DateUtils.IncDay(d2,5);
    d:=DateUtils.IncHour(d,3);
    x.TimeBegin:=d;
    d2:=DateUtils.IncDay(d,5);
    x.TimeEnd:=d2;

    k:=Random(10);
    case k of
      5: begin
        x.BGTaskStyle:=bgtsCross;
      end;
      8:begin
        x.BGTaskStyle:=bgtsDiagonal;
      end;
    end;

    x.Text:=x.GridRow.Text+'- N'+inttostr(r); inc(r);
    x.Hint:='Подсказка'+#13+'Текст';
    GTFControl.ActiveDocument.ModelSpace.Objects.Add(x);
    x.Created;

    //19
    x:=TGraphicTask.Create;
    x.ID:=GTFControl.ActiveDocument.GetEntityID;
    x.GridRow:=TGTFCOutsetTreeRowItem(GTFControl.ActiveDocument.Rows.Items[ARowKey]);
    x.Color:=Random(115);
    j1:=24;
    j2:=24;
    d:=DateUtils.IncHour(d2,-2);
    x.TimeBegin:=d;
    d2:=DateUtils.IncDay(d,5);
    x.TimeEnd:=d2;

    k:=Random(10);
    case k of
      5: begin
        x.BGTaskStyle:=bgtsCross;
      end;
      8:begin
        x.BGTaskStyle:=bgtsDiagonal;
      end;
    end;

    x.Text:=x.GridRow.Text+'- N'+inttostr(r); inc(r);
    x.Hint:='Подсказка'+#13+'Текст';
    GTFControl.ActiveDocument.ModelSpace.Objects.Add(x);
    x.Created;

    /////////LINE
    xLine:=TGraphicConnectionline.Create;
    xLine.ID:=GTFControl.ActiveDocument.GetEntityID;
    xLine.BeginEntityID:=GTFControl.ActiveDocument.ModelSpace.Objects.Items[6].ID;
    xLine.EndEntityID:=GTFControl.ActiveDocument.ModelSpace.Objects.Items[14].ID;
    GTFControl.ActiveDocument.ModelSpace.Objects.Add(xLine);
    xLine.Created;
  //end;
end;

procedure TFgassicMain.GTFControlMouseMove(Sender: TObject; Shift: TShiftState;
  X, Y: Integer);
var
  Cur:TGTFPoint;
  Item:TEntity;
  gtTmpItem:TGraphicTask;
  glTmpItem:TGraphicLandmark;
  gflTmpItem:TGraphicFrameLine;
  gclTmpItem:TGraphicConnectionline;
begin
  Cur:=GTFControl.GetCursorPoint;
  //etTask,etFrameLine,etLandmark
  Item:=GTFControl.GetObjectUnderRect(Cur,Cur,[etTask,etFrameLine,etLandmark]);
  if not Assigned(Item) then
  begin
     GTFControl.Hint:='';
     GTFControl.ShowHint:=False;
  end
  else
  begin
     if Item is TGraphicTask then
     begin
       gtTmpItem   :=TGraphicTask(Item);
       GTFControl.ShowHint:=False;
       GTFControl.Hint:='Task:'+#13+gtTmpItem.Hint;
       GTFControl.ShowHint:=True;
     end
     else if Item is TGraphicFrameLine then
     begin
       gflTmpItem   :=TGraphicFrameLine(Item);
       GTFControl.ShowHint:=False;
       GTFControl.Hint:='FrameLine:'+#13+gflTmpItem.Hint;
       GTFControl.ShowHint:=True;
     end
     else if Item is TGraphicLandmark then
     begin
       glTmpItem   :=TGraphicLandmark(Item);
       GTFControl.ShowHint:=False;
       GTFControl.Hint:='Landmark:'+#13+glTmpItem.Hint;
       GTFControl.ShowHint:=True;
     end
     else if Item is TGraphicConnectionline then
     begin
       gclTmpItem   :=TGraphicConnectionline(Item);
       GTFControl.ShowHint:=False;
       //GTFControl.Hint:='Connectionline:'+#13+gclTmpItem.Hint;
       GTFControl.ShowHint:=True;
     end;

  end;
end;

procedure TFgassicMain.GTFControlOutsetTreeRowEvent(Sender: TObject;
  ATreeItem: TGTFCOutsetTreeBasicItem; ATarget: TGTFCOutsetTreeClickResult);
begin
   if ATarget=tcrButton then
   begin
     if ATreeItem is TGTFCOutsetTreeRowItem then
     begin
       TGTFCOutsetTreeRowItem(ATreeItem).RowFiltered:=not TGTFCOutsetTreeRowItem(ATreeItem).RowFiltered;
     end;
   end;
end;

procedure TFgassicMain.Button3Click(Sender: TObject);
var
  i1,i2,i3,Index:integer;
  Item1,Item2,Item3:TGTFCOutsetTreeRowItem;
begin
  GTFControl.ActiveDocument.Rows.BeginUpdate;
  GTFControl.ActiveDocument.Rows.Clear;
  GTFControl.ActiveDocument.ModelSpace.Objects.Clear;
  GTFControl.ShowGroupHorizontal:=CheckBox2.Checked;

  GTFControl.ActiveDocument.SetExtendedColumns([]);
  GTFControl.ActiveDocument.SetFirstColumn('');

  for i1:=0 to 5 do
  begin
    Item1:=TGTFCOutsetTreeRowItem.Create;
    Item1.Text:='Договор '+inttostr(i1);
    Item1.DBRecordID:='ID^'+Item1.Text;
    Item1.Color:=Random(115);
    if i1=1 then
       Item1.RowEnabled:=False;

    GTFControl.ActiveDocument.Rows.Add(Item1);
    for i2:=0 to 4 do
    begin
      Item2:=TGTFCOutsetTreeRowItem.Create;
      Item2.Parent:=Item1;
      Item2.Text:='Тех.задание '+inttostr(i2);
      Item2.DBRecordID:='ID^'+Item2.Text;
      Item2.Color:=Random(115);
      GTFControl.ActiveDocument.Rows.Add(Item2);
      for i3:=0 to 4 do
      begin
        Item3:=TGTFCOutsetTreeRowItem.Create;
        Item3.Parent:=Item2;
        Item3.Text:='Задача '+inttostr(i3);
        //Item3.RowKey:=GTFControl.ActiveDocument.GetEntityID;
        Index:=GTFControl.ActiveDocument.Rows.Add(Item3);
        GenerateTask(Index,1,'Исполнитель');
      end;
    end;
  end;

  GTFControl.ActiveDocument.Rows.EndUpdate;
  GTFControl.ScrollToBegin;
  GTFControl.ScrollToBookmark;
  GTFControl.Refresh;
end;

procedure TFgassicMain.Button4Click(Sender: TObject);
var
  i1,i2,i3,Index:integer;

  Item1,Item2,Item3:TGTFCOutsetTreeRowItem;
begin
  Randomize;

  GTFControl.ActiveDocument.Rows.BeginUpdate;
  GTFControl.ActiveDocument.Rows.Clear;
  GTFControl.ActiveDocument.ModelSpace.Objects.Clear;
  GTFControl.ShowGroupHorizontal:=CheckBox2.Checked;

  GTFControl.ActiveDocument.SetFirstColumn('Договор');
  GTFControl.ActiveDocument.SetExtendedColumns(['Статус','Начало','Окончание']);

  for i1:=0 to Random(4) do
  begin
    Item1:=TGTFCOutsetTreeRowItem.Create;
    Item1.Text:='Заказчик'+inttostr(i1);
    Item1.DBRecordID:='ID^'+Item1.Text;
    Item1.Color:=Random(115);
    GTFControl.ActiveDocument.Rows.Add(Item1);
    for i2:=0 to Random(4) do
    begin
      Item2:=TGTFCOutsetTreeRowItem.Create;
      Item2.Parent:=Item1;
      Item2.Text:='Здание '+inttostr(i2);
      Item2.DBRecordID:='ID^'+Item2.Text;
      GTFControl.ActiveDocument.Rows.Add(Item2);
      for i3:=0 to Random(4) do
      begin
        Item3:=TGTFCOutsetTreeRowItem.Create;
        Item3.Parent:=Item2;
        Item3.Text:='Задание '+inttostr(i3);
        Item3.DBRecordID:='ID^'+Item3.Text;
        Item3.SetExtendedData(['В работе',Item3.Text,'2036']);
        //Item3.RowKey:=GTFControl.ActiveDocument.GetEntityID;
        Index:=GTFControl.ActiveDocument.Rows.Add(Item3);
        GenerateTask(Index,4,'Исполнитель');
      end;
    end;
  end;

  GTFControl.ActiveDocument.Rows.EndUpdate;
  GTFControl.ScrollToBegin;
  GTFControl.ScrollToBookmark;
  GTFControl.Refresh;
end;

procedure TFgassicMain.Button5Click(Sender: TObject);
var
  i1,i2:integer;
  Item1,Item2,Item3:TGTFCOutsetTreeRowItem;
begin
  Randomize;

  GTFControl.ActiveDocument.Rows.BeginUpdate;
  GTFControl.ActiveDocument.Rows.Clear;
  GTFControl.ActiveDocument.ModelSpace.Objects.Clear;
  GTFControl.ShowGroupHorizontal:=CheckBox2.Checked;

  GTFControl.ActiveDocument.SetFirstColumn('Люди');
  GTFControl.ActiveDocument.SetExtendedColumns([]);

  for i1:=0 to Random(4) do
  begin
    Item1:=TGTFCOutsetTreeRowItem.Create;
    Item1.Text:='Отдел'+inttostr(i1);
    Item1.DBRecordID:='ID^'+Item1.Text;
    Item1.DBTableName:='TCompanyMasterGroups';
    GTFControl.ActiveDocument.Rows.Add(Item1);
    for i2:=0 to Random(8) do
    begin
      Item2:=TGTFCOutsetTreeRowItem.Create;
      Item2.Parent:=Item1;
      Item2.Text:='Сотрудник '+inttostr(i2);
      Item2.DBRecordID:='ID^'+Item2.Text;
      Item2.DBTableName:='TCompanyPeoples';

      GTFControl.ActiveDocument.Rows.Add(Item2);
      //for i3:=0 to Random(4) do
      //begin
        Item3:=TGTFCOutsetTreeRowItem.Create;
        Item3.Parent:=Item2;
        Item3.Text:='Отпуск';
        Item3.DBRecordID:='ID^'+Item3.Text+inttostr(i1)+inttostr(i2);
        Item3.DBTableName:='TCompanyRisk';
        GTFControl.ActiveDocument.Rows.Add(Item3);

        Item3:=TGTFCOutsetTreeRowItem.Create;
        Item3.Parent:=Item2;
        Item3.Text:='День рождения';
        Item3.DBRecordID:='ID^'+Item3.Text+inttostr(i1)+inttostr(i2);
        Item3.DBTableName:='TCompanyRisk';
        GTFControl.ActiveDocument.Rows.Add(Item3);

        Item3:=TGTFCOutsetTreeRowItem.Create;
        Item3.Parent:=Item2;
        Item3.Text:='Отгул';
        Item3.DBRecordID:='ID^'+Item3.Text+inttostr(i1)+inttostr(i2);
        Item3.DBTableName:='TCompanyRisk';
        Item3.DBTableName:='TCompanyRisk';
        GTFControl.ActiveDocument.Rows.Add(Item3);

        Item3:=TGTFCOutsetTreeRowItem.Create;
        Item3.Parent:=Item2;
        Item3.Text:='В офисе';
        Item3.DBRecordID:='ID^'+Item3.Text+inttostr(i1)+inttostr(i2);
        Item3.DBTableName:='TCompanyRisk';
        GTFControl.ActiveDocument.Rows.Add(Item3);

        Item3:=TGTFCOutsetTreeRowItem.Create;
        Item3.Parent:=Item2;
        Item3.Text:='Удаленная работа';
        Item3.DBRecordID:='ID^'+Item3.Text+inttostr(i1)+inttostr(i2);
        Item3.DBTableName:='TCompanyRisk';
        Item3.RowEnabled:=False;
        GTFControl.ActiveDocument.Rows.Add(Item3);

        Item3:=TGTFCOutsetTreeRowItem.Create;
        Item3.Parent:=Item2;
        Item3.Text:='Командировка';
        Item3.DBRecordID:='ID^'+Item3.Text+inttostr(i1)+inttostr(i2);
        Item3.DBTableName:='TCompanyRisk';
        GTFControl.ActiveDocument.Rows.Add(Item3);
      //end;
    end;
  end;
  GenerateTask2(4);
  GenerateTask2Frame(4,4);
  GenerateTask2Frame(6,4);

  GTFControl.ActiveDocument.Rows.EndUpdate;
  GTFControl.ScrollToBegin;
  GTFControl.ScrollToBookmark;
  GTFControl.Refresh;
end;

procedure TFgassicMain.Button6Click(Sender: TObject);
var
  xLine:TGraphicConnectionline;
begin
  xLine:=TGraphicConnectionline.Create;
  xLine.ID:=GTFControl.ActiveDocument.GetEntityID;
  xLine.BeginEntityID:=GTFControl.ActiveDocument.ModelSpace.Objects.Items[10].ID;
  xLine.EndEntityID:=GTFControl.ActiveDocument.ModelSpace.Objects.Items[30].ID;
  GTFControl.ActiveDocument.ModelSpace.Objects.Add(xLine);
  xLine.Created;
end;

procedure TFgassicMain.Button7Click(Sender: TObject);
begin
  if SavePictureDialog1.Execute then
  begin
     GTFControl.SaveToFileAsJPEG(SavePictureDialog1.FileName);
  end;
end;

procedure TFgassicMain.Button8Click(Sender: TObject);
begin
  GTFControl.ActiveDocument.EditMode:=eemReadOnly;
end;

procedure TFgassicMain.Button9Click(Sender: TObject);
begin
 GTFControl.ActiveDocument.EditMode:=eemSelectOnly;
end;

procedure TFgassicMain.cbAABASEPOINTChange(Sender: TObject);
begin
  if (Sender as TCheckBox).Checked then
  GTFControl.SelectStyle:=GTFControl.SelectStyle+[aasoBASEPOINT]
  else
  GTFControl.SelectStyle:=GTFControl.SelectStyle-[aasoBASEPOINT];
end;

procedure TFgassicMain.cbAABORDERChange(Sender: TObject);
begin
  if (Sender as TCheckBox).Checked then
  GTFControl.SelectStyle:=GTFControl.SelectStyle+[aasoBORDER]
  else
  GTFControl.SelectStyle:=GTFControl.SelectStyle-[aasoBORDER];
end;

procedure TFgassicMain.cbAAINSIDEChange(Sender: TObject);
begin
  if (Sender as TCheckBox).Checked then
  GTFControl.SelectStyle:=GTFControl.SelectStyle+[aasoINSIDE]
  else
  GTFControl.SelectStyle:=GTFControl.SelectStyle-[aasoINSIDE];
end;

procedure TFgassicMain.cbAAOUTSIDEChange(Sender: TObject);
begin

end;

procedure TFgassicMain.cbAAVERTEXChange(Sender: TObject);
begin
  if (Sender as TCheckBox).Checked then
  GTFControl.SelectStyle:=GTFControl.SelectStyle+[aasoVERTEX]
  else
  GTFControl.SelectStyle:=GTFControl.SelectStyle-[aasoVERTEX];
end;

procedure TFgassicMain.cbColorSelectChange(Sender: TObject);
begin

end;

procedure TFgassicMain.cbGraphMultiplicityChange(Sender: TObject);
begin

end;

procedure TFgassicMain.cbLineWeightChange(Sender: TObject);
begin

end;

procedure TFgassicMain.cbDevModeChange(Sender: TObject);
begin
  if (Sender as TCheckBox).Checked then
      GTFControl.DevelopMode:=true
  else
      GTFControl.DevelopMode:=false;
end;

procedure TFgassicMain.cbAxesChange(Sender: TObject);
begin

end;

procedure TFgassicMain.cbReadOnlyChange(Sender: TObject);
begin

end;

procedure TFgassicMain.cbWayLineChange(Sender: TObject);
begin
  GTFControl.ShowWayLine      :=cbWayLine.Checked;
  GTFControl.ShowTodayWayLine :=cbWayLine.Checked;
end;

procedure TFgassicMain.CheckBox1Change(Sender: TObject);
begin
  GTFControl.AntiLayering :=CheckBox1.Checked;
end;

procedure TFgassicMain.CheckBox2Change(Sender: TObject);
begin
  GTFControl.ShowGroupHorizontal :=CheckBox2.Checked;
end;

procedure TFgassicMain.CheckBox3Change(Sender: TObject);
begin
  GTFControl.GraphDrawDatePrecision :=CheckBox3.Checked;
end;

procedure TFgassicMain.ComboBox1Change(Sender: TObject);
begin

end;

procedure TFgassicMain.edtscaleKeyPress(Sender: TObject; var Key: char);
begin
  if (Key in ['.']) then Key:=char(',');
end;

procedure TFgassicMain.FormDestroy(Sender: TObject);
begin
  GTFControl.free;
end;

procedure TFgassicMain.FormShow(Sender: TObject);
begin
  Case GTFControl.GraphMultiplicity of
    gmHour:cbGraphMultiplicity.ItemIndex:=0;
    gmDay:cbGraphMultiplicity.ItemIndex:=1;
    gmWeek:cbGraphMultiplicity.ItemIndex:=2;
    qmMonth:cbGraphMultiplicity.ItemIndex:=3;
    gmQuarter:cbGraphMultiplicity.ItemIndex:=4;
  end;
  self.DateEdit1.Date:=GTFControl.GraphDateTimeBegin;
  self.DateEdit2.Date:=GTFControl.GraphDateTimeEnd;
end;

procedure TFgassicMain.ListView1ColumnClick(Sender: TObject; Column: TListColumn
  );
begin

end;

procedure TFgassicMain.Memo2Change(Sender: TObject);
begin

end;

end.

