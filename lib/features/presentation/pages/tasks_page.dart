import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:task_test/core/di/injection.dart';
import 'package:task_test/core/failures.dart';
import 'package:task_test/features/domain/entities/task.dart';
import 'package:task_test/features/domain/usecases/create_task.dart';
import 'package:task_test/features/domain/usecases/update_task.dart';
import 'package:task_test/features/presentation/task/task_bloc.dart';

class TasksPage extends StatelessWidget {
  const TasksPage({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: getIt.getAsync<TaskBloc>(),
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        
        if (snapshot.hasError) {
          return Scaffold(
            body: Center(
              child: Text('Error al inicializar: ${snapshot.error}'),
            ),
          );
        }
        
        return BlocProvider.value(
          value: snapshot.data!..add(const TaskEvent.fetchTasks()),
          child: const TasksView(),
        );
      },
    );
  }
}

class TasksView extends StatelessWidget {
  const TasksView({super.key});

  @override
  Widget build(BuildContext context) {
    // Obtener el bloc del contexto ahora que está disponible vía BlocProvider.value
    final bloc = context.read<TaskBloc>();
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tareas'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => bloc.add(const TaskEvent.fetchTasks()),
          ),
          IconButton(
            icon: const Icon(Icons.delete_sweep),
            onPressed: () => bloc.add(const TaskEvent.clearCache()),
          ),
        ],
      ),
      body: BlocConsumer<TaskBloc, TaskState>(
        listener: (context, state) {
          if (state is Error) {
            // Convertir el failure en un mensaje para el usuario
            final message = _mapFailureToMessage(state.failure);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(message)),
            );
          }
        },
        builder: (context, state) {
          switch (state.runtimeType) {
            case Initial:
              return const Center(child: Text('Inicie la búsqueda de tareas'));
            case Loading:
              return const Center(child: CircularProgressIndicator());
            case Loaded:
              final tasks = (state as Loaded).tasks;
              return tasks.isEmpty
                ? const _EmptyTasksView()
                : _TaskListView(tasks: tasks, bloc: bloc);
            case Error:
              final failure = (state as Error).failure;
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Error: ${_mapFailureToMessage(failure)}'),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => bloc.add(const TaskEvent.fetchTasks()),
                      child: const Text('Reintentar'),
                    ),
                  ],
                ),
              );
            default:
              return const SizedBox.shrink();
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddTaskDialog(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  String _mapFailureToMessage(Failure failure) {
    switch (failure.runtimeType) {
      case NetworkFailure:
        return 'Error de conexión: ${(failure as NetworkFailure).message}';
      case ServerFailure:
        final serverFailure = failure as ServerFailure;
        return 'Error del servidor: ${serverFailure.message}';
      case CacheFailure:
        return 'Error de caché: ${(failure as CacheFailure).message}';
      case ValidationFailure:
        return 'Error de validación: ${(failure as ValidationFailure).message}';
   
      case NotFoundFailure:
        return 'Recurso no encontrado';
      case BadRequestFailure:
        return 'Solicitud incorrecta';
      case UnauthorizedFailure:
        return 'No autorizado';
      case ForbiddenFailure:
        return 'Acceso denegado';
      case InternalServerFailure:
        return 'Error interno del servidor';
      default:
        return 'Error desconocido';
    }
  }

  void _showAddTaskDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => TaskFormDialog(
        onSave: (title, description, dueDate) {
          context.read<TaskBloc>().add(
            TaskEvent.addTask(
              CreateTaskParams(
                title: title,
                description: description,
                dueDate: dueDate,
              ),
            ),
          );
          context.read<TaskBloc>().add(const TaskEvent.fetchTasks());
        },
      ),
    );
  }
}

String _mapFailureToMessage(Failure failure) {
    // Implementa este método para convertir el Failure en un mensaje
    // Por ejemplo:
    if (failure is NetworkFailure) {
      return 'Error de red: ${failure.message}';
    } else if (failure is ServerFailure) {
      return 'Error de servidor: ${failure.message}';
    }
    return 'Error inesperado';
  }

  void _showAddTaskDialog(BuildContext context, TaskBloc bloc) {
    // Implementa este método para mostrar el diálogo
  }


class _EmptyTasksView extends StatelessWidget {
  const _EmptyTasksView();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('No hay tareas disponibles'),
    );
  }
}

class _TaskListView extends StatelessWidget {
  final List<Task> tasks;
  final TaskBloc bloc;

  const _TaskListView({required this.tasks, required this.bloc});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: tasks.length,
      itemBuilder: (context, index) {
        final task = tasks[index];
        return TaskItem(task: task, bloc: bloc);
      },
    );
  }
}

class TaskItem extends StatelessWidget {
  final Task task;
  final TaskBloc bloc;

  const TaskItem({
    super.key,
    required this.task,
    required this.bloc,
  });

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(task.id),
      background: Container(
        color: Colors.red,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 16),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      direction: DismissDirection.endToStart,
      onDismissed: (_) {
        context.read<TaskBloc>().add(TaskEvent.deleteTask(task.id));
      },
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        child: ListTile(
          leading: Checkbox(
            value: task.isCompleted,
            onChanged: (value) {
              if (value != null) {
                context.read<TaskBloc>().add(
                  TaskEvent.updateTask(
                    UpdateTaskParams(
                      id: task.id,
                      title: task.title,
                      description: task.description,
                      dueDate: task.dueDate,
                      isCompleted: value,
                    ),
                  ),
                );
                context.read<TaskBloc>().add(const TaskEvent.fetchTasks());}
            },
          ),
          title: Text(
            task.title,
            style: TextStyle(
              decoration: task.isCompleted ? TextDecoration.lineThrough : null,
              color: task.isCompleted ? Colors.grey : null,
            ),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (task.description.isNotEmpty)
                Text(
                  task.description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              Text(
                'Vence: ${_formatDate(task.dueDate)}',
                style: const TextStyle(
                  fontSize: 12,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
          trailing: IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => _showEditTaskDialog(context, task),
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  void _showEditTaskDialog(BuildContext context, Task task) {
    showDialog(
      context: context,
      builder: (context) => TaskFormDialog(
        initialTitle: task.title,
        initialDescription: task.description,
        initialDueDate: task.dueDate,
        onSave: (title, description, dueDate) {
          context.read<TaskBloc>().add(
            TaskEvent.updateTask(
              UpdateTaskParams(
                id: task.id,
                title: title,
                description: description,
                dueDate: dueDate,
                isCompleted: task.isCompleted,
              ),
            ),
          );
          context.read<TaskBloc>().add(const TaskEvent.fetchTasks());
        },
      ),
    );
  }
}

class TaskFormDialog extends StatefulWidget {
  final String? initialTitle;
  final String? initialDescription;
  final DateTime? initialDueDate;
  final Function(String title, String description, DateTime dueDate) onSave;

  const TaskFormDialog({
    super.key,
    this.initialTitle,
    this.initialDescription,
    this.initialDueDate,
    required this.onSave,
  });

  @override
  State<TaskFormDialog> createState() => _TaskFormDialogState();
}

class _TaskFormDialogState extends State<TaskFormDialog> {
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late DateTime _selectedDate;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.initialTitle ?? '');
    _descriptionController = TextEditingController(text: widget.initialDescription ?? '');
    _selectedDate = widget.initialDueDate ?? DateTime.now().add(const Duration(days: 1));
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.initialTitle == null ? 'Nueva Tarea' : 'Editar Tarea'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Título',
                border: OutlineInputBorder(),
              ),
              autofocus: true,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Descripción',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            ListTile(
              title: const Text('Fecha límite'),
              subtitle: Text(_formatDate(_selectedDate)),
              trailing: const Icon(Icons.calendar_today),
              onTap: () async {
                final pickedDate = await showDatePicker(
                  context: context,
                  initialDate: _selectedDate,
                  firstDate: DateTime.now(),
                  lastDate: DateTime.now().add(const Duration(days: 365)),
                );
                if (pickedDate != null) {
                  setState(() {
                    _selectedDate = pickedDate;
                  });
                }
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: () {
            if (_titleController.text.trim().isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('El título es obligatorio')),
              );
              return;
            }
            widget.onSave(
              _titleController.text.trim(),
              _descriptionController.text.trim(),
              _selectedDate,
            );
            Navigator.pop(context);
          },
          child: const Text('Guardar'),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}