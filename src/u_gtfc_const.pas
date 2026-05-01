unit u_gtfc_const;

//************************************************************
//
//    Модуль компонента Graphic Task Flow Control
//    Copyright (c) 2013  Pichugin M.
//
//    Разработчик: Pichugin M. (e-mail: pichugin-swd@mail.ru)
//
//************************************************************

interface

uses
   Classes;

// Constants for enum Color
type
  TgaColor = LongWord;  //Max44
const
  gaMaxColors       = 47;
  gaNonRGBMaxColors = 30;

  gaDefault   = 0;
  gaRed       = 24;
  gaYellow    = 42;
  gaGreen     = 38;
  gaBlue      = 34;
  gaGray      = 10;
  gaGray2     = 11;
  gaWhite     = 14;
  gaBlack     = 9;

  gaInactive  = 10;

  gaHighLight   = 3;
  gaHighLightText = 4;
  gaDefaultText = 0;
  gaDefaultBG   = 1;
  gaDefaultForm = 2;

  gaTaskRangColor1 =15;    //срочно+важно
  gaTaskRangColor2 =16;    //важно
  gaTaskRangColor3 =17;    //срочно
  gaTaskRangColor4 =18;    //не важно и не срочно

  gaDefaultTaskColor = 23;
  gaTaskColorFinished  =19;
  gaTaskColorComplited =20;
  gaTaskColorInWork    =21;
  gaTaskColorDraft     =12;
  gaTaskColorReject    =22;
  gaTaskColorPostponed =22;
  gaTaskColorSuspended =22;
  gaTaskColorOther     =23;

// Constants for enum AttachmentPoint
type
  TgaAttachmentPoint = LongWord;
const
  gaAttachmentPointTopLeft = 1;
  gaAttachmentPointTopCenter = 2;
  gaAttachmentPointTopRight = 3;
  gaAttachmentPointMiddleLeft = 4;
  gaAttachmentPointMiddleCenter = 5;
  gaAttachmentPointMiddleRight = 6;
  gaAttachmentPointBottomLeft = 7;
  gaAttachmentPointBottomCenter = 8;
  gaAttachmentPointBottomRight = 9;

// Constants for enum LineWeight
type
  TgaLineWeight = LongWord;
const
  gaLnWtDefault = 0;
  gaLnWtDouble = 1;
  gaLnWtTriple = 3;

const
   ENTITYLIST_ID='';

implementation

end.
