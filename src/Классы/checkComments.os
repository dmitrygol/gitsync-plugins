#Использовать logos

Перем ВерсияПлагина;
Перем Лог;
Перем КомандыПлагина;
Перем ВызватьОшибку;

#Область Интерфейс_плагина

// Возвращает версию плагина
//
//  Возвращаемое значение:
//   Строка - текущая версия плагина
//
Функция Версия() Экспорт
	Возврат "1.0.4";
КонецФункции

// Возвращает приоритет выполнения плагина
//
//  Возвращаемое значение:
//   Число - приоритет выполнения плагина
//
Функция Приоритет() Экспорт
	Возврат 0;
КонецФункции

// Возвращает описание плагина
//
//  Возвращаемое значение:
//   Строка - описание функциональности плагина
//
Функция Описание() Экспорт
	Возврат "Плагин добавляет функциональность проверки комментариев в хранилище";
КонецФункции

// Возвращает подробную справку к плагину 
//
//  Возвращаемое значение:
//   Строка - подробная справка для плагина
//
Функция Справка() Экспорт
	Возврат "Справка плагина";
КонецФункции

// Возвращает имя плагина
//
//  Возвращаемое значение:
//   Строка - имя плагина при подключении
//
Функция Имя() Экспорт
	Возврат "check-comments";
КонецФункции 

// Возвращает имя лога плагина
//
//  Возвращаемое значение:
//   Строка - имя лога плагина
//
Функция ИмяЛога() Экспорт
	Возврат "oscript.lib.gitsync.plugins.check-comments";
КонецФункции

#КонецОбласти

#Область Подписки_на_события

Процедура ПриРегистрацииКомандыПриложения(ИмяКоманды, КлассРеализации) Экспорт

	Лог.Отладка("Ищю команду <%1> в списке поддерживаемых", ИмяКоманды);
	Если КомандыПлагина.Найти(ИмяКоманды) = Неопределено Тогда
		Возврат;
	КонецЕсли;

	Лог.Отладка("Устанавливаю дополнительные параметры для команды %1", ИмяКоманды);

	КлассРеализации.Опция("C error-comment", Ложь, "[*check-comments] флаг вызова ошибки при отсутствии текста комментария")
					.Флаговый();

КонецПроцедуры

Процедура ПриПолученииПараметров(ПараметрыКоманды) Экспорт

	ВызватьОшибку = ПараметрыКоманды.Параметр("error-comment", Ложь);
	
	ВызватьОшибку = Булево(ВызватьОшибку);

	Лог.Отладка("Получаю параметр <error-comment> значение <%1>", ВызватьОшибку);

КонецПроцедуры

Процедура ПередОбработкойВерсииХранилища(СтрокаВерсии, СледующаяВерсия) Экспорт

	Если ПустаяСтрока(СтрокаВерсии.Комментарий) Тогда
		СтрокаОшибки = СтрШаблон("Нашли следующую версию <%1> от автора <%2>, а комментарий не задан!", 
								СледующаяВерсия,
								 СтрокаВерсии.Автор);
		Лог.КритичнаяОшибка(СтрокаОшибки);

		Если ВызватьОшибку Тогда

			ВызватьИсключение СтрокаОшибки;

		КонецЕсли;

	КонецЕсли;

КонецПроцедуры

#КонецОбласти

Процедура Инициализация()

	ВерсияПлагина = "1.0.0";
	Лог = Логирование.ПолучитьЛог(ИмяЛога());
	КомандыПлагина = Новый Массив;
	КомандыПлагина.Добавить("sync");

КонецПроцедуры

Инициализация();
