import '../../core/logger/app_logger.dart';
import '../../core/utils/result.dart';
import '../../domain/repositories/idea_repository.dart';

class RestoreIdeaUseCase {
  final IdeaRepository _ideaRepository;
  final AppLogger _logger;

  RestoreIdeaUseCase(this._ideaRepository, this._logger);

  Future<Result<void>> execute(int id) async {
    try {
      final existingIdea = await _ideaRepository.getById(id);
      if (existingIdea == null) {
        _logger.warning('恢复灵感失败: 灵感不存在 id=$id');
        return Result.error('灵感不存在');
      }

      if (!existingIdea.isDeleted) {
        _logger.warning('恢复灵感失败: 灵感未被删除 id=$id');
        return Result.error('灵感未被删除，无需恢复');
      }

      await _ideaRepository.restore(id);
      _logger.info('灵感恢复成功: id=$id');

      return Result.success(null);
    } catch (e, st) {
      _logger.error('恢复灵感失败: id=$id', e, st);
      return Result.error('恢复失败: $e', e);
    }
  }
}
