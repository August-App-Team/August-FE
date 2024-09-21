/* 
## 기타 (Institutions, Departments)

`semesters/`

`GET`: 지원하는 학기 목록을 반환합니다. 

응답 형식

```json
[
  202308
]
```

쿼리 파라미터

| 이름 | 설명 | 지원 값 | 필수 |
| --- | --- | --- | --- |
| institution_id | 기관 ID를 지정합니다. 
default: 1 | integer | O |

*/
import 'package:shared_preferences/shared_preferences.dart';

Future<int> getSchoolId() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  return prefs.getInt('schoolId') ?? 1;
}
