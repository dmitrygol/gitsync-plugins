#Использовать logos

Перем ВерсияПлагина;
Перем Лог;
Перем Обработчик;
Перем КомандыПлагина;
Перем ПропускатьСуществующиеТеги;
Перем ПоследняяВерсияКонфигурации;
Перем ТекущаяВерсияКонфигурации;

Перем НумероватьВерсии;
Перем ТекущаяВерсияХранилища1С;

#Область Интерфейс_плагина

// Возвращает версию плагина
//
//  Возвращаемое значение:
//   Строка - текущая версия плагина
//
Функция Версия() Экспорт
	Возврат "1.0.6";
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
	Возврат "Плагин добавляет функциональность автоматической расстановки меток в git";
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
	Возврат "smart-tags";
КонецФункции 

// Возвращает имя лога плагина
//
//  Возвращаемое значение:
//   Строка - имя лога плагина
//
Функция ИмяЛога() Экспорт
	Возврат "oscript.lib.gitsync.plugins.smart-tags";
КонецФункции

#Область Подписки_на_события

Процедура ПриАктивизации(СтандартныйОбработчик) Экспорт

	Обработчик = СтандартныйОбработчик;
	ПоследняяВерсияКонфигурации = "";
	ТекущаяВерсияКонфигурации = "";

КонецПроцедуры

Процедура ПриРегистрацииКомандыПриложения(ИмяКоманды, КлассРеализации) Экспорт

	Лог.Отладка("Ищу команду <%1> в списке поддерживаемых", ИмяКоманды);
	Если КомандыПлагина.Найти(ИмяКоманды) = Неопределено Тогда
		Возврат;
	КонецЕсли;

	Лог.Отладка("Устанавливаю дополнительные параметры для команды %1", ИмяКоманды);

	КлассРеализации.Опция("S skip-exists-tags", Ложь, "[*smart-tags] флаг пропуска ошибок создания существующих тегов")
					.Флаговый()
					.ВОкружении("GITSYNC_SKIP_EXISTS_TAGS");

	КлассРеализации.Опция("N numerator", Ложь, "[*smart-tags] флаг добавляет номер хранилища 1С как тег вида v.X")
					.Флаговый();

КонецПроцедуры

Процедура ПриПолученииПараметров(ПараметрыКоманды) Экспорт

	ПропускатьСуществующиеТеги = ПараметрыКоманды.Параметр("skip-exists-tags", Ложь);

	НумероватьВерсии = ПараметрыКоманды.Параметр("numerator", Ложь);

КонецПроцедуры

Процедура ПередНачаломВыполнения(ПутьКХранилищу, КаталогРабочейКопии) Экспорт

	ПоследняяВерсияКонфигурации = ПрочитатьВерсиюИзИсходников(КаталогРабочейКопии);

КонецПроцедуры

Процедура ПередОбработкойВерсииХранилища(СтрокаВерсии, СледующаяВерсия) Экспорт

	Если ЗначениеЗаполнено(СтрокаВерсии.Тэг) Тогда
		ТекущаяВерсияКонфигурации = СтрокаВерсии.Тэг;
	Иначе
		ТекущаяВерсияКонфигурации = "";
	КонецЕсли;

	ТекущаяВерсияХранилища1С = СледующаяВерсия;

КонецПроцедуры

Процедура ПослеКоммита(ГитРепозиторий, КаталогРабочейКопии) Экспорт

	Если ПустаяСтрока(ТекущаяВерсияКонфигурации) Тогда
		ТекущаяВерсияКонфигурации = ПрочитатьВерсиюИзИсходников(КаталогРабочейКопии);
	КонецЕсли;

	Если ПустаяСтрока(ТекущаяВерсияКонфигурации) Тогда
		Возврат;
	КонецЕсли;

	Если ПоследняяВерсияКонфигурации <> ТекущаяВерсияКонфигурации Тогда
		Лог.Информация("Определена новая версия конфигурации: %1. Будет установлен новый тег", ТекущаяВерсияКонфигурации);

		ПараметрыКоманды = Новый Массив;
		ПараметрыКоманды.Добавить("tag");
		ПараметрыКоманды.Добавить(Строка(ТекущаяВерсияКонфигурации));

		Попытка
			ГитРепозиторий.ВыполнитьКоманду(ПараметрыКоманды);
		Исключение
			ТекстОшибки = ОписаниеОшибки();
			Если ПропускатьСуществующиеТеги
				И ЭтоОшибкаТегУжеСуществует(ТекстОшибки, ТекущаяВерсияКонфигурации) Тогда
				Лог.Ошибка(ТекстОшибки);
			Иначе
				ВызватьИсключение ТекстОшибки;
			КонецЕсли;
		КонецПопытки;

		ПоследняяВерсияКонфигурации = ТекущаяВерсияКонфигурации;
		ТекущаяВерсияКонфигурации = "";

	КонецЕсли;

	Если НумероватьВерсии Тогда
		Если ЗначениеЗаполнено(ТекущаяВерсияХранилища1С) Тогда
			Лог.Информация("Устанавливаем тэг-нумератор версии хранилища 1С: 'v.%1'", ТекущаяВерсияХранилища1С);

			ПараметрыКоманды = Новый Массив;
			ПараметрыКоманды.Добавить("tag");
			ПараметрыКоманды.Добавить("v." + Строка(ТекущаяВерсияХранилища1С));
	
			Попытка
				ГитРепозиторий.ВыполнитьКоманду(ПараметрыКоманды);
			Исключение
				ТекстОшибки = ОписаниеОшибки();
				Если ПропускатьСуществующиеТеги
					И ЭтоОшибкаТегУжеСуществует(ТекстОшибки, ТекущаяВерсияХранилища1С) Тогда
					Лог.Ошибка(ТекстОшибки);
				Иначе
					ВызватьИсключение ТекстОшибки;
				КонецЕсли;
			КонецПопытки;
	
			ТекущаяВерсияХранилища1С = "";
		
		КонецЕсли;

	КонецЕсли;

КонецПроцедуры

#КонецОбласти

#Область Вспомогательные_процедуры_и_функции

Функция ПрочитатьВерсиюИзИсходников(КаталогИсходныхФайлов)

	ФайлКонфигурации = Новый Файл(ОбъединитьПути(КаталогИсходныхФайлов, "Configuration.xml"));
	Если Не ФайлКонфигурации.Существует() Тогда
		Возврат ПоследняяВерсияКонфигурации;
	КонецЕсли;

	ПараметрыКонфигурации = ПолучитьПараметрыКонфигурацииИзИсходников(КаталогИсходныхФайлов);

	Возврат ПараметрыКонфигурации.Version;

КонецФункции // ПрочитатьВерсиюИзИсходников()

Функция ЭтоОшибкаТегУжеСуществует(ТекстОшибки, ТекущаяВерсияКонфигурации)

	Возврат СтрНайти(
		ТекстОшибки,
		СтрШаблон("fatal: tag '%1' already exists", ТекущаяВерсияКонфигурации)) > 0;

КонецФункции

// Функция читает параметры конфигурации из каталога исходников
//
Функция ПолучитьПараметрыКонфигурацииИзИсходников(КаталогИсходныхФайлов)

	ФайлКонфигурации = Новый Файл(ОбъединитьПути(КаталогИсходныхФайлов, "Configuration.xml"));
	Если Не ФайлКонфигурации.Существует() Тогда
 		ВызватьИсключение СтрШаблон("Файл <%1> не найден у указанном каталоге.", ФайлКонфигурации.ПолноеИмя);
	КонецЕсли;

	ПараметрыКонфигурации = Новый Структура;

	Чтение = Новый ЧтениеXML;
	Чтение.ОткрытьФайл(ФайлКонфигурации.ПолноеИмя);

	Пока Чтение.Прочитать() Цикл
		Если Чтение.ТипУзла = ТипУзлаXML.НачалоЭлемента И Чтение.Имя = "Properties" Тогда
			Прервать;
		КонецЕсли;
	КонецЦикла;

	Чтение.Прочитать();

	МассивДоступныхСвойств = Новый Массив;
	МассивДоступныхСвойств.Добавить("Vendor");
	МассивДоступныхСвойств.Добавить("Version");
	МассивДоступныхСвойств.Добавить("UpdateCatalogAddress");
	МассивДоступныхСвойств.Добавить("Comment");
	МассивДоступныхСвойств.Добавить("Name");

	Пока Не (Чтение.ТипУзла = ТипУзлаXML.КонецЭлемента И Чтение.ЛокальноеИмя = "Properties") Цикл

		КлючИЗначение = ПрочитатьОпцию(Чтение);

		Если МассивДоступныхСвойств.Найти(КлючИЗначение.Ключ) = Неопределено  Тогда
			Продолжить;
		КонецЕсли;

		ПараметрыКонфигурации.Вставить(КлючИЗначение.Ключ, КлючИЗначение.Значение);

	КонецЦикла;
	Чтение.Закрыть();

	Возврат ПараметрыКонфигурации;

КонецФункции

// Функция читает опцию из ЧтениеXML
//
Функция ПрочитатьОпцию(Знач Чтение)

	Перем Ключ;
	Перем Значение;

	Ключ = Чтение.ЛокальноеИмя;

	Чтение.Прочитать();
	Если Чтение.ТипУзла = ТипУзлаXML.Текст Тогда
		Значение = Чтение.Значение;
		Чтение.Прочитать();
	ИначеЕсли Чтение.ТипУзла = ТипУзлаXML.КонецЭлемента Тогда
		Значение = "";
	КонецЕсли;

	Лог.Отладка("Читаю опцию: %1
	| Значение: %2", Ключ, Значение);

	Чтение.Прочитать();

	Возврат Новый Структура("Ключ,Значение", Ключ, Значение);

КонецФункции

Процедура Инициализация()

	Лог = Логирование.ПолучитьЛог(ИмяЛога());
	КомандыПлагина = Новый Массив;
	КомандыПлагина.Добавить("sync");
	КомандыПлагина.Добавить("export");
	ПоследняяВерсияКонфигурации = "";
	ТекущаяВерсияКонфигурации = "";
	ТекущаяВерсияХранилища1С = "";

КонецПроцедуры

#КонецОбласти

Инициализация();
