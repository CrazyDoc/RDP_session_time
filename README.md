# RDP_session_time

example: 

Path_to_Dir\RDP_time_work.ps1 -StartTime "April 27, 2020" -Period 2

Path_to_Dir\RDP_time_work.ps1 -StartTime "April 27, 2020"

Powershell script to know the time of the sessions.

Prepared only for Russian-language servers(change the selection for Get-EventLog in the appropriate language, if necessary).

Output contains only closed sessions.

Change the selection processing logic if your server has records of more than 100 users - it is not optimized.




Скрипт powershell для учета времени работы сессий. 

Подготовленно только для русифицированных серверов(измените выборку для Get-EventLog соответствующим языком, если это необходимо). 

Вывод содержит только закрытые сессии.

Измените логику обработки выборки если ваш сервер имеет записи о более чем 100 пльзователях - она не оптимизированна.
