import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/utils/validators.dart';

class ProjectFormState extends Equatable {
  final String name;
  final String description;
  final String? nameError;

  const ProjectFormState({
    this.name = '',
    this.description = '',
    this.nameError,
  });

  bool get isValid =>
      nameError == null && name.trim().length >= 2 && name.trim().length <= 60;

  ProjectFormState copyWith({
    String? name,
    String? description,
    String? nameError,
    bool clearNameError = false,
  }) {
    return ProjectFormState(
      name: name ?? this.name,
      description: description ?? this.description,
      nameError: clearNameError ? null : (nameError ?? this.nameError),
    );
  }

  @override
  List<Object?> get props => [name, description, nameError];
}

class ProjectFormCubit extends Cubit<ProjectFormState> {
  ProjectFormCubit() : super(const ProjectFormState());

  void nameChanged(String value) {
    final error = Validators.validateProjectName(value);
    emit(
      state.copyWith(
        name: value,
        nameError: error,
        clearNameError: error == null,
      ),
    );
  }

  void descriptionChanged(String value) {
    emit(state.copyWith(description: value));
  }

  bool validate() {
    final error = Validators.validateProjectName(state.name);
    emit(state.copyWith(nameError: error, clearNameError: error == null));
    return error == null;
  }
}
