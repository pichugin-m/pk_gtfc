//
//    Graphic Task Flow Control
//    Copyright (c) 2013-2026  Pichugin M.
//    License: LGPL
//    Dev. Pichugin M. (e-mail: pichugin-swd@mail.ru)
//
// ver. 0.57
// - fix error with TListColumns class
// - fix error with draw columns if visible=off
// - change text paint in task rect
//
// ver. 0.56
// - fix cursor draw in procedure TGTFControl.SLCursorPaint();
// - fix draw TGraphicConnectionline on filtered row in procedure TGTFControl.RefreshFilterEntity;
// - add property DBTableName to TGTFCOutsetTreeBasicItem;
// - add property TGTFControl.ShowTodayWayLine. Separete functions of Today highlight line and row\col highlight;
//
// ver. 0.55
// - Добавлены +/- в дерево строк
// - Добавлены новые OnEvents
// - Доработка вех, диапазона
// - Переработка алгоритмов отрисовки
// - Добавлено два PopupMenu по зонам
//
// ver. 0.53
// - Добавлен список отфильтрованных объектов
// - Переработана функция защиты от наложения объектов друг на друга
// - Добавлена опция точного/неточного сравнения даты и отрисовки задач на мастабе дней, месяцев
//
// ver. 0.52
//
// ver. 0.51
//
// ver. 0.48
// - Исправлен баг мерцания отрисовки, при работе через RDP
//
// ver. 0.47
// - Добавлено кеширование состояния столбца при его отрисовке в первый раз.
//
//
// ver. 0.46
// - Добавлены вехи TGraphicLandmark и границы TGraphicFrameLine 
//
// ver. 0.45
// - Устранена утечка памяти
// - Добавлены дополнительные столбцы для объектов строк
// - Добавлена функция позиционирования по закладке, указанной дате
// 
//
// ver. 0.32
// - Переработана работа с цветами
// - Добавлено создание строки для Row являющимся владельцем группы эл-тов
// 
