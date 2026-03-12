import '../../core/constants/app_constants.dart';
import '../../core/logger/app_logger.dart';
import '../../core/utils/result.dart';
import '../../domain/entities/idea.dart';
import '../../domain/repositories/idea_repository.dart';

class UpdateIdeaUseCase {
  final IdeaRepository _ideaRepository;
  final AppLogger _logger;

  UpdateIdeaUseCase(this._ideaRepository, this._logger);

  Future<Result<IdeaEntity>> execute(int id, String newContent) async {
    if (newContent.trim().isEmpty) {
      return Result.error('内容不能为空');
    }

    if (newContent.length > AppConstants.maxContentLength) {
      return Result.error('内容长度不能超过${AppConstants.maxContentLength}字符');
    }

    try {
      final existingIdea = await _ideaRepository.getById(id);
      if (existingIdea == null) {
        _logger.warning('更新灵感失败: 灵感不存在 id=$id');
        return Result.error('灵感不存在');
      }

      if (existingIdea.isDeleted) {
        _logger.warning('更新灵感失败: 灵感已删除 id=$id');
        return Result.error('无法更新已删除的灵感');
      }

      final updatedIdea = existingIdea.copyWith(
        content: newContent.trim(),
        updatedAt: DateTime.now(),
        aiStatus: AIStatus.pending,
      );

      await _ideaRepository.update(updatedIdea);

      _logger.info('灵感更新成功: id=$id');

      return Result.success(updatedIdea);
    } catch (e, st) {
      _logger.error('更新灵感失败: id=$id', e, st);
      return Result.error('更新失败: $e', e);
    }
  }
}
