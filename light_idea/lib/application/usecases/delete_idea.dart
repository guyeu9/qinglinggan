import '../../core/logger/app_logger.dart';
import '../../core/utils/result.dart';
import '../../domain/repositories/idea_repository.dart';

class DeleteIdeaUseCase {
  final IdeaRepository _ideaRepository;
  final AppLogger _logger;

  DeleteIdeaUseCase(this._ideaRepository, this._logger);

  Future<Result<void>> execute(int id, {bool permanent = false}) async {
    try {
      final existingIdea = await _ideaRepository.getById(id);
      if (existingIdea == null) {
        _logger.warning('删除灵感失败: 灵感不存在 id=$id');
        return Result.error('灵感不存在');
      }

      if (permanent) {
        await _ideaRepository.permanentDelete(id);
        _logger.info('灵感永久删除成功: id=$id');
      } else {
        await _ideaRepository.softDelete(id);
        _logger.info('灵感软删除成功: id=$id');
      }

      return Result.success(null);
    } catch (e, st) {
      _logger.error('删除灵感失败: id=$id', e, st);
      return Result.error('删除失败: $e', e);
    }
  }
}
