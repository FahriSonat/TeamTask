// Dosya: lib/features/projects/presentation/cubit/project_form_cubit.dart
// "Yeni Proje" formunun anlık durumu ve doğrulaması.

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/utils/validators.dart';

/// Formdaki ad, açıklama ve ad hatası.
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

/// Her tuşta adı doğrular; kaydet'te son kontrolü yapar.
class ProjectFormCubit extends Cubit<ProjectFormState> {
  ProjectFormCubit() : super(const ProjectFormState());

  /// Ad değişti -> anında doğrula.
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

  /// Açıklama değişti.
  void descriptionChanged(String value) {
    emit(state.copyWith(description: value));
  }

  /// Kaydetmeden önce son kontrol; geçerliyse true.
  bool validate() {
    final error = Validators.validateProjectName(state.name);
    emit(state.copyWith(nameError: error, clearNameError: error == null));
    return error == null;
  }
}
