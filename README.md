### **📌 Flutter Riverpod + Clean Architecture 확장형 구조 정리**
---

## **📖 개요**
이 문서는 **Riverpod + Clean Architecture** 패턴을 활용한 확장형 구조를 설명합니다.  
✅ **MVVM보다 확장성 높은 구조**  
✅ **UseCase + Repository Pattern 적용**  
✅ **Dependency Injection (DI) 적용 (`get_it`)**  
✅ **Local DB(Hive) + Remote API(Dio) 지원**  

---

## **📁 프로젝트 디렉토리 구조**
```
lib/
 ├── core/                 # 공통 유틸리티 및 설정
 │   ├── error/            # 에러 처리 (예외 클래스)
 │   ├── network/          # 네트워크 설정 (Dio, HTTP 등)
 │   ├── utils/            # 유틸리티 함수 (예: 날짜 포맷팅)
 ├── data/                 # Data Layer (데이터 저장소)
 │   ├── models/           # DTO (Data Transfer Object)
 │   ├── repositories/     # Repository 구현체
 │   ├── sources/          # 데이터 소스 (API, Local DB)
 │   │   ├── local/        # Local DB (Hive, SQLite)
 │   │   ├── remote/       # Remote API (Dio, Supabase 등)
 ├── domain/               # Domain Layer (비즈니스 로직)
 │   ├── entities/         # 도메인 엔티티 (UI 독립적)
 │   ├── repositories/     # Repository 인터페이스
 │   ├── usecases/         # UseCase (비즈니스 로직)
 ├── services/             # Service Layer 추가
 │   ├── auth_service.dart # 인증 관련 서비스 (예: Supabase, Firebase)
 │   ├── notification_service.dart # 푸시 알림 서비스
 │   ├── analytics_service.dart # 분석 서비스 (예: Firebase Analytics)
 ├── presentation/         # Presentation Layer (UI 및 상태 관리)
 │   ├── providers/        # Riverpod Provider 관리
 │   ├── screens/          # Flutter UI 화면
 │   ├── widgets/          # 재사용 가능한 UI 컴포넌트
 ├── main.dart             # 앱 진입점 (Riverpod ProviderScope 설정)
 ├── injection.dart        # Dependency Injection (get_it 설정)
```

---

## **🛠️ 핵심 개념**
### **1️⃣ Entity (Domain Layer)**
```dart
class Todo {
  final String id;
  final String title;
  final bool isCompleted;

  Todo({required this.id, required this.title, this.isCompleted = false});
}
```

### **2️⃣ Repository Interface (Domain Layer)**
```dart
abstract class TodoRepository {
  Future<List<Todo>> fetchTodos();
  Future<void> addTodo(Todo todo);
  Future<void> updateTodo(Todo todo);
  Future<void> deleteTodo(String id);
}
```

### **3️⃣ UseCase (Domain Layer)**
```dart
class GetTodosUseCase {
  final TodoRepository repository;

  GetTodosUseCase(this.repository);

  Future<List<Todo>> call() async {
    return await repository.fetchTodos();
  }
}
```

### **4️⃣ Repository Implementation (Data Layer)**
```dart
class TodoRepositoryImpl implements TodoRepository {
  final TodoApi api;
  final TodoDB db;

  TodoRepositoryImpl(this.api, this.db);

  @override
  Future<List<Todo>> fetchTodos() async {
    try {
      final remoteTodos = await api.getTodos();
      db.saveTodos(remoteTodos);
      return remoteTodos;
    } catch (_) {
      return db.getTodos();
    }
  }
}
```

### **5️⃣ API Service (Remote Data Source)**
```dart
class TodoApi {
  final Dio dio = Dio(BaseOptions(baseUrl: "https://example.com"));

  Future<List<Todo>> getTodos() async {
    final response = await dio.get('/todos');
    return (response.data as List).map((json) => Todo(
      id: json['id'],
      title: json['title'],
      isCompleted: json['completed'],
    )).toList();
  }
}
```

### **6️⃣ Local Database (Local Data Source)**
```dart
class TodoDB {
  final Box _box = Hive.box('todos');

  Future<void> saveTodos(List<Todo> todos) async {
    await _box.put('todos', todos);
  }
}
```

### **7️⃣ Riverpod Provider (ViewModel)**
```dart
class TodoState {
  final List<Todo> todos;
  final bool isLoading;

  TodoState({this.todos = const [], this.isLoading = false});

  TodoState copyWith({List<Todo>? todos, bool? isLoading}) {
    return TodoState(
      todos: todos ?? this.todos,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class TodoNotifier extends StateNotifier<TodoState> {
  final GetTodosUseCase getTodosUseCase;

  TodoNotifier(this.getTodosUseCase) : super(TodoState());

  Future<void> loadTodos() async {
    state = state.copyWith(isLoading: true);
    final todos = await getTodosUseCase();
    state = state.copyWith(todos: todos, isLoading: false);
  }
}

// Riverpod Provider (StateNotifierProvider)
final todoProvider = StateNotifierProvider<TodoNotifier, TodoState>((ref) {
  final getTodosUseCase = locator<GetTodosUseCase>(); // DI로 주입받음
  return TodoNotifier(getTodosUseCase);
});
```

### **8️⃣ Dependency Injection (get_it)**
```dart
final GetIt locator = GetIt.instance;

void setupLocator() {
  locator.registerLazySingleton(() => TodoApi());
  locator.registerLazySingleton(() => TodoDB());
  locator.registerLazySingleton(() => TodoRepositoryImpl(locator(), locator()));
  locator.registerLazySingleton(() => GetTodosUseCase(locator()));
  // TodoNotifier는 Riverpod Provider에서 생성하므로, DI에 등록할 필요 없음.
}
```

### **9️⃣ main.dart**
```dart
void main() {
  setupLocator();

  runApp(
    ChangeNotifierProvider(
      create: (context) => locator<TodoProvider>(),
      child: MaterialApp(
        home: TodoScreen(),
      ),
    ),
  );
}
```

---

## **🎯 결론 : Riverpod + Clean Architecture 확장형**
| **구성 요소** | **기능** |
|--------------|---------|
| **UseCase** | 비즈니스 로직 담당 |
| **Repository Pattern** | 데이터 저장소 분리 |
| **Provider** | UI 상태 관리 |
| **DI (get_it)** | 의존성 관리 |
| **Local & Remote Data Source** | 오프라인 지원 (Hive, Dio)|

✔ **소규모 프로젝트** → `MVVM + Riverpod`  
✔ **확장 가능한 프로젝트** → `Clean Architecture + Riverpod`  

---

이제 **확장성이 뛰어난 Riverpod + Clean Architecture 구조**가 완성되었습니다! 🚀

