# PLSQL Developer plugin replace param

PLSQL Developer Plugin. Replacing :param with &param and back (excludes comment text and single quotes)

![T](https://github.com/derevyov/plsqlDeveloperPluginUtil/blob/main/img/image2.png)


### Test sql

```sql
/*Replacing parameters :param with &param and vice versa
        except comments and ':' in text*/
SELECT t.*, :PARAM
  FROM TABLE_NAME t
 WHERE t.tir = :PARAM
   AND t.time = TO_CHAR('02:33', 'HH:MI')
 and decode('str', :param, 'str2')
/*in comment :param*/
/*in the comment :param and
more text on another line*/
-- :param
```
